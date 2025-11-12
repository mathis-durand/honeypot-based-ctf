#!/usr/bin/env python3

import re
import os
import datetime
import subprocess
import time

# Define patterns that indicate suspicious commands (expand this list!)
suspicious_patterns = [
    r".*\?.*",          # Bypass
    r".*base64.*",          # Bypass
    r".*rev.*",          # Bypass
    r".*\\x.*",          # Bypass
    r".*rm.*",          # Recursive and force delete (dangerous!)
    r".*wget.*",            # Downloading files from the web
    r".*curl.*",            # Similar to wget
    r".*nc.*",           # Netcat listen (potential backdoors)
    r".*chmod.*",       # Making files executable
    r".*eval.*",           # Dangerous execution of code
    r".*python.*",      # Running Python one-liners (can be malicious)
    r".*bash.*",        # Interactive bash shell (potential access)
    r".*/etc/shadow.*", # Viewing password hash file
    #r".*find .* -perm.*",    # Finding files with specific permissions
    #r"ps aux",          # Examining running processes
    r".*/dev/null*", # Redirection to hide output (can be used maliciously)
    r".*install.*",  # Installing packages (potentially malicious)
    r".*apt.*",  # Modern apt install command.
    r".*dpkg.*",         # Installing .deb packages (can install malware)
    r".*addgroup.*",      # Adding a group. Usually harmless, but can be part of an attack.
    r".*adduser.*",       # Adding a user. Similar to addgroup.
    r".*crontab.*",    # Editing crontab (persistent backdoor)
    r".*service.*", # Restarting services
    r".*systemctl.*", # Systemd control (start, stop, restart).  Can be abused.
    r".*passwd.*",        # Changing passwords (could indicate account compromise)
    #r"ssh.*(root|user@)",  # Attempts to SSH to root or a user@host.  Important to check.
    r".*sudo su.*",         # Using sudo to get root shell
    r".*bashrc.*",  # Modifying .bashrc
    r".*zshrc.*",  # Modifying .zshrc
    r".*ifconfig.*",      # (deprecated but still used) - network configuration. Check for malicious configuration changes.
    r".*ip.*",       # Modern replacement for ifconfig.
    #r".*iptables.*",       # Firewall manipulation
    r".*ufw.*",           # Uncomplicated Firewall control (Ubuntu default).
    r".*netstat.*",         # Network connections.  Check for suspicious connections.
    r".*tcpdump.*",        # Packet capture (could be used for sniffing)
    r".*wget.*", # Spidering, potentially malicious
    r".*screen.*",         # Screen session (can be used to hide activity)
    r".*tmux.*",           # Tmux session (similar to screen)
    r".*history.*",    # Clear shell history (attempting to hide activity)
    r".*killall.*",       # Kill all process of some name (can be used maliciously)
    r".*kill.*",          # Forcefully kill processes (can disrupt services)
    r".*\.pyc.*",         # Attempt to run compiled python files.
    r".*perl.*",        # Running Perl one-liners (can be malicious)
    r".*ruby.*",        # Running Ruby one-liners (can be malicious)
    r".*sed.*",        # In-place text substitution (can be used to inject code)
    r".*awk.*",            # Powerful text processing tool, can be misused.
    r".*tail.*",        # Following a log file, can be used to monitor.
    #r".*whoami",         # Typically harmless, but useful to check.
    #r".*id.*",           # Similar to whoami. Useful to check.
    r".*uname.*",       # Get system information, can be a recon step.
    r".*mount.*",          # Check for malicious mount operations.
    r".*umount.*",         # Unmount (can be used to disrupt services)
    r".*tar.*-cf.*",        # Creating tar archives (can be used to exfiltrate data)
    r".*zip.*",            # Compressing files, could be used to exfiltrate data.
    r".*unzip.*",          # Unzipping archives.
    #r".*find .* -name \.ssh.*", # Find .ssh directories
    r".*ssh-keygen.*",      # SSH key generation (often a precursor to exploitation)
    r".*ssh-copy-id.*",     # Copying SSH keys to a server
    #r".*cat /root/.ssh/authorized_keys.*", # Viewing authorized keys.
]

NB_CONTAINERS = 9

def load(path):
    f = open(path,"r")
    res = str(f.readline()[:-1])
    f.close()
    return res

GEN = load("/app/dind/.gen")
DID = load("/app/dind/.container_id")
LOG_USER = load("/app/config/log_user")
LOG_SERVER = load("/app/config/log_server")
REMOTE_LOG_PATH = load("/app/config/remote_log_path")


def init_log(container:int):
    if os.path.exists("/logs/"+str(container)+"/command_history.log"):
        os.system("rm /logs/"+str(container)+"/command_history.log")
    os.system("touch /logs/"+str(container)+"/command_history.log")
    os.system("chmod 666 /logs/"+str(container)+"/command_history.log")

def backup(container:int):
    if not os.path.exists("/logs_bck/"+str(container)+"/"):
        os.system("mkdir -p /logs_bck/"+str(container))
    os.system("cp /logs/"+str(container)+"/command_history.log /app/dind/logs/history_ssh"+str(container)+".log")


def reset_logs():
    if os.path.exists("/logs/-1/.ash_history"):
            os.system("rm /logs/-1/.ash_history")
    os.system("touch /logs/-1/.ash_history")
    os.system("chmod 666 /logs/-1/.ash_history")
    for container in range(-1,NB_CONTAINERS):
            if os.path.exists("/app/dind/logs/history_ssh"+str(container)+".log"):
                 os.system("rm /app/dind/logs/history_ssh"+str(container)+".log")
    
    

def send_logs():
    try:  
        GEN = load("/app/dind/.gen")
        log_name = "log_" + DID + "_" + GEN + ".log"
        scp_command = [
            "scp",
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "-i", "/app/config/log_key",
            "/app/dind/logs/agg_logs_" + GEN + ".csv",
            LOG_USER + "@" + LOG_SERVER + ":" + REMOTE_LOG_PATH + log_name
        ]
        process = subprocess.Popen(scp_command,
                                   stdout=subprocess.DEVNULL,  # Discard standard output
                                   stderr=subprocess.DEVNULL)  # Discard standard error
        
        GEN = load("/app/dind/.gen")
        ip_file_name = "gen_" + DID + "_" + GEN + ".ip"
        scp_command = [
            "scp",
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "-i", "/app/config/log_key",
            "/app/dind/logs/gen-" + str(int(GEN)-1) + ".txt",
            LOG_USER + "@" + LOG_SERVER + ":" + REMOTE_LOG_PATH + ip_file_name
        ]
        process = subprocess.Popen(scp_command,
                                   stdout=subprocess.DEVNULL,  # Discard standard output
                                   stderr=subprocess.DEVNULL)  # Discard standard error
    except Exception as e:
        print(str(e))

def clear_logs():
    for container in range(-1,NB_CONTAINERS):
        os.system("touch /app/dind/logs/history_ssh"+str(container)+".log")
        os.system("rm /app/dind/logs/history_ssh"+str(container)+".log")

def alarm(msg='An Intruder has been detected! Reconfiguring the network...'):
    os.system("echo '" + msg +"' > /msg/alert")
    time.sleep(2)
    remaining_attempts = load("/app/dind/.remaining_attempts")
    print(remaining_attempts)
    f = open("/app/dind/.remaining_attempts","w")
    f.write(str(remaining_attempts))
    f.close()
    os.system("ps -ef | grep \"10.0.0.\" | grep -v grep | awk '{print $1}' | xargs kill")
    print("Alarm!")
    os.system("python /app/dind/stop-services.py")
    send_logs()
    clear_logs()
    remaining_attempts = int(load("/app/dind/.remaining_attempts"))
    if remaining_attempts > -1:
        os.system("python /app/dind/start-lobby.py")
        os.system("python /app/dind/start-services.py")

def aggregate_logs():
    GEN = load("/app/dind/.gen")
    agg_log_file = open("/app/dind/logs/agg_logs_" + GEN + ".csv", "w")
    agg_log_file.write("docker_id;generation;full_time;service;command\n")
    for container in range(-1,NB_CONTAINERS):
        if os.path.exists("/app/dind/logs/history_ssh"+str(container)+".log"):
            log_file = open("/app/dind/logs/history_ssh"+str(container)+".log", "r")
            logs = log_file.readlines()
            for log in logs:
                log = log[7:]
                log.replace("\n","\\n")
                #time = re.finditer("\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", log)[0].group()
                time = log.split(" ")[0] + " " + log.split(" ")[1]
                command = ""
                for arg in log.split(" ")[2:]:
                    command += arg + " "
                command= command[:-1]
                agg_log_file.write(str(DID) + ";" + str(GEN) + ";" + time + ";" + str(container) + ";" + command)
            log_file.close()        
    agg_log_file.close()
    send_logs()
    

def analyze_logs(container:int):
    aggregate_logs()
    log_file = open("/app/dind/logs/history_ssh"+str(container)+".log", "r")
    logs = log_file.readlines()
    log_file.close()
    if len(logs) > 5:
        logs = logs[-5:]
    for log in logs:
        print("Analyzing: " + log)
        log = log.replace(" ","")
        log = log.replace("'","")
        log = log.replace("\"","")
        log = log.replace("*","")
        log = log.replace("`","")
        for pattern in suspicious_patterns:
            if re.search(pattern, log, re.IGNORECASE):
                print(f"ALARM: Suspicious command detected in "+str(container)+": "+log)
                alarm()
                return 1
        if re.search(r"myshell", log, re.IGNORECASE) and container != 0:
            print(f"ALARM: Suspicious command detected in "+str(container)+": "+log)
            alarm()
            return 1
    return 0
               
def check_logs():
    for container in range(-1,NB_CONTAINERS):
        history_size = os.path.getsize("/logs/"+str(container)+"/command_history.log")
        if history_size != 0:
            backup(container)
            print("Log found")
            analyze_logs(container)
            init_log(container)
            
        
def main():
    #f = open("/app/dind/.last_dind_log", "w")
    #f.write("-1\n")
    #f.close()
    # Keep the script running
    for container in range(-1,NB_CONTAINERS):
        init_log(container)
    #os.system("touch /logs/-1/.ash_history")
    while True:
        GEN = load("/app/dind/.gen")
        #save_dind_log()
        check_logs()

if __name__ == "__main__":
    main()



























