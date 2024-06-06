# RLM for Linux

## Overview

The RLM (Reprise License Manager) can be used to provide, with public or private cloud, a way to storage, manage and activate licenses.

## How to setup

Download and execute this script:

```bash
bash rlm_server_install.sh
```

You can also check last releases here: https://github.com/NISP-GmbH/RLM_for_Linux/releases

## Customizing the script

### File structure

- head.txt : A script header
- library.sh : All bash functions implemented
- vars.conf : All global vars that you need to configure or customize
- main.sh : Where the logic is implemented
- tail.txt : A script tail
- create_end_user_script.sh : Will create the script to setup RLM for Linux. By default will be rlm_server_install.sh

### Customizing

You can edit any file that you want, and then execute:
```bash
bash create_end_user_script.sh
```
It will create the rlm_server_install.sh installer.
