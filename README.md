# Install-ExchangeSU
This scripts installs an Exchange SU if it is a later version that currently installed

# Usage

 The script requires the following parameters to run:
    -configFile [UNCPath\Filename of config file]
    
    #You will need to populate the config file with the remote path, local path, and TRUE or FALSE to do the install or not
    
    <?xml version="1.0" encoding="UTF-8"?>
    <configuration>
      <UpdateFilePath>\\SERVER1\ExchangeUpdates</UpdateFilePath>
      <UpdateLocalPath>C:\Updates</UpdateLocalPath>
      <InstallUpdate>FALSE</InstallUpdate>
    </configuration> 
 
 
    
  
