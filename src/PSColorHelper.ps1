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
    # The following is based on https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
    # which is derived from https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt
    [bool]$isWide = $Char -ge 0x1100 -and
        ($Char -le 0x115f -or # Hangul Jamo init. consonants
         $Char -eq 0x2329 -or $Char -eq 0x232a -or
         ($Char -ge 0x2e80 -and $Char -le 0xa4cf -and
         $Char -ne 0x303f) -or # CJK ... Yi
         ($Char -ge 0xac00 -and $Char -le 0xd7a3) -or # Hangul Syllables
         ($Char -ge 0xf900 -and $Char -le 0xfaff) -or # CJK Compatibility Ideographs
         ($Char -ge 0xfe10 -and $Char -le 0xfe19) -or # Vertical forms
         ($Char -ge 0xfe30 -and $Char -le 0xfe6f) -or # CJK Compatibility Forms
         ($Char -ge 0xff00 -and $Char -le 0xff60) -or # Fullwidth Forms
         ($Char -ge 0xffe0 -and $Char -le 0xffe6))

    # We can ignore these ranges because .Net strings use surrogate pairs
    # for this range and we do not handle surrogage pairs.
    # ($Char -ge 0x20000 -and $Char -le 0x2fffd) -or
    # ($Char -ge 0x30000 -and $Char -le 0x3fffd)
    if ($isWide)
    {
        return 2
    }
    else
    {
        return 1
    }
}
