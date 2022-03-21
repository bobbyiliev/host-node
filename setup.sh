#!/bin/bash

##
# Script to setup and manage multiple Node applications
##

# Check if Nginx is installed and running
function nginx_check() {
    # check for process
    if [ -z "$(pgrep nginx)" ]; then
        echo "Nginx is not running, please start it"
        echo "If nginx is not installed, please install it with:"
        echo "sudo apt install nginx"
        exit 1
    fi
}

# Check if Node is installed
function node_check() {
    if [[ ! -f /usr/bin/node ]]; then
        echo "Node is not installed, please install it"
        echo "If node is not installed, please install it with:"
        echo "sudo apt install nodejs"
        exit 1
    fi
}

# Check if npm is installed
function npm_check() {
    if [[ ! -f /usr/bin/npm ]]; then
        echo "npm is not installed, please install it"
        echo "If npm is not installed, please install it with:"
        echo "sudo apt install npm"
        exit 1
    fi
}

# Check if pm2 is installed
function pm2_check() {
    if [[ ! -f /usr/local/bin/pm2 ]]; then
        echo "PM2 is not installed, please install it"
        echo "If pm2 is not installed, please install it with:"
        echo "npm install pm2 -g"
        exit 1
    fi
}

# Check if netstat is installed
function netstat_check() {
    if [[ ! -f /usr/bin/netstat ]]; then
        echo "netstat is not installed, please install it"
        echo "If netstat is not installed, please install it with:"
        echo "sudo apt install net-tools"
        exit 1
    fi
}

# Check if port is available
function port_check() {
    if [ $(netstat -tulpn | grep $PORT | wc -l) -gt 0 ]; then
        return 1
    fi
}


# Generate Nginx server block for reverse proxy to node app
function nginx_server_block() {

    echo 'server {' >> /etc/nginx/sites-available/$DOMAIN
    echo '    listen 80;' >> /etc/nginx/sites-available/$DOMAIN
    echo '    listen [::]:80;' >> /etc/nginx/sites-available/$DOMAIN
    echo "    server_name $DOMAIN www.$DOMAIN;" >> /etc/nginx/sites-available/$DOMAIN
    echo "    root /var/www/$DOMAIN/html;" >> /etc/nginx/sites-available/$DOMAIN
    echo '    index index.html index.htm index.nginx-debian.html;' >> /etc/nginx/sites-available/$DOMAIN
    echo '    location / {' >> /etc/nginx/sites-available/$DOMAIN
    echo "        proxy_pass http://localhost:$PORT;" >> /etc/nginx/sites-available/$DOMAIN
    echo '        proxy_http_version 1.1;' >> /etc/nginx/sites-available/$DOMAIN
    echo '        proxy_set_header Upgrade $http_upgrade;' >> /etc/nginx/sites-available/$DOMAIN
    echo '        proxy_set_header Connection 'upgrade';' >> /etc/nginx/sites-available/$DOMAIN
    echo '        proxy_set_header Host $host;' >> /etc/nginx/sites-available/$DOMAIN
    echo '        proxy_cache_bypass $http_upgrade;' >> /etc/nginx/sites-available/$DOMAIN
    echo '    }' >> /etc/nginx/sites-available/$DOMAIN
    echo '}' >> /etc/nginx/sites-available/$DOMAIN

}

# Enable Nginx server block
function enable_server_block() {
    ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
}

# Disable Nginx server block
function disable_server_block() {
    rm /etc/nginx/sites-enabled/$DOMAIN
}

# Clone repository
function clone_repo() {
    git clone $REPO /var/www/$DOMAIN
}

# Install dependencies
function install_deps() {
    cd /var/www/$DOMAIN
    npm install
}

# Start Node application with pm2 with specific name and port
function start_node() {
    pm2 start /var/www/$DOMAIN/app.js --name $DOMAIN -- --port $PORT
}

# Get domain from user input
function get_domain() {
    read -p "Enter domain: " DOMAIN

    # Check if domain was entered
    while [ -z $DOMAIN ]; do
        echo "Please enter a domain"
        get_domain
    done

    domain_check
    if [[ $? -eq 0 ]] ; then
        echo "Domain is already in use, choose another one"
        get_domain
    fi
}

# Check if domain already exists in Nginx config
function domain_check() {
    if grep -q $DOMAIN /etc/nginx/sites-available/* ; then
        echo "Domain $DOMAIN already exists in Nginx config"
        return 0
    else
        return 1
    fi

    if [[ -d /var/www/$DOMAIN ]]; then
        echo "Domain $DOMAIN already exists in /var/www"
        return 0
    else
        return 1
    fi
}

# Get git repo from user input
function get_repo() {
    read -p "Enter git repo: " REPO
    # Check if repo was entered
    while [ -z $REPO ]; do
        echo "Please enter a git repo"
        get_repo
    done
}

# Get port from user input
function get_port() {
    read -p "Enter port: " PORT
    # Check if port was entered
    while [ -z $PORT ]; do
        echo "Please enter a port"
        get_port
    done

    # Check if port is available
    port_check
    if [[ $? -eq 1 ]] ; then
        echo "Port $PORT is already in use"
        unset PORT
        get_port
    fi
}

# Main function to call all other functions
function main() {
    # Check if Nginx is installed and running
    nginx_check
    # Check if Node is installed
    node_check
    # Check if npm is installed
    npm_check
    # Check if pm2 is installed
    pm2_check
    # Get domain from user input
    get_domain
    # Get git repo from user input
    get_repo
    # Get port from user input
    get_port
    # Clone repository
    clone_repo
    # Install dependencies
    install_deps
    # Start Node application with pm2 with specific name and port
    start_node
    # Create and enable Nginx server block
    nginx_server_block
    enable_server_block
    # Test config
    nginx -t
    # Restart Nginx if config test is successful
    if [[ $? -eq 0 ]]; then
        systemctl restart nginx
    else
        echo "Nginx config test failed"
    fi
}
main