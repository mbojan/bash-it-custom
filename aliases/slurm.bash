cite 'about-alias'
about-alias 'Aliases for SLURM workload manager'

# Relevant queue
alias myq='squeue -u $USER --format="%.10i %.9P %.16E %.30j %.8u %.10M %.6D %.3t %R"'

# How many jobs wait for resources
alias sqlen='squeue | grep " PD " | wc -l'
