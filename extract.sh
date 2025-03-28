#!/bin/bash
# This script extracts the variable regions from the reads. It is designed to be run on Garibaldi

#SBATCH --job-name=Extract_Test
#SBATCH --output=logs/misc/%x%A_%a.out # redirects out files
#SBATCH --error=logs/misc/%x%A_%a.err # redirects error files
#SBATCH --array=1-1 # one array for each library
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=16GB

module purge
module load python/3.8.3
module load blast

input_dir="/gpfs/home/sradak/Variable_Extract/files/" # input fasta files
pydir="/gpfs/home/sradak/Variable_Extract/pythonfiles/"

libraries=("test")
library=${libraries[$((SLURM_ARRAY_TASK_ID-1))]}
num_regions=6



# export anything written to the terminal into a log file
log_file="logs/${SLURM_JOB_ID}_${library}_extract.log"
exec > "$log_file" 2>&1


# extract sequences to fasta
python3 -u $pydir"extract_to_fasta.py" "$library" $input_dir


# make blast database only once, when the first array task runs
if [[ "$SLURM_ARRAY_TASK_ID" -eq 1 ]]; then
    python3 -u $pydir"make_db.py"
fi

# extract the variable regions from each sequence
python3 -u $pydir"extract.py" "$library" "$num_regions"
