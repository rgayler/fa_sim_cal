# These are all the functions used by the {targets} pipelines.
# They are *developed* in the meta notebooks
# and stored here to ensure that {targets} uses the same functions
# in the core pipeline and meta notebooks.
#
# Where the meta notebooks need to use these functions
# they are sourced into the notebook from here.
# This relies on the '## ---- some_function_name' section headers
# to identify the function to source into the notebook.
# See https://bookdown.org/yihui/rmarkdown-cookbook/read-chunk.html

# The functions are organised by the targets they are used by.

# TARGET c_clean_entity_data ##################################################

## ---- raw_entity_data_read

# Function to get the raw entity data
# Assumes the data is UTF-8 with embedded nulls deleted
# The returned value is encoded as UTF-8
raw_entity_data_read <- function(
  file_path # character - file path usable by vroom
  # value - data frame
) {
  vroom::vroom(
    file_path,
    # n_max = 1e4, # limit the rows for testing
    col_select = c( # get all the columns that might conceivably be used
      # the names and ordering are from the metadata file
      snapshot_dt : voter_status_reason_desc, # 9 cols
      last_name : street_sufx_cd, # 10 cols
      unit_num : zip_code, # 4 cols
      area_cd, phone_num, # 2 cols
      sex_code : registr_dt, # 5 cols
      cancellation_dt, load_dt # 2 cols
    ), # total 32 cols
    col_types = cols(
      .default = col_character() # all cols as chars to allow for bad formatting
    ),
    delim = "\t", # assume that fields are *only* delimited by tabs
    col_names = TRUE, # use the column names on the first line of data
    trim_ws = TRUE, # trim leading and trailing whitespace
    na = "", # missing fields are empty string or whitespace only (see trim_ws argument)
    quote = "", # strings NEVER quoted. Read embedded double quote as just another character
    comment = "", # don't allow comments
    escape_double = FALSE, # assume no escaped quotes
    escape_backslash = FALSE # assume no escaped backslashes
  )
}

## ---- raw_entity_data_excl_status

# Function to exclude records based on voter status
raw_entity_data_excl_status <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::filter(
      voter_status_desc == "ACTIVE" & voter_status_reason_desc == "VERIFIED"
    )
}

## ---- raw_entity_data_excl_test

# Function to exclude test records based on names
raw_entity_data_excl_test <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::filter(
      ! (
        stringr::str_detect(last_name, regex("\\bTEST\\b", ignore_case = TRUE)) &
          stringr::str_detect(first_name, regex("\\bTHIS\\b", ignore_case = TRUE))
      )
    )
}

## ---- raw_entity_data_drop_novar

# Function to drop variables with no variation
raw_entity_data_drop_novar <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::select(
      -c(snapshot_dt, load_dt,
         status_cd, voter_status_desc, reason_cd, voter_status_reason_desc)
    )
}

## ---- raw_entity_data_parse_dates

# Function to parse the date strings in the raw entity data
raw_entity_data_parse_dates <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate( # convert the datetime cols to dates
      registr_dt      = lubridate::as_date(registr_dt),
      cancellation_dt = lubridate::as_date(cancellation_dt)
    )
}

## ---- raw_entity_data_exclude_dup_ncid

# Function to exclude duplicated NCID records
raw_entity_data_exclude_dup_ncid <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::group_by(ncid) %>%
    dplyr::arrange(registr_dt, voter_reg_num, .by_group = TRUE) %>%
    dplyr::slice_head(n = 1) %>%
    dplyr::ungroup()
}

## ---- raw_entity_data_drop_admin

# Function to drop unneeded admin variables
raw_entity_data_drop_admin <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::select(-c(county_id, registr_dt, cancellation_dt))
}

## ---- raw_entity_data_drop_demog

# Function to drop unneeded admin variables
raw_entity_data_drop_demog <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::select(-sex_code)
}

## ---- raw_entity_data_add_id

# Function to add ID
# This is just transitional.
# Remove it after switching to 2008 snapshot with NCID
raw_entity_data_add_id <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(id = 1:nrow(.))
}

## ---- raw_entity_data_clean_age

# Function to clean age
raw_entity_data_clean_age <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      age_cln = as.integer(age),
      age_cln_miss = ! dplyr::between(age_cln, 17, 104), # valid age range
      age_cln = dplyr::if_else(age_cln_miss, 0L, age_cln)
    )
}

## ---- raw_entity_data_clean_preprocess_char

# Helper function to preprocess one char variable
raw_entity_data_clean_preprocess_char_1 <- function(x) {
  x %>%
    tidyr::replace_na("") %>% # map NA to ""
    stringr::str_to_upper() # map lower case to upper case
}

# Function to preprocess all char variables
raw_entity_data_clean_preprocess_char <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      across(where(is.character), raw_entity_data_clean_preprocess_char_1) # apply to all char vars
    )
}

## ---- raw_entity_data_clean_all_names

# Helper function to fix zeroes in all names
# Map zero to O if there are no other digits in the string
raw_entity_data_clean_all_names_fix_zero <- function(x) { # x: vector of strings
  dplyr::if_else(
    stringr::str_detect( x, "0") & # if string contains zero AND
      stringr::str_detect( x, "[1-9]", negate = TRUE), # string contains no other digits
    stringr::str_replace_all( x, "0", "O"), # then map zero to O
    x # else return x
  )
}

# Helper function to apply all-name cleaning to one name
# Apply all-name cleaning
raw_entity_data_clean_all_names_1 <- function(x) { # x: vector of strings
  x %>%
    stringr::str_replace_all("[^ A-Z0-9]", " ") %>% # map non-alphanumeric to " "
    stringr::str_replace_all( # fix generation suffixes
      c("\\b11\\b"   = "II",
        "\\b111\\b"  = "III",
        "\\b1111\\b" = "IIII")
    ) %>%
    raw_entity_data_clean_all_names_fix_zero() %>%
    stringr::str_remove_all("[0-9]") %>% # map remaining digits to ""
    stringr::str_squish() # remove excess whitespace
}

# Function to apply all-name cleaning to all names
raw_entity_data_clean_all_names <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      across(
        .cols = c(last_name, first_name, midl_name), # apply to all name vars
        .fns = raw_entity_data_clean_all_names_1,
        .names = "{.col}_cln")
    )
}

## ---- raw_entity_data_clean_last_name

# Helper function to remove words (w) from vector of strings (x)
raw_entity_data_clean_all_names_remove_words <- function(x, w) { # x, w: vectors of char (w = words to remove)
  x %>%
    stringr::str_remove_all(
      pattern =  paste0("\\b", w, "\\b", collapse = "|") #convert word list to regexp
    ) %>%
    stringr::str_squish() # remove excess whitespace
}

# Function to apply last-name cleaning
raw_entity_data_clean_last_name <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      last_name_cln = last_name_cln %>% # remove special words
        raw_entity_data_clean_all_names_remove_words(
          c("DR", "II", "III", "IIII", "IV", "JR", "MD", "SR")
        ),

      last_name_cln = dplyr::if_else( # remove very short names
        stringr::str_length(last_name_cln) > 1,
        last_name_cln,
        ""
      )
    )
}

## ---- raw_entity_data_clean_middle_name

# Function to apply middle-name cleaning
raw_entity_data_clean_middle_name <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      midl_name_cln = midl_name_cln %>% # remove special words
        raw_entity_data_clean_all_names_remove_words(
          c("AKA", "DR", "II", "III", "IV", "JR", "MD", "MISS",
            "MR", "MRS", "MS", "NMN", "NN", "REV", "SR")
        )
    )
}

## ---- raw_entity_data_clean_first_name

# Helper function
# If no first name, move first word of middle name to first name
raw_entity_data_clean_first_name_move_name <- function(d) { # d: data frame of entity data
  has_first_name <- d$first_name_cln != ""

  re_fword <- "^[A-Z]+\\b" # regular expression for first word

  midl <- d$midl_name_cln

  midl_head <- midl %>% # get first word
    stringr::str_extract(re_fword) %>%
    tidyr::replace_na("")

  midl_tail <- midl %>% # get remainder of words
    stringr::str_remove(re_fword) %>%
    stringr::str_squish()

  d %>%
    dplyr::mutate(
      first_name_cln = dplyr::if_else(has_first_name,
                                      first_name_cln,
                                      midl_head
      ),
      midl_name_cln = dplyr::if_else(has_first_name,
                                     midl_name_cln,
                                     midl_tail
      )
    )
}

# Function to apply first-name cleaning
raw_entity_data_clean_first_name <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      first_name_cln = first_name_cln %>% # remove special words
        raw_entity_data_clean_all_names_remove_words(
          c("DR", "FATHER", "III", "IV", "JR", "MD", "MISS",
            "MR", "MRS", "NMN", "REV", "SISTER", "SR")
        )
    ) %>%
    raw_entity_data_clean_first_name_move_name()
}

## ---- raw_entity_data_clean_postprocess_names

# Function to postprocess all cleaned name variables
raw_entity_data_clean_postprocess_names <- function(
  d # data frame - raw entity data
) {
  d %>%
    dplyr::mutate(
      # remove all spaces
      last_name_cln  = last_name_cln  %>% stringr::str_remove_all(" "),
      first_name_cln = first_name_cln %>% stringr::str_remove_all(" "),
      midl_name_cln  = midl_name_cln  %>% stringr::str_remove_all(" "),

      # add missing value indicators
      last_name_cln_miss  = last_name_cln  == "",
      first_name_cln_miss = first_name_cln == "",
      midl_name_cln_miss  = midl_name_cln  == ""
    )
}

## ---- raw_entity_data_clean_all

# Function to apply all the cleaning actions
raw_entity_data_clean_all <- function(
  d # data frame - raw entity data
) {
  d %>%
    raw_entity_data_clean_age() %>%
    raw_entity_data_clean_preprocess_char() %>%
    raw_entity_data_clean_all_names() %>%
    raw_entity_data_clean_last_name() %>%
    raw_entity_data_clean_middle_name() %>%
    raw_entity_data_clean_first_name() %>%
    raw_entity_data_clean_postprocess_names()
}


## ---- raw_entity_data_make_clean

# Function to make the cleaned raw entity data
# Reads the data, applies exclusions
# and neatens it to where it's ready to calculate modelling features
raw_entity_data_make_clean <- function(
  file_path # character - file path usable by vroom
  # value - data frame
) {
  raw_entity_data_read(file_path) %>%
    raw_entity_data_excl_status() %>%
    raw_entity_data_excl_test() %>%
    raw_entity_data_drop_novar() %>%
    raw_entity_data_parse_dates() %>%
    raw_entity_data_exclude_dup_ncid() %>%
    raw_entity_data_drop_admin() %>%
    raw_entity_data_drop_demog() %>%
    raw_entity_data_clean_all() %>%
    raw_entity_data_add_id()
}

## ---- END

# TARGET c_blocks ########################################

