# set --------------------------------------------------------------------------
library(tidyverse)

# load and wrangle -------------------------------------------------------------
# set log directory
dir_log <-
  "./data_processed/genesis_output/logs/"

# list log files
logs <-
  list.files(dir_log)

# read log files
log_files <- list()
for(log in logs){
  log_files[[log]] <-
    read_lines(paste0(dir_log,log))
}

# find run times
runtimes <-
  c()
run_ids <-
  c()
mismatch <-
  c()

for(log in logs){
  # read log file
  file <-
    log_files[[log]]
  
  # run ID
  run_id <-
    file[grep("config",file)+1][1]
  run_id <-
    gsub(".*configs/","",run_id)
  run_id <-
    gsub(".R.","",run_id) %>% 
    as.numeric()
  
  run_ids <-
    c(run_ids,
      run_id)
  
  # run time
  runtime <-
    as.numeric(gsub("[^[:digit:].]","",file[grep("runtime",file)]))
  
  if(length(runtime) == 0){
    runtime <- NA
  }

  runtimes <-
    c(runtimes,
      runtime)
  
  # troubleshoot
  mismatch <-
    c(mismatch,
      length(runtimes) == length(run_ids))
  
  print(log)
}

jobtimes <-
  data.frame(run_id = run_ids,
             run_hours = runtimes)

# explore ----------------------------------------------------------------------
ggplot(jobtimes) +
  geom_histogram(aes(x = runtimes),
                 fill = "black",
                 colour = "transparent") +
  theme_classic() +
  xlab("hours") +
  ylab("simulations")

# export -----------------------------------------------------------------------
ggsave("./results/plots/runtimes.png",
       height = 4,
       width = 8)

write_csv(jobtimes,
          "./data_processed/summary/run_times.csv")
  





