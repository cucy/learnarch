#!/bin/bash
# 源视频地址dir
# soure_vd_dir="/home/weblogs/video_temp_170829/record01/video_170828"
soure_vd_dir="/home/weblogs/video_temp_170829/record02/video_170828"
# 所有视频列表
vd_lists=$(ls $soure_vd_dir)

# php获取视频信息输出到临时文件
    php_out_2_file=$(pwd)/tmp1.zrd

# 视频保存目录(基目录)
    vd_link_dir="/home/ops_zhourudong/video"
# cd /home/ops_zhourudong/video && rm -rf * 

    zphp (){
# 获取视频信息
        php /home/internal_wwwroot/buka_video_name/buka.php "$@"

    }



index=0
for i in ${vd_lists[@]}
do 
    # 视频全名
    video_name=${i} 

    # 视频名,去掉扩展
    video_file_name="${video_name%.*}"  
    # 视频扩展名
    video_extension_name="${video_name##.*}" 

    # 获取文件信息
    php /home/internal_wwwroot/buka_video_name/buka.php ${video_file_name} >${php_out_2_file}

    # 获取老师、学生手机号
    teacher_phone_num=$(grep -A 1 teacher_account ${php_out_2_file} | tail -1 | grep -o '[0-9]\+') || continue
    student_phone_num=$(grep -A 1 student_account ${php_out_2_file} | tail -1 | grep -o '[0-9]\+') || continue

    # 创建视频存放目标 目录
    vd_dst_dir="${vd_link_dir}/teacher_${teacher_phone_num}_student_${student_phone_num}"
    mkdir -p ${vd_dst_dir}

    # 硬链接
    ln ${soure_vd_dir}/${video_name} ${vd_dst_dir}/${video_name}
    echo "创建视频硬链接成功  ${soure_vd_dir}/${video_name} ${vd_dst_dir}/${video_name}"
    # echo $ret
    # break

    let index++
done



# dont_use (){ 

# for ((i=0;i<${#vd_lists[@]}; i++))
# do
#   php /home/internal_wwwroot/buka_video_name/buka.php  "${vd_lists[${i}]}" 
#   sleep 2

# done

# }
