rm(list = ls())

spectra <- readRDS("data/clean/spectra.rds")



# quick plot of raw data --------------------------------------------------
ggplot(spectra, aes(x = wavelength, y = absorbance, group = sample)) +
  geom_line(size = 0.1) +
  facet_wrap(~dataset, ncol = 3)

ggsave("graphs/raw_data.pdf")

# fit the data ------------------------------------------------------------

x <- filter(spectra, wavelength == 350) %>% 
  select(absorbance)

x <- as.vector(t(x))

fits <- list()

wl <- seq(250, 450, by = 1)

for(i in wl){
  y <- filter(spectra, wavelength == i) %>% 
    select(absorbance)
  
  y <- as.vector(t(y))
  
  fits[[i - 249]] <- lm(x ~ y)
}


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

saveRDS(df, "data/clean/fit_cdom.rds")

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


p3 + ylim(min(x), max(x)) # A relative perspective



# histogram ---------------------------------------------------------------
df <- data.frame(x = x)
ggplot(df, aes(x = x)) +
  geom_histogram(binwidth = 0.01) +
  geom_vline(x = 0.010, col = "red")

