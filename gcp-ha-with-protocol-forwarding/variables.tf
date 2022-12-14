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

variable "health_check_port" {
  description = "TCP port used for health check"
  default     = 80
}

variable "nginx_instances_number" {
  description = "Number of Instances to create in the Target Pool - use at least 2 for redundancy"
  default     = 2
}

variable "dedicated_ip_number" {
  description = "If not using BYOIP ('use_byoip' set to 'false'), number of dedicated public IPs to create"
  default     = 5
}

variable "use_byoip" {
  description = "Boolean indicating whether to use BYOIP or dedicated public IPs"
}