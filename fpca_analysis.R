####################################################################################
### Functional principle component analysis (fPCA) on Actigraphy accelerometer data
### R code prepared for manuscript: 
####################################################################################
#### R code used 50 randomly selected subjects with accelerometer data from NHANES 2011-2014 and perform the following
#### 1. calculate the mean activity value at each 5-min epoch across days for each subject
#### 2. perform fPCA analysis
#### 3. fit functional object split by median of fPCA eigenvalues

### load libraries
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
library(dplyr); library(fda)

### load script for different color scheme for making figures
source("plot_fd_new1.r")
source("plot_fpca_new1.r")

####################################################################################
#### 1. calculate the mean activity value at each 5-min epoch across days for each subject
####################################################################################
#### read in sample data
data0 <- readRDS("NHANES_sample_data.rds")
ID <- unique(data0$SEQN)

## create empty dataframe to store the mean activity values, the data structure will be:
## first column is the time index, in this case, 288 numbers of 5-min time stamp,
## followed by mean activity values at each time stamp, one column for each subject
## remove any subjects that do no thave a full-day of data
dat_wide <- data.frame(fivemin=1:288)
# if subjects have multiple days of recordings, take the average across days
for (j in 1:length(ID)){ # subject by subject
#  print(paste0("processing ",j,"-th subject"))
  ID.dat <- subset(data0, SEQN == ID[j])
  table(ID.dat$day)
  ### long to wide format, so one column for each day
  ID.dat.day.average <- ID.dat %>% group_by(fivemin) %>% summarise(activity_mean = mean(activity_avg, na.rm=T))
  ### if subjects do not have a full-day of data, skip them
  if(sum(!is.na(ID.dat.day.average$activity_mean)) < 288){print(paste0("removing ",j,"-th subject")); next}
  ### otherwise keep them
  names(ID.dat.day.average)[2] <- paste0("ID", ID[j])
  dat_wide <- cbind(dat_wide, ID.dat.day.average[, 2])
}
#saveRDS(dat_wide, "NHANES_sample_data_day_average.rds")
dim(dat_wide)
View(dat_wide)

####################################################################################
#### 2. perform fPCA analysis
####################################################################################
#dat <- readRDS("NHANES_sample_data_day_average.rds")
dat <- dat_wide
ID <- substr(colnames(dat)[-1],3,8)
### setup fitting functional object
n_basis <- 9 # number of basis functions, can only be odd numbers
### timepoints for x axis
timepoints <- 1:288	
## create fourier basis functions
basis <- create.fourier.basis(c(1,length(timepoints)), nbasis=n_basis)
## fit functional object
fd <- smooth.basis(timepoints, data.matrix(dat[,-1]), basis, method = "qr")$fd
L <- dim(fd$y)[1] # get the number of data samples.
fpar <- fdPar(basis) # functional parameter object
### first fit fPCA -- preliminary, to decide how many components to use
### here to we extract the first 9 PCA and then examine the scree plot
fpca0 <- pca.fd(fd, nharm=9, fpar)
par(mfrow=c(1,1))
plot(fpca0$values, type = "b", ylab = "eigenvalue", xlab = "number of components")
## choose an appropriate number of components to use in the final analysis
### here we choose 4 PCA based on the scree plot
fpca <- pca.fd(fd,nharm=4, fpar)
### plot fPCA components
## mean activity is same in all figures
## "+" shows add the component to the mean
## "-" shows subtract the component to the mean
par(mfrow=c(2,2))
plot(fpca,cex.main=.8)
flip <- c(1,2,4) # identify which components to flip the sign
plot.fpca.new(fpca,cex.main=.8, flip = flip) # flipped fPCA
### extract corresponding eigenvalues
score0 <- fpca$scores
# flip the sign for fPCA1,2,4
score0[,flip] <- -score0[,flip]
fpca$scores <- score0


#### custom functions for later use -------------------------------------------------
# build functional object for each dataset contained in the data.list
function1 <- function(data.list # list of datasets
){
  N.i <- length(data.list) # number of categories
  fd.list <- list()
  # get functional object for each category
  for (i in 1:length(data.list)){
    dat_wide <- data.list[[i]]
    # basis functions
    basis <- create.fourier.basis(c(0,length(timepoints)-1), nbasis=n_basis)
    # fit functional object
    fd <- smooth.basis(timepoints, data.matrix(dat_wide), basis, method = "qr")$fd
    fd.list[[i]] <- fd
  }
  return(fd.list)
}

#### plot mean activity
function2 <- function(fd.list,   # list of functional object (fd)
                      category,  # contains the label for each fd's category
                      main.title # title of the figure
){
  # only one plot will be in the output from this function
  #par(mfrow=c(1,1))
  N.i <- length(data.list) # number of categories
  plot.fd.new(mean.fd(fd.list[[1]])
              , ylab="Triaxial activity per minute"
              , ylim=c(0,25), xlim=c(0,length(timepoints))
              , col="black"
              , lty=1, lwd=2
              , main = main.title, font.main=1
  )
  for (i in 2:N.i){
    lines(mean.fd(fd.list[[i]], na.rm=TRUE), lwd=2, lty=i)
  }
  legend(legend=c(category)
         ,lwd=2
         , lty=1:N.i
         , bty = "n", x="topleft"
  )
}


####################################################################################
#### 3. fit functional object split by median of fPCA eigenvalues
####################################################################################
#### compare activity profiles split by median of fPCA score 
#### standardize with mean and sd
score <- scale(fpca$scores) 
summary(score) 
score1 <- data.frame(ID=ID, score=score)
colnames(score1)[2:5] <- paste0("fPCA", 1:4)
#### create categorical variable by median of fPCA
fpca_grp <- score1 %>% 
  mutate(fPCA1_grp = cut(fPCA1,breaks=unique(quantile(fPCA1, probs=seq(0, 1, by=.5),na.rm=T)),
                         labels=c("low","high"), include.lowest=TRUE)) %>% 
  mutate(fPCA2_grp = cut(fPCA2,breaks=unique(quantile(fPCA2, probs=seq(0, 1, by=.5),na.rm=T)),
                         labels=c("low","high"), include.lowest=TRUE)) %>% 
  mutate(fPCA3_grp = cut(fPCA3,breaks=unique(quantile(fPCA3, probs=seq(0, 1, by=.5),na.rm=T)),
                         labels=c("low","high"), include.lowest=TRUE)) %>% 
  mutate(fPCA4_grp = cut(fPCA4,breaks=unique(quantile(fPCA4, probs=seq(0, 1, by=.5),na.rm=T)),
                         labels=c("low","high"), include.lowest=TRUE))
#### set-up for fitting functional object
## this does not necessarily have to be the same with what is used in fPCA analysis
n_basis <- 9 # number of basis functions, can only be odd
timepoints <- 1:288
dat_all <- dat[,-1]
temp <- fpca_grp # dataset to run fda
category <- c("high","low")
## ID by fPCA quantile: for PCA1
ID_1 <- ID[ID %in% temp$ID[temp$fPCA1_grp == "high"]]
ID_2 <- ID[ID %in% temp$ID[temp$fPCA1_grp == "low"]]
dat1 <- dat_all[ , ID %in% ID_1]
dat2 <- dat_all[ , ID %in% ID_2]
data.list <- list(dat1, dat2)
fdlist_fpca1 <- function1(data.list)
## ID by fPCA quantile:for PCA2
ID_1 <- ID[ID %in% temp$ID[temp$fPCA2_grp == "high"]]
ID_2 <- ID[ID %in% temp$ID[temp$fPCA2_grp == "low"]]
dat1 <- dat_all[ , ID %in% ID_1]
dat2 <- dat_all[ , ID %in% ID_2]
data.list <- list(dat1, dat2)
fdlist_fpca2 <- function1(data.list)
## ID by fPCA quantile:for PCA3
ID_1 <- ID[ID %in% temp$ID[temp$fPCA3_grp == "high"]]
ID_2 <- ID[ID %in% temp$ID[temp$fPCA3_grp == "low"]]
dat1 <- dat_all[ , ID %in% ID_1]
dat2 <- dat_all[ , ID %in% ID_2]
data.list <- list(dat1, dat2)
fdlist_fpca3 <- function1(data.list)
## ID by fPCA quantile:for PCA4
ID_1 <- ID[ID %in% temp$ID[temp$fPCA4_grp == "high"]]
ID_2 <- ID[ID %in% temp$ID[temp$fPCA4_grp == "low"]]
dat1 <- dat_all[ , ID %in% ID_1]
dat2 <- dat_all[ , ID %in% ID_2]
data.list <- list(dat1, dat2)
fdlist_fpca4 <- function1(data.list)

#### now making figures
par(mfrow=c(2,2))
function2(fdlist_fpca1, category, "standardized fPCA1")
function2(fdlist_fpca2, category, "standardized fPCA2")
function2(fdlist_fpca3, category, "standardized fPCA3")
function2(fdlist_fpca4, category, "standardized fPCA4")
