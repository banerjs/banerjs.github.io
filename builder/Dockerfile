# Create a docker image that we can use to build LaTeX and perform other compile
# steps. Although we could do things in travis, it's probably better to do them
# with docker so that there aren't any transient changes that affect the build

FROM ubuntu:bionic

# Set Maintainer
MAINTAINER Siddhartha Banerjee, banerjs@banerjs.com

# Install wget, texlive, and rvm
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        apt-transport-https \
        gnupg \
        lsb-release \
        software-properties-common \
        sudo \
        tzdata \
        wget && \
    apt-add-repository -y ppa:rael-gc/rvm && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        rvm \
        texlive-full

# Set the env variables, workdir, etc.
ENV INSTALL_DIR="/usr/src"

WORKDIR ${INSTALL_DIR}
CMD ["bash"]
