main()
{
	welcomeInstructions
	if checkIfLicenseFileExist
	then
		if checkIfLicenseFileIsConfigured
		then
			if checkIfHostnameIsResolvable
			then
				setupRlmServer
				finishedSetup
			else
				echo "The hostname >>> $server_hostname <<< is not resolvable to an IP address. Please fix your >>> /etc/hostname <<< file and, if is necessary, add it to /etc/hosts to be resolved locally. Exitting..."
				exit 3
			fi
		else
			echo "The DCV License config under file >>> $dcv_config_file <<< with the pattern >>> $dcv_license_file_regex <<< was not found. Please configure your >>> $dcv_config_file <<< config file with >>> $dcv_license_file_regex <<< under [license] section. Exitting..."
			exit 2
		fi
	else
		echo "The License file >>> $license_file <<< does not exist. Please copy your license file to >>> $license_file  <<<. Exitting..."
		exit 1
	fi
	
	exit 0
}

main
