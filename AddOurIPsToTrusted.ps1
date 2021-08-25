<#powershell
Добавляем IP-адреса, перечисленные в нашей DNS-зоне в свой RBL для использовавния в качестве IPAllowListProvider
Добавляем задачу в планировщик на DNS-сервере обслуживающем данную зону.
#>

#Очистка неактуальных записей в 3 часа ночи
$Zone = "domain.com"
if ((Get-Date).TimeOfDay.Hours -eq 3) {
    Get-DnsServerResourceRecord -ZoneName $zone | Where-Object {$_.Hostname -like "*.trusted.domain.com"}
}

function AddReverseIPToTrusted ($IP) {
    Write-Host $IP -ForegroundColor Yellow
    $IPreversed = ""
    for ($index = 3; $index -ge 0; $index--) {
        $IPtoArray = $IP.Split(".")
        $IPreversed += $IPtoArray[$index] + "."
    }
    $ARecord = $IPreversed + "trusted"
    Write-Host $ARecord
    Add-DnsServerResourceRecordA -Name $ARecord -IPv4Address 127.0.0.1 -ErrorAction SilentlyContinue -ZoneName $Zone #-WhatIf
}

(Get-DnsServerZone).ZoneName | ForEach-Object {
    (Get-DnsServerResourceRecord -RRType A -ZoneName $_).RecordData.IPv4Address | ForEach-Object {
        if ($null,"127.0.0.1" -notcontains $_) {
            AddReverseIPToTrusted $_.ToString()
        }
    }

}
