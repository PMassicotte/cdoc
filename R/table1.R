# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Table presenting an overview of the data used in the study.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# Hashmap linking study to bibliography -----------------------------------

refs <- list(
  "agro" = "\\citet{agro}",
  "antarctic" = "\\citet{Norman2011}",
  "arctic" = "\\citet{Stedmon2011}",
  "asmala2014" = "\\citet{Asmala2016}",
  "bergen2007" = "\\citet{Conan2007}",
  "bouillon2014" = "\\citet{Bouillon2014}",
  "breton2009" = "\\citet{Breton2009}",
  "castillo1999" = "\\citet{Castillo1999}",
  "chen2000" = "\\citet{Osburn2007}",
  "cv1_om_pigments_seabass" = "\\citet{Werdell2003}",
  "cv2_om_pigments_seabass" = "\\citet{Werdell2003}",
  "cv3_om_pigments_seabass" = "\\citet{Werdell2003}",
  "cv4_om_pigments_seabass" = "\\citet{Werdell2003}",
  "cv5_om_pigments_seabass" = "\\citet{Werdell2003}",
  "cv6_om_seabass" = "\\citet{Werdell2003}",
  "dana12" = "\\citet{Stedmon2015}",
  "delcastillo2000" = "\\citet{Delcastillo2000}",
  "engel2015" = "\\citet{Engel2015}",
  "everglades_pw" = "\\citet{Aiken2005}",
  "everglades_sw" = "\\citet{Aiken2005}",
  "finish_rivers" = "\\citet{Finishriver2016}",
  "forsstrom2015" = "\\citet{Forsstrom2015}",
  "geocape_om_pigments" = "\\citet{Werdell2003}",
  "gonnelli2016" = "\\citet{Gonnelli2016}",
  "greenland_lakes" = "\\citet{Anderson2007}",
  "griffin2011" = "\\citet{Griffin2011}",
  "gueguen2011" = "\\citet{Gueguen2011}",
  "helms2008" = "\\citet{Helms2008}",
  "hernes2008" = "\\citet{Hernes2008}",
  "horsens" = "\\citet{Markager2011}",
  "kattegat" = "\\citet{Osburn2011, Stedmon2010a}",
  "kellerman2015" = "\\citet{Kellerman2015b}",
  "lambert2015" = "\\citet{Lambert2015a}",
  "loken2016" = "\\citet{Loken2016}",
  "lter5653" = "\\citet{lter5653}",
  "lter5689" = "\\citet{lter5689}",
  "massicotte2011" = "\\citet{Massicotte2011EA}",
  "nelson" = "\\citet{Nelson2002, Nelson2007, Nelson2010}",
  "oestreich2016" = "\\citet{Oestreich2016}",
  "osburn2007" = "\\citet{Osburn2007}",
  "osburn2009" = "\\citet{Osburn2009}",
  "osburn2011" = "\\citet{Osburn2011a}",
  "osburn2016" = "\\citet{Osburn2016}",
  "polaris2012" = "\\citet{Polaris2012}",
  "retamal2007" = "\\citet{Retamal2007}",
  "russian_delta" = "\\citet{Goncalves2015}",
  "sickman2010" = "\\citet{Sickman2010}",
  "table5d" = "\\citet{Aiken2005}",
  "tanana" = "\\citet{Moran2006}",
  "umeaa" = "\\citet{Stedmon2007a}",
  "wagner2015" = "\\citet{Wagner2015}",
  "zhang2005" = "\\citet{Zhang2005}",
  "lter2004" = "\\citet{lter2004}",
  "brezonik2015" = "\\citet{Brezonik2015}",
  "kutser2005" = "\\citet{Kutser2005}",
  "lter2008" = "\\citet{lter2008}",
  "tehrani2013" = "\\citet{Tehrani2013}",
  "galgani2016" = "\\citet{Galgani2016}",
  "braun2015" = "\\citet{Braun2015}",
  "shen2014" = "\\citet{Shen2014}",
  "hur2014" = "\\citet{Hur2014}",
  "nguyen2010" = "\\citet{Nguyen2010}",
  "yang2013" = "\\citet{Yang2013a}",
  "shank2009" = "\\citet{shank2009}",
  "devilbiss2016" = "\\citet{DeVilbiss2016}",
  "hong2012" = "\\citet{Hong2012}",
  "kowalczuk2013" = "\\citet{Kowalczuk2013}",
  "kowalczuk2010" = "\\citet{Kowalczuk2010}",
  "kowalczuk2010a" = "\\citet{Kowalczuk2010a}",
  "spencer2007" = "\\citet{Spencer2007, Spencer2007a}",
  "heinz2015" = "\\citet{Heinz2015}",
  "chen2004" = "\\citet{Chen2004}",
  "seritti1998" = "\\citet{Seritti1998}",
  "csiro" = "\\citet{CSIRO}",
  "banks2016" = "\\citet{Banks2016}",
  "kowalczuk2012" = "Kowalczuk (2012)\\footnote{Dr Piotr Kowalczuk is acknowledged for providing unpublished collection of the data set from ANTXXVIII/5 cruise on board of FS Polarstern was supported by FP7 Project EUROFLEETS, grant agreement no. 228344 and the research grant no. 546/N-AMT-CDOM/2009/0 awarded to PK by the National Science Centre, Poland.}",
  "bittar2016" = "\\citet{Bittar2016}"
)

# Check for missing studies -----------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather")
setdiff(unique(df$study_id), names(refs))


# Add dates to Nelson -----------------------------------------------------

n <- length(which(df$study_id == "nelson"))
df$date[df$study_id == "nelson"] <- sample(as.Date(c("2003-06-01", "2007-04-30")), size = n, replace = TRUE)


# Read and summarise the data ---------------------------------------------

df <- df %>%
  mutate(bib_ref = unlist(refs[study_id], use.names = FALSE)) %>% 
  mutate(source = ifelse(source == "literature", "Discrete", "Continuous")) %>% 
  group_by(bib_ref, source) %>%
  summarise(n = n(),
            date_min = as.character(min(date, na.rm = TRUE)),
            date_max = as.character(max(date, na.rm = TRUE)),
            doc_min = format(round(min(doc)), nsmall = 0),
            doc_max = format(round(max(doc)), nsmall = 0),
            a350_min = round(min(absorption), digits = 2),
            a350_max = round(max(absorption), digits = 2)) %>% 
  arrange(bib_ref) %>% 
  unite(sampling_period, date_min, date_max, sep = "---") %>% 
  unite(range_doc, doc_min, doc_max, sep = "-") %>% 
  unite(range_doc, a350_min, a350_max, sep = "-")

caption = "Summary of data used in this study. \\textit{Discrete} means that the absorption data was reported at discrete 
wavelengths whereas \\textit{Continuous} means that complete absorption spectra were available. \\textit{n} represents the 
number of unique observations in each study."


xt <- xtable::xtable(df,
                     align = c("lllrcll"),
                     caption = caption)

names(xt) <- c(
  "Reference",
  "Type",
  "$n$",
  "Sampling period",
  "DOC ($\\mu mC \\times L^{-1}$)",
  "$a_{CDOM}(350) (m^{-1})$"
)

print(
  xt,
  file = "article/tables/table1.tex",
  include.rownames = FALSE,
  # sanitize.text.function = identity,
  # sanitize.colnames.function = NULL,
  size = "footnotesize",
  tabular.environment = "longtable",
  floating = FALSE,
  sanitize.text.function = function(x) {
    x
  }
  
)

system("cd article/tables/; pdflatex tables.tex", wait = FALSE)


