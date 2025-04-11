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

# Options to display
PS3="Please select an option: "
opt1="Basic MongoDB, Node, NPM, PM2"
opt2="MERN APP"
opt3="MERN APP + Nginx"
opt4="Quit"
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
            break
            ;;
        "$opt2")
            echo -e "${YELLOW}Processing... $opt2${NC}"
            sleep 1
            break
            ;;
        "$opt3")
            echo -e "${YELLOW}Processing... $opt3${NC}"
            sleep 1
            break
            ;;
        "$opt4")
            echo -e "${YELLOW}Exiting...${NC}"
            break
            ;;
    esac
done
