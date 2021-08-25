<#
Скрипт делался для того чтобы
1) иметь актуальную информацию о железе в читаемом и людьми и БД формате
2) менеджеры имели информацию об использовании учётных записей пользователей и компьютеров(для отчётов в Microsoft по SPLA)
3) отслеживать мёртвые души - уволенные сотрудники, об увольнении которых нам забыли сообщить.
По-хорошему, давно можно было переписать с использованием кастомных объектов, но работает и поэтому не тратил время на доработку.
Где-то скачет стиль оформления (в первую очередь отступы), ибо писался скрипт когда я только учился, а потом допиливался по мере надобности.
#>
import-module activedirectory #для забывчивых, запускающих обычный пош
#Берём текущую дату, парсим её.
$date = get-date
if ($date.month -lt 10) {$month = "0"+$date.month} else {$month = ""+$date.month}
			$year = ""+$date.year
if ($date.day -lt 10) {$day = "0"+$date.day} else {$day = ""+$date.day}
$report_path = (get-itemproperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\')."common desktop"+"\Инвентаризации"
if (test-path $report_path) {} else {new-item -type directory -path $report_path}

#обзываем точку с запятой - запятой >.< будет нужна для разделения значений при выводе данных. Запятые будут использоваться для разделения текста внутри одного значения (например, если дисков 2 или если в описании учётки запятая, или для перечисления характеристик сетевой карты)
$comma = "`t"
#опись учётных записей пользователей
$file_users =  $report_path + "\Инвентаризация_АД_пользователи"+$year+$month+$day +".csv"
$result = "Полное имя"+$comma+"Компьютер/ноутбук/комментарий"+$comma+"Имя"+$comma+"Фамилия"+$comma+"Эл. почта"+$comma+"Телефон"+$comma+"Должность"+$comma+"Отдел"+$comma+"Компания"+$comma+"Дата создания"+$comma+"Последний вход"+$comma+"Enabled"+$comma+"Доступ к VPN"+$comma+"Логин"
$result>>$file_users
get-aduser -filter {name -notlike "HealthMailbox*"} -properties *|sort name|%{
	if ($_.created -eq $null) {$createdate = "-"} else {$createdate = get-date $_.created -format d}
	if ($_.lastlogondate -eq $null) {$lastlogondate = "-"} else {$lastlogondate = get-date $_.lastlogondate -format d}
	if ($_.memberof -like "*VPN*") {$vpn = "Да"} else {$vpn = "Нет"}
	$result = $_.name+$comma+$_.description+$comma+$_.givenname+$comma+$_.surname+$comma+$_.mail+$comma+$_.officephone+$comma+$_.title+$comma+$_.department+$comma+$_.company+$comma+$createdate+$comma+$lastlogondate+$comma+$_.enabled+$comma+$vpn+$comma+$_.SamAccountName
	$result=$result.replace("True","Да")
	$result=$result.replace("False","Нет")
	$result>>$file_users
}


#опись учётных записей компьютеров
$file_computers = $report_path + "\Инвентаризация_АД_компьютеры"+$year+$month+$day +".csv"
#описываем параметры и делаем из них заголовок
$pcname = "Имя"
$description = "Описание"
$createdate = "Дата создания"
$lastlogondate = "Lastlogondate"
$enabled = "Enabled"
$OS = "ОС"
$NetStatus = "Онлайн?"
$Username = "Залогинен сейчас"
$OS_Build = "Билд ОС"
	$result = $pcname+$comma+$description+$comma+$createdate+$comma+$lastlogondate+$comma+$enabled+$comma+$oS+$comma+$NetStatus+$comma+$Username+$comma+$OS_Build
	$result>>$file_computers
Get-ADComputer -filter {operatingsystem -like "windows*"} -properties *|sort name |%{
	$PCname = $_.name
	$NetStatus = "Offline"
	$username = ""
	$OS = $_.operatingsystem
	$OS_Build = ""
	if (test-connection $pcname -count 1 -ea silentlycontinue) {$OS_Build = (Get-WmiObject Win32_OperatingSystem -computername $pcname).buildnumber}
	$description = $_.description
	if ($_.created -eq $null) {$createdate = "-"} else {$createdate = get-date $_.created -format d}
	if ($_.lastlogondate -eq $null) {$lastlogondate = "-"} else {$lastlogondate = get-date $_.lastlogondate -format d}
	$Enabled = $_.enabled
	if (($enabled -eq "$True") -and ($OS -notlike "*server*")) {
		if (test-connection $pcname -count 2 -erroraction silentlycontinue) {
			$NetStatus = "Online"
			$hostname = Get-WmiObject Win32_ComputerSystem –Computer $pcname -erroraction silentlycontinue
			$userName = $hostname.UserName
		}
	}

	$result = $pcname+$comma+$description+$comma+$createdate+$comma+$lastlogondate+$comma+$enabled+$comma+$oS+$comma+$comma+$NetStatus+$comma+$Username+$comma+$os_build
	$result>>$file_computers
}

#опись железа
$file_hardware = $report_path + "\Инвентаризация_железа_"+$year+$month+$day +".csv"
$paramcount=1
#Определяем характеристики оперативной памяти
$paramcount++
$paramcount++
Function memory ($PC_number,$PC_name) {
#Ищем объём оперативки и количество модулей
write-host "memory" #поможет выявить, на каком этапе сбой, если он возникнет
$PC_memSize = 0
$pc_membanksUsed = 0
get-wmiobject "Win32_PhysicalMemory" -computername $pc_name -ErrorAction SilentlyContinue -warningaction silentlycontinue|%{
$PC_memSize+=$_.capacity
$PC_membanksUsed++
$pc_memspeed = $_.speed
}
$PC_memSizeMax = (get-wmiobject Win32_PhysicalMemoryarray -computername $pc_name).maxcapacity/1024
$PC_MemoBankTotal = (get-wmiobject Win32_PhysicalMemoryarray -computername $pc_name).memorydevices
$PC_MemSize/=1048576
$results[$pc_number,3] = "$pc_memsize"+"/"+"$PC_memSizeMax"
$results[$pc_number,4] = "$pc_membanksUsed"+" из "+"$PC_MemoBankTotal"
$results[$pc_number,8] = $pc_memspeed
}
#Модель системной платы
$paramcount++
Function motherboard ($PC_number,$PC_name) {
write-host "BaseBoard"
$results[$pc_number,5] = (Get-WmiObject win32_baseboard -computername $pc_name).manufacturer + ', ' + (Get-WmiObject win32_baseboard -computername $pc_name).product
}
#Модель ЦП
$paramcount++
Function CPU ($PC_number,$PC_name) {
write-host "CPU"
$results[$pc_number,6] = (get-wmiobject -class "Win32_processor" -computername $pc_name).name
}
#HDD
$paramcount++
Function HDD ($pc_number,$PC_name) {
Write-host "HDD"
$diskinfo = ""
$DiskCount = 0
(Get-WmiObject win32_diskdrive -computername $pc_name|?{$_.caption -notlike "*usb*"}).caption|%{
$diskCount++
$diskcaption = $_
if ($diskcaption -like "*raid*") {$diskcaption = "Raid LUN"}
if ($diskcount -gt 1) {$diskinfo+= ", "}
$diskinfo+= "Диск"+$diskcount+": "+$diskcaption
}
$results[$pc_number,7] = $diskinfo
}
#Монитор
$paramcount++
Function Display ($PC_number,$PC_name) {
write-host "Display"
$results[$pc_number,8] = (Get-WmiObject Win32_DesktopMonitor -computername $PC_name| ? {$_.PNPDeviceID -like "Display\*"}).PNPDeviceID
}
$paramcount++
Function InstallDate ($PC_number,$PC_name) {
$results[$pc_number,9] = ((Get-WmiObject win32_operatingsystem -computername $pc_name).installdate).remove(8)
}
# Ethernet
Function NIC ($PC_number,$PC_name) {
	write-host "NIC"
	Get-WmiObject win32_networkadapter -computername $pc_name|?{($_.adaptertype -like "ethernet*") -and ($_.name -notlike "Kerio*") -and ($_.speed -like "10000000*")}| %{
		$adapter = $_.name
		$speed = ($_.speed)/1000000
	#write-host $adapter $speed
	}
	$results[$pc_number,10] = $adapter+";"+$speed
}

Function DiskSpace ($pc_number,$pc_name) {
	write-host "DiskSpace"
	$results[$pc_number,11] = ((Get-WmiObject win32_logicaldisk -filter "drivetype=3" -computername $pc_name|?{$_.deviceid -eq (Get-WmiObject Win32_OperatingSystem -computername $pc_name).systemdrive}).freespace)/1GB + ""
	Get-WmiObject win32_logicaldisk -filter "drivetype=3" -computername $pc_name|foreach-object{
		if(($_.freespace -lt 20737418240) -and ($_.freespace -ne $null)) {
			$results[$pc_number,12] = $results[$pc_number,12]+$_.deviceid+($_.freespace)/1GB+";"
		}
	}
}
#Выводим массив с результатом на экран
Function ScreenResult ($array,$stolb){
$strok = (($array).length)/$stolb
for ($n=0; $n -lt $strok; $n++) {
$result = ""
	for ($r=0; $r -lt $stolb; $r++) {
		$result = $result + $results[$n,$r] + $comma
	}
$result >> $file_hardware
}
#write-host "$result" #Без кавычек массив будет выведен в столбик.
write-host "Данные выведены на рабочий стол в файл"
}
###############################################################################
#Let's go!
###############################################################################
# Определяем выходной массив в зависимости от числа искомых параметров и компьютеров:
# 0) Номер компьютера
# 1) Имя компьютера
# 2) Доступен?
# 3) Объём оперативной
# 4) Количество занятых слотов
# 5) Модель системной платы
# 6) Модель ЦП
# 7) Модель HDD
# 8) Частота RAM
# 9) Дата установки ОС
# 10) Сетевая карта
# 11) Свободно на системном, ГБ
# 12) Диски с нехваткой места
#Значение переменной Columns - количество столбцов в таблице с результатами - назначаем с учётом того, что отсчёт элементов (как и индексы в массиве) с нуля.
$columns = 13
write-host "Сбор параметров"
#Считаем сколько в АД включённых учёток компьютеров:
$PC_NumberOf=1
#нумерация строк, как и столбцов, начинается с 0, но я здесь беру начальным значением 1, т.к. в нулевой строке будет заголовок таблицы.
#Непосредственно подсчёт:
Get-ADComputer -filter {(enabled -eq "true") -and (operatingsystem -like "*windows*")}| sort name |%{$PC_NumberOf++}
Write-host "Количество компьютеров:" $pc_numberof
#Создаём массив для вывода данных:
$results = new-object "object[,]" ($pc_numberof),($columns)
#Обнулять массив не нужно. Даже если такой массив использовался, new-object убивает хвосты.
$results[0,0] = "№"
$results[0,1] = "Имя"
$results[0,2] = "Доступен?"
$results[0,3] = "Объём RAM"
$results[0,4] = "Занятых слотов"
$results[0,5] = "Модель материнки"
$results[0,6] = "Модель ЦП"
$results[0,7] = "Модель HDD"
$results[0,8] = "Частота RAM"
$results[0,9] = "Дата установки ОС"
$results[0,10] = "Ethernet"
$results[0,11] = "Свободно на системном, ГБ"
$results[0,12] = "Диски с нехваткой места"
###############################################################################
#Начинаем собирать данные
$i=0
Get-ADComputer -filter {(enabled -eq "true") -and (operatingsystem -like "*windows*")}| sort name |%{
$i++
$results[$i,0]=$i
$results[$i,1]=$_.name
if (test-connection $_.name -count 1 -ea silentlycontinue) {
	write-host "Сбор информации по" $_.name -foregroundcolor yellow
	$results[$i,2] = "Да"
	memory $results[$i,0] $results[$i,1]
	cpu $results[$i,0] $results[$i,1]
	motherboard $results[$i,0] $results[$i,1]
	hdd $results[$i,0] $results[$i,1]
	installdate $results[$i,0] $results[$i,1]
	NIC $results[$i,0] $results[$i,1]
	diskspace $results[$i,0] $results[$i,1]
}
else {$results[$i,2] = "Offline"}
}
#Выводим данные в файл:
screenresult $results $columns

#Опись офисов
$file_office = $report_path + "\Инвентаризация_Microsoft_Office_"+$year+$month+$day +".csv"
Function getofficevertion ($pcname) {
$pr_files_x86 = "\\"+$pcname+"\c$\Program Files (x86)\"
$pr_files = "\\"+$pcname+"\c$\Program Files\"
$MS_Office = ""
$O_Office = ""
if (test-path $pr_files_x86) {get-childitem $pr_files_x86|foreach-object{
	if (($_.name -like "OpenOffice*") -or ($_.name -like "Libre*")) {$O_Office = $O_Office + $_.name}
	}
}
get-childitem $pr_files|foreach-object{
	if (($_.name -like "OpenOffice*") -or ($_.name -like "Libre*")) {$O_Office = $O_Office + $_.name}
}
$MS_Office = $MS_Office + (get-wmiobject Win32_Product -computername $pcname|where-object {$_.name -like "microsoft office standard*" -or $_.name -like "microsoft office profess*" -or $_.name -like "microsoft office start*" -or $_.name -like "microsoft office для*"}).name
$officeHB16path_32 = $pr_files_x86+"Microsoft Office\root\Office16\winword.exe"
$officeHB16path_64 = $pr_files+"Microsoft Office\root\Office16\winword.exe"
if ((test-path $officeHB16path_32) -or (test-path $officeHB16path_64)) {$MS_Office = $MS_Office + "Microsoft Office 2016 для дома и бизнеса"}
$officeHB13path_32 = $pr_files_x86+"Microsoft Office\root\Office15\winword.exe"
$officeHB13path_64 = $pr_files+"Microsoft Office\root\Office15\winword.exe"
if ((test-path $officeHB13path_32) -or (test-path $officeHB13path_64)) {$MS_Office = $MS_Office + "Microsoft Office 2013 для дома и бизнеса"}
$result_office = $pcname + $comma + $MS_Office + $comma + $O_Office + $comma + "online"
write-host $result_office
$result_office >> $file_Office
}
get-adcomputer -filter {(enabled -eq "true") -and (operatingsystem -like "*windows*") -and (operatingsystem -notlike "*server*")}|sort name|%{
if (test-connection $_.name -erroraction silentlycontinue) {getofficevertion $_.name} else {write-host $_.name";;offline" -foregroundcolor yellow}
}

#Сжимаем старые
Function compressold ($path) {
	get-childitem $path -recurse|%{
		if (($_.extension -ne ".zip") -and (($_.creationtime + 8D) -lt (get-date)) -and ($_.mode -eq "-a----")) {
			if (($_.creationtime).day -lt 10) {$creationday = "0"+($_.creationtime).day} else {$creationmonth = ""+($_.creationtime).day}
			if (($_.creationtime).month -lt 10) {$creationmonth = "0"+($_.creationtime).month} else {$creationmonth = ""+($_.creationtime).month}
			$creationyear = ""+($_.creationtime).year
			$archivename = $path+"\"+$creationYear+"_"+$creationMonth+".zip"
			write-host Добавление $_.fullname в архив $archivename
			& 'C:\Program Files\7-Zip\7z.exe' a $archivename $_.fullname
			$archivestate = & 'C:\Program Files\7-Zip\7z.exe' t $archivename
			if ($archivestate -contains "Everything is Ok") {
				write-host $archivename "OK, удаляем" $_.fullname -foregroundcolor yellow
				remove-item $_.fullname -force
			} else {write-host $archivename BAD -foregroundcolor red}
		}
	}
}
compressold $report_path
#Отправляем актуальные по почте.
$reports = $file_users,$file_computers,$file_hardware,$file_Office
$encoding = [System.Text.Encoding]::UTF8
$subj = "Инвентаризация от "+ (get-date -format D)
$domain = (get-addomain).dnsroot
$sender = $domain+"@alerts.domain.com"
send-mailmessage -smtpserver openrelay -to "aslan@domain.com" -from $sender -subject $subj -body "Во вложении опись компьютеров, пользователей, железа и пакетов Office. Последняя может быть не точна." -attachments $reports -encoding $encoding
###############################################################################
#THE END!#

