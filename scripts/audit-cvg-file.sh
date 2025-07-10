#!/bin/bash

SRCS=('kernel/audit.c' 'kernel/auditfilter.c' 'kernel/audit_fsnotify.c' 'kernel/auditsc.c' 'kernel/audit_tree.c' 'kernel/audit_watch.c')

TESTDIR="/home/rrobaina/src/audit-testsuite"

if [[ $EUID -ne 0 ]]; then
	echo "error: must run as root." 
	exit
fi

if [[ ! -e /sys/kernel/debug/gcov ]]; then
	echo "error: gcov not enabled."
	exit
fi

# reset GCOV data
echo 1 > /sys/kernel/debug/gcov/reset

# run full test suite
make test -C ${TESTDIR} &> /dev/null

# collect data
for s in ${SRCS[@]}; do

	gcov -p -H ${s} -o /sys/kernel/debug/gcov/home/rrobaina/src/kernel-ark/kernel |
	awk '
		/File /{gsub(/\047/,""); printf "%s\t", $2}
		/executed/{sub(/executed:/, ""); sub(/%/, ""); print $2 "\t" $4}
		FNR>3{exit} 
	'
done
