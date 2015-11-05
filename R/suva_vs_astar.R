#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         suva_vs_astar.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relationship between SUVA and astar
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_asmala <- read_rds("dataset/clean/spectra_asmala2014.rds") %>% 
  mutate(date = as.Date(str_extract(sample_id, "\\d{4}-\\d{2}-\\d{2}"))) %>% 
  mutate(sample_id = str_sub(sample_id, 12, -3)) %>% 
  mutate(absorbance = absorption / 2.303)
  
doc_asmala <- read_rds("dataset/clean/asmala2014.rds") %>% 
  mutate(doc = doc / 1000 * 12) %>% ## umolC to mgC
  select(sample_id, doc)

data <- inner_join(cdom_asmala, doc_asmala, by = "sample_id") %>% 
  select(sample_id, wavelength, absorbance, doc) %>%
  mutate(a_star = absorbance / doc) %>% 
  select(sample_id, wavelength, a_star) %>% 
  arrange(sample_id, wavelength) %>% 
  unique() 

data$a_star[data$a_star > 8] <- NA

head(data)


x <- filter(data, wavelength == 254) %>% 
  select(suva = a_star)

wl <- seq(250, 450, by = 10)

fits <- list()
dat <- list()

for(i in 1:length(wl)){
  
  y <- filter(data, wavelength == wl[i]) %>% 
    select(a_star)
  
  fits[[i]] <- lm(y$a_star ~ x$suva)
  
  dat[[i]] <- data.frame(suva = x$suva, astar = y$a_star)

}

r2 <- lapply(fits, function(x){summary(x)$r.squared}) %>% 
  unlist()

dat <- bind_cols(dat)
dat <- dat[, c(1, seq(2, ncol(dat), by = 2))]
names(dat)[2:ncol(dat)] <- paste(names(dat)[2:ncol(dat)], wl, sep = "_")

#---------------------------------------------------------------------
# Some plots
#---------------------------------------------------------------------

ggplot(data.frame(wl = wl, r2 = r2), aes(x = wl, y = r2)) + 
  geom_point() +
  geom_line() +
  xlab("Wavelength (nm.)") +
  ylab(expression(R^2))

ggsave("graphs/suva_vs_astar_1.pdf")


dat <- gather(dat, wavelength, a_star, -suva)

ggplot(dat, aes(x = suva, y = a_star)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm") +
  facet_wrap(~wavelength, ncol = 5, scales = "free")

ggsave("graphs/suva_vs_astar_2.pdf", width = 10, height = 7)
