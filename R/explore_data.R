#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         explore_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Priliminary script to explore data.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

data_all <- readRDS("dataset/clean/data_all.rds")

#---------------------------------------------------------------------
# Figure 1 for the meeting.
# 
# This is done to show the differences in slope and intercept.
#---------------------------------------------------------------------

dat <- filter(data_all, wavelength %in% c(254, 300, 350, 400))

p <- ggplot(dat, aes(x = doc, y = acdom)) +
  geom_point(aes(color = salinity), alpha = 0.5) +
  geom_smooth(method = "lm") +
  xlab("DOC (um/L)") +
  ylab(expression(paste("acdom (", m^{-1}, ")", sep = ""))) +
  facet_wrap(~wavelength, nrow = 2)
  
ggsave("graphs/fig1.pdf", p, width = 6, height = 4)


#---------------------------------------------------------------------
# Figure 2 (R2 of 350 vs. moving wavelength)
#---------------------------------------------------------------------

## Panel A

df <- readRDS("dataset/clean/fit_cdom.rds")

p1 <- ggplot(df, aes(x = wl, y = r2)) +
  geom_line() +
  xlab("Wavelength (nm.)") +
  ylab(expression(R^2)) +
  geom_hline(yintercept = 0.99, size = 0.1, color = "red", lty = 2) +
  geom_hline(yintercept = 0.98, size = 0.1, color = "blue", lty = 2) +
  annotate("text", x = 450, y = 0.97, label = 0.98, size = 3, color = "blue") +
  annotate("text", x = 450, y = 1, label = 0.99, size = 3, color = "red")

## Panel B

df <- readRDS("dataset/clean/spectra_asmala2014.rds") %>% 
  bind_rows(readRDS("dataset/clean/spectra_massicotte.rds"))

dat_350 <- filter(df, wavelength == 350)
dat_254 <- filter(df, wavelength == 254)
dat <- data.frame(acdom350 = dat_350$absorption, acdom254 = dat_254$absorption)

p2 <- ggplot(dat, aes(x = acdom350, y = acdom254)) +
  geom_point() +
  geom_smooth(method = "lm")

## Panel C

dat_350 <- filter(df, wavelength == 350)
dat_300 <- filter(df, wavelength == 300)
dat <- data.frame(acdom350 = dat_350$absorption, acdom300 = dat_300$absorption)

p3 <- ggplot(dat, aes(x = acdom350, y = acdom300)) +
  geom_point() +
  geom_smooth(method = "lm")

## Panel D

dat_350 <- filter(df, wavelength == 350)
dat_400 <- filter(df, wavelength == 400)
dat <- data.frame(acdom350 = dat_350$absorption, acdom400 = dat_400$absorption)

p4 <- ggplot(dat, aes(x = acdom350, y = acdom400)) +
  geom_point() +
  geom_smooth(method = "lm")

pdf("graphs/fig2.pdf", width = 8, height = 5)
grid.arrange(p1, p2, p3, p4)
dev.off()

#---------------------------------------------------------------------
# Figure 3 (massive plot; 350 vs. DOC, studies separated with colour, 
# also w/ log-scale)
#---------------------------------------------------------------------

dat <- filter(data_all, wavelength %in% c(340, 350), acdom > 0) %>% 
  na.omit()

p1 <- ggplot(dat, aes(x = doc, y = acdom, group = study_id)) +
  geom_point(aes(color = study_id), alpha = 0.5) +
  geom_smooth(method = "lm", aes(color = study_id)) +
  xlab("DOC (um/L)") +
  ylab(expression(acdom[340-350]))

p2 <- p1 +
  scale_y_log10() + 
  scale_x_log10() +
  annotation_logticks()

pdf("graphs/fig3.pdf", width = 8, height = 8)
grid.arrange(p1, p2)
dev.off()


