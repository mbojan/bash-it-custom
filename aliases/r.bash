cite 'about-alias'
about-alias 'R abbreviations'

# Aliases
alias r-oldpkg='Rscript -e "old.packages()"'
alias r-update2='Rscript -e "update.packages(lib=.libPaths()[1], ask=FALSE, Ncpus=2)"'
alias r-here='cd `Rscript -e "cat(here::here())"`'
alias rpkg-autotest='Rscript -e "testthat::auto_test_package()"'
alias rpkg-install='Rscript -e "devtools::install(build_vignettes=TRUE)"'
alias rpkg-build='Rscript -e "devtools::build()"'
alias rpkg-check='Rscript -e "devtools::check()"'
