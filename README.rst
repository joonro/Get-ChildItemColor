.. highlight:: posh

===================
Get-ChildItem-Color
===================

Add coloring to the output of `Get-ChildItem` Cmdlet of PowerShell. In
addition to the original functionality, this provides:

* Color support for `Format-Wide` case (`ls` equivalent) 
* Better performance by using `Dictionary` objects instead of regular
  expressions

Install
=======

.. code-block::

   git clone https://github.com/joonro/Get-ChildItem-Color.git

It is convenient to do this in your `$PROFILE` [#]_ folder.

Usage
=====

In your `$PROFILE` [#]_, add the following::

   . "Path\To\Get-ChildItem-Color\Get-ChildItem-Color.ps1"

   Set-Alias l Get-ChildItem-Color -option AllScope
   Set-Alias ls Get-ChildItem-Format-Wide -option AllScope

If you install it under the `$PROFILE` folder, you can also do the following::

   $ScriptPath = Split-Path -parent $PSCommandPath
   . "$ScriptPath\Get-ChildItem-Color\Get-ChildItem-Color.ps1"
   
   Set-Alias l Get-ChildItem-Color -option AllScope
   Set-Alias ls Get-ChildItem-Format-Wide -option AllScope

Authors
=======

`Joon Ro <http://github.com/joonro>`_

This code is based on Tim Johnson's `script
<http://tasteofpowershell.blogspot.com/2009/02/get-childitem-dir-results-color-coded.html>`_ 
and also `Keith Hill
<http://stackoverflow.com/users/153982/keith-hill>`_'s answer at `this
<http://stackoverflow.com/questions/3420731/>`_ Stack Overflow question.

Footnotes
=========

.. [#] ``C:\Users\username\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1``

