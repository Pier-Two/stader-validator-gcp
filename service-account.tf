#####################################################################
#region:  Service Account & Permissions
# Create Service Account for VM
resource "google_service_account" "vm_service_account" {
  account_id   = "sv-${var.name_prefix}"
  display_name = "sv-${var.name_prefix}"
}