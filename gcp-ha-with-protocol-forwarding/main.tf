/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  image = "debian-cloud/debian-11"
  machine_type = "f1-micro"
}

resource "google_project_service" "required_api" {
  for_each = toset(["compute.googleapis.com", "cloudresourcemanager.googleapis.com"])
  service  = each.key
}

# Retrieve BYOIP addresses using a datasource filtering on name with prefix "ha-pf-byoip"
# This means that all BYOIP addresses shall be named starting with this prefix
data "google_compute_addresses" "byoip_addresses" {
    filter = "name:ha-pf-byoip*"
}

resource "google_compute_network" "ha_pf_vpc" {
  depends_on              = [google_project_service.required_api]
  name                    = "ha-pf-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ha_pf_subnet" {
  name          = "ha-pf-subnet"
  ip_cidr_range = var.subnet_range
  network       = google_compute_network.ha_pf_vpc.id
}

resource "google_compute_router" "ha_pf_router" {
  name    = "ha-pf-router"
  region  = var.region
  network = google_compute_network.ha_pf_vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "ha-pf-router-nat"
  router                             = google_compute_router.ha_pf_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_project_iam_custom_role" "nginx_gateway_custom_role" {
  role_id     = "nginx_gateway_role"
  title       = "Nginx Gateway Custome Role"
  description = "Grant Nginx Gateways basic permissions"
  permissions = [
    "compute.instances.list",
    "compute.instances.get"
  ]
}

resource "google_service_account" "nginx_gateway_sa" {
  account_id = "nginx-gateway-sa"
  display_name = "Nginx Gateway Service Account"
}

resource "google_project_iam_member" "nginx_binding" {
  project = var.project_id
  role    = "projects/${var.project_id}/roles/nginx_gateway_role"
  member  = "serviceAccount:${google_service_account.nginx_gateway_sa.email}"
}

# Authorize HTTP/HTTPS traffic to Nginx gateway from all sources
# A better and more restrictive way would be to authorize SMTP traffic
# only from MTA IP ranges to the Nginx IP forwarded addresses (BYOIP or dedicated IPs)
resource "google_compute_firewall" "ha_pf_firewall_http" {
  name = "ha-pf-http-traffic"
  allow {
    protocol = "tcp"
    ports    = [443, 80]
  }
  network     = google_compute_network.ha_pf_vpc.id
  #source_tags = ["client"]
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["nginx-gateway"]
}

resource "google_compute_firewall" "ha_pf_firewall_ssh_iap" {
  name = "ha-pf-ssh-iap"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  network = google_compute_network.ha_pf_vpc.id
  #IP range used by Identity-Aware-Proxy
  #See https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "ha_pf_firewall_hc" {
  name = "ha-pf-hc"
  allow {
    protocol = "tcp"
    ports    = [var.health_check_port]
  }
  network = google_compute_network.ha_pf_vpc.id
  #IP ranges used for health checks
  #See https://cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs#setting_up_an_autohealing_policy
  source_ranges = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
}

# Create as many dedicated external IP addresses as needed
# Should use BYOIPs instead of allocated public IPs for production email sending
# If the use-byoip flag is set to true, those dedicated public IPs will not be
# created
resource "google_compute_address" "ha_pf_ip" {
  count        = var.use_byoip ? 0 : var.dedicated_ip_number
  name = "ha-pf-ip-${count.index}"
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = "STANDARD"
}

resource "google_compute_instance" "nginx_instance" {
  count = var.nginx_instances_number
  name  = "ha-pf-nginx-${count.index + 1}"
  machine_type = local.machine_type
  zone  = var.zone
  boot_disk {
    initialize_params {
        image = local.image
        type = "pd-standard"
    }
  }
  metadata_startup_script = templatefile("startup-script.tmpl", {
    instance_number= count.index+1
  })
  tags = ["nginx-gateway", "http-server", "https-server"]
  
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.nginx_gateway_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ha_pf_subnet.id
  }
}

resource "google_compute_target_pool" "target_pool_nginx" {
  name = "ha-pf-target-pool-nginx"

  instances = google_compute_instance.nginx_instance[*].self_link
  
  session_affinity = "CLIENT_IP_PROTO"

  health_checks = [
    google_compute_http_health_check.ha_pf_target_pool_health_check.name
  ]
}

resource "google_compute_http_health_check" "ha_pf_target_pool_health_check" {
  depends_on = [google_project_service.required_api]
  name                = "ha-pf-target-pool-health-check"
  check_interval_sec  = 1
  timeout_sec         = 1
  healthy_threshold   = 2
  unhealthy_threshold = 3 # 3 seconds
}

resource "google_compute_forwarding_rule" "ha_pf_forwarding_rule" {
  depends_on    = [google_compute_target_pool.target_pool_nginx]
  count         = var.use_byoip ? length(data.google_compute_addresses.byoip_addresses.addresses[*].address) : length(google_compute_address.ha_pf_ip[*])
  name          = "ha-pf-forwarding-rule-outbound-${count.index+1}"
  target        = google_compute_target_pool.target_pool_nginx.id
  ip_protocol   = "TCP"
  all_ports     = true
  ip_address    = var.use_byoip ? data.google_compute_addresses.byoip_addresses.addresses[count.index].address : google_compute_address.ha_pf_ip[count.index].address
  network_tier  = "STANDARD"
}

output "instances" {
  value       = google_compute_instance.nginx_instance[*].id
  description = "The nginx instance ids"
}