#���� ������� ����, �������� � ��������� ���� ��������.
$date = get-date
$OS = Get-WmiObject win32_operatingsystem
if ($date.month -lt 10) {$month = "0"+$date.month} else {$month = ""+$date.month}
			$year = ""+$date.year
if ($date.day -lt 10) {$day = "0"+$date.day} else {$day = ""+$date.day}
$report_path = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\')."desktop"+"\��������������"
if (test-path $report_path) {} else {new-item -type directory -path $report_path} 

#�������� ��� ���������� �������� ��� ������ ������. ������� ����� �������������� ��� ���������� ������ ������ ������ �������� (��������, ���� ������ 2 ��� ���� � �������� ������ �������, ��� ��� ������������ ������������� ������� �����)
$delimiter = "`t"

$report_file = $report_path + "\��������������_"+$OS.pscomputername+"_"+$year+$month+$day +".csv" #��������� ���� � ����� � �������.

	#OS
$OS_Name = "��� ����������"+$delimiter+$OS.pscomputername >> $report_file
$OS_version = "������ ��"+$delimiter+$OS.caption +","+$OS.BuildNumber+","+$OS.OSArchitecture >> $report_file
$OSInstallDate = "���� ��������� ��"+$delimiter+((Get-WmiObject win32_operatingsystem ).installdate).remove(8) >> $report_file

	#RAM
write-host "memory" #������� �� ����� ����� "memory"
$PC_memSize = 0
$pc_membanksUsed = 0
get-wmiobject -class "Win32_PhysicalMemory"  -ErrorAction SilentlyContinue -warningaction silentlycontinue|foreach-object{
	$PC_memSize+=$_.capacity
	$PC_membanksUsed++
}

$PC_MemsBankTotal = (get-wmiobject Win32_PhysicalMemoryarray ).memorydevices
$PC_MemSize="����� RAM"+$delimiter+$PC_MemSize/1048576 >> $report_file
$pc_memsizemax = "�������� RAM"+$delimiter+(get-wmiobject Win32_PhysicalMemoryarray ).maxcapacity/1024 >> $report_file
$pc_membanksUsed = "������� ������"+$delimiter+$pc_membanksUsed+" �� "+$PC_MemsBankTotal >> $report_file

	#������ ��������� �����
write-host "BaseBoard"
$baseboard = "������ ���������"+$Delimiter+(Get-WmiObject win32_baseboard ).manufacturer + ', ' + (Get-WmiObject win32_baseboard ).product >> $report_file

	#������ ��
write-host "CPU"
$CPU ="������ ��" +$delimiter+(get-wmiobject -class "Win32_processor" ).name >> $report_file

	#HDD
Write-host "HDD"
$DiskCount = 0
$diskinfo = ""
(Get-WmiObject win32_diskdrive |?{$_.caption -notlike "*usb*"}).caption|foreach-object{
	$diskCount++
	$diskcaption = $_
	if ($diskcaption -like "*raid*") {$diskcaption = "Raid LUN"}
	if ($diskcount -gt 1) {$diskinfo+= ", "}
	$diskinfo+= "����"+$diskcount+":"+$diskcaption
}
$Disks = "HDD" + $delimiter+$diskinfo >> $report_file
$Sys_Disk_Free = 0
$low_Space_Disk = $null
$Sys_Disk_Free = ((Get-WmiObject win32_logicaldisk -filter "drivetype=3"|?{$_.deviceid -eq (Get-WmiObject Win32_OperatingSystem ).systemdrive}).freespace)/1073741824 + ""
	Get-WmiObject win32_logicaldisk -filter "drivetype=3"|foreach-object{
		if(($_.freespace -lt 10737418240) -and ($_.freespace -ne $null)) {
			$low_Space_Disk = $low_Space_Disk+$_.deviceid+($_.freespace)/1073741824+";"
		}
	}
if ($low_Space_Disk -eq $null) {$low_Space_Disk = "��� �����"}
$Sys_Disk_Free = "�������� �� ��������� �����, ��" +$Delimiter + $Sys_Disk_Free >> $report_file
$low_Space_Disk = "����� � ��������� �����" +$Delimiter+$low_Space_Disk >> $report_file


