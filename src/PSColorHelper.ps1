# Helper method for simulating ellipsis
function CutString
{
    param ([string]$Message, $length)

    $len = 0
    $count = 0
    $max = $length - 3
    ForEach ($c in $Message.ToCharArray())
    {
        $len += $Host.UI.RawUI.LengthInBufferCells($c)
        if ($len -gt $max)
        {
            Return $Message.SubString(0, $count) + '...'
        }
        $count++
    }

    Return $Message
}
