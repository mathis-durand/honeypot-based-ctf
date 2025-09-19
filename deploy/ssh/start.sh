#!/bin/bash
set -e

SSH_TYPE=$(cat /app/ssh_type)
FLAG=$(cat /app/flag)
PASS=$(cat /app/pass)

echo $SSH_TYPE

# 0 Real SSH
# 1 Easy Pot : accept all connection
# 2 New Pot : no old file
# 3 Empty Pot : no data / user
# 4 Empty Pot 2 : no script
# 5 Misconfigured Pot : cowrie user and port
# 6 Misconfigured Pot 2 : cowrie banner
# 7 Lazy Pot : wrong command error
# 8 Glutton Pot : all ports
# / Busy Pot : 2s latency



## ----------- ##
# CREATE GROUPS #
## ----------- ##

# 3 Empty Pot : no data / user
if [ $SSH_TYPE -ne 3 ]; then
  addgroup hacker
fi
addgroup admin
addgroup temp
# 5 Misconfigured Pot : cowrie user and port
if [ $SSH_TYPE -eq 5 ]; then
  addgroup cowrie
fi



## ---------- ##
# CREATE USERS #
## ---------- ##

# 1 Easy Pot : accept all connection
if [ $SSH_TYPE -eq 1 ]; then
  echo "Add Common Users"
  useradd -m -s /bin/bash -g temp user
  echo "user:password" | chpasswd  
else
	echo "No Common Users"
fi

# 3 Empty Pot : no data / user
if [ $SSH_TYPE -ne 3 ]; then
  echo "Add Real Users" 
  useradd -m -s /bin/bash -g hacker ghost
  echo "ghost:${PASS}" | chpasswd  
  useradd -m -s /bin/bash -g admin zephyr-adm
  echo "zephyr-adm:${PASS}" | chpasswd  
  useradd -m -s /bin/bash -g hacker zephyr
  echo "zephyr:${PASS}" | chpasswd 
  useradd -m -s /bin/bash -g hacker skywalker
  echo "skywalker:${PASS}" | chpasswd 
else
	echo "No Real Users"
fi

useradd -m -s /bin/bash -g temp ot-user
echo "ot-user:p@ssword" | chpasswd  
useradd -m -s /bin/bash -g admin ot-admin
echo "ot-admin:${PASS}" | chpasswd

# 5 Misconfigured Pot : cowrie user and port
if [ $SSH_TYPE -eq 5 ]; then
  echo "Add Honeypot Users"
  useradd -m -s /bin/bash -g cowrie cowrie
  echo "cowrie:password" | chpasswd  
else
	echo "No Honeypot Users"
fi



## ------------ ##
# CREATE PROCESS #
## ------------ ##

# 4 Empty Pot 2 : no script
if [ $SSH_TYPE -ne 4 ]; then
  echo "Add Real Scripts"
  echo "while True:" > /app/update.py
  echo "    pass" >> /app/update.py
  python3 /app/update.py &
  chmod 700 /app/update.py
else
  echo "No Real Scripts"
fi



## --------- ##
# CREATE DATA #
## --------- ##

# 3 Empty Pot : no data / user
if [ $SSH_TYPE -ne 3 ]; then
  echo "Add Real Data"
  echo "N.B.: Zephyr told me that ot-user should be deleted... Skywalker." > /home/ot-user/README
else
  echo "No Real Data"
fi

# 2 New Pot : no old file
if [ $SSH_TYPE -ne 2 ]; then
  python3 /app/ssh/update-date.py
fi  



## ---- ##
# BANNER #
## ---- ##

# 6 Misconfigured Pot 2 : cowrie banner
if [ $SSH_TYPE -ne 6 ]; then
  cat /app/ssh/banners/ssh > /etc/motd
else
  echo "Debian GNU/Linux 7 \n \l" > /etc/motd
fi



## -- ##
# FLAG #
## -- ##

# 0 Real SSH
if [ $SSH_TYPE -eq 0 ]; then
  echo "Add Flag"
  echo "${FLAG}" > /home/ot-admin/flag.txt
  chmod 600 /home/ot-admin/flag.txt
fi



## --- ##
# VULN. #
## --- ##

mkdir -p /bin/rootshell
echo '#include<stdio.h>' > /bin/rootshell/asroot.c
echo '#include<unistd.h>' >> /bin/rootshell/asroot.c
echo '#include<sys/types.h>' >> /bin/rootshell/asroot.c
echo 'int main(){setuid(geteuid());system("/bin/bash");return 0;}' >> /bin/rootshell/asroot.c
cd /bin/rootshell && gcc asroot.c -o myShell
chmod u+s /bin/rootshell/myShell 
chown -R ot-admin:admin /home/ot-admin



## -------- ##
# LOG SYSTEM #
## -------- ##

echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /home/ot-user/.bashrc
echo 'history > /logs/command_history.log 2>/dev/null' >> /home/ot-user/.bashrc
#if [ $SSH_TYPE -eq 6 ]; then
#  echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; sleep 2; $PROMPT_COMMAND"' >> /home/ot-user/.bashrc
#else
echo 'PROMPT_COMMAND="history > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /home/ot-user/.bashrc
#fi


#echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> /root/.bashrc
#echo 'history -a > /logs/command_history.log 2>/dev/null' >> /root/.bashrc
#echo 'PROMPT_COMMAND="history -a > /logs/command_history.log 2>/dev/null; $PROMPT_COMMAND"' >> /root/.bashrc



## --------- ##
# SSHD.CONFIG #
## --------- ##

# SSH Configuration
mkdir /run/sshd
# Create required folder and start ssh server.
mkdir -p /home/ot-user/.ssh

echo 'PermitRootLogin no' >> /etc/ssh/sshd_config # Not root login.
# Permit password login
sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config


sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# 1 Easy Pot : accept all connection
if [ $SSH_TYPE -eq 1 ]; then
  sed -i "s/^#MaxAuthTries 6.*/MaxAuthTries 10/g" /etc/ssh/sshd_config
fi

# 8 Glutton Pot : all ports
if [ $SSH_TYPE -eq 8 ]; then
  echo 'Port 2222' >> /etc/ssh/sshd_config
  echo 'Port 22' >> /etc/ssh/sshd_config
  echo 'Port 80' >> /etc/ssh/sshd_config
  echo 'Port 443' >> /etc/ssh/sshd_config
# 5 Misconfigured Pot : cowrie user and port
elif [ $SSH_TYPE -eq 5 ]; then
  echo 'Port 2222' >> /etc/ssh/sshd_config
  echo 'Port 2223' >> /etc/ssh/sshd_config
else
  sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config
fi

# cleaning ssh
chmod -x /etc/update-motd.d/*

# Start SSH service
/usr/sbin/sshd -D &



## --- ##
# MISC. #
## --- ##

rm /app/flag
rm /app/pass
rm /app/ssh_type

# 7 Lazy Pot : wrong command error
if [ $SSH_TYPE -eq 7 ]; then
  echo 'command_not_found_handle() {' >> /home/ot-user/.bashrc
  echo '    if [[ -z "$1" ]]; then' >> /home/ot-user/.bashrc
  echo '        echo "Error: No command specified." >&2' >> /home/ot-user/.bashrc
  echo '    else' >> /home/ot-user/.bashrc
  echo '        echo "Permission denied." >&2' >> /home/ot-user/.bashrc
  echo '    fi' >> /home/ot-user/.bashrc
  echo '    return 127' >> /home/ot-user/.bashrc
  echo '}' >> /home/ot-user/.bashrc
fi

# Keep the container running
tail -f /dev/null

