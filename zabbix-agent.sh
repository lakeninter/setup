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
    echo -e "${GREEN}* ${BOLD}Welcome To Crazy Tech Solution🔥 *${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${BLUE}************************************${NC}"
}

startTime=$(date +%s)

greetFunc

echo -e "\n${GREEN} Zabbix installation will begin\n Please wait...${NC}\n"
set -e

# Download the Zabbix release package
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb

# Install the Zabbix release package
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb

# Update package lists
apt update -y

# Install Zabbix agent
apt install zabbix-agent -y

# Configure Zabbix agent server settings
sed -i 's/^Server=.*/Server=67.220.85.106/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=.*/ServerActive=67.220.85.106/' /etc/zabbix/zabbix_agentd.conf

# Restart the Zabbix agent service
systemctl restart zabbix-agent

# Optional: Check status of the Zabbix agent service
# systemctl status zabbix-agent

endTime=$(date +%s)
runTime=$((endTime - startTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

# Removing files 
rm -rf zabbix-release_latest_7.2+ubuntu24.04_all.deb

echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"
echo -e "${GREEN}${BOLD}Zabbix agent installed successfully"
