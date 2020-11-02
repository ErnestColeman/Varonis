<#
    Creates and permissions working share on list of remote collectors
    1. Creates working share folder
    2. Shares folder and sets share permissions to Local Admins with full control
    3. Sets NTFS permissions to Local Admins with full control

#>

####UPDATE THESE VARIABLES
$colList = "C:\Users\jonathan\Desktop\BulkAddCollectors - 6.3.173\CollectorList.csv" 	# Location of CollectorList.csv
$workSharePath = "C:\VaronisWorkingShare5"    # Physical working share path on remote server 
$workShareName = "VaronisWorkingShare5"   # Working share name


##############################################################################
####This stuff can be left alone

#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
"--------------------"
"--------------------"


##########################
# FUNCTIONS

# Function to create folder on remote machine
function createDir ([string]$server, [string]$path) {
    $shareAdminPath = $path.Replace(":", "$")
    $shareUnc =  "\\$server\$shareAdminPath"
    echo " - Creating working share folder: $shareUnc"
    $createDir = New-Item $shareUnc -ItemType Directory
}

# Function to create share and set Share permissions for Local Admins with Full Control
function createShare ([string]$server, [string]$path, [string]$shareName) {
    # Set the folder path
    echo " - Creating share and setting Share permissions (Local Admin with FullControl)"
    
    # Group to grant access to
    $domain = "BUILTIN"
    $groupName = "Administrators"

    # User Name/Group to give permissions to
    $trustee = ([wmiclass]'Win32_trustee').psbase.CreateInstance()
    $trustee.Domain = $domain
    $trustee.Name = $groupName

    # Access mask values
    $fullcontrol = 2032127
    $change = 1245631
    $read = 1179785

    # Create access-list
    $ace = ([wmiclass]'Win32_ACE').psbase.CreateInstance()
    $ace.AccessMask = $fullcontrol
    $ace.AceFlags = 3
    $ace.AceType = 0
    $ace.Trustee = $trustee


    # Security descriptor containing access
    $sd = ([wmiclass]'Win32_SecurityDescriptor').psbase.CreateInstance()
    $sd.ControlFlags = 4
    $sd.DACL = $ace
    $sd.group = $trustee
    $sd.owner = $trustee

    $share = Get-WmiObject Win32_Share -List -ComputerName $server
    $createShare = $share.create("$path", $shareName, 0, 100, "", "", $sd)
                                

}



# Function to set NTFS permissions on the working share
function setNtfs ([string]$path, [string]$group) {
    
    try {
        #1. Protect folder and remove inherited permissions
        echo " - Getting ACL on $path"
        $acl = get-acl $path 
        
        echo " - Protecting folder and revoking inherited permissions"
        $acl.SetAccessRuleProtection($True, $False)

        #2. Remove any other direct permissions
        echo " - Revoking direct permissions"
        $revokeDirect = $acl.Access | %{$acl.RemoveAccessRule($_)}

        #3a. Permission group1 to folder with FullControl
            #build the new ACE
        echo " - Creating ACE object for $group"
        $objGroup = New-Object System.Security.Principal.NTAccount($group)
        $colRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $xInheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit" 
        $xPropagationFlag = [System.Security.AccessControl.PropagationFlags]"None"
        $objType =[System.Security.AccessControl.AccessControlType]"Allow"
        $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objGroup, $colRights, $xInheritanceFlag, $xPropagationFlag, $objType) 
        $acl.AddAccessRule($objACE) #adds new ACE to ACL
        
        <#
        #3b. Permission group2 to folder with FullControl
            #build the new ACE
        echo " - Creating ACE object for $group2"
        $objGroup2 = New-Object System.Security.Principal.NTAccount($group2)
        $colRights2 = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $xInheritanceFlag2 = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit" 
        $xPropagationFlag2 = [System.Security.AccessControl.PropagationFlags]"None"
        $objType2 =[System.Security.AccessControl.AccessControlType]"Allow"
        $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objGroup2, $colRights2, $xInheritanceFlag2, $xPropagationFlag2, $objType2) 
        $acl.AddAccessRule($objACE) #adds new ACE to ACL
        #>

        #4. Apply new ACL
        echo " - Applying changes"
        $acl.SetAccessRule($objACE)
        
        Set-ACL -Path $path -AclObject $acl -ErrorVariable ProcessError # commit the new ACL
        
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Warning $errorMessage
        Add-Content $errorLog "$path`n"
        #return $false
    }
}


# Import CollectorList CSV          
$colInfo = import-csv $colList

# Set up a counter to show progress
$serverCount = $colInfo | Measure-Object | Select-Object -expand count #.length #Used to display progress counter
$counter = 0



# Iterate through the collectors and create working shares.
$colinfo | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    try {
        Clear-Variable -ErrorAction SilentlyContinue -name colName, shareUnc
            

    }
    catch {

    }

    $colName = $_.hostname
    
    $counter++
    echo "[$counter/$serverCount] - $colName"
    # Create working share directory on remote machine
    createDir $colName $workSharePath

    # Create the share on the remote machine
    createShare $colName $workSharePath $workShareName

    # Set NTFS permissions (service accoutn and local admins only)
    echo " - Setting NTFS permissions (Local Admin with Full Controll)"
    $shareAdminPath = $workSharePath.Replace(":", "$")
    $workShareUnc =  "\\$colName\$shareAdminPath"
    setNtfs $workShareUnc "BUILTIN\Administrators" #"JT\Varonis"
    
    
}

"--------------------"

#disconnect from IDU
#"Disconnecting from IDU"
#disconnect-idu

"Complete - Check the Management Console for file server status"