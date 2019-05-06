# ANSI / CP949 / CRLF

$title = 'Microsoft Visual C++ 재배포 가능 패키지 설치'
$host.ui.RawUI.WindowTitle = $title
Write-Host "`r`n # $title 시작 #`r`n" -ForegroundColor Blue

$OSBit = if ([IntPtr]::Size -eq 4) {32} else {64}
$OSArchs = 86, 64
$restart = $null

$data = Invoke-RestMethod 'https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.json'
[array]::Reverse($data)

foreach ($item in $data) {
	if ($item.Product -gt 2013 -and $item.Product -lt $data[-1].Product) {continue}
	foreach ($OSArch in $OSArchs) {
		if ($OSBit -eq 32 -and $OSArch -eq 64) {continue}
		if ([string]::IsNullOrWhitespace($item.ServicePack)) {
			$ServicePackName = ''
			$ServicePackFile = ''
		} else {
			$ServicePackName = ' SP{0}' -f $item.ServicePack
			$ServicePackFile = '-{0}' -f $ServicePackName -replace ' ', ''
		}
		$name = 'Microsoft Visual C++ {0}{1} x{2} 재배포 가능 패키지' -f $item.Product, $ServicePackName, $OSArch
		$file = '{0}\VCRedist-{1}{2}-x{3}.exe' -f $env:TEMP, $item.Product, $ServicePackFile, $OSArch
		$log = '{0} "{1}"' -f $item.LogOption, $file -replace '\.exe', '.log'
		if ($item.Product -eq 2005) {$log = ''}
		$CLO = '{0} {1}' -f $item.CommandLineOptions, $log
		$url = if ($OSArchs -eq 86) {$item.x86} else {$item.x64}
		Write-Host "   $name | 다운로드" -NoNewline
		(New-Object System.Net.WebClient).DownloadFile("$url", "$file")
		if (Test-Path -Path "$file") {
			Write-Host " 완료" -NoNewline
		} else {
			Write-Host " 실패 !" -ForegroundColor Red
			continue
		}
		Write-Host " | 설치" -NoNewline
		$process = Start-Process -FilePath "$file" -ArgumentList $CLO -PassThru -Verb RunAs -Wait
		if ($process.ExitCode -eq 3010) {$restart = $true}
		if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
			Write-Host " 실패 !" -ForegroundColor Red
		} else {
			Write-Host " 완료"
		}
	}
	Write-Host "`r`n"
}

Write-Host " # $title 완료 #`r`n" -ForegroundColor Blue

if ($restart) {
	Write-Host " 설치를 완료하려면 컴퓨터를 다시 시작해야 합니다."
	Write-Host " 지금 컴퓨터를 다시 시작하시겠습니까? [Y/N] " -NoNewline -ForegroundColor Red
	$input = Read-Host
	if ($input -eq "y") {Restart-Computer -Force}
} else {
	Write-Host " 아무키나 누르십시오." -NoNewline
	Read-Host
}