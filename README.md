How to fix
Option 1: Use a full-permission service account

Create a Service Account in your project:

gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Admin SA"


Grant Project Owner role (for testing/development):

gcloud projects add-iam-policy-binding lustrous-drake-412814 \
    --member="serviceAccount:terraform-sa@lustrous-drake-412814.iam.gserviceaccount.com" \
    --role="roles/owner"


Generate JSON key for Terraform:

gcloud iam service-accounts keys create ~/terraform-sa-key.json \
    --iam-account=terraform-sa@lustrous-drake-412814.iam.gserviceaccount.com


Set environment variable so Terraform uses it:

export GOOGLE_APPLICATION_CREDENTIALS=~/terraform-sa-key.json


Re-run:

terraform init
terraform plan -var="project_id=lustrous-drake-412814" -var="region=us-central1"
terraform apply -var="project_id=lustrous-drake-412814" -var="region=us-central1"


✅ This should work because the service account has full access.
