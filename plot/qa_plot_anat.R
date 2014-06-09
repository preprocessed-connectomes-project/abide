#' # ABIDE: Anatomical Data Quality Metrics

#' Here we plot all the anatomical QA measures. The code for this can be found 
#' at https://github.com/preprocessed-connectomes-project/abide/blob/master/plot/qa_plot_anat.R

#' ## Load Dependencies
#' Functions and libraries that are needed for plotting needs
#' Please see https://github.com/preprocessed-connectomes-project/abide/blob/master/plot/qa_plot_functions.R for actual code.
#+ anat-source
source("qa_plot_functions.R")

#' ## Read in Data
#' Along with reading the data, we setup descriptions that will be associated
#' with each column and used as the label for the y-axis.
#+ anat-read
df 					<- read.csv("Phenotypic_V1_0b_preprocessed.csv")
df$SITE_ID  <- factor(sub("_", " ", as.character(df$SITE_ID)))
qa.measures <- colnames(df)[grep("^anat_", colnames(df))]
qa.descs    <- list(
    anat_cnr  = "Contrast to Noise Ratio", 
    anat_efc  = "Entropy Focus Criteria", 
    anat_fber = "Foreground to Background Energy Ratio", 
    anat_fwhm = "FWHM in mm", 
    anat_qi1  = "Percent of Artifact Voxels",
    anat_snr = "Signal to Noise Ratio"
)

#' ## Plot each measure
#' Now we plot the data. Note that here we are removing outliers with values
#' greater than 3 times the IQR relative to the 25% or 75% mark.
#+ anat-plot, fig.width=8, fig.height=5, dpi=100
for (measure in qa.measures) {
    desc <- qa.descs[[measure]]
    plot_measure(df, measure, desc, site.col="SITE_ID", plot=TRUE, 
                             outfile=NULL, rm.outlier=TRUE)
}
