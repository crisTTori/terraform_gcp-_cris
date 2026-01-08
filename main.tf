 # Configuración servicio Google Cloud
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("./sigma-chemist-480216-i9-915c82de1f11.json")
  project = "sigma-chemist-480216-i9"
  region = "europe-west1"
  zone = "europe-west1-b"
}

# Red virtual
resource "google_compute_network" "red_practica" {
  name = "red-terraform"
  auto_create_subnetworks = true
}

# Bucket de almacenamiento
resource "google_storage_bucket" "bucket_practica" {
  name = "terraform-sigma-chemist-480216-i9"
  location = "EU"
  force_destroy = true
}

# Instancia virtual
resource "google_compute_instance" "vm_practica" {
  name = "vm-terraform"
  machine_type = "e2-micro"
  zone = "europe-west1-b"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network = google_compute_network.red_practica.name
    access_config {
    }
  }
}
