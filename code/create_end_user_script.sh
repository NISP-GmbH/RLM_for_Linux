#!/bin/bash

# create the end user script

end_user_script_name="../rlm_server_install.sh"

if [ -f $end_user_script_name ]
then
    rm -f $end_user_script_name
fi

cat head.txt > $end_user_script_name
echo "" >> $end_user_script_name
cat library* >> $end_user_script_name
echo "" >> $end_user_script_name
cat vars.conf >> $end_user_script_name
echo "" >> $end_user_script_name
cat main.sh >> $end_user_script_name
echo "" >> $end_user_script_name
cat tail.txt >> $end_user_script_name
chmod +x $end_user_script_name
