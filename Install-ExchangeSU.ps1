<#
Exchange Script Version 1.1
Last Update by Reuben Ellett 16/01/2023
 
.SYNOPSIS
    This scripts installs an Exchange SU if it is a later version that currently installed
 
.DESCRIPTION
    The script requires the following parameters to run:
    -configFile [UNCPath\Filename of config file]
 
    You will need to populate the config file
 
.NOTES
    File Name  : Update-ExchangeSU.ps1
    Author     : Reuben Ellett - reuben_ellett@outlook.com
    Version:     1.1
    Requires   : PowerShell Version 5.1
 
.PARAMETER ConfigFile
    Specifies the path to the configuration XML file that contains all the configuration parameters.
 
.EXAMPLE
   .\Update-ExchangeSU.ps1 -ConfigFile C:\ExchangeInstallFiles\ConfigFile.xml 
 
.LINK
    NA
#>
 
#region --------------- Load Parameters -------------------------------
<# **********************************************************************************************************************
Load Parameters
 
This section focuses on loading all variables and parameters
************************************************************************************************************************* #>
[CmdletBinding()]
Param (
    [parameter(Mandatory=$True)]$ConfigFile
 
)
[XML] $Config = Get-Content -Path $ConfigFile
[string] $UpdateFilePath = $Config.configuration.UpdateFilePath
[string] $UpdateLocalPath = $config.configuration.updatelocalpath
[bool]$InstallUpdate = [System.Convert]::ToBoolean($Config.configuration.InstallUpdate)
$global:updatelist = @()
$global:updatefile = $null
$global:toomanyfiles = $false
$global:InstallSUPath = $null
$server = hostname
Start-Transcript -Path "$UpdateLocalPath\install_$(get-date -f yyyy-MM-dd).log" -Append
 
#region --------------- Check Exchange Version -------------------------------
<# **********************************************************************************************************************
Check Exchange Version
 
This function will check the exchange versions and load it into the vars
************************************************************************************************************************* #>
 
Function Get-ExchangeVersion {
 
    Write-Output "Get-ExchangeVersion started $(get-date)"
    try {
        $updatefile = Get-ChildItem $UpdateFilePath | Where-Object {$_.Extension -eq ".exe"}
        if ($updatefile.Count -gt 1) {
            Write-Output "Too many files in the folder, setting update value to false"
            $global:toomanyfiles = $True
        }
        $global:updatefile = $updatefile
 
        #Checking the  path
        if (!(Test-Path $env:ExchangeInstallPath)) {
            Write-Output "Invalid ExchangeInstallPath"
            return
        }
        $rempath = "$env:ExchangeInstallPath\Bin\Setup.exe"
 
        $filever = Get-ChildItem $rempath
        $IsOutofDate = $False
 
        if ($filever.VersionInfo.FileVersion -lt $updatefile.VersionInfo.FileVersion) {
            $IsOutofDate = $True
        }
        $obj = [PSCustomObject]@{
                name = $server
                version = $filever.VersionInfo.FileVersion
                Update = $IsOutofDate
                Updated = $null
                FileName = $null
                FilePath = $UpdateLocalPath
 
            }
        $global:updatelist += $obj
 
 
        $obj = [PSCustomObject]@{
                name = 'File In Folder'
                version = $updatefile.VersionInfo.FileVersion
                FileName = $updatefile.Name
                FilePath = $UpdateFilePath
            }
        $global:updatelist += $obj
} 
catch 
    {
    Write-Output "An error occurred while checking the version: $_"
    }
Write-Output "Get-ExchangeVersion finished $(get-date)"
} 
 
 

 
#region --------------- Install Exchange SU -------------------------------
<# **********************************************************************************************************************
Install-ExchangeSU
 
If the version of the SU is later than what is currently installed - install the SU on that machine
************************************************************************************************************************* #>
 
Function Install-ExchangeSU {
    try {
 
        # Verify that the update file exists and is not too many files
 
        Write-Output "Install-ExchangeSU started $(get-date)"
        if (!$global:toomanyfiles -and $global:updatelist[0].update) {
 
            # Copy the update file to the local path
            $InstallSUPath = $UpdateLocalPath + '\' + $updatefile.Name
            $global:InstallSUPath = $InstallSUPath
            Copy-Item -Path "$updatefilepath\*.exe" -Destination $UpdateLocalPath -Include "*.exe" -Force
 
            # Install the update
            if ($InstallUpdate) {
                Write-Verbose "Installing update $($updatefile.Name) on server $server"
                $global:updatelist[0].Updated = $(get-date)
                & $InstallSUPath /silent
                $global:updatelist[0].Updated = "Yes, restart may be required however"
            }
        }
        Else{
 
            Write-Output "There are either too many executable files in $($updatefilepath), the config file is set to not install (Currently $($InstallUpdate)), or the version installed on the server is already the same or later"
 
        }
    } catch {
 
        Write-Output "An error occurred while installing the update: $_"
 
    }
    Write-Output "Install-ExchangeSU finished $(get-date)"
}
 
 
#region --------------- MAIN -------------------------------
<# **********************************************************************************************************************
MAIN
 
Call all functions and run the script
************************************************************************************************************************* #>
 
Get-ExchangeVersion 
Install-ExchangeSU
 
$global:updatelist | Out-File ($UpdateFilePath + ('\' + $server + '.txt'))
$global:updatelist | Out-File ($UpdatelocalPath + ('\' + $server + '.txt'))
gci -path $updatelocalpath | Remove-Item -Include *.exe 
Stop-Transcript
 
 
 
