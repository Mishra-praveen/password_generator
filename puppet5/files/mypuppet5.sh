#!/bin/sh

if [ "$(id -un)" = "root" ]
then
  echo "Please run as yourself."
  exit 1
fi

MYID=$(id -un)
PORT=""
if [ "$MYID" = "ravi" ];
then
  PORT=8141
elif [ "$MYID" = "abhishek" ];
then
  PORT=8142
elif [ "$MYID" = "moses" ];
then
  PORT=8143
elif [ "$MYID" = "viraj" ];
then
  PORT=8144
elif [ "$MYID" = "pramod" ];
then
  PORT=8145
fi

if [ ! "$PORT" ]
then
  echo "You aren't one of the users I know about; bailing."
  exit 1
fi

if [ "$#" -gt 0 ]
then
  sudo /usr/local/bin/puppet5 "$@" --masterport=$PORT
else
  sudo /usr/local/bin/puppet5 agent -tv --masterport=$PORT
fi
