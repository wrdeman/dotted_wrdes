#!/bin/bash

amixer get -D pulse Master | tail -n1 |  awk -F[\]\[] '{if ($4 == "off") {print "MUTE";} else { print $2; }}'

exit 0
