# Container image that runs your code
FROM ubuntu:20.04

RUN apt-get update
RUN yes | apt-get install zip curl wget unzip zip
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl -s "https://get.sdkman.io" | bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT [ "./entrypoint.sh" ]