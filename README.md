# kick.sh
Simple BASH script to kick users from a Linux/Unix box.  
 

![Alt text](/../screenshots/kick-user.png?raw=true "Kicking a user") 

The system manager can choose to kill all sessions from an user, or a specific session. 

The script runs interactively and asks for confirmation before killing anything.  

Requires *root* privileges to run. 

## Disclaimer

***Be advised that killing ssh sessions with programs open can have many adverse effects on your system!*** 

You should know what you are doing and I take no responsibility for any damage caused by this script.  
You should take full responsibility when kicking people on their faces, balls, or their open vi document. 

From version 0.3.3 (or greater), kick.sh will show the user's process tree with `pstree` before confirming the kick.

## Dependencies

The script uses `awk`, `sort`, `who`, `killall`, `pstree` and `kill`, all of which are usually installed by default.

## Methods of kicking

Uses `who -u` to get the list of users and sessions. 

Uses `killall -u <username> -HUP` to kick a user. 

Uses `kill <PID>` to kill a specific session. 

Uses `pstree -npsu <username>` to show user's processes before kicking a user.

## Localization
The script uses the environmental variable `$LANG` to define its language. 

If an unsupported language is detected, the script will run in English. 

#### Currently Supported Languages
 - en_US
 - pt_BR
 
#### If you want to force a language, you can use something like:

```
LANG="en_US.utf8" sudo ./kick.sh
```  
```
LANG="pt_BR.iso88591" sudo ./kick.sh
```

Please note that even though the variable `$LANG` requires the encoding,
kick.sh only uses the language part of the string to define the display language. 
 
So if `$LANG` is either `"pt_BR.utf8"` or `"pt_BR.iso88591"` would be the same for the display language. 
 
## Makefile / Install

The Makefile will install the script as `kick` (without the .sh) to `/usr/bin`. 

Please change the makefile variables if you want to install it somewhere else or with another name. 

#### To install:
```
sudo make install
```

#### To Uninstall
```
sudo make uninstall
```

## Wish List
- Option to use `kill -9` in a session
- Option to send message to the user that is going to be kicked, with sleep before killing
- Force language with cli parameter
