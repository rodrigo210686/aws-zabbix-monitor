######## General ########
variable "general" {
     type = object({
          region = string
          env    = string
          app    = string
     })
}

######## Specific ######## 
variable "lambdaAlerts" {
     type = object({
          name = string
          description   = string
          s3BucketName  = string
          s3FilePath    = string
          vpcId         = string
          subnetIds     = list(string)
          logRetention  = number
          timeout       = number
     })
}

variable "zabbix" {
     type = object({
          host        = string
          clientName  = string
          port        = number
          trapItem    = string
          timeout     = number
     })
}

variable "alarm_tags" {
  type = map(string)
  description = "Inetum Alarms Tags"
  default = {
    Terraform   = "true"
    Environment = "prd"
    Application = "Inetum Monitoring - Zabbix Proxy"
    Area        = "Tooling Supervision/Hypervision Automation"
  }
}
