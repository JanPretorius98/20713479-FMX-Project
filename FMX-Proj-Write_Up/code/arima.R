
model_arima <- function(cpi_ts_list) {

    # Function to test stationarity and difference if necessary
    prepare_series <- function(series) {
        if(adf.test(series, alternative = "stationary")$p.value > 0.05) {
            # Series is not stationary, apply differencing
            series <- diff(series, differences = 1)
        }
        return(series)
    }

    # Apply this function to each time series the list
    cpi_ts_list <- lapply(cpi_ts_list, prepare_series)

    # Fit ARIMA models
    arima_models <- lapply(cpi_ts_list, auto.arima)

    return(arima_models)
}


get_residuals <- function(arima_models) {
    # To see the summary of each model
    lapply(arima_models, summary)

    # Extract residuals
    residuals_ts_list <- lapply(arima_models, residuals)

    # Convert each time series of residuals to a data frame
    residuals_df_list <- lapply(residuals_ts_list, as.data.frame)

    return(residuals_ts_list)
}