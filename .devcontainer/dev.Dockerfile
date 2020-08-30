#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM python:3.8-buster

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ARG USERNAME=fm
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update && \
    apt-get -yqq install --no-install-recommends apt-utils dialog apt-transport-https locales 2>&1 && \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    apt-get -yqq install git procps lsb-release && \
    # Clean up
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN pip install -U pip && pip install pipenv && \
    # create new user
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # [Optional] Uncomment the next three lines to add sudo support
    # apt-get install -y sudo && \
    # echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    # chmod 0440 /etc/sudoers.d/$USERNAME && \
    # make working directory and change owner
    mkdir -p /workspaces/fm_server/ && \
    chown $USER_UID:$USER_GID /workspaces/fm_server/

# Change to the newly created user
USER $USER_UID:$USER_GID
COPY fm_server /workspaces/fm_server/fm_server
COPY Pipfile* package* setup.py /workspaces/fm_server/
WORKDIR /workspaces/fm_server

# Set up the dev environment
RUN pipenv install --dev

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

EXPOSE 5554

CMD ["/bin/bash"]