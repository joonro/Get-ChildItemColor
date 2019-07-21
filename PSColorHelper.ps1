# Helper method for simulating ellipsis
function CutString
{
    param ([string]$Message, $length)

    if ($Message.length -gt $length)
    {
        return $Message.SubString(0, $length-3) + '...'
    }

    Return $Message
}
