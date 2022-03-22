# Host multiple Node applications on a single machine

This is a script to help you automate the deployment of multiple Node.js applications on a single machine.

## Prerequisites

- [DigitalOcean account](https://m.do.co/c/2a9bba940f39)
- [Ubuntu Server](https://docs.digitalocean.com/products/droplets/how-to/create/)
- [Nginx](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04)
- [Node.js](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04)
- `netstat`: `sudo apt install net-tools`

To install all of the above, run the following commands:

```bash
sudo apt update

curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh

sudo bash /tmp/nodesource_setup.sh

sudo apt update

sudo apt-get install gcc g++ make

sudo apt install nginx net-tools nodejs git -y

npm install -g pm2
```

## Setup

All that you need to do is to download the latest version of `setup.sh` script and run it:

```bash
wget https://raw.githubusercontent.com/bobbyiliev/host-node/main/setup.sh
```

## Usage

To create a new Node application, run the following command:

```bash
bash setup.sh
```

You will be prompted to enter the following information:

- Domain name: Make sure to omit the `www.` and `http[s]://`.
- GitHub repository: Make sure to use the full repository name, e.g. `https://github.com/bobbyiliev/nodejs-example.git`
- Port: The port on which the application will be running on. **Each application must have a unique port**!

## Rundown of the script

The script includes the following steps:
- Check if Nginx is installed and running
- Check if Node is installed
- Check if `npm` is installed
- Check if `pm2` is installed
- Get domain from user input
- Get git repo from user input
- Get port from user input
- Clone repository
- Install dependencies
- Start Node application with `pm2` with specific name and port
- Create and enable Nginx server block
- Test the Nginx config
- Restart Nginx if config test is successful
