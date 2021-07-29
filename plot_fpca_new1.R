### based on source code of plot.pca.fd
### revisions:
### 1) colored add/subtract pca components
### 2) change xaxis labels to clock time of 0:00 - 23:00
### 3) add the argument of 'flip' to determine which components to flip the sign
### warning: depends on the results and interpretation, may not suitable for other data or analysis. 

plot.fpca.new <- function (x, nx = 128, pointplot = TRUE, harm = 0, expand = 0, 
          cycle = FALSE, flip=c(1,2,4)
          , ...) {
  pcafd <- x
  
  # xaxis labels and locations
  x.axis <- seq(from=0, to=24, by=1)
  x.axis.lab <- paste0(x.axis,":00")
  x.axis.loc <- x.axis/24*288
  
  if (!(inherits(pcafd, "pca.fd"))) 
    stop("Argument 'x' is not a pca.fd object.")
  harmfd <- pcafd[[1]]
  basisfd <- harmfd$basis
  rangex <- basisfd$rangeval
  {
    if (length(nx) > 1) {
      x <- nx
      nx <- length(x)
    }
    else x <- seq(rangex[1], rangex[2], length = nx)
  }
  fdmat <- eval.fd(x, harmfd)
  meanmat <- eval.fd(x, pcafd$meanfd)
  dimfd <- dim(fdmat)
  nharm <- dimfd[2]
  plotsPerPg <- sum(par("mfrow"))
  harm <- as.vector(harm)
  if (harm[1] == 0) 
    harm <- (1:nharm)
  if (length(dimfd) == 2) {
    for (jharm in 1:length(harm)) {
      #jharm=1
      if (jharm == 2) {
        op <- par(ask = TRUE)
        on.exit(par(op))
      }
      iharm <- harm[jharm]
      if (expand == 0) {
        fac <- sqrt(pcafd$values[iharm])
      }
      else {
        fac <- expand
      }
      vecharm <- fdmat[, iharm]
      #if (jharm == 3){ # fPCA3
      if (jharm %in% flip){
        pcmat <- cbind(meanmat + fac * (-vecharm)
                     , meanmat - fac * (-vecharm)
                     )
      }
      #else{ # fPCA1,2,4 flip the sign 
      else{
        pcmat <- cbind(meanmat + fac * vecharm
                       , meanmat - fac * vecharm
        )
      }
      
      if (pointplot) 
        plottype <- "p"
      else plottype <- "l"
      percentvar <- round(100 * pcafd$varprop[iharm], 1)
      plot(x, meanmat, type = "l", ylim = c(min(pcmat), 
                                            max(pcmat)), ylab = paste("Harmonic", iharm), 
           main = paste("PCA function", iharm, "(Percentage of variability", 
                        percentvar, ")")
           , xaxt="n", xlab=NA , ...
           )
      axis(1, at=x.axis.loc, labels=x.axis.lab, las=0) 
      
      if (pointplot) {
        points(x, pcmat[, 1], pch = "+", col="darkgoldenrod1")
        points(x, pcmat[, 2], pch = "-", col="blue1")
      }
      else {
        lines(x, pcmat[, 1], lty = 2, col="darkgoldenrod1")
        lines(x, pcmat[, 2], lty = 3, col="blue1")
      }
    }
  }
#  this is not a complete version as original plot.pca.fd function, the rest starting from here is deleted.
  invisible(NULL)
}
