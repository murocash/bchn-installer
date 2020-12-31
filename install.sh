#!/bin/bash
if [ -z "$1" ]; then
    echo "usage: ./install-bchn.sh version"
	exit 1
fi

set -e
FILENAME="bitcoin-cash-node-$1-x86_64-linux-gnu.tar.gz"
ORIGIN="https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v$1/${FILENAME}"
BCHN_USER=bchn
BCHN_HOME=/opt/${BCHN_USER}
TARGET_PATH="/tmp/${BCHN_USER}/$1"
mkdir -p ${TARGET_PATH}
TARGET="${TARGET_PATH}/${FILENAME}"
cd $TARGET_PATH
echo $ORIGIN
curl -L -o $TARGET $ORIGIN
tar -zxvf $TARGET
rm $TARGET
id -u ${BCHN_USER} &>/dev/null || groupadd ${BCHN_USER}
id -u ${BCHN_USER} &>/dev/null || useradd ${BCHN_USER} -g ${BCHN_USER} -m -d $BCHN_HOME -s /bin/bash
usermod -a -G ${BCHN_USER} ${BCHN_USER}
VERSION_HOME=${BCHN_HOME}/$1
mv $TARGET_PATH/bitcoin-cash-node-$1 ${VERSION_HOME}
chown -R ${BCHN_USER}:${BCHN_USER} ${BCHN_HOME}
mkdir /etc/${BCHN_USER}
chown -R ${BCHN_USER}:${BCHN_USER} /etc/${BCHN_USER}
mkdir -p /var/log/${BCHN_USER}
chown -R ${BCHN_USER}:${BCHN_USER} /var/log/${BCHN_USER}


cat > /etc/systemd/system/${BCHN_USER}.service <<EOF
[Unit]
Description=${BCHN_USER} service

[Service]
User=${BCHN_USER}
ExecStart=${VERSION_HOME}'/bin/bitcoind'
ExecStop=${VERSION_HOME}'/bin/bitcoincli -stop'

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ${BCHN_USER}

