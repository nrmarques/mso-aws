resource "mso_schema_template_vrf" "template_vrf_prod_1" {
  schema_id        = mso_schema.on_prem_and_aws.id
  template         = mso_schema.on_prem_and_aws.template_name
  name             = var.vrf
  display_name     = var.vrf
  layer3_multicast = false
  vzany            = false
}

resource "mso_schema_site_vrf" "on_prem_vrf_prod_1" {
  depends_on    = [mso_schema_template_vrf.template_vrf_prod_1]
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id       = data.mso_site.on_prem_site.id
  schema_id     = mso_schema.on_prem_and_aws.id
  vrf_name      = mso_schema_template_vrf.template_vrf_prod_1.name
}

#AWS

resource "mso_schema_site_vrf" "site_vrf_prod_1" {
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id       = data.mso_site.aws_site.id
  schema_id     = mso_schema.on_prem_and_aws.id
  vrf_name      = mso_schema_template_vrf.template_vrf_prod_1.name
}

resource "mso_schema_site_vrf_region" "vrfRegion" {
  schema_id          = mso_schema.on_prem_and_aws.id
  template_name      = mso_schema.on_prem_and_aws.template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_template_vrf.template_vrf_prod_1.name
  region_name        = var.aws_region
  vpn_gateway        = true
  hub_network_enable = false
  cidr {
    cidr_ip = var.aws_cidr
    primary = true
    subnet {
      ip   = var.aws_subnet
      zone = var.aws_az
    }
  }
}

resource "mso_schema_template_anp" "hybrid" {
  schema_id     = mso_schema.on_prem_and_aws.id
  template      = mso_schema.on_prem_and_aws.template_name
  name          = var.anp
  display_name  = var.anp
}

resource "mso_schema_site_anp" "on_prem_site_hybrid" {
  depends_on    = [mso_schema_template_anp.hybrid]
  schema_id     = mso_schema.on_prem_and_aws.id
  anp_name      = mso_schema_template_anp.hybrid.name
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id       = data.mso_site.on_prem_site.id
}

resource "mso_schema_template_bd" "bd_local" {
  schema_id              = mso_schema.on_prem_and_aws.id
  template_name          = mso_schema.on_prem_and_aws.template_name
  name                   = var.bd_local
  display_name           = var.bd_display_name
  vrf_name               = mso_schema_template_vrf.template_vrf_prod_1.name
  layer2_unknown_unicast = "proxy"
  unicast_routing = "true"
}

resource "mso_schema_site_bd" "on_prem_site_bd_local" {
  depends_on    = [mso_schema_template_bd.bd_local]
  schema_id     = mso_schema.on_prem_and_aws.id
  bd_name       = mso_schema_template_bd.bd_local.name
  template_name = mso_schema.on_prem_and_aws.template_name
  site_id       = data.mso_site.on_prem_site.id
  host_route    = false
}

resource "mso_schema_site_bd_subnet" "on_prem_site_bd_subnet" {
depends_on    = [mso_schema_site_bd.on_prem_site_bd_local]
  schema_id          = mso_schema.on_prem_and_aws.id
  template_name      = mso_schema.on_prem_and_aws.template_name
  site_id            = data.mso_site.on_prem_site.id
  bd_name            = mso_schema_template_bd.bd_local.name
  ip                 = var.bd_local_gw
  shared             = false
  scope              = "private"
  querier            = false
  no_default_gateway = false
}

resource "mso_schema_template_anp_epg" "hybrid_epg" {
  schema_id                  = mso_schema.on_prem_and_aws.id
  template_name              = mso_schema.on_prem_and_aws.template_name
  anp_name                   = mso_schema_template_anp.hybrid.name
  name                       = var.epg_streched
  bd_name                    = mso_schema_template_bd.bd_local.name
  vrf_name                   = mso_schema_template_vrf.template_vrf_prod_1.name
  display_name               = var.epg_streched
  useg_epg                   = false
  intra_epg                  = "unenforced"
  intersite_multicast_source = false
  preferred_group            = false
}

resource "mso_schema_site_anp_epg_domain" "site_anp_epg_domain" {
  depends_on           = [mso_schema_template_anp_epg.hybrid_epg]
  schema_id            = mso_schema.on_prem_and_aws.id
  template_name        = mso_schema.on_prem_and_aws.template_name
  site_id              = data.mso_site.on_prem_site.id
  anp_name             = mso_schema_template_anp.hybrid.name
  epg_name             = mso_schema_template_anp_epg.hybrid_epg.name
  domain_type          = var.vmm_type
  dn                   = var.vmm_name
  deploy_immediacy     = "immediate"
  resolution_immediacy = "immediate"
}

resource "mso_schema_template_anp_epg_selector" "check" {
  schema_id     = mso_schema.on_prem_and_aws.id
  template_name = mso_schema.on_prem_and_aws.template_name
  anp_name      = mso_schema_template_anp.hybrid.name
  epg_name      = mso_schema_template_anp_epg.hybrid_epg.name
  name          = "hybrid-epg-cloud-selector"
  expressions {
    key      = "Custom:tag"
    operator = "equals"
    value    = "epg1"
  }
}