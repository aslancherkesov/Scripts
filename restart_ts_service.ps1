<#
������������� ������ ������������� ������� � ������� ������� � ������. ���������� ��� ������� �� �������
TerminalServices-RemoteConnectionManager	20497
workaround � �������� ��������� ���� ����� ������ (����������� ��������� ���������� �����������).
#>
$TS_Service = get-wmiobject win32_service | where { $_.name -eq 'termservice'}
Stop-Process $TS_Service.processID -Force
$recipients = ""
$sender
Send-MailMessage -To $recipients -From $Sender -Body "����������� ������ ����������� ������ ��" -Subject "������ �� ������������ �������" -SmtpServer openrelay -encoding utf8
start-service termservice
