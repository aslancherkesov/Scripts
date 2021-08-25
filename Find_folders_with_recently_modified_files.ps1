#$Folder = "D:\Users"
$report_file = [Environment]::GetFolderPath("Desktop")+"\"+(get-date -Format yyyyMMdd_HHmm)+"\folders_using_report.txt"
function search_fresh_files ($subfolder) {
	$modified = $False
	$skipped_ext = @(".db",".dat",".log",".lnk")
	get-childitem $subfolder -recurse -erroraction silentlycontinue|foreach-object {
		if ((-not $Modified) -and ($_.mode -notlike "d*") -and ($skipped_ext -notcontains $_.extension)) {
			if ((($_.lastwritetime + 200D) -gt (get-date))) {
				$modified = $True
				write-host $_.fullname,`t,new,`t,$_.lastwritetime -foregroundcolor green
			}
		}
	}
	if ($Modified) {
	$result = $subfolder+"`t"+"Modified"
	$result >> $report_file
	write-host $subfolder,`t,Modified
	} else { 
		if ($subfolder.mode -notlike "d*") {
			write-host $subfolder,`t,old -foregroundcolor yellow
			$result = $subfolder+"`t"+"Old"
			$result >> $report_file
			}
		}
}
get-childitem $Folder -erroraction silentlycontinue|foreach-object {
	search_fresh_files $_.fullname
}

