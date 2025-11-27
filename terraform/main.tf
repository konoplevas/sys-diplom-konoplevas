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
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
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
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
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
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
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
    cores  = 2
    memory = 4
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
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
    cores  = 2
    memory = 4
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
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
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa_diploma.pub")}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# Используем существующие ALB компоненты
data "yandex_alb_target_group" "existing" {
  name = "web-target-group"
}

data "yandex_alb_backend_group" "existing" {
  name = "web-backend-group"
}

data "yandex_alb_http_router" "existing" {
  name = "web-router"
}

data "yandex_vpc_security_group" "alb-sg" {
  name = "alb-sg"
}

data "yandex_alb_load_balancer" "existing" {
  name = "web-balancer"
}

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


# Snapshot schedule для резервного копирования (соответствует требованиям диплома)

# Snapshot schedule для резервного копирования (точное соответствие диплому)
resource "yandex_compute_snapshot_schedule" "daily-backup" {
  name = "daily-backup"

  schedule_policy {
    expression = "0 2 * * *"  # Ежедневное копирование в 2:00
  }

  retention_period = "168h"  # Ограничение времени жизни - неделя (168 часов)

  snapshot_spec {
    description = "Daily backup - Diploma project"
  }

  # Все диски ВМ
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web1.boot_disk.0.disk_id,
    yandex_compute_instance.web2.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
  ]
}
