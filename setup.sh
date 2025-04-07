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
function managedMongoDBSetup (){
    if command -v mongod >/dev/null 2>&1; then
        echo -e "${BLUE}\nMongoDB is already installed\n${NC}"
        isMongoDB=1
    else
        # Step 1: Import MongoDB GPG Key
        curl -fsSL https://pgp.mongodb.com/server-6.0.asc \
        | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

        # Step 2: Add the MongoDB Repository
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] \
        https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
        | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

        # Step 3: Update Package Database
        sudo apt-get update

        # Step 4: Install MongoDB
        sudo apt-get install -y mongodb-org

        # Step 5: Start MongoDB Service
        sudo systemctl start mongod

        # Step 6: Enable MongoDB Service on Boot
        sudo systemctl enable mongod

        # Step 7: Check MongoDB Status
        systemctl status mongod

        # Step 8: Updating /etc/mongod.conf
        sudo sed -i '$a\
        security:\
        authorization: enabled' /etc/mongod.conf

        sudo sed -i '$a\
        # network interfaces\
        net:\
        port: 27017\
        bindIp: 0.0.0.0' /etc/mongod.conf

        # Step 9: Restarting mongod
        sudo systemctl restart mongod

        # Step 10: Inserting sample data in DB
        mongosh <<EOF
            use admin
            db.createUser({
                user: "adminUser",
                pwd: "strongPassword",
                roles: [ { role: "root", db: "admin" } ]
            })
        EOF
        mongosh "$MONGO_URL" <<EOF
        use sampleDB
        db.sampleDB.insertMany([
            { name: "John", age: 30 },
            { name: "Jane", age: 25 },
        { name: "Bob", age: 40 }
        ])
        exit
EOF
    echo -e "${GREEN} MongoDB setup done"
    fi
}


# Installing packages
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y curl nodejs
npm install -g npm@11
npm install -g pm2
sudo apt-get install ufw
# Involking managedMongoDBSetup function
managedMongoDBSetup

sudo ufw allow 27017
sudo systemctl restart mongod


