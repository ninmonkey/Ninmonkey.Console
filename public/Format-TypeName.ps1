$__ninColor = @{
    Default = @{
        SkyBlue      = '#85BDD8'
        Fg           = 'gray85'
        FgDim        = 'gray60'
        PesterGreen  = '#3EBC77'
        PesterPurple = '#A35BAA'

    }
}



# }
function _writeTypeNameString {
    <#
    .synopsis
        macro conditionally prints with parens

    .example
        _writeTypeNameString 'Foo' -Brackets
            [Foo]
    #>
    [cmdletbinding()]
    param(
        # Can be anything, it's a string
        [alias('Name')]
        [Parameter(
            # ParameterSetName = '',
            Mandatory, Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$TypeName,

        # may not be a real namespace. used for color
        [Parameter(
            Position = 1, ValueFromPipelineByPropertyName
        )]
        [String]$NameSpace,

        # pre/post
        [Alias('Brackets')]
        [Parameter()]
        [switch]$WithBrackets,

        # ansi color?
        [Alias('WithColor')]
        [Parameter()]
        [switch]$Color
    )
    begin {
        <#
        todo: next: Will
            - show a bunch of (visual only) tests of Format-TYpeNameColor
            colorize brackets, namespace, typename
        #>

    }
    process {
        if (! $WithBrackets) {
            $TypeName
            return
        }

        if (! $Color ) {
            '[{0}]' -f @($TypeName)
            return
        }


        '[{0}]' -f @($TypeName) | Write-Color $__ninColor.Default.PesterGreen
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

    warning:
        A low level function like this, should (probably) never use functions like 'format-dict',
        because of indirect recursion

    .link
        Dev.Nin\Get-HelpFromTypeName
    #>

    [cmdletbinding()]
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
        [Parameter()][switch]$WithBrackets,

        # PassThru formatted typename
        [Parameter()][switch]$PassThru


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
            NullSymbol     = "`u{2400}"
            EmptyStr       = 'EmptyStr'
            EmptySet       = '∅'
            OnlyWhitespace = 'StringIsBlank'
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

            if type doesn't resolve, and get type isn't non-string, then return self

            attempt 'typenameString' -as 'type' before other parsing
            quick hack before rewrite, otherwise it consumes types
        #>

        # todo: is type already a type?

        # true null?
        if ($Null -eq $InputObject) {
            _writeTypeNameString @wb $str.NullSymbol
            return
        }

        $startedAsString = $InputObject -is 'string'
        # $startedAsType = $InputObject -is 'type'
        $startedAsType = $InputObject -is 'type'
        $tinfo = ($InputObject)?.GetType()

        if($startedAsString) {
            $tinfo = $InputObject -as 'type'
        } elseif( $InputObject -is 'type' ){
            $tinfo = $InputObject
        } else {
            write-warning "maybe shouldn't reach here? '$PSCommandPath'"
            $tinof = $InputObject
        }


        if ($InputObject -is 'type') {
            $tinfo = $InputObject
        } else {
            $tinfo = ($InputObject)?.GetType()
        }

        if ($startedAsString) {
            # todo: next: PR: auto cast using -as
            $parsed = $InputObject -replace '^System\.', ''
            # $nameSpace =
        } else {
            $parsed = $tinfo.FullName -replace '^System\.', ''
        }

        $parsedInfo = [ordered]@{
            PSTypeName        = 'nin.ParsedTypeName'
            <#
            duties:
                external code/type has 'nin.TypeInfo' and other inspection

                Format-TypeName:
                    least amount of info, and dependencies as possible.
                    otherwise recursion
            #>
            # RenderName        = # plus, here, it's recursive. visual, maybe not? $tinfo | Format-TypeName -WithBrackets
            FullName          = $tinfo.FullName
            Name              = $tinfo.Name # would be format style / compute some
            NameSpace         = $tinfo.NameSpace
            OriginalReference = $tinfo
        }

        if ($PassThru) {
            [pscustomobject]$parsedInfo
            return
        }

        # -replace '^System\.', ''
        _writeTypeNameString @wb -Name $parsedInfo.Name -Namespace $parsedInfo.NameSpace
        # _writeTypeNameString @wb -TypeNameString $ninTypeInfo -Namespace ($tinfo.Namespace ?? '')




        return






























        Write-Debug 'skipping  logic'
        if ($InputObject -is 'type') {
            $tinfo = $InputObject
        }
        # is a str, but is a valid type?
        $maybeFromStr = $InputObject -as 'type'
        $resolvedFromStringFailed = $null -eq $maybeFromStr

        # if (($null -eq $InputObject) -or ($null -eq $tinfo)) {
        if (($null -eq $InputObject) -or ($null -eq $tinfo)) {
            # might need to move out
            Write-Debug "I think valid str-resolve-types fall here, but shouldn't '$tinfo', '$resolvedFromStringFailed'"
            Write-Debug 'if type doesn''t resolve, and get type isn''t non-string, then return self'
            _writeTypeNameString @wb $str.NullSymbol
            return
        }
        # string-y null?
        if ([string]::IsNullOrWhiteSpace( $InputObject ) ) {
            _writeTypeNameString @wb $str.OnlyWhitespace
            return
        }

        @{
            InputObject              = $InputObject
            tinfo                    = $tinfo
            maybeFromStr             = $maybeFromStr ?? '$null'
            resolvedFromStringFailed = $resolvedFromStringFailed
        } | Format-Table | Out-String | Write-Debug

        if (! $resolvedFromStringFailed) {
            # good, keep it
            $parsed =

            # if($)

            $finalString = $tinfo.GetType().FullName
        } else {

            $finalString
            $maybeFromStr.GetType().FullName
        }

        if ($maybeFromStr) {
            $tinfo = $maybeFromStr
            $finalString = ''
            # str, but not a valid type
        } else {
            $finalString = $tinfo.FullName
        }

        if ($finalString) {
            $parsed = $finalString
        } else {
            $parsed = $tinfo.FullNames
        }

        $dbgMeta = @{
            ParameterSetName         = $PSCmdlet.ParameterSetName
            Name                     = $tinfo.Name
            FullName                 = $tinfo.FullName
            Type                     = $tinfo
            PreCastInputType         = $InputObject.GetType().FullName
            FinalString              = $finalString
            # ... extra
            InputObject              = $InputObject
            tinfo                    = $tinfo
            maybeFromStr             = $maybeFromStr ?? '$null'
            resolvedFromStringFailed = $resolvedFromStringFailed
        }



        $dbgMeta | Format-Table | Out-String | wi

        _writeTypeNameString @wb $parsed # this part, actually goes into rendering? no?

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
            default {
                Write-Error "not implemented parameter set: '$switch'"
            }
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

<#

test it:
Import-Module Ninmonkey.Console -Force

(gi . ) | Format-TypeName  -ea break

(gi . ).GetType() | Format-TypeName  -ea break

#>
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
