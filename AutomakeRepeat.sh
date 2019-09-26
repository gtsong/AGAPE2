#!/bin/sh
expect <<EOF
set timeout 3
spawn perl ./configure
expect "*CONTINUE>"
send "\n"
expect eof
expect "*/usr/bin/perl ]:"
send "\n"
expect eof
expect "*RepeatMasker ]:"
send "\n"
expect eof
expect "*]:"
send "/usr/local/bin/trf409.linux64\n"
expect eof
expect "Enter Selection"
send "2\n"
expect eof
expect "Enter path [  ]:"
send "/usr/bin\n"
expect eof
expect "*]:"
send "Y\n"
expect eof
expect "Enter Selection"
send "5\n"
expect eof
EOF
