# RLM for Linux

## Overview

The RLM (Reprise License Manager) can be used to provide, with public or private cloud, a way to storage, manage and activate licenses.

## File structure

- head.txt : A script header
- library.sh : All bash functions implemented
- vars.conf : All global vars that you need to configure or customize
- main.sh : Where the logic is implemented
- tail.txt : A script tail
- create_end_user_script.sh : Will create the script to setup RLM for Linux. By default will be rlm_server_install.sh

## How to setup

1. If needed, configure or customize vars.conf
2. Execute the script
```bash
bash create_end_user_script.sh
```

3. Then copy the script rlm_server_install.sh to the Linux server and executer:
```bash
bash rlm_server_install.sh
```

4. Follow all the questions
