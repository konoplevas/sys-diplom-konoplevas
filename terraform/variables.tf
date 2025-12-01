variable "yc_token" {
  type        = string
  sensitive   = true
  description = "Yandex Cloud OAuth token"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = "~/.ssh/id_rsa_diploma.pub"
}
