#!/usr/bin/bash

#test mode on  Change to false to move files
testmode=true

#diskmv command
dmvcommand="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -f"
dmvcommandtestmode="/boot/config/plugins/scripts/unraid-diskmv-master/diskmv -t"


#Create an array of shares to accelerate
array1[0]="/mnt/user/TV/"
array1[1]="/mnt/user/Movies/"

#Days Newer Than - Find files newer...
newerdays=20

echo ""
echo ""
echo "___________________________________"
echo "Looking for files Newer than $newerdays"
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

#sleep for 3 seconds so we can see the days newer we are searchig for
sleep 3s

#Create an array of diskids to strip
array2=( 1 2 )

#Define accelerator disk
accelerator=disk3

#define all the file sizes combined that will be moved.
alltotalsize=0

#Create a list of file to move for each diskid
for diskid in "${array2[@]}"
do

        #check to see that the disk is real
        if [ ! -d "/mnt/disk$diskid" ]; then
                echo "The disk disk$diskid does not exist"
                exit 1

        fi
        echo ""
        echo ""
        echo ""
        echo "----------------------------------------------------------------------------------------------------------"
        echo "In disk$diskid"

        #Loop through the shares you want to move and create a filelist for each
        for path in "${array1[@]}"
        do
                if [ -d "$path" ]; then

                        echo ""
                        echo ""
                        echo "     **************************************"
                        echo "     In $path"
                        diskpath="${path/'/mnt/user'//mnt/disk$diskid}"
                        echo "     DiskPath: $diskpath"

                        if [ -d "$diskpath" ]; then


                                #find command for disk newer than xx days for this disk id into /tmp/disk_sharename
                                find "$diskpath" -mtime -$newerdays -type f > /tmp/acc_find.list

                                #check to see if the find is empty.
                                linesinfind=`cat /tmp/acc_find.list | wc -l`

                                if [ $linesinfind -gt 0  ]
                                then
                                        ####echo "Filelist is not empty!"


                                        #Calculate size of all files to be moved
                                        totalsize=`while read filename ; do stat -c '%s' "$filename" ; done < /tmp/acc_find.list |  awk '{total+=$1} END {print total}'`
                                        ####echo "Totalsize1: $totalsize"
                                        totalsize=$(( ${totalsize%% *} / 1024))
                                        alltotalsize=$((alltotalsize+totalsize))
                                        echo "     Filelist total Size: $totalsize kilobytes"


                                        #Calculate size of accelerator disk
                                        acc_free=`df -k /mnt/$accelerator | awk '{ print $4}' | tail -1`
                                        echo "     Accelerator Free Space: $acc_free kilobytes"

                                        #check to see there is enough space left
                                        if [ $acc_free -gt $totalsize ]
                                        then

                                                echo "     Okay to move files, enough space left"
                                                echo "     **************************************"
                                                echo ""

                                                #Loop through each line in the file list
                                                while read filename; do
                                                        #####echo "     FileName: $filename"


                                                        #Replace the /mnt/diskID with /mnt/user
                                                        share_filename="${filename/"mnt/disk$diskid"/mnt/user}"
                                                        echo "     Found File: $share_filename"


                                                        #Loop through all the files with a diskmv command
                                                        $dmvcommand "$share_filename" disk$diskid $accelerator
                                                        echo ""
                                                done </tmp/acc_find.list


                                        fi #end acc_free gt totalsize

                                else
                                        echo "     No files found to move."
                                        echo "     **************************************"
                                fi #end lineinfind gt 0
                        else
                                echo "     ----------------------- The DiskPath: $diskpath does not exists ------------------------"
                        fi  #end diskpath check
                else
                        echo "    ------------------ The path $path does not exists-------------------"
                fi #end path check




        done
done

#Get the size in kilobytes with commas
alltotalsizekb=`echo $alltotalsize |sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`

echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------------"
echo "Total Size of Files Moved: $alltotalsizekb kb"
echo ""

alltotalsize=$(( ${alltotalsize%% *} / 1048576))
alltotalsize=`echo $alltotalsize |sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`

echo "Total Size of Files Moved: $alltotalsize GB"
echo "-----------------------------------------"
