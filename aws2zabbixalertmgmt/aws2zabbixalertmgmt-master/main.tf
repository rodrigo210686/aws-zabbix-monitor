provider "aws" {
  region = var.general.region
}


terraform {
  # This data will be overwritten by Azure DevOps service connection, but this block must exist.
  backend "s3" {
    region = ""
    bucket = ""
    key    = ""
  }
}


locals {

  lambda_environment_variables = {
    s3BucketName        =   var.lambdaAlerts.s3BucketName
    s3FilePath          =   var.lambdaAlerts.s3FilePath
    ZabbixHost          =   var.zabbix.host
    ZabbixClientName    =   var.zabbix.clientName
    zabbixPort          =   var.zabbix.port
    zabbixTrapItem      =   var.zabbix.trapItem
    zabbixTimeout       =   var.zabbix.timeout
  }
}