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
greetFunc

#########################################
# Function to check and install zip if not installed
#########################################
function installPackageIfNotExits(){
  packageName="$1"

  if ! command -v "$packageName" > /dev/null; then
    echo -e "${YELLOW}${BOLD}$packageName could not be found, Installing $packageName...${NC}"
    sudo apt-get install -y zip
  else
    echo -e "${GREEN}$packageName is already installed....${NC}"
    
  fi
}
#########################################
# Function to spin MERN app
#########################################

function spinMern() {
  # sudo apt-get remove -y zip
  installPackageIfNotExits "zip"
  
  # Creating Directory
  mkdir -p ./works

  # Unzipping files
  curl -L -o react-vite.zip https://github.com/lakeninter/setup/raw/refs/heads/main/react-vite-tailwind.zip 

  curl -L -o express-node.zip https://github.com/lakeninter/setup/raw/refs/heads/main/node-express.zip

  unzip react-vite.zip -d ./works/frontend

  unzip express-node.zip -d ./works/backend

  # clean up
  rm -rf react-vite.zip express-node.zip

  cd works/frontend/
  npm i
  cd ../backend/
  npm i
  npm run both

  echo -e "${GREEN}${BOLD}Frontend started on: ${BLUE}${UNDERLINE}http://localhost:5173 \nBackend started on: ${BLUE}${UNDERLINE}http://localhost:5000${NC}"
}

startTime=$(date +%s)
# Calling spinMern fuction
spinMern
endTime=$(date +%s)
runtime=$((endTime - startTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"
