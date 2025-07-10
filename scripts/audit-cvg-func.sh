#!/bin/bash

SRCS=('kernel/audit.c' 'kernel/auditfilter.c' 'kernel/audit_fsnotify.c' 'kernel/auditsc.c' 'kernel/audit_tree.c' 'kernel/audit_watch.c')
TEST_PATH="/home/rrobaina/src/audit-testsuite"
GCOV_DATA_PATH="/sys/kernel/debug/gcov/home/rrobaina/src/kernel-ark/kernel/"

if [[ $EUID -ne 0 ]]; then
	echo "error: must run as root." 
	exit
fi

if [[ ! -e /sys/kernel/debug/gcov ]]; then
	echo "error: gcov not enabled."
	exit
fi

# clean GCOV data
echo 1 > /sys/kernel/debug/gcov/reset

# run full test suite
make test -C ${TEST_PATH} &> /dev/null

# collect data
for s in ${SRCS[@]}; do
	printf "%s\n---\n" ${s}

	# get source size (ss)
	ss=$(gcov -f $s -p -H -o $GCOV_DATA_PATH 2> /dev/null | awk 'END {print $4}')

	# print: function name, function coverage (fc), function size (fs), source size (ss), potential coverage increase index (PCII)	
	printf "function\tfc\tfs\tss\tpcii\n"	
	gcov -f $s -p -H -o $GCOV_DATA_PATH 2> /dev/null | \
	awk -v ss="$ss" '
		/Function/{gsub(/\047/,""); printf("%s\t", $2)}
		/ines/{sub(/executed:/, ""); sub(/%/, ""); if ($1 == "Lines") print $2 "\t" $4 "\t" ss "\t" (100-$2)*($4/ss); else print "NA NA NA NA"}
		/File/{exit}
	'
	printf "\n\n"
done
