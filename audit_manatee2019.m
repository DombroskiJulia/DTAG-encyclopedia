%AUDIT PROTOCOL FOR MANATEE DATA
%Set matlab path to the folder Tools in your hardrive. Make sure all
%folders and subfolders are in your path.
%make sure your workspace is clear. Run clear all and check if the area
%called Workspace on the top right part of your matlab is empity. 
clear all
%settagpath. You are giving the tag tools the adressess its going to use to find each file it needs. 
%for example, it is going to look for AUDIT files in the folder called audit. the audit folder is in the dtag folder on your hardrive which address is M: 
settagpath('AUDIT', 'M:\dtag\audit', 'CAL', 'M:\dtag\cal', 'PRH', 'M:\dtag\prh')
%Now you are just giving depid, prefix and tag proper names. 
depid='tm17_010a';
prefix=depid
tag='tm17_010a';
%Here you are giving the tools the address where the unpacked files are.
recdir=['M:\tm17_010a'] ;
%Every time you need help which a function just type help function. It is a
%good idea to read the help before using a new or unfamiliar function. The
%help will tell yourwhat arguments the function needs (information its
%going to use) and hopefully examples of its use and a quick guide on how
%to operate it.
help d3audit
%     R = d3audit(recdir,prefix,tag,tcue,R)
%      Audit tool for dtag 3.
 %     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
  %    prefix is the base part of the name of the files to analyse e.g., 
   %      if the files have names like 'eg207a001.wav', put prefix='eg207a'.
    %  tag is the tag deployment string e.g., 'eg15_207a'
     % tcue is the time in seconds-since-tag-on to start displaying from
      %R is an optional audit structure to edit or augment
      %Output:
       %  R is the audit structure made in the session. Use saveaudit
        % to save this to a file.
      %Examples:
       %  1. explicit definition of where the audio files are:
        %  d3audit('f:/hp14/hp14_226b','hp14_226b',2000,R);
         %2. use settagpath shortcut method as with dtag2 data:
          %settagpath('AUDIO','f:')
          %d3audit('hp14_226b',2000,R);
 
      %OPERATION
      %Type or click on the display for the following functions:
      %- type 'f' to go to the next block
      %- type 'b' to go to the previous block
      %- click on the graph to get the time cue, depth, time-to-last
      %  and frequency of an event. Time-to-last is the elapsed time 
       % between the current click point and the point last clicked. 
        %Results display in the matlab command window.
      %- type 's' to select the current segment and add it to the audit.
       % You will be prompted to enter a sound type on the matlab command
       % window. Enter a single word and type return when complete.
      %- type 'l' to select the current cursor position and add it to the 
      %  audit as a 0-length event. You will be prompted to enter a sound 
       % type on the matlab command window. Enter a single word and type 
        %return when complete.
     % - type 'x' to delete the audit entry at the cursor position.
      %  If there is no audit entry at the cursor, nothing happens.
       % If there is more than one audit entry overlapping the cursor, one
        %will be deleted (the first one encountered in the audit structure).
      %- type 'p' to play the displayed sound segment 
       % through the computer speaker/headphone jack.
      %- type 'q' or press the right hand mouse button to finish auditing.
      %- type 'a' to report the angle of arrival of the selected segment
      %- type 'w' to save a wav file for the current segment
      %- type 'e' to open an echogram worker for the current segment.
 	   %  The results are saved in a file named with the prefix and starting cue.
%Calling the audit function       
E = d3audit_jd(recdir,depid,depid);
%Everytime you start a new audit, your first task is to save it. So make a
%selection on the spectrogram right in the begining. Click s to select it,
%right NameLastname_date. Hit Enter. type q and save the audit using the saveaudit
%function:
saveaudit('tm17_010a',E)
%now you have to reload the file you saved
E=loadaudit('tm17_010a');
%and re-start auditing.
start=22 %time in seconds when you stoped last time and where the funtion will beging now.
E = d3audit_jd(recdir,depid,depid,start,E);
%make your selections. 
%When you are done click q, and save the audit.
saveaudit('tm17_010a',E)
%Everytime you start auditing a tag that you never worked on, save a
%selection with NameLastname_date.

%Code for sounds in manatee tags:
%ft=fart
%ch=chewing
%focal
%b=boat
%






