# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --------------------------------------------------------------------------------------------------
# Imports
# --------------------------------------------------------------------------------------------------

# General Imports
import random
import json
import base64
import hashlib
import time
import uuid
from decimal import Decimal

# AWS Imports
import boto3

# --------------------------------------------------------------------------------------------------
# AWS Settings
# --------------------------------------------------------------------------------------------------

# Kinesis
KINESIS_STREAM_NAME = 'IncomingDataStream'

# DynamoDB Table and Column Names
PARAMETER_TABLE_NAME = 'ParameterTable'
PARAMETER_TABLE_KEY = 'parameter'
PARAMETER_COLUMN_NAME = 'value'

AGGREGATE_TABLE_NAME = 'AggregateTable'
AGGREGATE_TABLE_KEY = 'Identifier'

MESSAGE_COUNT_NAME = 'message_count'

ID_COLUMN_NAME = 'TradeID'
VERSION_COLUMN_NAME = 'Version'
VALUE_COLUMN_NAME = 'Value'
TIMESTAMP_COLUMN_NAME = 'Timestamp'
HIERARCHY_COLUMN_NAME = 'Hierarchy'

HIERARCHY_DEFINITION = {
    'RiskType': ['PV', 'Delta'],
    'Region': ['EMEA', 'APAC', 'AMER'],
    'TradeDesk': ['FXSpot', 'FXOptions']
}

TIMESTAMP_GENERATOR_FIRST = 'timestamp_generator_first'
TIMESTAMP_GENERATOR_MEAN = 'timestamp_generator_mean'

# --------------------------------------------------------------------------------------------------
# Aggregation Settings
# --------------------------------------------------------------------------------------------------

# Definition of the Hierarchy
AGGREGATION_HIERARCHY = ['RiskType', 'TradeDesk', 'Region']

# --------------------------------------------------------------------------------------------------
# Generator Settings
# --------------------------------------------------------------------------------------------------

# Number of messages per Generator
NUMBER_OF_BATCHES = 250
BATCH_SIZE = 40

# Risk Values
MIN_VALUE_OF_RISK = 0
MAX_VALUE_OF_RISK = 100000

# Other
TIME_INTERVAL_SPEED_CALCULATION = 3

# Lambda Settings
FAILURE_STATE_LAMBDA_PCT = 5
FAILURE_MAP_LAMBDA_PCT = 10
FAILURE_REDUCE_LAMBDA_PCT = 10


# --------------------------------------------------------------------------------------------------
# Generic Helper Functions
# --------------------------------------------------------------------------------------------------

# Add a value to an entry in a dictionary, create the entry if necessary
def dict_entry_add(dictionary, key, value):
    if key in dictionary:
        dictionary[key] += value
    else:
        dictionary[key] = value


# Add a value to an entry in a dictionary, create the entry if necessary
def dict_entry_min(dictionary, key, value):
    if (key not in dictionary) or (value < dictionary[key]):
        dictionary[key] = value


# --------------------------------------------------------------------------------------------------
# AWS Helper Functions
# --------------------------------------------------------------------------------------------------

# Get item from a DynamoDB Table, if it exists, return None otherwise
def get_item_ddb(table, key_name, strong_consistency=False):
    # Call to DynamoDB
    if strong_consistency:
        response = table.get_item(Key=key_name, ConsistentRead=True)
    else:
        response = table.get_item(Key=key_name)

    # Return item if found
    if 'Item' in response:
        item = response['Item']
    else:
        item = None

    return item


# Count number of items in DynamoDB Table
def count_items(table):
    item_count = 0
    scan_args = dict()
    done = False
    start_key = None
    i = 0

    while not done:
        # Scan
        if start_key:
            scan_args['ExclusiveStartKey'] = start_key
        response = table.scan(**scan_args)
        start_key = response.get('LastEvaluatedKey', None)
        done = start_key is None

        # Get Items
        items = response.get('Items', [])
        item_count += len(items)

    return item_count


# Get Parameter Value
def get_parameter(ddb_ressource, param_name, default_val):
    parameter_table = ddb_ressource.Table(PARAMETER_TABLE_NAME)
    response = get_item_ddb(parameter_table, {PARAMETER_TABLE_KEY: param_name}, True)

    if response:
        return int(response[PARAMETER_COLUMN_NAME])
    else:
        return default_val


# Set Parameter Value
def set_parameter(ddb_ressource, param_name, param_val):
    parameter_table = ddb_ressource.Table(PARAMETER_TABLE_NAME)
    response = parameter_table.put_item(Item={
        PARAMETER_TABLE_KEY: param_name,
        PARAMETER_COLUMN_NAME: Decimal(str(param_val))
    })
    return response


# --------------------------------------------------------------------------------------------------
# Aggregation & Generator Helper Functions
# --------------------------------------------------------------------------------------------------

# Random Value
def random_value():
    value = random.randint(100 * MIN_VALUE_OF_RISK, 100 * MAX_VALUE_OF_RISK) / 100
    return value


# Random Type Constructor
def random_hierarchy():
    hierarchy = dict()
    for k, v in HIERARCHY_DEFINITION.items():
        hierarchy[k] = random.choice(v)
    return hierarchy


# --------------------------------------------------------------------------------------------------
# Generate Messages
# --------------------------------------------------------------------------------------------------

def generate_messages():
    for i in range(NUMBER_OF_BATCHES):

        # Initialize record list for this batch
        records = []

        # Create Batch
        for j in range(BATCH_SIZE):
            # Initialize Empty Message
            message = {
                ID_COLUMN_NAME: str(uuid.uuid4()),
                VERSION_COLUMN_NAME: 0,
                VALUE_COLUMN_NAME: random_value(),
                HIERARCHY_COLUMN_NAME: random_hierarchy(),
                TIMESTAMP_COLUMN_NAME: time.time()
            }

            # Dump to String
            message_string = json.dumps(message)

            # Append to Record List
            record = {'Data': message_string, 'PartitionKey':
                hashlib.sha256(message_string.encode()).hexdigest()}
            records.append(record)

        # Send Batch to Kinesis Stream
        return kinesis_client.put_records(StreamName=KINESIS_STREAM_NAME, Records=records)


# --------------------------------------------------------------------------------------------------
# Preparation
# --------------------------------------------------------------------------------------------------

# Connect to DynamoDB
ddb_ressource = boto3.resource('dynamodb')
aggregate_table = ddb_ressource.Table(AGGREGATE_TABLE_NAME)

# Initialize Kinesis Consumer
kinesis_client = boto3.client('kinesis')


def lambda_handler(event, context):
    generate_messages()
    print("Ingested " + str(NUMBER_OF_BATCHES * BATCH_SIZE) + " messages into pipeline.")
    return {'statusCode': 200}
