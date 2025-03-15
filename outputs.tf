output "start_vms_function_url" {
  value = google_cloudfunctions_function.start_vms.https_trigger_url
}

output "stop_vms_function_url" {
  value = google_cloudfunctions_function.stop_vms.https_trigger_url
}
