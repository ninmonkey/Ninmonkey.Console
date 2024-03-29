
# Remove-Module Ninmonkey.Console
# $ErrorActionPreference = 'Continue'
$splat_AllOn = @{
    Force             = $true
    Verbose           = $true
    Debug             = $true
    InformationAction = 'Continue'
}

$splat_Default = @{
    Force             = $true

    InformationAction = 'Continue'
}

Import-Module @splat_Default -Name Ninmonkey.Console -ea stop
# Import-Module @splat_AllOn -Name Ninmonkey.Console #-ea stop
# Import-Module Ninmonkey.Console -Force -Verbose -Debug -InformationAction Continue
