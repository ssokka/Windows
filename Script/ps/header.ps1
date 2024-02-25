$hwnd = (Get-Process -Id (gwmi win32_process -Filter "processid='$PID'").ParentProcessId).MainWindowHandle
$type = Add-Type -PassThru -NameSpace Util -Name SetFgWin -MemberDefinition @'
	[DllImport("user32.dll", SetLastError=true)]
	public static extern bool SetForegroundWindow(IntPtr hWnd);
	[DllImport("user32.dll", SetLastError=true)]
	public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);    
	[DllImport("user32.dll", SetLastError=true)]
	public static extern bool IsIconic(IntPtr hWnd);
'@ 
$null = $type::SetForegroundWindow($hWnd)
if ($type::IsIconic($hwnd)) { $type::ShowWindow($hwnd, 9) }
