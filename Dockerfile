#ARG PYTHON_VERSION="3.8"

#FROM python:$PYTHON_VERSION AS dependencies
FROM vsc-anki-sync-server-75d12691effaa4b860b34870e27e26b5:latest AS dependencies


# Allow non-root users to install things and modify installations in /opt.
RUN chmod 777 /opt && chmod a+s /opt

# Install rust.
ENV CARGO_HOME="/opt/cargo" \
    RUSTUP_HOME="/opt/rustup"
ENV PATH="$CARGO_HOME/bin:$PATH"
RUN mkdir $CARGO_HOME $RUSTUP_HOME \
    && chmod a+rws $CARGO_HOME $RUSTUP_HOME \
    && curl -fsSL --proto '=https' --tlsv1.2 https://sh.rustup.rs \
    | sh -s -- -y --quiet --no-modify-path \
    && rustup default nightly \
    && rustup update \
    && cargo install ripgrep

# Install system dependencies.
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        gettext \
        lame \
        libnss3 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxkbcommon-x11-0 \
        libxcomposite1 \
        mpv \
        portaudio19-dev \
        rsync \
    && rm -rf /var/lib/apt/lists/*

# Install node and npm.,shoud install by first image
WORKDIR /opt/node
ENV HTTPS_PROXY=http://192.168.1.227:1088
RUN curl -fsSL --proto '=https' https://nodejs.org/dist/v12.18.3/node-v12.18.3-linux-x64.tar.xz \
    | tar xJ --strip-components 1
ENV PATH="/opt/node/bin:$PATH"

# Install protoc.
WORKDIR /opt/protoc
ENV HTTPS_PROXY=http://192.168.1.227:1088
RUN curl -fsSL --proto '=https' -O https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protoc-3.13.0-linux-x86_64.zip \
    && unzip protoc-3.13.0-linux-x86_64.zip -x readme.txt \
    && rm protoc-3.13.0-linux-x86_64.zip
ENV PATH="/opt/protoc/bin:$PATH"

# Allow non-root users to install toolchains and update rust crates.
RUN chmod 777 $RUSTUP_HOME/toolchains $RUSTUP_HOME/update-hashes $CARGO_HOME/registry \
    && chmod -R a+rw $CARGO_HOME/registry \
    # Necessary for TypeScript.
    && chmod a+w /home


#### build qt for debain  from github qt-build 
FROM dependencies as qtprep

LABEL maintainer="devel@jochenbauer.net"
LABEL stage=qt-build-base

# UID/GID injection on build if wanted
ARG USER_UID=
ARG USER_GID=

# In case you have to build behind a proxy
ARG PROXY=
ENV http_proxy=$PROXY
ENV https_proxy=$PROXY

# Name of the regular user. Does not look useful but can save a bit time when changing
ENV QT_USERNAME=qt

# Needed in both builder and qt stages, so has to be defined here
ENV QT_PREFIX=/usr/local/

# Install all build dependencies
RUN apt-get update && apt-get -y --no-install-recommends install \
	ca-certificates \
	# sudo to be able to modify the container as the user, if needed.
	sudo \
	curl \
	python \
	gperf \
	bison \
	flex \
	build-essential \
	pkg-config \
	libgl1-mesa-dev \
	libicu-dev \
	firebird-dev \
	libmariadb-dev \
	libpq-dev \
	# bc suggested for openssl tests
	bc \
	libssl-dev \
	# git is needed to build openssl in older versions
	git \
	# xcb dependencies
	libfontconfig1-dev \
	libfreetype6-dev \
	libx11-dev \
	libxext-dev \
	libxfixes-dev \
	libxi-dev \
	libxrender-dev \
	libxcb1-dev \
	libx11-xcb-dev \
	libxcb-glx0-dev \
	libxkbcommon-x11-dev \
	libxcb-shm0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-keysyms1-dev \
	libxcb-render-util0-dev \
	libxcb-xinerama0-dev \
	x11proto-record-dev \
	libxtst-dev \
	libatspi2.0-dev \
	libatk-bridge2.0-dev \
	# bash needed for argument substitution in entrypoint
	bash \
	# since 5.14.0 we apparently need libdbus-1-dev and libnss3-dev
	libnss3-dev \
	libdbus-1-dev \
	&& apt-get -qq clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& printf "#!/bin/sh\nls -lah" > /usr/local/bin/ll && chmod +x /usr/local/bin/ll

# Adding regular user
RUN if [ ${USER_GID} ]; then \
	addgroup -g ${USER_GID} ${QT_USERNAME}; \
	else \
	addgroup ${QT_USERNAME}; \
	fi \
	&& if [ ${USER_UID} ]; then \
	useradd -u ${USER_UID} -g ${QT_USERNAME} ${QT_USERNAME}; \
	else \
	useradd -g ${QT_USERNAME} ${QT_USERNAME}; \
	fi && mkdir /home/${QT_USERNAME}

## make sure the user is able to sudo if needed
#RUN adduser ${QT_USERNAME} sudo
#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# build stage
FROM qtprep as qtbuilder

LABEL stage=qt-build-builder

# QT Version
ARG QT_VERSION_MAJOR=5
ARG QT_VERSION_MINOR=15
ARG QT_VERSION_PATCH=1

ENV QT_BUILD_ROOT=/tmp/qt_build

# They switched the tarball naming scheme from 5.9 to 5.10. This ARG shall provide a possibility to reflect that
ARG QT_TARBALL_NAMING_SCHEME=everywhere
# Providing flag for archived or stable versions
ARG QT_DOWNLOAD_BRANCH=official_releases

ENV QT_BUILD_DIR=${QT_BUILD_ROOT}/qt-${QT_TARBALL_NAMING_SCHEME}-src-${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}/build

# Installing from here
WORKDIR ${QT_BUILD_ROOT}

# Download sources
ENV HTTPS_PROXY=http://192.168.1.227:1088
RUN curl -sSL https://download.qt.io/${QT_DOWNLOAD_BRANCH}/qt/${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}/${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}/single/qt-${QT_TARBALL_NAMING_SCHEME}-src-${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}.tar.xz | tar xJ

WORKDIR ${QT_BUILD_DIR}

# Possibility to make outputs less verbose when required for a ci build
ARG CI_BUILD=0
ENV CI_BUILD=${CI_BUILD}

# Speeding up make depending of your system
ARG CORE_COUNT=5
ENV CORE_COUNT=${CORE_COUNT}

# addtianl package 
RUN apt-get update && apt-get -y --no-install-recommends install libxcomposite-dev libxcursor-dev libxrandr-dev


# Configure, make, install
ADD buildconfig/configure-${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}.sh configure.sh
# before running the configuration, adding a directory to copy additional contents to the final image
RUN mkdir /opt/extra-dependencies && chmod +x ./configure.sh && ./configure.sh ${CORE_COUNT} ${CI_BUILD}

COPY buildconfig/build.sh build.sh
#RUN ./build.sh ${CI_BUILD} ${CORE_COUNT}
#RUN ls -lahR $(QT_BUILD_DIR)


## debug build no need install,only local build dir
## install it
###RUN make install




# # Build anki. Use a separate image so users can build an image with build-time
# # dependencies.
#FROM qtbuilder AS builder
#WORKDIR /workspaces/anki
#COPY . .
#ENV HTTPS_PROXY=http://192.168.1.227:8080
#ENV HTTP_PROXY=http://192.168.1.227:8080
#RUN rm -rf pyenv && make clean && make develop
# RUN make develop


#FROM builder AS pythonbuilder
#ENV HTTPS_PROXY=http://192.168.1.227:8080
#ENV HTTP_PROXY=http://192.168.1.227:8080

#RUN make build


## Build final image.
## FROM python:${PYTHON_VERSION}-slim
## debian and pythondebug
#FROM vsc-anki-sync-server-75d12691effaa4b860b34870e27e26b5:latest

## Install system dependencies.
#RUN apt-get update \
#    && apt-get install --yes --no-install-recommends \
#        gettext \
#        lame \
#        libnss3 \
#        libxcb-icccm4 \
#        libxcb-image0 \
#        libxcb-keysyms1 \
#        libxcb-randr0 \
#        libxcb-render-util0 \
#        libxcb-xinerama0 \
#        libxcb-xkb1 \
#        libxkbcommon-x11-0 \
#        libxcomposite1 \
#        mpv \
#        portaudio19-dev \
#        rsync \
#    && rm -rf /var/lib/apt/lists/*

## Install pre-compiled Anki.
#COPY --from=pythonbuilder /opt/anki/dist/ /opt/anki/
#ENV HTTPS_PROXY=http://192.168.1.227:1088
#RUN python -m pip install --no-cache-dir \
#        PyQtWebEngine \
#        /opt/anki/*.whl \
#    # Create an anki executable.
#    && printf "#!/usr/bin/env python\nimport aqt\naqt.run()\n" > /usr/local/bin/anki \
#    && chmod +x /usr/local/bin/anki \
#    # Create non-root user.
#    && useradd --create-home anki

#USER anki
#USER vscode


#ENTRYPOINT ["/usr/local/bin/anki"]

#LABEL maintainer="cecini <github/cecini>"
