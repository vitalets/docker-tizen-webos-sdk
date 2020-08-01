# docker-tizen-webos-sdk
[Samsung Tizen CLI](https://developer.samsung.com/smarttv/develop/getting-started/using-sdk/command-line-interface.html)
and [LG webOS CLI](http://webostv.developer.lge.com/sdk/tools/using-webos-tv-cli/) bundled as docker container.
Allows to develop, build, launch and debug Smart TV apps without installing Tizen Studio and webOS SDK.
Available CLI commands:
* `tizen`
* `sdb`
* `ares-*`

## Requirements
The only requirement is docker:
* for Mac/Windows - [Docker Desktop](https://www.docker.com/products/docker-desktop) 
* for Linux - [Docker Engine](https://docs.docker.com/engine/install/) 

## Usage
Run `bash` session inside container:
```
docker run -it --rm -v webos:/.webos vitalets/tizen-webos-sdk bash
```
Now you have Ubuntu with `sdb`, `tizen`, and `ares-*` commands available:
```
$ tizen version
Tizen CLI 2.5.21

$ sdb version
Smart Development Bridge version 4.2.12

$ ares-setup-device --version
Version: 1.10.4-j1703-k
```

> Container is intentionally started under the `root` user.
  Starting under non-root user will cause [permissions issue](https://github.com/moby/moby/issues/2259)
  when attaching volumes.

### Samsung Tizen TV
#### Get info about Samsung TV
If you have Samsung TV with IP `192.168.1.66` in the same network as your host machine, you can get TV info: 
```
curl http://192.168.1.66:8001/api/v2/
```
<details>
 <summary>Example response</summary>

    {
       "device":{
          "FrameTVSupport":"false",
          "GamePadSupport":"true",
          "ImeSyncedSupport":"true",
          "Language":"ru_RU",
          "OS":"Tizen",
          "PowerState":"on",
          "TokenAuthSupport":"true",
          "VoiceSupport":"false",
          "WallScreenRatio":"0",
          "WallService":"false",
          "countryCode":"RU",
          "description":"Samsung DTV RCR",
          "developerIP":"192.168.1.64",
          "developerMode":"1",
          "duid":"uuid:88d68ee4-cffc-47c4-894f-6d46ca51333a",
          "firmwareVersion":"Unknown",
          "id":"uuid:88d68ee4-cffc-47c4-894f-6d46ca51333a",
          "ip":"192.168.1.66",
          "model":"19_MUSEL_UHD",
          "modelName":"UE43RU7400UXRU",
          "name":"[TV] Samsung 7 Series (43)",
          "networkType":"wireless",
          "resolution":"3840x2160",
          "smartHubAgreement":"true",
          "ssid":"94:4a:0c:86:c7:00",
          "type":"Samsung SmartTV",
          "udn":"uuid:88d68ee4-cffc-47c4-894f-6d46ca51333a",
          "wifiMac":"B8:BC:5B:93:7E:D2"
       },
       "id":"uuid:88d68ee4-cffc-47c4-894f-6d46ca51333a",
       "isSupport":"{\"DMP_DRM_PLAYREADY\":\"false\",\"DMP_DRM_WIDEVINE\":\"false\",\"DMP_available\":\"true\",\"EDEN_available\":\"true\",\"FrameTVSupport\":\"false\",\"ImeSyncedSupport\":\"true\",\"TokenAuthSupport\":\"true\",\"remote_available\":\"true\",\"remote_fourDirections\":\"true\",\"remote_touchPad\":\"true\",\"remote_voiceControl\":\"false\"}\n",
       "name":"[TV] Samsung 7 Series (43)",
       "remote":"1.0",
       "type":"Samsung SmartTV",
       "uri":"http://192.168.1.66:8001/api/v2/",
       "version":"2.0.25"
    }
</details>

#### Connect to Samsung TV 
Please ensure that TV is in [Developer Mode](https://developer.samsung.com/smarttv/develop/getting-started/using-sdk/tv-device.html)
and Developer IP equals to your host IP (check `developerMode` and `developerIP` in curl response).
```
$ sdb connect 192.168.1.66

* Server is not running. Start it now on port 26099 *
* Server has started successfully *
connecting to 192.168.1.66:26101 ...
connected to 192.168.1.66:26101
```

#### List connected TVs
```
$ sdb devices

List of devices attached 
192.168.1.66:26101      device          UE43RU7400UXRU
```

#### Get TV capabilities
```
$ sdb -s 192.168.1.66 capability

secure_protocol:enabled
intershell_support:disabled
filesync_support:pushpull
...
```

#### Get list of installed apps
```
$ sdb -s 192.168.1.66 shell 0 applist

Application List for user 5001
User's Application 
Name               AppID 
=================================================
'HdmiCec'         'org.tizen.hdmicec'
'automation-app'  'org.tizen.automation-app'
...
```
#### Launch app on TV
```
$ tizen run -s 192.168.1.66:26101 -p 9Ur5IzDKqV.TizenYouTube

Launching the Tizen application...
--------------------
Platform log view
--------------------
... successfully launched pid = 1656 with debug 0
Tizen application is successfully launched.
```
or
```
$ sdb -s 192.168.1.66:26101 shell 0 was_execute 9Ur5IzDKqV.TizenYouTube
```

#### Pack app
Sample developer certificate is included, so you can pack your app without any setup (for development).
Author.p12 / distributor.p12 password is `developer`.
Run container with mounting app source `./src` into `/app`:
```
docker run -it --rm -v ./src:/app vitalets/tizen-webos-sdk bash
```
Create `wgt` package:
```
tizen package -t wgt -o /home/developer -- /app

The active profile is used for signing. If you want to sign with other profile, please use '--sign' option.
Author certficate: /home/developer/author.p12
Distributor1 certificate : /home/developer/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12
Excludes File Pattern: {.manifest.tmp, .delta.lst}
Ignore File: /app/.manifest.tmp
Package File Location: /home/developer/MyTvApp.wgt
```

#### Install app 
```
$ tizen install -s 192.168.1.66:26101 --name MyTvApp.wgt -- /home/developer

Transferring the package...
Transferred the package: /home/developer/MyTvApp.wgt -> /home/owner/share/tmp/sdk_tools/tmp
Installing the package...
--------------------
Platform log view
--------------------
install TESTABCDEF.MyTvApp
package_path /home/owner/share/tmp/sdk_tools/tmp/MyTvApp.wgt
was_install_app return WAS_TRUE
app_id[TESTABCDEF.MyTvApp] install start
...
app_id[TESTABCDEF.MyTvApp] install completed
spend time for wascmd is [1898]ms
cmd_ret:0
Installed the package: Id(TESTABCDEF.MyTvApp)
Tizen application is successfully installed.
Total time: 00:00:02.895
```
> You may need to rename wgt before installing
> because `tizen install` does not work properly with spaces and non-latin symbols in wgt filename

#### Debug app
Launch app in debug mode:
```
$ sdb -s 192.168.1.66:26101 shell 0 debug TESTABCDEF.MyTvApp

... successfully launched pid = 12915 with debug 1 port: 34541
```
Then open in chrome url `http://{TV_IP}:{PORT}` using port from previous command.

#### Close app
```
$ sdb -s 192.168.1.66:26101 shell 0 kill TESTABCDEF
```
> Note using only `packageId` instead of full `appId`.

#### Uninstall app
```
$ tizen uninstall -s 192.168.1.66:26101 -p TESTABCDEF.MyTvApp

--------------------
Platform log view
--------------------
uninstall TESTABCDEF.MyTvApp
app_id[TESTABCDEF.MyTvApp] uninstall start
...
app_id[TESTABCDEF.MyTvApp] uninstall completed
spend time for wascmd is [2027]ms
cmd_ret:0
Total time: 00:00:02.703
```

#### Pack, install and launch app on TV in single command
App sources are in `./src`.
The following env variables are used:
- `TV_IP=192.168.1.66`
- `APP_ID=TESTABCDEF.MyTvApp` (from config.xml)
- `APP_NAME="My TV App"` (from config.xml)
```
docker run -it --rm \
  -e TV_IP=192.168.1.66 \
  -e APP_ID=TESTABCDEF.MyTvApp \
  -e APP_NAME="My TV App" \
  -v webos:/.webos
  -v ./src:/app \
  vitalets/tizen-webos-sdk /bin/bash -c '\
  tizen package -t wgt -o . -- /app \
  && mv "$APP_NAME.wgt" app.wgt \
  && sdb connect $TV_IP \
  && tizen install -s $TV_IP:26101 --name app.wgt -- . \
  && tizen run -s $TV_IP:26101 -p $APP_ID'
```

### LG WebOS TV
tbd

## Development

#### Build container
```bash
docker build -t vitalets/tizen-webos-sdk .
```
For faster builds during development you can download Tizen Studio installer to `vendor` dir:
```bash
wget http://download.tizen.org/sdk/Installer/tizen-studio_3.7/web-cli_Tizen_Studio_3.7_ubuntu-64.bin \
-O vendor/web-cli_Tizen_Studio_3.7_ubuntu-64.bin
```
and use local file in docker build:
```bash
docker run -d --name nginx-temp -p 8080:80 -v $(pwd)/vendor:/usr/share/nginx/html:ro nginx \
&& docker build -t vitalets/tizen-webos-sdk . \
  --build-arg TIZEN_STUDIO_URL=http://host.docker.internal:8080/web-cli_Tizen_Studio_3.7_ubuntu-64.bin \
; docker rm --force nginx-temp
```

#### Test
```bash
./test.sh
```

#### Publish to Docker Hub
```bash
docker push vitalets/tizen-webos-sdk
```
