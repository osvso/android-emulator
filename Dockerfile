FROM ubuntu:16.04

# Android Emulator properties
ENV ANDROID_PLATFORM_VERSION 23
ENV DEVICE_NAME=Android-Emulator-${ANDROID_PLATFORM_VERSION}
ENV ARCH=x86

RUN \
  echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Install Java
RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Android SDK
RUN \
  wget -qO- http://dl.google.com/android/android-sdk_r${ANDROID_PLATFORM_VERSION}-linux.tgz | \
    tar xvz -C /usr/local/ && \
  mv /usr/local/android-sdk-linux /usr/local/android-sdk && \
  chown -R root:root /usr/local/android-sdk/
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Install Android Tools and system images
RUN \
  ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
    platform-tool,android-${ANDROID_PLATFORM_VERSION},build-tools-${ANDROID_PLATFORM_VERSION},sys-img-x86-google_apis-${ANDROID_PLATFORM_VERSION}

# Create fake keymap file
RUN \
  mkdir /usr/local/android-sdk/tools/keymaps && \
  touch /usr/local/android-sdk/tools/keymaps/en-us

# Miscellaneous packages - required to run AVD on 64bit machine
RUN \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y \
      libz1:i386 \
      libncurses5:i386 \
      libbz2-1.0:i386 \
      libstdc++6:i386 \
      socat \
      net-tools

# Create Android Emulator
RUN \
  echo "no" | /usr/local/android-sdk/tools/android create avd -n ${DEVICE_NAME} -t android-${ANDROID_PLATFORM_VERSION} -c 374M -s WXGA720 --abi google_apis/${ARCH} -f

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh