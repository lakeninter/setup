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
# IP=$(hostname -I | awk '{print $1}')

# result=$(nslookup "$DOMAIN")
# # Display the full nslookup result.
# echo -e "${BLUE}${BOLD}nslookup result for $DOMAIN:${NC}"
# EXPECTED_IP=$(echo "$result" | awk '/^Address: / {print $2}' | tail -n1)

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

function spinGo() {
  # sudo apt-get remove -y zip
  installPackageIfNotExits "zip" "apt-get install -y zip"
  installPackageIfNotExits "go" "sudo apt update && sudo apt install -y golang-go"
  installPackageIfNotExits "nginx" "sudo apt update && sudo apt install -y nginx"
  installPackageIfNotExits "certbot" "sudo apt-get update && sudo apt-get install -y certbot python3-certbot-nginx"

  # Creating Directory
  mkdir -p ./works
  cd works
  mkdir -p ./incomming_go
  mkdir -p ./mongo-csv-export

  # Unzipping files
  curl -L -o go.zip https://github.com/lakeninter/setup/raw/refs/heads/main/zips/go.zip 
  sleep 1
  curl -L -o mongo-csv-export.zip https://github.com/lakeninter/setup/raw/refs/heads/main/zips/mongo-csv-export.zip
  sleep 1

  unzip go.zip -d ./incomming_go
  sleep 1
  unzip mongo-csv-export.zip -d ./mongo-csv-export
  sleep 1

  # clean up
  rm -rf go.zip mongo-csv-export.zip

  echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}${MONGO_URL}${NC}\n"

  # creating .env.local file
  cat <<EOF > ./incomming_go/.env
MONGO_URL=${MONGO_URL}
PORT=7000
EOF

  cd incomming_go
  go mod init incomming_go
  sleep 1
  go mod tidy
  sleep 1.5

  cd ..
  cd ./mongo-csv-export
  npm i
  sleep 1
  cd ..
  # Updation in mongo-csv-export
  sed -i "s|const uri = 'YOUR CONNECTION STRING';|const uri = '$MONGO_URL';|g" /root/works/mongo-csv-export/server.js
  sed -i "s|const API_BASE_URL = 'YOUR API BASE URL';|const API_BASE_URL = 'http://$IP:4000';|g" /root/works/mongo-csv-export/index.html


  # To update nginx.conf inside nginx directory
  sudo sed -i '/include \/etc\/nginx\/sites-enabled\/\*;/ { /^[[:space:]]*#/! s/^/# / }' /etc/nginx/nginx.conf

  sleep 1.5

  # To add domain.conf file inside nginx/conf directory
  cat <<EOF > /etc/nginx/conf.d/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN;  # Change to your domain or IP

    # --- Proxy all other requests to the Vite Dev Server ---
    location /mongo-csv-export {
        proxy_pass http://127.0.0.1:4000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # --- Proxy all other requests to the Vite Dev Server ---
    location / {
        proxy_pass http://127.0.0.1:7000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

  sleep 1.5
  # Obtain or renew the SSL certificate using Certbot (non-interactive mode)
  sudo certbot --nginx -d "${DOMAIN}" --non-interactive --agree-tos --email "${EMAIL}"
  sleep 1.5

  echo -e "${GREEN}Nginx SSL setup complete for ${DOMAIN}.${NC}"
  
  sleep 1.5
  sudo nginx -t
  sleep 1.5

  # Reload the Nginx configuration so the changes take effect
  sudo systemctl reload nginx
  sleep 1.5
  echo -e "${BLUE}Firewall rule updated${NC}"
  sudo ufw allow 'Nginx Full'
  sleep 1.5

  go build -o incomming_go main.go
  sleep 2
  pm2 start ./incomming_go --name "main.go"

  # pm2 node ./mongo-csv-export --name "main.go"
  sleep 1.5
  echo -e "${BLUE}${UNDERLINE}https://$DOMAIN${NC}"

#   npm run both
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

# Calling spinGo fuction
# Compare the actual IP with the expected IP.
if [ "$IP" == "$EXPECTED_IP" ]; then
    echo -e "${GREEN}Success: The domain $DOMAIN correctly resolves to $EXPECTED_IP.${NC}"
    spinGo
else
    echo -e "${RED}${BOLD}Mismatch: The domain $DOMAIN is not pointed to $IP${NC}"
fi
endTime=$(date +%s)
runtime=$((endTime - startingTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo "MONGO_URL is: $MONGO_URL"
echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"