cite about-plugin
about-plugin 'Windows Subsystem - Linux functions'

function launch-terminal {
	about 'launch XFCE4 terminal. X server must be running'
	group 'wsl'

	xfce4-terminal &
	disown %1
}


winenv()
{
	if [ "$#" == "0" ] || [ "$1" == "--help" ]
	then
		echo $'\n'Usage:
		echo $'\t'winenv [-d] WINDOWS_ENVIRONEMENT_VARIABLE_NAME
		echo $'\t'-d: Defines environment variable in current shell
		echo $'\t'"    "Note that paths will be translated into un*x-like paths$'\n'
		return
	fi
	local IFS='$\n'
	local PATH_TO_TRANSLATE=$1
	[ "$1" == "-d" ] && PATH_TO_TRANSLATE=$2
	local VAR=$(cmd.exe /c echo %${PATH_TO_TRANSLATE}% 2>/dev/null | tr -d '\r')
	local NEW=$(wslpath -u "${VAR}" 2>/dev/null || echo ${VAR})
	echo "${PATH_TO_TRANSLATE} = ${VAR} -> ${NEW}"
	[ "$1" == "-d" ] && export "${PATH_TO_TRANSLATE}=${NEW}"
}

