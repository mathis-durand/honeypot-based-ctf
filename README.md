# Challenge description

This challenge collects logs. See Privacy Policy.

You’ve gained access to a restricted network via a backdoored SSH service. 
Your task is to navigate this environment and identify the real target: a vulnerable SSH server ripe for exploitation. However, Honeypots are scattered throughout, designed to mislead and trap you. 

Carefully explore the network, analyzing the SSH services you find. 
Distinguish between legitimate targets and deceptive traps. 
Once you’ve identified the correct server, exploit its weaknesses, gain access, and escalate your privileges to root. 
Good luck, and be cautious!

The challenge may take a few minutes to setup.


# Challenge host guide

This challenge has been made for CTFd.

Build the challenge:
```sh
sudo docker build -t dind_custom deploy/
```
Run the Docker container on the port `PORT`:
```sh
sudo docker run --name challenge --privileged -p PORT:2222 dind_custom
```
Connect as root to the challenge (debug)
```sh
sudo docker exec -it challenge /bin/bash
```

# Player guide

Use `ssh` to connect to the Docker container port.

nobody1 : password -- player connection
