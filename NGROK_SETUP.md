# Setting Up Webhook Tunneling with Ngrok

This document explains how to use ngrok with your self-hosted n8n instance to make webhooks accessible from the internet.

## Why Use Ngrok?

- Expose your localhost services to the internet with HTTPS
- Bypass NAT/firewalls for webhook access
- Get a public URL for testing webhooks from external services like Telegram

## Setup Instructions

### 1. Sign up for Ngrok

1. Create a free account at [https://ngrok.com/](https://ngrok.com/)
2. Once registered, go to the [dashboard](https://dashboard.ngrok.com/) and copy your Authtoken

### 2. Configure Your Environment

1. Edit the `.env` file in the project root:
   ```
   NGROK_AUTHTOKEN=your-ngrok-auth-token
   ```
   Replace `your-ngrok-auth-token` with the token you copied from the ngrok dashboard.

2. Make sure the update script is executable:
   ```bash
   chmod +x update_ngrok_url.sh
   ```

### 3. Start The Services

Run the startup script which will:
- Start all the required services 
- Configure ngrok to expose your n8n instance
- Update the environment with the correct ngrok URL

```bash
python3 start_services.py --profile cpu
```

### 4. Verify Ngrok Connection

After starting, you can check the ngrok status:

```bash
docker logs ngrok
```

The URL should be automatically updated in your `.env` file and applied to the n8n container.

### 5. Set Up Telegram Webhook (Optional)

If you're using a Telegram bot with n8n:

1. Add your Telegram bot token to the `.env` file:
   ```
   TELEGRAM_BOT_TOKEN=your-telegram-bot-token
   ```

2. Run the update script to configure the webhook:
   ```bash
   ./update_ngrok_url.sh
   ```

### 6. Using Webhooks

Your webhook URLs will now be in this format:
```
https://xxxx-xxx-xxx-xxx.ngrok-free.app/webhook/[YOUR-WEBHOOK-ID]
```

Replace `[YOUR-WEBHOOK-ID]` with the actual webhook ID from n8n.

When creating new workflows with webhook triggers in n8n:
1. The webhook URL will be automatically set to use your ngrok URL
2. You can copy this URL and use it in your external services

### Notes

- Free ngrok accounts have limitations (like connection time limits)
- For production use, consider upgrading to a paid ngrok plan or using a reverse proxy with your own domain
- Each time you restart the services, you'll get a new ngrok URL
- The update script automatically handles updating your webhook URLs 