library(ggplot2)
library(ggpubr)

ROOT_DIR <- "/home/kevinchern/blang/blangSDK/results/latest/samples/"
FILE_NAMES <- paste(ROOT_DIR, list.files(ROOT_DIR, pattern="*.csv"), sep="")
print(FILE_NAMES)
FILES <- lapply(FILE_NAMES, read.csv)
dat <- data.frame(FILES)

# earlyMean 
plot_early <- ggplot(data = dat) + geom_density(aes(x = dat$value))
trace_early <- ggplot(data = dat) + geom_line(aes(x = dat$sample, y = dat$value))
# lateMean 
plot_late <- ggplot(data = dat) + geom_density(aes(x = dat$value.1))
trace_late <- ggplot(data = dat) + geom_line(aes(x = dat$sample.1, y = dat$value.1))
# switchPoint
plot_switch <- ggplot(data = dat) + geom_histogram(aes(x = dat$value.3))
trace_switch <- ggplot(data = dat) + geom_line(aes(x = dat$sample.3, y = dat$value.3))

dev.off()
ggarrange(plot_early, trace_early, plot_late, trace_late, plot_switch, trace_switch, ncol=2, nrow = 3)

summary(dat$value)
summary(dat$value.1)
summary(dat$value.3)
