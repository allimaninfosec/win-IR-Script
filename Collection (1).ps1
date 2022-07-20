#######Writen by Matt Alliman
#Requires -RunAsAdministrator
$Global:computer_name = $env:COMPUTERNAME
$Global:grab_logs = "System","Application", "Application", "Security"
$Global:CurrentCOL = "Start"
$Global:save_Location
$Global:Case_ID
function gather_DT(){
   (Get-Date).ToUniversalTime()
}
function COL_SYSinfo {
    ##Collect System Information##
    ##OS information##
    log_me("sys_info")
    Get-ComputerInfo | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_compinfo.csv"
    log_me("sys_info")
}
function col_services{
    ##Collect Running Services##
    log_me("services")
    Get-Service | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_services.csv"
    log_me("services")
}
function col_tasks{
    ##Collect Scheduled Tasks##
    log_me("task_pulled")
    $tasks = Get-ScheduledTask | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_task.csv"
    foreach ($task in $tasks){
        Get-ScheduledTaskInfo -TaskPath $task.TaskPath -TaskName $task.TaskName | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_taskdetails.csv"
    }
    log_me("task_pull")
}
function col_local_user_group {
    log_me("user_info")
    ##Collect System Accounts
    Get-LocalUser | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_users.csv"
    ##Collect System Groups
    $groups = Get-LocalGroup
    $groups | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_groups.csv"
    foreach($group in $groups){
        Write-Host $group
        Get-LocalGroupMember -Group $group
    }
    log_me("user_info")
}

function col_network {
    log_me("network_Pull")
  ## Collect Network Detail
  Get-NetAdapter | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_NIC.csv"
  Get-NetIPConfiguration | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_ipadd.csv"
  ## Collect Routing Table 
  Get-NetRoute | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_routing.csv"
  ##Collect Arp Table
  Get-NetNeighbor -IncludeAllCompartments | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_arp.csv"
  ## Collect DNS Cache 
  Get-DnsClientCache | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_dns.csv"
  ##Collect Network COnnections
  Get-NetTCPConnection | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_net_connections.csv"
  log_me("network_pull")
}
function col_drivers{
    ##Collect Loaded Drivers/ Modules
    log_me("drivers")
    Get-WindowsDriver -Online -All | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_drivers.csv"
    Get-Module | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_module.csv"
    log_me("drivers")
}

function col_handles{
    log_me("handles")
    ##Collect File and Hndles
    Get-CimInstance Win32_Thread | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_handle.csv"
    log_me("handles")
}
function get_Proc{
    ##Process List
    log_me("proc")
    Get-Process | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_proc.csv"
    log_me("proc")
}
##System Config Data##
function col_logs{
    foreach($log in $Global:grab_logs){
        log_me("Collecting $log")
        Get-EventLog -LogName $log | Export-Csv -path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_Events_"$log".csv"
        log_me("Collecting $log")
    }
}
function col_software(){
    ##Installed Software
    log_me("Gather Software")
    Get-Package | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_software.csv"
    log_me("Gather Software")
}
function log_me($process){
    $dt = gather_DT
    Write-Host = $Global:CurrentCOL
    if ($Global:CurrentCOL -ne $process){
        Add-Content -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_log.log" -Value "$dt - Start - $process" 
    }
    else{
        Add-Content -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_log.log" -Value "$dt - Complete - $process"
    }
    $Global:CurrentCOL = $process
}

function file_structure{
    log_me("files_system")
    ##File system including timestamp
    Get-ChildItem -Recurse -Path c:\ | Export-Csv -Path $Global:save_Location\$Global:Case_ID"_"$Global:computer_name"_files.csv"
    log_me("files_system")
}
$Global:Case_ID = $args[0]
$Global:save_Location = $args[1]
Write-Host $Global:save_Location
write-host $Global:Case_ID
#####Starting Process#####
get_Proc
col_network
COL_SYSinfo
col_handles
col_drivers
col_tasks
col_services
col_logs
col_software
col_local_user_group
