cite 'about-alias'
about-alias 'Michals KeepassXC aliases'

alias keepassxc-push='rclone sync -v ~/Drive/Szyfry gd:Szyfry'
alias keepassxc-pull='rclone sync -v gd:Szyfry ~/Drive/Szyfry'
alias keepassxc-check='rclone check ~/Drive/Szyfry gd:Szyfry --combined -; echo Local; rclone lsl ~/Drive/Szyfry; echo Remote; rclone lsl gd:Szyfry'
