#!/bin/bash

#########################################
# Define color variables
#########################################
NC='\033[0m'          # No Color / Reset
BOLD='\033[1m'
UNDERLINE='\033[4m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

#########################################
# Greetings
#########################################
function greetFunc(){
    clear
    echo -e "${BLUE}************************************${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${GREEN}* ${BOLD} MERN app - Crazy Tech Solution  *${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${BLUE}************************************${NC}"
}
# greetFunc


#########################################
# Taking inputs from the user
#########################################
# read -p "$(echo -e ${YELLOW}Enter your domain: ${NC})" DOMAIN

# Getting the default IP
IP=$(hostname -I | awk '{print $1}')

result=$(nslookup "$DOMAIN")
# Display the full nslookup result.
echo -e "${BLUE}${BOLD}nslookup result for $DOMAIN:${NC}"
EXPECTED_IP=$(echo "$result" | awk '/^Address: / {print $2}' | tail -n1)

#########################################
# Function to check and install zip if not installed
#########################################
function installPackageIfNotExits(){
  packageName="$1"
  packageCMD="$2"

  if ! command -v "$packageName" > /dev/null; then
    echo -e "${YELLOW}${BOLD}$packageName could not be found, Installing $packageName...${NC}"
    eval $packageCMD
    sleep 1.5
  else
    echo -e "${GREEN}$packageName is already installed....${NC}"
    
  fi
}
#########################################
# Function to spin MERN app
#########################################

function spinMern() {
  # sudo apt-get remove -y zip
  installPackageIfNotExits "zip" "apt-get install -y zip"
  installPackageIfNotExits "nginx" "sudo apt update && sudo apt install -y nginx"
  # Creating Directory
  mkdir -p ./works

  # Unzipping files
  curl -L -o react-vite.zip https://github.com/lakeninter/setup/raw/refs/heads/main/react-vite-tailwind.zip 

  curl -L -o express-node.zip https://github.com/lakeninter/setup/raw/refs/heads/main/node-express.zip

  unzip react-vite.zip -d ./works/frontend

  unzip express-node.zip -d ./works/backend

  # clean up
  rm -rf react-vite.zip express-node.zip

  echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}${MONGO_URL}${NC}\n"

  echo -e "\nYour StartTime: ${GREEN}${BOLD}${UNDERLINE}${startTime}${NC}\n"

  # creating .env.local file
  cat <<EOF > ./works/backend/.env
MONGO_URL=${MONGO_URL}
EOF

  cd works/frontend/
  npm i
  # Step 1: Prepend the new import statements and comment at the top.
  cat <<EOF > vite.config.js
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    host: true, // This makes Vite listen on 0.0.0.0
    port: 5173,
    allowedHosts: ['$DOMAIN'],
  }
});
EOF


  cd ../backend/
  npm i

  # To update nginx.conf inside nginx directory
  sudo sed -i '/include \/etc\/nginx\/sites-enabled\/\*;/ { /^[[:space:]]*#/! s/^/# / }' /etc/nginx/nginx.conf

  sleep 1.5

  # To add domain.conf file inside nginx/conf directory
  cat <<EOF > /etc/nginx/conf.d/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN;  # Change to your domain or IP

    # --- Proxy API requests to Node backend ---
    location /api/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # --- Proxy all other requests to the Vite Dev Server ---
    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

  sleep 1.5
  sudo nginx -t
  sleep 1.5

  sudo systemctl reload nginx
  sleep 1.5

  echo -e "${GREEN}${BOLD}Frontend started on: ${BLUE}${UNDERLINE}http://localhost:5173\n${BLUE}${UNDERLINE}http://$DOMAIN\nBackend started on: ${BLUE}${UNDERLINE}http://localhost:5000${NC}"

  npm run both
}

#########################################
# Set starting time based on whether startTime exists
#########################################

# Corrected the if-statement: added quotes around $startTime and proper spacing before the closing bracket.
if [ -n "$startTime" ]; then
  startingTime=$(date -d @"$startTime" +%s)
else 
  startingTime=$(date +%s)
fi

# Now you can use any variables or functions defined in mern.sh
sleep 2

# Calling spinMern fuction
# Compare the actual IP with the expected IP.
if [ "$IP" == "$EXPECTED_IP" ]; then
    echo -e "${GREEN}Success: The domain $DOMAIN correctly resolves to $EXPECTED_IP.${NC}"
    spinMern
else
    echo -e "${RED}${BOLD}Mismatch: The domain $DOMAIN is not pointed to $IP${NC}"
fi
endTime=$(date +%s)
runtime=$((endTime - startingTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo "MONGO_URL is: $MONGO_URL"
echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"

