resource "google_compute_network" "vpc_network" {
  name                    = "monitormc-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  project = var.project_id
}

resource "google_compute_subnetwork" "default" {
  name          = "monitormc"
  ip_cidr_range = "10.0.69.0/24"
  region        = var.zone
  network       = google_compute_network.vpc_network.id
  project = var.project_id
}


resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  project = var.project_id
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1
  source_ranges = var.concourse_allowlist
}

resource "google_compute_firewall" "http" {
  name = "allow-http"
  project = var.project_id
  allow {
    ports    = ["80","8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 0
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "https" {
  name = "allow-https"
  project = var.project_id
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "plugins" {
  name = "allow-plugins"
  project = var.project_id
  allow {
    ports    = ["8123","9000","3000","25565"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "monitormc" {
  name         = var.hostname
  machine_type = "e2-standard-2"
  zone         = "${var.zone}-a"
  project = var.project_id
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 20
    }
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host = var.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.target_dir}/",
      "sudo mkdir -p ${var.target_dir}/prometheus",
      "sudo mkdir -p ${var.target_dir}/plugins",
      "sudo chown -R root:root ${var.target_dir}"
    ]
  }

  provisioner "file" {
    source      = "./../../prometheus/prometheus.yml"
    destination = "${var.target_dir}/prometheus/"
  }

  provisioner "file" {
    source      = "./../../docker-compose.yml"
    destination = "${var.target_dir}/docker-compose.yml"
  }

  provisioner "file" {
    source      = "./../../plugins/"
    destination = "${var.target_dir}/plugins/"
  }

  provisioner "file" {
    source      = "./../../ssh_keygen.sh"
    destination = "${var.target_dir}/ssh_keygen.sh"
  }

  provisioner "remote-exec" {
      inline = [
        "sudo find ${var.target_dir} -name \"*.sh\" | sudo xargs chmod a+x",
        "sudo addgroup --system docker",
        "sudo ${var.target_dir}/scripts/create_github_users.sh \"${var.concourse_users}\"", # Add github usernames in terraform variable file to automatically put public ssh keys on vm
        "sudo ./${var.target_dir}/ssh_keygen.sh",
        "sudo start.sh"
      ]
    }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      nat_ip = var.public_ip
    }
  }
}