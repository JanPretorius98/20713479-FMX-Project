# 20713479-FMX-Project

This project introduces InCast, an Automated Forecasting Dashboard designed to improve the accuracy of Consumer Price Index (CPI) forecasts in South Africa. Given the volatile nature of CPI data, traditional forecasting models often struggle to provide reliable predictions. InCast tackles this challenge by leveraging advanced statistical models, such as ARIMA and GARCH, to capture both underlying trends and volatility.

The integration of these models into InCast offers a comprehensive framework for better understanding CPI trends and their financial implications. With real-time data updates and automation features, InCast aims to enhance economic planning, policy-making, and financial analysis in South Africa, providing a valuable tool for decision-makers dealing with CPI volatility.

- **The write-up for the report is available [here](FMX-Proj-Write_UP/FMX-Proj-Write_Up.pdf)**
- **The main markdown file from which the report was compiled is available [here](FMX-Proj-Write_Up/FMX-Proj-Write_Up.Rmd)**

---

## Table of Contents

1. [Installation](#installation)
2. [Project Organisation](#project-organisation)
3. [Thought Process for Coding Scripts](#thought-process-for-coding-scripts)
4. [Code Functions](#code-functions)
5. [InCast Web Application](#incast-web-application)
6. [Documentation](#documentation)
7. [Authors](#authors)

---

## Installation

The following packages have been installed for use throughout the project:

- `tidyverse`

- `ggplot2`

- `dplyr`

- `devtools`

- `forecast`

- `tseries`

- `rugarch`

- `readxl`

- `zoo`

- `xtable`

- `xts`

- `econdatar`

  - This package is not available on CRAN, but can be downloaded as follows:

    ```R
    library(devtools)
    install_github("coderaanalytics/econdatar")
    library(econdatar)
    ```

All of these packages are loaded using the pacman package, which offers a more convenient way to load R packages, installing them if necessary. Ensure that pacman is installed on your machine by running the following code in R:

```r
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

```

---

## Project Organisation

This is the part of my readme that shows the repository organisation for my project. It shows the different folders, what is stored in them and some descriptions: The project repository is organised as follows: 

- [**FMX-Proj-Write_Up**](FMX-Proj-Write_Up)
  - [**code**](FMX-Proj-Write_Up/code)
    - [`aesthetics.R`](FMX-Proj-Write_Up/code/aesthetics.R) - Contains scripts for plot aesthetics
    - [`arima.R`](FMX-Proj-Write_Up/code/arima.R) - Contains functions for ARIMA modeling
    - [`garch.R`](FMX-Proj-Write_Up/code/garch.R) - Contains functions for GARCH modeling
    - [`plot.R`](FMX-Proj-Write_Up/code/plot.R) - Contains functions for plotting
    - [`transform`](FMX-Proj-Write_Up/code/transform.R) - Contains functions for transforming data
  - [**data**](FMX-Proj-Write_Up/data)
    - [`Codelists.xlsx`](FMX-Proj-Write_Up/data/Codelists.xlsx) - An Excel sheet that describes the variables and their identification codes
  - [**FMX-Proj-Write_Up_files**](FMX-Proj-Write_Up/FMX-Proj-Write_UP_files)
    - Contains all necessary files for the project write-up
  - [**Tex**](FMX-Proj-Write_Up/Tex)
    - Contains files necessary for the reference list and layout of the write-up
- [**InCast**](InCast)
  - [`app.R`](InCast/app.R) - The Shiny app scripts
  - [**data**](InCast/data)
    - Where the data for InCast is temporarily stored
  - [**functions**](InCast/functions)
    - All functions defined in **code** are stored here
- [**Literature**](Literature)
  - All literature used is stored in this folder
- [**License**](Licence)
  - Licensing information for the project – an MIT licence was used

---

## Thought Process for Coding Scripts

In this section, I want to clarify some of my thought processes.

- Use of list objects as opposed to dataframes:
  - I made extensive use of lists in the code.
  - This proved incredible flexible, due to the fact that mutliple data series could be analysed, without the need of creating unnecessary dataframes – this keeps the data self-contained and easily accessible.
- Use of EconData's automated processes:
  - The data used in the project is completely self-contained in the code.
  - No data storage is necessary.
  - The data is automatically updated – each time the code runs, it produces the most recent data
- Decision to build a Shiny App:
  - I initially wanted to look at each of the CPI components (there are 12 in total), but this meant a very long and extensive paper.
  - Instead I opted to create a web application that can show the efficacy of the models produced, while keeping the focus for the supplementing paper on the modelling process.
  - This also allows the reader to get a more personalised experience.
- Functional Coding Paradigm:
  - The decision to encapsulate specific tasks within functions allows for modularity and code reusability. This approach makes it easier to maintain and update the code in the future and helps keep it organized.
  - The project contains many recursive functions, allowing efficient use of code and allowing for consistent analysis of data.
- Leveraging Automated Testing:
  - Implementing unit tests and validation checks for critical functions and processes ensures that the code behaves as expected. This practice helps catch errors and inconsistencies early in the development process.
- Scalability:
  - Designing the code with scalability in mind allows it to handle larger datasets or more complex tasks in the future without major rewrites. This ensures that the code remains valuable as requirements evolve.

----

## Code Functions

- [`transform.R`](FMX-Proj-Write_Up/code/transform.R)
  - This script contains data cleaning functions in order to streamline the data processing.
  - It contains two functions:
    - `get_ts_data()`:
      - The `get_ts_data` function imports CPI (Consumer Price Index) data using the `read_econdata` function, specifying various parameters like the ID, version, series key, and release date. After importing the data, it converts it into time series objects for further analysis. The start time is set to January 2008, and the data is monthly with a frequency of 12. The function returns a list of time series objects, one for each component of the CPI data.
    - `get_plot_df()`:
      - The function first imports CPI (Consumer Price Index) data using the `read_econdata` function, similar to `get_ts_data()`. It then defines an inner function called `combine_dataframes` which takes a list of dataframes and combines them into a single dataframe. The function checks if the list is empty and initializes the combined dataframe with the first element of the list. It iterates through the list, renaming columns based on the dataframe names and then merging them horizontally using `cbind`.
      - After combining the dataframes, it checks if there's an "OBS_VALUE" column and removes it. The function returns a processed dataframe suitable for plotting, where each row corresponds to a date, CPI component, and its observed value.

- [`aesthetics.R`](FMX-Proj-Write_Up/code/aesthetics.R)
  - This script defines the plot aesthetics in order to have consistent plot aesthetics
- [`arima.R`](FMX-Proj-Write_Up/code/arima.R)
  - This script contains the functions used to model the ARIMA model for the project.
  - There are two functions specified:
    - `model_arima()`:
      - The `model_arima` function fits ARIMA models to a list of time series data. It first checks if each time series is stationary using the Augmented Dickey-Fuller test and makes it stationary if necessary by differencing. Then, it applies the `auto.arima` function to determine the best ARIMA model for each time series based on the Akaike Information Criterion (AIC). Finally, it returns a list of ARIMA models corresponding to the input time series.
    - `get_residuals()`
      - The `get_residuals` function takes a list of ARIMA models as input. It first summarizes each ARIMA model using the `summary` function but doesn't capture or store the summaries. Then, it extracts the residuals from each ARIMA model using the `residuals` function. These residuals are stored in a list of time series objects. Finally, the function converts each time series of residuals into a data frame and returns a list of these data frames containing the residuals for further analysis or visualization.
- [`garch.R`](FMX-Proj-Write_Up/code/garch.R)
  - This script contains the functions necessary to model the GARCH model.
  - There is one function in the script:
    - `model_garch()`
      - Fits Generalized Autoregressive Conditional Heteroskedasticity (GARCH) models to a collection of time series data representing residuals. It begins by initializing an empty list called `garch_models` to hold the fitted GARCH models. The function then iterates through the names of the provided time series, specifying a GARCH(1,1) model for each using the `ugarchspec` function. This model includes both a volatility component and an optional mean component. Subsequently, it fits the specified GARCH model to the respective residual time series using the `ugarchfit` function. The fitted GARCH models are stored in the `garch_models` list, where each model is associated with the name of its corresponding time series. Ultimately, the function returns the `garch_models` list containing these fitted GARCH models, facilitating further analysis or evaluation of the models.
- [`plot.R`](FMX-Proj-Write_Up/code/plot.R)
  - This script contains plotting functions used in the project. It recursively refers to the theme functions defined in `aethetics`.
  - It contains three functions:
    - `plot_cpi_series`
      - Creates a time series plot. It highlights a specific component in the plot, depending on the "selected_component" argument. The function first prepares the data frame by adding a "Highlight" column based on the selection. It then filters the data to create a separate data frame for the selected component. The plot is customized with color and line size variations, and it returns the final ggplot object.
    - `plot_cpi_forecast`
      - Generates CPI (Consumer Price Index) forecasts along with 95% confidence intervals. It uses ARIMA and GARCH models to make predictions for a specified number of periods ahead. The function calculates confidence intervals, cumulative CPI forecasts, and plots the CPI forecast with confidence intervals as well as the cumulative change in CPI over time. It returns both plots in a list: "forecast_plot" for the CPI forecast and "cumulative_plot" for the cumulative change in CPI.
    - `plot_forecast_actual`
      - The function takes a list of time series data, applies ARIMA and GARCH models to make CPI (Consumer Price Index) forecasts for a specified number of periods ahead, and then compares the actual and forecasted CPI values. It trims the data to December 2021, generates forecasts, and combines them. After preparing the data, it plots the actual and forecasted CPI values over time. The resulting plot shows the actual and forecasted CPI values, highlighting the differences between them.

---

## InCast Web Application

The InCast web application is defined in the coding script `app.R` in the [**InCast**](InCast/app.R) folder. It defines a Shiny web application called the "InCast Forecasting Dashboard." The application is designed to forecast and visualize the Consumer Price Index (CPI) data for various components. It allows users to select a specific CPI component, choose the number of periods to forecast, and decide whether to plot the series or forecast the CPI.

The InCast Forecasting Dashboard was created to provide an interactive platform for analyzing and forecasting CPI data, which is crucial for economic analysis and decision-making. It enables users to explore and visualize CPI trends for different components and make forecasts based on advanced time series models. This app facilitates data-driven insights into inflation patterns and helps users assess potential economic impacts. By offering both plotting and forecasting capabilities, it empowers users to make informed decisions and gain a deeper understanding of CPI dynamics.

----

## Documentation

You can find additional documentation for using EconData [here](https://randomsample.co.za/user-guide/).

---

## Authors

- Jan-Hendrik Pretorius, Stellenbosch University
  - Project and analysis
