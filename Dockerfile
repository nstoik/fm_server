FROM python:3.9-buster

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ARG USERNAME=fm
ARG USER_UID=1000
ARG USER_GID=$USER_UID


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
    chown $USER_UID:$USER_GID /workspaces/fm_server/ && \
    # create directory for logs and change owner
    mkdir /logs/ && \
    chown $USER_UID:$USER_GID /logs/

# Change to the newly created user
USER $USER_UID:$USER_GID
COPY fm_server /workspaces/fm_server/fm_server
COPY Pipfile* package* setup.py /workspaces/fm_server/
WORKDIR /workspaces/fm_server

# Production deploy steps below
RUN pipenv install --deploy --ignore-pipfile
RUN pipenv run pip install -e .

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

CMD ["pipenv", "run", "fm_server", "run",]