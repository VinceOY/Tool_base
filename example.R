new_dir <- "C:/Users/USER/Downloads/function_tool/"
setwd(new_dir)
source("tool_function/fetch_function.R")
source("tool_function/standard_function.R")

#===============================================================================
# define parameters list
parameters <- list(
  # files
  folder_path = "C:/Users/USER/Downloads/hospital/TMUCRD_2021_csv_new/",
  disease_codes = list("E08","E09","E10","E11","E12"),
  # data sets parameters
  data_sets = list(
    list(
      # dt1 parameters
      file_list = list("v_opd_basic_w.csv","v_opd_basic_t.csv",
                       "v_opd_basic_s.csv"),
      target_ID_cols = list("CHR_NO", "OPD_DATE"),
      disease_ID_cols = list("ICD9_CODE1", "ICD9_CODE2", "ICD9_CODE3", 
                             "ICD10_CODE1", "ICD10_CODE2", "ICD10_CODE3", 
                             "ICD10_CODE4", "ICD10_CODE5", "OPER10_CODE1", 
                             "OPER10_CODE2", "OPER10_CODE3"),
      date_col = "OPD_DATE",
      df_name = "dt_c",
      group_id = "CHR_NO",
      k = 3
    ),
    list(
      # dt2 parameters
      file_list = list("v_ipd_basic_w.csv","v_ipd_basic_t.csv",
                       "v_ipd_basic_s.csv"),
      target_ID_cols = list("CHR_NO", "IPD_DATE"),
      disease_ID_cols = list("OP_CODE1", "OP_CODE2", "OP_CODE3", "OP_CODE4",
                             "OP_CODE5", "OPER10_CODE1", "OPER10_CODE2", 
                             "OPER10_CODE3", "OPER10_CODE4", "OPER10_CODE5", 
                             "EDIAG_CODE", "ESDIAG_CODE1", "ESDIAG_CODE2", 
                             "ESDIAG_CODE3", "ESDIAG_CODE4", "EDIAG_DESC",
                             "ICD10_CODE1", "ICD10_CODE2", "ICD10_CODE3", 
                             "ICD10_CODE4", "ICD10_CODE5", "ICD10_CODE6", 
                             "ICD10_CODE7"),
      date_col = "IPD_DATE",
      df_name = "dt_hos",
      group_id = "CHR_NO",
      k = 1
    )
  )
)


#===============================================================================
# preprocess flow
P_list = list()
folder_path <- unlist(parameters$folder_path) 
disease_codes <- unlist(parameters$disease_codes) 

for (data_set in parameters$data_sets) {
  dt_file_list <- unlist(data_set$file_list) 
  dt_target_ID_cols <- unlist(data_set$target_ID_cols)
  dt_disease_ID_cols <- unlist(data_set$disease_ID_cols)
  dt_date_col <- unlist(data_set$date_col)
  dt_df_name <- unlist(data_set$df_name)
  dt_group_id <- unlist(data_set$group_id)
  dt_valid_times <- unlist(data_set$k)
  dt_name <- unlist(data_set$df_name)
  
  # step1: fetch data
  assign(dt_name, data.table())
  dt_name <- get(dt_name)
  for (file in dt_file_list) {
    d_tmp <- fread(paste0(folder_path, file))
    d_tmp <- fetch_data(d_tmp, dt_target_ID_cols, dt_disease_ID_cols, 
                        disease_codes)
    dt_name <- rbind(dt_name, d_tmp)
  }
  
  # step2: standard date
  dt_name <- standardized_date(dt_name, dt_date_col)
  P_list <- append(P_list, list(list(df = dt_name, idcol = dt_group_id, 
                                     datecol = dt_date_col, 
                                     k = dt_valid_times)))
}

# step3: combine and find earliest dateset
clean_dt <- find_earliest_date(P_list)
dim(clean_dt)
