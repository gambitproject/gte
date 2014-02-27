## CLIENT version - Development process ##

The CLIENT version is only for developing the GUI.

You do not need to execute ANT targets on the CLIENT version, because you only modify
ActionScript files and Eclipse helps you to compile and test your code.
Access the code from GitHub, change the GUI, submit the code back to GitHub

If you want to compile, test and run the complete GTE you need to setup the
SERVER version. Access the code from GitHub and run the **compileComplete** ANT-target.

## 1. Install Eclipse IDE##

Download Eclipse IDE (HELIOS or INDIGO) for Java EE Developpers 32-bit version at:
[http://www.eclipse.org/downloads/](http://www.eclipse.org/downloads/ "Eclipse Download").
Do not use the 64-bit version or the new JUNO release of eclipse because it does not work
with the FlashBuilder plugin later.


## 2. Setup and run the CLIENT version ##

1. Make a copy of your Eclipse installation, because you will integrate FlashBuilder -
   FLEX support for Eclipse, which is buggy and may harm other projects on eclipse.
2. Download and install Adobe Flash Builder 4.6. Sign up to Adobe with your student ID
   (this might take some days until Adobe has verified you as a student).
   As a student you will get Flash Builder for free.
3. Navigate to your Adobe Flash Builder install directory and go to the subdirectory
   **utilities**. Open and install "Adobe Flash Builder 4.6 Plugin-in Utility.exe".
   This will install the Flashbuilder - Flex Plugin into your Eclipse installation.
4. Switch to Eclipse and import the GitHub repository into a new Flex-Project
5. Choose Flex 4.1A as the Flash Version (NOT 4.6). If you cannot choose 4.1A go
   to **Configure Flex SDK** and add the directory of the installed Flex SDK
   (4. Install Flex SDK) to Eclipse.
6. Choose as the primary source directory **gui-builder/src**
7. Finish the project wizard
8. Navigate in the project explorer to `gui-builder/src/les/math/games/builder/view`,
   right click on Main.mxml and choose **set as default application**.
9. Delete the original *.mxml application file created by the project wizard
   (should be createt in gui-builder/src)
10. Run "main.mxml"

Optional: If you see only a grey screen adjust the security settings of the FlashPlayer.
Right-Click on the grey area and choose **Global settings** from the popup menu.
Navigate to **Advanced** and scroll down. Click on **Trusted Location Settings**
and add the directory where the Flash-File is executed to the list of trusted locations.

