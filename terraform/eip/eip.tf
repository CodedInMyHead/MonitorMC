resource "google_compute_address" "MonitorMC-Address" {
  name = "static-monitormc-ip"
  project = var.project_id
  address_type = "EXTERNAL"
}
resource "google_dns_record_set" "MonitorMC" {
  name = "${var.hostname}.${google_dns_managed_zone.MonitorMC.dns_name}"
  type = "A"
  ttl  = 300
  managed_zone = google_dns_managed_zone.MonitorMC.name
  rrdatas = [google_compute_address.MonitorMC-Address.address]
}

resource "google_dns_managed_zone" "MonitorMC" {
  name     = var.hostname
  dns_name = "gcp.cfn.sapcloud.io." 
  dnssec_config {
    state = "on"
  }
}