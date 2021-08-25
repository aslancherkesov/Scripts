<#
Stopping specified service on available Active Directory computers
Appliciable if you need to do it only once or immediately, instead of changing GPO and waiting for 
#>
function disable_and_stop ($ServiceName, $pc){
    if(Get-Service $serviceName -ComputerName $pc -ErrorAction SilentlyContinue){
        $ServiceStatus = Get-Service $ServiceName -ComputerName $pc -ea silentlycontinue
        if ($ServiceStatus.StartType -ne "Disabled") {
            #write-host служба включена, попытка отключения
            Set-Service $ServiceName -ComputerName $pc -StartupType Disabled
            }
        if ($ServiceStatus.Status -ne "Stopped"){
            #write-host служба запущена, попытка остановки
            $ServiceStatus.Stop()
            }
        $ServiceStatus|ft machinename,name,status,starttype -HideTableHeaders -auto -wrap
    } else {write-host Error`t"На компьютере $PC служба $service не найдена" -foregroundcolor darkyellow}
}

$PC = read-host('Имя компьютера?
    0: localhost
    1: Ввести вручную
    2: Взять из Active Directory
Введите цифру')
$service = read-host ('Имя службы?
Введите имя')

if ($pc -eq "0") {
    $PC = 'localhost'
    disable_and_stop $service $pc
    }
    elseif ($pc -eq '1') {$pc = read-host('Введите имя компьютера')
        if (Test-Connection $pc) {
           disable_and_stop $service $pc
        } else {write-host Error,`t,"Компьютер $pc не доступен"}
    }
        elseif ($pc -eq "2") {
            $filter = read-host('Какие компьютеры AD?
                0: Все-все доступные
                1: Все доступные серверы
                2: Все доступные рабочие станции
            Выберите вариант')
            if ($filter -eq "1") {
                $filter = '(enabled -eq "True") -and (operatingsystem -like "*server*")'
                    } elseif ($filter -eq "2") {
                        $filter = '(enabled -eq "True") -and (operatingsystem -like "*windows*") -and (operatingsystem -notlike "*server*")'
                        } else {
                            $filter = '(enabled -eq "True")'
                            }
            get-adcomputer -filter $filter|sort name|%{
		        disable_and_stop $service $_.dnshostname
		        #write-host $_.dnshostname
		    }
        }