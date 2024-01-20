# Tatertots
Starch Miner in Bash. Run it standalone or with Docker. 


## With Docker
Install Docker or Docker Desktop.
[https://docs.docker.com/desktop/](https://docs.docker.com/desktop/)

1. Clone this repo and cd into it.
```shell
git clone https://github.com/wcatz/tatertots.git; cd tatertots
```
2. Copy the miner-example.conf file to a file named miner.conf
```shell
cp miner-example.conf miner.conf
```
3. Edit miner.conf, add your miner id/'s with Nano. ctrl+o to save, ctrl+x to exit Nano.
```shell
nano miner.conf
```
4. Check which version of docker compose is installed. 
```shell
docker compose up -d
```
If that does not work try the old method.

```shell
docker-compose up -d
```
5. Follow the containers output to confirm it is running. Use the docker compose command that worked to bring it up. ctrl+x to stop following the output. Once the container is built you can also follow it's output in Docker Desktop.

```shell
docker compose logs -f
```
6. You can stop the miner from Docker Desktop or with.
```shell
docker compose down
```

## Standalone script execution

If you want to run the script in a Tmux session or with Systemd just go through these steps to execute it locally.

1. You need curl an jq.
```shell
sudo apt install curl jq
```

2. Clone this repo and cd into it.
```shell
git clone https://github.com/wcatz/tatertots.git; cd tatertots
```
3. Copy the miner-example.conf file to a file named miner.conf
```shell
cp miner-example.conf miner.conf
```
4. Edit miner.conf, add your miner id/'s with Nano. ctrl+o to save, ctrl+x to exit Nano.
```shell
nano miner.conf
```
5. Make the script executable and run it. ctr+c to stop it.
```shell
chmod +x tatertots.sh
./tatertots.sh
```

