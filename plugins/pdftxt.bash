# Create plain txt from PDF through OCR

pdftxt() {
	local opt
	local OPTIND=1

	local resolution=""
	local output=""
	while getopts "hv" opt; do
		case "$opt" in
			h)
				cat <<End-of-Usage
Usage ${FUNCNAME[0]} [option] <pdffile>
	options:
	    -h  show this message and exit
	    -o  output file
	    -r  resolution
End-of-Usage
				return
				;;
			r)
				resolution=${OPTARG}
				;;
			o)	
				output=${OPTARG}
				;;
			*)
				pdftxt -h >&2
				return 1
				;;
		esac
	done
	shift $((OPTIND-1))

	[ $# -eq 0 ] && pdftxt -h && return 1

	local -r filename=$1
	local -r pages=$(pdfinfo $filename | grep "^Pages" | grep -oP "[0-9]+")

	echo filename=$filename pages=$pages resolution=$resolution output=$output
}
