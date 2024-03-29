library(tidyverse)
library(logger)

# Function for reading a single lang-file:
get_df_for_a_lang_file <- function(lang_file_path) {
  
  parsed_content <- jsonlite::fromJSON(lang_file_path)
  
  for_return <- parsed_content$po
  
  return(for_return)
}

# test_df <- get_df_for_a_lang_file('data_raw/2023-11-23/f16/languages/fr.json')


# Function for reading a single Fedora version and returning a single dataframe:
# TODO: more path info as argument
get_df_for_fedora_version <- function(fedora_version) {
  
  log_info("preparing data for Fedora version {fedora_version}")
  
  path_for_languages_in_version <- paste0('data_raw/2023-11-23/',
                                          fedora_version,
                                          '/languages/')
  
  files_in_version <- list.files(path_for_languages_in_version,
                                 full.names = FALSE)
  
  paths_for_files_in_version <-
    list.files(path_for_languages_in_version,
               full.names = TRUE)
  
  version_listing <-
    tibble(lang_file_path = paths_for_files_in_version,
           lang_file      = files_in_version)
  
  version_listing <- version_listing |>
    mutate(file_df = map(lang_file_path,
                         possibly(get_df_for_a_lang_file,
                                  otherwise = NULL,
                                  quiet = FALSE),
                         .progress = TRUE))
  
  files_with_error <- version_listing |>
    filter(is.null(file_df))
  
  if (nrow(files_with_error) > 0) {
    log_info("some files have problems:")
    print(files_with_error)
  }
  
  files_without_error <- version_listing |>
    filter(!is.null(file_df))
  
  df_list_for_version        <- files_without_error$file_df
  names(df_list_for_version) <- files_without_error$lang_file

  version_df <- bind_rows(df_list_for_version,
                          .id = "json_file")
  
  return(version_df)
}

# test_version_df <- get_df_for_fedora_version('f16')

# Reading all versions and building a single dataframe:
fedora_versions <- list.files('data_raw/2023-11-23/')

fedora_version_building_df <- tibble(version = fedora_versions)

# ordering by version number:
fedora_version_building_df <- fedora_version_building_df |>
  mutate(version_num = as.numeric(str_remove(version, 'f'))) |>
  arrange(version_num)

fedora_version_building_df <- fedora_version_building_df |>
  mutate(version_df = map(
    version,
    possibly(
      get_df_for_fedora_version,
      otherwise = NULL,
      quiet = FALSE
    ),
    .progress = TRUE
  ))

versions_with_error <- fedora_version_building_df |>
  filter(is.null(version_df))

if (nrow(versions_with_error) > 0) {
  log_info("some versions have problems:")
  print(versions_with_error)
}

versions_without_error <- fedora_version_building_df |>
  filter(!is.null(version_df))

df_list_for_versions        <- versions_without_error$version_df
names(df_list_for_versions) <- versions_without_error$version

versions_df <- bind_rows(df_list_for_versions,
                         .id = "version")

arrow::write_feather(versions_df,
                     'data_prepared/versions.feather')

