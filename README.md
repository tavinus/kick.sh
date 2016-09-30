# kick.sh
Simple BASH script to kick users from a Linux server. 

The system manager can choose to kill all sessions from an user, or a specific session. 

Requires root privileges to run. 

## Dependencies
The script uses `awk` and `who`, which are usually installed by default.
 
## Localization
The script uses the environmental variable $LANG to define its language.
If an unsupported language is detected, the script will run in English.
 
#### Current Supported Languages
 - en_US
 - pt_BR
 
If you want to force a language, you can use something like:
`LANG="en_US.utf8" ./kick.sh`
 
Please note that even though the variable `$LANG` requires the encoding,
kick.sh only uses the language part of the string to define the display language.
 
So if `$LANG` is either `"pt_BR.utf8"` or `"pt_BR.iso88591"` would be the same
for the display language.
 
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
 
## Methods of kicking

Uses `killall -u <username> -HUP` to kick a user.
Uses `kill <PID>` to kill a specific session.


## Wish List
- Option to use `kill -9` in a session
- Option to send message to the user that is going to be kicked, with sleep before killing
- Force language with cli parameter
