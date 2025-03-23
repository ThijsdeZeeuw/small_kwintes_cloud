# Telegram Login Widget Integration Guide

This guide explains how to set up and use the Telegram Login Widget with your Kwintes Cloud installation.

## Prerequisites

1. A Telegram account
2. BotFather access to create a bot

## Step 1: Create a Bot for Login

1. Open Telegram and search for "BotFather"
2. Start a chat with BotFather and send the command `/newbot`
3. Follow the instructions to create a new bot:
   - Provide a name for your bot (e.g., "Kwintes Cloud Login")
   - Provide a username for your bot (e.g., "Kwintes_cloud_bot")
4. BotFather will give you a token - keep this secure

## Step 2: Set Up Login Widget

1. Send the `/mybots` command to BotFather
2. Select your newly created bot
3. Select "Bot Settings" > "Login Widget"
4. Enter your website domain (e.g., "kwintes.cloud")
5. BotFather will confirm that your domain is added to the allowed list

## Step 3: Implement the Login Widget

1. Place the `telegram_login.html` file in your web server's directory
2. Make sure to update the `data-telegram-login` attribute with your bot's username (without the "_bot" suffix)

```html
<script async src="https://telegram.org/js/telegram-widget.js?22" 
        data-telegram-login="Kwintes_cloud" 
        data-size="large" 
        data-onauth="onTelegramAuth(user)" 
        data-request-access="write">
</script>
```

## Step 4: Verify Authentication (Important for Security)

For production use, you must verify the authentication data on your server to prevent forgery. Add a server-side verification function like:

```javascript
// Node.js example
const crypto = require('crypto');

function verifyTelegramAuth(authData) {
  const { hash, ...data } = authData;
  const secretKey = crypto.createHash('sha256')
    .update(BOT_TOKEN)
    .digest();
  
  const dataCheckString = Object.keys(data)
    .sort()
    .map(k => `${k}=${data[k]}`)
    .join('\n');
  
  const hmac = crypto.createHmac('sha256', secretKey)
    .update(dataCheckString)
    .digest('hex');
  
  return hmac === hash;
}
```

## Step 5: Integrate with Kwintes Cloud

To fully integrate Telegram login with your Kwintes Cloud installation:

1. Create a login endpoint on your server that:
   - Receives the Telegram auth data
   - Verifies it using the method above
   - Creates or updates a user in your database
   - Issues a session token or cookie

2. Update the `sendToServer` function in `telegram_login.html` to point to your endpoint

3. Configure the redirect after login to go to your application dashboard

## Additional Options

The Telegram Login Widget supports several options:

- `data-size`: "large", "medium", or "small"
- `data-radius`: Button corner radius in pixels (1-20)
- `data-auth-url`: URL for direct server-side authentication
- `data-lang`: Language code (e.g., "en", "nl")

For more details, see the [Telegram Login Widget documentation](https://core.telegram.org/widgets/login). 