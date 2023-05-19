$ExecutionContext.InvokeCommand.GetCommand('TabExpansion2', 'All')

$setAliasSplat = @{
    Scope       = 'global'
    Name        = 'TabExpansion2_Original'
    Value       = $ExecutionContext.InvokeCommand.GetCommand(
        'TabExpansion2', 'Function'
    )
    Description = 'Test out the vanilla completion'
}

Set-Alias @setAliasSplat