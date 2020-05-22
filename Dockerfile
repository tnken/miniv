FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y git gcc wget make

# TODO: Fix V version
RUN mkdir -p ~/code && \
    cd ~/code && \
    git clone https://github.com/vlang/v && \
    cd v && \
    make && \
    ~/code/v/v symlink

ENTRYPOINT ["/bin/bash"]
