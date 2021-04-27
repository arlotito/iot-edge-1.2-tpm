#! /bin/bash

getRandomString() {
  sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 4) | tr '[:upper:]' '[:lower:]'
}

PREFIX=iotedge12-vtpm
RANDOM_SUFFIX=$(getRandomString)

RG_NAME=$PREFIX-$RANDOM_SUFFIX
VNET_NAME=$PREFIX-vnet
SUBNET_NAME=$PREFIX-subnet
NSG_NAME=$PREFIX-nsg
BASTION_PUBLIC_IP=$PREFIX-bastion-public-ip-$RANDOM_SUFFIX
VM_SIZE=Standard_B1ms
BASTION_NAME=$PREFIX-bastion-$RANDOM_SUFFIX
CLOUD_INIT_IOT_EDGE=cloud-init.yaml
ADMIN_USERNAME=azureuser

set -e
trap 'catch $?' EXIT
catch() {
  # echo "catching!"
  if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred"
  fi
}

# Configure defaults
if [ -z "$1" ]; then
  echo "No region provided. Using default location [westeurope]"
  az configure --defaults location=westeurope
else
  az configure --defaults location=$1
fi

# Create a resource group.
az group create --name ${RG_NAME}

# Create a virtual network and front-end subnet.
az network vnet create --resource-group ${RG_NAME} --name ${VNET_NAME} --address-prefix 10.0.0.0/16 \
  --subnet-name ${SUBNET_NAME} --subnet-prefix 10.0.0.0/24

  # Create AzureBastionSubnet
az network vnet subnet create --resource-group ${RG_NAME} --vnet-name ${VNET_NAME} \
  --name AzureBastionSubnet --address-prefix 10.0.1.0/27

# Create public IP for Azure Bastion
az network public-ip create --resource-group ${RG_NAME} --name ${BASTION_PUBLIC_IP} \
  --allocation-method Static --sku Standard

# Create Azure Bastion
az network bastion create --name ${BASTION_NAME} --public-ip-address ${BASTION_PUBLIC_IP} \
  --resource-group ${RG_NAME} --vnet-name ${VNET_NAME}

# Create an IoT Edge virtual machine
az vm create --resource-group ${RG_NAME} --name ${RG_NAME} --image UbuntuLTS \
   --vnet-name ${VNET_NAME} --subnet ${SUBNET_NAME} --nsg ${NSG_NAME} --public-ip-address "" \
   --generate-ssh-keys --size ${VM_SIZE} --admin-username ${ADMIN_USERNAME} --custom-data ${CLOUD_INIT_IOT_EDGE}

# Output credentials for VMs
echo "YOUR SSH USERNAME FOR AZURE BASTION:"
echo ${ADMIN_USERNAME}

echo "YOUR SSH PRIVATE KEY FOR AZURE BASTION:"
cat ~/.ssh/id_rsa

# Wait for cloud-init to finish
echo -e "\nAll tools and IoT Edge are now being installed. Waiting for cloud-init to finish..."
az vm run-command invoke -g ${RG_NAME} -n ${RG_NAME} --command-id RunShellScript --script "/usr/bin/cloud-init status --wait"

# Initialize IoT Edge
echo -e "\nThe installation was successful! Configure IoT Edge to use your DPS instance and EST endpoint"

echo The PKCS11/TPM is used to securely store keys.
echo DPS provisioning
echo --------------------------------
echo Registration ID? ex. my-device-1
read DEVICE_ID
echo
echo Scope ID? ex. 0ne00112233
read DPS_SCOPEID
echo

echo EST configuration
echo --------------------------------
echo EST hostname:port? ex. id.myest.net:443
read EST_HOSTNAME
echo
echo Username? ex. username
read EST_USERNAME
echo
echo
echo Password? ex. password
read EST_PASSWORD
echo

az vm run-command invoke -g ${RG_NAME} -n ${RG_NAME} --command-id RunShellScript \
    --script "/home/${ADMIN_USERNAME}/iot-edge-1.2-tpm/scripts/iot-edge-config-azure.sh '${DEVICE_ID}' '${DPS_SCOPEID}' '${EST_HOSTNAME}' '${EST_USERNAME}' '${EST_PASSWORD}'"