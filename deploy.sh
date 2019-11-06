#!/bin/bash
clear

echo "-----------LEAD APP DEPLOYMENT SCRIPT--------------------"

function stopTomcat()
{
	echo "---------------Stop Tomcat--------------------"
	ssh root@$1 'netstat -nl | grep 8080'
	if [ $? -eq 1 ]
	then
		echo "Tomcat is already down"
	else
		ssh root@$1 'sh /opt/tomcat/bin/shutdown.sh'
 	        sleep 2
	fi
}

function startTomcat()
{
	echo "---------------Start Tomcat--------------------"
	ssh root@$1 'netstat -nl | grep 8080'
        if [ $? -eq 1 ]
        then
                ssh root@$1 'sh /opt/tomcat/bin/startup.sh'
		sleep 2
        else
		stopTomcat
		ssh root@$1 'sh /opt/tomcat/bin/startup.sh'
                sleep 2
        fi

}

function backup()
{
	echo "---------------Backup the leadapp war file------------------"
	ssh root@$1 'if [ -f /opt/tomcat/webapps/leadapp.war ];  then mv /opt/tomcat/webapps/leadapp.war /root/backup/; fi; rm -rf /opt/tomcat/webapps/leadapp;'
	sleep 2
}

function dbDeploy()
{
	echo "---------------LeadApp DB Deloyment------------------"
        scp   src/database/schema.sql root@$1:/opt/tomcat/
        ssh root@$1 'mysql -u leadApp -pleadApp123 leadAppDB < /opt/tomcat/schema.sql'		
	sleep 2
}

function appDeploy()
{
	echo "---------------LeadApp war Deloyment------------------"
	scp  dist/lib/leadapp.war  root@$1:/opt/tomcat/webapps/
	sleep 2
}

function removeWar()
{
	echo "---------------Remove war File-----------------------"
	ssh root@$1 'rm -rf  /opt/tomcat/webapps/leadapp  /opt/tomcat/webapps/leadapp.war;'
	sleep 2
}

function startTime()
{
	echo "!!!! START TIME :" `date`
}

function endTime()
{
	echo "!!!! END TIME :" `date`
}

function newLine()
{
	echo ""
}

if [ $# -eq 1 ]
then	
    server="172.31.0.19"
    case $1 in 
	deploy)  	newLine
			startTime
			newLine 
			stopTomcat $server
			backup $server
			dbDeploy $server
			appDeploy $server 
		 	startTomcat $server
			newLine
			endTime
			newLine;;
	stop)		stopTomcat $server ;;
	start)		startTomcat $server ;;
	remove) 	removeWar $server;;
	restart)	stopTomcat $server
			startTomcat $server ;;
	db)    		dbDeploy $server ;;
   	app) 		appDeploy $server ;;
	backup)		backup $server ;;
	*)	echo " You have entered a worng operation"
    esac
else
    echo "USAGE: sh deploy.sh deploy "
fi

