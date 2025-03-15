import google.auth
from googleapiclient import discovery

def start_vms(request):
    credentials, project = google.auth.default()
    service = discovery.build('compute', 'v1', credentials=credentials)

    instances = ["dev-instance", "staging-instance"]
    zone = "us-central1-a"

    for instance in instances:
        service.instances().start(project=project, zone=zone, instance=instance).execute()

    return "VMs started successfully", 200
