# New-HVManualApplication
This is an updated cmdlet that supports adding application pools from desktop pools.
It adds additional argument for desktop pool name as referenced in View API since Horizon 7.9:
https://developer.vmware.com/apis/1298/view

Properties

NAME	TYPE	DESCRIPTION
executablePath	xsd:string	
Path to Application executable
version	xsd:string	
Application version
This property need not be set.
publisher	xsd:string	
Application publisher
This property need not be set.
startFolder	xsd:string	
Starting folder for Application
This property need not be set.
args	xsd:string	
parameters to pass to application when launching
This property need not be set.
farm	FarmId	
Farm Entity ID. It is marked as read-only because, once an Application is created with a FarmId, it is always associated with that Farm, and cannot be removed from the Farm, or added to another Farm. Either this or desktop should be set.
This property need not be set.
This property cannot be updated.
desktop	DesktopId	
Desktop Entity ID. It is marked as read-only because, once an Application is created with a desktopId, it is always associated with that Desktop, and cannot be removed from the Desktop, or added to another Desktop. Either this or farm should be set.
Since Horizon 7.9
This property need not be set.
This property cannot be updated.
fileTypes	ApplicationFileTypeData[]	
If set, set of file types reported by the application as supported (if this application is discovered) or as specified by the administrator (if this application is manually configured). If unset, this application does not present any file type support.
Since Horizon View 6.1
This property need not be set.
This property is an unordered array of unique values.
autoUpdateFileTypes	xsd:boolean	
Whether or not the file types supported by this application should be allowed to automatically update to reflect changes reported by the agent. Typically this should be set to false if the application has manually configured supported file types.
Since Horizon View 6.2
This property has a default value of true.
otherFileTypes	ApplicationOtherFileTypeData[]	
If set, set of different type of file types reported by Application that can be passed from agent to client via broker or as specified by the administrator (if this application is manually configured). If unset, this application does not present any other file type support.
Since Horizon 7.0
This property need not be set.
This property is an unordered array of unique values.
autoUpdateOtherFileTypes	xsd:boolean	
Whether or not the other file types supported by this application should be allowed to automatically update to reflect changes reported by the agent. Typically this should be set to false if the application has manually configured supported file types.
Since Horizon 7.0
This property has a default value of true.
