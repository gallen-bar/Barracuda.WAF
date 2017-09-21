<#
.Synopsis
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Invoke-Api
{
    [CmdletBinding(DefaultParameterSetName='None')]
    [OutputType([Object])]
    Param
    (
        # Uri help description
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        
        # Paramaters help description
        [Parameter(Mandatory=$false)]
        [Hashtable]
        $Parameters,
        
        # Data help description
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Data,
        
        # Method help description
        [Parameter(Mandatory=$false)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Default,

        # Paramaters help description
        [Parameter(Mandatory=$false)]
        [Hashtable]
        $Headers
    )

    process
    {
        try {
            $requestParameters = @{}

            $builder = New-Object -TypeName 'System.UriBuilder' -ArgumentList $Script:WAF_URI
            $builder.Path = $Path
            
            if ($PSBoundParameters.ContainsKey('Parameters')) {
                $Parameters.GetEnumerator() |
                    ForEach-Object {
                        if ($builder.Query -ne $null -and $builder.Query.Length -gt 1) {
                            $builder.Query = $builder.Query.Substring(1) + '&' + ('{0}={1}' -f $_.Key, $_.Value)
                        } else {
                            $builder.Query = '{0}={1}' -f $_.Key, $_.Value
                        }
                    }   
            }

            $requestParameters.Uri = $builder.ToString()

            $newHeaders = $Script:DEFAULT_HEADERS
            if ($Script:ACCESS_TOKEN -ne $null) {
                $encodedToken = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("{0}`r`n:" -f $Script:ACCESS_TOKEN.token))
                $newHeaders.Authorization = "Basic {0}" -f $encodedToken
            }

            if ($PSBoundParameters.ContainsKey('Headers')) {
                $Headers.GetEnumerator() |
                ForEach-Object {
                    if (-not $newHeaders.ContainsKey($_.Key)) {
                        $newHeaders.$_.Key = $_.Value
                    }
                }
            }

            [string]$hdr = ($newHeaders | Format-Table -AutoSize | Out-String).TrimEnd()
            Write-Verbose "Headers: `n$($hdr.split("`n").Foreach({"$("`t"*2)$_"}) | Out-String) `n"
            
            $requestParameters.Headers = $newHeaders

            if ($PSBoundParameters.ContainsKey('Data')) {
                $requestParameters.Body = $Data | ConvertTo-Json -Depth 4
                
                Write-Debug "Body: `n$($Data | ConvertTo-Json -Depth 4)`n"
            }
            
            if ($PSBoundParameters.ContainsKey('Method')) {
                $requestParameters.Method = $Method
            }
            
            Invoke-RestMethod @requestParameters
        } catch {
            throw $_
        }
    }
}