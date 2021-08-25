<#
Собирает и выводит информацию о VHD на сервере Hyper-V. Версия 0.001.
#>
$VHDs = @()

get-vm|foreach-object{
    $VMName = $_.VMName
    Get-VMHardDiskDrive -VMName $VMname|ForEach-Object{
        if (Test-path $_.path) {
            $VHDProperties = get-vhd $_.path
            $VHD = [PSCustomObject]@{
                VNName = $_.VMName
                Path = $_.Path
                CurrentSize = $VHDProperties.Filesize/1GB
                MaxSize = $VHDProperties.Size/1GB
                Type = $VHDProperties.VHDType
                Format = $VHDProperties.VHDFormat
                ID = $VHDProperties.DiskIdentifier
            }
        } else {
            $VHD = [PSCustomObject]@{
                VNName = $_.VMName
                Path = $_.Path
                Type = 'DISK NOT FOUND'
            }
        }
        $VHDs += $VHD
        $reportfile = $env:Userprofile+"\"+((get-date).DateTime).replace(":","_")+"\vhds.csv"
        Export-Csv -Path $reportfile -InputObject $VHD -Append -Delimiter ',' -NoTypeInformation -force
    }
}
$VHDs|FT -Wrap -AutoSize
        #Заготовка для переноса по определённому условию:
        #$NewStoragePath = "D:\Hyper-V\"+$VMName
        #if (not (Test-Path $NewStoragePath -ErrorAction SilentlyContinue) {mkdir $NewStoragePath}
        #Move-VMStorage -VMName $VMName -DestinationStoragePath $NewStoragePath

