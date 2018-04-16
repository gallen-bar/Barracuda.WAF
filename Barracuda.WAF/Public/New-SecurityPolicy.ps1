<#
.SYNOPSIS
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
.LINK
    https://campus.barracuda.com/product/webapplicationfirewall/api/9.1.1
#>
function New-SecurityPolicy {
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSCustomObject])]
    Param (
        # Name help description
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(1, 64)]
        [String]
        $Name,

        # BasedOn help description
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias('based-on')]
        [ValidateLength(1, 64)]
        [String]
        $BasedOn = '*'
    )

    process {
        try {
            $PSBoundParameters |
                ConvertTo-Post |
                    Invoke-API -Path '/restapi/v3/security-policies' -Method Post
        } catch {
            if ($_.Exception -is [System.Net.WebException]) {
                Write-Verbose "ExceptionResponse: `n$($_ | Get-ExceptionResponse)`n"
                if ($_.Exception.Response.StatusCode -ne 404) {
                    throw
                }
            } else {
                throw
            }
        }
    }
}