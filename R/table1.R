# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Table presenting an overview of the data used in the study.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# Hashmap linking study to bibliography -----------------------------------

keys <- c(
  "agro",
  "antarctic",
  "arctic",
  "asmala2014",
  "bergen2007",
  "bouillon2014",
  "breton2009",
  "castillo1999",
  "chen2000",
  "cv1_om_pigments_seabass",
  "cv2_om_pigments_seabass",
  "cv3_om_pigments_seabass",
  "cv4_om_pigments_seabass",
  "cv5_om_pigments_seabass",
  "cv6_om_seabass",
  "dana12",
  "delcastillo2000",
  "engel2015",
  "everglades_pw",
  "everglades_sw",
  "finish_rivers",
  "forsstrom2015",
  "geocape_om_pigments",
  "gonnelli2016",
  "greenland_lakes",
  "griffin2011",
  "gueguen2011",
  "helms2008",
  "hernes2008",
  "horsens",
  "kattegat",
  "kellerman2015",
  "lambert2015",
  "loken2016",
  "lter5653",
  "lter5689",
  "massicotte2011",
  "nelson",
  "oestreich2016",
  "osburn2007",
  "osburn2009",
  "osburn2011",
  "osburn2016",
  "polaris2012",
  "retamal2007",
  "russian_delta",
  "sickman2010",
  "table5d",
  "tanana",
  "umeaa",
  "wagner2015",
  "zhang2005"
)

values <- c(
  "\\citet{agro}",
  "\\citet{Norman2011}",                # antarctic
  "\\citet{Stedmon2011}",               # arctic rivers
  "\\citet{Asmala2014}",
  "\\citet{Conan2007}",                 # Bergen
  "\\citet{Bouillon2014}",
  "\\citet{Breton2009}",
  "\\citet{Castillo1999}",
  "\\citet{Osburn2007}",               # chen2000
  "\\citet{Werdell2003}",              # cv1_om_pigments_seabass
  "\\citet{Werdell2003}",              # cv2_om_pigments_seabass
  "\\citet{Werdell2003}",              # cv3_om_pigments_seabass
  "\\citet{Werdell2003}",              # cv4_om_pigments_seabass
  "\\citet{Werdell2003}",              # cv5_om_pigments_seabass
  "\\citet{Werdell2003}",              # cv6_om_seabass
  "\\citet{Stedmon2015}",              # dana 12
  "\\citet{Delcastillo2000}",
  "\\citet{Engel2015}",
  "\\citet{Aiken2005}",                # everglades_pw
  "\\citet{Aiken2005}",                # everglades_sw
  "\\citet{finish_rivers}",
  "\\citet{Forsstrom2015}",
  "\\citet{Werdell2003}",              # geocape_om_pigments
  "\\citet{Gonnelli2016}",
  "\\citet{Anderson2007}",             # greenland lakes
  "\\citet{Griffin2011}",
  "\\citet{Gueguen2011}",
  "\\citet{Helms2008}",
  "\\citet{Hernes2008}",
  "\\citet{Markager2011}",             # Horsen
  "\\citet{kattegat}",
  "\\citet{Kellerman2015}",
  "\\citet{Lambert2015a}",
  "\\citet{Loken2016}",
  "\\citet{lter5653}",
  "\\citet{lter5689}",
  "\\citet{Massicotte2011EA}",
  "\\citet{Nelson2002}",
  "\\citet{Oestreich2016}",
  "\\citet{Osburn2007}",
  "\\citet{Osburn2009}",
  "\\citet{Osburn2011}",
  "\\citet{Osburn2016}",
  "\\citet{Polaris2012}",
  "\\citet{Retamal2007}",
  "\\citet{Goncalves2015}",           # Russian delta
  "\\citet{Sickman2010}",
  "\\citet{Aiken2005}",               # table5d
  "\\citet{tanana}",
  "\\citet{Stedmon2007a}",            # umeaa 
  "\\citet{Wagner2015}",
  "\\citet{Zhang2005}"
)

hm <- hashmap::hashmap(keys, values)

# Read and summarise the data ---------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>%
  mutate(bib_ref = hm[[study_id]]) %>% 
  mutate(source = ifelse(source == "literature", "Discrete", "Continuous")) %>% 
  group_by(bib_ref, source) %>%
  summarise(n = n(),
            date_min = as.character(min(date)),
            date_max = as.character(max(date)),
            min_doc = min(doc),
            max_doc = max(doc),
            min_a350 = min(absorption),
            max_a350 = max(absorption))

caption = "Summary of data used in this study. \\textit{Discrete} means that the 
absorption data was reported at discrete wavelengths whereas 
\\textit{Continuous} means that complete absorption spectra were available."

print(xtable::xtable(df,
                     align = c("lllrllrrrr"),
                     caption = caption),
      file = "article/tables/table1.tex",
      include.rownames = FALSE,
      sanitize.text.function = identity,
      sanitize.colnames.function = NULL,
      size = "footnotesize")

