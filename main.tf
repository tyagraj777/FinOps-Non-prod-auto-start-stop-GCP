provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "dev_instance" {
  name         = "dev-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_instance" "staging_instance" {
  name         = "staging-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_storage_bucket" "function_bucket" {
  name = "${var.project_id}-function-bucket"
}

resource "google_storage_bucket_object" "start_function" {
  name   = "start_vms.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./cloud-functions/start_vms/start_vms.zip"
}

resource "google_storage_bucket_object" "stop_function" {
  name   = "stop_vms.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./cloud-functions/stop_vms/stop_vms.zip"
}

resource "google_cloudfunctions_function" "start_vms" {
  name        = "start-vms-function"
  runtime     = "python310"
  entry_point = "start_vms"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.start_function.name

  trigger_http = true

  environment_variables = {
    PROJECT_ID = var.project_id
    ZONE       = var.zone
  }
}

resource "google_cloudfunctions_function" "stop_vms" {
  name        = "stop-vms-function"
  runtime     = "python310"
  entry_point = "stop_vms"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.stop_function.name

  trigger_http = true

  environment_variables = {
    PROJECT_ID = var.project_id
    ZONE       = var.zone
  }
}

resource "google_cloud_scheduler_job" "start_vms_job" {
  name        = "start-vms-job"
  description = "Trigger start-vms Cloud Function every weekday at 8 AM"
  schedule    = "0 8 * * 1-5"
  time_zone   = "America/Los_Angeles"

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.start_vms.https_trigger_url
    oidc_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}

resource "google_cloud_scheduler_job" "stop_vms_job" {
  name        = "stop-vms-job"
  description = "Trigger stop-vms Cloud Function every weekday at 8 PM"
  schedule    = "0 20 * * 1-5"
  time_zone   = "America/Los_Angeles"

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.stop_vms.https_trigger_url
    oidc_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}

resource "google_service_account" "scheduler_sa" {
  account_id   = "scheduler-sa"
  display_name = "Cloud Scheduler Service Account"
}

resource "google_project_iam_member" "scheduler_sa_role" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

resource "google_project_iam_member" "cloud_function_role" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}
