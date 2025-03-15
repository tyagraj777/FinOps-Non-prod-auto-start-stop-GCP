import google.auth
from googleapiclient import discovery
from googleapiclient.errors import HttpError

def start_vms(request):
    """
    Cloud Function to start VM instances.
    """
    try:
        # Authenticate and create the Compute Engine API client
        credentials, project = google.auth.default()
        service = discovery.build('compute', 'v1', credentials=credentials)

        # List of VM instances to start
        instances = ["dev-instance", "staging-instance"]
        zone = "us-central1-a"  # Zone where the VMs are located

        # Start each VM instance
        for instance in instances:
            print(f"Starting instance: {instance}")
            operation = service.instances().start(
                project=project,
                zone=zone,
                instance=instance
            ).execute()
            print(f"Operation status for {instance}: {operation['status']}")

        return "VMs started successfully", 200

    except HttpError as e:
        print(f"An error occurred: {e}")
        return f"Failed to start VMs: {e}", 500
