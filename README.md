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

-   <http://pubs.usgs.gov/of/2007/1390/section4.html>
-   <http://sofia.usgs.gov/exchange/aiken/aikenchem.html>
-   <http://pubs.usgs.gov/sir/2007/5240/#table4>

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

Graphics
========

All graphics will be automatically updated in the `graphs` folder on Dropbox.

Datasets overview
=================

Data with complete CDOM absorption profils
------------------------------------------

| study\_id      |     n|
|:---------------|-----:|
| agro           |   168|
| antarctic      |    56|
| arctic         |    83|
| asmala2014     |   141|
| chen2000       |   161|
| dana12         |   200|
| horsens        |   577|
| kattegat       |   509|
| massicotte2011 |    69|
| nelson         |  2344|
| osburn2007     |    37|
| umeaa          |    15|

    ## [1] 4360

Data from the literature
------------------------

| study\_id                  |     n|
|:---------------------------|-----:|
| agro\_partners             |    82|
| amon2012                   |   193|
| bouillon2014               |    30|
| castillo1999               |    26|
| cv1\_om\_pigments\_seabass |   452|
| cv2\_om\_pigments\_seabass |   488|
| cv3\_om\_pigments\_seabass |   280|
| cv4\_om\_pigments\_seabass |   644|
| cv5\_om\_pigments\_seabass |   448|
| cv6\_om\_seabass           |   752|
| everglades\_pw             |   603|
| everglades\_sw             |   263|
| ferrari2000                |   129|
| finish\_rivers             |  2823|
| forsstrom2015              |    38|
| geocape\_om\_pigments      |   484|
| helms2008                  |    66|
| hernes2008                 |    29|
| kellerman2015              |   113|
| kutser2005                 |    14|
| lonborg2010                |    11|
| mladenov2011               |   180|
| osburn2009                 |    27|
| osburn2016                 |   260|
| russian\_delta             |    76|
| table5d                    |    28|
| tanana                     |    85|
| tehrani2013                |    39|

    ## [1] 8663

Total number of observations:

    ## [1] 13023

Spatial coverage
================

Complete profils data with missing coordinates:

    ## Source: local data frame [5 x 1]
    ## 
    ##    study_id
    ##       (chr)
    ## 1 antarctic
    ## 2    arctic
    ## 3    dana12
    ## 4   horsens
    ## 5     umeaa

Literature data with missing coordinates:

    ## Source: local data frame [0 x 1]
    ## 
    ## Variables not shown: study_id (chr)

Ecotypes
========

Complete profils datasets
-------------------------

| study\_id      | ecotype    |     n|
|:---------------|:-----------|-----:|
| agro           | river      |   168|
| antarctic      | hyposaline |    56|
| arctic         | hyposaline |    83|
| asmala2014     | coastal    |   123|
| asmala2014     | river      |    18|
| chen2000       | coastal    |    24|
| chen2000       | ocean      |   136|
| chen2000       | river      |     1|
| dana12         | ocean      |   200|
| horsens        | coastal    |   404|
| horsens        | lake       |    60|
| horsens        | river      |    69|
| horsens        | sewage     |    32|
| horsens        | NA         |    12|
| kattegat       | coastal    |   284|
| kattegat       | ocean      |   225|
| massicotte2011 | river      |    69|
| nelson         | ocean      |  2344|
| osburn2007     | coastal    |    12|
| osburn2007     | ocean      |    24|
| osburn2007     | river      |     1|
| umeaa          | NA         |    15|

Literature datasets
-------------------

| study\_id                  | ecotype |     n|
|:---------------------------|:--------|-----:|
| agro\_partners             | river   |    82|
| amon2012                   | ocean   |   193|
| bouillon2014               | river   |    30|
| castillo1999               | coastal |     4|
| castillo1999               | ocean   |    22|
| cv1\_om\_pigments\_seabass | ocean   |   452|
| cv2\_om\_pigments\_seabass | ocean   |   488|
| cv3\_om\_pigments\_seabass | ocean   |   280|
| cv4\_om\_pigments\_seabass | ocean   |   644|
| cv5\_om\_pigments\_seabass | ocean   |   448|
| cv6\_om\_seabass           | ocean   |   752|
| everglades\_pw             | lake    |   603|
| everglades\_sw             | lake    |   263|
| ferrari2000                | ocean   |   129|
| finish\_rivers             | lake    |  2823|
| forsstrom2015              | lake    |    38|
| geocape\_om\_pigments      | ocean   |   484|
| helms2008                  | coastal |    66|
| hernes2008                 | river   |    29|
| kellerman2015              | lake    |   113|
| kutser2005                 | lake    |    14|
| lonborg2010                | ocean   |    11|
| mladenov2011               | lake    |   180|
| osburn2009                 | coastal |    10|
| osburn2009                 | ocean   |    13|
| osburn2009                 | river   |     4|
| osburn2016                 | coastal |   158|
| osburn2016                 | ocean   |    58|
| osburn2016                 | river   |    44|
| russian\_delta             | coastal |    64|
| russian\_delta             | ocean   |    12|
| table5d                    | lake    |    28|
| tanana                     | river   |    85|
| tehrani2013                | coastal |    17|
| tehrani2013                | ocean   |    22|

Questions for Colin
===================

Colin provided a huge dataset of CDOM and DOC observations. I did my best to pre-process these data. However, here are some pending questions.

Graphics of CDOM profils for each dataset can be found on the Dropbox folder under `/graphs/colin`.

Nelson ocean (incl. AOU) ~1000
------------------------------

-   CDOM profiles have been measured between 275 and 729 nm. Do you have data at shorter wavelengths? This would match other datasets and let us use important metrics such as SUVA254.

-   I originally had ~ 9000 CDOM profiles. After removing observations with no DOC values we have n = 2359. Is it normal to have "only" 2359 measurements of DOC?

-   Presence of some "weird" CDOM profile. I modeled them using the simple exponential model and discarded those with R2 &lt; 0.9. Two profiles were removed.

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

-   Some stations are missing geographical information.

Arctic rivers
-------------

-   `Station` and `SampleNo` are present in the DOC data. I have used `SampleNo` to merge DOC with CDOM. Is it OK?

-   There are two DOC variables `DOC_um` and `doc`. If I scatterplot them I do not have a perfect fit. So, which one to use?

-   CDOM and DOC data has been merged using `river`, `t`, `year` as common variables.

-   DOC values seems to be in mg, I converted them to umol. Please confirm.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

-   Missing geographic coordinates.

Greenland lakes
---------------

-   I have DOC value for 2002 and 2003 but I have CDOM data that seems to be only for one year. From which year are CDOM data?
    -   I tried to merge CDOM with *both* DOC and either case the value of a375 reported in the DOC dataset fits with the *raw* absorption from the CDOM dataset.
-   Do you have the CDOM data for the *missing* year?

-   I am not sure which field I should use for the `sample_id`: `SS_CODES` or `STATION`. I am using `STATION` at the moment.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Horsens dataset
---------------

-   There are two types of filters used for CDOM (GFF and 0.2). Which one should we use? I decided to use 0.2.

-   Some values for the filter type have `NA`. What it means?

-   Samples have been taken at different depths. Some have `NA`. Can I interpret it as depth = 0?

-   There is a field named `DOC_FLAG` which can have two values (0, 1). Is it related to the quality of DOC measurements?

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

Literature data
===============

Amon 2012
---------

-   After cleaning data, there are 193 CDOM measurements for 49 distinct DOC values. Have to dig that.

Methods
=======

-   CDOM values between 250-600 nm have been kept for further analyzes.

-   All CDOM profiles have been interpolated at 1 nm increment to make sure that the calculation of metrics will be performed on same spectral range for everyone.

Cleaning process
----------------

These spectra have been automatically removed based on calculated metrics.

| study\_id | removal\_reason        |    n|
|:----------|:-----------------------|----:|
| antarctic | R2 smaller than 0.95   |    2|
| chen2000  | R2 smaller than 0.95   |   19|
| chen2000  | SUVA254 greater than 6 |    1|
| horsens   | R2 smaller than 0.95   |    1|
| horsens   | SUVA254 greater than 6 |    2|
| nelson    | R2 smaller than 0.95   |    3|
| nelson    | S greater than 0.08    |    1|
