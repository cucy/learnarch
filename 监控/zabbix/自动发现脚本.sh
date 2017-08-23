#!/usr/bin/env bash

MQ_IP=192.168.1.19
MQ_PORT=8161
MQ_USER=admin
MQ_PASS=admin
zabbix_config_file=/etc/zabbix/zabbix_agentd.conf

CURL_2_FILE=/tmp/amq_status_out.log
SEND_2_ZABBIX=/tmp/zabbix_mq_status.log

ERROR_2_FILE=/tmp/zabbix_curl_error.log

URL="http://${MQ_IP}:${MQ_PORT}/admin/queues.jsp"

# 清空
>${CURL_2_FILE}
>${SEND_2_ZABBIX}


function curl_get_mq_msg(){

    curl  -u${MQ_USER}:${MQ_PASS} --connect-timeout 2 -s ${URL} | grep -A 2 "</a></td>" >${CURL_2_FILE}

    if [ $? -ne 0 ]; then
            echo "$(date "+%F %T") curl获取mq信息失败">>${ERROR_2_FILE}
            exit 1
    fi
}
curl_get_mq_msg


function mq_queues_discovery(){
    mq_lists=($(grep "</a></td>" ${CURL_2_FILE}|sed 's#</a></td>##'))

	printf '{\n'
	printf '\t"data":[\n'
	for((i=0;i<${#mq_lists[@]};++i))

	{
		num=$(echo $((${#mq_lists[@]}-1)))
		if [ "$i" != $num ];
		then
			printf "\t\t{ \n"
			printf "\t\t\t\"{#MQ_UEUES}\":\"${mq_lists[$i]}___pending_msg\"},\n"

			printf "\t\t{ \n"
			printf "\t\t\t\"{#MQ_UEUES}\":\"${mq_lists[$i]}___consumers\"},\n"
		else
		    printf "\t\t{ \n"
			printf "\t\t\t\"{#MQ_UEUES}\":\"${mq_lists[$i]}___pending_msg\"},\n"

			printf  "\t\t{ \n"
			printf  "\t\t\t\"{#MQ_UEUES}\":\"${mq_lists[$num]}___consumers\"}]}\n"
		fi
	}

}



function fmt_mq_msg(){
# 队列列表
QUEUES_LIST=($(grep "</a></td>" ${CURL_2_FILE}|sed 's#</a></td>##'))

# 遍历队列列表
for key in ${QUEUES_LIST[@]}
do

	values=($(grep -A 2 "$key</a></td>" ${CURL_2_FILE} | sed -ne '2,$p' |grep -o '[0-9]*'))

	declare -i  x=0
	for value in  ${values[@]}
	do
		if [ "$x" -eq 0 ]; then
		    # 被阻塞消息数量
			echo "- ${key}___pending_msg ${value}">> ${SEND_2_ZABBIX}

		elif [ "$x" -eq 1 ]; then
		    # 连接客户端数量
			echo "- ${key}___consumers ${value}" >> ${SEND_2_ZABBIX}
		fi
		x+=1
	done

done
}



function send_2_zabbix_server(){
    fmt_mq_msg
    zabbix_sender -c ${zabbix_config_file} -i ${SEND_2_ZABBIX}  >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo 1
    else
        echo 0
    fi
}


case "$1" in
    mq_queues_discovery)
        mq_queues_discovery
        ;;

    send_2_zabbix_server)
        send_2_zabbix_server
        ;;

    debug)
        mq_queues_discovery
        printf '**************************\n'
        fmt_mq_msg
        cat ${SEND_2_ZABBIX}
        ;;

    *)
        echo "Usage:$0 {mq_queues_discovery}"
        ;;
esac



