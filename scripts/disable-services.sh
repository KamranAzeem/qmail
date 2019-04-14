#!/bin/bash

SERVICES="postfix"

systemctl disable ${SERVICES}
systemctl stop  ${SERVICES}
