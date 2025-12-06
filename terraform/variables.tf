variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  sensitive   = true
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  default     = "b1gc2ba7jfvljkdq70r6"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "elastic_password" {
  description = "Password for Elasticsearch"
  type        = string
  sensitive   = true
}

variable "zabbix_password" {
  description = "Password for Zabbix"
  type        = string
  sensitive   = true
}

variable "kibana_password" {
  description = "Password for Kibana"
  type        = string
  sensitive   = true
}
