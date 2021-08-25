<#
It's a draft.
Looking for Mikrotik device with simply checking Winbox port is open.
Could be easily adapted for any port scanning.

#>
$ports = @("8291")
$NetworkAddress = "192.168.0.0"
$NetworkMask = "24"
$IPsToLook = @("1","254")
function LookingForMikrotik ($NetworkAddress, $NetworkMask, $Ports) {
    $IP =
    $test = Test-NetConnection $IP -port $port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        write-host $IP $Port
    }
}

for ($i = 0; $i -lt 255; $i++) {
}

