# set session ------------------------------------------------------------------
library(randtoolbox)
library(tidyverse)

# set the number of runs
start_from <- 6001
n <- 9000

# convert the sobol numbers to within defined parameter space
linMap <- function(x, from, to) {(x - min(x)) / max(x - min(x)) * (to - from) + from}

# generate parameter values ----------------------------------------------------
# burn in sobol values
burnin <- sobol(start_from-1, init = T)

# create parameter value table
params_table                  <- data.frame(sobol(n, 6, init = F)) # if starting from scratch, make init = T
params_table                  <- cbind(start_from:(start_from+dim(params_table)[1]-1), params_table)
colnames(params_table)        <- c("run_id",
                                   "t_opt",
                                   "dispRange",
                                   "speciation",
                                   "initialAbundance",
                                   "mutationRate",
                                   "n_width")

# set parameters
params_table$seed             <- 1989
params_table$start            <- 1201  # 390*0.166 ~ 65 mya
params_table$initialAbundance <- round(linMap(params_table$initialAbundance, from=0.11, to=1),3)
params_table$t_opt            <- round(linMap(params_table$t_opt, from=0, to=1),3) # normalised values from 17 to 28
params_table$dispRange        <- round(linMap(params_table$dispRange, from=100, to=5000),0) # varies from <20 to <15000 km / generation depending on species (Green et al. 2015). Further reduction based on 5.1 and 5.2
params_table$speciation       <- round(linMap(params_table$speciation, from=12, to=600),0) # 0.01 - 0.5 speciations/my (Rabosky, 2020) = 2 - 100 my = 12 - 600 time steps.
params_table$mutationRate     <- round(linMap(params_table$mutationRate, from=0.01, to=0.15),4) # values eyeballed from mutationRate.R as niche position is abstract.
params_table$n_width          <- round(linMap(params_table$n_width, from=0.02, to=0.5),3) # values eyeballed from mutationRate.R as niche position is abstract.

# Write table ------------------------------------------------------------------
write_csv(params_table, "./data_processed/configs/config_parameters.csv")

# Generate config files --------------------------------------------------------
for(i in 1:nrow(params_table)){ 
  
  params <- params_table[i,]
  
  config_i <- readLines('scripts/02_configure_genesis/template.R')
  
  config_i <- gsub('params\\$seed', params$seed, config_i)
  config_i <- gsub('params\\$start', params$start, config_i)
  config_i <- gsub('params\\$initialAbundance', params$initialAbundance, config_i)
  config_i <- gsub('params\\$t_opt', params$t_opt, config_i)
  config_i <- gsub('params\\$dispRange', params$dispRange, config_i)
  config_i <- gsub('params\\$speciation', params$speciation, config_i)
  config_i <- gsub('params\\$mutationRate', params$mutationRate, config_i)
  config_i <- gsub('params\\$n_width', params$n_width, config_i)
  
  writeLines(config_i, paste0('data_processed/configs/',i+start_from-1, '.R'))

}

# create bat file --------------------------------------------------------------
run_head     <- c("#!/bin/bash",
                  "#SBATCH --job-name=gen3sis",
                  "#SBATCH --mail-user=keggint@ethz.ch",
                  "#SBATCH --mail-type=FAIL,END",
                  "#SBATCH --cpus-per-task=1",
                  "#SBATCH --time=96:00:00",
                  "#SBATCH --mem-per-cpu=64000",
                  paste0("#SBATCH --array=1-",n),
                  "#SBATCH -A es_pelli",
                  "",
                  "module load gcc/6.3.0 r/4.1.3 udunits2/2.2.28 gdal/3.1.4 geos/3.8.1 proj/6.3.2 zlib/1.2.9",
                  "",
                  paste0("run_id=$((${SLURM_ARRAY_TASK_ID} + ", start_from-1,"))"),
                  "")
rscript      <- 'Rscript'
script_name  <- 'run_genesis.R'
config_dir   <- '-c /cluster/home/keggint/chapter_1/scripts/configs/${run_id}.R'
input_dir    <- '-i /cluster/work/ele/keggint/input/2021_1d_2000m_17c/'
output_dir   <- '-o /cluster/work/ele/keggint/output/'
other_par    <- '-v 1'# do not save intermediate results and be verbose

run_body <- paste(rscript,
                  script_name,
                  config_dir,
                  input_dir,
                  output_dir,
                  other_par)

output_file  <- file("./data_processed/configs/submit_sims.sh", "wb")

write(c(run_head, run_body), file = output_file)

close(output_file)
