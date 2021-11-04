﻿$__ninColor = @{
    Default = @{
        SkyBlue      = '#85BDD8'
        Fg           = 'gray85'
        FgDim        = 'gray60'
        PesterGreen  = '#3EBC77'
        PesterPurple = '#A35BAA'

    }    
}


function _writeTypeNameString {
    <#
    .synopsis
        macro conditionally prints with parens

    .example
        _writeTypeNameString 'Foo' -Brackets
            [Foo]
    #>
    param(
        [alias('Text')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$TypeNameString,

        # pre/post
        [Alias('Brackets')]
        [Parameter()]
        [switch]$WithBrackets,

        # ansi color? 
        [Alias('WithColor')]
        [Parameter()]
        [switch]$Color
    )
    process {
        if (! $WithBrackets) {
            $TypeNameString
            return
        }

        if (! $Color ) {
            '[{0}]' -f @($TypeNameString)
            return 
        }

        
        '[{0}]' -f @($TypeNameString) | Write-Color $__ninColor.Default.PesterGreen
        return
    }
}


function Format-TypeName {
    <#
    .synopsis
        Formats type names to be more readable, removes common prefixes
    .example
        # $cat is a [pscustomobject] with PSTypeName = 'Nin.Animal'
        PS> $cat.pstypenames | Format-TypeName | join-string -sep ', ' { "[$_]" }

            [Selected.System.Management.Automation.PSCustomObject], [Nin.Animal], [PSCustomObject], [Object]
    .notes
    see also:
        [ParameterMetadata](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.parametermetadata?view=powershellsdk-7.0.0)]

        [https://docs.microsoft.com/en-us/dotnet/api/system.reflection.typeinfo?view=netcore-3.1#properties]

    .link
        Dev.Nin\Get-HelpFromTypeName
    #>

    param(
        # list of types as strings

        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Alias('Type')]
        [Parameter(
            ParameterSetName = 'paramTypeAsString',
            Mandatory, ValueFromPipeline
        )]
        [object]$InputObject,

        # # list of types / type instances
        # [Parameter(
        #     ParameterSetName = 'paramTypeAsInstance',
        #     ValueFromPipeline
        # )][System.Reflection.TypeInfo]$TypeInstance,

        # A List of Namespaces or prefixes to ignore: -IgnoreNamespace
        [Parameter()][Alias('WithoutPrefix')]
        [string[]]$IgnorePrefix = @(),

        # A list of Namespaces to include (overriding defaults)
        [Parameter()][Alias('WithPrefix')]
        [string[]]$IncludePrefix = @(),

        # use Ansi coloring for formatting, using Format.ps1xml
        [Parameter()][switch]$Colorize,

        # surround type names with '[]' ?
        [Alias('Brackets')]
        [Parameter()][switch]$WithBrackets


        # [Alias('WithoutBrackets')]
        # [Parameter()][switch]$NoBrackets
    )
    begin {
        # $x = 10
        # return 
        $Config = @{
            # WithoutBrackets
        }
        $DefaultIgnorePrefix = @(
            'System.Collections.Generic'
            'System.Collections'
            'System.Management.Automation'
            'System.Runtime.CompilerServices'
            'System.Text'
            'System'
        )

        if ($IncludePrefix.count -gt 0) {
            Write-Warning 'currently ignoring: -IncludePrefix'
        }
        if ($IgnorePrefix.count -gt 0) {
            Write-Warning 'currently ignoring: -IgnorePrefix'
        }
        if ($Colorize) {
            Write-Error 'Format.ps1xml Ansi Escape NYI' 
            # also use ENV:NO_COLOR
        }
        $Str = @{
            NullSymbol = "`u{2400}"
            EmptyStr   = 'EmptyStr'
            EmptySet   = '∅'
        }        

        $wb = @{
            WithBrackets = $WithBrackets
        }

        $color = @{
            SkyBlue      = '#85BDD8'
            FgDim        = 'gray60'
            PesterGreen  = '#3EBC77'
            PesterPurple = '#A35BAA'
        }
    }

    Process {
        # $x2 = 0
        # return
        <#
        refactor:
            attempt 'typenameString' -as 'type' before other parsing
            quick hack before rewrite, otherwise it consumes types
        #>

        # todo: is type already a type?

        # true null?
        $tinfo = ($InputObject)?.GetType()
        if ($InputObject -is 'type') {
            $tinfo = $InputObject
        }
       
        if (($null -eq $InputObject) -or ($null -eq $tinfo)) {
            _writeTypeNameString @wb $str.NullSymbol
            return 
        }
        # string-y null?
        if ([string]::IsNullOrWhiteSpace( $InputObject ) ) {
            _writeTypeNameString @wb $str.NullSymbol
            return
        }

        # is a str, but is a valid type? 
        $maybeFromStr = $InputObject -as 'type'
        if ($maybeFromStr) {
            $tinfo = $maybeFromStr
            $finalString = ''
            # str, but not a valid type
        } else {
            $finalString = $InputObject
        }

        if ($finalString) {
            $parsed = $finalString
        } else {
            $parsed = $tinfo.fullname -replace '^System\.', ''
        }
        
        $dbgMeta = @{
            ParameterSetName = $PSCmdlet.ParameterSetName
            Name             = $tinfo.Name
            FullName         = $tinfo.FullName
            Type             = $tinfo
            PreCastInputType = $InputObject.GetType().FullName
            FinalString      = $finalString
        }



        $dbgMeta | Format-Table | Out-String | wi

        _writeTypeNameString @wb $parsed

        return 

        $PSCmdlet.ParameterSetName
        | str prefix 'parameterSetName'
        | Write-Debug
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {
                if ( [string]::IsNullOrWhiteSpace( $TypeAsString ) ) {
                    return
                }
                Write-Debug "Original: $TypeName"
                $TypeAsString = $TypeName
                Write-Verbose 'Nyi: Regex (Format-TypeName)'
                # throw "NYI: get regex: NYI"
                break
            }
            'paramTypeAsInstance' {
                if ($null -eq $TypeInstance) {
                    return
                }
                if ($TypeInstance.IsGenericType) {
                    Write-Debug 'IsGenericType: True'
                    $TypeInstance | Format-GenericTypeName -WithBrackets:$WithBrackets
                    return # full exit
                }

                Write-Debug "Instance: $TypeInstance"
                $TypeAsString = $TypeInstance.FullName
                break
            }
            default { Write-Error "not implemented parameter set: '$switch'" }
        }

        $filteredName = $TypeAsString
        foreach ($prefix in $IgnorePrefix) {
            $Pattern = '^{0}\.' -f [regex]::Escape( $prefix )
            $filteredName = $filteredName -replace $Pattern, ''
            continue
        }
        if (! $WithBrackets) {
            $filteredName
        } else {
            '[', $filteredName, ']' -join ''
        }
    }

}


function NestedOrNot( [type]$TypeInfo ) {
    H1 'nestedOrNot'
    $isNested = $typeInfo.IsNested
    Label 'Nested' $isNested
    @{
        IsNested = $typeInfo.Name
        Name     = $typeInfo.Name
    } | Format-HashTable

    if ($false) {
        ( $typeInfo.IsNested ) ? $typeInfo.DeclaringType : $typeInfo.Name
        $true -eq $typeinfo.IsNested | Label 'IsNested?: '
        $nestedTypeName = $typeinfo.DeclaringType.Name, $typeinfo.Name -join '+'
        ( $typeinfo.namespace), $nestedTypeName -join '.'
    }

}
$warningText = @'
1]
    [string](([system.collections.generic.list[hashtable]]@()).GetType())

thread: <https://discord.com/channels/180528040881815552/447476117629304853/849489347564666910>

    '@
& {
    if ($false -or 'quick test') {
        $typeName = 'System.Collections.Generic.Dictionary`2+KeyCollection[[System.String],[System.Management.Automation.ParameterMetadata]]'
        $TypeInfo = $typeName -as 'type'
        NestedOrNot 'dsf'.GetType()
        #| label 'string '
        NestedOrNot $typeinfo
        #| Label 'typeinfo '

    }
} | Write-Debug


# Need to convert string type to typename when able
Write-Debug @'
changefix:
    always convert to [System.RuntimeType] if not already a [System.RuntimeType]
    require a manual  opt-out to not do it

bugfix:
🐒> $target.gettype() | % fullname | %{ $_ -as 'type' } |  Format-TypeName

Dictionary`2[String, ParameterMetadata]

🐒> $target.gettype() | % fullname | Format-TypeName

Dictionary`2[[System.String, System.Private.CoreLib, Version=5.0.0.0, Culture=neu
tral, PublicKeyToken=7cec85d7bea7798e],[System.Management.Automation.ParameterMet
adata, System.Management.Automation, Version=7.1.0.0, Culture=neutral, PublicKeyT
oken=31bf3856ad364e35]]
'@
