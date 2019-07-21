# Helper method for simulating ellipsis
function CutString
{
    param ([string]$message, $length)

    if ($message.length -gt $length)
    {
        return $message.SubString(0, $length-3) + '...'
    }

    return $message
}