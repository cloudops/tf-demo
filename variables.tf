# Required variables
variable "api_key" {}

variable "organization" {
    default = "juniper"
}

variable "username" {
    default = "demo"
}

variable "admin_role" {
    type = "list"
    default = ["wstevens"]
}

variable "api_url" {
    default = "https://api.cloud.ca/v1"
}

variable "service_name" {
    default = "compute-on"
}

variable "zone" {
    default = "ON-1"
}

# default network offering w/ LB
variable "network_offering" {
    default = "Load Balanced Tier"
}

# default template type
variable "template" {
    default = "CentOS 7.6"
}

# default compute offering
variable "compute_offering" {
    default = "Standard"
}

variable "master_vcpu_count" {
    default = 8
}
variable "master_ram_in_mb" {
    default = 32768
}
variable "master_root_volume_size_in_gb" {
    default = 100
}

variable "worker_vcpu_count" {
    default = 8
}
variable "worker_ram_in_mb" {
    default = 16384
}
variable "worker_root_volume_size_in_gb" {
    default = 50
}

variable "tf_repo" {
    default = "docker.io/opencontrailnightly"
    #default = "docker.io/tungstenfabric"
}
variable "tf_release" {
    default = "latest"
    #default="r5.0.1"
}
variable "tf_pod_cidr" {
    default = "10.32.0.0/12"
}
variable "tf_service_cidr" {
    default = "10.96.0.0/12"
}
variable "tf_ip_fabric_cidr" {
    default = "10.64.0.0/12"
}
variable "tf_ui_password" {}