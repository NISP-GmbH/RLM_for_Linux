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
	echo "- Check if the server hostname is resolvable to an IP address. The command >>> hostname --ip-address <<< must return a valid ipv4."
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

checkIfHostnameIsResolvable()
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
