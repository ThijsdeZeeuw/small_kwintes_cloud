# Telegram Login Integration for Kwintes Cloud

This document explains how the Telegram login integration works with Kwintes Cloud and provides a comprehensive overview of all the components.

## Architecture Overview

The Telegram login integration consists of:

1. **Frontend Login Page**: A simple HTML page with the Telegram login widget
2. **n8n Workflow**: Handles authentication verification and user management
3. **Database Schema**: Stores user information in Supabase
4. **Security Layer**: Verifies authenticity of Telegram login data

## Components

### 1. Frontend (`telegram_login.html`)

This file provides a clean login interface featuring:
- Telegram Login Widget button
- User information display after login
- Forwarding to the main application after successful login

### 2. n8n Workflow (`telegram_auth_handler.json`)

The workflow processes login requests with the following steps:
1. Receives authentication data via webhook
2. Extracts and formats the user data
3. Verifies the authenticity using crypto signatures
4. If valid, inserts/updates the user in the database
5. Returns success/error response to frontend

### 3. Database Schema (`10_telegram_users_schema.sql`)

The database schema:
- Stores user information from Telegram
- Implements proper timestamps for creation/updates
- Adds indexes for performance
- Sets up row-level security policies
- Creates appropriate database triggers

### 4. Configuration (`.env`)

Environment variables for the integration:
- `TELEGRAM_BOT_TOKEN`: Your bot's API token from BotFather
- `TELEGRAM_BOT_USERNAME`: Your bot's username (without "_bot" suffix)

## Setup Flow

1. Create a Telegram bot via BotFather
2. Configure the login widget settings for your domain
3. Set the environment variables in `.env`
4. Place the HTML file on your web server
5. Import the n8n workflow
6. Run the database schema SQL
7. Configure your application to use the user information

## Security Considerations

This integration implements several security best practices:

1. **Data Verification**: Validates login data with HMAC-SHA256 signatures
2. **Database Security**: Uses row-level security to protect user data
3. **Token Security**: Never exposes the bot token in client-side code
4. **Auth Date Checking**: Can be extended to validate freshness of auth data

## Integration with Other Services

The Telegram users can be integrated with:

1. **Open WebUI**: For personalized AI assistant experiences
2. **n8n Workflows**: For custom automation based on user identity
3. **Supabase Auth**: Can be linked with existing auth system

## Customization

You can customize this integration by:

1. Modifying the HTML/CSS to match your branding
2. Extending the n8n workflow for additional validation steps
3. Adding more fields to the database schema for app-specific data
4. Creating additional database policies for fine-grained access control

## Troubleshooting

Common issues and solutions:

1. **Widget not showing**: Ensure the bot username is correct and the script is properly loaded
2. **Authentication failures**: Check that the bot token is correctly set in the environment
3. **Database errors**: Verify Supabase connection and permissions
4. **Login loop**: Check for proper session management in your application

## References

- [Telegram Login Widget Documentation](https://core.telegram.org/widgets/login)
- [n8n Documentation](https://docs.n8n.io)
- [Supabase Authentication](https://supabase.com/docs/guides/auth)
- [Detailed Setup Instructions](./TELEGRAM_LOGIN.md) 