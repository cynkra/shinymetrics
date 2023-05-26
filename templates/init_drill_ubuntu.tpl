#! /bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

%{ for key in ssh_keys ~}
echo ${key} >> ~ubuntu/.ssh/authorized_keys
%{ endfor ~}

apt-get -y install openjdk-19-jre-headless
curl -sLO https://dlcdn.apache.org/drill/1.21.1/apache-drill-1.21.1.tar.gz
tar -xf apache-drill-1.21.1.tar.gz

sed -i 's/localhost/zookeeper.cynkra-drill/' apache-drill-1.21.1/conf/drill-override.conf

apache-drill-1.21.1/bin/drillbit.sh start
