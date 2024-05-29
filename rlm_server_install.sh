#!/bin/bash
################################################################################
# Copyright (C) 2019-2024 NI SP GmbH
# All Rights Reserved
#
# info@ni-sp.com / www.ni-sp.com
#
# We provide the information on an as is basis.
# We provide no warranties, express or implied, related to the
# accuracy, completeness, timeliness, useability, and/or merchantability
# of the data and are not liable for any loss, damage, claim, liability,
# expense, or penalty, or for any direct, indirect, special, secondary,
# incidental, consequential, or exemplary damages or lost profit
# deriving from the use or misuse of this information.
################################################################################

finishedSetup()
{
	echo "The setup was finished. Please check the systemctl RLM daemon status with >>> systemctl status rlm <<< command."
}

welcomeInstructions()
{
	clear
	echo "This script will setup the RLM server."
	echo "Before proceed, you need to prepare the environment. Please check if:"
	echo "- Copy your license file to >>> $license_file <<<."
	echo "- Configure your >>> $dcv_config_file <<< config file to have >>> $dcv_license_file_regex <<< unique line."
	echo "- Check if the server hostname is a FQDN. The command >>> hostname --ip-address <<< must return a valid ipv4."
	echo "If your environment meets all requirements, please press enter. Or ctrl+c if not."
	read p
}

checkIfLicenseFileExist()
{
	if [ -f $license_file ]
	then
		true
	else
		false
	fi
}

checkIfLicenseFileIsConfigured()
{
	if sudo cat $dcv_config_file | egrep -i "^license-file" | tr -d '[:space:]' | egrep -iq $dcv_license_file_regex
	then
		true
	else
		false
	fi
}

checkIfHostnameIsFqdn()
{
	sudo host $server_hostname 2>&1 > /dev/null
	if [ $? -eq 0 ]
    then
		true
	else
		false
	fi
}

setupRlmServer()
{
	if ! sudo getent group $rlm_group >/dev/null
	then
		sudo groupadd -r $rlm_group
	fi

	if ! id $rlm_user >/dev/null 2>&1
	then
		sudo useradd -r -g $rlm_group -d "/opt/nice/rlm" -s /sbin/nologin -c "RLM License Server" $rlm_user
	fi

	sudo mkdir -p /opt/nice/rlm/license

	wget --no-check-certificate ${rlm_url}
	if [[ "$?" != "0" ]]
	then
		echo "Problem downloading >>> ${rlm_url} <<<. Aborting..."
		exit 2
	fi

	sudo tar xf $rlm_filename -C /opt/nice/rlm/ --strip-components 1
	sudo chown -R rlm:rlm /opt/nice/rlm
	sudo cp $license_file /opt/nice/rlm/license/
	sudo cp /usr/share/dcv/license/nice.set /opt/nice/rlm/

	sudo cat <<EOF> /usr/lib/systemd/system/rlm.service
[Unit]
Description=Reprise License Manager Server
After=network.target

[Service]
Type=simple
WorkingDirctory=/opt/nice/rlm/
ExecStart=/opt/nice/rlm/rlm -c /opt/nice/rlm/license -nows -dlog +/var/log/rlm.log
ExecStop=/opt/nice/rlm/rlmutil rlmdown RLM -c /opt/nice/rlm/license -q
User=$rlm_user
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

	sudo systemctl daemon-reload
	sudo systemctl enable --now rlm.service
}

# global vars
license_file="/etc/dcv/license.lic"
dcv_config_file="/etc/dcv/dcv.conf"
dcv_license_file_regex="license-file=\"/etc/dcv/license.lic\""
server_hostname=$HOSTNAME
rlm_url="https://www.ni-sp.com/wp-content/uploads/2019/10/rlm_15.1_linux_x64_l1.admin.tar.gz"
rlm_filename=$(basename "${rlm_url}")
rlm_user="rlm"
rlm_group="rlm"

main()
{
	welcomeInstructions
	if checkIfLicenseFileExist
	then
		if checkIfLicenseFileIsConfigured
		then
			if checkIfHostnameIsFqdn
			then
				setupRlmServer
				finishedSetup
			else
				echo "The hostname >>> $server_hostname <<< is not FQDN. Please fix your >>> /etc/hostname <<< file and, if is necessary, add it to /etc/hosts to be resolved locally. Aborting..."
				exit 3
			fi
		else
			echo "The DCV License config under file >>> $dcv_config_file <<< with the pattern >>> $dcv_license_file_regex <<< was not found. Please configure your >>> $dcv_config_file <<< config file with >>> $dcv_license_file_regex <<<. Aborting..."
			exit 2
		fi
	else
		echo "The License file >>> $license_file <<< does not exist. Please copy your license file to >>> $license_file  <<<. Aborting..."
		exit 1
	fi
	
	exit 0
}

main

# unknown error
exit 255
