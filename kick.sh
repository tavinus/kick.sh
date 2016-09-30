#!/usr/bin/env bash

#########################################################################
# kick.sh
#
# Kicked by Console :)
# A Simple Bash User Manager
# Makes easy to kick users or close user sessions
#
# Author....: Gustavo Arnosti Neves
# Created...: 29 Sept 2016
#
# Github....: 
# 
#
#########################################################################

KICK_VERSION="0.2.3"




################################################################
############################# MAIN #############################
################################################################


####### MAIN VARIABLES
WHOU=""        # Gets Who -u response string
WHOLIST=()     # Array with lines from $WHOU
USERLIST=()    # Array to hold UNIQUE user names
SESSCOUNT=0    # Number of open sessions
USERCOUNT=0    # Number of users connected
ROPTION=""     # Menu Option to Run
RSTAT=()       # Status messages


####### MAIN FUNCTION
main() {
    localize_start
    check_sudo
    while true; do
        get_who_list
        get_users
        print_menu # will exit from here if told to
    done
    exit 1         # should never get here
}




################################################################
##################### GET USERS / SESSIONS #####################
################################################################


####### Updates list of users / sessions
get_who_list() {
    WHOU=$(who -u)                  # Get Who -u list
    mapfile -t WHOLIST <<< "$WHOU"  # Map Who -u to array
    SESSCOUNT=${#WHOLIST[@]}        # reset session count
}


####### Creates unique users list
get_users() {
    USERLIST=()                      # reset user list
    for u in "${WHOLIST[@]}"; do     # get users
        USERLIST+=($(echo -ne "$u" | awk '{print $1}'))
    done
    # Remove duplicated items
    USERLIST=($(printf "%s\n" "${USERLIST[@]}" | sort -u))
    USERCOUNT=${#USERLIST[@]}       # Reset user count
}




################################################################
######################## MENU HANDLING #########################
################################################################

print_banner() {
    echo $'\n'"Kick! v$KICK_VERSION by Tavinus"$'\n'
}

####### Print User List on Menu
print_users() {
    echo ""
    localize_print "${M_KILL_USER[@]}"
    echo ""
    for u in "${!USERLIST[@]}"; do     # print all users
        mi=$((u + 1))                  # menu item tracking
        [[ $mi -lt 10 ]] && mi=" $mi"  # text formatting (up to 99)
        printf "    [ %s ]\t%s\n" "$mi" "${USERLIST[$u]}"
    done
}


####### Print Sessions List on Menu
print_sessions() {
    echo ""
    localize_print "${M_KILL_SESSION[@]}"
    echo ""
    for s in "${!WHOLIST[@]}"; do
        mi=$((s + USERCOUNT + 1))
        [[ $mi -lt 10 ]] && mi=" $mi"
        printf "    [ %s ]\t%s\n" "$mi" "${WHOLIST[$s]}"
    done
}


####### Prints Main Menu to screen
print_menu() {
    ROPTION=""
    clear
    print_banner
    localize_print "${M_CHOOSE_OPTION[@]}"
    echo $'\n'
    localize_print "${M_CONNECTED_USERS[@]}"
    echo " $USERCOUNT"
    localize_print "${M_OPEN_SESSIONS[@]}"
    echo " $SESSCOUNT"
    print_users
    print_sessions
    if [[ "${#RSTAT[@]}" > "0" ]]; then
        echo -ne $'\n'"Status: "; localize_print "${RSTAT[@]}"; echo ""
        RSTAT=()
    fi
    echo ""; localize_print "${M_ENTER_OPTION[@]}"
    read ROPTION
    run_command
}




################################################################
##################### COMMAND PROCESSING #######################
################################################################


#######Check if the user confirmed an action (with localization)
read_yes() {
    local y_answer="${M_Y[$LANG_INDEX]}"
    local yes_answer="${M_YES[$LANG_INDEX]}"
    if [[ ${1,,} = "$y_answer" ]] || [[ ${1,,} = "$yes_answer" ]]; then
        return 0
    fi
    return 1
}


####### Run a command from the menu
run_command() {
    total_options=$((SESSCOUNT + USERCOUNT + 1))
    user_options=$((USERCOUNT + 1))
    if [[ -z $ROPTION ]]; then
        RSTAT=("${M_BLANK_COMMAND[@]}")
        return 1
    elif [[ ${ROPTION,,} = "q" ]] || [[ ${ROPTION,,} = "quit" ]] || [[ ${ROPTION,,} = "exit" ]]; then
        echo "Ciao!"$'\n'
        exit 0
    elif [[ "$ROPTION" > "0" ]] && [[ "$ROPTION" < "$total_options" ]]; then
        if [[ "$ROPTION" < "$user_options" ]]; then
            opt_index=$(($ROPTION - 1))
            user_name="${USERLIST[$opt_index]}"
            localize_refresh
            echo ""; localize_print "${M_CONFIRM_USER[@]}"
            echo ""; localize_print "${M_YES_TO_CONFIRM[@]}"
            read answer
            if read_yes "$answer"; then
                RSTAT=("${M_USER_KICKED[@]}")
                killall -u "$user_name" -HUP
            else
                RSTAT=("${M_USER_KICK_CANCELLED[@]}")
            fi
        else
            opt_index=$(($ROPTION - 1 - USERCOUNT))
            session_string="${WHOLIST[$opt_index]}"
            s_pid="$(echo -ne "$session_string" | awk '{print $6}')"
            localize_refresh
            echo ""; localize_print "${M_CONFIRM_SESSION[@]}"
            echo $'\n'"$session_string"
            echo ""; localize_print "${M_YES_TO_CONFIRM[@]}"
            read answer
            if read_yes "$answer"; then
                RSTAT=("${M_SESSION_CLOSED[@]}")
                kill "$s_pid"
            else
                RSTAT=("${M_SESSION_CLOSE_CANCELLED[@]}")
            fi
        fi
        return 0
    else
        localize_refresh
        RSTAT=("${M_INVALID_COMMAND[@]}")
        return 1
    fi
    return 1
}




################################################################
######################### LOCALIZATION #########################
################################################################


####### Defines languages and check current language
localize_start() {
    # LANG="pt_BR.iso88591"        # Set LANG manually here if you want
    #LANG="en_US.utf8"             # Set LANG manually here if you want
    LOCALIZED=("en_US" "pt_BR")    # add localization here if implemented
                                   # the order is important, at to the end
    LANG_COUNTRY=${LANG%.*}        # Uses Env Var LANG to set location
    if [[ -z $LANG ]] || ! [[ " ${LOCALIZED[@]} " =~ " $LANG_COUNTRY " ]]; then
        LANG="en_US.utf8"          # Use English if not found
        LANG_COUNTRY=${LANG%.*}
    fi

    LANG_INDEX=0                   # Index of language to use for messages
    for i in "${!LOCALIZED[@]}"; do
       if [[ "${LOCALIZED[$i]}" = "${LANG_COUNTRY}" ]]; then
           LANG_INDEX=$i;          # Set Index
       fi
    done

    localize_define
    return $?
}


####### Defines static messages
localize_define() {
    M_NEED_ROOT=("You need root privileges to run this script." "Voce precisa rodar esse script como root.")
    M_TRY=("Try:" "Tente:")
    M_KILL_USER=("Kill all sessions for a user:" "Matar todas as sessoes de um usuario:")
    M_KILL_SESSION=("Kill specific session:" "Matar sessao especifica:")
    M_BLANK_COMMAND=("Empty option, choose a number from the list" "Comando em branco, escolha um numero na lista")
    M_Y=("y" "s")
    M_YES=("yes" "sim")
    M_YES_TO_CONFIRM=("[\"${M_Y[0]}\" or \"${M_YES[0]}\" to confirm]: " "[\"${M_Y[1]}\" ou \"${M_YES[1]}\" para confirmar]: ")
    M_CONFIRM_SESSION=("Are you sure that you want to disconnect the session:" "Tem certeza que deseja desconectar o a sessao:")
    M_CHOOSE_OPTION=("Choose an option below by entering its number." "Escolha uma das opcoes abaixo, usando o numero do item.")
    M_ENTER_OPTION=("Enter desired option [\"q\" or \"quit\" to leave]: " "Entre com a opcao desejada [\"q\" ou \"quit\" para sair]: ")
    M_CONNECTED_USERS=("  Connected Users:" "  Usuarios conectados:")
    M_OPEN_SESSIONS=(  "    Open Sessions:" "      Sessoes Abertas:")
    return 0
}


####### Refresh localization text with current variables
localize_refresh() {
    M_CONFIRM_USER=("Are you sure that you want to kick the user \"$user_name\" ?" "Tem certeza que deseja desconectar o usuario \"$user_name\" ?")
    M_USER_KICKED=("The user \"$user_name\" was kicked from the system" "O usuario \"$user_name\" foi desconectado do sistema")
    M_USER_KICK_CANCELLED=("Kicking the user \"$user_name\" was cancelled / not confirmed" "Desconectar usuario \"$user_name\" cancelado / nao confirmado")
    M_SESSION_CLOSED=("The process with PID \"$s_pid\" was killed." "O processo com PID \"$s_pid\" foi morto.")
    M_SESSION_CLOSE_CANCELLED=("Killing process with PID \"$s_pid\" was cancelled / not confirmed" "Matar processo com PID \"$s_pid\" cancelado / nao confirmado")
    M_INVALID_COMMAND=("Invalid Command, the option \"$ROPTION\" was not available" "Comando invalido, a opcao \"$ROPTION\" nao estava disponivel")
    return 0
}


####### Prints localized messages to screen
localize_print() {
    if [[ "${#@}" > "${#LOCALIZED[@]}" ]]; then
        error_print "function localize_print(): Invalid number of parameters"
        return 65
    fi
    local params=("$@")
    echo -ne "${params[$LANG_INDEX]}"
    return 0
}




################################################################
########################## LOGGING #############################
################################################################

####### Prints error message to stderr
error_print() {
    echo "ERROR: $1" >&2
    return 0
}




################################################################
########################### CHECKS #############################
################################################################


####### Check sudo / root
check_sudo() {
    if [ "$(id -u)" != "0" ]; then
        print_banner
        localize_print "${M_NEED_ROOT[@]}"
        echo $'\n'
        localize_print "${M_TRY[@]}"
        echo ""
        echo "  sudo $0"$'\n'
        exit 1
    fi
}




################################################################
############################ RUN ###############################
################################################################


main "$@"




####### Should never get here
exit 1 
