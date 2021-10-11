$server = "DHCP_server_IP_address"
$ScopeId = "network_address"
$namefile = "DHCP_export.txt"

$ip = Get-DhcpServerv4Lease -ComputerName $server -ScopeId $ScopeId | Select-Object -Property IPAddress
$masque = Get-DhcpServerv4Scope -ComputerName $server -ScopeId $ScopeId | Select-Object -Property SubnetMask
$mac = Get-DhcpServerv4Lease -ComputerName $server -ScopeId $ScopeId | Select-Object -Property ClientId
$name = Get-DhcpServerv4Lease -ComputerName $server -ScopeId $ScopeId | Select-Object -Property HostName


$i = 0
$Output = foreach($line in Get-DhcpServerv4Lease -ComputerName $server -ScopeId $ScopeId) {
    if($line -match $regex){
    
        [string]$Replace_IP = $ip[$i]
        $Export_IP = $Replace_IP.replace("@{IPAddress=","").replace("}","")
        [string]$Replace_Masque = $masque
        $Export_Masque = $Replace_Masque.replace("@{SubnetMask=","").replace("}","")
        [string]$Replace_Mac = $mac[$i]
        $Export_Mac = $Replace_Mac.replace("@{ClientId=","").replace("}","")
        [string]$Replace_Name = $name[$i]
        $Export_Name = $Replace_Name.replace("@{HostName=","").replace("}","")

        New-Object -TypeName PSObject -Property @{
            ip = $Export_IP
            masque = $Export_Masque
            mac = $Export_Mac
            name = $Export_Name
        } | Select-Object ip,masque,mac,name
        $i ++
    }
}

$Output | convertto-csv -NoTypeInformation -Delimiter ";" | % {$_ -replace '"',''} | Select-Object -Skip 1 | out-file $namefile