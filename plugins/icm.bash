cite about-plugin
about-plugin 'Functions to interact with HPC at ICM UW'

export ICM_USERNAME="mbojan"


function icm {
	case $1 in
		open) 
			echo "Openning connection"
			ssh -f -N -M hpc;
			shift
		;;

		close) 
			echo "Closing conneciton"
			ssh -S ~/.ssh/mbojan@hpc.icm.edu.pl\:22 -O exit hpc;
			shift
		;;

		mount)
			echo "Mounting ICM at ~/mnt/icm"
			mkdir -p ~/mnt/icm
			sshfs mbojan@hpc:/lu/topola/home/mbojan ~/mnt/icm;
			shift
		;;

		unmount)
			echo "Unmounting ICM from ~/mnt/icm"
			fusermount3 -u ~/mnt/icm;
			shift
		;;

		*) 
			echo "Checking for connection"
			ssh -S ~/.ssh/mbojan@hpc.icm.edu.pl\:22 -O check hpc;
		;;
	esac
}


function to_host {
	about 'Copy local folder to remote host'
	group 'icm'

	LOCAL_SOURCE=$1
	REMOTE_DESTINATION_DIR=$2
	echo -e "Stuff to be copied to remote: $LOCAL_SOURCE \n"

	if ! test -z "$LOCAL_SOURCE" && test -z "$REMOTE_DESTINATION_DIR"
	then
		rsync -avzhe ssh --progress ${LOCAL_SOURCE} ${REMOTE_HOME_DIR}${REMOTE_DESTNATION_DIR}
	else
		echo "Usage: to_remote LOCAL_SOURCE REMOTE_DESTINATION_DIR"
	fi
}

function from_host {
	about 'Copy remote folder to local'
	group 'icm'

	SOURCE_ON_REMOTE=$1
	LOCAL_DESTINATION_DIR=$2
	# echo -e "Stuff to be copied from remote: $SOURCE_ON_REMOTE \n"

	if ! test -z "$SOURCE_ON_REMOTE" && ! test -z "$LOCAL_DESTINATION_DIR"
	then
		rsync -avzhe ssh --progress ${REMOTE_HOME_DIR}${SOURCE_ON_REMOTE} ${LOCAL_DESTINATION_DIR}
	else
		echo "Usage: from_remote SOURCE_ON_REMOTE LOCAL_DESTINATION_DIR"
	fi
}

function to_hpc {
	REMOTE_HOME_DIR="${ICM_USERNAME}@hpc:/lu/topola/home/${ICM_USERNAME}/"
	to_host $@
}

function from_hpc {
	REMOTE_HOME_DIR="${ICM_USERNAME}@hpc:/lu/topola/home/${ICM_USERNAME}/"
	from_host $@
}

