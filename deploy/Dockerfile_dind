# Use the Docker-in-Docker (DinD) image.
FROM docker:dind

# Set the working directory
WORKDIR /app

# INSTALL PACKAGES
RUN apk add --no-cache bash \
        python3 py3-pip \
#        openssh \
        util-linux \ 
        coreutils \
        nmap

# COPY FILES
COPY ./dind ./dind
COPY ./ssh ./ssh
COPY ./lobby ./lobby
COPY ./config ./config

ARG SSH_USER='nobody1'
ARG SSH_PASS='password'


# %%
# LOGS
# %%

RUN mkdir /logs

# %%
# START
# %%

RUN chmod +x /app/dind/start.sh
RUN chmod 600 /app/config/log_key

# Expose SSH Port
EXPOSE 2222

# Run the build and run script, and then the log analyzer in the background
CMD ["/app/dind/start.sh"]

