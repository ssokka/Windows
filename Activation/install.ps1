Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1")
param([bool]$wait = $true)

try {
	$name = "Windows"
	
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	
	Write-Host "`n# 정품 인증" -ForegroundColor Blue
	$slmgr = "$Env:WinDir\System32\slmgr.vbs"
	
	if (!(("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)', '$1').Trim() -match "인증되었습니다")) {
		$site = "https://github.com/ssokka/Windows/raw/master/Activation"
		$file = "restore.7z"
		$exec = "restore.exe"
		install-7zip
 		ddr $false
		Start-BitsTransfer -Source "$site/$file" -Destination "$Global:Temp\$file"
		Write-Host "암호: " -NoNewline
		$LastConsoleLine = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			Expand-7Zip -ArchiveFileName "$Global:Temp\$file" -TargetPath $Global:Temp -SecurePassword (Read-Host -AsSecureString) -ErrorAction Ignore
			if ($?) { break } else { ccp $x $y }
		}
		Start-Process -NoNewWindow -Wait "$Global:Temp\$exec" '/activate'
		"$Global:Temp\$file", "$Global:Temp\$exec" | ForEach-Object { Remove-Item -Path $_ -Force -ErrorAction Ignore }
		ddr $true
	}

	("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)', '$1').Trim()
	
	set-window
	Write-Host "`n### 완료" -ForegroundColor Green
	
	if ($wait) { Write-Host "`n아무 키나 누르십시오..." -NoNewline; Read-Host }
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}
