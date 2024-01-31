# Function to plot the series as is
plot_cpi_series <- function(plot_df, selected_component) {
    plot_df <- plot_df %>%
        mutate(Highlight = ifelse(CPI_COMPONENT == selected_component, "yes", "no")) %>%
        # Apply the second mutation conditionally
        { if (selected_component != "00.0.0.0.TC") mutate(., Highlight = ifelse(CPI_COMPONENT == "00.0.0.0.TC", "total", Highlight)) else . }

    # Now that we have a single data frame with all transformations applied, filter it
    highlight_df <- filter(plot_df, Highlight == "yes")

    # Create the plot
    p <- ggplot(plot_df, aes(x = Date, y = OBS_VALUE, group = CPI_COMPONENT)) +
        geom_line(aes(color = Highlight, size = Highlight), show.legend = FALSE) +
        geom_path(data = highlight_df, color = "#C93D44", size = 1) +
        scale_color_manual(values = c("no" = "grey", "yes" = "#C93D44", "total" = "#1E3364")) +
        scale_size_manual(values = c("no" = 0.3, "yes" = 1, "total" = 1)) +
        th +
        theme(legend.position = "none") +
        labs(y = "Index Value",
             x = "",
             caption = "Selected CPI component in red. CPI (all items) in blue if not selected.",
             title = "CPI for Selected Series over Time")

    return(p)
}


# Function to plot the forecast

plot_cpi_forecast <- function(arima_model, garch_model, n.ahead, selected_component) {
    cpi_forecast <- forecast(arima_model[[selected_component]], h = n.ahead)
    garch_forecast <- ugarchforecast(garch_model[[selected_component]], n.ahead = n.ahead)

    # Get the last date from the time series data used in the ARIMA model
    end_date <- as.Date(tail(time(arima_model[[selected_component]]$x), 1))

    # Create a sequence of dates for the forecast period starting from the day after the end_date
    forecast_dates <- seq.Date(from = end_date + 1, by = "month", length.out = n.ahead)

    combined_forecast <- data.frame(
        Date = forecast_dates,
        CPI_Forecast = as.numeric(cpi_forecast$mean),
        Volatility = as.numeric(sigma(garch_forecast))
    )

    # Calculate confidence intervals
    alpha <- 0.05  # 95% confidence interval
    upper_bound <- combined_forecast$CPI_Forecast + qnorm(1 - alpha/2) * combined_forecast$Volatility
    lower_bound <- combined_forecast$CPI_Forecast - qnorm(1 - alpha/2) * combined_forecast$Volatility

    combined_forecast$Upper_CI <- upper_bound
    combined_forecast$Lower_CI <- lower_bound

    # Calculate cumulative CPI Forecast
    combined_forecast$Cumulative_CPI_Forecast <- cumsum(combined_forecast$CPI_Forecast)

    combined_forecast$Date <- as.Date(combined_forecast$Date, format="%b %Y")

    # Plot the forecast with confidence intervals
    p <- ggplot(combined_forecast, aes(x = Date)) +
        geom_line(aes(y = CPI_Forecast), color = "#C93D44") +
        geom_ribbon(aes(ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2) +
        labs(title = "CPI Forecast with 95% Confidence Intervals",
             x = "",
             y = "Change in CPI") +
        th

    # Plot the cumulative change in CPI
    p_cumulative <- ggplot(combined_forecast, aes(x = Date, y = Cumulative_CPI_Forecast)) +
        geom_line(color = "#1E3364") +
        labs(title = "Cumulative Change in CPI Forecast",
             x = "",
             y = "Cumulative Change in CPI") +
        th

    # Return both plots
    list(forecast_plot = p, cumulative_plot = p_cumulative)
}


plot_forecast_actual <- function(test_df) {

    # Truncate the last 24 periods from each series in the list
    test_df <- lapply(test_df, function(ts) {
        window(ts, end = c(2021, 18))  # Truncate to keep data up to December 2021
    })

    # Apply models
    test_arima <- model_arima(test_df)
    test_residuals <- get_residuals(test_arima)
    test_garch <- model_garch(test_residuals)

    n.ahead <- 18

    # Forecast future values using the ARIMA and GARCH model
    cpi_forecast <- forecast(test_arima[["00.0.0.0.TC"]], h = n.ahead)
    garch_forecast <- ugarchforecast(test_garch[["00.0.0.0.TC"]], n.ahead = n.ahead)

    # Get the last date from the time series data used in the ARIMA model
    end_date <- as.Date(tail(time(test_arima[["00.0.0.0.TC"]]$x), 1))

    # Create a sequence of dates for the forecast period starting from the day after the end_date
    forecast_dates <- seq.Date(from = end_date, by = "month", length.out = n.ahead)

    # Combine the mean forecast from ARIMA and the volatility forecast from GARCH
    combined_forecast <- data.frame(
        Date = forecast_dates,
        CPI_Forecast = as.numeric(cpi_forecast$mean)
    )

    plot_df <- get_plot_df() %>%
        filter(CPI_COMPONENT == "00.0.0.0.TC")

    # Convert Date columns to Date class to ensure matching works correctly
    plot_df$Date <- as.Date(plot_df$Date)
    combined_forecast$Date <- as.Date(combined_forecast$Date)

    # Perform the left join
    result_df <- left_join(plot_df, combined_forecast, by = "Date") %>%
        select(-c(CPI_COMPONENT)) %>%
        filter(!is.na(CPI_Forecast))  %>%
        arrange(Date) %>%
        mutate(OBS_VALUE = OBS_VALUE - lag(OBS_VALUE, default = first(OBS_VALUE))) %>%
        # Calculate cumulative sums and add 100 to each observation
        mutate(Actual = cumsum(OBS_VALUE) + 100,
               Forecast = cumsum(CPI_Forecast) + 100) %>%
        select(-c(OBS_VALUE, CPI_Forecast)) %>%
        pivot_longer(cols = c(Actual, Forecast),
                     names_to = "Series",
                     values_to = "Value")

   p <-  result_df %>%
        ggplot(aes(x = Date, y = Value, color = Series)) +
        geom_line() +  # Plot lines
        labs(title = "Actual vs. Forecasted CPI for all items",
             x = "",
             y = "CPI",
             color = "Series") +
        th +
        scale_color_manual(values = c("Actual" = "#1E3364", "Forecast" = "#C93D44"))

   return(p)
}
