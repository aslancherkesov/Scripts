
Get-ADComputer -filter {(enabled -eq "True") -and (operatingsystem -notlike "*server*") -and (operatingsystem -like "*windows*")}-properties *|sort name |%{
	$PC_name = $_.dnshostname
	#write-host $pc_name
	if (test-connection $pc_name -count 1 -erroraction silentlycontinue) {
		#Write-host Start $PC_name -foregroundcolor Green
        	Get-WmiObject win32_logicaldisk -filter "drivetype=3" -computername $pc_name|%{
			$letter = $_.deviceID
			$FreespaceGB = [math]::Round(($_.freespace)/(1024*1024*1024),1)
			$sizeGB = [math]::Round(($_.size)/(1024*1024*1024),1)
			$color = "yellow"
			if (($freespaceGB -lt 20) -or ($freespaceGB/$sizegb -lt 1/10)){$color = "red"}
			write-host $pc_name`t$letter`t$freespaceGB`t$sizeGB -foregroundcolor $color
		}
     } else {write-host $pc_name Offline -foregroundcolor yellow}
}

