import google.auth
from googleapiclient import discovery

def stop_vms(request):
    credentials, project = google.auth.default()
    service = discovery.build('compute', 'v1', credentials=credentials)

    instances = ["dev-instance", "staging-instance"]
    zone = "us-central1-a"

    for instance in instances:
        service.instances().stop(project=project, zone=zone, instance=instance).execute()

    return "VMs stopped successfully", 200
