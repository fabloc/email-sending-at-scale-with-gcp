/**
 * Copyright 2021 Google LLC
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
 
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region used to deploy resources"
  default     = "europe-west1"
}

variable "zone" {
  description = "Google Cloud Zone used to deploy resources"
  default     = "europe-west1-b"
}


variable "subnet_range" {
  description = "IP address range used for the subnet"
  default     = "10.100.0.0/16"
}

variable "floating_ip_ranges" {
  description = "Alias IP Ranges that will be used by clients to access the Nginx Gateway"
  type        = list
  default     = ["192.168.0.0/24","192.168.1.0/24"]
}

variable "primary_ip" {
  description = "IP address of the primary VM"
  default     = "10.100.2.1"
}

variable "secondary_ip" {
  description = "IP address of the secondary VM"
  default     = "10.100.2.2"
}

variable "health_check_port" {
  description = "TCP port used for health check"
  default     = 80
}

variable "vrrp_password" {
  description = "Password used for VRRP between instances"
}