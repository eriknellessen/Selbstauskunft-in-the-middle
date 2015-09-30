# Welcome

This project includes the source code for the "Selbstauskunft in the middle" scenario. Information about the scenario can be found here: https://sarwiki.informatik.hu-berlin.de/Selbstauskunft_%22in-the-middle%22

Warning: This is just proof-of-concept code and should _NOT_ be used in production environments

## Building

Continuous integration with Travis CI: [![Build Status](https://travis-ci.org/eriknellessen/Selbstauskunft-in-the-middle.svg?branch=master)](https://travis-ci.org/eriknellessen/Selbstauskunft-in-the-middle)

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
bin/Test_nPAClientLib_AutentApp
```