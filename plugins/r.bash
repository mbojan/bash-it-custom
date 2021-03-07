cite about-plugin
about-plugin 'R specific functions'


# R administration
#
# Package management and so on.

r-update() (
	about 'update R packages with parallel compilation'
	group 'r'

	usage() {
		echo ""
		echo "Update R packages in specified library"
		echo ""
		echo "Usage: radmin-update [-l <string>] [-p <integer>]" 1>&2
		echo ""
		echo "-l  Library path number as returned by .libPaths(). Defaults to 1 so the packages"
	        echo "    are updated in .libPaths()[1]"
		echo "-p  Number of cores. Defaults to 1"
		echo "-h  Display this message"
		echo ""
	}

	exit_abnormal() {
		usage
		return 1
	}

	# Default option values
	local LIBINDEX=1
	local CORES=1
	local SUDO=

	while getopts ":hsl:p:" o; do
		case "${o}" in
			l) 
				LIBINDEX=${OPTARG} 
				;;
			p) 
				CORES=${OPTARG} 
				;;
			s)
				SUDO=sudo
				;;
			h) 
				usage 
				return 0
				;;
			:)
				echo "Error: -${OPTARG} requires and argument."
				exit_abnormal
				;;
			*)
				exit_abnormal
				;;
		esac
	done

	echo "Updating packages in ${LIBINDEX}:$(Rscript -e "cat(.libPaths()[${LIBINDEX}])") using ${CORES} core(s)."
	read -n 2 -p "Press any key to continue"
	MAKE="make -j${CORES}" ${SUDO} Rscript -e "update.packages(lib=.libPaths()[${LIBINDEX}], ask=FALSE, checkBuilt=TRUE)"
)

function r-install {
	about 'install R package parallelled'
	param '1: name of the package to install'
	group 'r'

	# Get number of cores
	local NCORES=$(grep -c ^processor /proc/cpuinfo)
	local USE_CORES=$(expr $NCORES - 1)

	echo Installing package $1 using $USE_CORES cores
	MAKE="make -j$USE_CORES" Rscript -e "install.packages(\"$1\")"
}

function r-github {
	about 'install R package from GitHub'
	param '1: user/repo string to GH repository with the package'
	group 'r'

	Rscript -e "remotes::install_github(\"$1\", build_vignettes=TRUE, force=TRUE)"
}


function r-render {
	about 'run rmarkdown::render() via Rscript'
	param '1: name of Rmd file to render'
	group 'r'

	Rscript -e "rmarkdown::render(\"$1\", params=list($2) )"
}

