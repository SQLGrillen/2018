###################### Setup for Demo's

docker rm $(docker ps -a -q) -f

if (!(test-path -PathType Container "C:\Docker\SQLServer\Linux")){
	new-item -ItemType Directory -path "C:\Docker\SQLServer\Linux" -Force | Out-NULL
}
	sl C:\Docker\SQLServer\Linux

Get-ChildItem "C:\Docker\SQLServer\" #-Recurse
	#Create directories for backups to map to
	if (!(Test-Path "C:\Docker\SQLServer\Backups\SQLLinuxLocal\AdventureWorks2016CTP3.bak")) {
		if (!(Test-Path -PathType Container "C:\Docker\SQLServer\Backups\SQLLinuxLocal")) {
			New-Item C:\Docker\SQLServer\Backups\SQLLinuxLocal -type directory | Out-NULL
	}
	if (!(Test-Path -PathType Container "C:\Docker\SQLServer\Linux\SQLLinuxLocal")) {
		New-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -type directory | Out-NULL
	}
		Copy-Item C:\Docker\SQLServer\Backups\AdventureWorks2016CTP3.bak C:\Docker\SQLServer\Backups\SQLLinuxLocal\AdventureWorks2016CTP3.bak
	}
	Get-ChildItem "C:\Docker\SQLServer\Backups\SQLLinuxLocal\"

###################### End Setup

######################################################
### *** Run through Docker settings in systray *** ###
######################################################



###################### Checking docker running as service
#Get-Service docker #Windows Server 2016 only

	docker version

	docker info #Check the "OS Type" showing Linux

#Show the difference beween Windows and Linux
	& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon 

	docker version #Check the "OS Type" showing windows

#Switch back to Linux
	& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

##############################################################################



###################### Setup first SQL Server container (Linux)

#Check what images we have
	docker images #"sqlgeordie/*"
	
	docker search mssql --limit=10 #--no-trunc
	#docker pull microsoft/mssql-server-linux:2017-CU7 
	docker pull sqlgeordie/sqlonlinuxdemo:demo # Use tagged version just to be safe!

	<#
	-e = Environment variable
	-d = Detatched mode
	-i = For Interactive processes (ie. echo test | docker run -i busybox cat)
	-p = Assign Port
	#>
Clear-Host
	docker run 	-e "ACCEPT_EULA=Y" `
				-e "SA_PASSWORD=P@ssword1" `
				--cpus="2" `
				--name SQLLinuxLocal -d `
				-p 1433:1433  `
        		sqlgeordie/sqlonlinuxdemo:demo
	
	docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
    
    #$psformat = "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
	
	docker ps -a --format $psformat
	
	docker logs SQLLinuxLocal
	
	docker inspect SQLLinuxLocal
  
#Run in terminal / powershell.exe
    docker exec -it SQLLinuxLocal /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 
	#Show SELECT @@version and SELECT name FROM sys.databases

#Check out how easy it is to get the sa password!
	docker exec -it SQLLinuxLocal /bin/bash	
	echo $SA_PASSWORD # WOWZA!!! 
	
	exit
###

#cleanup
	docker ps -a --format $psformat 
	docker ps -a -q

	docker stop <id> #<ContainerId1, ContainerId2, etc>
	docker stop $(docker ps -a -q) #Clean(er) shutdown
	docker rm $(docker ps -a -q) -f
  
##############################################################################



###################### Restore a database by Bind Mounting a local folder
<#
    ******* NOTE: Showing this to highlight the error with mounting a volume!! *******
#>
	#Works
	docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
				--cpus="2" `
				--name SQLLinuxLocal -d `
				-p 1433:1433 `
				-v C:\Docker\SQLServer\Backups:/var/backups `
				sqlgeordie/sqlonlinuxdemo:demo 
	
	#Does not work (#This will fail due to 'NOTHING')
	docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
				--cpus="2" `
				--name SQLLinuxLocal2 -d `
				-p 15105:1433 `
				-v C:\Docker\SQLServer\Backups:/var/opt/mssql/data `
				sqlgeordie/sqlonlinuxdemo:demo 
		
	docker ps -a --format $psformat #10secs to fail
	docker logs SQLLinuxLocal2 #Takes about 20s to mount the volume

	docker exec -it SQLLinuxLocal /bin/bash
		cd /var/backups
		
	<#
	docker rm $(docker ps -a -q) -f
	Remove-Item C:\Docker\SQLServer\Backups\m*.*df
	
	#Now fixed with latest version (CU7)
	docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
				--cpus="2" `
				--name SQLLinuxLocal3 -d `
				-p 15106:1433 `
				-v C:\Docker\SQLServer\Backups:/var/opt/mssql/data `
				microsoft/mssql-server-linux:2017-CU7
				
	docker ps -a --format $psformat #10secs to fail
	docker logs SQLLinuxLocal3 #Takes about 20s to mount the volume

	docker exec -it SQLLinuxLocal3 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 
	#>

*** The filesystem has changed meaning mounting doesnt work, see error when attaching above! ext2 / 3 to ext4***

#Clean up
	docker stop $(docker ps -a -q)
	docker rm $(docker ps -a -q) -f
	Remove-Item C:\Docker\SQLServer\Backups\m*.*df #Remove dodgy files left over
##############################################################################



###################### Breaking SQL on Linux - deleting mdf files
<#

***Removed this demo as the filesystem has changed meaning mounting doesn't work ***

#>



###################### Docker DataVolume Demo - As opposed to Bind Mounting a volume

<#
	- Create Volume
	- Create / Backup DB
	- Restore to another
#>

#Clear volume
	docker rm dummycontainer
	docker volume rm sqldatavolume

#Create dummy container to define and copy backup file
    #Rubbish but the only way to copy stuff to it!!!
    docker container create --name dummycontainer -v sqldatavolume:/sqlserver/data/ sqlgeordie/sqlonlinuxdemo:demo
	docker ps -a --format $psformat
	
#Copy AdventureWorks or whatever you like ;)
    docker cp C:\Docker\SQLServer\Backups\AdventureWorks2016CTP3.bak dummycontainer:/sqlserver/data/AdventureWorks2016CTP3.bak
    docker cp C:\Docker\SQLServer\Linux\SQLScripts dummycontainer:/sqlserver/data/
    docker volume ls
    docker rm dummycontainer

    docker inspect sqldatavolume

	#docker stop $(docker ps -a -q)
	#docker rm $(docker ps -a -q) -f

#Create SQLLinuxLocalPersist container
    docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        		--name SQLLinuxLocalPersist -d `
        		-p 1433:1433 `
        		-v sqldatavolume:/sqlserver/data `
        		sqlgeordie/sqlonlinuxdemo:demo

#Create SQLLinuxLocalPersist2 container (NOTE the different port!)
    docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        		--name SQLLinuxLocalPersist2 -d `
        		-p 15105:1433 `
        		-v sqldatavolume:/sqlserver/data `
        		sqlgeordie/sqlonlinuxdemo:demo

    docker ps -a --format $psformat
    docker logs SQLLinuxLocalPersist
    docker logs SQLLinuxLocalPersist2

#Show what is in the sqldatavolume and copy another file if desired
    docker exec -it SQLLinuxLocalPersist2 /bin/bash
    cd /sqlserver/data
    ls

<# Here we are going to:
	- create a DB and table with 100 rows on SQLLinuxLocalPersist
	- back it up to the shared data volume
	- restore from shared data volume to SQLLinuxLocalPersist2
	- select count(*) from [SQLGeordie].[dbo].[SQLGeordietable] to get 100 rows
#>
	docker exec -it SQLLinuxLocalPersist /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 `
				-i '/sqlserver/data/SQLScripts/SQLLinuxLocalPersist_1.sql'
	
    Clear-Host
	docker exec -it SQLLinuxLocalPersist2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 `
				-i '/sqlserver/data/SQLScripts/SQLLinuxLocalPersist_2.sql'
	
    
#Cleanup
	docker rm $(docker ps -a -q) -f
	docker volume rm sqldatavolume

##############################################################################
