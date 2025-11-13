# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Update the package lists and install OpenSSH server, auditd, and rsyslog
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        python3 \
        sudo \
        bash \
        build-essential \
        nmap \
        && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

ARG SESSION_ID

# Expose the SSH port
EXPOSE 2222

# Start services
 
RUN mkdir -p /app/lobby/

RUN echo "$SESSION_ID" > /app/session-id

COPY . /app/lobby/
COPY deploy/config/ssh-key-ctf.pub /app/lobby/

#COPY analyze /bin/
RUN chmod 700 /app/lobby/start.sh
ENTRYPOINT ["/app/lobby/start.sh"]





