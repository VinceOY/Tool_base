new_dir <- "C:/Users/USER/Downloads/function_tool/"
setwd(new_dir)
source("tool_function/fetch_function.R")
library(testthat)

#===============================================================================
# fetch_data: unit_test

test_that("fetch_data() function test", {
  
  # create test data 
  dt <- data.table(
    CHR_NO = c("ID1", "ID2", "ID3"),
    OPD_DATE = c("2024-01-01", "2024-01-02", "2024-01-03"),
    ICD9_CODE1 = c("5434.01", "434.01", "434.02"),
    ICD9_CODE2 = c("585", "586", "587")
  )
  
  # define target_ID_cols, disease_ID_cols, disease_codes
  target_ID_cols <- c("CHR_NO", "OPD_DATE")
  disease_ID_cols <- c("ICD9_CODE1", "ICD9_CODE2")
  disease_codes <- c("434.01", "585")
  
  # test fetch_data() 
  filtered_data <- fetch_data(dt, target_ID_cols, disease_ID_cols, 
                              disease_codes)
  
  answer <- data.table(
    CHR_NO = c("ID2", "ID1"),
    OPD_DATE = c("2024-01-02", "2024-01-01")
  )
  
  # compare result
  expect_equal(filtered_data, answer)
  
})

#===============================================================================
# get_valid_data: unit_test
# test_item: 
# 1.duplicate date，2.diff group id col，3.different k = 2,3

test_that("get_valid_data() function test", {
  
  # example1
  dt <- data.table(
    ID_TEST = c("ID1", "ID2", "ID2", "ID1", "ID2", "ID1"),
    IPD_DATE = as.Date(c("2016-01-01", "2016-02-02", "2016-03-03", "2016-04-04",
                         "2016-05-05", "2016-04-04")))
  k <- 2
  group_id_col<- "ID_TEST"
  date_col <- "IPD_DATE"
  valid_data <- get_valid_data(dt, group_id_col, date_col, k)
  
  # create answer
  answer <- data.table(
    ID = c("ID1", "ID2", "ID2"),
    DATE = as.Date(c("2016-01-01", "2016-02-02", "2016-03-03"))
    )
  
  # test same result 
  expect_equal(valid_data, answer)
  
  # example2
  dt2 <- data.table(
    CHR_NO = c("ID1", "ID1", "ID1", "ID1", "ID2", "ID1"),
    OPD_DATE = as.Date(c("2016-01-01", "2016-02-02", "2016-03-03", "2016-04-04", 
                         "2016-05-05","2013-04-04")))
  k2 <- 3
  valid_data2 <- get_valid_data(dt2, "CHR_NO", "OPD_DATE", k2)
  
  # create answer
  answer2 <- data.table(
    ID = c("ID1", "ID1"),
    DATE = as.Date(c("2016-01-01", "2016-02-02")))
  
  # test same result 
  expect_equal(valid_data2, answer2)
  
})

#===============================================================================
# find_earliest_date: unit_test

test_that("Find_earliest_date() function test", {
  # create data and answer
  dt_c <- data.table(ID = c(1, 1, 2, 2), 
                     OPD_DATE = as.Date(c("2024-01-01", "2024-02-01", 
                                          "2024-01-15", "2024-02-15")))
  dt_hos <- data.table(CHR_NO = c(2, 3, 4), 
                       IPD_DATE = as.Date(c("2024-03-01", "2024-04-01", 
                                            "2024-03-15")))
  expected_result <- data.table(ID = c(1, 2, 3, 4), 
                                Date = as.Date(c("2024-01-01", "2024-01-15", 
                                                 "2024-04-01", "2024-03-15")))
  # set parameters
  P_list <- list(
    list(df = dt_c, idcol = "ID", datecol = "OPD_DATE", k = 2),
    list(df = dt_hos, idcol = "CHR_NO", datecol = "IPD_DATE", k = 1)
  )
  
  # function result 
  actual_result <- find_earliest_date(P_list)
  
  # test
  expect_equivalent(actual_result, expected_result)
})
