
using namespace System.Collections.Generic
using namespace System.Management.Automation

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Find-FunctionChildItem'
    )
    $publicToExport.alias += @(
        # 'a' # 'Find-FunctionChildItem'
    )
}


# ls . *.ps1 | lsFunc | s Name, Verb, Noun, CommandType, Module, ModuleName | Ft

class NinFunctionInfo {
    <#
    .synopsis
        quick hack, terrible code. mini attributes on a [System.Management.Automation.FunctionInfo]
    #>

    [FunctionInfo]$FunctionInfoInstance

    # possible close, most are accessed by the instance
    [Boolean]$CmdletBinding
    [System.Collections.ObjectModel.ReadOnlyCollection[Management.Automation.PSTypeName]]$OutputType
    # [ReadOnlyCollection[[Automation.CommandParameterSetInfo, Management.Automation]]]$ParameterSets
    [Dictionary[[String], [Management.Automation.ParameterMetadata]]]$Parameters
    [Management.Automation.CommandTypes]$CommandType
    [Management.Automation.PSModuleInfo]$Module
    [Management.Automation.ScopedItemOptions]$Options
    [Management.Automation.ScriptBlock]$ScriptBlock
    [Management.Automation.SessionStateEntryVisibility]$Visibility
    [Object]$HelpUri
    [String]$DefaultParameterSet
    [String]$Definition
    [String]$Description
    [String]$HelpFile
    [String]$Name
    [String]$Noun
    [String]$Source
    [String]$Verb
    [Version]$Version

    [Management.Automation.RemotingCapability]$RemotingCapability
    # [string]$ModuleName
    NinFunctionInfo( [FunctionInfo]$FunctionInfo ) {
        $this.FunctionInfoInstance = $FunctionInfo

        ## basics

        $this.CmdletBinding = $FunctionInfo.CmdletBinding
        $this.CommandType = $FunctionInfo.CommandType
        $this.DefaultParameterSet = $FunctionInfo.DefaultParameterSet
        $this.Definition = $FunctionInfo.Definition
        $this.Description = $FunctionInfo.Description
        $this.HelpFile = $FunctionInfo.HelpFile
        $this.HelpUri = $FunctionInfo.HelpUri
        $this.Module = $FunctionInfo.Module
        $this.Name = $FunctionInfo.Name
        $this.Noun = $FunctionInfo.Noun
        $this.Options = $FunctionInfo.Options
        $this.OutputType = $FunctionInfo.OutputType
        $this.Parameters = $FunctionInfo.Parameters
        $this.ParameterSets = $FunctionInfo.ParameterSets
        $this.ScriptBlock = $FunctionInfo.ScriptBlock
        $this.Source = $FunctionInfo.Source
        $this.Verb = $FunctionInfo.Verb
        $this.Version = $FunctionInfo.Version
        $this.Visibility = $FunctionInfo.Visibility
    }


    <#
    unwanted ?
    #>
}

# Write-Warning "$PSCommandPath 🐱‍👤"
function Find-FunctionChildItem {
    <#
    .synopsis
        search for functions in files
    .description

    .example
        PS> #
    #>
    [Alias(
        # 'a'
    )]
    [CmdletBinding()]
    param(
        # Command, alias, or function name to search for
        [Parameter(Mandatory, Position = 0)] # ValueFromPipeline)]
        [string[]]$Path,
        # # returns object with source metadadata
        # [switch]$PassThru

        [hashtable]$Options = @{}
    )
    begin {
        [List[object]]$items = [list[object]]::new()
    }
    process {
        $files = Get-ChildItem -Path $Path -Recurse -File -Force -Filter '*.ps1'
        $files | Join-String -op '$files found: ' -sep ', ' | Write-Debug

        $files | ForEach-Object {

        }

        $items.AddRange( $CommandName )
    }
    end {
        $cmd_list = Ninmonkey.Console\Resolve-CommandName $items
        | Sort-Object -Unique

        $cmd_list | ForEach-Object {
            $cmd = $_
            $codeArgs = @(
                '--goto'
                '"{0}:{1}:{2}"' -f @(
                    $cmd.ScriptBlock.Ast.Extent.File
                    $cmd.ScriptBlock.Ast.Extent.StartLineNumber
                    $cmd.ScriptBlock.Ast.Extent.StartColumnNumber
                )
            )

            # Write-Debug 'wrote $global:ninLastPath'
            $global:ninLastPath = $cmd.ScriptBlock.Ast.Extent.File | Get-Item

            $codeArgs | Join-String -sep ' ' -op ($binCode.Name + ' ') | Write-Debug
            if ($NameOnly) {
                return $cmd.ScriptBlock.Ast.Extent.File | Get-Item | ForEach-Object FullName
            }



            if ($PassThru) {
                return $cmd.ScriptBlock.Ast.Extent
            }
            # todo: simplify using Ninmonkey.Console\Code-Venv


            $cmd.ScriptBlock.Ast.Extent.File
            | Join-String -op 'loading:... <' -os '>' { $_ }
            | Write-Information
            Start-Process -path $binCode -args $codeArgs -WindowStyle Hidden
        }
    }
}
