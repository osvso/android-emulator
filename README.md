# Android-emulator

### Running the docker

Pull docker image running desired API level version from docker repository and start it up with docker-compose.

```sh
$ docker pull snapshot.onegini.com/library/android-emulator:23
$ docker-compose up -d
```

### Connecting with emulator

Docker-compose creates a port mapping between the image which runs the emulator and host so as soon as the image is started the emulator will be able to communicate with ADB running on the host.

Port mapping:

* 5554:5554/tcp - ADB
* 5555:5555/tcp - ADB connection port
* 5900:5900/tcp - QEMU VNC connection

```sh
$ adb kill-server
$ adb devices
List of devices attached
emulator-5554	device
```

Starting from this point the emulator running inside a docker container should be discoverable like any other device connected to the host.


### Accessing docker

In order to access the image by starting bash or executing any other command inside it the target containers ID is required:

```sh
$ docker ps
CONTAINER ID        IMAGE                                              COMMAND             CREATED              STATUS              PORTS                                                      NAMES
a9329a7340da        snapshot.onegini.com/library/android-emulator:23   "/entrypoint.sh"    About a minute ago   Up 6 seconds        0.0.0.0:5554-5555->5554-5555/tcp, 0.0.0.0:5900->5900/tcp   androidemulator_android-emulator_1
```

Afterwards a desired command can be executed:

```sh
$ docker exec -it a9329a7340da bash
```

### Building Android Emulator docker image

#### Environment variables

ANDROID_API_LEVEL - The Android SDK API Level (ex. `23`). By manipulating this value an image running different Android OS version can be created.
DEVICE_NAME - Android Virtual Device (AVD) name. Default value is `Android-Emulator-${ANDROID_API_LEVEL}`. Please note that using unescaped spaces is not allowed and will cause issues during emulator startup.
ARCH - The AVD architecture. Default value is `armeabi-v7a`. In order to run emulator using `X86` architecture, KVM is required to be installed on the host and mounted inside the container.