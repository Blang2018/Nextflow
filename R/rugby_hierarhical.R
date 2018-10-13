library("ggplot2")
library("ggpubr")
library("dplyr")

ROOT_PATH <- "/home/kevinchern/blang/blangSDK/results/all/2018-10-06-13-14-16-DvYGO22c.exec/samples/"
ROOT_PATH <- "/home/kevinchern/blang/blangSDK/results/latest/samples/"
atks_star <- read.csv(paste(ROOT_PATH, "atks_star.csv", sep=""))
# atks      <- read.csv(paste(ROOT_PATH, "atks.csv",      sep=""))
defs_star <- read.csv(paste(ROOT_PATH, "defs_star.csv", sep=""))
# defs      <- read.csv(paste(ROOT_PATH, "defs.csv",      sep=""))
home      <- read.csv(paste(ROOT_PATH, "home.csv"     , sep=""))
intercept <- read.csv(paste(ROOT_PATH, "intercept.csv", sep=""))
sd_atk    <- read.csv(paste(ROOT_PATH, "sd_atk.csv"   , sep=""))
sd_def    <- read.csv(paste(ROOT_PATH, "sd_def.csv"   , sep=""))

atks <- atks_star %>%
  group_by(sample) %>%
  mutate_at(vars(value), funs(subtr_mean = . - mean(.)))

defs <- defs_star %>%
  group_by(sample) %>%
  mutate_at(vars(value), funs(subtr_mean = . - mean(.)))

plot_astar <- ggplot(atks_star, aes(x = value, group = index_0, color = index_0)) + geom_density(size=1) + 
  scale_color_distiller(palette = "Set3") + 
  labs(colour = "Team Index", title = "atks_star") + xlim(-1, 1)
plot_dstar <- ggplot(defs_star, aes(x = value, group = index_0, color = index_0)) + geom_density(size=1) + 
  scale_color_distiller(palette = "Set3") +
  labs(colour = "Team Index", title = "defs_star") + xlim(-1, 1)

plot_home <- ggplot(home, aes(x = value)) + geom_density(size=1, colour="turquoise") +
  labs(title = "home") + xlim(0,0.3)

plot_sda <- ggplot(sd_atk, aes(x = value)) + geom_density(size = 1, colour="violet") + labs(title = "sd_atk") +
  xlim(0, 1.0)
plot_sdd <- ggplot(sd_def, aes(x = value)) + geom_density(size = 1, colour="violet") + labs(title = "sd_def") +
  xlim(0, 1.4)

plot_int <- ggplot(intercept, aes(x = value)) + geom_density(size=1, colour="turquoise") + 
  labs(title = "intercept") + xlim(2.8, 3.0)


plot_atks <- ggplot(atks, aes(x = subtr_mean, group = index_0, color = index_0)) + geom_density(size = 1) +
  scale_color_distiller(palette = "Set3") + labs(colour = "Team Index", title = "atks") + xlim(-0.4,0.4)
plot_defs <- ggplot(defs, aes(x = subtr_mean, group = index_0, color = index_0)) + geom_density(size = 1) +
  scale_color_distiller(palette = "Set3") + labs(colour = "Team Index", title = "defs") + xlim(-.6, 0.8)

dev.off()
ggarrange(plot_astar, plot_dstar, plot_home, plot_sda, plot_sdd, plot_int, plot_atks, plot_defs, ncol=1, nrow=8)


