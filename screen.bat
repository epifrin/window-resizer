<# :
:: Based on https://gist.github.com/coldnebo/1148334
:: Converted to a batch/powershell hybrid via http://www.dostips.com/forum/viewtopic.php?p=37780#p37780
@echo off
setlocal
cls
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
endlocal & powershell -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
goto :EOF
#>

# Add the relevant section of the Win32 API to the PowerShell session
# Allows windows to be moved and resized
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
		
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@

################################################################################
# Moves and resizes the window based the broswer
#
# Arguments: 
# $program_path is the full path to the program
# $screen_x is the horizontal location of the window on the screen
# $screen_y is the vertical location of the window on the screen
# $win_x is the width of the target window
# $win_y is the height of the target window
# Returns:   None
################################################################################
Function Fit ($program_path, $screen_x, $screen_y, $win_x, $win_y)
{
	Write-Host $program_path
    # Find the running process where the application path matches $program_path
    $processes = (Get-Process | where {$_.Path -eq $program_path})
	
	foreach ($process in $processes)
	{
		$pntInt = $process.MainWindowHandle
		if ($pntInt -ne 0)
		{
			$result = [Win32]::ShowWindow($pntInt, 1) # show normal
			$result = [Win32]::MoveWindow($pntInt, $screen_x, $screen_y, $win_x, $win_y, $true) # fit window
			Write-Host $process.MainWindowTitle
		}
	}	
}

Function Maximize ($program_path)
{
	Write-Host $program_path
	# Find the running process where the application path matches $program_path
    $processes = (Get-Process | where {$_.Path -eq $program_path})
	foreach ($process in $processes)
	{
		$pntInt = $process.MainWindowHandle
		if ($pntInt -ne 0)
		{
			$result = [Win32]::ShowWindow($pntInt, 3) # show maximize
			Write-Host $process.MainWindowTitle
		}
	}
}

Fit "C:\Program Files\Mozilla Firefox\firefox.exe" 143 0 1775 1045
Fit "C:\Users\panas\AppData\Local\Programs\Opera\opera.exe" 143 0 1775 1045
Fit "C:\Program Files\Google\Chrome\Application\chrome.exe" 143 0 1775 1045
Fit "C:\Program Files (x86)\JetBrains\PhpStorm 2020.2.2\bin\phpstorm64.exe" 143 0 1775 1045

#Maximize "C:\Users\panas\AppData\Local\Programs\Opera\opera.exe"

PAUSE
