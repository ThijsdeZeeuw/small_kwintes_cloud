#!/bin/bash

# Script to update Telegram webhook URL with the current ngrok URL

# Check if TELEGRAM_BOT_TOKEN is set
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  # Try to get it from .env file
  if [ -f .env ]; then
    TELEGRAM_BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN .env | cut -d= -f2)
  fi
  
  # If still empty, exit
  if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Error: TELEGRAM_BOT_TOKEN is not set!"
    echo "Please set it in your .env file or as an environment variable."
    exit 1
  fi
fi

# Get the current ngrok URL from .env file
NGROK_URL=$(grep NGROK_URL .env | cut -d= -f2)

if [ -z "$NGROK_URL" ]; then
  echo "Error: NGROK_URL not found in .env file!"
  echo "Please make sure ngrok is running and the URL is updated in .env."
  exit 1
fi

# Remove any quotes around the URL
NGROK_URL=$(echo $NGROK_URL | tr -d '"')
NGROK_URL=$(echo $NGROK_URL | tr -d "'")

# Construct the webhook URL
WEBHOOK_URL="${NGROK_URL}webhook/telegram-auth"

echo "Setting Telegram webhook URL to: $WEBHOOK_URL"

# Make the API request to set the webhook
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$WEBHOOK_URL\", \"drop_pending_updates\": true}")

# Check the response
if echo $RESPONSE | grep -q '"ok":true'; then
  echo "Success! Webhook has been set."
  echo "Response: $RESPONSE"
else
  echo "Failed to set webhook!"
  echo "Response: $RESPONSE"
  exit 1
fi

echo "Telegram webhook configuration complete."
echo "Any login attempts will be processed by the n8n workflow at: $WEBHOOK_URL"

exit 0 