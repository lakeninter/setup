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
MONGO_URL="mongodb://${USERNAME}:${PASSWORD}@${IP}:27017/?authSource=admin"
echo -e "\nYour MONGO_URL: ${GREEN}${BOLD}${UNDERLINE}${MONGO_URL}${NC}\n"

# Check mongodb is installed
isMongoDB=0
function managedMongoDBSetup (){
    if command -v mongod >/dev/null 2>&1; then
        echo -e "${BLUE}MongoDB is already installed, skipping.\n${NC}"
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

        # Step 8: Updating /etc/mongod.conf to allow remote connections + auth
        sudo sed -i '$a\
        security:\
          authorization: enabled' /etc/mongod.conf

        sudo sed -i '$a\
        net:\
          port: 27017\
          bindIp: 0.0.0.0' /etc/mongod.conf

        # Step 9: Restart mongod
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
        mongosh "${MONGO_URL}" <<EOF
            use sampleDB
            db.sampleDB.insertMany([
                { name: "John", age: 30 },
                { name: "Jane", age: 25 },
                { name: "Bob", age: 40 }
            ])
            exit
EOF
        echo -e "${GREEN}MongoDB setup done${NC}\n"
    fi
}

startTime=$(date +%s)

# Update system
sudo apt update && sudo apt upgrade -y

# Installing packages
# Check and install curl
if ! curl --version &>/dev/null; then
  echo "Installing curl..."
  sudo apt install -y curl
else
  echo -e "${BLUE}curl is already installed, skipping.\n${NC}"
fi

# Check and install Node.js v20
if ! node --version 2>/dev/null | grep -q '^v20\.'; then
  echo "Installing Node.js 20.x..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo -e "${BLUE}Node.js 20.x is already installed, skipping.${NC}\n"
fi

# Check and install npm@11
if ! npm --version 2>/dev/null | grep -q '^11\.'; then
  echo "Upgrading npm to v11..."
  sudo npm install -g npm@11
else
  echo -e "${BLUE}npm v11 is already installed, skipping.${NC}\n"
fi

# Check and install pm2
if ! pm2 --version &>/dev/null; then
  echo "Installing pm2..."
  sudo npm install -g pm2
else
  echo -e "${BLUE}pm2 is already installed, skipping.${NC}\n"
fi

# Check and install ufw
if ! ufw --version &>/dev/null; then
  echo "Installing ufw..."
  sudo apt install -y ufw
else
  echo -e "${BLUE}ufw is already installed, skipping.\n${NC}"
fi

# Setup MongoDB
managedMongoDBSetup

# Optionally open Mongo port via ufw (uncomment if you want it open publicly)
# sudo ufw allow 27017

#############################################
#      SPIN UP THE MERN APPLICATIONS       #
#############################################

function spinMERNapp(){
  echo -e "${BLUE}Starting MERN App Setup...${NC}"

  # Ensure our "works" subdirectories exist
  mkdir -p works/backend
  mkdir -p works/frontend

  # 1) Download and unzip Node-Express backend into works/backend
  echo -e "${YELLOW}Downloading Node Express zip...${NC}"
  curl -L -o node-express.zip \
    "https://github.com/lakeninter/setup/raw/refs/heads/main/node-express.zip"

  echo -e "${YELLOW}Unzipping Node Express into ./works/backend...${NC}"
  unzip -o node-express.zip -d ./works/backend

  # 2) Create .env file in backend with user-provided MONGO_URL
  cd works/backend
  echo -e "${YELLOW}Creating .env for backend...${NC}"
  cat <<EOF > .env
PORT=5000
MONGO_URL=${MONGO_URL}
EOF

  # 3) Install dependencies
  echo -e "${YELLOW}Installing backend dependencies (npm i)...${NC}"
  npm install

  # 4) Start with pm2 or run dev
  echo -e "${YELLOW}Starting backend with pm2...${NC}"
  pm2 start npm --name "mern-backend" -- run dev

  # Go back to project root
  cd ../../

  # 5) Download and unzip React-Vite-Tailwind frontend into works/frontend
  echo -e "${YELLOW}Downloading React Vite Tailwind zip...${NC}"
  curl -L -o react-vite-tailwind.zip \
    "https://github.com/lakeninter/setup/raw/refs/heads/main/react-vite-tailwind.zip"

  echo -e "${YELLOW}Unzipping React Vite Tailwind into ./works/frontend...${NC}"
  unzip -o react-vite-tailwind.zip -d ./works/frontend

  # 6) Install dependencies for React app
  cd works/frontend
  echo -e "${YELLOW}Installing frontend dependencies (npm i)...${NC}"
  npm install

  # 7) Start React app with pm2 (dev mode)
  echo -e "${YELLOW}Starting frontend with pm2...${NC}"
  pm2 start npm --name "mern-frontend" -- run dev

  cd ../../

  echo -e "\n${GREEN}MERN apps are now running via pm2.${NC}"
  
  # Optional: Show PM2 logs (last 100 lines) for verification
  echo -e "\n${BLUE}Showing PM2 logs (last 100 lines) for the backend:${NC}"
  pm2 logs mern-backend --lines 100 --nostream

  echo -e "\n${BLUE}Showing PM2 logs (last 100 lines) for the frontend:${NC}"
  pm2 logs mern-frontend --lines 100 --nostream

  echo -e "\nTo continuously tail logs, use:"
  echo -e "  ${YELLOW}pm2 logs mern-backend${NC} or ${YELLOW}pm2 logs mern-frontend${NC}"
  echo -e "To see pm2 status: ${YELLOW}pm2 list${NC}"
}

spinMERNapp

endTime=$(date +%s)
runtime=$((endTime - startTime))
minutes=$((runtime / 60))
seconds=$((runtime % 60))

echo -e "✅ ${GREEN}Total Execution Time: ${YELLOW}${BOLD}${minutes} min ${seconds} sec${NC}"
