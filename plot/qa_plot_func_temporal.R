#' # ABIDE: Temporal Functional Data Quality Metrics

#' Here we plot all the anatomical QA measures. The code for this can be found 
#' at https://github.com/preprocessed-connectomes-project/abide/blob/master/plot/qa_plot_func_temporal.R

#' ## Load Dependencies
#' Functions and libraries that are needed for plotting needs
#' Please see https://github.com/preprocessed-connectomes-project/abide/blob/master/plot/qa_plot_functions.R for actual code.
#+ func-temp-source
source("qa_plot_functions.R")

#' ## Read in Data
#' Along with reading the data, we setup descriptions that will be associated
#' with each column and used as the label for the y-axis.
#+ func-temp-read
df     			<- read.csv("Phenotypic_V1_0b_preprocessed.csv")
df$SITE_ID  <- factor(sub("_", " ", as.character(df$SITE_ID)))
qa.measures <- c("func_dvars", "func_outlier", "func_quality", "func_mean_fd", 
                 "func_perc_fd")
qa.descs    <- list(
  func_dvars    = "Standardized DVARS", 
  func_outlier  = "Fraction of Outlier Voxels", 
  func_quality  = "Distance Quality Index", 
  func_mean_fd  = "Mean Framewise Displacement (FD)", 
  func_perc_fd  = "Percent FD greater than 0.2mm"
)

#' ## Plot each measure
#' Now we plot the data. Note that here we are removing outliers with values
#' greater than 3 times the IQR relative to the 25% or 75% mark.
#+ func-temp-plot, fig.width=8, fig.height=5, dpi=100
for (measure in qa.measures) {
  desc <- qa.descs[[measure]]
  plot_measure(df, measure, desc, site.col="SITE_ID", plot=TRUE, 
               outfile=NULL, rm.outlier=TRUE)
}
