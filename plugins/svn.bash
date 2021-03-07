cite about-plugin
about-plugin 'svn helper functions'

svn_authors(){
    about 'extract comitt authors'
    group 'svn'

    svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u
}
