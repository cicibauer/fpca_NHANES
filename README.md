# fpca_NHANES 

### "sample_data.rds" includes 50 subjects randomly selected from NHANES 2011-2014 with accelerometer data
This dataset includes the following variables:
- SEQN
- day
- fivemin: index of the 5 minutes epoch, integers from 1 to 288 (starting from midnight)
- activity_avg: average activity counts at 5 minutes epoch
- flag_min: number of minutes that have been flagged with invalid recording

### "plot_fd_new1.R" includes R functions to generate figures displaying analysis after fpca. 

### "plot_fpca_new1.R" includes R functions to generate figures displaying analysis after fpca. 

### "fPCA_analysis code" includes the main R code to run fpca analysis on the sample NHANES data. 