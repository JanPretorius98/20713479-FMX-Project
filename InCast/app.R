

pacman::p_load(tidyverse,
               dplyr,
               ggplot2,
               devtools,
               econdatar,
               forecast,
               tseries,
               rugarch,
               shiny,
               readxl,
               zoo,
               gridExtra)


source("/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/functions/transform.R")
source("/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/functions/arima.R")
source("/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/functions/garch.R")
source("/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/functions/plot.R")
source("/Users/janhendrikpretorius/Library/CloudStorage/OneDrive-StellenboschUniversity/01-Masters-2023/02 Financial Econometrics/20713479-FMX-Project/InCast/functions/aesthetics.R")



# Define UI for CPI forecasting app
ui <- fluidPage(
    # App title
    titlePanel("InCast Forecasting Dashboard"),

    # Sidebar layout with input and output definitions
    sidebarLayout(
        # Sidebar panel for inputs
        sidebarPanel(
            # Input: Select a CPI component
            selectInput("cpi_component",
                        "Choose a CPI Component:",
                        choices = c("CPI - All items" = "00.0.0.0.TC",
                                    "CPI - Food and non alcoholic beverages" = "01.0.0.0.TC",
                                    "CPI - Alcoholic beverages and tobacco" = "02.0.0.0.TC",
                                    "CPI - Clothing and footwear" = "03.0.0.0.TC",
                                    "CPI - Housing, water, electricity, gas and other fuels" = "04.0.0.0.TC",
                                    "CPI - Furnishings, household equipment and routine household maintenance" = "05.0.0.0.TC",
                                    "CPI - Health" = "06.0.0.0.TC",
                                    "CPI - Transport" = "07.0.0.0.TC",
                                    "CPI - Communication" = "08.0.0.0.TC",
                                    "CPI - Recreation and culture" = "09.0.0.0.TC",
                                    "CPI - Education" = "10.0.0.0.TC",
                                    "CPI - Restaurants and hotels" = "11.0.0.0.TC",
                                    "CPI - Miscellaneous goods and services" = "12.0.0.0.TC")),

            # Input: Numeric input for number of periods to forecast
            numericInput("n_periods",
                         "Select Number of Periods to Forecast:",
                         value = 12),  # Default to 12 periods

            # Input: Choose action - Plot Series or Forecast
            radioButtons("plot_action", "Choose Action:", choices = list("Plot Series" = "plot",
                                                                         "Forecast CPI" = "forecast"))
        ),

        # Main panel for displaying outputs
        mainPanel(
            # Output: Plot of the forecast
            plotOutput("forecastPlot")
        )
    )
)


server <- function(input, output) {
    # Load the data
    cpi_dat <- get_ts_data()  # Ensure this function returns the 'cpi_dat' list

    output$forecastPlot <- renderPlot({
        # Determine action based on radio button selection
        if (input$plot_action == "plot") {
            # Plot the original series
            plot_df <- get_plot_df()
            plot_cpi_series(plot_df, input$cpi_component)

        } else if (input$plot_action == "forecast") {
            # Call the function to plot the forecast
            cpi_arima <- model_arima(cpi_dat)
            cpi_arima_residuals <- get_residuals(cpi_arima)
            cpi_garch <- model_garch(cpi_arima_residuals)

            # Get the plots from the function
            plots <- plot_cpi_forecast(cpi_arima, cpi_garch, input$n_periods, input$cpi_component)

            # Use grid.arrange to display both plots side by side
            grid.arrange(plots$forecast_plot, plots$cumulative_plot, ncol = 2)
        }
    })
}



# Run the application
shinyApp(ui = ui, server = server)
