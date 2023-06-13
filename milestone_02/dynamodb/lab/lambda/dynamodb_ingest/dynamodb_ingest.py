# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --------------------------------------------------------------------------------------------------
# Imports
# --------------------------------------------------------------------------------------------------

import base64
# General Imports
import json
import time
from decimal import Decimal

# AWS Imports
import boto3

# Project Imports
ID_COLUMN_NAME = 'TradeID'
VERSION_COLUMN_NAME = 'Version'
VALUE_COLUMN_NAME = 'Value'
TIMESTAMP_COLUMN_NAME = 'Timestamp'
HIERARCHY_COLUMN_NAME = 'Hierarchy'
TTL_COLUMN_NAME = 'TimeToExist'
# DynamoDB Table and Column Names
STATE_TABLE_NAME = 'StateTable'
STATE_TABLE_KEY = 'TradeId'


# --------------------------------------------------------------------------------------------------
# Lambda Function
# --------------------------------------------------------------------------------------------------

def lambda_handler(event, context):
    # Print Status at Start
    records = event['Records']
    print('Invoked StateLambda with ' + str(len(records)) + ' record(s).')

    # Initialize DynamoDB
    ddb_ressource = boto3.resource('dynamodb')
    table = ddb_ressource.Table(STATE_TABLE_NAME)

    # Loop over records
    for record in records:

        # Load Record
        data = json.loads(base64.b64decode(record['kinesis']['data']).decode('utf-8'))

        # Get Entries
        record_id = data[ID_COLUMN_NAME]
        record_hierarchy = data[HIERARCHY_COLUMN_NAME]
        record_value = data[VALUE_COLUMN_NAME]
        record_version = data[VERSION_COLUMN_NAME]
        record_time = data[TIMESTAMP_COLUMN_NAME]

        # If Record is older than 1 Minute -> Ignore it
        if (time.time() - record_time) > 60:
            continue

        # Write to DDB
        table.update_item(
            Key={
                STATE_TABLE_KEY: record_id
            },
            UpdateExpression='SET  #VALUE     = :new_value,' + \
                             '#VERSION   = :new_version,' + \
                             '#HIERARCHY = :new_hierarchy,' + \
                             '#TIMESTAMP = :new_time,' + \
                             '#TIMESTAMP_TTL = :ttl',
            ExpressionAttributeNames={
                '#VALUE': VALUE_COLUMN_NAME,
                '#VERSION': VERSION_COLUMN_NAME,
                '#HIERARCHY': HIERARCHY_COLUMN_NAME,
                '#TIMESTAMP': TIMESTAMP_COLUMN_NAME,
                '#TIMESTAMP_TTL': TTL_COLUMN_NAME
            },
            ExpressionAttributeValues={
                ':new_version': record_version,
                ':new_value': Decimal(str(record_value)),
                ':new_hierarchy': json.dumps(record_hierarchy, sort_keys=True),
                ':new_time': Decimal(str(record_time)),
                ':ttl': Decimal(str(record_time + 60))
            }
        )

    # Print Status at End
    print('StateLambda successfully processed ' + str(len(records)) + ' record(s).')

    return {'statusCode': 200}
