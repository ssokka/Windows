param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "Windows"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	Write-Host "`n# 정품 인증" -ForegroundColor Blue
	$slmgr = "$Env:WinDir\System32\slmgr.vbs"
	
	if (!(("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)', '$1').Trim() -match "인증되었습니다")) {
		$site = "$Git/Activation"
		$file = "restore.exe"
		install-7zip
 		ddr $false
		$down = dw "$site/restore.7z"
		Write-Host "암호: " -NoNewline
		$LastConsoleLine = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			Expand-7Zip -ArchiveFileName $down -TargetPath $Temp -SecurePassword (Read-Host -AsSecureString) -ErrorAction Ignore
			if ($?) { break } else { ccp $x $y }
		}
		& "$Temp\$file" /activate | Out-Host
		$down, "$Temp\$file" | ForEach-Object { Remove-Item -Path $_ -Force -ErrorAction Ignore }
		ddr $true
	}

	("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)', '$1').Trim()
	
	if ($wait) {
		set-window
		Write-Host "`n### 완료" -ForegroundColor Green
		Write-Host "`n아무 키나 누르십시오..." -NoNewline; Read-Host
	}
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}
