#!/bin/bash

SRCS=('kernel/audit.c' 'kernel/auditfilter.c' 'kernel/audit_fsnotify.c' 'kernel/auditsc.c' 'kernel/audit_tree.c' 'kernel/audit_watch.c')

TESTS=('amcast_joinpart' 'backlog_wait_time_actual_reset' 'bpf' 'exec_execve' 'exec_name' 'fanotify' 'file_create' 'file_delete' 'file_permission' 'file_rename' 'filter_exclude' 'filter_saddr_fam' 'filter_sessionid' 'io_uring' 'login_tty' 'lost_reset' 'netfilter_pkt' 'signal' 'syscalls_file' 'syscall_module' 'syscall_socketcall' 'time_change' 'user_msg')

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

# pint header information
for s in ${SRCS[@]}; do
	printf "\t${s}"
done
echo ""

# collect GCOV data
for t in ${TESTS[@]}; do
	echo 1 > /sys/kernel/debug/gcov/reset
	TESTS="${t}" make -e test -C ${TEST_PATH} &> /dev/null

	printf "%s\t" ${t}
	for s in ${SRCS[@]}; do
		gcov -H ${s} -o ${GCOV_DATA_PATH=} |
		awk '
			/executed/{sub(/executed:/, ""); sub(/%/, ""); printf "%s\t", $2}
			FNR>3{exit} 
		'
	done
	printf "\n"
done
