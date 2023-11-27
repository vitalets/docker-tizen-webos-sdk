FROM ubuntu:22.04

# Install prerequisites
RUN apt-get update && apt-get install -y \
  ca-certificates \
  wget \
  zip \
  unzip \
  pciutils \
  locales \
  libssl-dev \
  # helper packages
  curl \
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
RUN useradd --create-home ${USER}
ENV HOME /home/${USER}

USER ${USER}
WORKDIR ${HOME}

# Install tizen studio
# See: https://developer.tizen.org/development/tizen-studio/download/installing-tizen-studio#cli_installer
# Tizen Studio can't be installed under root, so we use developer.
# Tizen Studio must be installed in user home dir.
# See: https://stackoverflow.com/questions/47269478/error-installing-tizen-studio-on-windows-10
# See also: https://forum.developer.samsung.com/t/double-click-on-installer-tizen-studio-4-1-doesnt-launch-the-app-on-big-sure-11-3-1/13352/8
ARG TIZEN_STUDIO_VERSION=5.5
ARG TIZEN_STUDIO_FILE=web-cli_Tizen_Studio_${TIZEN_STUDIO_VERSION}_ubuntu-64.bin
ARG TIZEN_STUDIO_URL=http://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_STUDIO_VERSION}/${TIZEN_STUDIO_FILE}
RUN wget ${TIZEN_STUDIO_URL} \
  && chmod +x ${TIZEN_STUDIO_FILE} \
  && echo y | ./${TIZEN_STUDIO_FILE} --accept-license \
  && rm ${TIZEN_STUDIO_FILE}

# Copy sample author certificate and profiles.xml
COPY --chown=${USER} tizen-profile/author.p12 author.p12
COPY --chown=${USER} tizen-profile/profiles.xml ${HOME}/tizen-studio-data/profile/profiles.xml

# Container is intentionally started under the root user.
# Starting under non-root user will cause permissions issue when attaching volumes
# See: https://github.com/moby/moby/issues/2259
USER root

# Move Tizen studio from home because we mount home to host volume, and create symlink to keep everything working.
RUN mv ${HOME}/tizen-studio /tizen-studio \
  && ln -s /tizen-studio ${HOME}/tizen-studio

# Copy and extract webOS CLI
ARG WEBOS_SDK_PATH=/webOS_TV_SDK
COPY vendor/webos_cli_tv.zip .
RUN unzip -q webos_cli_tv.zip -d ${WEBOS_SDK_PATH} \
  && chmod -R +x ${WEBOS_SDK_PATH}/CLI/bin \
  && rm webos_cli_tv.zip

# Add tizen/webos cli to PATH
ENV PATH $PATH:/tizen-studio/tools/:/tizen-studio/tools/ide/bin/:/tizen-studio/package-manager/:${WEBOS_SDK_PATH}/CLI/bin
