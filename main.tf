# ============================================
# CONFIGURACIÓN DEL PROVEEDOR DE GOOGLE CLOUD
# ============================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configuración del proveedor de Google Cloud
provider "google" {
  credentials = file("./sigma-chemist-480216-i9-915c82de1f11.json")
  project     = "sigma-chemist-480216-i9"
  region      = "europe-west1"
  zone        = "europe-west1-b"
}

# ============================================
# RECURSOS A CREAR
# ============================================

# 1. RED VIRTUAL (VPC)
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = true
  description             = "Red virtual creada con Terraform para la práctica"
}

# 2. BUCKET DE CLOUD STORAGE
resource "google_storage_bucket" "storage_bucket" {
  name          = "terraform-bucket-practica-${var.project_id}"
  location      = "EU"
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = false
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# 3. INSTANCIA DE COMPUTE ENGINE
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-vm-instance"
  machine_type = "e2-micro"  # Tipo de máquina económico
  zone         = "europe-west1-b"
  
  tags = ["terraform", "practica"]
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
    
    # Asignar IP pública
    access_config {
      // IP efímera
    }
  }
  
  # Script de inicio
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "VM creada con Terraform" > /var/www/html/index.html
  EOF
  
  # Permitir que Terraform destruya la instancia
  allow_stopping_for_update = true
}

# ============================================
# VARIABLES
# ============================================

variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
  default     = "sigma-chemist-480216-i9"
}

# ============================================
# OUTPUTS
# ============================================

output "vpc_network_name" {
  description = "Nombre de la red VPC creada"
  value       = google_compute_network.vpc_network.name
}

output "bucket_url" {
  description = "URL del bucket de Cloud Storage"
  value       = google_storage_bucket.storage_bucket.url
}

output "vm_instance_external_ip" {
  description = "IP pública de la instancia VM"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "vm_instance_internal_ip" {
  description = "IP interna de la instancia VM"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}
