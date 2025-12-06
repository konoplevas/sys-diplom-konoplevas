output "bastion_external_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "zabbix_external_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana_external_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "web1_internal_ip" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "web2_internal_ip" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "elastic_internal_ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}

output "snapshot_schedule_id" {
  value = yandex_compute_snapshot_schedule.daily_backups.id
}
