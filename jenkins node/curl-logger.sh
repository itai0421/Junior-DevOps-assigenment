#!/bin/bash

LOG_FILE="/var/log/floating_ip.log"
FLOATING_IP="172.20.0.50"
PORT="80"

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
HOSTNAME="$(hostname)"

RESPONSE="$(curl -s http://${FLOATING_IP}:${PORT} || echo 'NO_RESPONSE')"

echo "${TIMESTAMP} | ${HOSTNAME} | ${RESPONSE}" >> "${LOG_FILE}"
