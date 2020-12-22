Installation instructions for passive mode FTP files in MATLAB.
Written by Idin Motedayen-Aval.

Updated 12/29/2010

(See references at the end for more information)


Quick Install notes (for more detailed instructions, see blow):
1. Locate your @ftp folder and copy it to a location outside MATLAB
   toolbox directory.
2. Add the folder containing @ftp to the top of your MATLAB path.
3. Copy the provided connect.m into your new @ftp/private folder.
4. Copy the rest of the files to your new @ftp folder
    (ftp.m pasv.m, active.m, dataMode.m)
5. Restart MATLAB and rehash your toolbox cache by typing:
    rehash toolboxcache
6. You can now use passive mode FTP by typing 'pasv(myFTP)' after
    constructing an FTP object called myFTP.


Detailed instructions:
1. Unzip all the files to a local directory on your machine.  Verify that
   you have these files in the zip file:
     ftp.m
     connect.m
     active.m
     pasv.m
     dataMode.m

2. Find the path to the MATLAB FTP class.
    a. At the MATLAB prompt, type
        which ftp
    b. This should return a string that looks like this:
        D:\Applications\MATLAB701\toolbox\matlab\iofun\@ftp\ftp.m  % ftp constructor
    c. Note this path (or copy it).

3. Copy the entire @ftp directory to a location outside the MATLAB toolbox
   directory, e.g.,
       C:\myWork\myFunctions\@ftp

4. Add this new folder to the top of MATLAB path:
       addpath('C:\myWork\myFunctions')
       savepath

   NOTE: Add the folder containing @ftp to your MATLAB path, NOT the
         @ftp folder itself.

5. Copy the provided connect.m file to the new '@ftp/private' folder
   (over the old connect.m file).

6. Copy the remaining files to the new @ftp folder.  Once the files are
   copied, you should have the following files in this folder:

        active.m    close.m     disp.m      mget.m      rename.m
        ascii.m     dataMode.m  display.m   mkdir.m     rmdir.m
        binary.m    delete.m    ftp.m       mput.m      saveobj.m
        cd.m        dir.m       loadobj.m   pasv.m

6. Resart MATLAB and rehash your MATLAB Toolbox Cache by issuing this
    command at the MATLAB prompt:
        rehash toolboxcache

7. You can now enter 'passive mode' FTP as follows:
    myFTP = ftp('ftp.mathworks.com')
    pasv(myFTP)
    dataMode(myFTP)  % this command simply shows the current mode

    you can return to normal/active mode by issuing the command
    active(myFTP)


REFERENCES:
For a description of passive mode FTP:
http://slacksite.com/other/ftp.html

For details on the FTPClient Java class used in MATLAB:
http://jakarta.apache.org/
The specifics for the class are at:
http://jakarta.apache.org/commons/net/apidocs/org/apache/commons/net/ftp/FTPClient.html
