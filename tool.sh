#! /bin/bash

red="\033[31m"
black="\033[0m"
main(){
echo -e "${black}       			 ————————————杰森工具箱————————————"
echo -e "${black}       ————————————对接适配centos7和Ubuntu16，其他系统待测试————————————"
echo -e "${red}1. sogav2"
echo -e "${red}2. 安装speedtest"
echo -e "${red}3. xrayr"
echo -e "${red}4. 加速脚本安装${black}:(推荐使用BBR2或BBRPlus)"
echo -e "${red}5. 安装Brook"
echo -e "${red}6. AWS改root权限"
echo -e "${red}7. 一键BBRPlus"
echo -e "${black} ————————————————————————————————————————————————————————————————————————————————————————"
read -p "请选择对接模式(1,2,3,4,5,6,7)：" xuan
}


#s输入参数
start(){
xi=" "
xi2=" "
#网站地址
domain='    "panelUrl": "http://stantao.com/",'
#mukey
mukey='"panelKey": "weilehaoji",'
#面板节点id
#read -p "  1.面板里添加完节点后生成的自增ID:" sid
#rid='"nodeId": '$sid','
#cloudflare 邮箱
email="- CF_Email=l2690329987@gmail.com"
#cloudflare密钥
value="- CF_Key=790a5ab094267d77f740e17aab0f21646f625"
#授权密钥
key='    "license_key": "LP+BAwEBB0xpY2Vuc2UB/4IAAQMBBERhdGEBCgABAVIB/4QAAQFTAf+EAAAACv+DBQEC/4YAAAD/2f+CAW57Ikhvc3RNZDUiOiI2MzkxRkFDQzcyMTcyODMxOTY1QzM5MEJBNTExRDVDOCIsIkVuZCI6IjIwMjEtMDItMjZUMjI6Mzc6NTQuNjY1MTk2KzA4OjAwIiwiSXNXSE1DU0xpY2Vuc2UiOmZhbHNlfQExAhS09FXSdZhsZXPTdALlhBzbPfmFUdsVkGdDXDw5UUMr7UeBaFYkEd6uUbQ+ueLivQExAk9Z5c6cbuvtdIf/mEpN1Ju8mZj8LNplLm97rx1mV14loMwJPySUR5du8yItdX4bZwA=",'
}
#判断系统
os_pan(){
os=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [ "$os" == '"CentOS Linux"' ] ;
then
        echo "您的系统是"${os}"，开始进入脚本："
		
		yum install -y epel-release && yum install -y nload
        	yum -y install ntpdate
		timedatectl set-timezone Asia/Shanghai
		ntpdate ntp1.aliyun.com
		systemctl disable firewalld
		systemctl stop firewalld
elif [ "$os" == '"Ubuntu"' ]; 
then
        echo "您的系统是"${os}"，开始进入脚本："
		
		apt install -y nload
		apt install -y ntpdate
		timedatectl set-timezone Asia/Shanghai
		ntpdate ntp1.aliyun.com
		ufw disable
fi
}
##环境安装
huan(){


pName=$(rpm -qa | grep docker)
if [ $? -eq 0 ]
then
        echo $xi;
else
		curl -fsSL https://get.docker.com | bash
		curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		chmod a+x /usr/local/bin/docker-compose
		rm -f `which dc`
		ln -s /usr/local/bin/docker-compose /usr/bin/dc
		systemctl start docker
		service docker start
		systemctl enable docker.service
		systemctl status docker.service
fi



}


while :
do
	#statements
main
case $xuan in
	1)
		#WS模式
		start
		os_pan
		huan
		echo "恭喜您，安装成功了！"
		break;
		;;
	2)
		#安装speedtest
		wget -qO- https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-x86_64-linux.tgz | tar zxv && rm -f ./speedtest.*
		echo "恭喜您，安装成功了！"
		./speedtest
		break;
		;;
	3)
		#ws-tls模式
		start
		os_pan
		huan
		docker pull crackair/xrayr:latest && docker run --restart=always --name xrayr -d -v /root/config.yml:/etc/XrayR/config.yml --network=host crackair/xrayr:latest
		echo "恭喜您，安装成功了！"
		break;
		;;
	4)
		yum install wget
		wget http://sh.nekoneko.cloud/tools.sh -O tools.sh && bash tools.sh
		break;
		;;
	5)
		yum install bind-utils -y
		rm -rf brook-pf-mod.sh;wget -N --no-check-certificate "https://raw.githubusercontent.com/yulewang/brook/master/brook-pf-mod.sh"
		mkdir /usr/local/brook-pf;cd /usr/local/brook-pf;rm -rf /usr/local/brook-pf/*
		wget -N --no-check-certificate "https://www.isyunyi.com/download/linux/brook";chmod +x brook
		echo >  /usr/local/brook-pf/brook.conf
		wget https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/brook-pf_centos -O /etc/init.d/brook-pf;chmod +x /etc/init.d/brook-pf;chkconfig --add brook-pf;chkconfig brook-pf on
		cd ~;chmod +x brook-pf-mod.sh;./brook-pf-mod.sh
		break;
		;;
	6)  
		sed -i 's/#PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
		sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		service sshd restart
		break;
		;;
	7)
		wget "https://github.com/a8866051/bbrplus/raw/master/ok_bbrplus_centos.sh" && chmod +x ok_bbrplus_centos.sh && ./ok_bbrplus_centos.sh
		;;
	*) 	
		echo "您的选择错误，请使用(1,2,3,4,5,6,7)进行选择！"
		sleep 3;
		;;
esac

done
