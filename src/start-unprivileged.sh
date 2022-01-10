#!/bin/bash
set -Eeuo pipefail

#set -x		# Uncomment for debugging

echo "Script is executing as '$(whoami)'"

# required parameters
if [ -z ${MN_PRIVATE_KEY+x} ]; then
	echo 'You need to supply the MN_PRIVATE_KEY: masternode private key';
	exit 1;
fi

if [ -z ${GUAPCOIN_BOOTSTRAP_DOWNLOAD_URL+x} ]; then
	echo 'You need to supply the GUAPCOIN_BOOTSTRAP_DOWNLOAD_URL: the bootstrap download URL';
	exit 1;
fi

# local parameters
rpc_user=${NODE_RPC_USER:-default}
rpc_password=${NODE_RPC_PASSWORD:-default}
rpc_port=${NODE_RPC_PORT:-default}

mn_public_ip=${NODE_PUBLIC_IP:-default}
mn_port=${NODE_PORT:-default}
mn_private_key=${MN_PRIVATE_KEY}

# if envirment viaribles exist
if [ -z ${NODE_RPC_USER+x} ]; then
	echo "Generating RPC user..."
	rpc_user=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 || true)
fi

if [ -z ${NODE_RPC_PASSWORD+x} ]; then
	echo "Generating RPC password..."
	rpc_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 || true)
fi

if [ -z ${NODE_RPC_PORT+x} ]; then
	echo "Using default RPC port 9634"
	rpc_port=9634
fi

if [ -z ${NODE_PUBLIC_IP+x} ]; then
	echo "Getting public ip..."
	mn_public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi

if [ -z ${NODE_PORT+x} ]; then
	echo "Using default masternode port 9633"
	mn_port=9633
fi

# /home/guapcoin/
if [ ! -d .guapcoin ]; then
	echo "Creating guapcoin data directory..."
	
	mkdir .guapcoin
fi

# /home/guapcoin/.guapcoin
cd .guapcoin

# /home/guapcoin/.guapcoin/guapcoin.conf
if [ ! -f guapcoin.conf ]; then
	echo "Creating guapcoin.conf..."
		
	cat <<EOF > guapcoin.conf
rpcuser=$rpc_user
rpcpassword=$rpc_password
rpcallowip=172.16.0.0/12
rpcport=$rpc_port
port=$mn_port
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
masternode=1
externalip=$mn_public_ip:$mn_port
masternodeaddr=$mn_public_ip:$mn_port
masternodeprivkey=$mn_private_key
addnode=159.65.221.180
addnode=45.76.61.148
addnode=209.250.250.121
addnode=136.244.112.117
addnode=199.247.20.128
addnode=78.141.203.208
addnode=155.138.140.38
addnode=45.76.199.11
addnode=45.63.25.141
EOF

else
	echo "File 'guapcoin.conf' do exists, no need to create one"
fi

# /home/guapcoin/.guapcoin/blocks/
if [ ! -d blocks ]; then
	echo "Downloading bootstrap..."
	curl -SLO ${GUAPCOIN_BOOTSTRAP_DOWNLOAD_URL}
	
	echo "Extracting bootstrap..."
	unzip bootstrap.zip
	
	rm bootstrap.zip
else
	echo "Directory 'blocks' do exists, no need to download bootstrap"
fi

# start daemon
guapcoind -daemon

# loading blocks
echo "Waiting for masternode till its completely synchronized..."
echo "Loading blocks..."

while true
do
	sleep 5

	if [ -n "$(guapcoin-cli mnsync status | grep '"IsBlockchainSynced": true')" ]; then
		echo "Masternode is synchronized"
		break
		
	else
		currentBlock=$(guapcoin-cli getblockcount);
		
		# if wallet is still loading it shows: Current block -1 instead of: Current block 1225146
		if [ "$currentBlock" -ne "-1" ]; then
			echo "Current block $(guapcoin-cli getblockcount)"
		fi
	fi
done

# report masternode status every x seconds
while true
do
	# guapcoin-cli getmasternodestatus returns exit status code 1 when unhealthy so override `set -e`
	# examples:
	# - error: couldn't connect to server			daemon is still starting-up
	# - Active Masternode not initialized.			waiting for start command
	
	# override the `set -e` defined at the top of the file
	set +e
	
	# exit code is mostly 1 in the beginning
	masternodestatus=$(guapcoin-cli getmasternodestatus 2>&1)
	
	# turn `set -e` back on so future errors halt the script
	set -e
	
	if [ -n "$(echo $masternodestatus | grep '"message":"This is not a masternode."')" ]; then
		echo "Something went wrong during initialization of this masternode. Please reset this container and try again."
		exit 1
		
	elif [ -n "$(echo $masternodestatus | grep '"message":"Active Masternode not initialized."')" ]; then
		echo "Waiting for 'startmasternode' command from the local wallet..."
		sleep 5
		
	else
		echo "status: $masternodestatus"
		sleep 600
	fi
	
done