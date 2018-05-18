#!/bin/bash

###############################################
#   必须改参数
#   TOMCAT_BASE_NAME 
#   TOMCAT_BIN_DIR
#   TOMCAT_WEB_DIR
#
#   上传项目到目录为:
#     /opt/${TOMCAT_BASE_NAME}/upload  
###############################################
# BASENAME 
TOMCAT_BASE_NAME="tomcat03"

# tomcat脚本文件路径
TOMCAT_BIN_DIR="/usr/java/tomcat03/apache-tomcat-8.5.30/bin"
# tomcat web部署路径
TOMCAT_WEB_DIR="/usr/java/tomcat03/apache-tomcat-8.5.30/webapps"


# 上传项目目录
PROJECT_DATA_BASE_DIR=/opt
UPLOAD_DIR="${PROJECT_DATA_BASE_DIR}/${TOMCAT_BASE_NAME}/upload"
# 所有解压历史
HISTORY_DIR="${PROJECT_DATA_BASE_DIR}/${TOMCAT_BASE_NAME}/history"
# 项目软链接
CURRENT_DIR="${PROJECT_DATA_BASE_DIR}/${TOMCAT_BASE_NAME}/current"
# 当前时间 年-月-日_时-分-秒
CURRENT_TIME=$(date +"%F_%H-%M-%S")






# 创建上传目录和解压目录(项目目录)
if ! [[ -d ${UPLOAD_DIR} || -d  ${HISTORY_DIR} ]]; then
echo "创建项目目录${UPLOAD_DIR}   ${HISTORY_DIR}"
mkdir -p  ${UPLOAD_DIR} 
mkdir -p  ${HISTORY_DIR}

fi


# 判断是否已经上传
CHANGE_TO_UPLOAD_DIR=$(cd ${UPLOAD_DIR};pwd)
HAVE_DATA=$(ls ${CHANGE_TO_UPLOAD_DIR} | wc -l )

	if [[ ${HAVE_DATA} == 0 ]]; then
	echo -e "\033[31m没有上传项目到${UPLOAD_DIR}, 退出\033[0m"     
	exit 1
	fi

	if [[ $HAVE_DATA -ne 1 ]]; then
	echo -e "\033[31m项目目录${UPLOAD_DIR},必须有war包,且只有一个war压缩包,退出\033[0m"
	exit 1
	fi


	UPLOAD_WAR_NAME=$(cd ${UPLOAD_DIR};ls)

FULL_NAME=$(/usr/bin/basename -- ${UPLOAD_WAR_NAME})
# EXT_NAME="${filename##*.}"
	FILE_NAME="${FULL_NAME%.*}"

# 将指向目录
	PREPARE_NAME="${HISTORY_DIR}/${CURRENT_TIME}__${FILE_NAME}"

# 解压项目 
	/usr/bin/unzip -oq  ${UPLOAD_DIR}/${UPLOAD_WAR_NAME} -d ${PREPARE_NAME}

	if [[ $? -ne 0 ]]; then
	echo "解压文件失败"
	exit 1
	fi
	echo -e "\033[32m启动解压项目${UPLOAD_DIR}/${UPLOAD_WAR_NAME} --> ${PREPARE_NAME}成功\033[0m"

# 停止tomcat
	cd ${TOMCAT_BIN_DIR}; ./shutdown.sh 


	echo "删除原来软链接,重新建立新连接,指向新上传项目"
	if ! [[ -z ${CURRENT_DIR}  ]]; then
	echo "111"
	unlink ${CURRENT_DIR} || echo -e "\033[31m删除 ${CURRENT_DIR} 失败\033[0m"

	fi
	ln -sv ${PREPARE_NAME}  ${CURRENT_DIR}

# 删除上传的文件
cd ${UPLOAD_DIR} && FILE_LIST=$(ls -l |wc -l )
	if ! [[ -z ${FILE_LIST} ]]; then
	cd ${UPLOAD_DIR} && rm -rf *
	fi


# 删除ROOT目录

	if [[ -d ${TOMCAT_WEB_DIR}/ROOT ]]; then
	cd ${TOMCAT_WEB_DIR}; rm  -rf ./ROOT 
# 创建新的连接指向
	ln -sv      ${CURRENT_DIR}        ${TOMCAT_WEB_DIR}/ROOT 
	echo -e "\033[32m创建新的连接指向:${CURRENT_DIR} -->  ${TOMCAT_WEB_DIR}/ROOT \033[0m"
	fi

# 启动tomcat
	cd ${TOMCAT_BIN_DIR}; ./startup.sh

	echo -e "\033[32m启动${TOMCAT_BASE_NAME}成功\033[0m"
