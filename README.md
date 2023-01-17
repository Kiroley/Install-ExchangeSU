# Install-ExchangeSU
This scripts installs an Exchange SU if it is a later version than currently installed, provided it exists in a particular folder on a remote file share

# Usage
You will need to populate the config file with the remote path, local path, and TRUE or FALSE to do the install or not
    
    <?xml version="1.0" encoding="UTF-8"?>
    <configuration>
      <UpdateFilePath>\\SERVER1\ExchangeUpdates</UpdateFilePath>
      <UpdateLocalPath>C:\Updates</UpdateLocalPath>
      <InstallUpdate>FALSE</InstallUpdate>
    </configuration> 
 
 **UpdateFilePath**, the location where you place your update files
 **UpdateLocalPath**, where the server will copy the update files to as well as keep the logs/transcripts
 **InstallUpdate**, TRUE to apply the update, FALSE to not apply the update
 
 # Parameters
 **-ConfigFile**, UNC Path to the config file location.
 
 # Examples
 
    .\Update-ExchangeSU.ps1 -ConfigFile C:\ExchangeInstallFiles\ConfigFile.xml 
    
# More information

You can set this script up to run as a scheduled task on the target server, permissions required are local administrator and whatever NTFS/File Share permissions to access the **UpdateFilePath**.

This way you can specify different **-configfile** XML files for servers in different sites that may access different shares.

There is a basic text file that is dropped in both the **UpdateFilePath** and **UpdateLocalPath** that will tell you the version of the server. This can be useful when running **InstallUpdate** in **FALSE** mode to just get an idea of what versions are running in your fleet (or just use get-exchangeserver from your management shell)

The script reports on the version of the executable in the install folder. This way you get the exact build numbers as they correspond to the SU releases. 

# Why would I use this script?

You may want to control when updates occur in your environment Exchange through semi-automation. Using this script I can update sites when I see fit (that point towards a seperate config file and file share) by simply copying a file into the updates folder. 

   E.G. Week 1 place the update in the DC4 folder, all Exchange servers update that week. Next week place the update executable into the DC5 folder, all exchange     servers pointing toward that DC5 folder update that week. etc.
