rm(list = ls())

spectra_massicotte <- readRDS("dataset/clean/spectra_massicotte.rds")
spectra_asmala2014 <- readRDS("dataset/clean/spectra_asmala2014.rds")

spectra <- bind_rows(spectra_massicotte, spectra_asmala2014)

# quick plot of raw data --------------------------------------------------
ggplot(spectra, aes(x = wavelength, y = absorption, group = sample_id)) +
  geom_line(size = 0.5) +
  facet_wrap(~dataset, ncol = 3)

ggsave("graphs/raw_data.pdf", width = 7, height = 5)

# fit the data ------------------------------------------------------------

x <- filter(spectra, wavelength == 350) %>% 
  select(absorption)

x <- as.vector(t(x))

fits <- list()

wl <- seq(250, 450, by = 1)

for(i in wl){
  y <- filter(spectra, wavelength == i) %>% 
    select(absorption)
  
  y <- as.vector(t(y))
  
  fits[[i - 249]] <- lm(x ~ y)
  #plot(x,y)
}

#---------------------------------------------------------------------
# Extract intercept, slope and R2.
#---------------------------------------------------------------------
intercept <- unlist(lapply(fits, function(x){coef(x)[1]}))
intercept_std <- unlist(lapply(fits, function(x){summary(x)$coefficients[1, 2]}))

slope <- unlist(lapply(fits, function(x){coef(x)[2]}))
slope_std <- unlist(lapply(fits, function(x){summary(x)$coefficients[2, 2]}))

r2 <- unlist(lapply(fits, function(x){summary(x)$r.squared}))

# Graph on effect of wl ---------------------------------------------------

df <- data.frame(wl = wl, 
                 intercept = intercept, 
                 slope = slope, 
                 r2 = r2,
                 slope_std = slope_std,
                 intercept_std = intercept_std)

saveRDS(df, "dataset/clean/fit_cdom.rds")

p1 <- ggplot(df, aes(x = wl, y = r2)) +
  geom_line() +
  geom_hline(yintercept = 0.99, size = 0.1, color = "cadetblue", lty = 2) +
  geom_hline(yintercept = 0.98, size = 0.1, color = "blue", lty = 2)

p2 <- ggplot(df, aes(x = wl, y = slope)) +
  geom_line() +
  geom_errorbar(aes(ymin = slope - slope_std, ymax = slope + slope_std),
                size = 0.1, col = "firebrick") 

p3 <- ggplot(df, aes(x = wl, y = intercept)) +
  geom_line() +
  geom_errorbar(aes(ymin = intercept - intercept_std, ymax = intercept + intercept_std),
                size = 0.1, col = "firebrick")

pdf("graphs/effect_wavelength.pdf", width = 5, height = 9)
grid.arrange(p1, p2, p3)
dev.off()


# histogram ---------------------------------------------------------------
df <- data.frame(x = x)

ggplot(df, aes(x = x)) +
  geom_histogram(binwidth = 10) +
  geom_vline(x = mean(intercept), col = "red") +
  xlab("a350")

ggsave("graphs/hist_a350.pdf")
