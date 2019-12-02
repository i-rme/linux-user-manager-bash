#!/bin/bash
# User Manager v1.0 by Raul Martinez

if [ "$EUID" -ne 0 ]
  then echo "ERROR - Please run this script as root"
  exit
fi


done=0

while [ $done -ne 1 ]
do

# Display Menu
clear
echo -e "\n"
echo "  ######################################################################"
echo "  ###########  User Manager v1.0 by Raul Martinez ######################"
echo "  ######################################################################"
echo -e "\n"
echo "  ######################################################################"
echo "  ##                                                                  ##"
echo "  ##  Choose an option from the ones listed below by typing           ##"
echo "  ##  a number and pressing [Enter]                                   ##"
echo "  ##                                                                  ##"
echo "  ##  ( 1 ) - Add a user                                              ##"
echo "  ##  ( 2 ) - Remove a user                                           ##"
echo "  ##  ( 3 ) - Perform a backup of a user                              ##"
echo "  ##  ( 4 ) - Restore a user from a backup                            ##"
echo "  ##  ( 5 ) - Exit                                                    ##"
echo "  ##                                                                  ##"
echo "  ######################################################################"
echo -e "\n"

read option

case $option in
     1)
        clear
echo -e "\n"
echo "  ######################################################################"
echo "  ##                         Adding a user                            ##"
echo "  ######################################################################"
echo -e "\n"

echo "Enter the username: (Example: john)"
read username

echo "Enter the home folder: (Example: /home/john)"
read home_folder

echo "Enter the login shell: (Example: /bin/bash)"
read login_shell

echo "Enter the user info: (Example: City,Country,Email)"
read user_info

echo "Thanks"

echo "Adding user..."
adduser --home $home_folder --shell $login_shell --gecos $user_info $username
echo "Finished."

        ;;
     2)
        clear
echo -e "\n"
echo "  ######################################################################"
echo "  ##                         Remove a user                            ##"
echo "  ######################################################################"
echo -e "\n"

echo "Enter the username or UID of the user: (Example: John OR 1000)"
read username_or_uid

# UID to username conversion, it works if the input is already an username
username=$(id -nu $username_or_uid)

echo "Are you sure that you want to delete user $username and all its files?"
echo "This action cannot be undone. Write \"delete\" to confirm."

read del_confirmation

if [ $del_confirmation = "delete" ]
then
        echo "Thanks"
        #find / -user $username -exec ls -ltr {} \; 2>/dev/null
        find / -user $username -exec rm {} \; 2>/dev/null
        userdel -r $username
        echo "Finished."

else
        echo "Canceled by user, returning to the menu..."
fi

sleep 3
        ;;
     3)
        clear
echo -e "\n"
echo "  ######################################################################"
echo "  ##                   Perform a backup of a user                     ##"
echo "  ######################################################################"
echo -e "\n"

# Create a directory to store all files related to this script
mkdir -p /tmp/UserManagerRME/

echo "Enter the username or UID of the user: (Example: John OR 1000)"
read username_or_uid

# UID to username conversion, it works if the input is already an username
username=$(id -nu $username_or_uid)



# Backup user in /etc/passwd
# ":" at the end of the username to avoid partial matching of other users
# "^: at the start of the username to only match begining of the line
grep ^$username: /etc/passwd > /tmp/UserManagerRME/${username}_passwd.txt

# Backup password in /etc/shadow
# ":" at the end of the username to avoid partial matching of other users
# "^: at the start of the username to only match begining of the line
grep ^$username: /etc/shadow > /tmp/UserManagerRME/${username}_shadow.txt

# Backup group in /etc/group
# ":" at the end of the username to avoid partial matching of other users
# "^: at the start of the username to only match begining of the line
grep ^$username: /etc/group > /tmp/UserManagerRME/${username}_group.txt

# Change ownership, this way they get included in the backup
chown $username /tmp/UserManagerRME/${username}_passwd.txt
chown $username /tmp/UserManagerRME/${username}_shadow.txt
chown $username /tmp/UserManagerRME/${username}_group.txt


#date=$( date +%Y-%m-%d_%H:%M:%S )

#The -print0 and -T work together to allow filenames with spaces newlines
#The final - tells tar to read the input filenames from standard input
# -xdev -type d tells find to not look on /proc and other virtual devices
find / -user $username -print0 2>/dev/null | tar -zcvf /tmp/UserManagerRME/userbackup_${username}.tar.gz --null -T -

# Delete temporal files as they are already included in the backup
rm /tmp/UserManagerRME/${username}_passwd.txt
rm /tmp/UserManagerRME/${username}_shadow.txt
rm /tmp/UserManagerRME/${username}_group.txt



sleep 3
        ;;
     4)
        clear
echo -e "\n"
echo "  ######################################################################"
echo "  ##                   Restore a user from a backup                   ##"
echo "  ######################################################################"
echo -e "\n"

echo "Enter the username of the user: (Example: John OR 1000)"
read username

if [ ! -f /tmp/UserManagerRME/userbackup_${username}.tar.gz ]
then
    echo "No backup found for user $username."
else
    tar -xf /tmp/UserManagerRME/userbackup_${username}.tar.gz --directory /

    cat /tmp/UserManagerRME/${username}_passwd.txt >> /etc/passwd
    cat /tmp/UserManagerRME/${username}_shadow.txt >> /etc/shadow
    cat /tmp/UserManagerRME/${username}_group.txt >> /etc/group

    rm /tmp/UserManagerRME/${username}_passwd.txt
    rm /tmp/UserManagerRME/${username}_shadow.txt
    rm /tmp/UserManagerRME/${username}_group.txt
    echo "Successfully restored $username's backup."
fi
sleep 3
        ;;
     5)
        clear
        done=1
echo -e "\n"
echo "  ######################################################################"
echo "  ##                            Goodbye!                              ##"
echo "  ######################################################################"
echo -e "\n"
echo "  Exiting..."
        sleep 2
        clear
        ;;
     *)
        clear
echo -e "\n"
echo "  ######################################################################"
echo "  ##  INFO: Incorrect option choosen, select an option from 1 to 5.   ##"
echo "  ######################################################################"
echo -e "\n"
echo "  Returning to menu..."
        sleep 3
        ;;
esac

done

exit 0
