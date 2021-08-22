$Metadata = @(

    @{
        'Name'        = 'Exception'
        'Description' = 'Condition'
    }
    @{
        'Name'        = 'ArgumentException'
        'Description' = 'A non-null argument that is passed to a method is invalid.'
    }
    @{
        'Name'        = 'ArgumentNullException'
        'Description' = 'An argument that is passed to a method is null.'
    }
    @{
        'Name'        = 'ArgumentOutOfRangeException'
        'Description' = 'An argument is outside the range of valid values.'
    }
    @{
        'Name'        = 'DirectoryNotFoundException'
        'Description' = 'Part of a directory path is not valid.'
    }
    @{
        'Name'        = 'DivideByZeroException'
        'Description' = 'The denominator in an integer or Decimal division operation is zero.'
    }
    @{
        'Name'        = 'DriveNotFoundException'
        'Description' = 'A drive is unavailable or does not exist.'
    }
    @{
        'Name'        = 'FileNotFoundException'
        'Description' = 'A file does not exist.'
    }
    @{
        'Name'        = 'FormatException'
        'Description' = 'A value is not in an appropriate format to be converted from a string by a conversion method such as Parse.'
    }
    @{
        'Name'        = 'IndexOutOfRangeException'
        'Description' = 'An index is outside the bounds of an array or collection.'
    }
    @{
        'Name'        = 'InvalidOperationException'
        'Description' = 'A method call is invalid in an object''s current state.'
    }
    @{
        'Name'        = 'KeyNotFoundException'
        'Description' = 'The specified key for accessing a member in a collection cannot be found.'
    }
    @{
        'Name'        = 'NotImplementedException'
        'Description' = 'A method or operation is not implemented.'
    }
    @{
        'Name'        = 'NotSupportedException'
        'Description' = 'A method or operation is not supported.'
    }
    @{
        'Name'        = 'ObjectDisposedException'
        'Description' = 'An operation is performed on an object that has been disposed.'
    }
    @{
        'Name'        = 'OverflowException'
        'Description' = 'An arithmetic, casting, or conversion operation results in an overflow.'
    }
    @{
        'Name'        = 'PathTooLongException'
        'Description' = 'A path or file name exceeds the maximum system-defined length.'
    }
    @{
        'Name'        = 'PlatformNotSupportedException'
        'Description' = 'The operation is not supported on the current platform.'
    }
    @{
        'Name'        = 'RankException'
        'Description' = 'An array with the wrong number of dimensions is passed to a method.'
    }
    @{
        'Name'        = 'TimeoutException'
        'Description' = 'The time interval allotted to an operation has expired.'
    }
    @{
        'Name'        = 'UriFormatException'
        'Description' = 'An invalid Uniform Resource Identifier (URI) is used.'
    }

) | ForEach-Object { [pscustomobject]$_ }

Set-ModuleMetada -key 'ExceptionList' -Value $Metadata
