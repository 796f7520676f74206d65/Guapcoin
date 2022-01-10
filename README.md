Guapcoin masternode for docker
===================

Docker image that runs the Guapcoin masternode.

If you like this image, buy me a coffee ;) GUAP: GgSeiqi91vVMksUCp2AaHKUCN9q7W2cgTc

Quick Start
-----------

```bash
docker run \
	-d \
	-p 9633:9633 \
	-e MN_PRIVATE_KEY=your-masternode-key \
	--name guapcoin-mn01 \
	guapcoin:latest
```

This will create a ```guapcoin``` user and run the ```guapcoind``` daemon unprivileged. You can find the ```guapcoin.conf``` inside the home directory of the guapcoin user which is: ```/home/guapcoin/.guapcoin/```.

Start a masternode
------------

## On your local Guapcoin QT wallet:

##### 1. Open console for generating a masternode key and save it
- ```createmasternodekey```

## On your docker host:

##### 1. Run the docker container
```bash
docker run \
	-d \
	-p 9633:9633 \
	-e MN_PRIVATE_KEY=your_masternode_key \
	--name guapcoin-mn01 \
	guapcoin:latest
```

## Setup desktop wallet:

##### 1. Create a new receiving address with alias ```mn01``` in desktop wallet and copy it or by using the console
- ```getnewaddress mn01```

##### 2. Send collateral amount of Guapcoin to copied address

##### 3. Open the console and get the masternode output and copy it
- ```getmasternodeoutputs```

##### 4. Open the masternode configuration file and paste and save the configuration
- ```mn01 docker_container_public_ip:9633 your_masternode_key masternode_output output_index```

##### 5. Restart desktop wallet so it will reload the new configuration
- **it's important**

##### 6. Wait for at least 15 confirmations of the transaction

##### 7. Start masternode in desktop wallet or by using the console:
- ```startmasternode alias false mn01```

## Masternode monitoring
The status of the masternodes in the desktop wallet masternode section is reliable. Another way too monitor is to have a look at the output of the docker container. It will report the status of the masternode every 10 minutes.