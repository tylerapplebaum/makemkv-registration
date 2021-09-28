Function Get-MakeMKVBetaKey {
[CmdletBinding()]
param(
    [Parameter(HelpMessage="Specify the URL containing the MakeMKV registration code")]
	[ValidateNotNull()]
    [String]$MakeMKVURL = "https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053"
)
$FunctionName = $MyInvocation.InvocationName
	Try {
		$MakeMKVPage = Invoke-WebRequest $MakeMKVURL
		$RegCodeHTML = $MakeMKVPage.Content | Select-String -Pattern '<code>(.*?)<\/code>'
	}
	Catch {
		$PSCmdlet.ThrowTerminatingError($PSItem)
	}
	If ($null -eq $RegCodeHTML.Matches.Value) {
		Write-Error "No key detected on $MakeMKVURL"
	}
	Else {
		$RegCode = $RegCodeHTML.Matches.Value.Trim('<code>').Trim('</code>')
		Write-Verbose "${FunctionName}: Found beta key $RegCode"
	}
Return $RegCode
}

Function Update-MakeMKVBetaKey {
[CmdletBinding()]
param(
    [Parameter(HelpMessage="Specify the registry path for MakeMKV")]
	[ValidateNotNull()]
    [String]$RegistryPath = 'HKCU:\SOFTWARE\MakeMKV',
	
    [Parameter(HelpMessage="Specify the registry key name for the MakeMKV registration key")]
	[ValidateNotNull()]
    [String]$KeyName = 'app_Key',
	
	[Parameter(HelpMessage="Specify the MakeMKV registration key")]
	[ValidateNotNull()]
	[String]$RegCode
)
$FunctionName = $MyInvocation.InvocationName
	Try {
		$RegistryKeyValue = Get-ItemProperty -Path $RegistryPath -Name $KeyName
		$OldMakeMKVKey = $RegistryKeyValue.$KeyName
	}
	Catch {
		$PSCmdlet.ThrowTerminatingError($PSItem)
	}
	If ($RegCode -notmatch $OldMakeMKVKey) {
		Write-Verbose "Existing key found: $OldMakeMKVKey; replacing with $RegCode"
		Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $RegCode
		New-ItemProperty -Path $RegistryPath -Name "$KeyName + _backup" -Value $OldMakeMKVKey
	}
	ElseIf ($RegCode -match $OldMakeMKVKey) {
		Write-Verbose "${FunctionName}: Existing key found: $OldMakeMKVKey; matches current beta key"
	}
}

Update-MakeMKVBetaKey -RegCode (Get-MakeMKVBetaKey -Verbose) -Verbose 