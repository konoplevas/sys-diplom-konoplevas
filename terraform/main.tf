terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

# Используем существующую сеть diplom-net
data "yandex_vpc_network" "existing" {
  network_id = "enp10co0ihe62ni6nhe9"
}

# Используем существующие подсети
data "yandex_vpc_subnet" "public-a" {
  subnet_id = "e9bd6pedqfkq72v9pljb"
}

data "yandex_vpc_subnet" "public-b" {
  subnet_id = "e2lo6me7svv8dcdjc9qc"
}

data "yandex_vpc_subnet" "private-a" {
  subnet_id = "e9bguf5rep4rf738dcol"
}

data "yandex_vpc_subnet" "private-b" {
  subnet_id = "e2leg2v65kq5gbhin225"
}

# BASTION host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 10
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.public-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# WEB1 в приватной зоне A
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  hostname    = "web1"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 10
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.private-a.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# WEB2 в приватной зоне B  
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  hostname    = "web2"
  platform_id = "standard-v2"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 10
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.private-b.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# ZABBIX сервер
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 15
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.public-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# Elasticsearch сервер
resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 15
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.private-a.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# Kibana сервер
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size     = 10
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.public-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# Используем существующие ALB компоненты

# NAT Gateway
resource "yandex_vpc_gateway" "nat-gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat-route" {
  name       = "nat-route"
  network_id = "enp10co0ihe62ni6nhe9"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}

# Обновляем приватные подсети чтобы использовали NAT


# Security Groups
resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-security-group"
  network_id = data.yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix_sg" {
  name       = "zabbix-security-group"
  network_id = data.yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP for web interface"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ALB Health Checks"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix agent"
    port           = 10050
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix server"
    port           = 10051
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic_sg" {
  name       = "elastic-security-group"
  network_id = data.yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "Elasticsearch HTTP"
    port           = 9200
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Kibana"
    port           = 5601
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Groups
# ALB для Zabbix
resource "yandex_alb_target_group" "zabbix_tg" {
  name = "zabbix-target-group"

  target {
    subnet_id  = data.yandex_vpc_subnet.public-a.id
    ip_address = yandex_compute_instance.zabbix.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "zabbix_bg" {
  name = "zabbix-backend-group"

  http_backend {
    name             = "zabbix-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.zabbix_tg.id]

    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "zabbix_router" {
  name = "zabbix-router"
}

resource "yandex_alb_virtual_host" "zabbix_host" {
  name           = "zabbix-virtual-host"
  http_router_id = yandex_alb_http_router.zabbix_router.id

  route {
    name = "zabbix-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.zabbix_bg.id
        timeout          = "60s"
      }
    }
  }
}

#resource "yandex_alb_load_balancer" "zabbix_alb" {
#  name               = "zabbix-load-balancer"
#  network_id         = data.yandex_vpc_network.existing.id
#
#  allocation_policy {
#    location {
#      zone_id   = "ru-central1-a"
#      subnet_id = data.yandex_vpc_subnet.public-a.id
#    }
#  }
#
#  listener {
#    name = "zabbix-listener"
#    endpoint {
#      address {
#        external_ipv4_address {
#        }
#      }
#      ports = [80]
#    }
#    http {
#      handler {
#        http_router_id = yandex_alb_http_router.zabbix_router.id
#      }
#    }

# Security Group specifically for ALB
resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-security-group"
  network_id = data.yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ALB Health Checks"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source for existing working ALB
data "yandex_alb_load_balancer" "existing" {
  name = "web-balancer"
}


# Output for verification




# Daily snapshot schedules for all VMs
resource "yandex_compute_snapshot_schedule" "daily_backups" {
  name             = "daily-snapshots"
  description      = "Daily backups for all VMs"
  snapshot_count   = 7
  retention_period = "604800s" # 7 days in seconds

  schedule_policy {
    expression = "0 2 * * *" # Daily at 02:00 AM
  }

  snapshot_spec {}

  # List of all VM disks
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web1.boot_disk.0.disk_id,
    yandex_compute_instance.web2.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id
  ]
}

output "snapshot_schedule_id" {
  value       = yandex_compute_snapshot_schedule.daily_backups.id
  description = "Snapshot schedule ID"
}
