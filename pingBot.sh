#!/bin/bash

# This script will manage your validators stake.
PATH="/usr/local/bin:/usr/bin:/bin"
PATH=$PATH

NETWORK="mainnet"
POOL_ID="NEAR POOL ID"
ACCOUNT_ID="ACCOUNT ID"

# Enable More Verbose Output
DEBUG_MIN=1

# Epoch Length
MAINET_EPOCH_LEN=43200

export NEAR_ENV=$NETWORK

HOST="https://rpc.mainnet.near.org"

VALIDATORS=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $HOST )
if [ "$DEBUG_ALL" == "1" ]
then
  echo "Validators: $VALIDATORS"
fi
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Validator Info Received"
fi

STATUS_VAR="/status"
STATUS=$(curl -s "$HOST$STATUS_VAR")
if [ "$DEBUG_ALL" == "1" ]
then
  echo "STATUS: $STATUS"
fi

EPOCH_START=$(echo "$VALIDATORS" | jq .result.epoch_start_height)
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Epoch start: $EPOCH_START"
fi

LAST_BLOCK=$(echo "$STATUS" | jq .sync_info.latest_block_height)
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Last Block: $LAST_BLOCK"
fi

# Calculate blocks and time remaining in epoch based on the network selected
BLOCKS_COMPLETED=$((LAST_BLOCK - EPOCH_START))

BLOCKS_REMAINING=$((BLOCKS_COMPLETED - MAINET_EPOCH_LEN))
EPOCH_MINS_REMAINING=$((BLOCKS_REMAINING / 60))

if [ "$DEBUG_MIN" == "1" ]
then
echo "Blocks Completed: $BLOCKS_COMPLETED"
echo "Blocks Remaining: $BLOCKS_REMAINING"
echo "Epoch Minutes Remaining: $EPOCH_MINS_REMAINING"
fi

if (( $EPOCH_MINS_REMAINING < -150 ))
then
PING_COMMAND=$(near call $POOL_ID ping "{}" --accountId $ACCOUNT_ID)
echo "New Epoch Reached. Sending ping"
echo "$PING_COMMAND"
fi
