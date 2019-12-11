module "xilution_network" {
  source = "github.com/xilution/xilution-terraform/aws/network"
  organization_id = var.organization_id
}
