param(
	[string]$Module
)
$PrevPath = (Get-Location).Path
$RootPath = $PSScriptRoot
Set-Location -path $RootPath


& rojo serve $Module


Set-Location -path $PrevPath