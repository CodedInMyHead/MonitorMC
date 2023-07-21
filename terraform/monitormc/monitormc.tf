resource "google_compute_network" "vpc_network" {
  name                    = "monitormc-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  project = var.project_id
}

resource "google_compute_subnetwork" "default" {
  name          = "monitormc"
  ip_cidr_range = "10.0.69.0/24"
  region        = "europe-west3"
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
    ports    = ["3000","8123","9090","25565"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "monitormc" {
  name         = var.hostname
  machine_type = "e2-standard-16"
  zone         = "europe-west3-a"
  project = var.project_id
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 10
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
      "sudo mkdir -p ${var.target_dir}/plugins/",
      "sudo mkdir -p ${var.target_dir}/scripts/",
      "sudo mkdir -p ${var.target_dir}/prometheus/",
      "sudo chmod -R a+rwx ${var.target_dir}/",
    ]
  }

  provisioner "file" {
    source      = "./../../scripts/"
    destination = "${var.target_dir}/scripts"
  }

  provisioner "file" {
    source      = "./../../prometheus/"
    destination = "${var.target_dir}/prometheus"
  }

  provisioner "file" {
    source      = "./../../docker-compose.yml"
    destination = "${var.target_dir}/docker-compose.yml"
  }

    provisioner "file" {
    source      = "./../../plugins/"
    destination = "${var.target_dir}/plugins"
  }

  provisioner "remote-exec" {
      inline = [
        "cd ${var.target_dir}/scripts",
        "sudo chmod a+x start.sh",
        "sudo addgroup --system docker",
        "sudo ${var.target_dir}/scripts/start.sh",
      ]
    }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      nat_ip = var.public_ip
    }
  }
}