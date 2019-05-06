# ANSI / CP949 / CRLF
# EXE	https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-9b4b0493
# PS	powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -F .\install.ps1

$title = 'Microsoft Visual C++ ����� ���� ��Ű�� ��ġ'
$host.ui.RawUI.WindowTitle = $title
Write-Host "`r`n # $title ���� #`r`n" -ForegroundColor Yellow 

$OSBit = if ([IntPtr]::Size -eq 4) { 32 } else { 64 }
$OSArchs = 86, 64
$restart = $null

$data = Invoke-RestMethod 'https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.json'
[array]::Reverse($data)

:data foreach ($item in $data) {
	if ($item.Product -gt 2013 -and $item.Product -lt $data[-1].Product) { continue data }
	:osarch foreach ($OSArch in $OSArchs) {
		if ($OSBit -eq 32 -and $OSArch -eq 64) {
			Write-Host ""
			break osarch
		}
		if ([string]::IsNullOrWhitespace($item.ServicePack)) {
			$ServicePackName = '	'
			$ServicePackFile = ''
		} else {
			$ServicePackName = ' SP{0}' -f $item.ServicePack
			$ServicePackFile = '-{0}' -f $ServicePackName -replace ' ', ''
		}
		$name = 'Microsoft Visual C++ {0}{1} x{2} ����� ���� ��Ű��' -f $item.Product, $ServicePackName, $OSArch
		$file = '{0}\VCRedist-{1}{2}-x{3}.exe' -f $env:TEMP, $item.Product, $ServicePackFile, $OSArch
		$log = '{0} "{1}"' -f $item.LogOption, $file -replace '\.exe', '.log'
		if ($item.Product -eq 2005) { $log = '' }
		$CLO = '{0} {1}' -f $item.CommandLineOptions, $log
		$url = if ($OSArch -eq 86) { $item.x86 } else { $item.x64 }
		Write-Host "   $name" -NoNewline
		Write-Host "	| �ٿ�ε� " -NoNewline
		(New-Object System.Net.WebClient).DownloadFile("$url", "$file")
		if (Test-Path -Path "$file") {
			Write-Host "�Ϸ�" -NoNewline
		} else {
			Write-Host "���� !" -ForegroundColor Red
			if ($OSBit -eq 32 -or $OSArch -eq 64) { Write-Host "" }
			continue osarch
		}
		Write-Host " | ��ġ " -NoNewline
		$process = Start-Process -FilePath "$file" -ArgumentList $CLO -PassThru -Verb RunAs -Wait
		if ($process.ExitCode -eq 3010) { $restart = $true }
		if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
			Write-Host "���� !" -ForegroundColor Red
		} else {
			Write-Host "�Ϸ�"
		}
		if ($OSBit -eq 64) { Write-Host "" }
	}
}

Write-Host " # $title �Ϸ� #`r`n" -ForegroundColor Yellow 

if ($restart) {
	Write-Host " ��ġ�� �Ϸ��Ϸ��� ��ǻ�͸� �ٽ� �����ؾ� �մϴ�."
	Write-Host " ���� ��ǻ�͸� �ٽ� �����Ͻðڽ��ϱ�? [Y/N] " -NoNewline -ForegroundColor Red
	$input = Read-Host
	if ($input -eq "y") { Restart-Computer -Force }
} else {
	Write-Host " �ƹ�Ű�� �����ʽÿ�." -NoNewline
	Read-Host
}