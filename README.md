CDOC project
================

Motivations
-----------

Numerous studies are presenting graphics or data about the DOC/aCDOM relationship. However, there are at least two potential problems:

1.  Given that results are often study-specific, we are clearly missing the big picture since the results are rarely discussed from a broader perspective.

2.  People are using different wavelengths (254, 300, 350, 400, …) to present aCDOM data, hence preventing literature comparisons.

The idea of this project is to use published data to explore the relationships between DOC and aCDOM across a large gradient of ecosystems (from lakes to open ocean) in order to highlight potential drivers influencing such relationships. Additionally, we could use this opportunity to:

-   Provide a “standard” value for the wavelength used to report aCDOM.

-   Find patterns or drivers in CDOM/DOC relationship.

-   Provide/advertise an open aCDOM repository (database) where researchers could deposit their published data. Given that aCDOM is nowadays routinely measured in most ecological studies, this could provide a central point for further research on aCDOM.

Database
========

Possible sources
----------------

Naming convention
-----------------

There are few *rules* that should be used to make data importation and merging as easy as possible.

1.  Use lower-case variable names. Example: `var1` vs `Var1`.

2.  Use underscore `_` rather than space in variable names. Example: `sample_id` vs `sample id`.

3.  Avoid *weird* characters such as `èçê`.

Variables
---------

This section presents the list of variables that should be *minimally* included in each dataset.

-   `study_id`: The unique identifier for the study where the data have been extracted. For example: *asmala2014*.

-   `sample_id`: The unique identifier for the sample.

-   `doc`: Dissolved organic carbon (DOC) concentration (in µmol/l).

-   `acdom`: CDOM value expressed in absorption coefficient (*m-1*).

-   `wavelength`: Wavelength at which `acdom` was measured.

-   `date`: Date at which the sampling took place.

-   `longitude`: Longitude expressed in degree decimal. Example: `23.7109`.

-   `latitude`: Latitude expressed in degree decimal. Example: `60.4876`.

Note that we are excluding data where people have been using the same DOC value but with differents absorption measurements. For example, in Mladenov 2011, they have using the same DOC at different depths with with many aCDO measurements.

Graphics
========

All graphics will be automatically updated in the `graphs` folder on Dropbox.

Datasets overview
=================

Data with complete CDOM absorption profils
------------------------------------------

| study\_id        |     n|
|:-----------------|-----:|
| agro             |   168|
| antarctic        |    58|
| arctic           |    78|
| asmala2014       |   140|
| bergen2007       |   248|
| chen2000         |   150|
| dana12           |   189|
| greenland\_lakes |    38|
| horsens          |   551|
| kattegat         |   497|
| lter2004         |   102|
| massicotte2011   |    59|
| nelson           |  2333|
| osburn2007       |    37|
| umeaa            |    15|

    ## [1] 4663

Data from the literature
------------------------

| study\_id                  |  wavelength|     n|
|:---------------------------|-----------:|-----:|
| bouillon2014               |         350|    30|
| braun2015                  |         254|   263|
| breton2009                 |         320|    48|
| brezonik2015               |         254|    35|
| brezonik2015               |         440|    35|
| castillo1999               |         300|    26|
| cv1\_om\_pigments\_seabass |         355|   113|
| cv1\_om\_pigments\_seabass |         380|   113|
| cv1\_om\_pigments\_seabass |         412|   113|
| cv1\_om\_pigments\_seabass |         443|   113|
| cv2\_om\_pigments\_seabass |         355|   123|
| cv2\_om\_pigments\_seabass |         380|   123|
| cv2\_om\_pigments\_seabass |         412|   123|
| cv2\_om\_pigments\_seabass |         443|   123|
| cv3\_om\_pigments\_seabass |         355|    72|
| cv3\_om\_pigments\_seabass |         380|    72|
| cv3\_om\_pigments\_seabass |         412|    72|
| cv3\_om\_pigments\_seabass |         443|    72|
| cv4\_om\_pigments\_seabass |         355|   163|
| cv4\_om\_pigments\_seabass |         380|   163|
| cv4\_om\_pigments\_seabass |         412|   163|
| cv4\_om\_pigments\_seabass |         443|   163|
| cv5\_om\_pigments\_seabass |         355|   115|
| cv5\_om\_pigments\_seabass |         380|   115|
| cv5\_om\_pigments\_seabass |         412|   115|
| cv5\_om\_pigments\_seabass |         443|   115|
| cv6\_om\_seabass           |         355|   192|
| cv6\_om\_seabass           |         380|   192|
| cv6\_om\_seabass           |         412|   192|
| cv6\_om\_seabass           |         443|   192|
| delcastillo2000            |         375|    13|
| delcastillo2000            |         412|    13|
| delcastillo2000            |         440|     8|
| engel2015                  |         325|   247|
| engel2015                  |         355|   247|
| engel2015                  |         375|   226|
| everglades\_pw             |         254|   603|
| everglades\_sw             |         254|   263|
| finish\_rivers             |         254|  2823|
| forsstrom2015              |         320|    19|
| forsstrom2015              |         440|    19|
| galgani2016                |         325|    76|
| geocape\_om\_pigments      |         355|   121|
| geocape\_om\_pigments      |         380|   121|
| geocape\_om\_pigments      |         412|   121|
| geocape\_om\_pigments      |         443|   121|
| gonnelli2016               |         254|    13|
| gonnelli2016               |         280|    13|
| gonnelli2016               |         325|    13|
| gonnelli2016               |         355|    13|
| gonnelli2016               |         443|     9|
| griffin2011                |         400|    18|
| gueguen2011                |         355|     8|
| helms2008                  |         254|    33|
| helms2008                  |         300|    33|
| hernes2008                 |         350|    29|
| hur2014                    |         254|    38|
| kellerman2015              |         254|   113|
| kutser2005                 |         420|    14|
| lambert2015                |         350|   573|
| loken2016                  |         254|   206|
| lter2008                   |         254|    45|
| lter2008                   |         280|    45|
| lter2008                   |         300|    45|
| lter2008                   |         320|    45|
| lter2008                   |         365|    45|
| lter2008                   |         400|    45|
| lter2008                   |         420|    45|
| lter2008                   |         440|    45|
| lter5653                   |         253|    30|
| lter5653                   |         280|    30|
| lter5653                   |         440|    35|
| lter5689                   |         254|   136|
| lter5689                   |         300|   135|
| lter5689                   |         350|   134|
| lter5689                   |         400|   129|
| nguyen2010                 |         254|     9|
| oestreich2016              |         340|    29|
| osburn2009                 |         330|    27|
| osburn2011                 |         350|    20|
| osburn2016                 |         254|   130|
| osburn2016                 |         350|   130|
| polaris2012                |         254|   116|
| polaris2012                |         350|   116|
| polaris2012                |         400|   116|
| polaris2012                |         412|    62|
| polaris2012                |         440|    61|
| retamal2007                |         320|    22|
| russian\_delta             |         350|    38|
| russian\_delta             |         443|    38|
| shen2014                   |         254|    28|
| shen2014                   |         280|    28|
| shen2014                   |         350|    28|
| sickman2010                |         254|    72|
| table5d                    |         254|    28|
| tanana                     |         254|    86|
| tehrani2013                |         412|    39|
| wagner2015                 |         254|    60|
| yang2013                   |         350|    25|
| yang2013                   |         412|    24|
| zhang2005                  |         280|    16|
| zhang2005                  |         355|    16|
| zhang2005                  |         440|    16|

The total of **unique** observation in the literature dataset is 0.

Total number of observations:

    ## Warning: Unknown column 'n'

    ## [1] 4663

Spatial coverage
================

Complete profils data with missing coordinates:

    ## # A tibble: 0 x 1
    ## # ... with 1 variables: study_id <chr>

Literature data with missing coordinates:

    ## # A tibble: 0 x 1
    ## # ... with 1 variables: study_id <chr>

<!-- # Ecotypes -->
<!-- ## Complete profils datasets -->
<!-- ```{r, echo = FALSE} -->
<!-- cdom_dataset %>% -->
<!--   group_by(study_id, ecotype) %>% -->
<!--   summarise(n = n_distinct(unique_id)) %>% -->
<!--   arrange(study_id) %>% -->
<!--   knitr::kable() -->
<!-- ``` -->
<!-- ## Literature datasets -->
<!-- ```{r, echo = FALSE} -->
<!-- literature_dataset %>% -->
<!--   group_by(study_id, ecotype) %>% -->
<!--   summarise(n = n_distinct(unique_id)) %>% -->
<!--   arrange(study_id) %>% -->
<!--   knitr::kable() -->
<!-- ``` -->
Questions for Colin
===================

Colin provided a huge dataset of CDOM and DOC observations. I did my best to pre-process these data. However, here are some pending questions.

Graphics of CDOM profils for each dataset can be found on the Dropbox folder under `/graphs/colin`.

Nelson ocean (incl. AOU) ~1000
------------------------------

-   CDOM profiles have been measured between 275 and 729 nm.

-   I originally had ~ 9000 CDOM profiles. After removing observations with no DOC values we have n = 2359. Is it normal to have "only" 2359 measurements of DOC?

-   CDOM is presumed to be absorption coefficients (not absorbance).

Antarctic
---------

-   Only `Brines` DOC are available in the data. I am missing something?

-   In the file `Antarctic_abs.sas7bdat` there are two date fields `m_date` and `Date`. I used `Date`.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

-   Need to validate sampling locations (see the KML file).
    -   lat/long seem to have been inverted in the SAS file. I made the switch.
-   Some stations (eg. `061010SHa`) have no geographical information.

Dana12
------

-   CDOM were converted to absorption coefficients using a pathlength of 0.01m. Is that OK?

Arctic rivers
-------------

-   `Station` and `SampleNo` are present in the DOC data. I have used `SampleNo` to merge DOC with CDOM. Is it OK?

-   There are two DOC variables `DOC_um` and `doc`. After discussion with Colin, `DOC_um` has been used.

-   CDOM and DOC data has been merged using `river`, `t`, `year` as common variables.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Greenland lakes
---------------

-   I have DOC value for 2002 and 2003 but I have CDOM data that seems to be only for one year. From which year are CDOM data?
    -   I tried to merge CDOM with *both* DOC and either case the value of a375 reported in the DOC dataset fits with the *raw* absorption from the CDOM dataset.
-   Do you have the CDOM data for the *missing* year?

-   I am not sure which field I should use for the `sample_id`: `SS_CODES` or `STATION`. I am using `STATION` at the moment.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Horsens dataset
---------------

-   There are two types of filters used for CDOM (GFF and 0.2). I decided to use 0.2.

-   Some values for the filter type have `NA`. What it means?

-   Samples have been taken at different depths. Some have `NA`. Can I interpret it as depth = 0?

-   There is a field named `DOC_FLAG` which can have two values (0, 1). I removed those with values = 1.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

-   Missing geographic coordinates.

Kattegat
--------

-   CDOM was already provided as absorption coefficients. No conversion has been done.

-   Some CDOM profiles were duplicated. They have been deleted.

-   In `gt237doc.sas7bdat` there was two DOC entries for station 213. This station has been removed from data.

Umeaa
-----

-   There was DOC for `is` and `water`. `is` data has been discarded.

General questions/comments
--------------------------

-   Need to verify that all DOC measurements are using same units (i.e. umol/L).

-   Need to verify that all CDOM is expressed as absorption coefficients.

-   Missing geographic coordinates.

Methods
=======

-   CDOM values between 250-600 nm have been kept for further analyzes.

-   All CDOM profiles have been interpolated at 1 nm increment to make sure that the calculation of metrics will be performed on same spectral range for everyone.

-   We suspected problems with absorbance data from lter5653. We have assumed a pathlength of 0.1 m.

Cleaning process
----------------

These spectra have been automatically removed based on calculated metrics.

| study\_id        | removal\_reason          |    n|
|:-----------------|:-------------------------|----:|
| antarctic        | R2 smaller than 0.95     |    2|
| asmala2014       | Absorption at 440 &lt; 0 |    1|
| chen2000         | Absorption at 440 &lt; 0 |   29|
| chen2000         | R2 smaller than 0.95     |   28|
| chen2000         | SUVA254 greater than 6   |    1|
| dana12           | Absorption at 440 &lt; 0 |    8|
| greenland\_lakes | Absorption at 440 &lt; 0 |    5|
| horsens          | Absorption at 440 &lt; 0 |    3|
| horsens          | R2 smaller than 0.95     |    1|
| horsens          | SUVA254 greater than 6   |    2|
| kattegat         | Absorption at 440 &lt; 0 |   16|
| lter2004         | SUVA254 greater than 6   |    2|
| massicotte2011   | Absorption at 440 &lt; 0 |   13|
| nelson           | Absorption at 440 &lt; 0 |   22|
| nelson           | R2 smaller than 0.95     |    3|
| nelson           | S greater than 0.08      |    2|

Removed datasets
----------------

-   Shank 2011 (because we had the same DOC measurement for various aCDOM values).
