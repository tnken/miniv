FROM ubuntu:18.04

RUN apt update && \
    apt install -y git gcc wget make vim

# TODO: Fix V version
RUN mkdir -p ~/code && \
    cd ~/code && \
    git clone https://github.com/vlang/v && \
    cd v && \
    make && \
    ~/code/v/v symlink

ENTRYPOINT ["/bin/bash"]
