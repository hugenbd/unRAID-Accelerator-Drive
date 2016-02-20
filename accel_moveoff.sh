#!/usr/bin/bash

#test mode on  Change to false to move files
testmode=true

#diskmv command
dmvcommand="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -t"
dmvcommandtestmode="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -t"


#Create an array of shares to accelerate
array1[0]="/mnt/user/TV/"
array1[1]="/mnt/user/Movies/"

#Create an array of diskids to strip
array2=( 1 2 )

#Define accelerator disk
accelerator=disk3

#define all the file sizes combined that will be moved.
alltotalsize=0

#ignore all files that have an extension below
Ignorefileextensions="xml,nfo,sfv,sff,properties,jpg,idx,sub"
#replace , with \|
Ignorefileextensions="${Ignorefileextensions//,/\|}"
echo "Ignorefilext: $Ignorefileextensions"

#ignore files that are smaller than this size
Ignoresmallsize=10M

#days old
Daysold="10"

#Comma Seperated list of directories to ignore on the accelerator drive
Ignoredirectories="Good Show 1, Good Show 2"

#What percentage do you want to fill the drive to
TargetDriveFilltopercentage=55

#Is the current drive full?
DriveFull=false


echo ""
echo ""
echo "___________________________________"
echo "Accelerator - Move off SSD"
echo ""
if [ $testmode = true ]
then
        echo "Test Mode ON!"
        dmvcommand="$dmvcommandtestmode"
        echo "Command Used: $dmvcommand"
else
        echo "Test Mode OFF   *** Warning - Files will be moved! ***"
        echo "Command Used: $dmvcommand"
fi



echo "___________________________________"
echo ""
echo ""

for diskid in "${array2[@]}"
do
        echo "In Disk$diskid"

        for path in "${array1[@]}"
        do


                echo ""
                echo ""
                echo "     **************************************"
                echo "     In $path"
                accelpath="${path/'/mnt/user'//mnt/$accelerator}"

                if [ -d "$accelpath" ]; then

                        #check to see if diskid in loop exists
                        if [ -d "/mnt/disk$diskid" ]; then

                                find "$accelpath" -mtime +$Daysold -type f -size +$Ignoresmallsize ! -iregex ".*/.*\.\($Ignorefileextensions\)">/tmp/acc_move.list

                                #check to see if the find is empty.
                                linesinfind=`cat /tmp/acc_move.list | wc -l`

                                if [ $linesinfind -gt 0  ]
                                then
                                        ####echo "Filelist is not empty!"

                                        #Loop through each line in the file list
                                        while read filename; do
                                                #####echo "     FileName: $filename"

                                                #Check to see if there is enough space left on the target drive
                                                target_used=`df -k /mnt/disk$diskid | awk '{ print $5}' | tail -1`
                                                target_used=`echo "${target_used%?}"`
                                                ###echo "     Target Used %: $target_used"
                                                ####echo "     Target Max % : $TargetDriveFilltopercentage"

                                                if [ $target_used -gt $TargetDriveFilltopercentage ]; then
                                                        echo "     You don't have enough free space"
                                                        echo "     **************************************"
                                                        echo " "
                                                        DriveFull=true
                                                        break
                                                else
                                                        #move all the file
                                                        #Replace the /mnt/accelerator with /mnt/user
                                                        share_filename="${filename/"mnt/$accelerator"/mnt/user}"
                                                        echo "     Found File: $share_filename"

                                                        $dmvcommand "$share_filename" $accelerator disk$diskid
                                                        echo ""


                                                fi



                                        done </tmp/acc_move.list



                                fi #end linesinfind
                        else
                                echo "     Disk not found: disk$diskid"
                                echo "     **************************************"

                        fi #end diskid check

                else
                        echo "     Accelerator not found $accelerator"
                        echo "     **************************************"

                fi #end if excelpath exists

                #Check to see if the drive is full
                if [ $DriveFull = true ]; then
                        DriveFull=false
                        break
                fi
        done #done with path loop


done
