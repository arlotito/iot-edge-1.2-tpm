# Troubleshooting

In general refer to [this trobleshooting guide](https://docs.microsoft.com/en-us/azure/iot-edge/troubleshoot?view=iotedge-2020-11) for IoT Edge.  
- Check out the logs:
```bash
sudo iotedge system set-log-level debug
sudo iotedge system restart
sudo iotedge system logs
```  
- If you see errors or bad requests (400) try to explicitly re-apply config and/or trigger reprovisioning:  
 ```bash
sudo iotedge config apply
sudo iotedge system reprovision
sudo iotedge system logs
```  

you might see more details in the log now.  

- Verify that you ```/etc/aziot/config.toml``` hast correct settings:  
  - Make sure that you use correct DPS instance with you verified Root certificate and correct IP Scope.  
  - Make sure that IoT Edge is configured to use x509 based provisioning.
  - Make sure that EST endpoint is configured correctly. 
  - Make sure that pkcs11 settings are correct.
- Certificates are located in  ```/var/lib/aziot/certd/certs ```. See if your  ```deviceid-``` certificate is there and is issued by your ICA  
 ```bash
 sudo openssl x509 -in /var/lib/aziot/certd/certs/deviceid-<YOUR SUFFIX>.cer -text
 ```  
 - Since we use an HSM to store secret keys you should NOT see any prvate keys corresponding to *deviceid* or *deviceca* certificates in ```/var/lib/aziot/keyd/keys```  