data "mso_site" "on_prem_site"{
  name = var.on_prem_site
}
  
data "mso_site" "aws_site"{
  name = var.aws_site
}


resource "mso_tenant" "demo_tenant" {
  name = var.tenant
  display_name = var.tenant
  description  = "PoC AWS"
  site_associations {
      site_id = data.mso_site.on_prem_site.id
  }
  site_associations {
    site_id                = data.mso_site.aws_site.id
    vendor                 = "aws"
    aws_account_id         = "835427663033"
    is_aws_account_trusted = true
  }
}

resource "mso_schema" "on_prem_and_aws" {
  name          = var.hybrid_schema.name
  template_name = var.hybrid_schema.template_name
  tenant_id     = mso_tenant.demo_tenant.id 
}

resource "mso_schema_site" "schema_on_prem_site" {
  schema_id       =  mso_schema.on_prem_and_aws.id 
  site_id         =  data.mso_site.on_prem_site.id 
  template_name   =  mso_schema.on_prem_and_aws.template_name
}

resource "mso_schema_site" "schema_aws_site" {
  schema_id       =  mso_schema.on_prem_and_aws.id 
  site_id         =  data.mso_site.aws_site.id 
  template_name   =  mso_schema.on_prem_and_aws.template_name
}

resource "mso_schema_template_deploy" "deploy" {
  depends_on = [mso_schema_template_anp_epg_selector.check]
  schema_id = mso_schema.on_prem_and_aws.id 
  template_name = mso_schema.on_prem_and_aws.template_name
}


#mso_schema.on_prem_and_aws.template_name


resource "mso_schema_template_deploy" "template_deployer" {
  depends_on = [mso_schema_template_anp_epg_selector.check]
  schema_id = mso_schema.on_prem_and_aws.id 
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id = data.mso_site.on_prem_site.id 
  undeploy = false
}

resource "mso_schema_template_deploy" "template_deployer_aww" {
  depends_on = [mso_schema_template_anp_epg_selector.check]
  schema_id = mso_schema.on_prem_and_aws.id 
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id = data.mso_site.aws_site.id 
  undeploy = false
}