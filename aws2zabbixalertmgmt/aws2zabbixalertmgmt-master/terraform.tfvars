general = {
    region = "eu-west-3"
    env    = "prd"
    app    = "Inetum Monitoring"
}

lambdaAlerts = {
    name            = "Inetum_SendCloudWatchToZabbix"
    description     = "Function to send alerts from CloudWatch to Zabbix"
    s3BucketName    = "bucket-to-alams"
    s3FilePath      = "AlarmsNotSent"
    vpcId           = "vpcId"
    subnetIds       = ["subnetId_01", "subnetId_02"]
    logRetention    = 30
    timeout         = 10
}

zabbix = {
    host        = "Zabbix_Hostname"
    clientName  = "Zabbix_Client_Name"
    port        = 10052
    trapItem    = "Zabbix_Trap_name"
    timeout     = 5
}