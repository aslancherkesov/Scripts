#Берём текущую дату, приводим к понятному виду ГГГГММДД.
$date = get-date
$OS = Get-WmiObject win32_operatingsystem
if ($date.month -lt 10) {$month = "0"+$date.month} else {$month = ""+$date.month}
			$year = ""+$date.year
if ($date.day -lt 10) {$day = "0"+$date.day} else {$day = ""+$date.day}
$report_path = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\')."desktop"+"\Инвентаризации"
if (test-path $report_path) {} else {new-item -type directory -path $report_path} 

#обзываем для разделения значений при выводе данных. Запятые будут использоваться для разделения текста внутри одного значения (например, если дисков 2 или если в описании учётки запятая, или для перечисления характеристик сетевой карты)
$delimiter = "`t"

$report_file = $report_path + "\Инвентаризация_"+$OS.pscomputername+"_"+$year+$month+$day +".csv" #Формируем путь к файлу с отчётом.

	#OS
$OS_Name = "Имя компьютера"+$delimiter+$OS.pscomputername >> $report_file
$OS_version = "Версия ОС"+$delimiter+$OS.caption +","+$OS.BuildNumber+","+$OS.OSArchitecture >> $report_file
$OSInstallDate = "Дата установки ОС"+$delimiter+((Get-WmiObject win32_operatingsystem ).installdate).remove(8) >> $report_file

	#RAM
write-host "memory" #выводим на экран текст "memory"
$PC_memSize = 0
$pc_membanksUsed = 0
get-wmiobject -class "Win32_PhysicalMemory"  -ErrorAction SilentlyContinue -warningaction silentlycontinue|foreach-object{
	$PC_memSize+=$_.capacity
	$PC_membanksUsed++
}

$PC_MemsBankTotal = (get-wmiobject Win32_PhysicalMemoryarray ).memorydevices
$PC_MemSize="Объём RAM"+$delimiter+$PC_MemSize/1048576 >> $report_file
$pc_memsizemax = "Максимум RAM"+$delimiter+(get-wmiobject Win32_PhysicalMemoryarray ).maxcapacity/1024 >> $report_file
$pc_membanksUsed = "Занятых слотов"+$delimiter+$pc_membanksUsed+" из "+$PC_MemsBankTotal >> $report_file

	#Модель системной платы
write-host "BaseBoard"
$baseboard = "Модель материнки"+$Delimiter+(Get-WmiObject win32_baseboard ).manufacturer + ', ' + (Get-WmiObject win32_baseboard ).product >> $report_file

	#Модель ЦП
write-host "CPU"
$CPU ="Модель ЦП" +$delimiter+(get-wmiobject -class "Win32_processor" ).name >> $report_file

	#HDD
Write-host "HDD"
$DiskCount = 0
$diskinfo = ""
(Get-WmiObject win32_diskdrive |?{$_.caption -notlike "*usb*"}).caption|foreach-object{
	$diskCount++
	$diskcaption = $_
	if ($diskcaption -like "*raid*") {$diskcaption = "Raid LUN"}
	if ($diskcount -gt 1) {$diskinfo+= ", "}
	$diskinfo+= "Диск"+$diskcount+":"+$diskcaption
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
if ($low_Space_Disk -eq $null) {$low_Space_Disk = "Нет таких"}
$Sys_Disk_Free = "Свободно на системном диске, ГБ" +$Delimiter + $Sys_Disk_Free >> $report_file
$low_Space_Disk = "Диски с нехваткой места" +$Delimiter+$low_Space_Disk >> $report_file


