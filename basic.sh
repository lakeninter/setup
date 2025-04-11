#!/bin/bash

#########################################
# Define color variables
#########################################
NC='\033[0m' # No Color / Reset
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
function greetFunc() {
    clear
    echo -e "${BLUE}************************************${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${GREEN}* ${BOLD}Welcome To Crazy Tech Solution🔥 *${NC}"
    echo -e "${BLUE}*                                  *${NC}"
    echo -e "${BLUE}************************************${NC}"
}
greetFunc

defaultIP=$(hostname -I | awk '{print $1}')
#########################################
# Taking inputs from the user
#########################################
read -e -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" -i $defaultIP IP
read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD
read -p "$(echo -e ${YELLOW}Enter your domain: ${NC})" DOMAIN

# Construct the Mongo Connection String (needed inside the function too)
MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"

#########################################
# Function to check and install zip if not installed
#########################################
function installPackageIfNotExits() {
    packageName="$1"
    installCMD="$2"
    packageVersion="$3"

    # if package is not installed
    if ! command -v "$packageName" >/dev/null; then
        echo -e "${YELLOW}${BOLD}$packageName could not be found, Installing $packageName...${NC}"
        sudo apt-get update -y
        # Use eval to handle commands with pipes and multiple parts.
        eval "$installCMD"
        sleep 1.5
    else
        # If a target version is specified, compare versions.
        if [ -n "$packageVersion" ]; then
            # Get the installed package's version.
            installedVersion=$("$packageName" --version 2>/dev/null | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
            # If the installed version is less than the target version, upgrade.
            if dpkg --compare-versions "$installedVersion" lt "$packageVersion"; then
                echo -e "${YELLOW}${BOLD}$packageName version $installedVersion is less than required $packageVersion. Upgrading...${NC}"
                eval "$installCMD"
            else
                echo -e "${GREEN}$packageName is already installed with version $packageVersion ${NC}"
            fi
        else
            echo -e "${GREEN}$packageName is already installed....${NC}"
        fi
    fi
}

#########################################
# MongoDB Setup
#########################################
function managedMongoDBSetup() {
    # If mongod is already installed, skip the main installation steps
    if command -v mongod >/dev/null; then
        echo -e "${BLUE}MongoDB is already installed....${NC}"

        # Step 5: Start MongoDB Service
        # sudo systemctl start mongod

        # # Step 6: Enable MongoDB Service on Boot
        # sudo systemctl enable mongod

        # # Step 9: Restart mongod
        # sudo systemctl daemon-reload
        # sudo systemctl restart mongod

        echo -e "${BLUE}Inserting sample data into sampleDB...${NC}"
        mongosh "$MONGO_URL" <<EOF
            use sampleDB
            db.sampleDB.insertMany([
                { name: "John", age: 30 },
                { name: "Jane", age: 25 },
                { name: "Bob", age: 40 }
            ])
            exit
EOF

        echo -e "${GREEN}MongoDB sample data inserted.${NC}\n"

    else
        echo -e "${YELLOW}${BOLD}MongoDB could not be found, Installing MongoDB...${NC}"
        sleep 1
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
        

        #########################################
        # Step 10: Create the admin user and insert sample data
        # IMPORTANT: Use the credentials from the user input
        #########################################
        sleep 1.5
        echo -e "${BLUE}Creating user '$USERNAME' in admin DB.${NC}"
        sleep 1.5
        mongosh <<EOF
            use admin
            db.createUser({
                user: "$USERNAME",
                pwd: "$PASSWORD",
                roles: [ { role: "root", db: "admin" } ]
            })
EOF
        sleep 1.5
        echo -e "${BLUE}Inserting sample data into sampleDB...${NC}"
        sleep 1.5
        mongosh "$MONGO_URL" <<EOF
            use sampleDB
            db.sampleDB.insertMany([
                { name: "John", age: 30 },
                { name: "Jane", age: 25 },
                { name: "Bob", age: 40 }
            ])
            exit
EOF

        echo -e "${GREEN}MongoDB sample data inserted.${NC}\n"
    fi
}

#########################################
# Main Script Start
#########################################
startTime=$(date +%s)

# Update system
sleep 1.5
sudo apt-get update -y && sudo apt-get upgrade -y
sleep 1.5

#########################################
# Installing packages
#########################################

# Check and install curl
installPackageIfNotExits "curl" "sudo apt-get install -y curl"

# Check and install Node.js v20
installPackageIfNotExits "nodejs" "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"

# Check and install npm@11
installPackageIfNotExits "npm" "npm install -g npm@11" "11"

# Check and install pm2
installPackageIfNotExits "pm2" "npm install -g pm2"

# Check and install ufw
installPackageIfNotExits "ufw" "sudo apt-get install -y ufw"

# Check and install zip
installPackageIfNotExits "zip" "sudo apt-get install -y zip"
sleep 1.5
#########################################
# Setup MongoDB
#########################################
managedMongoDBSetup
sleep 1.5

#########################################
# Optionally open Mongo port via ufw
#########################################
sudo ufw allow 27017
sudo systemctl restart mongod

#########################################
# Print final MONGO_URL for the user
#########################################
echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}$MONGO_URL${NC}\n"

endTime=$(date +%s)
runtime=$((endTime - startTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"

# Spinnig MERN app
# Export MONGO_URL so the remote script sees it.
export MONGO_URL="${MONGO_URL}"
export DOMAIN="${DOMAIN}"
export startTime="${startTime}"
sleep 2

# Source the remote mern.sh script.
# source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/mern_nginx.sh)
