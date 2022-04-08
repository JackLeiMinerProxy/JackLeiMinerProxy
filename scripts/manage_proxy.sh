#!/bin/bash
[[ $(id -u) != 0 ]] && echo -e "请在Root用户下运行安装该脚本" && exit 1

cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "这个安装脚本不支持你的系统" && exit 1
fi


install(){
    if [ -d "/root/JackLeiMinerProxy" ]; then
        echo -e "检测到您已安装JackLeiMinerProxy，请勿重复安装，如您确认您未安装请使用rm -rf /root/JackLeiMinerProxy指令" && exit 1
    fi
    if screen -list | grep -q "JackLeiMinerProxy"; then
        echo -e "检测到您的JackLeiMinerProxy已启动，请勿重复安装" && exit 1
    fi

    $cmd update -y
    $cmd install wget screen -y
    
    mkdir /root/JackLeiMinerProxy
    wget https://cdn.jsdelivr.net/gh/JackLeiMinerProxy/JackLeiMinerProxy@main/others/cert.tar.gz -O /root/JackLeiMinerProxy/cert.tar.gz --no-check-certificate
    tar -zxvf /root/JackLeiMinerProxy/cert.tar.gz -C /root/JackLeiMinerProxy
    wget https://cdn.jsdelivr.net/gh/JackLeiMinerProxy/JackLeiMinerProxy@main/scripts/run.sh -O /root/JackLeiMinerProxy/run.sh --no-check-certificate
    chmod 777 /root/JackLeiMinerProxy/run.sh
    
    wget https://files.catbox.moe/owqroq -O /root/JackLeiMinerProxy/JackLeiMinerProxy --no-check-certificate
    chmod 777 /root/JackLeiMinerProxy/JackLeiMinerProxy

    screen -dmS JackLeiMinerProxy
    sleep 0.2s
    screen -r JackLeiMinerProxy -p 0 -X stuff "cd /root/JackLeiMinerProxy"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'
    screen -r JackLeiMinerProxy -p 0 -X stuff "./run.sh"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'

    sleep 2s
    echo "JackLeiMinerProxy 999pro已经安装到/root/JackLeiMinerProxy"
    cat /root/JackLeiMinerProxy/pwd.txt
    echo ""
    echo "您可以使用指令screen -r JackLeiMinerProxy查看程式端口和密码"
}


uninstall(){
    read -p "您确认您是否删除JackLeiMinerProxy)[yes/no]：" flag
    if [ -z $flag ];then
         echo "您未正确输入" && exit 1
    else
        if [ "$flag" = "yes" -o "$flag" = "ye" -o "$flag" = "y" ];then
            screen -X -S JackLeiMinerProxy quit
            rm -rf /root/JackLeiMinerProxy
            echo "JackLeiMinerProxy已成功从您的伺服器上卸载"
        fi
    fi
}


update(){
    wget https://files.catbox.moe/owqroq -O /root/JackLeiMinerProxy --no-check-certificate

    if screen -list | grep -q "JackLeiMinerProxy"; then
        screen -X -S JackLeiMinerProxy quit
    fi
    rm -rf /root/JackLeiMinerProxy/JackLeiMinerProxy

    mv /root/JackLeiMinerProxy /root/JackLeiMinerProxy/JackLeiMinerProxy
    chmod 777 /root/JackLeiMinerProxy/JackLeiMinerProxy

    screen -dmS JackLeiMinerProxy
    sleep 0.2s
    screen -r JackLeiMinerProxy -p 0 -X stuff "cd /root/JackLeiMinerProxy"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'
    screen -r JackLeiMinerProxy -p 0 -X stuff "./run.sh"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'

    sleep 2s
    echo "JackLeiMinerProxy 已经更新至999pro版本并启动"
    cat /root/JackLeiMinerProxy/pwd.txt
    echo ""
    echo "您可以使用指令screen -r JackLeiMinerProxy查看程式输出"
}


start(){
    if screen -list | grep -q "JackLeiMinerProxy"; then
        echo -e "检测到您的JackLeiMinerProxy已启动，请勿重复启动" && exit 1
    fi
    
    screen -dmS JackLeiMinerProxy
    sleep 0.2s
    screen -r JackLeiMinerProxy -p 0 -X stuff "cd /root/JackLeiMinerProxy"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'
    screen -r JackLeiMinerProxy -p 0 -X stuff "./run.sh"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'
    
    echo "JackLeiMinerProxy已启动"
    echo "您可以使用指令screen -r JackLeiMinerProxy查看程式输出"
}


restart(){
    if screen -list | grep -q "JackLeiMinerProxy"; then
        screen -X -S JackLeiMinerProxy quit
    fi
    
    screen -dmS JackLeiMinerProxy
    sleep 0.2s
    screen -r JackLeiMinerProxy -p 0 -X stuff "cd /root/JackLeiMinerProxy"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'
    screen -r JackLeiMinerProxy -p 0 -X stuff "./run.sh"
    screen -r JackLeiMinerProxy -p 0 -X stuff $'\n'

    echo "JackLeiMinerProxy 已经重新启动"
    echo "您可以使用指令screen -r JackLeiMinerProxy查看程式输出"
}


stop(){
    screen -X -S JackLeiMinerProxy quit
    echo "JackLeiMinerProxy 已停止"
}


change_limit(){
    if grep -q "1000000" "/etc/profile"; then
        echo -n "您的系统连接数限制可能已修改，当前连接限制："
        ulimit -n
        exit
    fi

    cat >> /etc/sysctl.conf <<-EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100

net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768

# forward ipv4
# net.ipv4.ip_forward = 1
EOF

    cat >> /etc/security/limits.conf <<-EOF
*               soft    nofile          1000000
*               hard    nofile          1000000
EOF

    echo "ulimit -SHn 1000000" >> /etc/profile
    source /etc/profile

    echo "系统连接数限制已修改，手动reboot重启下系统即可生效"
}


check_limit(){
    echo -n "您的系统当前连接限制："
    ulimit -n
}


echo "======================================================="
echo "JackLeiMinerProxy 一键脚本，脚本默认安装到/root/JackLeiMinerProxy"
echo "                                   脚本版本：999pro"
echo "  1、安  装"
echo "  2、卸  载"
echo "  3、更  新"
echo "  4、启  动"
echo "  5、重  启"
echo "  6、停  止"
echo "  7、一键解除Linux连接数限制(需手动重启系统生效)"
echo "  8、查看当前系统连接数限制"
echo "======================================================="
read -p "$(echo -e "请选择[1-8]：")" choose
case $choose in
    1)
        install
        ;;
    2)
        uninstall
        ;;
    3)
        update
        ;;
    4)
        start
        ;;
    5)
        restart
        ;;
    6)
        stop
        ;;
    7)
        change_limit
        ;;
    8)
        check_limit
        ;;
    *)
        echo "请输入正确的数字！"
        ;;
esac