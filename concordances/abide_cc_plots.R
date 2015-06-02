# abide_cc_plots.R
#
# Usage Rscript abide_cc_plots.R <path_to_df_csv> <path_to_out_pdf>
#
# Author: Daniel Clark, 2015

# Plot ABIDE concordances
plot_abide_cc <- function(big_df, deriv) {

    # Get only the derivative's entries
    deriv_df <- subset(big_df, derivative == deriv)

    # Cross-strategy plots
    pipe_df <- subset(deriv_df, pipeline != '')
    # GGplot object
    p1 <- ggplot(pipe_df, aes(x=comparison, y=concordance, colour=pipeline)) +
          geom_boxplot(width=0.5, outlier.size=1) +
          labs(title=paste(deriv, 'cross-strategy')) +
          scale_y_continuous(limits=c(-.5, 1.2)) +
          scale_x_discrete(labels=c('fg-fng', 'fg-nfg', 'fg-nfng', 'fng-nfg', 'fng-nfng', 'nfg-nfng'))

    # Cross-pipeline plots
    strat_df <- subset(deriv_df, strategy != '')
    # GGplot object
    p2 <- ggplot(strat_df, aes(x=comparison, y=concordance, colour=strategy)) +
          geom_boxplot(width=0.5, outlier.size=1) +
          labs(title=paste(deriv, 'cross-pipeline')) +
          scale_y_continuous(limits=c(-.5, 1.2))
    if ((deriv != 'alff') & (deriv != 'falff')) {
          p2 <- p2 + scale_x_discrete(labels=c('ccs-cpac', 'ccs-dparsf', 'ccs-niak', 'cpac-dparsf', 'cpac-niak', 'dparsf-niak'))
    }

    # Return plots
    plot_list <- list(p1, p2)
    return(plot_list)
}

# Import packages
library(ggplot2)

# Grab arguments
args <- commandArgs(TRUE)
csv_path <- args[1]
out_pdf <- args[2]

# Load ABIDE dataframe with all concordances
big_df <- read.csv(csv_path)

# Get derivatives list
deriv_list <- unique(big_df$derivative)

# Init pdf-out
pdf(out_pdf)

# For each derivative: call function and return plot objects
for (deriv in deriv_list) {

    # Call function
    plot_list <- plot_abide_cc(big_df, deriv)

    # Print status
    print(paste('Printing', deriv))

    # Save as pdf
    for (plt in plot_list) {
        print(plt)
    }
}
