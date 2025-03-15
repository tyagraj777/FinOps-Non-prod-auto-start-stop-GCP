import google.auth
from googleapiclient import discovery
from googleapiclient.errors import HttpError

def stop_vms(request):
    """
    Cloud Function to stop VM instances.
    """
    try:
        # Authenticate and create the Compute Engine API client
        credentials, project = google.auth.default()
        service = discovery.build('compute', 'v1', credentials=credentials)

        # List of VM instances to stop
        instances = ["dev-instance", "staging-instance"]
        zone = "us-central1-a"  # Zone where the VMs are located

        # Stop each VM instance
        for instance in instances:
            print(f"Stopping instance: {instance}")
            operation = service.instances().stop(
                project=project,
                zone=zone,
                instance=instance
            ).execute()
            print(f"Operation status for {instance}: {operation['status']}")

        return "VMs stopped successfully", 200

    except HttpError as e:
        print(f"An error occurred: {e}")
        return f"Failed to stop VMs: {e}", 500
