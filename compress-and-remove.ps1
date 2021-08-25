<#
Compressing files from specified folder(s) with specified extension and age using 7-zip. If success then original file is removing.
Probably better to use Compress-Archive cmdlet, but script was designed for Windows Server 2003 which doesn't have those one.
Have no sense for SQL Backups compressed by SQL server while creating. This option available not at all versions lf MS SQL Server.
#>

$Ext =".bak"
$ArchiveExt = ".zip"
Function compressbak ($path,$Depth) {
	get-childitem $path -recurse|foreach-object{
		if (($_.extension -eq $Ext) -and (($_.creationtime.AddDays($Depth)) -lt (get-date))) {
			$fullname = $_.fullname
			#$Timestamp = get-date ($_.creationtime) -Format yyyy_MM_dd
			$archivename = ($_.fullname).replace($Ext,$ArchiveExt)
			write-host Добавление $_.fullname в архив $archivename
			& 'C:\Program Files\7-Zip\7z.exe' a $archivename $fullname
			$archivestate = & 'C:\Program Files\7-Zip\7z.exe' t $archivename
			 if ($archivestate -like "*Everything is Ok*") {
				write-host $archivename "OK, removing original file" $fullname -foregroundcolor yellow
				remove-item $fullname -force
			} else {write-host $archivename BAD -foregroundcolor red}
		}
	}
}

#compressbak U:\SQL\Monthly 185
#compressbak U:\SQL\Weekly 30
#compressbak U:\SQL\Quartal 366
#compressbak U:\SQL\Daily 1

