# unRAID-Accelerator-Drive
Move new files to a specified drive using diskmv script command line call.  Based on a file list created from a find command

Before running a few variables have to be updated.

testmode=
 - Set this to true or false.  True means you will not actually move files but use the -t flag in diskmv.

dmvcommand="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -f"
dmvcommandtestmode="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -t"
 - Update these two lines so they point to the location of your diskmv script.  keep the -f and -t

array1[0]="/mnt/user/TV/"
array1[1]="/mnt/user/Movies/"
-Keep creating a list of shares and incrmement the [#] by one each time.  This is the list of shares we will search for new files.

newerdays=20
 - Set to any number of days you wish.  This will be used in the find command to set the -mtime option.
 
array2=( 1 2 )
 - Add the disk id # to this array in order to loop through all the disk you want to search for.  Do not include your cache drives or the accelerator drive listed below.
 
accelerator=disk3
 - Change disk3 to be the drive you wish to move files onto.  Usually this is an SSD or the fastest read disk you have.  Do not include this in the array2 array above.

Verify the script has execute permissions.
ls -ltr <location of script>/accel_new.sh
-rwxrwxrwx 1 root root 4317 Feb 15 11:53 accel_new.sh*

Run the script from the command line.

./accel_new.sh

If the variable testmode is set to true you will see the script start like this.    Recommended to run this way before actually moving files.
___________________________________
Looking for files Newer than 20

Test Mode ON!
Command Used: /boot/config/plugins/scripts/unraid-diskmv-master/diskmv -t
___________________________________


If the vraible testmode is set to false you iwll see the script start like this.
___________________________________
Looking for files Newer than 20

Test Mode OFF   *** Warning - Files will be moved! ***
Command Used: /boot/config/plugins/scripts/unraid-diskmv-master/diskmv -f
___________________________________

-- There is a 3 second pause if you wish to cancel or ctrl+c out of the script.

Once it's running each disk will loop through and search for file.  You should see similar output to...
----------------------------------------------------------------------------------------------------------
In disk1


     **************************************
     In /mnt/user/TV/
     DiskPath: /mnt/disk1/TV/
     Filelist total Size: 5406011 kilobytes
     Accelerator Free Space: 885101456 kilobytes
     Okay to move files, enough space left
     **************************************


 
 
