#! /bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

%{ for key in ssh_keys ~}
echo ${key} >> ~ubuntu/.ssh/authorized_keys
%{ endfor ~}

apt-get -y install openjdk-19-jre-headless
curl -sLO https://dlcdn.apache.org/zookeeper/zookeeper-3.8.1/apache-zookeeper-3.8.1-bin.tar.gz
tar -xf apache-zookeeper-3.8.1-bin.tar.gz

cat > apache-zookeeper-3.8.1-bin/conf/zoo.cfg <<EOF
tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
EOF

apache-zookeeper-3.8.1-bin/bin/zkServer.sh start
