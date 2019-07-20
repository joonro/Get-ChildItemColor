$OriginalForegroundColor = $Host.UI.RawUI.ForegroundColor
if ([System.Enum]::IsDefined([System.ConsoleColor], 1) -eq "False") { $OriginalForegroundColor = "Gray" }

$global:GetChildItemColorExtensions = @{}

$GetChildItemColorExtensions.Add(
    'CompressedList',
    @(
        ".7z",
        ".gz",
        ".rar",
        ".tar",
        ".zip"
    )
)

$GetChildItemColorExtensions.Add(
    'ExecutableList',
    @(
        ".exe",
        ".bat",
        ".cmd",
        ".reg",
        ".fsx",
        ".sh"
    )
)

$GetChildItemColorExtensions.Add(
    'DllPdbList',
    @(
        ".dll",
        ".pdb"
    )
)

$GetChildItemColorExtensions.Add(
    'TextList',
    @(
        ".csv",
        ".log",
        ".markdown",
        ".md",
        ".rst",
        ".txt"
    )
)

$GetChildItemColorExtensions.Add(
    'ConfigsList',
    @(
        ".cfg",
        ".conf",
        ".config",
        ".ini",
        ".json"
    )
)

$GetChildItemColorExtensions.Add(
    'SourceCodeList',
    @(
        # Ada
        ".adb", ".ads",

        # C Programming language
        ".c", ".h",

        # C++
        #".C", ".h"
        ".cc", ".cpp", ".cxx", ".c++", ".hh", ".hpp", ".hxx", ".h++",

        # C#
        ".cs",

        # COBOL
        ".cbl", ".cob", ".cpy",

        # Common Lisp
        ".lisp", ".lsp", ".l", ".cl", ".fasl",

        # Clojure
        ".clj", ".cljs", ".cljc", "edn",

        # Erlang
        ".erl", ".hrl",

        # F# Programming Language
        #".fsx"
        ".fs", ".fsi", ".fsscript",

        # Fortran
        ".f", ".for", ".f90",

        # Go
        ".go",

        # Groovy
        ".grooy",

        # Haskell
        ".hs", ".lhs",

        # HTML
        ".html", ".htm", ".hta", ".css", ".scss",
        
        # Java
        ".java", ".class", ".jar",

        # Javascript
        ".js", ".mjs", ".ts", ".tsx"

        # Objective C
        ".m", ".mm",

        # P Programming Language
        ".p",

        # Perl
        ".pl", ".pm", ".t", ".pod",

        # PHP
        ".php", ".phtml", ".php3", ".php4", ".php5", ".php7", ".phps", ".php-s", ".pht",

        # Pascal
        ".pp", ".pas", ".inc",

        # PowerShell
        ".ps1", ".psm1", ".ps1xml", ".psc1", ".psd1", ".pssc", ".cdxml",

        # Prolog
        #".P"
        #".pl"
        ".pro",

        # Python
        ".py", ".pyx", ".pyc", ".pyd", ".pyo", ".pyw", ".pyz",

        # R Programming Language
        ".r", ".RData", ".rds", ".rda",

        # Ruby
        ".rb"

        # Rust
        ".rs", ".rlib",

        # Scala
        ".scala", ".sc",

        # Scheme
        ".scm", ".ss",

        # Swift
        ".swift",

        # Unreal Script
        ".uc", ".uci", ".upkg",

        # SQL
        ".sql",

        # VB Script
        ".vbs", ".vbe", ".wsf", ".wsc", ".asp"
    )
)

$global:GetChildItemColorTable = @{
    Default = $OriginalForegroundColor
}

$GetChildItemColorTable.Add('Directory', "Blue")
$GetChildItemColorTable.Add('Symlink', "Cyan") 

ForEach ($Extension in $GetChildItemColorExtensions.CompressedList) {
    $GetChildItemColorTable.Add($Extension, "Red")
}

ForEach ($Extension in $GetChildItemColorExtensions.ExecutableList) {
    $GetChildItemColorTable.Add($Extension, "Green")
}

ForEach ($Extension in $GetChildItemColorExtensions.TextList) {
    $GetChildItemColorTable.Add($Extension, "Yellow")
}

ForEach ($Extension in $GetChildItemColorExtensions.DllPdbList) {
    $GetChildItemColorTable.Add($Extension, "DarkGreen")
}

ForEach ($Extension in $GetChildItemColorExtensions.ConfigsList) {
    $GetChildItemColorTable.Add($Extension, "Gray")
}

ForEach ($Extension in $GetChildItemColorExtensions.SourceCodeList) {
    $GetChildItemColorTable.Add($Extension, "DarkYellow")
}


Function Get-Color($Item) {
    $Key = 'Default'

    if ([bool]($Item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        $Key = 'Symlink'
    } Else {
        If ($Item.GetType().Name -eq 'DirectoryInfo') {
            $Key = 'Directory'
        } Else {
           If ($Item.PSobject.Properties.Name -contains "Extension") {
                If ($GetChildItemColorTable.ContainsKey($Item.Extension)) {
                    $Key = $Item.Extension
                }
            }
        }
    }

    $Color = $GetChildItemColorTable[$Key]
    Return $Color
}


Function Get-ChildItemColor {
    Param(
        [string]$Path = ""
    )
    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    $Items = Invoke-Expression $Expression

    ForEach ($Item in $Items) {
        $Color = Get-Color $Item

        $Host.UI.RawUI.ForegroundColor = $Color
        $Item
        $Host.UI.RawUI.ForegroundColor = $OriginalForegroundColor
    }
}

Function Get-ChildItemColorFormatWide {
    Param(
        [string]$Path = "",
        [switch]$Force
    )

    $nnl = $True

    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    if ($Force) {$Expression += " -Force"}

    $Items = Invoke-Expression $Expression

    $lnStr = $Items | Select-Object Name | Sort-Object { "$_".Length } -Descending | Select-Object -First 1
    $len = $lnStr.Name.Length
    $width = $Host.UI.RawUI.WindowSize.Width
    $cols = If ($len) {[math]::Floor(($width + 1) / ($len + 2))} Else {1}
    if (!$cols) {$cols = 1}

    $i = 0
    $pad = [math]::Ceiling(($width + 2) / $cols) - 3

    ForEach ($Item in $Items) {
        If ($Item.PSobject.Properties.Name -contains "PSParentPath") {
            If ($Item.PSParentPath -match "FileSystem") {
                $ParentType = "Directory"
                $ParentName = $Item.PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "")
            }
            ElseIf ($Item.PSParentPath -match "Registry") {
                $ParentType = "Hive"
                $ParentName = $Item.PSParentPath.Replace("Microsoft.PowerShell.Core\Registry::", "")
            }
        } Else {
            $ParentType = ""
            $ParentName = ""
            $LastParentName = $ParentName
        }

        $Color = Get-Color $Item

        If ($LastParentName -ne $ParentName) {
            If($i -ne 0 -AND $Host.UI.RawUI.CursorPosition.X -ne 0){  # conditionally add an empty line
                Write-Host ""
            }
            Write-Host -Fore $OriginalForegroundColor ("`n`n   $($ParentType): $ParentName`n`n")
        }

        $nnl = ++$i % $cols -ne 0

        # truncate the item name
        $toWrite = $Item.Name
        If ($toWrite.length -gt $pad) {
            $toWrite = $toWrite.Substring(0, $pad - 3) + "..."
        }

        Write-Host ("{0,-$pad}" -f $toWrite) -Fore $Color -NoNewLine:$nnl

        If ($nnl) {
            Write-Host "  " -NoNewLine
        }

        $LastParentName = $ParentName
    }

    Write-Host "`n"

    If ($nnl) {  # conditionally add an empty line
        Write-Host ""
    }
}

Export-ModuleMember -Function 'Get-*'
