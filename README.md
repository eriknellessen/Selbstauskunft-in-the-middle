# Welcome

This project includes the source code for the "Selbstauskunft in the middle" scenario. Information about the scenario can be found here: https://sarwiki.informatik.hu-berlin.de/Selbstauskunft_%22in-the-middle%22

Warning: This is just proof-of-concept code and should _NOT_ be used in production environments

## Using with docker

You can find the docker images for this project here: https://hub.docker.com/r/eriknellessen/selbstauskunft-in-the-middle

You can use the docker image both on the client PC and on the server PC.

### Setting up the server

```sh
docker pull eriknellessen/selbstauskunft-in-the-middle:1.0.0
docker create -it --privileged --tmpfs /tmp --tmpfs /run --name selbstauskunft-1.0.0 eriknellessen/selbstauskunft-in-the-middle:1.0.0
docker container start selbstauskunft-1.0.0
```

That is all you need to do, the web server is now running on port 4444.

You might need to open your firewall, e.g.
```sh
iptables -A FORWARD -d 172.17.0.2/32 -p tcp --dport 4444 -j ACCEPT
iptables -A FORWARD -d 172.17.0.2/32 -p tcp --dport 35963 -j ACCEPT
```

### Running the client

Connect your physical card reader to the server's virtual reader like this:
1. Your docker container should be in another subnet. You can change it like this in */etc/docker/daemon.json*:
```sh
{
  "bip": "172.18.0.1/24"
}
```
Restart docker after altering the file: 
```sh
service docker restart
```
2. Add a route to the web server:
```sh
ip r a 172.17.0.2/32 via $IP_OF_YOUR_SERVER_HOST_PC
```
3. Create and start the docker container:
```sh
docker pull eriknellessen/selbstauskunft-in-the-middle:1.0.0
docker create -it --privileged --tmpfs /tmp --tmpfs /run --name selbstauskunft-1.0.0 eriknellessen/selbstauskunft-in-the-middle:1.0.0
docker container start selbstauskunft-1.0.0
docker exec -it selbstauskunft-1.0.0 bash
```
4. Connect your physical card reader to your client PC, if you did not already do this. Insert your nPA. Find out about your card reader number by executing in the docker container:
```sh
pcsc_scan
```
5. Insert your nPA in the virtual card reader on the server:
```sh
PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.7/site-packages/ vicc --hostname 172.17.0.2 --port 35963 --type=relay --reader $YOUR_CARD_READER_NUMBER -v
```

Now you can check on the server PC that the nPA is inserted in the virtual card reader via:
```sh
pcsc_scan
```

On your client PC, open your web browser and connect to http://172.17.0.2:4444/. Then click "Show me the secret!". The server will perform reading the data from the nPA. If your first name is "Erik", it will show you the secret. Else, it will show you the results from reading your data.

## Building without docker

[![Build Status](https://gitlab.com/eriknellessen/Selbstauskunft-in-the-middle/badges/master/pipeline.svg)](https://gitlab.com/eriknellessen/Selbstauskunft-in-the-middle/-/pipelines?ref=master)[![Code Quality](https://img.shields.io/badge/code%20quality-download%20report-blue)](https://gitlab.com/api/v4/projects/15583774/jobs/artifacts/master/download?job=code_quality)

### Server

To build the server part, execute the following command:

```sh
make server
```

### Client

To build the client part, execute the following command:

```sh
make client
```

## Using without docker

First, connect from the client PC to the server by executing
```sh
vicc --hostname $HOSTNAME --port $PORT --type=relay --reader $NUMBER -v
```
with the correct parameters.

Then, start the eID procedure by executing the following command:
```sh
bin/Start_Testcase --testcase=AutentApp
```

## Using the Apache module without docker
After building and installing the Apache module, start or restart your Apache server:
```sh
rcapache2 restart
```
Then open the page /eIDClientCore on your Apache web server. The eIDClientCore will then be started. If your first name is "Erik", the secret will be shown. If not, the result will be shown as a webpage.

## ToDo:
* Examine possibilities of automating connection establishment from the client
