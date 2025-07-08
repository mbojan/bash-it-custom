# Commands mounting some remote drives

# Mount DVC remote at UAB's OneDrive share
alias mount-uab-dvc="rclone mount uab:DVC ~/mnt/DVC --vfs-cache-mode full --daemon"

# Mount UAB PATCHWORK folder
alias mount-uab-patchwork="rclone mount uab:PATCHWORK ~/mnt/PATCHWORK --vfs-cache-mode full --daemon"
