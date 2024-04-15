# nginx-connection-check

In Azure VM, the bash file is used to check the active connection value in nginx-based pods on the nodes of the AKS cluster every 5 minutes, automatically increasing or decreasing the number of nodes.

## How it works

After creating the VM, enter the following command via CMD to access the VM and prepare the Bash file to work properly in the local environment by entering the authentication code.
```
az login
```

Enter the authentication code that appears when you enter the above command locally.
![VM10](https://github.com/Bullishman/nginx-connection-check/assets/42830393/49c573dc-15db-4f69-bb4b-e56545247471)
![VM11_updated](https://github.com/Bullishman/nginx-connection-check/assets/42830393/4603edb2-7a4f-4add-bec0-c6218bbb42a2)
![VM12_updated](https://github.com/Bullishman/nginx-connection-check/assets/42830393/2570669b-49f0-478c-8a6e-8c3be09f6e07)

Upon successful login, the following result is returned.
![VM13_updated](https://github.com/Bullishman/nginx-connection-check/assets/42830393/a95a5b50-8d53-44f5-883b-cd0fbccb55cd)

Install or Unzip Apache24 and then you can execute command following to increase active connection.
```
ab -n 100 -c 100 http://localhost:8080/basic_status
```
Afterwards, running the bash file checks the active connection value in all nodes' nginx-based pods every 5 minutes, automatically creating a node when there are more than 5 active connections and deleting a node when there are none.
![VM15_updated](https://github.com/Bullishman/nginx-connection-check/assets/42830393/9585b576-b152-46ad-8b50-c893576b6cf5)

Below is a photo when the node has been successfully created.
![VM16_updated](https://github.com/Bullishman/nginx-connection-check/assets/42830393/723ae333-c45d-4934-b11e-ee70964d599f)
