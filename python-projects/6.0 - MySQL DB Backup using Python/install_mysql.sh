#!/bin/bash

exec > ./install_mysql.log 2>&1

if dpkg -l | grep -q mysql-server; then
    echo "exiting script... MySQL is already installed!"
    exit 1
else
    echo "MySQL is not yet installed... Installing..."
    sleep 3
    sudo apt update -y
    sudo apt install mysql-server -y
    echo "Successfully installed MySQL"
fi

sudo mysql_secure_installation

# Create users, add DBs, tables, and columns... Update DBs by inserting new data... Then execute mysql_db_backup.py