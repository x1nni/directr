# D.I.R.E.C.T.R.
*vCenter **D**eployment + **I**nitialization **R**esource for **E**ducation, that **C**reates vms and users from a **T**emplate **R**epeatedly*

The main purpose of this script is to streamline the process of creating VMs and user accounts for students in a school lab environment. You can specify the name and network settings for each VM, which template it should copy from, which host it should deploy to, as well as the user account and password associated with the VM. The script will then automagically create each VM and each user, giving the user administrative access to only their VM(s). You can also create baseline snapshots of each VM in case someone needs theirs reverted.

## Prerequisites
- Administrative access to a vCenter server
- At least one template that is registered in your inventory (.vmtx)
- [PowerCLI installed](https://developer.vmware.com/powercli/installation-guide)
- If using a self-signed certificate, ``Set-PowerCLIConfiguration -InvalidCertificateAction Ignore``

## Installation
1. Clone this repo or download it as a .zip
2. Open and edit the example csv with a WYSIWYG spreadsheet editor (.e.g. Excel)
3. Save the edited csv as ``directr.csv`` in the same directory as the script
4. Open the script in a text editor and adjust the variables at the top of the file to match your environment
5. Run the script!

## Credits
- [VMPros](https://blog.vmpros.nl/2011/01/16/vmware-deploy-multiple-vms-from-template-with-powercli/)
- [The Sleepy Admins](https://thesleepyadmins.com/2018/09/08/deploy-multiple-vms-using-powercli-and-vmware-template/)
