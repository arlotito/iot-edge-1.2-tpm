# One-click deployment on Azure  
  
```bash
./deploy.sh [optional region e.g. westeurope, westus...]
```  
> **_NOTE:_** Make sure your are logged in using ```az login``` and your target subscription is set as default ```az account set --subscription``` 

After a successful deployment you can ssh into the IoT Edge VM using [Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh#privatekey). The deployment script will output the username and the ssh private key.