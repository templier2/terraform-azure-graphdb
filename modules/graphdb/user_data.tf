#
# User data script
#

data "cloudinit_config" "entrypoint" {
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
        #!/bin/bash
        # Stop GraphDB to override configurations
        echo "Stopping GraphDB"
        systemctl stop graphdb
        az login --identity
      EOF
  }

  # 01 Disk setup
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/01_disk_management.sh.tpl", {
      resource_name_prefix : var.resource_name_prefix
      disk_storage_account_type : var.disk_storage_account_type
      disk_iops_read_write : var.disk_iops_read_write
      disk_mbps_read_write : var.disk_mbps_read_write
      disk_size_gb : var.disk_size_gb
      disk_network_access_policy : var.disk_network_access_policy
      disk_public_network_access : var.disk_public_network_access
    })
  }

  # 02 DNS setup
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/02_dns_provisioning.sh.tpl", {})
  }

  # 03 GDB config overrides
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/03_gdb_conf_overrides.sh.tpl", {
      graphdb_external_address_fqdn : var.graphdb_external_address_fqdn
      app_config_name : var.app_configuration_name
    })
  }

  # 04 Backup script configuration
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/04_gdb_backup_conf.sh.tpl", {
      app_config_name : var.app_configuration_name
      backup_schedule : var.backup_schedule
      backup_storage_account_name : var.backup_storage_account_name
      backup_storage_container_name : var.backup_storage_container_name
    })
  }

  # 05 Telegraf configuration
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/05_telegraf_conf.sh.tpl", {
      app_config_name : var.app_configuration_name
    })
  }

  # 06 Application Insights configuration
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/06_application_insights_config.sh.tpl", {
      appi_connection_string : var.appi_connection_string
      appi_sampling_percentage : var.appi_sampling_percentage
      appi_logging_level : var.appi_logging_level
      appi_dependency_sampling_override : var.appi_dependency_sampling_override
      appi_grpc_sampling_override : var.appi_grpc_sampling_override
      appi_repositories_requests_sampling : var.appi_repositories_requests_sampling
    })
  }

  # 07 Cluster setup
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/07_cluster_setup.sh.tpl", {
      app_config_name : var.app_configuration_name
    })
  }
}
