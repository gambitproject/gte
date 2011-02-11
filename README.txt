I. PREREQUISITES

1. Install Java SDK (not just JRE)
	1.1 Download - http://www.oracle.com/technetwork/java/javase/downloads/
	1.2 Add bin directory to path
	1.3 Add JAVA_HOME environment variable (makes sure it points to the SDK, not JRE)
	
2. Install Apache Ant
	2.1 Download archive - http://ant.apache.org/
	2.2 Add bin directory to path	
	2.3 Add ANT_HOME environment variable (might not be necessary)

3. Install Flex SDK
	3.1 Download archive - http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4	
	3.2 Add bin directory to path
	3.3 Update FLEX_HOME property in build.properties file	

4. Install the Google App Engine SDK 
	4.1 Download archive - http://code.google.com/appengine/downloads.html
	4.2 Add bin directory to path
	4.3 Update GAE_HOME property in build.properties file	
	

II. BUILD

Open command prompt.
Go to project root directory (location of this README).
Type "ant" and return.
You should see the build.xml script being executed.


III. DEV SERVER

After building, cd into the new "build" directory.
Type "dev_appserver.sh <WAR_NAME>" and return.
The server should now be running at http://localhost:8080/
