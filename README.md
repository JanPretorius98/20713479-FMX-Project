# 20713479-FMX-Project

Why has CPI become more noisy? Signal to noise analysis.

---

## Table of Contents

1. [Installation](#installation)
2. [Project Organization](#project-organization)
3. [Utilities Functions](#utilities-functions)
4. [Documentation](#documentation)
5. [Authors](#authors)

---

## Installation

- `tidyverse`

- `ggplot2`

- `dplyr`

- `devtools`

- `econdatar`

  - This package is not available on CRAN, but can be downloaded as follows:

    ```R
    library(devtools)
    install_github("coderaanalytics/econdatar")
    library(econdatar)
    ```

---

## Project Organisation

In the context of CPI data, a GARCH model can be particularly useful if you are interested in modeling and forecasting the volatility (or the conditional variance) of inflation rates, rather than the levels of the CPI itself. This could be the case if you're analyzing the uncertainty or the noise around the inflation rate, rather than the inflation rate.

For instance, if the residuals of your inflation model (from an ARIMA model, for instance) exhibit time-varying volatility, a GARCH model can be used to model this conditional variance. The residuals of the ARIMA model (the noise) would serve as the input series for the GARCH model, allowing you to capture the dynamic variance in the data.

The GARCH model would give you a time series of the estimated volatilities, which can be interpreted as the changing risk or uncertainty of inflation over time. This can be extremely useful for risk management purposes, such as in portfolio optimization, derivative pricing, or for policymakers who are interested in the stability of the inflation rate.
