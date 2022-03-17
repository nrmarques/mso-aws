# Author: NMARQUES
# Description: Variable definitions for MSO login.

variable "mso_url" {
  type        = string
  description = "The URL of ACI MSO"
  default     = "https://10.150.178.65"
}

variable "mso_username" {
  type        = string
  description = "Username of the MSO admin user"
  default     = "admin"
}

variable "mso_password" {
  type        = string
  description = "Password of the MSO admin user"
  default     = "cisco123"
}

variable "tenant" {
  type    = string
  default = "Cliente_A"
}

variable "vrf" {
  type    = string
  default = "vrf_streched"
}

variable "on_prem_site" {
  type    = string
  default = "SITE1"
}

variable "aws_site" {
  type    = string
  default = "cAPIC-AWS"
}

variable "hybrid_schema" {
  default = {
      name = "streched"
      template_name = "streched"

  }
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_subnet" {
  type    = string
  default = "11.11.0.0/24"
}

variable "aws_cidr" {
  type    = string
  default = "11.11.0.0/16"
}

variable "aws_az" {
  type    = string
  default = "eu-central-1a"
}

variable "anp" {
  type    = string
  default = "streched-app"
}

variable "bd_display_name" {
  type    = string
  default = "bd1"
}

variable "bd_local" {
  type    = string
  default = "bd1"
}

variable "bd_local_gw" {
  type    = string
  default = "192.168.1.254/24"
}

variable "epg_streched" {
  type    = string
  default = "epg1"
}

variable "vmm_type" {
  type    = string
  default = "vmmDomain"
}

variable "vmm_name" {
  type    = string
  default = "VMM_vCenter60"
}

