# analysis at commit: 6f8c12d

library(gt)
library(dplyr)
library(ggplot2)

srcNames <- c("audit.c", "auditfilter.c", "audit_fsnotify.c", "auditsc.c", "audit_tree.c", "audit_watch.c")

## per-file ##
initFileCvg<- read.csv("../data/at-6f8c12d/file-cvg.csv", 
                       col.names = c("file", "cvg"))

mean(initFileCvg$cvg)

# plot bar chart
barplot(initFileCvg$cvg, 
        ylim=c(0,100), 
        xlab="Audit Subssystem Source Code File", 
        ylab="Code Coverage (%)",
        names.arg = srcNames, 
        cex.names = .85)


## per-function ##
audit <- read.csv("../data/at-6f8c12d/audit.c.csv", 
                  col.names = c("function", "cvg", "fs", "ss", "pcii"))

auditfilter <- read.csv("../data/at-6f8c12d/auditfilter.c.csv", 
                  col.names = c("function", "cvg", "fs", "ss", "pcii"))

audit_fsnotify <- read.csv("../data/at-6f8c12d/audit_fsnotify.c.csv", 
                  col.names = c("function", "cvg", "fs", "ss", "pcii"))

auditsc <- read.csv("../data/at-6f8c12d/auditsc.c.csv", 
                           col.names = c("function", "cvg", "fs", "ss", "pcii"))

audit_tree <- read.csv("../data/at-6f8c12d/audit_tree.c.csv", 
                           col.names = c("function", "cvg", "fs", "ss", "pcii"))

audit_watch <- read.csv("../data/at-6f8c12d/audit_watch.c.csv", 
                           col.names = c("function", "cvg", "fs", "ss", "pcii"))

audit_all <- c(audit$cvg, auditsc$cvg, auditfilter$cvg, audit_watch$cvg,
               audit_fsnotify$cvg, audit_tree$cvg)

# plot histogram
hist(audit_all, main="", 
     xlab="Code Coverage (%)", ylab="Number of Functions")


# Some metrics of interest
nFunctions <- audit_all >= 0 & audit_all <= 100
sum(nFunctions)

zeroCvgFunc <- audit_all == 0
sum(zeroCvgFunc)

lowCvgFunc <- audit_all > 0 & audit_all <= 50
sum(lowCvgFunc)

goodCvgFunc <- audit_all > 50 & audit_all <= 80
sum(goodCvgFunc)

highCvgFunc <- audit_all  > 80 & audit_all < 100
sum(highCvgFunc)

fullCvgFunc <- audit_all == 100
sum(fullCvgFunc)


## PCII metrics ##
df <- data_frame(audit)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
audit_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

df <- data_frame(auditsc)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
auditsc_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

df <- data_frame(auditfilter)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
auditfilter_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

df <- data_frame(audit_watch)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
audit_watch_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

df <- data_frame(audit_fsnotify)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
audit_fsnotify_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

df <- data_frame(audit_tree)
df_z <- subset(df, cvg == 0)
df_l <- subset(df, cvg > 0 & cvg <= 50)
df_g <- subset(df, cvg > 50 & cvg <= 80)
df_h <- subset(df, cvg > 80 & cvg < 100)
audit_tree_pcii <- c(sum(df_z$pcii), sum(df_l$pcii), sum(df_g$pcii), sum(df_h$pcii))

data <- matrix(c(audit_pcii, auditsc_pcii, auditfilter_pcii, audit_watch_pcii, audit_fsnotify_pcii, audit_tree_pcii),  nrow = 4, ncol = 6,byrow = TRUE)
colnames(data) <- srcNames
l <- c("0%","0%-50%","50%-80%","80%-100%")

data_percentage <- apply(data, 2, function(x){x*100/sum(x,na.rm=T)})

# plot stacked bar chart
barplot(data_percentage, xlim = c(0, 7), xlab="Audit Subssystem Source Code File", 
        ylab="PCII (%)",
        cex.names = 0.85)
par(xpd=TRUE)
legend(x="top", legend = l, fill=c("#4d4d4d", "#969696", "#c3c3c3", "#e6e6e6"), inset=c(0,-0.12), horiz=TRUE, cex = 0.8, box.lwd=0, text.width = 0.9, bg="transparent")

# some metrics of interest
mean(data_percentage[1,])
mean(data_percentage[2,])
mean(data_percentage[3,])
mean(data_percentage[4,])

data_percentage[,1]
data_percentage[,2]
data_percentage[,3]
data_percentage[,4]
data_percentage[,5]
data_percentage[,6]

data_percentage