variable "yandex_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yandex_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  sensitive   = true
}

variable "yandex_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = ""
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  sensitive   = true
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
  sensitive   = true
}
