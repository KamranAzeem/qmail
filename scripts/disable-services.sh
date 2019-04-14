#!/bin/bash

SERVICES="postfix"

echo "Disabling services: ${SERVICES}"
systemctl disable ${SERVICES}
systemctl stop  ${SERVICES}
