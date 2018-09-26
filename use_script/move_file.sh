############################################
# 把文件放到目录里
############################################

# 1.获取目录列表
L1=$(ls -d /home/kube/tt/资料库资料/小*)

# 2. 到目录内查找所有文件
for i in $L1;
do
	cd $i

	# 获取到文件列表
	FILE_LIST=$(ls -l --time-style='+%y-%m-%d %H:%M:%S'| grep '^-' | awk -F '[0-9]+:[0-9]+:[0-9]+ '  '{print $NF }')

	# 3. 查找到对应的文件,并创建目录

	IFS=$'\n'
	OLDIFS="$IFS"
	for f in    ${FILE_LIST}
	do
		echo "${i}/${f} 222222222222"
		# 包含后缀的文件名
		fullname=${f}
		# 文件名没有后缀
		filename=${fullname%.*}

		mkdir -pv ${i}/${filename}

		echo "mv ${i}/${f} ${i}/${filename} "
		# 4. 将文件移动到刚刚创建的目录
		mv ${i}/${f}    ${i}/${filename}

	done

	IFS="$OLDIFS"
	# 5. 返回上一级,目录

	cd ..
done
