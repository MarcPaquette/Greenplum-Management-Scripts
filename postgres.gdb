set print pretty on
set pagination off

#############################################################
#############################################################
printf "btall - dump back trace for all threads\n"
define btall
	info thread all
	thread apply all bt
printf "\n"
end

document btall
	list threds and run backtrace for each
end

#############################################################
#############################################################
#static LWLockId held_lwlocks[100];
#static LWLockPadded *LWLockArray;
#static PGPROC *lockHolderProcPtr;
#static bool held_lwlocks_exclusive[100];
#static enum LWLockId ftsControlLock;
#static enum LWLockId ftsQDMirrorLock;
#static enum LWLockId ftsQDMirrorUpdateConfigLock;
#static enum LWLockId shmControlLock;
#struct WritePersistentStateLockLocalVars writePersistentStateLockLocalVars;
printf "dump_locks - dumps global locks\n"
define dump_locks

	printf "Global IDs:\n"
	printf "static enum LWLockId ftsControlLock : %d\n", ftsControlLock
	printf "static enum LWLockId ftsQDMirrorLock : %d\n", ftsQDMirrorLock
	printf "static enum LWLockId ftsQDMirrorUpdateConfigLock : %d\n", ftsQDMirrorUpdateConfigLock
	printf "static enum LWLockId shmControlLock : %d\n", shmControlLock
	#printf "struct WritePersistentStateLockLocalVars writePersistentStateLockLocalVars.persistentObjLockIsHeldByMe : %d\n", writePersistentStateLockLocalVars.persistentObjLockIsHeldByMe
	printf "slock_t ShmemLock : %d\n", *ShmemLock
	set $i = 0
	set $foundlock = 0

	printf "\nLWLocks:\n"
	while ($i <= 100)
		if ( held_lwlocks[$i] != 0 )
			printf "held_lwlocks %d : %d : ", $i, held_lwlocks[$i]
			output held_lwlocks[$i]
			printf "\n"
			set $foundlock = 1
		end
		set $i = $i + 1
	end
	if ( $foundlock == 0 )
		printf "held_lwlocks : none found\n"
	end

	set $i = 0
	set $foundlock = 0
	while ( $i < 100 )
		if ( held_lwlocks_exclusive[$i] )
			printf "held_lwlocks_exclusive %d : %d\n", $i, held_lwlocks_exclusive[$i]
			set $foundlock = 1
		end
		set $i = $i + 1
	end
	if ( $foundlock == 0 )
		printf "held_lwlocks_exclusive : none found\n"
	end
printf "\n"
end

document dump_locks
	Dumps global lock IDs and what locks are held
end


#############################################################
#############################################################
printf "pidinfo - dump info about the gpdb postmaster instance\n"
define pidinfo
	printf "My execute Path: %s\n", my_exec_path
	printf "PID: %d\n", MyProc.pid
	printf "SessionID: %d\n", MyProc.mppSessionId
	printf "Number of segments: %d\n", GpIdentity.numsegments
	printf "dbid: %d\n", GpIdentity.dbid
	printf "segindex: %d\n", GpIdentity.segindex

	printf "\nState information:\n"
	printf "SemId: %d\n", lockHolderProcPtr->sem.semId
	printf "Gp_role: %s\n",	gp_role_string
	printf "QueryCancelPending: %d\n", QueryCancelPending
	printf "QueryCancelCleanup: %d\n", QueryCancelCleanup
	printf "waitStatus: %d\n", MyProc.waitStatus
	printf "lwWaiting: %d\n", MyProc.lwWaiting
	printf "lwExclusive: %d\n", MyProc.lwExclusive
	printf "lwWaitLink: %d\n", MyProc.lwWaitLink
	printf "waitLock: %d\n", MyProc.waitLock
	printf "waitProcLock: %d\n", MyProc.waitProcLock
	printf "waitLockMode: %d\n", MyProc.waitLockMode
	printf "heldLocks: %d\n", MyProc.heldLocks
	printf "waitLock: %d\n", MyProc.waitLock
printf "\n"
end

document pidinfo
	dump the current process state and lock status information
end

#############################################################
#############################################################
#int gp_resqueue_memory_policy_auto_fixed_mem;
#int gp_vmem_protect_gang_cache_limit;
#int gp_vmem_protect_limit;
#int maintenance_work_mem;
#int max_statement_mem;
#int max_work_mem;
#int planner_work_mem;
#int statement_mem;
#int work_mem;
printf "meminfo - dump process memory utilization info\n"
define meminfo
	printf "\nDumping GUCs:\n"
	printf "gp_resqueue_memory_policy_auto_fixed_mem = %d\n", gp_resqueue_memory_policy_auto_fixed_mem
	printf "gp_vmem_protect_gang_cache_limit         = %d\n", gp_vmem_protect_gang_cache_limit
	printf "gp_vmem_protect_limit                    = %d\n", gp_vmem_protect_limit
	printf "maintenance_work_mem                     = %d\n", maintenance_work_mem
	printf "max_statement_mem                        = %d\n", max_statement_mem
	printf "max_work_mem                             = %d\n", max_work_mem
	printf "planner_work_mem                         = %d\n", planner_work_mem
	printf "statement_mem                            = %d\n", statement_mem
	printf "work_mem                                 = %d\n", work_mem

	printf "\nDump struct gpsema_vmem_prot:\n"
	output gpsema_vmem_prot
	printf "\n"

	printf "\nDump struct *CurrentMemoryContext:\n"
	output *CurrentMemoryContext
	printf "\n"

printf "\n"
end

document meminfo
	print common user defined GUCs and memory utilization
end

#############################################################
#############################################################
printf "find_elock_owner - finds all locks and reports there owners\n"
define find_elock_owner
	if ( LWLockArray[148].lock->exclusive  )
		printf "\nFound shmControlLock exclusive lock held by process %d\n\n", LWLockArray[148].lock->exclusivePid

		## debug
		if ( $arg0 == 1 ) 
			output LWLockArray[148].lock
			printf "\n\n"
		end
	end

	if ( LWLockArray[CheckpointLock].lock->exclusive ) 
		printf "\nFound Checkpoint exclusive lock held by process %d\n\n", LWLockArray[CheckpointLock].lock->exclusivePid

		## debug
		if ( $arg0 == 1 )
			output LWLockArray[CheckpointLock].lock
			printf "\n\n"
		end
	end

	if ( LWLockArray[MirroredLock].lock->exclusive )
		printf "\nFound Mirrored exclusive lock held by process %d\n\n", LWLockArray[MirroredLock].lock->exclusivePid

		 # debug
		if ( $arg0 == 1 )
			output LWLockArray[MirroredLock].lock
			printf "\n\n"
		end
	end
printf "\n"
end

document find_elock_owner
	search global memory for exclusive locks
end

printf "\n"

