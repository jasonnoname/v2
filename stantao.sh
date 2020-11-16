#! /bin/bash

red="\033[31m"
black="\033[0m"
main(){
echo -e "${black}       			 ————————————杰森工具箱————————————"
echo -e "${black}       ————————————对接适配centos7和Ubuntu16，其他系统待测试————————————"
echo -e "${red}1. WS模式"
echo -e "${red}2. TCP模式${black}:(前端面板格式：你的IP或域名;10086;2;tcp;;)"
echo -e "${red}3. WS-TLS模式${black}:(前端面板格式：你的域名;443;0;tls;ws;path=/|host=你的域名)"
echo -e "${red}4. 加速脚本安装${black}:(推荐使用BBR2或BBRPlus)"
echo -e "${red}5. 中转脚本安装${black}:(iptables1)"
echo -e "${red}6. 中转脚本安装${black}:(iptables2)"
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
read -p "  1.面板里添加完节点后生成的自增ID:" sid
rid='"nodeId": '$sid','
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

        	yum -y install ntpdate
		timedatectl set-timezone Asia/Shanghai
		ntpdate ntp1.aliyun.com
		systemctl disable firewalld
		systemctl stop firewalld
elif [ "$os" == '"Ubuntu"' ]; 
then
        echo "您的系统是"${os}"，开始进入脚本："

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
        	docker run --restart=on-failure --name v$sid -d -v /etc/soga/:/etc/soga/ --network host jasonstantao/soga:2.0.7 \
		--type=sspanel-uim \
		--server_type=v2ray \
		--api=webapi \
		--webapi_url=https://stantao.com \
		--webapi_mukey=weilehaoji \
		--node_id=$sid \
		--default_dns=1.1.1.1,8.8.8.8 \
		--dns_cache_time=10
		echo "恭喜您，安装成功了！"
		break;
		;;
	2)
		#tcp模式
		start
		os_pan
		huan
		read -p "  2.tcp端口：" port
		port1='     - "'$port':'$port'"'
		port2='    "port": '$port','
		cd /root/v2ray-poseidon/docker/sspanel/tcp
		sed -i '/license_key/d' config.json
		sed -i "/\"panel\": \"sspanel-webapi\",/ a\\$key" config.json
		sed -i '/"panelUrl":/d' config.json
		sed -i "/\"checkRate\": 60,/ a\\$domain" config.json
		sed -i '/"panelKey":/d' config.json
		sed -i "8a\    $mukey" config.json
		sed -i '/\"nodeId\":/d' config.json
		sed -i "4a \    $rid" config.json
		sed -i '22d' config.json
		sed -i "21a \ $port2" config.json
		sed -i '9d' docker-compose.yml
		sed -i "8a \ $port1" docker-compose.yml
		dc up -d
		echo "恭喜您，安装成功了！"
		break;
		;;
	3)
		#ws-tls模式
		start
		os_pan
		huan
		read -p "  2.CF上面解析的域名：" cf
		cf1="- CERT_DOMAIN="$cf
		cd /root/v2ray-poseidon/docker/sspanel/ws-tls/
		sed -i '/license_key/d' config.json
		sed -i "/\"panel\": \"sspanel-webapi\",/ a\\$key" config.json
		sed -i '/"panelUrl":/d' config.json
		sed -i "/\"checkRate\": 60,/ a\\$domain" config.json
		sed -i '/"panelKey":/d' config.json
		sed -i "8a\    $mukey" config.json
		sed -i '/\"nodeId\":/d' config.json
		sed -i "4a \    $rid" config.json
		sed -i "/-\ CF_Email=/d" docker-compose.yml
		sed -i "/-\ CF_Key=/d" docker-compose.yml
		sed -i "27a \      $value" docker-compose.yml
		sed -i "27a \      $email" docker-compose.yml
		sed -i "/-\ CERT_\DOMAIN/d" docker-compose.yml
		sed -i "25a \      $cf1" docker-compose.yml
		dc up -d
		echo "恭喜您，安装成功了！"
		break;
		;;
	4)
		yum install wget
		wget -N --no-check-certificate "https://github.000060000.xyz/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
		break;
		;;
	5)
		wget -qO natcfg.sh http://www.arloor.com/sh/iptablesUtils/natcfg.sh && bash natcfg.sh
		;;
	6)  
		wget --no-check-certificate -qO natcfg.sh http://www.arloor.com/sh/iptablesUtils/natcfg.sh && bash natcfg.sh
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
