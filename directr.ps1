# vCenter D.I.R.E.C.T.R.
# https://github.com/x1nni/directr
# Format: .\directr.ps1

# EDIT THESE VARIABLES FOR YOUR ENVIRONMENT

$myCluster = Get-Cluster -Name "Datacenter" # Cluster name. Comment out if not using a cluster or resource pool.
$ext = Get-VirtualNetwork -Name "Internet" # Name of network that every VM should connect to, regardless of network specified in directr.csv. e.g. internet access network
$vDomain = "vsphere.local" # SSO Domain to create the student accounts in.
$defaultFirstName = "CyberSchool" # Standardized first name for student accounts.
$defaultLastName = "Student" # Standardized last name for student accounts.
$defaultStudentGroup = "CyberSchool Students" # Global permissions group to add all student accounts to. 

try{
    $csv = Import-Csv -Path $PSScriptRoot\directr.csv
}
catch{
    Write-Host "Directr was unable to find the data CSV in the directory of the script. Please ensure you are running Directr in the same directory as directr.csv. The script will now exit."
    pause
    exit
}

#Deploy VMs by interating on every newline, taking relevant data from the CSV, and running New-VM.
Function MakeVMs {
    Clear-Host
    Write-Host "
 _______  ______ _______ _______ _______ _______      _    _ _______ _______
 |       |_____/ |______ |_____|    |    |______       \  /  |  |  | |______
 |_____  |    \_ |______ |     |    |    |______        \/   |  |  | ______|
                                                                            
" -ForegroundColor Cyan
    Write-Host "You are about to create the VMs listed in the CSV with the settings you specified. You cannot easily stop the creation process once it has begun. Ensure your settings are correct and continue."
    pause
    foreach ($vm in $csv) {
        Write-Host "Creating $($vm.Name) with the following settings:" -foreground green
        Write-Host $name $pod $ext $myDatastore $myTemplate $mySpecification $myCluster -foreground cyan
        $name = $vm.Name
        $pod = Get-VirtualNetwork -Name $vm.Network #Comment out if not using per-pod networking.
        $myDatastore = Get-Datastore -Name $vm.Datastore
        $myTemplate = Get-Template -Name $vm.Template
        $myHost = Get-VMHost -Name $vm.Host
        New-VM -Template $myTemplate -Name $name -VMHost $myHost -Datastore $myDatastore -NetworkName $pod,$ext -RunAsync #Remove -ResourcePool flag and/or $pod from -NetworkName if not using them.
    }
    Write-Host "Done! Please check for errors in the output before continuing." -ForegroundColor Green
    Pause
    Caller
}

# Deploy Users by iterating on every newline, taking the username, password, and VM name, creating the user (if applicable), and assigning it admin on its VM.
Function MakeUsers {
    Clear-Host
    Write-Host "
 _______  ______ _______ _______ _______ _______      _     _ _______ _______  ______ _______
 |       |_____/ |______ |_____|    |    |______      |     | |______ |______ |_____/ |______
 |_____  |    \_ |______ |     |    |    |______      |_____| ______| |______ |    \_ ______|
                                                                                                                                                                  
" -ForegroundColor Cyan
    Write-Host "You are about to create the users listed in the CSV with the password you specified. You cannot easily stop the creation process once it has begun. Ensure your settings are correct and continue."
    pause
    foreach ($user in $csv) {
        Write-Host "Creating $($user.Name) with the following linked VMs:" -foreground green
        Write-Host $vm1 $vm2 $vm3
        $uname = $user.Username
        $upass = $user.Password
        $vm = Get-VM -Name $user.Name
        try {
            New-SsoPersonUser -UserName $uname -Password $upass -FirstName $defaultFirstName -LastName $defaultLastName | Set-SsoPersonUser -Group (Get-SsoGroup -Domain $vDomain -Name $defaultStudentGroup) -Add
        }
        catch {
            Write-Host User exists, skipping creation...
        }
        $getuser = Get-VIAccount -User $uname -Domain $vDomain
        New-VIPermission -Role 'Admin' -Principal $getuser -Entity $vm
    }
    Write-Host "Done! Please check for errors in the output before continuing." -ForegroundColor Green
    Pause
    Caller
}

# Create new snapshot of every VM in the CSV by iterating on every newline.
Function MakeSnapshot {
    Clear-Host
    Write-Host "
 _______ __   _ _______  _____  _______ _     _  _____  _______
 |______ | \  | |_____| |_____] |______ |_____| |     |    |   
 ______| |  \_| |     | |       ______| |     | |_____|    |   
                                                               
                                                               
" -ForegroundColor Cyan
    Write-Host "You are about to create a snapshot for every VM listed in the CSV. You cannot easily stop the creation process once it has begun. Ensure your settings are correct and continue."
    pause
    foreach ($vm in $csv) {
        Write-Host "Creating snapshot of $($vm.Name)" -foreground green
        $name = Get-VM -Name $vm.Name
        New-Snapshot -VM $name -Name $snapshotname -Memory $true
    }
    Write-Host "Done! Please check for errors in the output before continuing." -ForegroundColor Green
    Pause
    Caller
}

Function Intro {
    Clear-Host
    Write-Host "
   _    _ _______ _______ __   _ _______ _______  ______      ______    _____    ______   _______   _______   _______    ______  
    \  /  |       |______ | \  |    |    |______ |_____/      |     \     |     |_____/   |______   |            |      |_____/  
     \/   |_____  |______ |  \_|    |    |______ |    \_      |_____/ . __|__ . |    \_ . |______ . |_____  .    |    . |    \_ .
                                                                                                                                 
 " -ForegroundColor Cyan
    Write-Host "Welcome to the vCenter Deployment and Initialization Resource for Education, that Creates vms and users from a Template Repeatedly."
    $vip = Read-Host -Prompt "IP Address or FQDN of vCenter Server"
    $vuser = Read-Host -Prompt "Username@Domain"
    $vpassS = Read-Host "Password" -AsSecureString
    write-host "Connecting to vCenter Server..." -foreground green
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vpassS)
    $vpassP = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    try{ 
        Import-Module $PSScriptRoot\VMWare.vSphere.SsoAdmin\VMWare.vSphere.SsoAdmin.psd1
        Connect-VIServer $vip -user $vuser -password $vpassP -WarningAction 0 
        Connect-SsoAdminServer -Server $vip -user $vuser -password $vpassP -SkipCertificateCheck
        }
    catch{
        Write-Host "Directr was unable to connect to vCenter Server. Please check network connection and server power status. The script will now close."
        pause
        exit
    }
    write-host "Connected!" -foreground green
    Caller
}

Function Caller {
    Write-Host "What would you like to do?" -ForegroundColor Cyan
    $response = Read-Host "(D)eploy new set of VMs   (C)reate new user for every VM   (S)napshot every VM  (E)xit"
    if ($response -like 'd'){MakeVMs}
    elseif ($response -like 'c'){MakeUsers}
    elseif ($response -like 's'){MakeSnapshot}
    elseif ($response -like 'e'){exit}
    else {
        Write-Host "Invalid input."
        Pause
        Caller
    }
}

Intro # GO!

