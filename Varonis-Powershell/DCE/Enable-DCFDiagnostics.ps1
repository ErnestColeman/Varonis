# Read the file in as $file
$file = Get-Content "C:\Program Files (x86)\Varonis\DatAdvantage\DatAdvantage GUI\DataVantage.Windows.exe.config"
# Regular Expression to find setting in file
$regex = '<add key="DCF_Monitor_DiagnosticMode" value=".*\/>'
# Find setting string in $file using Regular Expression and replace it with string that contains "True" value, then write the edited content back to file
$file -replace $regex, '<add key="DCF_Monitor_DiagnosticMode" value="True" />' | Set-Content "C:\Program Files (x86)\Varonis\DatAdvantage\DatAdvantage GUI\DataVantage.Windows.exe.config"