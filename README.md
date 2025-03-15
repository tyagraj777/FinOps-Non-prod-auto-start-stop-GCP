# FinOps-Non-prod-auto-start-stop-GCP
project aims to reduce costs by automatically stopping non-production environments (e.g., development, staging) during off-hours using Google Cloud Platform (GCP) services


   
Here’s a concise `README.md` for the **Scheduled Start/Stop of Non-Production Environments** project. It provides an overview, prerequisites, deployment steps, and testing instructions.

---

# **Scheduled Start/Stop of Non-Production Environments**

This project automates the start and stop of non-production VM instances (e.g., development, staging) in Google Cloud Platform (GCP) during off-hours to reduce costs.

---

## **Prerequisites**
1. **Google Cloud Platform (GCP) Account**:
   - A GCP project with billing enabled.
2. **Google Cloud SDK**:
   - Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
3. **Terraform**:
   - Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
4. **Python**:
   - Install Python 3.10 or higher.

---

## **Folder Structure**
```
scheduled-vm-start-stop/
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Terraform variables
├── outputs.tf               # Terraform outputs
├── cloud-functions/
│   ├── start_vms/           # Start VMs Cloud Function
│   │   ├── main.py          # Python script to start VMs
│   │   ├── requirements.txt # Python dependencies
│   │   └── start_vms.zip    # Zipped Cloud Function code
│   └── stop_vms/            # Stop VMs Cloud Function
│       ├── main.py          # Python script to stop VMs
│       ├── requirements.txt # Python dependencies
│       └── stop_vms.zip     # Zipped Cloud Function code
└── README.md                # Project documentation
```

---

## **Deployment Steps**

### **1. Clone the Repository**
```bash
git clone <repository-url>
cd scheduled-vm-start-stop
```

### **2. Initialize Terraform**
```bash
terraform init
```

### **3. Apply Terraform Configuration**
```bash
terraform apply
```
- Provide the required variables (e.g., `project_id`, `region`, `zone`) when prompted.

### **4. Deploy Cloud Functions**
1. **Zip the Cloud Function Files**:
   ```bash
   cd cloud-functions/start_vms
   zip start_vms.zip main.py requirements.txt
   cd ../stop_vms
   zip stop_vms.zip main.py requirements.txt
   ```

2. **Upload to Google Cloud Storage**:
   ```bash
   gsutil cp start_vms.zip gs://<your-bucket-name>/
   gsutil cp stop_vms.zip gs://<your-bucket-name>/
   ```

3. **Deploy the Functions**:
   ```bash
   gcloud functions deploy start-vms-function \
     --runtime python310 \
     --trigger-http \
     --entry-point start_vms \
     --source gs://<your-bucket-name>/start_vms.zip \
     --set-env-vars PROJECT_ID=<your-project-id>,ZONE=us-central1-a

   gcloud functions deploy stop-vms-function \
     --runtime python310 \
     --trigger-http \
     --entry-point stop_vms \
     --source gs://<your-bucket-name>/stop_vms.zip \
     --set-env-vars PROJECT_ID=<your-project-id>,ZONE=us-central1-a
   ```

---

## **Testing the Functions**

### **1. Manually Trigger the Functions**
- Start VMs:
  ```bash
  gcloud functions call start-vms-function
  ```
- Stop VMs:
  ```bash
  gcloud functions call stop-vms-function
  ```

### **2. Check Logs**
- View logs in the GCP Cloud Console:
  - Navigate to **Cloud Functions** > **Logs**.

---

## **Scheduled Start/Stop**
- The Cloud Scheduler jobs are automatically created by Terraform to:
  - Start VMs at **8:00 AM on weekdays**.
  - Stop VMs at **8:00 PM on weekdays**.

---

## **Cost Savings**
- **Eliminates Unnecessary Costs**: VMs are stopped during off-hours, reducing compute costs.
- **Automation**: Ensures consistent and reliable start/stop schedules.

---

## **Customization**
- Update the `instances` list in the Cloud Function scripts to include your VM names.
- Modify the schedule in `main.tf` to adjust start/stop times.

---

## **Cleanup**
To destroy the infrastructure:
```bash
terraform destroy
```

---

This `README.md` provides a clear guide for setting up, deploying, and testing the project. Customize it further based on your specific requirements.
