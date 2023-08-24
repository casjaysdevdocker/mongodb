## 👋 Welcome to mongodb 🚀  

mongodb README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update mongodb
```
  
## Install and run container
  
```shell
mkdir -p "$HOME/.local/share/srv/docker/mongodb/rootfs"
git clone "https://github.com/dockermgr/mongodb" "$HOME/.local/share/CasjaysDev/dockermgr/mongodb"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/mongodb/rootfs/." "$HOME/.local/share/srv/docker/mongodb/rootfs/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-mongodb \
--hostname mongodb \
-e TZ=${TIMEZONE:-America/New_York} \
-v $HOME/.local/share/srv/docker/casjaysdevdocker-mongodb/rootfs/data:/data:z \
-v $HOME/.local/share/srv/docker/casjaysdevdocker-mongodb/rootfs/config:/config:z \
-p 80:80 \
casjaysdevdocker/mongodb:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/mongodb
    container_name: casjaysdevdocker-mongodb
    environment:
      - TZ=America/New_York
      - HOSTNAME=mongodb
    volumes:
      - $HOME/.local/share/srv/docker/casjaysdevdocker-mongodb/rootfs/data:/data:z
      - $HOME/.local/share/srv/docker/casjaysdevdocker-mongodb/rootfs/config:/config:z
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/mongodb
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/mongodb" "$HOME/Projects/github/casjaysdevdocker/mongodb"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/mongodb"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
