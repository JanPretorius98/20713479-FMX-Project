# Function to plot the series as is
plot_cpi_series <- function(plot_df, selected_component) {
    plot_df <- plot_df %>%
        mutate(Highlight = ifelse(CPI_COMPONENT == selected_component, "yes", "no"))

    # Ensure that the filter is applied to the same data frame as mutate
    highlight_df <- filter(plot_df, Highlight == "yes")

    p <- ggplot(plot_df, aes(x = Date, y = OBS_VALUE, group = CPI_COMPONENT)) +
        geom_line(aes(color = Highlight, size = Highlight), show.legend = FALSE) +
        geom_path(data = highlight_df, color = "red", size = 1) +
        scale_color_manual(values = c("no" = "grey", "yes" = "red")) +
        scale_size_manual(values = c("no" = 0.5, "yes" = 1)) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(y = "Index Value")

    return(p)
}


# Function to plot the forecast
plot_cpi_forecast <- function(arima_model, garch_model, n.ahead, selected_component) {
    cpi_forecast <- forecast(arima_model[[selected_component]], h = n.ahead)
    garch_forecast <- ugarchforecast(garch_model[[selected_component]], n.ahead = n.ahead)

    # Combine the mean forecast from ARIMA and the volatility forecast from GARCH
    combined_forecast <- data.frame(
        Date = time(cpi_forecast$mean),
        CPI_Forecast = as.numeric(cpi_forecast$mean),
        Volatility = as.numeric(sigma(garch_forecast))
    )

    # Calculate confidence intervals
    alpha <- 0.05  # 95% confidence interval
    upper_bound <- combined_forecast$CPI_Forecast + qnorm(1 - alpha/2) * combined_forecast$Volatility
    lower_bound <- combined_forecast$CPI_Forecast - qnorm(1 - alpha/2) * combined_forecast$Volatility

    combined_forecast$Upper_CI <- upper_bound
    combined_forecast$Lower_CI <- lower_bound

    p <- ggplot(combined_forecast, aes(x = Date)) +
        geom_line(aes(y = CPI_Forecast), color = "red") +
        geom_ribbon(aes(ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2) +
        labs(title = "CPI Forecast with 95% Confidence Intervals",
             x = "Date",
             y = "CPI") +
        theme_bw()

    return(p)
}
