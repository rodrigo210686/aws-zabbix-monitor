"""
Company: Inetum
Version: 1.0
Function: Send data from CloudWatch to Zabbix
Description: When the alert is trigger on CloudWatch a JSON with all data will be send to this Lambda function that will parse the data and send to Zabbix.
             All configuration must be done in environment variable. No change in this script must be done.

            Lambda function has a timeout to finished. If the function not finish until this time it will be canceled and a log file will be created on S3 bucket.
Changelog:
    2021-05-10 : Creation
    
Copyright (C) 2021 Inetum. All rights reserved.
"""

from __future__ import print_function
from pyzabbix import ZabbixMetric, ZabbixSender
from datetime import datetime
import signal
import socket
import boto3
import json
import os

def lambda_handler(event, context):

    # Setup alarm for remaining runtime
    signal.alarm(int(context.get_remaining_time_in_millis() / 1000))

    message = event

    s3 = boto3.resource("s3")
    s3BucketName = os.environ['s3BucketName']
    s3Path = os.environ['s3FilePath']

    ZabbixClientName = os.environ['ZabbixClientName']
    ZabbixHost = os.environ['ZabbixHost']
    zabbixPort = int(os.environ['zabbixPort'])
    zabbixTrapItem = os.environ['zabbixTrapItem']
    zabbixTimeout = int(os.environ['zabbixTimeout'])

    try:
        resourceType = message['detail']['configuration']['metrics'][0]['metricStat']['metric']['namespace']
        resourceIdRAW = message['detail']['configuration']['metrics'][0]['metricStat']['metric']['dimensions']
        resourceIdKey = list(resourceIdRAW.keys())[0]
        resourceId = message['detail']['configuration']['metrics'][0]['metricStat']['metric']['dimensions'][resourceIdKey]
        metricName = message['detail']['configuration']['metrics'][0]['metricStat']['metric']['name']
        newStatus = message['detail']['state']['value']
        oldStatus = message['detail']['previousState']['value']
        region = message['region']
        timestamp = message['time']
        newStateReason = json.loads(message['detail']['state']['reasonData'])
        threshold = str(newStateReason['threshold'])
        period = str(newStateReason['period'])+"seg"
        reasonRAW = message['detail']['state']['reason']
        reasonMSG = reasonRAW.split(']', 1)[1].split('(', 1)[0].lstrip()
        reasonValue = str(round(float(reasonRAW.split('[', 1)[1].split(']', 1)[0].split(' ', 1)[0]), 2))
        
        result = resourceId+";"+metricName+";"+reasonMSG+"("+threshold+");"+reasonValue+";"+newStatus+";"+oldStatus+";"+resourceType+";"+region

        # Test if Zabbix is available
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(zabbixTimeout)
        connection = sock.connect_ex((ZabbixHost,int(zabbixPort)))
        if connection != 0:
            print('Timeout to connect to Zabbix')
            raise Exception('Timeout to connect to Zabbix')
        sock.close()

        # Send to Zabbix
        packet = [
            ZabbixMetric(ZabbixClientName, zabbixTrapItem, result),
        ]
        
        result = ZabbixSender(ZabbixHost,zabbixPort,use_config=None,).send(packet)

        if int(result.failed) > 0:
            raise Exception('Zabbix did not accept the message.')
        
        print(result)

    except Exception as erroMSG:
        print("Error to send to Zabbix")
        
        # Gerenate file name
        now = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        fileName = s3Path+'/error_'+now+'.txt'
        fileNameMessage = s3Path+'/error_message_'+now+'.txt'
        fileNameAlert = s3Path+'/alert_'+now+'.txt'
        
        # Save on S3
        s3.Bucket(s3BucketName).put_object(Key=fileName, Body=str(message))
        s3.Bucket(s3BucketName).put_object(Key=fileNameMessage, Body=str(erroMSG))
        s3.Bucket(s3BucketName).put_object(Key=fileNameAlert, Body=str(result))

def timeout_handler(_signal, _frame):
    # If Lambda timeout is thrown the code below will be executed

    #import boto3
    s3 = boto3.resource("s3")
    s3BucketName = os.environ['s3BucketName']
    s3Path = os.environ['s3FilePath']
    
    # Gerenate file name
    now = datetime.now()
    fileNameMessage = s3Path+'/error_message_'+now.strftime("%Y%m%d_%H%M%S_%f")+'.txt'
    
    # Save on S3
    s3.Bucket(s3BucketName).put_object(Key=fileNameMessage, Body=str("Error to connect to Zabbix."))

signal.signal(signal.SIGALRM, timeout_handler)