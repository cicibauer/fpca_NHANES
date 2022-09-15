# Rest-activity profiles among U.S. adults in a nationally representative sample: a functional principal component analysis

This Github repository provides sample data and codes for the [published study](https://link.springer.com/article/10.1186/s12966-022-01274-4#Sec2).

## Overview

This study aimed at characterizing the rest-activity patterns in the general population and by demographic socioeconomic and work characteristics, and shed light on individual and environmental factors shaping the rest-activity behaviors. We applied functional Principal Component Analysis (fPCA) using 24-hr actigraphy data on a large sample that representative of the US population from The National Health and Nutrition Examination Survey (NHANES) 2011-2014 cycles.

## Research Questions

* How to characterize rest-activity patterns from 24-hr actigraphy data?
* What are the overall rest-activity patterns among the general population?
* How do different features of rest-activity pattern vary by demographics and socioeconomic factors?
* Are there any associations between the rest-activity pattern and health outcomes?

## Findings

* Four distinct rest-activity profiles were identified to describe aspects of overall amplitude, early rising time, prolonged daytime activity and biphasic pattern. [insert the profiles figure here. need access to upload figure]
* Rest-activity profiles are highly associated with age, race, education levels and household income levels.
* Rest-activity profiles differ on weekdays and weekends by demographics and socioeconomics.
* Lower overall activity is associated with higher odds of self-reported poor or fair health.

## Conclusions

In a nationally representative sample of US adults, we identified four distinct profiles for the 24-h rest-activity cycle. We found considerable variation in these profiles across different subgroups by age, gender, race/ethnicity, SES and work status. We also observed associations between rest-activity profiles and self-rated health status.

## Data
A sample data of 50 randomly selected subjects from NHANES 2011-2014 with accelerometer data can be found [here](NHANES_sample_data.rds).

This dataset includes the following variables:
- SEQN
- day
- fivemin: index of the 5 minutes epoch, integers from 1 to 288 (start from he midnight)
- activity_avg: average activity counts at 5 minutes epoch
- flag_min: number of minutes that have been flagged with invalid recording

## Codes

The main code to run fpca analysis on the sample data can be found [here](fPCA_analysis.R)

R function to [plot a functional object](plot_fd_new1.R)
- code adapted from plot.fd{fda}
- changes are made to present labels of xasis as clock time

R function to generate Figure1 in the paper of [functional principal components](plot_fpca_new1.R)
- code adapted from plot.pca.fd{fda}
- add argument 'flip' to decide which component(s) to have sign(s) flipped ('+' to '-' or vice versa)
- use different colors to represent component's sign
- modified x labels to clock time

Reference:
- J. O. Ramsay, Spencer Graves and Giles Hooker (2020). fda: Functional Data Analysis. R package version 5.1.9. https://CRAN.R-project.org/package=fda
