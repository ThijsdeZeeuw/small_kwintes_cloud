#!/bin/bash

# update_ngrok_url.sh
# Script to dynamically update the NGROK_URL in .env file after ngrok starts

set -e

# Wait for ngrok to start
echo "Waiting for ngrok to start..."
sleep 10

# Get ngrok URL from ngrok API
NGROK_URL=$(curl -s http://ngrok:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'http[^"]*')

if [ -z "$NGROK_URL" ]; then
  echo "Failed to get ngrok URL. Make sure ngrok is running correctly."
  exit 1
fi

echo "Ngrok URL: $NGROK_URL"

# Update the .env file with the ngrok URL
sed -i "s|NGROK_URL=.*|NGROK_URL=$NGROK_URL|g" .env

# Update the container environment variable for n8n
docker exec n8n sh -c "export WEBHOOK_TUNNEL_URL=$NGROK_URL"
docker exec n8n sh -c "export WEBHOOK_URL=$NGROK_URL"

# If you have Telegram Bot integration, configure the webhook
if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "Setting up Telegram webhook..."
  # Webhook for regular bot commands
  curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook?url=$NGROK_URL/webhook-telegram"
  echo "Telegram command webhook set to $NGROK_URL/webhook-telegram"
  
  # Webhook for Telegram login authentication
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$NGROK_URL/webhook/telegram-auth\", \"drop_pending_updates\": true}"
  echo "Telegram auth webhook set to $NGROK_URL/webhook/telegram-auth"
fi

echo "Ngrok URL updated successfully. Your n8n instance is now accessible via: $NGROK_URL"
echo "Web UI: $NGROK_URL"
echo "Webhook URLs will be: $NGROK_URL/webhook/[YOUR-WEBHOOK-ID]" 