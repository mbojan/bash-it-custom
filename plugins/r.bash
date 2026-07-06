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

	Rscript -e "remotes::install_github(\"$1\", build_vignettes=FALSE, force=TRUE)"
}

function r-githubv {
	about 'install R package from GitHub'
	param '1: user/repo string to GH repository with the package'
	group 'r'

	Rscript -e "remotes::install_github(\"$1\", build_vignettes=TRUE, force=TRUE)"
}

function r-render {
	about 'run rmarkdown::render() via Rscript'
	param '1: name of Rmd file to render'
	param '2: list-like structure to params= argument'
	group 'r'

	Rscript -e "rmarkdown::render(\"$1\", params=list($2))"
}

function r-render-docx {
	about 'run rmarkdown::render() via Rscript'
	param '1: name of Rmd file to render'
	param '2: list-like structure to params= argument'
	group 'r'

	Rscript -e "rmarkdown::render(\"$1\", params=list($2), output_format=\"bookdown::word_document2\")"
}

function r-render-html {
	about 'run rmarkdown::render() via Rscript'
	param '1: name of Rmd file to render'
	param '2: list-like structure to params= argument'
	group 'r'

	Rscript -e "rmarkdown::render(\"$1\", params=list($2), output_format=\"bookdown::html_document2\")"
}

function r-render-pdf {
	about 'run rmarkdown::render() via Rscript'
	param '1: name of Rmd file to render'
	param '2: list-like structure to params= argument'
	group 'r'

	Rscript -e "rmarkdown::render(\"$1\", params=list($2), output_format=\"bookdown::pdf_document2\")"
}

function r-tangle {
	about 'run knitr::knit(tangle=TRUE) on the Rmd document'
	param '1: name of the Rmd file to tangle'
	group 'r'

	Rscript -e "knitr::knit(\"$1\", tangle=TRUE)"
}

function rbbt-bib {
	about 'run rbbt::bbt_update_bib() on a file to generate local bib'
	param '1: name of Rmd/Qmd/md file to process'
	group 'r'

	Rscript -e "rbbt::bbt_update_bib(path_rmd=\"$1\", path_bib=\"zotero.bib\")"
}

function rpkg-testfile {
	about 'run testthat::test_file() on a file'
	param '1: path to R script'
	group 'r'

	echo Testing $1
	Rscript -e "testthat::test_file(\"$1\")"
}

function rpkg-testmonitor {
	about 'monitor file $1 and source $2 when $1 is modified'
	param '1: path being modified'
	param '2: path to R script to be sourced'
	group 'r'

	while inotifywait -qe modify $1; do rpkg-testfile $2; done
}




function install-positron {
	about 'install Positron'
	group 'r'

	local old_opts
	old_opts=$(set -o)
	# set -euo pipefail

	local ARCH=$(uname -m)
	case "$ARCH" in
		x86_64) local POSIT_ARCH="x64" ;;
		aarch64|arm64) local POSIT_ARCH="arm64" ;;
		*) echo "Unsupported architecture: $ARCH"; exit 1 ;;
	esac

	local RELEASE_URL="https://github.com/posit-dev/positron/releases"
	local TMPFILE="/tmp/positron-latest.deb"

	echo "Finding latest Positron .deb for $POSIT_ARCH..."
	local DEB_URL=$(curl -fsSL "$RELEASE_URL" \
		| grep -Eo "https://cdn\.posit\.co/[A-Za-z0-9/_\.-]+Positron-[0-9\.~-]+-${POSIT_ARCH}\.deb" \
		| head -n 1)

	if [ -z "${DEB_URL:-}" ]; then
		echo "Could not find a .deb link for ${POSIT_ARCH} on the releases page"
		exit 1
	fi

	echo "Downloading: $DEB_URL"
	curl -fL "$DEB_URL" -o "$TMPFILE"

	echo "Installing Positron..."
	sudo apt install -y "$TMPFILE"

	echo "Cleaning up..."
	rm -f "$TMPFILE"

	echo "Done."

	# Reset old options
	# eval "$old_opts"
}


function r-deps {
	about 'list R packages mentioned in R, Quarto and RMarkdown files'
	param '1: path; defaults to current folder'

	local dir="${1:-.}"

	local pkg_re='\b(?:library|require)\("\K[A-Za-z0-9]+(?="\))'
	local pkg_re+='|\b(?:library|require)\(\K[A-Za-z0-9]+(?=\))'
	local pkg_re+='|\b(?:requireNamespace|loadNamespace|attachNamespace)\("\K[A-Za-z0-9]+(?="\))'
	local pkg_re+='|\b(?:library|require|requireNamespace|loadNamespace|attachNamespace)\(package\s*=\s*"\K[A-Za-z0-9]+(?="\))'
	local pkg_re+='|\b(?:library|require)\(package\s*=\s*\K[A-Za-z0-9]+(?=\))'
	local pkg_re+='|\b[A-Za-z0-9]+(?=::)'

	local files=()
	while IFS= read -r -d '' f; do
	  files+=("$f")
	done < <(find "$dir" -type f \( -name '*.R' -o -name '*.Rmd' -o -name '*.qmd' \) -print0)

	if [ ${#files[@]} -eq 0 ]; then
	  exit 0
	fi

	{
	  grep -ohP "$pkg_re" "${files[@]}"
	  grep -ohP '(?<=p_load\()[^)]*' "${files[@]}" \
	    | tr ',' '\n' \
	    | sed -E 's/^[[:space:]]*"?//; s/"?[[:space:]]*$//' \
	    | grep -xE '[A-Za-z0-9]+'
	} | sort -u
}




# function install-rstudio {
# 	about 'install RStudio'
# 	group 'r'
# 
# 	local old_opts
# 	old_opts=$(set -o)
# 	# set -euo pipefail
# 
# 	# --- Detect architecture ---
# 	local ARCH=$(uname -m)
# 	case "$ARCH" in
# 	  x86_64) local RSTUDIO_ARCH="amd64" ;;
# 	  aarch64|arm64) local RSTUDIO_ARCH="arm64" ;;
# 	  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
# 	esac
# 
# 	# --- Detect Ubuntu base ---
# 	local DISTRO=$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || true)
# 	[ -z "$DISTRO" ] && local DISTRO="noble"
# 
# 	# --- Define paths ---
# 	local TMPFILE="/tmp/rstudio-latest.deb"
# 	local LOGFILE="/var/log/rstudio_update.log"
# 
# 	echo "Detected Ubuntu base: ${DISTRO}"
# 	echo "Fetching latest version number from Posit..."
# 
# 	# --- Get version from Posit's official RStudio Desktop page ---
# 	local VERSION=$(curl -s https://posit.co/download/rstudio-desktop/ \
# 	  | grep -Eo 'rstudio-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' \
# 	  | head -n 1 \
# 	  | sed -E 's/rstudio-([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)/\1/')
# 
# 	if [ -z "$VERSION" ]; then
# 	  echo "Error: Could not extract the latest RStudio version number from Posit's site."
# 	  exit 1
# 	fi
# 
# 	echo "Latest RStudio version detected: ${VERSION}"
# 
# 	# --- Construct download URL (Jammy build for Noble until Noble builds exist) ---
# 	local BASE_DISTRO="jammy"
# 	local BASE_URL="https://download1.rstudio.org/electron/${BASE_DISTRO}/${RSTUDIO_ARCH}"
# 	local FULL_URL="${BASE_URL}/rstudio-${VERSION}-${RSTUDIO_ARCH}.deb"
# 
# 	echo "Downloading from:"
# 	echo "  ${FULL_URL}"
# 
# 	# --- Validate URL before downloading ---
# 	if ! curl --head --silent --fail "$FULL_URL" >/dev/null; then
# 	  echo "Error: The expected RStudio package was not found at ${FULL_URL}"
# 	  exit 1
# 	fi
# 
# 	# --- Download and install ---
# 	curl -L "$FULL_URL" -o "$TMPFILE"
# 	echo "Installing RStudio..."
# 	sudo apt install -y "$TMPFILE" | tee -a "$LOGFILE"
# 
# 	# --- Clean up ---
# 	rm -f "$TMPFILE"
# 	echo "RStudio update to version ${VERSION} completed successfully." | tee -a "$LOGFILE"
# 
# 	# Reset old options
# 	# eval "$old_opts"
# }
