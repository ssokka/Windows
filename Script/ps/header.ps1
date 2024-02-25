Add-Type @'
	using System;
	using System.Runtime.InteropServices;
	public class Window {
		[DllImport("user32.dll")]
		public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
		[DllImport("user32.dll")]
		public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);    
		[DllImport("user32.dll")]
		public extern static bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
	}
	public struct RECT {
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}
'@
Add-Type -a System.Windows.Forms
$area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea
$ppid = (gwmi win32_process -Filter "processid='$PID'").ParentProcessId
$hwnd = (Get-Process -Id $ppid).MainWindowHandle
$rect = New-Object RECT
$null = [Window]::GetWindowRect($hwnd,[ref]$rect)
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top
$x = ($area.Width - $w) / 2
$y = ($area.Height - $h) / 2
$null = [Window]::MoveWindow($hwnd,$x,$y,$w,$h,$true)
(1,2,9) | % { $null = [Window]::ShowWindow($hwnd, $_) }
