#!/bin/sh
set -e


sessionID=$(cat /app/session-id)
touch /etc/motd
cat /app/lobby/motd >> /etc/motd
sed -i "s/%session-id%/${sessionID}/g" /app/lobby/warning
echo "Banner /app/lobby/warning" >> /etc/ssh/sshd_config 


# CREATE USERS

addgroup backdoor
echo "Add backdoor" 
useradd -m -s /bin/bash -g backdoor nobody1
echo "nobody1:password" | chpasswd  


# LOG SYSTEM

echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /home/nobody1/.bashrc
echo 'history > /logs/command_history.log 2>/dev/null' >> /home/nobody1/.bashrc
echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /home/nobody1/.bashrc


# SERVICES

# SSH Configuration
mkdir /run/sshd
# Create required folder and start ssh server.
mkdir -p /home/nobody1/.ssh

echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

ssh-keygen -A

# Start SSH service
/usr/sbin/sshd -D &



# Keep the container running
tail -f /dev/null

