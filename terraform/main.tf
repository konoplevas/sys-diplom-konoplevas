terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.3.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "existing" {
  name        = "diplom-net"
  description = "Main network for diploma project"
}

resource "yandex_vpc_subnet" "public-a" {
  name           = "diploma-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.existing.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "diploma-public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.existing.id
  v4_cidr_blocks = ["10.131.0.0/24"]
}

resource "yandex_vpc_subnet" "private-a" {
  name           = "diploma-private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.existing.id
  v4_cidr_blocks = ["10.132.0.0/24"]
}

resource "yandex_vpc_subnet" "private-b" {
  name           = "diploma-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.existing.id
  v4_cidr_blocks = ["10.133.0.0/24"]
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat-route" {
  name       = "nat-route"
  network_id = yandex_vpc_network.existing.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}

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
    subnet_id = yandex_vpc_subnet.public-a.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

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
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

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
    subnet_id = yandex_vpc_subnet.private-b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

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
    subnet_id = yandex_vpc_subnet.public-a.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.zabbix_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

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
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.elastic_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

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
    subnet_id = yandex_vpc_subnet.public-a.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.kibana_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-security-group"
  network_id = yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent"
    port           = 10050
    v4_cidr_blocks = ["10.130.0.0/24"]  # Zabbix server subnet
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-security-group"
  network_id = yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    port           = 22
    v4_cidr_blocks = ["10.130.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent"
    port           = 10050
    v4_cidr_blocks = ["10.130.0.0/24"]  # Zabbix server subnet
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix_sg" {
  name       = "zabbix-security-group"
  network_id = yandex_vpc_network.existing.id

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
  network_id = yandex_vpc_network.existing.id

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

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent"
    port           = 10050
    v4_cidr_blocks = ["10.130.0.0/24"]  # Zabbix server subnet
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana_sg" {
  name       = "kibana-security-group"
  network_id = yandex_vpc_network.existing.id

  ingress {
    protocol       = "TCP"
    description    = "Kibana Web Interface"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix Agent"
    port           = 10050
    v4_cidr_blocks = ["10.130.0.0/24"]  # Zabbix server subnet
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_alb_target_group" "web_tg" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web_bg" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]

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

resource "yandex_alb_http_router" "web_router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web_host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web_alb" {
  name               = "web-balancer"
  network_id         = yandex_vpc_network.existing.id
  region_id          = "ru-central1"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public-b.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}

resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-security-group"
  network_id = yandex_vpc_network.existing.id

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

resource "yandex_compute_snapshot_schedule" "daily_backups" {
  name             = "daily-snapshots"
  description      = "Daily backups for all VMs"
  snapshot_count   = 7
  retention_period = "604800s"

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_spec {}

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web1.boot_disk.0.disk_id,
    yandex_compute_instance.web2.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id
  ]
}

