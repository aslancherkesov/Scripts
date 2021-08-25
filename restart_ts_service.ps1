<#
Перезапускает службу терминального сервера с помощью молотка и зубила. Создавался для запуска по событию
TerminalServices-RemoteConnectionManager	20497
workaround к проблеме зависания этой самой службы (переставала принимать клиентские подключения).
#>
$TS_Service = get-wmiobject win32_service | where { $_.name -eq 'termservice'}
Stop-Process $TS_Service.processID -Force
$recipients = ""
$sender
Send-MailMessage -To $recipients -From $Sender -Body "Выполняется скрипт перезапуска службы ТС" -Subject "Ошибка на терминальном сервере" -SmtpServer openrelay -encoding utf8
start-service termservice
