#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: слово '$WORD' найдено."
else
exit 0
fi
