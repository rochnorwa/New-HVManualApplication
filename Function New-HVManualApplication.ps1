Function New-HVManualApplication {
<#
.Synopsis
    Creates a Manual Application. Source: https://developer.vmware.com/apis/1298/view
.DESCRIPTION
    Creates Application manually with given parameters.
.PARAMETER HvServer
    View API service object of Connect-HVServer cmdlet.
.PARAMETER Name
    The Application name is the unique identifier used to identify this Application.
.PARAMETER DisplayName
    The display name is the name that users will see when they connect to view client. If the display name is left blank, it defaults to Name.
.PARAMETER Description
    The description is a set of notes about the Application.
.PARAMETER ExecutablePath
    Path to Application executable.
.PARAMETER Version
    Application version.
.PARAMETER Publisher
    Application publisher.
.PARAMETER Enabled
    Indicates if Application is enabled.
.PARAMETER EnablePreLaunch
    Application can be pre-launched if value is true.
.PARAMETER ConnectionServerRestrictions
    Connection server restrictions. This is a list of tags that access to the application is restricted to. Empty/Null list means that the application can be accessed from any connection server.
.PARAMETER CategoryFolderName
    Name of the category folder in the user's OS containing a shortcut to the application. Unset if the application does not belong to a category.
.PARAMETER ClientRestrictions
    Client restrictions to be applied to Application. Currently it is valid for RDSH pools.
.PARAMETER ShortcutLocations
    Locations of the category folder in the user's OS containing a shortcut to the desktop. The value must be set if categoryFolderName is provided.
.PARAMETER MultiSessionMode
    Multi-session mode for the application. An application launched in multi-session mode does not support reconnect behavior when user logs in from a different client instance.
.PARAMETER MaxMultiSessions
    Maximum number of multi-sessions a user can have in this application pool.
.PARAMETER StartFolder
    Starting folder for Application.
.PARAMETER Args
    Parameters to pass to application when launching.
.PARAMETER Farm
    Farm name.
.PARAMETER DesktopPool
    Pool name.
.PARAMETER AutoUpdateFileTypes
    Whether or not the file types supported by this application should be allowed to automatically update to reflect changes reported by the agent.
.PARAMETER AutoUpdateOtherFileTypes
    Whether or not the other file types supported by this application should be allowed to automatically update to reflect changes reported by the agent.
.PARAMETER GlobalApplicationEntitlement
    The name of a Global Application Entitlement to associate this Application pool with.
.EXAMPLE
    New-HVManualApplication -Name 'App1' -DisplayName 'DisplayName' -Description 'ApplicationDescription' -ExecutablePath "PathOfTheExecutable" -Version 'AppVersion' -Publisher 'PublisherName' -Farm 'FarmName'
    Creates a manual application App1 in the farm specified.
.OUTPUTS
    A success message is displayed when done.
.NOTES
    Author                      : Roch Norwa
    Author email                : rnorwa@vmware.com
    Version                     : 1.0
    ===Tested Against Environment====
    Horizon View Server Version : 8.5
    PowerCLI Version            : PowerCLI 12.7
    PowerShell Version          : 5.1 build 22000 revision 282
#>
  param (
    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]$HvServer,

    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [string][ValidateLength(1,64)]$Name,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String][ValidateLength(1,256)]$DisplayName = $Name,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String][ValidateLength(1,1024)]$Description,

    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [String]$ExecutablePath,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String]$Version,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String]$Publisher,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [Boolean]$Enabled = $True,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [Boolean]$EnablePreLaunch=$False,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [string[]]$ConnectionServerRestrictions,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True, ParameterSetName = 'categoryFolderName')]
    [String][ValidateRange(1,64)]$CategoryFolderName,

    #Below Parameter is for Client restrictions to be applied to Application. Currently it is valid for RDSH pools.
    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [Boolean]$clientRestrictions = $False,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True, ParameterSetName = 'categoryFolderName')]
    [String[]]$ShortcutLocations,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [ValidateSet('DISABLED','ENABLED_DEFAULT_OFF','ENABLED_DEFAULT_ON','ENABLED_ENFORCED')]
    [String]$MultiSessionMode = 'DISABLED',

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [ValidateScript({if(($MultiSessionMode -eq 'ENABLED_DEFAULT_OFF') -or ($MultiSessionMode -eq 'ENABLED_DEFAULT_ON') -or ($MultiSessionMode -eq 'ENABLED_ENFORCED')){$_ -gt 0}})]
    [Int]$MaxMultiSessions,

    #Below parameters are for ExecutionData, moved ExecutablePath, Version and Publisher to above from this.
    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String]$StartFolder,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String]$Args,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [String]$Farm,

    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [String]$DesktopPool,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [Boolean]$AutoUpdateFileTypes = $True,

    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
    [Boolean]$AutoUpdateOtherFileTypes = $True,

    [Parameter(Mandatory = $False)]
    [String]$GlobalApplicationEntitlement = $null
  )
  begin {
    $services = Get-ViewAPIService -HvServer $HvServer
    if ($null -eq $services) {
        Write-Error "Could not retrieve View API services from connection object"
        break
    }
    $PoolInfo = Get-HVPool -PoolName $DesktopPool
    if ($null -eq $PoolInfo) {
        Write-Error "Could not find the specified Pool."
        break
    }
    if ( $PSBoundParameters.ContainsKey('GlobalApplicationEntitlement') ) {
      $GlobalApplicationEntitlementInfo = Get-HVGlobalEntitlement -DisplayName $GlobalApplicationEntitlement
      $GlobalApplicationEntitlementId = $GlobalApplicationEntitlementInfo.Id
    } else {
      $GlobalApplicationEntitlementId = $null
    }

  }
  process {
    $App = Get-HVApplication -ApplicationName $Name -HvServer $HvServer
    if ($App) {
        Write-Host "Application already exists with the name : $Name"
        return
    }
    $AppData = New-Object VMware.Hv.ApplicationData -Property @{ 'name' = $Name; 'displayName' = $DisplayName; 'description' = $Description; 'enabled' = $Enabled; 'enableAntiAffinityRules' = $EnableAntiAffinityRules; 'antiAffinityPatterns' = $AntiAffinityPatterns; 'antiAffinityCount' = $AntiAffinityCount; 'enablePreLaunch' = $EnablePreLaunch; 'connectionServerRestrictions' = $ConnectionServerRestrictions; 'categoryFolderName' = $CategoryFolderName; 'clientRestrictions' = $ClientRestrictions; 'shortcutLocations' = $ShortcutLocations; 'globalApplicationEntitlement' = $GlobalApplicationEntitlementId; 'multiSessionMode' = $MultiSessionMode; 'maxMultiSessions' = $MaxMultiSessions }
    $ExecutionData = New-Object VMware.Hv.ApplicationExecutionData -Property @{ 'executablePath' = $ExecutablePath; 'version' = $Version; 'publisher' = $Publisher; 'startFolder' = $StartFolder; 'args' = $Args; 'farm' = $FarmInfo.id; 'desktop' = $PoolInfo.id  ; 'autoUpdateFileTypes' = $AutoUpdateFileTypes; 'autoUpdateOtherFileTypes' = $AutoUpdateOtherFileTypes}
    $AppSpec = New-Object VMware.Hv.ApplicationSpec -Property @{ 'data' = $AppData; 'executionData' = $ExecutionData}
    $AppService = New-Object VMware.Hv.ApplicationService
    $AppService.Application_Create($services,$AppSpec)
    if ($?) {
        Write-Host "Application '$Name' created successfully"
        return
    }
    Write-Host "Application creation of '$Name' has failed. $_"
  }
  end {
    [System.GC]::Collect()
  }
}