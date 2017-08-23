# touch /usr/share/command.log
export HISTORY_FILE=/usr/share/command.log
PS1="\[\e[0;1m\]┌─( \[\e[31;1m\]\u\[\e[0;1m\] ) - ( \[\e[32;1m\]\H\[\e[0;1m\] )- ( \[\e[36;1m\]\w\[\e[0;1m\] )- ( \[\e[33;1m\]\d \t\[\e[0;1m\] )\n└─> \[\e[0m\]"
export HISTTIMEFORMAT="{\"TIME\":\"%F %T\",\"HOSTNAME\":\"$(ip a l eth1 | awk -F'[/ ]+' '/inet[^6]/{print $3}' | grep -v "127.0.0.1")\",\"LI\":\"$(who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g')\",\"LU\":\"$(who am i|awk '{print $1}')\",\"NU\":\"$(id|awk "{print \$1}")\",\"CMD\":\""
export PROMPT_COMMAND='history 1|tail -1|sed "s/^[ ]\+[0-9]\+  //"|sed "s/$/\"}/">> $HISTORY_FILE'
