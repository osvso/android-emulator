#!/bin/bash

# Port-forwarding
ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &

# Kill ADB server as ADB connection will be establishe from outside the docker image
adb kill-server

if [[ $ARCH == *"armeabi-v7a"* ]]
then
    ARCH="arm"
fi

echo "no" | /usr/local/android-sdk/tools/emulator64-${ARCH} -avd ${DEVICE_NAME} -noaudio -no-window -gpu off -verbose -qemu -vnc :0