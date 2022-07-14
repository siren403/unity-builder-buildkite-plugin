# initially inspired from https://github.com/drecom/docker-ubuntu-ruby/blob/master/Dockerfile
ARG RUBY_PATH=/usr/local
ARG RUBY_VERSION=3.1.2
ARG GAME_CI_UNITY_EDITOR_IMAGE
ARG RUBY_BUILD_REPO=https://github.com/rbenv/ruby-build.git
# build ruby
FROM ubuntu:18.04 AS rubybuild

RUN apt-get update \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    wget \
    curl \
    git \
    build-essential \
    g++ \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ARG RUBY_PATH
ARG RUBY_VERSION
ARG RUBY_BUILD_REPO

RUN git clone $RUBY_BUILD_REPO $RUBY_PATH/plugins/ruby-build \
&&  $RUBY_PATH/plugins/ruby-build/install.sh
RUN ruby-build $RUBY_VERSION $RUBY_PATH

# inject ruby and additional dependencies in game-ci's unity editor image
FROM $GAME_CI_UNITY_EDITOR_IMAGE

ARG RUBY_PATH
ENV PATH $RUBY_PATH/bin:$PATH
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        gcc \
        make \
        libssl-dev \
        zlib1g-dev \
        libsqlite3-dev \
        g++
COPY --from=rubybuild $RUBY_PATH $RUBY_PATH

#ARG GAME_CI_UNITY_EDITOR_IMAGE
#ENV GAME_CI_UNITY_EDITOR_IMAGE $GAME_CI_UNITY_EDITOR_IMAGE

ARG PLATFORM
ENV PLATFORM $PLATFORM

ARG DOCKER_FASTLANE
RUN if [ "$DOCKER_FASTLANE" = true ]; then gem install fastlane; fi
#RUN if [ "$PLATFORM" = "android" ]; then \
        #echo export LC_ALL=en_US.UTF-8 >> /root/.bashrc; \
        #echo export LANG=en_US.UTF-8 >> /root/.bashrc; \
        #echo export FL_UNITY_PROJECT_PATH=/app >> /root/.bashrc; \
        #echo export FL_UNITY_PATH=unity-editor >> /root/.bashrc; \
        #fi

ARG UNITY_LICENSE
RUN echo "$UNITY_LICENSE" >> root/env-unity-license.ulf && \
        unity-editor -batchmode -manualLicenseFile root/env-unity-license.ulf -logfile; exit 0

WORKDIR /app
COPY ./runner.sh /usr/bin/runner.sh
ENTRYPOINT ["/usr/bin/runner.sh"]
CMD ["init"]
#ENTRYPOINT ["echo", "-quit", "-nographics", "-projectPath", "/app", "-executeMethod", "UActions.Bootstrap.Run", "-logfile", "-"]
#CMD ["-buildTarget", "android", "-job", "build-apk"]

