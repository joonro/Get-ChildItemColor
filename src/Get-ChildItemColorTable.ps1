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
    File = @{ Default = $OriginalForegroundColor }
    Service = @{ Default = $OriginalForegroundColor }
    Match = @{ Default = $OriginalForegroundColor }
}

$GetChildItemColorTable.File.Add('Directory', "Blue")
$GetChildItemColorTable.File.Add('Symlink', "Cyan") 

foreach ($Extension in $GetChildItemColorExtensions['CompressedList']) {
    $GetChildItemColorTable.File.Add($Extension, "Red")
}

foreach ($Extension in $GetChildItemColorExtensions['ExecutableList']) {
    $GetChildItemColorTable.File.Add($Extension, "Green")
}

foreach ($Extension in $GetChildItemColorExtensions['TextList']) {
    $GetChildItemColorTable.File.Add($Extension, "Yellow")
}

foreach ($Extension in $GetChildItemColorExtensions['DllPdbList']) {
    $GetChildItemColorTable.File.Add($Extension, "DarkGreen")
}

foreach ($Extension in $GetChildItemColorExtensions['ConfigsList']) {
    $GetChildItemColorTable.File.Add($Extension, "Gray")
}

foreach ($Extension in $GetChildItemColorExtensions['SourceCodeList']) {
    $GetChildItemColorTable.File.Add($Extension, "DarkYellow")
}

$GetChildItemColorTable.Service.Add('Running', "DarkGreen")
$GetChildItemColorTable.Service.Add('Stopped', "DarkRed")

$GetChildItemColorTable.Match.Add('Path', "Cyan")
$GetChildItemColorTable.Match.Add('LineNumber', "Yellow")
$GetChildItemColorTable.Match.Add('Line', $OriginalForegroundColor)
