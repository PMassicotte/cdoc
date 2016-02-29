Untitled
================

CDOC project
============

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

-   `doc`: Dissolved organic carbon (DOC) concentration.

-   `doc_unit`: DOC unit, either *µmol/l* or *mg/l*.

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

So far, this dataset looks like this:

| study\_id      |     n|
|:---------------|-----:|
| arctic         |    83|
| asmala2014     |   141|
| Chen           |   172|
| dana12         |   200|
| horsens        |   578|
| kattegat       |   509|
| massicotte2011 |    66|
| nelson         |  2346|
| Osburn         |    37|
| umeaa          |    15|

    ## [1] 4147

Data from the literature
------------------------

| study\_id      |    n|
|:---------------|----:|
| amon2012       |  193|
| castillo1999   |   26|
| everglades\_pw |  603|
| everglades\_sw |  263|
| ferrari2000    |  129|
| hernes2008     |   29|
| killerman2015  |  113|
| kutser2005     |   16|
| lønborg2010    |   11|
| osburn2009     |   27|
| osburn2010     |   16|
| osburn2011     |  123|
| table5d        |   28|
| tanana         |   56|
| tehrani2013    |   39|

    ## [1] 1672

Questions for Eero
==================

-   Problem with duplicated data for Osburn 2010.
-   Same for Osburn 2011.
-   Same for Osburn 2009

Questions for Colin
===================

Colin provided a huge dataset of CDOM and DOC observations. I did my best to pre-process these data. However, here are some pending questions.

Graphics of CDOM profils for each dataset can be found on the Dropbox folder under `/graphs/colin`.

Nelson ocean (incl. AOU) ~1000
------------------------------

-   CDOM profiles have been measured between 275 and 729 nm. Do you have data at shorter wavelengths? This would match other dataets and let us use important metrics such as SUVA254.

-   I originally had ~ 9000 CDOM profiles. After removing observations with no DOC values we have n = 2359. Is it normal to have "only" 2359 measurements of DOC?

-   Presence of some "weird" CDOM profile. I modeled them using the simple exponential moel and discarded those with R2 &lt;= 0.9. Two profiles were removed.

-   CDOM is presumed to be absorption coefficients (not absorbance).

Antarctic
---------

-   Only `Brines` DOC are available in the data. I am missing something?

-   In the file `Antarctic_abs.sas7bdat` there are two date fields `m_date` and `Date`. Which one to use?

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Dana12
------

-   CDOM were converted to absorption coefficients using a pathlength of 0.01m. Is that OK?

Arctic rivers
-------------

-   `Station` and `SampleNo` are present in the DOC data. I have used `SampleNo` to merge DOC with CDOM. Is it OK?

-   There are two DOC variables `DOC_um` and `doc`. If I scatterplot them I do not have a perfect fit. So, which one to use?

-   CDOM and DOC data has been merged using `river`, `t`, `year` as common variables.

-   DOC values seems to be in mg, I converted them to uml. Please confirm.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Greenland lakes
---------------

-   I have DOC value for 2002 and 2003 but I have CDOM data that seems to be only for one year. From which year are CDOM data?

-   Do you have the CDOM data for the *missing* year?

-   I am not sure which field I should use for the `sample_id`: `SS_CODES` or `STATION`. I am using `STATION` at the moment.

-   CDOM was already provided as absorption coefficients. No conversion has been done.

Horsens dataset
---------------

-   There are two types of filters used for CDOM (GFF and 0.2). Which one should we use? I decided to use 0.2.

-   Some values for the filter type have `NA`. What it means? I replaced `NA` depths with the value of 0.

-   Samples have been taken at different depths. Some have `NA`. Can I interpret it as depth = 0?

-   There is a field named `DOC_FLAG` which can have two values (0, 1). Is it related to the quality of DOC measurements?

-   CDOM was already provided as absorption coefficients. No conversion has been done.

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

Methods
=======

-   CDOM values between 250-600 nm have been kept for further analyzes.

-   All CDOM profiles have been interpolated at 1 nm increment to make sure that the calculation of metrics will be performed on same spectral range for everyone.
