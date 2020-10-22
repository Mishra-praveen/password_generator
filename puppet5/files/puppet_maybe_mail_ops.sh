#!/bin/sh

cat - >/tmp/puppet_maybe_mail_ops.$$
cat /tmp/puppet_maybe_mail_ops.$$

if [ "$(stat -c '%s' /tmp/puppet_maybe_mail_ops.$$)" -gt 10 ]
then
  cat /tmp/puppet_maybe_mail_ops.$$ | mail -s "$1" ops@cytobank.org
fi

rm /tmp/puppet_maybe_mail_ops.$$
