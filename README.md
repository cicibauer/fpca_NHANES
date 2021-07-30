# fpca_NHANES 

### "sample_data.rds" includes 50 subjects randomly selected from NHANES 2011-2014 with accelerometer data
This dataset includes the following variables:
- SEQN
- day
- fivemin: index of the 5 minutes epoch, integers from 1 to 288 (starting from midnight)
- activity_avg: average activity counts at 5 minutes epoch
- flag_min: number of minutes that have been flagged with invalid recording

### "plot_fd_new1.R" includes R functions to plot a functional data object
- code adapted from plot.fd{fda}
- changes are made to present labels of xasis as clock time 

### "plot_fpca_new1.R" includes R functions to generate figures displaying functional principal components
- code adapted from plot.pca.fd{fda}
- add argument 'flip' to decide which component(s) to have sign(s) flipped ('+' to '-' or vice versa)
- use different colors to represent component's sign
- modified x labels to clock time

- J. O. Ramsay, Spencer Graves and Giles Hooker (2020). fda: Functional Data Analysis. R package version 5.1.9. https://CRAN.R-project.org/package=fda
 
### "fPCA_analysis code" includes the main R code to run fpca analysis on the sample NHANES data. 
