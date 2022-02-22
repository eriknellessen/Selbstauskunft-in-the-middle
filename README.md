# Welcome

This project includes the source code for the "Selbstauskunft in the middle" scenario. Information about the scenario can be found here: https://sarwiki.informatik.hu-berlin.de/Selbstauskunft_%22in-the-middle%22

Warning: This is just proof-of-concept code and should _NOT_ be used in production environments

## Building

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

## Using

First, connect from the client PC to the server by executing
```sh
vicc --hostname $HOSTNAME --port $PORT --type=relay --reader $NUMBER -v
```
with the correct parameters.

Then, start the eID procedure by executing the following command:
```sh
bin/Start_Testcase --testcase=AutentApp
```

## Using the Apache module
After building and installing the Apache module, start or restart your Apache server:
```sh
rcapache2 restart
```
Then open the page /eIDClientCore on your Apache web server. The eIDClientCore will then be started. If your first name is "Erik", the secret will be shown. If not, the result will be shown as a webpage.

##ToDo:
* Examine possibilities of automating connection establishment from the client
