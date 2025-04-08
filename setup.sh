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
greetFunc

#########################################
# Taking inputs from the user
#########################################
read -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" IP
read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD

# Construct the Mongo Connection String (needed inside the function too)
MONGO_URL="mongodb://${USERNAME}:${PASSWORD}@${IP}:27017/?authSource=admin"

#########################################
# MongoDB Setup
#########################################
function managedMongoDBSetup (){
    # If mongod is already installed, skip the main installation steps
    if command -v mongod >/dev/null 2>&1; then
        echo -e "${BLUE}MongoDB is already installed, skipping main installation.\n${NC}"
        
        # Step 1: Update
        sudo apt-get update -y

        # Step 5: Start MongoDB Service
        sudo systemctl start mongod

        # Step 6: Enable MongoDB Service on Boot
        sudo systemctl enable mongod

        # Step 9: Restart mongod
        sudo systemctl daemon-reload
        sudo systemctl restart mongod

    else
        # Step 1: Import MongoDB GPG Key
        curl -fsSL https://pgp.mongodb.com/server-6.0.asc \
        | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

        # Step 2: Add the MongoDB Repository
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
        | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

        # Step 3: Update Package Database
        sudo apt-get update -y

        # Step 4: Install MongoDB
        sudo apt-get install -y mongodb-org

        # Step 5: Start MongoDB Service
        sudo systemctl start mongod

        # Step 6: Enable MongoDB Service on Boot
        sudo systemctl enable mongod

        # Step 8: Updating /etc/mongod.conf to allow remote connections + auth
        sudo sed -i 's/^  bindIp: 127.0.0.1$/  bindIp: 0.0.0.0/' /etc/mongod.conf
        sudo sed -i 's/^#security:/security:\n authorization: enabled/' /etc/mongod.conf

        # Step 9: Restart mongod
        sudo systemctl daemon-reload
        sudo systemctl restart mongod
    fi

    #########################################
    # Step 10: Create the admin user and insert sample data
    # IMPORTANT: Use the credentials from the user input
    #########################################
    echo -e "${BLUE}Creating user '$USERNAME' in admin DB.${NC}"
    mongosh <<EOF
        use admin
        db.createUser({
            user: "$USERNAME",
            pwd: "$PASSWORD",
            roles: [ { role: "root", db: "admin" } ]
        })
EOF

    echo -e "${BLUE}Inserting sample data into sampleDB...${NC}"
    mongosh "${MONGO_URL}" <<EOF
        use sampleDB
        db.sampleDB.insertMany([
            { name: "John", age: 30 },
            { name: "Jane", age: 25 },
            { name: "Bob", age: 40 }
        ])
        exit
EOF

    echo -e "${GREEN}MongoDB setup/check complete.${NC}\n"
}

#########################################
# Main Script Start
#########################################
startTime=$(date +%s)

# Update system
sleep 3
sudo apt-get update -y && sudo apt-get upgrade -y
sleep 3

#########################################
# Installing packages
#########################################

# Check and install curl
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get install -y curl
else
  echo -e "${BLUE}curl is already installed, skipping.${NC}\n"
fi
sleep 3

# Check and install Node.js v20
if ! node --version 2>/dev/null | grep -q '^v20\.'; then
  echo "Installing Node.js 20.x..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo -e "${BLUE}Node.js 20.x is already installed, skipping.${NC}\n"
fi
sleep 3

# Check and install npm@11
if ! npm --version 2>/dev/null | grep -q '^11\.'; then
  echo "Upgrading npm to v11..."
  sudo npm install -g npm@11
else
  echo -e "${BLUE}npm v11 is already installed, skipping.${NC}\n"
fi
sleep 3

# Check and install pm2
if ! command -v pm2 &>/dev/null; then
  echo "Installing pm2..."
  sudo npm install -g pm2
else
  echo -e "${BLUE}pm2 is already installed, skipping.${NC}\n"
fi
sleep 3

# Check and install ufw
if ! command -v ufw &>/dev/null; then
  echo "Installing ufw..."
  sudo apt-get install -y ufw
else
  echo -e "${BLUE}ufw is already installed, skipping.${NC}"
fi
sleep 3

#########################################
# Setup MongoDB
#########################################
managedMongoDBSetup

#########################################
# Optionally open Mongo port via ufw
#########################################
sudo ufw allow 27017
sudo systemctl restart mongod

#########################################
# Print final MONGO_URL for the user
#########################################
echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}${MONGO_URL}${NC}\n"

endTime=$(date +%s)
runtime=$((endTime - startTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"
