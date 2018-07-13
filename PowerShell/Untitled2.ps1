 Start Powershell {$Token = 'xoxb-365714718179-366947241878-xnK88uIyx4EDtjvTc1lFAMVE'
$Admin = 'ngrtype31h491'
$botParams = @{
    Name = 'name'
    BotAdmins = @('ZolarV')
    CommandPrefix = '!'
    LogLevel = 'Info'
    BackendConfiguration = @{
        Name = 'SlackBackend'
        Token = $Token
    }
    AlternateCommandPrefixes = 'bender', 'hal'
}

$myBotConfig = New-PoshBotConfiguration @botParams

# Start a new instance of PoshBot interactively or in a job.
Start-PoshBot -Configuration $myBotConfig #-AsJob
}
