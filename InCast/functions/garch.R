
model_garch <- function(residuals_ts_list) {
    garch_models <- list()

    for (name in names(residuals_ts_list)) {
        # Specify the GARCH model - using GARCH(1,1) here
        spec <- ugarchspec(variance.model = list(model = "sGARCH",
                                                 garchOrder = c(1, 1)),
                           mean.model = list(armaOrder = c(0, 0),
                                             include.mean = FALSE))

        # Fit the GARCH model
        garch_models[[name]] <- ugarchfit(spec = spec,
                                          data = residuals_ts_list[[name]])
    }

    return(garch_models)
}
