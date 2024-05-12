$name = "WireGuard"
$path = "$Env:ProgramFiles\$name"
$exec = "$path\$name.exe"

$ErrorActionPreference = "SilentlyContinue"

function set-window {
	param(
		[int]$cpid = $PID
	)
	$ErrorActionPreference = "SilentlyContinue"
	$ncmd = "nircmd.exe"
	if (!(Test-Path -Path "$Env:Temp\$ncmd")) { Start-BitsTransfer -Source "https://github.com/ssokka/Windows/raw/master/Tool/$ncmd" -Destination "$Env:Temp\$ncmd" }
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$cpid'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $cpid).MainWindowHandle }
	if (Test-Path -Path "$Env:Temp\$ncmd") { ("normal", "activate", "center") | ForEach-Object { & "$Env:Temp\$ncmd" win $_ handle $hwnd } }
}

function smb {
	$reg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
	$smb = foreach($row in Get-SmbMapping){
		$key = Join-Path -Path $reg -ChildPath ($row.RemotePath -replace '\\', '#')
		[pscustomobject]@{
			Status = $row.Status
			RemotePath = $row.RemotePath
			LocalPath = $row.LocalPath
			Label = Get-ItemPropertyValue -Path $key -Name "_LabelFromReg" -ErrorAction SilentlyContinue
		}
	}
if ($smb) { ($smb | Sort-Object -Property LocalPath | Out-String).Trim("`r","`n") }
}

function on {
	if (!(Test-Path -Path $exec)) { exit }
	set-window
	
	#$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName.ToUpper()
	$host.ui.RawUI.WindowTitle = "$name On"
	Write-Host "`n### $name On" -ForegroundColor Green

	Write-Host "`n# 서비스 확인" -ForegroundColor Blue
	$sname = "WireGuardManager"
	if (!(Get-Service -Name $sname -ErrorAction Ignore)) {
		Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath $exec -ArgumentList "/installmanagerservice"
		do {
			Start-Sleep -Milliseconds 250
		} until (Get-Service -Name $sname)
		(Get-Process | Where-Object { $_.ProcessName -eq "wireguard" -and $_.MainWindowTitle -eq "WireGuard" }).Kill()
	}
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "failure $sname reset= 0 actions= restart/0/restart/0/restart/0"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "start $sname"
	do {
		Start-Sleep -Milliseconds 250
	} until ((Get-Service -Name $sname).Status -eq "Running")
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath takeown.exe -ArgumentList "/f `"$path\Data`" /r /d y"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath icacls.exe -ArgumentList "`"$path\Data`" /grant ${Env:UserName}:f /t"
	Get-ChildItem -Path "$path\Data\Configurations\*.dpapi" | ForEach-Object {
		if($_) {
			$sname = "WireGuardTunnel`$$($_ -replace '.*\\(.*)\.conf.*','$1')"
			if (!(Get-Service -Name $sname -ErrorAction Ignore)) {
				Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath $exec -ArgumentList "/installtunnelservice `"$_`""
				do {
					Start-Sleep -Milliseconds 250
				} until (Get-Service -Name $sname)
			}
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "failure $sname reset= 0 actions= restart/0/restart/0/restart/0"
		}
	}
	
	Write-Host "`n# 서비스 시작" -ForegroundColor Blue
	(Get-Service -Name "WireGuardTunnel`$*" -ErrorAction Ignore).Name | ForEach-Object {
		if($_) {
			$_
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "start `"$_`""
			do {
				Start-Sleep -Milliseconds 250
			} until ((Get-Service -Name "$_").Status -eq "Running")
		}
	}
	
	$file = "$path\*-drive.cmd"
	if(Test-Path -Path $file) {
		Write-Host "`n# 네트워크 드라이브 연결" -ForegroundColor Blue
		Get-ChildItem $file | ForEach-Object { Start-Process -NoNewWindow -Wait -FilePath $_ }
		#(Get-SmbMapping | Sort-Object | Format-Table -Force | Out-String).Trim("`r","`n")
		smb
	}
	
	Write-Host
	foreach ($i in 5..1) { Write-Host "`r${i}초 후 자동 닫힘" -NoNewline; Start-Sleep 1 }
}

function off {
	if (!(Test-Path -Path $exec)) { exit }
	set-window
	
	$host.ui.RawUI.WindowTitle = "$name Off"
	Write-Host "`n### $name Off" -ForegroundColor Green
	
	Write-Host "`n# 네트워크 드라이브 연결 끊기" -ForegroundColor Blue
	(Get-NetIPAddress -InterfaceAlias "wg*").IPAddress -replace '(.*\.).*', '$1' | ForEach-Object { (Get-SmbMapping -RemotePath "*$_*").LocalPath } | Sort-Object | ForEach-Object { if ($_) { $null = net use $_ /delete /y 2>$null } }
	smb
	
	Write-Host "`n# 서비스 중지" -ForegroundColor Blue
	(Get-Service -Name "WireGuardTunnel`$*" -ErrorAction Ignore).Name | ForEach-Object {
		if($_) {
			$_
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "stop `"$_`""
			do {
				Start-Sleep -Milliseconds 250
			} until ((Get-Service -Name "$_").Status -eq "Stopped")
		}
	}
	$sname = "WireGuardManager"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath sc.exe -ArgumentList "stop `"$sname`""
	do {
		Start-Sleep -Milliseconds 250
	} until ((Get-Service -Name "$sname").Status -eq "Stopped")
	
	Write-Host
	foreach ($i in 5..1) { Write-Host "`r${i}초 후 자동 닫힘" -NoNewline; Start-Sleep 1 }
}

function drive {
	Param(
		[String]$ndrv,
		[String]$ipad,
		[String]$path,
		[String]$user,
		[String]$pass,
		[String]$name
	)
	if (!(Test-Path -Path $exec)) { exit }
	set-window
	Write-Host "`n### $name 네트워크 드라이브 연결" -ForegroundColor Green
	do {
		Start-Sleep -Milliseconds 250
		$temp = [Net.Dns]::GetHostAddresses($ipad)
	} until ($temp)
	$ipad = ($temp | ? { $_.AddressFamily -eq "InterNetwork" }).IPAddressToString
	do {
		Start-Sleep -Milliseconds 250
	} until (Test-Connection -TargetName $ipad -Count 1)
	$null = net use $ndrv /delete /y 2>$null
	$null = net use $ndrv "\\$ipad\$path" /persistent:yes /user:$user $pass 2>$null
	if (!$?) { net use $ndrv "\\$ipad\$path" /persistent:yes }
	if ($?) {
		(New-Object -ComObject Shell.Application).NameSpace($ndrv).Self.Name = "$name"
	} else {
		powershell -WindowStyle Normal -Command { exit }
		set-window
		Write-Host "`n아무 키나 누르십시오..." -NoNewline
		Read-Host
	}
}
