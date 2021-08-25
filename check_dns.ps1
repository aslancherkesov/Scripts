<#powershell
Скрипт проверяет доступность DNS-сервера.
Планировался как часть набора для диагностики первой линией поддержки а может и конечными пользователями, но не доведено для ума
#>
function Check_DNS_Server ($DNS_Server_Name){
    $response_delay = (Measure-Command {Resolve-DnsName ya.ru -Server $DNS_Server_Name -erroraction silentlycontinue}).Milliseconds
    if (Resolve-DnsName ya.ru -Server $DNS_Server_Name -erroraction silentlycontinue) {
        write-host "Сервер $DNS_Server_Name отвечает, время отклика -" $response_delay мс -ForegroundColor Yellow
        } else {
            Write-host Что-то не так -ForegroundColor Red
            if (Test-Connection $dns_server_name -ErrorAction SilentlyContinue){
                write-host Сервер $DNS_Server_Name пингуется, но не отвечает -ForegroundColor Yellow
                }else {
                    write-host Адрес $DNS_Server_Name не пингуется -ForegroundColor Yellow
                }
        }
}
$DNS_Server_Name = Read-Host("Укажите имя или IP проверяемого сервера")
Check_DNS_Server $DNS_Server_Name