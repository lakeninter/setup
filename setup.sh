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

# Mongo connection string
MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"
echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin${NC}\n"

# Check mongodb is installed
isMongoDB=0
function checkMongoDBExists (){
    if command -v mongod >/dev/null 2>&1; then
        echo -e "${BLUE}\nMongoDB is already installed\n${NC}"
        isMongoDB=1
    else 
        echo -e "${RED}\nMongoDB installing will start soon\n${NC}"
        isMongoDB=0
    fi
}
checkMongoDBExists

# Installing packages
# sudo apt update && sudo apt upgrade -y
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# sudo apt install -y curl nodejs

# Inserting sample data in DB
mongosh "$MONGO_URL" <<EOF
use sampleDB
db.sampleDB.insertMany([
    { name: "John", age: 30 },
    { name: "Jane", age: 25 },
  { name: "Bob", age: 40 }
])
exit
EOF

# mongosh "mongodb://adminUser:strongPassword@38.99.82.133:27017/?authSource=admin"

