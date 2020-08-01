FROM ubuntu:18.04

# Install prerequisites
RUN apt-get update && apt-get install -y \
  ca-certificates \
  wget \
  zip \
  unzip \
  pciutils \
  locales \
  libssl1.0.0 \
  # helper packages
  curl \
  sudo \
  net-tools \
  nano \
  && rm -rf /var/lib/apt/lists/*

# Set the locale
# see: https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add a user
ARG USER=developer
ARG PASSWORD=developer
RUN useradd --create-home --shell /bin/bash ${USER} \
  && echo "${USER}:${PASSWORD}" | chpasswd
ENV HOME /home/${USER}

# Allow sudo without password
# See: https://stackoverflow.com/questions/8784761/adding-users-to-sudoers-through-shell-script/8784846
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER}
WORKDIR ${HOME}

# Remove sudo notice on login
# See: https://askubuntu.com/questions/22607/remove-note-about-sudo-that-appears-when-opening-the-terminal
RUN touch .sudo_as_admin_successful

# Install tizen studio
# See: https://developer.tizen.org/development/tizen-studio/download/installing-tizen-studio#cli_installer
# Install as 'developer' as Tizen Studio does not allow to install from root.
ARG TIZEN_STUDIO_VERSION=3.7
ARG TIZEN_STUDIO_FILE=web-cli_Tizen_Studio_${TIZEN_STUDIO_VERSION}_ubuntu-64.bin
ARG TIZEN_STUDIO_URL=http://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_STUDIO_VERSION}/${TIZEN_STUDIO_FILE}
RUN wget ${TIZEN_STUDIO_URL} \
  && chmod +x ${TIZEN_STUDIO_FILE} \
  && echo y | ./${TIZEN_STUDIO_FILE} --accept-license \
  && rm ${TIZEN_STUDIO_FILE}

# Copy author certificate and profiles.xml
COPY --chown=${USER} tizen-profile/author.p12 author.p12
COPY --chown=${USER} tizen-profile/profiles.xml ${HOME}/tizen-studio-data/profile/profiles.xml

# Copy and extract webOS CLI
COPY vendor/webos_cli_tv.zip .
RUN unzip -q webos_cli_tv.zip -d webOS_TV_SDK \
  && chmod -R +x webOS_TV_SDK/CLI/bin \
  && rm webos_cli_tv.zip

# Set path for webos data dir (.webos).
# Used '/' just to have shorter path in volume binds (-v webos:/.webos).
ENV APPDATA /

# Add tizen/webos cli to PATH
ENV PATH $PATH:$HOME/tizen-studio/tools/:$HOME/tizen-studio/tools/ide/bin/:$HOME/tizen-studio/package-manager/:$HOME/webOS_TV_SDK/CLI/bin

# Container is intentionally started under the root user.
# Starting under non-root user will cause permissions issue when attaching volumes
# See: https://github.com/moby/moby/issues/2259
USER root
