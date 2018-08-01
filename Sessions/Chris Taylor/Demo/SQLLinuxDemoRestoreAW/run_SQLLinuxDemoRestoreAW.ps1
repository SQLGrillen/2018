#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoRestoreAW\"
#### End Setup

$DockerImageName = "sqllinuxdockerfilerestoreaw"
$ContainerName = "sqllinuxrestoreaw"


docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

<#
docker images
docker ps -a 
#>

#Build the image using the Dockerfile
docker build -t $DockerImageName . #--squash
#docker history $DockerImageName
docker images

#NOTE: No sa password and changing default port of SQL Server to 15105 in Dockerfile
docker run --name $ContainerName -d -t -p 15105:15105 $DockerImageName

#Docker logs shows "Detected 3000 MB of RAM. This is an informational message; no user action is required."
docker logs $ContainerName 

#docker inspect $ContainerName

#Check Standard Edition
docker exec -it $ContainerName /opt/mssql-tools/bin/sqlcmd -S localhost,15105 -U sa -P P@ssword1 `
		-Q "SET NOCOUNT ON; SELECT @@version; SELECT name from sys.databases"

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

docker rmi $DockerImageName
