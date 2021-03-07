cite about-plugin
about-plugin 'Launching games in the terminal'

function dcss {
	about 'Launch DCSS in tmux with wiki in background'
	group 'michal'

        byobu  \
           new-session links http://crawl.chaosforge.org/Crawl_Wiki \; \
           new-window crawl \; 
}

function cddab {
	about 'Launch CDDA in byobu in tmux with wiki in background'
	group 'michal'

        byobu  \
           new-session links http://cddawiki.chezzo.com/cdda_wiki/index.php?title=Main_Page \; \
           new-window links http://cdda.chezzo.com/ \; \
	   new-window links https://cddawiki.chezzo.com/cdda_wiki/index.php?title=A_Skill_Training_Encyclopedia \; \
           new-window cdda \; 
}
