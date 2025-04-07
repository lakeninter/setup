#!/bin/bash

# Define color variables
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

# Greetings
function greetFunc(){
    clear
    echo -e "${BLUE}************************************${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${GREEN}* ${BOLD}Welcome To Crazy Tech Solution🔥 *${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${BLUE}************************************${NC}"

}
greetFunc

# Taking inputs from the user
read -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" IP
read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD


MONGO_URL="\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin${NC}\n"
echo -e $MONGO_URL
