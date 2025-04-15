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

#########################################
# OPTION 1 => Run Basic setup
#########################################
function basicSetup() {
    defaultIP=$(hostname -I | awk '{print $1}')
    #########################################
    # Taking inputs from the user
    #########################################
    read -e -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" -i $defaultIP IP
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD

    # Mongo Connection String
    MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"

    # Export MONGO_URL so the remote script sees it.
    export MONGO_URL="${MONGO_URL}"
    sleep 1
    source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/basic.sh)
}

#########################################
# OPTION 2 => Run MERN APP setup
#########################################
function mernSetup() {
    defaultIP=$(hostname -I | awk '{print $1}')
    #########################################
    # Taking inputs from the user
    #########################################
    read -e -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" -i $defaultIP IP
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD

    # Mongo Connection String
    MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"

    # Export MONGO_URL so the remote script sees it.
    export MONGO_URL="${MONGO_URL}"
    sleep 1
    source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/basic.sh)
    sleep 1
    source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/mern.sh)
}

#########################################
# OPTION 3 => Run MERN APP + Nginx setup
#########################################
function mernNginxSetup() {
    defaultIP=$(hostname -I | awk '{print $1}')
    #########################################
    # Taking inputs from the user
    #########################################
    read -e -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" -i $defaultIP IP
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD
    read -p "$(echo -e ${YELLOW}Enter your domain: ${NC})" DOMAIN
    read -p "$(echo -e ${YELLOW}Enter your email: ${NC})" EMAIL

    # Getting the default IP
    IP=$(hostname -I | awk '{print $1}')

    result=$(nslookup "$DOMAIN")
    # Display the full nslookup result.
    echo -e "${BLUE}${BOLD}nslookup result for $DOMAIN:${NC}"
    EXPECTED_IP=$(echo "$result" | awk '/^Address: / {print $2}' | tail -n1)
    # Compare the actual IP with the expected IP.
    if [ "$IP" == "$EXPECTED_IP" ]; then
        echo -e "${GREEN}Success: The domain $DOMAIN correctly resolves to $EXPECTED_IP.${NC}"
        # Mongo Connection String
        MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"

        # Export MONGO_URL so the remote script sees it.
        export MONGO_URL="${MONGO_URL}"
        export DOMAIN="${DOMAIN}"
        export EMAIL="${EMAIL}"
        export EXPECTED_IP="$EXPECTED_IP"
        export result="$result"
        export IP="$IP"
        sleep 1
        source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/basic.sh)
        sleep 1
        source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/mern_nginx.sh)
        
    else
        echo -e "${RED}${BOLD}Mismatch: The domain $DOMAIN is not pointed to $IP${NC}"
    fi

}

#########################################
# OPTION 4 => Run GO APP + Nginx setup
#########################################
function goNginxSetup() {
    defaultIP=$(hostname -I | awk '{print $1}')
    #########################################
    # Taking inputs from the user
    #########################################
    read -e -p "$(echo -e ${YELLOW}Enter your server IP: ${NC})" -i $defaultIP IP
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Username: ${NC})" USERNAME
    read -p "$(echo -e ${YELLOW}Enter your mongoDB Password: ${NC})" PASSWORD
    read -p "$(echo -e ${YELLOW}Enter your domain: ${NC})" DOMAIN
    read -p "$(echo -e ${YELLOW}Enter your email: ${NC})" EMAIL

    # Getting the default IP
    IP=$(hostname -I | awk '{print $1}')

    result=$(nslookup "$DOMAIN")
    # Display the full nslookup result.
    echo -e "${BLUE}${BOLD}nslookup result for $DOMAIN:${NC}"
    EXPECTED_IP=$(echo "$result" | awk '/^Address: / {print $2}' | tail -n1)
    # Compare the actual IP with the expected IP.
    if [ "$IP" == "$EXPECTED_IP" ]; then
        echo -e "${GREEN}Success: The domain $DOMAIN correctly resolves to $EXPECTED_IP.${NC}"
        # Mongo Connection String
        MONGO_URL="mongodb://$USERNAME:$PASSWORD@$IP:27017/?authSource=admin"

        # Export MONGO_URL so the remote script sees it.
        export MONGO_URL="${MONGO_URL}"
        export DOMAIN="${DOMAIN}"
        export EMAIL="${EMAIL}"
        export EXPECTED_IP="$EXPECTED_IP"
        export result="$result"
        export IP="$IP"
        sleep 1
        source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/basic.sh)
        sleep 1
        source <(curl -s https://raw.githubusercontent.com/lakeninter/setup/refs/heads/main/go_nginx.sh)
        
    else
        echo -e "${RED}${BOLD}Mismatch: The domain $DOMAIN is not pointed to $IP${NC}"
    fi

}

# Options to display
PS3="Please select an option: "
opt1="Basic MongoDB, Node, NPM, PM2"
opt2="MERN APP"
opt3="MERN APP + Nginx"
opt4="GO + Nginx"
optlast="Quit"
options=("$opt1" "$opt2" "$opt3" "$opt4")

select opt in "${options[@]}"; do
    if [ -z "$opt" ]; then
        echo -e "${RED}${BOLD}Invalid option. Please try again.${NC}"
        continue
    fi

    case $opt in
        "$opt1")
            echo -e "${YELLOW}Processing... $opt1${NC}"
            sleep 1
            basicSetup
            break
            ;;
        "$opt2")
            echo -e "${YELLOW}Processing... $opt2${NC}"
            sleep 1
            mernSetup
            break
            ;;
        "$opt3")
            echo -e "${YELLOW}Processing... $opt3${NC}"
            sleep 1
            mernNginxSetup
            break
            ;;
        "$opt4")
            echo -e "${YELLOW}Processing... $opt3${NC}"
            sleep 1
            goNginxSetup
            break
            ;;
        "$optlast")
            echo -e "${YELLOW}Exiting...${NC}"
            break
            ;;
    esac
done
