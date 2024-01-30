get_ts_data <- function() {
    # Import data
    cpi_dat <- read_econdata(
        id = "CPI_COICOP_5",
        version = "1.2.0",
        series_key = "TC.12+11+10_09+08+07+06+05+04+03+02+01+00.0.0.0",
        release = "Dec 2023 (2024-01-24)")

    # Convert to ts objects

    # Set time
    start_time <- c(2008, 1)  # Start time (year 2008, month 1)
    frequency <- 12           # Monthly data

    # Convert each component to a time series object
    cpi_ts_list <- lapply(cpi_dat, function(x) ts(x, start=start_time, frequency=frequency))

    return(cpi_ts_list)
}


get_plot_df <- function() {
    # Import data
    cpi_dat <- read_econdata(
        id = "CPI_COICOP_5",
        version = "1.2.0",
        series_key = "TC.12+11+10_09+08+07+06+05+04+03+02+01+00.0.0.0",
        release = "Dec 2023 (2024-01-24)")

    # Function to convert list to df for easy plotting
    combine_dataframes <- function(df_list) {

        if (length(df_list) < 1) {
            stop("The list of dataframes is empty.")
        }
        combined_df <- df_list[[1]]

        for (i in 1:length(df_list)) {
            current_df <- df_list[[i]]
            new_col_name <- names(df_list)[i]

            names(current_df) <- new_col_name

            combined_df <- cbind(combined_df, current_df)
        }

        if ("OBS_VALUE" %in% names(combined_df)) {
            combined_df <- combined_df %>% dplyr::select(-OBS_VALUE)
        }

        return(combined_df)
    }

    plot_df <- combine_dataframes(cpi_dat) %>%
        rownames_to_column() %>%
        rename(Date = rowname) %>%
        gather(key = "CPI_COMPONENT",
               value = "OBS_VALUE",
               -Date) %>%
        mutate(Date=as.Date(Date))

    return(plot_df)
}