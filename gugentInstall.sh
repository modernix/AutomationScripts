#==============================================
# Generated On: 08/04/2015
# Generated By: Gary Coburn
# Specialist
# Organization: VMware
# Twitter: @coburnGary
# gugent install script v1
#==============================================
#----------------------------------------------
#==================USAGE=======================
# incomplete
#----------------------------------------------
#===============REQUIREMENTS===================
# For this script to run successfully be sure:
# 	*To run PowerShell as administrator
#	*To have admin rights on the server
#----------------------------------------------

#=============EDITOR'S NOTE====================
# In order for this script to work on servers that
# have proxied or restricted access to the Internet,
# it is necessary to configure a local source repository
# or else the features and roles requiring .NET 3.5 will fail.
# To do so, configure the variable called $InstallSource
# below making sure to set the path appropriately. In
# this example, the source is provided by mounting the
# installation CD as drive D.
# 	- Chip Zoller, Senior Virtualization Engineer, Worldpay US

# ----------------------------------------
#   USER CONFIGURATION - EDIT AS NEEDED
# ----------------------------------------

# incomplete this section will build what the script prompts for later

# ----------------------------------------
# 		END OF USER CONFIGURATION
# ----------------------------------------
# ----------------------------------------
# 		Install Script
# ----------------------------------------
New-Item -ItemType Directory -Force -Path C:\opt

Start-Transcript -Path "c:\opt\AgentInstall.txt"

#functions
#Download the files
function downloadNeededFiles($url,$file)
{
    #Download files to specific location
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $clnt = New-Object System.Net.WebClient
    $clnt.DownloadFile($url,$file)
    write-output "$file downloaded"
}
#Extract the files into the needed locations
function extractZip($file,$dest)
{
    write-output "$file extracting files"
    $shell = new-object -com shell.application
    if (!(Test-Path "$file"))
    {
        throw "$file does not exist"
    }
    #New-Item -ItemType Directory -Force -Path $dest -WarningAction SilentlyContinue
    $shell.namespace($dest).copyhere($shell.namespace("$file").items())
    write-output "$file extracted"
}

$vRAurl = read-Host -Prompt "What is the url of your vRA Appliance? (ex. https://vraServer.domain)  "
Write-Host "The URL you specificed is $vRAurl" -ForegroundColor Yellow

$url+="$vRAurl" + ":5480/installer/GugentZip_x64.zip"
$file="c:\opt\GugentZip_x64.zip"
Write-Host "Downloading file: $url to $file " -ForegroundColor Yellow
$dest="c:"
downloadNeededFiles $url $file
extractZip $file $dest

$IaaS = read-Host -Prompt "What is fqdn of your IaaS Server? (ex. windowsServer.domain)  "
Write-Host "The fqdn you specificed is $IaaS" -ForegroundColor Yellow
$port = read-Host -Prompt "What is port of your IaaS Server? (ex. 443)  "
Write-Host "The port you specificed is $port" -ForegroundColor Yellow
$argumentList = " -i -h " + "$IaaS" + ":" + "$port" + " -p ssl"
Write-Host $argumentList

cd c:\VRMGuestAgent
$winservicefile = ("winservice.exe")
$gugentInstall = Start-Process $winservicefile -ArgumentList $argumentList -Wait -PassThru
# ----------------------------------------
# 		Install Script Complete
# ----------------------------------------
