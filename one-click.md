# One-click deployment on Azure  

> **_NOTE:_** Make sure your are logged in using ```az login``` and your target subscription is set as default ```az account set --subscription```   
> Also ideally have your device id, DPS id scope, EST server URL, EST username and password ready before running this script.  
> If you don't have those, it is OK to skip the configuration part at the end of the deployment and provide those settings in config.toml later.  
```bash
./deploy.sh [optional region e.g. westeurope, westus...]
```  

After a successful deployment you can ssh into the IoT Edge VM using [Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh#privatekey). The deployment script will output the username and the ssh private key.