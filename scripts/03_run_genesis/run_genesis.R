#!/usr/bin/Rscript
##################################################
## Description: option handlin gfor gen3sis simulations
## Copyright: GLP-3
## Date: 2018-04-17 11:45:31
## Author: Benjamin Flück
##################################################

keep.source = TRUE
library(gen3sis)
library(optparse)

if(interactive()){
  # change for interactive runs on the console
  opt <- list()
  opt$config                <- "your/config/file.R"
  opt$input_directory       <- "your/input/landscape/"
  opt$output_directory      <- "your/output/folder"
  opt$call_observer         <- "all" #NA
  opt$verbose               <-  1
  
  ## uncommon settings ##
  # move output to different folder (e.g. network share)
  opt$move_output_to_target <-  NA # NA or "folder"
  # redirect terminal output to file
  opt$redirect_output       <-  FALSE
  # gc early, gc often
  opt$enable_gc             <-  FALSE
  # enable cpu and memory profiling, may not work properly with library based simulations
  opt$enable_profiling      <-  FALSE

}else{
  option_list = list(
    make_option(c("-c", "--config"), action="store", default=NA, type='character',
                help="configuration file for experiment run"),
    make_option(c("-i", "--input_directory"), action="store",
                default=NA, type='character',
                help="input directory for simulation data
                \tnot set: derive input folder from config file path
                \t\"path\": use provided path (absolute or relative)"),
    make_option(c("-o", "--output_directory"), action="store",
                default=NA, type='character',
                help="output directory for simulation results
                \tnot set: derive output folder from config file path
                \t\"path\": use provided path (absolute or relative)"),
    make_option(c("-m", "--move_output_to_target"), action="store",
                default=NA, type='character',
                help="directory where final simulation data is moved to
                \tnot set: don't move
                \t\"path\": prepend provided path to [output_directory]"),
    make_option(c("-s", "--call_observer"), action="store", default=NA, type='character',
                help="call the observer function:
                \tnot set/NA: call only for initial (t_start) and final timesteps (t_end),
                \t\"x\" \t call for x timesteps between t_start and t_end,
                \t\"all\" \t call for all intermediate timesteps"),
    make_option(c("-r", "--redirect_output"), action="store_true", default=FALSE,
                help="print the output to the file [gen3sis.out] in the output directory"),
    make_option(c("-p", "--enable_profiling"), action="store_true", default=FALSE,
                help="enable profiling [default %default]"),
    make_option(c("-g", "--enable_gc"), action="store_true", default=FALSE,
                help="enable extra garbage colletion steps on memory critical operations"),
    make_option(c("-v", "--verbose"), action="store", default=1,
                help="Print extra stuff out [default %default]")
  )
  parser <- OptionParser(option_list=option_list, add_help_option = TRUE)
  opt = parse_args(parser)

}

##########################
# common part
##########################
if(opt$verbose){
  print("parsed option arguments:")
  print(opt)
}

if(opt$enable_profiling){
  options("keep.source" = TRUE)
}

dir <- prepare_directories(opt$config,
                           opt$input_directory,
                           opt$output_directory)

if(opt$redirect_output){
  sink(file = file(file.path(dir$output, "gen3sis.out"), open = "w"))
}

if(opt$enable_profiling){
  Rprof(filename = file.path(dir$output, "profiling.out"),
        memory.profiling = TRUE,
        gc.profiling = TRUE,
        line.profiling = TRUE)
}

sum_ <- run_simulation(config = opt$config,
                       landscape = opt$input_directory,
                       output_directory = opt$output_directory,
                       call_observer = opt$call_observer,
                       enable_gc = opt$enable_gc,
                       verbose = opt$verbose)

if(opt$enable_profiling){
  Rprof(NULL)
}

if(opt$redirect_output){
  sink() # close redirect
  closeAllConnections() # force close, bug fix for win/Rstudio(?)
}

#move output folder
if(!is.na(opt$move_output_to_target)){
  target = file.path(opt$move_output_to_target, dir$output)
  dir.create(target, recursive=TRUE, showWarnings = FALSE)
  files <- list.files(dir$output, full.names = T)
  if(all(file.copy(files, target, recursive = T, copy.date = T))){
    unlink(dir$output, recursive = T)
  }
}

