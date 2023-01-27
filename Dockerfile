# Container image that runs your code
FROM alpine:edge

ENV SDKMAN_DIR=/root/.sdkman
RUN apk --update add libc6-compat bash curl git zip unzip wget ca-certificates && \
    curl -s "https://get.sdkman.io" | bash && \
    echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config && \
    echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
# make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT  [ "/usr/bin/env", "bash", "-c", "/entrypoint.sh"]