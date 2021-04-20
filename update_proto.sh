#!/usr/bin/env bash

CHECKOUT_DIR=".checkout"

mkdir ${CHECKOUT_DIR}
git clone git@git.redmadrobot.com:RedMadRobot/SPb/robologs-api.git "${CHECKOUT_DIR}/robologs-api"

PROTO_DIR="Sources.Robologs.Remote/Transports/ProtoHttpRemoteLoggerTransport/proto"
rm -rf "${PROTO_DIR}"
mkdir "${PROTO_DIR}"
cp "${CHECKOUT_DIR}/robologs-api/src/main/proto/"*.proto "${PROTO_DIR}/"
protoc --swift_out=. "${PROTO_DIR}/"*.proto
echo
echo "Generated: "
ls "${PROTO_DIR}"

rm -rf ${CHECKOUT_DIR}
