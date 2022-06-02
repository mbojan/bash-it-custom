cite about-plugin
about-plugin "Various system functions"

function swapstats {
	about "Report process'es swap usage"
	group "system"

	for file in /proc/*/status ; do 
		awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; 
	done
}

