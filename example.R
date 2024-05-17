new_dir <- "C:/Users/USER/Downloads/function_tool/"
setwd(new_dir)
source("tool_function/fetch_function.R")
source("tool_function/standard_function.R")

#===============================================================================
# define parameters list
parameters <- list(
  # files
  folder_path = "C:/Users/USER/Downloads/hospital/TMUCRD_2021_csv_new/",
  disease_codes = c("E08","E09","E10","E11","E12"),
  # data sets parameters
  data_sets = list(
    dt1 = list(
      # dt1 parameters
      file_list = c("v_opd_basic_w.csv","v_opd_basic_t.csv",
                    "v_opd_basic_s.csv"),
      disease_ID_cols = c("ICD9_CODE1", "ICD9_CODE2", "ICD9_CODE3", 
                          "ICD10_CODE1", "ICD10_CODE2", "ICD10_CODE3", 
                          "ICD10_CODE4", "ICD10_CODE5", "OPER10_CODE1", 
                          "OPER10_CODE2", "OPER10_CODE3"),
      id_col = "CHR_NO",
      date_col = "OPD_DATE",
      k = 3
    ),
    dt2 = list(
      # dt2 parameters
      file_list = c("v_ipd_basic_w.csv","v_ipd_basic_t.csv",
                    "v_ipd_basic_s.csv"),
      disease_ID_cols = c("OP_CODE1", "OP_CODE2", "OP_CODE3", "OP_CODE4",
                          "OP_CODE5", "OPER10_CODE1", "OPER10_CODE2", 
                          "OPER10_CODE3", "OPER10_CODE4", "OPER10_CODE5", 
                          "EDIAG_CODE", "ESDIAG_CODE1", "ESDIAG_CODE2", 
                          "ESDIAG_CODE3", "ESDIAG_CODE4", "EDIAG_DESC",
                          "ICD10_CODE1", "ICD10_CODE2", "ICD10_CODE3", 
                          "ICD10_CODE4", "ICD10_CODE5", "ICD10_CODE6", 
                          "ICD10_CODE7"),
      id_col = "CHR_NO",
      date_col = "IPD_DATE",
      k = 1
    )
  )
)


#===============================================================================
# preprocess flow
P_list = list()
folder_path <- parameters$folder_path
disease_codes <- parameters$disease_codes

for (data_set_name in names(parameters$data_sets)) {
  dt_name <- data_set_name
  data_set <- parameters$data_sets[[data_set_name]]
  dt_file_list <- data_set$file_list
  dt_id_col <- data_set$id_col
  dt_date_col <- data_set$date_col
  dt_target_ID_cols <- c(dt_id_col, dt_date_col)
  dt_disease_ID_cols <- data_set$disease_ID_cols
  dt_valid_times <- data_set$k
  
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

# step3: combine and find earliest data set
clean_dt <- find_earliest_date(P_list)
dim(clean_dt)
length(unique(clean_dt$ID))
