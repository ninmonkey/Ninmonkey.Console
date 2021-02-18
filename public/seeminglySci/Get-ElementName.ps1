
function Get-ElementName {
    <#
    .synopsis
        originally from: <ConvertTo-SciBase64String>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        # For more see:
            <./test/public/ConvertTo-Base64String.ps1>
    #>
    [Alias('NameOf')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNull()]
        [ScriptBlock] $Expression
    )
    end {
        if ($Expression.Ast.EndBlock.Statements.Count -eq 0) {
            return
        }

        $firstElement = $Expression.Ast.EndBlock.Statements[0].PipelineElements[0]
        if ($firstElement.Expression.VariablePath.UserPath) {
            return $firstElement.Expression.VariablePath.UserPath
        }

        if ($firstElement.Expression.Member) {
            return $firstElement.Expression.Member.SafeGetValue()
        }

        if ($firstElement.GetCommandName) {
            return $firstElement.GetCommandName()
        }

        if ($firstElement.Expression.TypeName.FullName) {
            return $firstElement.Expression.TypeName.FullName
        }
    }
}