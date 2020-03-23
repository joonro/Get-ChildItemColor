# Helper method for simulating ellipsis
function CutString
{
    param ([string]$Message, $length)

    $len = 0
    $count = 0
    $max = $length - 3
    ForEach ($c in $Message.ToCharArray())
    {
        $len += LengthInBufferCell($c)
        if ($len -gt $max)
        {
            Return $Message.SubString(0, $count) + '...'
        }
        $count++
    }
    Return $Message
}

function LengthInBufferCells
{
    param ([string]$Str)

    $len = 0
    ForEach ($c in $Str.ToCharArray())
    {
        $len += LengthInBufferCell($c)
    }
    Return $len
}


function LengthInBufferCell
{
    param ([char]$Char)
    # The following is based on http://www.cl.cam.ac.uk/~mgk25/c/wcwidth.c
    # which is derived from https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt
    [bool]$isWide = $Char -ge 0x1100 -and
        ($Char -le 0x115f -or # Hangul Jamo init. consonants
         $Char -eq 0x2329 -or $Char -eq 0x232a -or
         ([uint32]($Char - 0x2e80) -le (0xa4cf - 0x2e80) -and
          $Char -ne 0x303f) -or # CJK ... Yi
         ([uint32]($Char - 0xac00) -le (0xd7a3 - 0xac00)) -or # Hangul Syllables
         ([uint32]($Char - 0xf900) -le (0xfaff - 0xf900)) -or # CJK Compatibility Ideographs
         ([uint32]($Char - 0xfe10) -le (0xfe19 - 0xfe10)) -or # Vertical forms
         ([uint32]($Char - 0xfe30) -le (0xfe6f - 0xfe30)) -or # CJK Compatibility Forms
         ([uint32]($Char - 0xff00) -le (0xff60 - 0xff00)) -or # Fullwidth Forms
         ([uint32]($Char - 0xffe0) -le (0xffe6 - 0xffe0)))

    # We can ignore these ranges because .Net strings use surrogate pairs
    # for this range and we do not handle surrogage pairs.
    # ($Char -ge 0x20000 -and $Char -le 0x2fffd) -or
    # ($Char -ge 0x30000 -and $Char -le 0x3fffd)
    if ($isWide)
    {
        Return 2
    }
    else
    {
        Return 1
    }
}
