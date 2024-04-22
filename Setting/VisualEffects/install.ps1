Invoke-Expression ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')
$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 시각 효과 설정'
	$host.ui.RawUI.WindowTitle = $name
	Write-Host -ForegroundColor Green "`n### $name"
	
	$run = $false
	if ((New-Object -ComObject WScript.Shell).RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting') -ne 3) { $run = $true }
	if ((New-Object -ComObject WScript.Shell).RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow') -ne 1) { $run = $true }
	if ((New-Object -ComObject WScript.Shell).RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IconsOnly') -ne 0) { $run = $true }
	if ((New-Object -ComObject WScript.Shell).RegRead('HKCU\Control Panel\Desktop\FontSmoothing') -ne 2) { $run = $true }
	
	if ($run) {
		SystemPropertiesPerformance
		do {
			Start-Sleep -Milliseconds 250
			$wid = (Get-Process | Where-Object {$_.Name -eq "SystemPropertiesPerformance"}).Id
		} until ($wid)
		
		$wshell = New-Object -ComObject WScript.Shell
		$null = $userInput::BlockInput($true)
		$null = $wshell.AppActivate($wid)
		Start-Sleep -Milliseconds 100
		
		Write-Host '> 최적 성능으로 조정'
		$wshell.SendKeys('%p'); Start-Sleep -Milliseconds 100
		
		Write-Host '> 사용자 지정'
		$wshell.SendKeys('{TAB}'); Start-Sleep -Milliseconds 100
		$wshell.SendKeys('{HOME}'); Start-Sleep -Milliseconds 100
		
		Write-Host '   V 바탕화면의 아이콘 레이블에 그림자 사용'
		1..6 | ForEach-Object {	$wshell.SendKeys('{DOWN}'); Start-Sleep -Milliseconds 100 }
		$wshell.SendKeys(' '); Start-Sleep -Milliseconds 100
		
		Write-Host '   V 아이콘 대신 미리 보기로 표시'
		$wshell.SendKeys('{DOWN}'); Start-Sleep -Milliseconds 100
		$wshell.SendKeys(' '); Start-Sleep -Milliseconds 100
		
		Write-Host '   V 화면 글꼴의 가장자리 다듬기'
		$wshell.SendKeys('{END}'); Start-Sleep -Milliseconds 100
		$wshell.SendKeys(' '); Start-Sleep -Milliseconds 100
		
		$wshell.SendKeys('{TAB}'); Start-Sleep -Milliseconds 100
		$wshell.SendKeys('{ENTER}'); Start-Sleep -Milliseconds 100
		
		$null = $userInput::BlockInput($false)
	}
	Write-Host -ForegroundColor Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String)
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}

Write-Host -NoNewline "`n아무 키나 누르십시오..."
Read-Host
