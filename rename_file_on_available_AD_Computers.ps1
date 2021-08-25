<#
Скрипт лепился на скорую руку для экстренного закрытия какой-то уязвимости нулевого дня. Хранится как память.
#>
function rename_files ($directories,$filenames,$modificator) {
    $report_folder = "C:\Scripts\"
    $report_file = $report_folder+$env:COMPUTERNAME+"_report.txt"
    if (-NOT (test-path $report_folder)) {
        mkdir $report_folder -ErrorAction SilentlyContinue
    }
    $to_rename = @() #
    foreach ($filename in $filenames){
        foreach ($directory in $directories) {
            $to_rename+=$directory+$filename
        }
    }

    foreach ($path in $to_rename) {
        if (test-path $path -ErrorAction SilentlyContinue){
                $new_name = (Get-Item $path).name + $modificator
                Rename-Item $path $new_name
                echo $path`t"renamed to"`t$new_name >> $report_file
            } else {
                echo $path`t"not found" >> $report_file
            }
        }
}

$filenames = @("ATMFD.DLL","ATMLIB.DLL")
$directories = @("c:\windows\system32\","c:\windows\Syswow64\")
$modificator = ".bkp"
rename_files $directories $filenames $modificator

        
<#Get-ADComputer -filter {(enabled -eq "True") -and (operatingsystem -like "*windows*")} -properties *|sort name |%{
    $PC_name = $_.dnshostname
	if (test-connection $pc_name -count 1 -erroraction silentlycontinue) {
        Нужно добавить проверку, что систамная папка - c:\windows.
        $system32="\\"+$PC_name+"\c$\windows\system32\"
        $syswow64="\\"+$pc_name+"\c$\windows\syswow64\"
        $filename_7="ATMFD.DLL"
        $filename_10="ATMLIB.DLL"
        $path_7_32=$system32+$filename_7
        $path_7_64=$syswow64+$filename_7
        $path_10_32=$system32+$filename_10
        $path_10_64=$syswow64+$filename_10
    } else {
        write-host $pc_name Offline -foregroundcolor yellow
        }
}
#>


