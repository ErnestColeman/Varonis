$netapphost = temp_hostname
$user = temp_user
$passwd = temp_password
$commandpath = temp_commands

plink.exe $netapphost -l $user -pw $passwd -m $commandpath