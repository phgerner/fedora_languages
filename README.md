# Study of Fedora languages

## Data preparation

Language: R

Required interpreter: R

Required packages: tidyverse, jsonlite, logger

Input data: in folder data_raw/2023-11-23/. The content of the folder is the uncompressed version of the data given in: https://mamot.fr/@jibec/111458520189397976

Run: run script fedora_language_preparation.R. Run duration: 3 to 4 minutes. A log line is given for each language.

Output: a single big dataframe, in folder data_prepared: data_prepared/versions.feather. If you're using Python/pandas for reading this dataframe, you'll need the "arrow" library. 

