# small_kwintes_cloud

## System Requirements
- Ubuntu 24.04 LTS
- Minimum 4GB RAM (8GB+ recommended)
- 20GB+ free disk space
- CPU with AVX2 support for optimal performance

## Pre-Installation Setup

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Required Software
```bash
# Install Python
sudo apt install -y python3 python3-pip python3-venv

# Install Git
sudo apt install -y git

# Generate and add SSH Key for GitHub
ssh-keygen -t rsa -b 4096 -C "tddezeeuw@gmail.com"
# When prompted, press Enter to save in default location (~/.ssh/id_rsa)
# Add a passphrase if desired (recommended for security)

# Display and copy your public key
cat ~/.ssh/id_rsa.pub
# Copy the output (starts with ssh-rsa)

# After adding to GitHub (Settings > SSH and GPG keys), test the connection:
ssh -T git@github.com
# Type 'yes' if prompted about host authenticity

# To add the key to GitHub:
# 1. Log in to your GitHub account
# 2. Go to Settings (click your profile picture → Settings)
# 3. Select SSH and GPG keys from the sidebar
# 4. Click "New SSH key" or "Add SSH key"
# 5. Add a descriptive title (e.g., "VPS Server Key")
# 6. Paste your public key in the "Key" field
# 7. Click "Add SSH key" and confirm with your password if prompted

# Install Docker
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Helpful Resources
- [Youtube Installation Guides](https://www.youtube.com/playlist?list=PLz0wwBxxxGRzyJ-fgFAktlk7-wmTwCC0m)
- [Self-Hosted Supabase Video](https://youtu.be/Gyh0c8pMmhE) (Optional)

## Installation Steps

1. **Clone the repository**
   ```bash
   
   git clone https://github.com/coleam00/local-ai-packaged.git
   ```

2. **Navigate to the project directory**
   ```bash
   cd local-ai-packaged

   ```

3. **Create environment file**
   ```bash
   cp .env.example .env
   ```

4. **Configure firewall (optional but recommended)**
   ```bash
   sudo apt install -y ufw
   sudo ufw allow ssh
   sudo ufw allow 3000  # WebUI
   sudo ufw allow 5678  # n8n workflow
   sudo ufw allow 8501  # Archon Streamlit UI (if using Archon)
   sudo ufw allow 5001  # DocLing Serve (if using DocLing)
   sudo ufw enable
   ```

5. **Start services**
   ```bash
   python3 start_services.py --profile cpu
   ```
   
   Note: If you have a GPU available, you can use:
   ```bash
   # For NVIDIA GPUs with proper drivers installed
   python3 start_services.py --profile cuda
   ```

6. **Open n8n workflow**
   - Navigate to `http://YOUR_SERVER_IP:5678` in your browser

## Configuration

### Configure Service Credentials
- **Qdrant**: `http://qdrant:6333`
- **Ollama**: 
  - Docker version: `http://ollama:11434`
  - Local installation: `http://host.docker.internal:11434/` (for local Ollama setup)
- **Supabase**: Use credentials from `.env` file

### Local Ollama Setup (Optional)
If you prefer to use Ollama locally instead of from the Docker package:
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull required models
ollama pull nomic-embed-text
ollama pull qwen2.5:7b-instruct-q4_K_M

# Make sure to start the Ollama service
systemctl --user enable ollama
systemctl --user start ollama
```

### Set Up WebUI

1. **Access WebUI**
   - Open `http://YOUR_SERVER_IP:3000/` in your browser

2. **Configure Workspace Functions**
   - Go to Admin Settings -> Workspace -> Functions -> Add Function
   - Give it a name and description
   - URL: `http://YOUR_SERVER_IP:3000/admin/functions`

3. **Add n8n_pip Code**
   - Copy code from [https://openwebui.com/f/coleam/n8n_pipe](https://openwebui.com/f/coleam/n8n_pipe)
   - Change the webhook URL to: `http://host.docker.internal:5678/webhook/invoke_n8n_agent`
   - Enable the function

4. **Add Tools**
   - Example: Add Wikipedia Tool

## Integrating DocLing (Optional)

DocLing is a computational linguistics platform that can be integrated with your Local AI Package for natural language processing tasks.

### DocLing Installation Options

#### Option 1: Using Docker

1. **Pull the DocLing CPU-optimized image**
   ```bash
   docker pull ghcr.io/docling-project/docling-serve-cpu
   # OR
   docker pull quay.io/docling-project/docling-serve-cpu
   ```

2. **Run the DocLing container with UI enabled**
   ```bash
   docker run -p 5001:5001 -e DOCLING_SERVE_ENABLE_UI=true quay.io/docling-project/docling-serve-cpu
   ```

3. **Access the DocLing UI**
   - Navigate to `http://YOUR_SERVER_IP:5001` in your browser

#### Option 2: Direct Python Installation

1. **Install the Python package with UI dependencies**
   ```bash
   pip install "docling-serve[ui]"
   ```

2. **Run DocLing with UI enabled**
   ```bash
   docling-serve run --enable-ui
   ```

### Adding DocLing to docker-compose.yml

You can add DocLing to your existing docker-compose.yml file to have it start with your other services:

```yaml
services:
  # ... existing services
  
  docling:
    image: quay.io/docling-project/docling-serve-cpu
    ports:
      - "5001:5001"
    environment:
      - DOCLING_SERVE_ENABLE_UI=true
    restart: unless-stopped
```

### Integrating DocLing with n8n

You can create workflows in n8n that utilize DocLing's NLP capabilities:

1. **Add an HTTP Request node in n8n**
   - Method: POST
   - URL: `http://docling:5001/api/analyze`
   - Body: 
     ```json
     {
       "text": "{{$node['Previous Node'].data.text}}",
       "tasks": ["pos", "ner", "sentiment"]
     }
     ```

2. **Process the results in subsequent nodes**
   - Parse the linguistic analysis results
   - Use the structured data for further processing or decision-making

## Integrating Archon V5 (Optional)

Archon is an AI orchestration framework that can be integrated with Local AI Package for enhanced capabilities.

### Prerequisites for Archon
- Python 3.11+
- Supabase account (for vector database)
- OpenAI/Anthropic/OpenRouter API key or Ollama for local LLMs
  - Note: Only OpenAI supports streaming in the Streamlit UI currently

### Installation Steps for Archon

1. **Clone the Archon repository**
   ```bash
   git clone https://github.com/coleam00/archon.git
   cd archon
   ```

2. **Setup with Docker (Recommended)**
   ```bash
   # This will build both containers and start Archon
   python3 run_docker.py
   ```

   This script automatically:
   - Builds the MCP server container
   - Builds the main Archon container
   - Runs Archon with appropriate port mappings
   - Uses environment variables from .env file if it exists

3. **Access Archon UI**
   - Navigate to `http://YOUR_SERVER_IP:8501` in your browser

4. **Integration with Local AI Package**
   - In your Archon configuration, you can point to the Local AI Package's services:
     - For vector databases, use Qdrant at `http://localhost:6333`
     - For local LLMs, use Ollama at `http://localhost:11434`

## Docker Environment Variables for MCP Servers

When using Model Context Protocol (MCP) servers with n8n in Docker deployments, you can configure them using environment variables. This enables AI agents to utilize various capabilities like search engines, weather data, and more.

### Configuring MCP Environment Variables

Environment variables for MCP servers should be prefixed with `MCP_` in your docker-compose file:

```yaml
version: '3'

services:
  n8n:
    image: n8nio/n8n
    environment:
      # MCP server environment variables
      - MCP_BRAVE_API_KEY=your-brave-api-key
      - MCP_OPENAI_API_KEY=your-openai-key
      - MCP_SERPER_API_KEY=your-serper-key
      - MCP_WEATHER_API_KEY=your-weather-api-key
      
      # Enable community nodes as tools
      - N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
    ports:
      - "5678:5678"
    volumes:
      - ~/.n8n:/home/node/.n8n
```

These environment variables will be automatically passed to your MCP servers when they are executed.

### Setting Up MCP Servers

1. **Install MCP Server Packages**

   For Brave Search:
   ```bash
   npm install -g @modelcontextprotocol/server-brave-search
   ```

   For other services, install the appropriate package:
   ```bash
   npm install -g @modelcontextprotocol/server-openai
   npm install -g @modelcontextprotocol/server-serper
   npm install -g @modelcontextprotocol/server-weather
   ```

2. **Configure MCP Client Credentials in n8n**

   For each MCP server:
   - Open n8n workflow editor
   - Go to Credentials > Add Credentials
   - Select MCP Client
   - Set Command: `npx`
   - Set Arguments: `-y @modelcontextprotocol/server-[service-name]`
   - Add any required environment variables

3. **Using MCP Servers with AI Agent**

   - Add an AI Agent node to your workflow
   - Enable MCP Client as a tool
   - Configure different MCP Client nodes with different credentials
   - Create prompts that leverage multiple data sources

### Example: Using Brave Search

1. Configure credentials:
   - Command: `npx`
   - Arguments: `-y @modelcontextprotocol/server-brave-search`
   - Environment Variables: `BRAVE_API_KEY=your-api-key`

2. Create a workflow:
   - Add an MCP Client node
   - Select "List Tools" operation to see available search tools
   - Add another MCP Client node
   - Select "Execute Tool" operation
   - Choose the "brave_search" tool
   - Set Parameters to: `{"query": "latest AI news"}`

### Using Local MCP Server with SSE

If you're running a local MCP server that supports Server-Sent Events (SSE):

1. Start the local MCP server:
   ```bash
   npx @modelcontextprotocol/server-example-sse
   ```

2. Configure MCP Client credentials in n8n:
   - Select Connection Type: Server-Sent Events (SSE)
   - Create new credentials of type MCP Client (SSE) API
   - Set SSE URL: `http://localhost:3001/sse`
   - Add any required headers for authentication

### Enabling MCP Tools in AI Agents

To use MCP clients as tools in AI Agent nodes, set the environment variable:

```bash
export N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
```

In Docker, add this to your environment configuration:
```yaml
environment:
  - N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
```

## Running as a Service (Optional)
To ensure the services start on system boot:

```bash
sudo nano /etc/systemd/system/localai.service
```

Add the following content:
```
[Unit]
Description=Local AI Package
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/path/to/local-ai-packaged
ExecStart=/usr/bin/python3 start_services.py --profile cpu
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable localai.service
sudo systemctl start localai.service
```

## Updating

```bash
# Stop all services
docker compose -p localai -f docker-compose.yml -f supabase/docker/docker-compose.yml down

# Pull latest versions of all containers
docker compose -p localai -f docker-compose.yml -f supabase/docker/docker-compose.yml pull

# Start services again with your desired profile
python3 start_services.py --profile <your-profile>
```

## Troubleshooting

- Check the [GitHub README](https://github.com/coleam00/local-ai-packaged?tab=readme-ov-file#troubleshooting)
- Visit the [Community Forum](https://thinktank.ottomator.ai/c/local-ai/18)
- Check service logs: `docker compose -p localai logs`
- Check system resources: `htop` (install with `sudo apt install htop` if needed) 
