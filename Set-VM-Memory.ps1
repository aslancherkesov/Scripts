<#
powershell
Скрипт для назначения выделяемой оперативной памяти виртуальной машине Hyper-V.
Создавалась для выполнения этой операции планировщиком задач:
powershell C:\Scripts\Set-VM-Memory.ps1 -VMname "targetVM" -NewMemorySize 512GB
#>
Param (
[string]$VMname,
$NewMemorySize
)
Stop-VM $VMname
Set-VM $VMname -MemoryStartupBytes $NewMemorySize
Start-VM $VMname
