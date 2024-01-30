get_ts_data <- function() {
    # Import data
    # Read the Excel file
    cpi_dat <- read_excel('/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/data/CPI.xlsx')

    # Set the first column as the row index
    row_names <- cpi_dat[[1]] # Save the first column as row names
    cpi_dat <- cpi_dat[-1] # Remove the first column from the dataframe

    # Create a list where each element is a data frame with one column of OBS_VALUE
    # and the dates as row names
    column_dataframes <- lapply(names(cpi_dat), function(col_name) {
        df <- data.frame(OBS_VALUE = cpi_dat[[col_name]], row.names = row_names)
        return(df)
    })

    # Give the list elements names based on the column names
    names(column_dataframes) <- names(cpi_dat)
    cpi_dat <- column_dataframes

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
    # Read the Excel file
    cpi_dat <- read_excel('/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/data/CPI.xlsx')

    # Set the first column as the row index
    row_names <- cpi_dat[[1]]
    cpi_dat <- cpi_dat[-1]

    # Create a list where each element is a data frame with one column of OBS_VALUE
    # and the dates as row names
    column_dataframes <- lapply(names(cpi_dat), function(col_name) {
        df <- data.frame(OBS_VALUE = cpi_dat[[col_name]], row.names = row_names)
        return(df)
    })

    # Give the list elements names based on the column names
    names(column_dataframes) <- names(cpi_dat)
    cpi_dat <- column_dataframes

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

