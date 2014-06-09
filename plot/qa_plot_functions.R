# Here, we give some functions to plot a given QC metric across subjects by site.


###
# SETUP
###

# Load some needed packages
library(grid)
library(ggplot2)
library(plyr)
library(RColorBrewer)

# CMI-Based Color Scheme
cmi_main_blue="#0071b2"
cmi_grey="#929d9e"
cmi_light_blue="#00c4d9"
cmi_pea_green="#b5bf00"

cmi_rich_green="#73933d"
cmi_rich_purple="#8e7fac"
cmi_rich_red="#d75920"
cmi_rich_blue="#4c87a1"
cmi_rich_aqua="#66c7c3"
cmi_rich_orange="#eebf42"

cmi_vibrant_yellow="#ffd457"
cmi_vibrant_orange="#f58025"
cmi_vibrant_green="#78a22f"
cmi_vibrant_garnet="#e6006f"
cmi_vibrant_purple="#9A4d9e"
cmi_vibrant_blue="#19398a"

cmi_site_colors = c(cmi_vibrant_blue,
                    cmi_rich_blue,
                    cmi_vibrant_purple,
                    cmi_vibrant_garnet,
                    cmi_rich_red,
                    cmi_vibrant_orange,
                    cmi_vibrant_yellow,
                    cmi_vibrant_green)
cmi_site_colors_ramp = colorRampPalette(cmi_site_colors)


###
# FUNCTIONS - TO FILTER DATA
###

remove_nas <- function(df, measure) {
    na_inds <- is.na(df[[measure]])
    cat(sprintf("...removing %i points with NA values\n", sum(na_inds)))
    df      <- df[!na_inds,]
    return(df)
}

get_outlier_inds <- function(dat, times.iqr=3) {
    # We figure out the lower and upper limit of acceptable data
    # similar to the approach taken with Tukey box plots
    upper.limit <- quantile(dat, 0.75) + times.iqr*IQR(dat)
    lower.limit <- quantile(dat, 0.25) - times.iqr*IQR(dat)
    # and remove the rows that are outside this bound
    inds    <- (dat > upper.limit) | (dat < lower.limit)
    return(inds)
}

# Sometimes extreme data-points can skew the plot 
# and make it difficult to see the spread of the data.
# If requested, we can remove these points
# Note: this only removes outliers for a given measure
remove_outliers <- function(df, measure, times.iqr=3) {
    dat     <- df[[measure]]    
    inds    <- get_outlier_inds(dat, times.iqr)
    df      <- df[!inds,]
    cat(sprintf("...removed %i outlier points\n", sum(inds)))
    
    return(df)
}


###
# FUNCTIONS - RELATED TO PERCENTILES
###


# In preperation for plotting the percentile lines
# we calculate the percentiles in advance
# and have some code to do the plotting for later
# We will be looking at 1%, 5%, 25%, 50%, 75%, 95%, & 99%
calc_percentiles <- function(df, measure) {
    # In our plots, we want to have percentile lines to indicate the 
    # distribution of each site relative to the whole sample
    qvals       <- c(0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99)
    qcat        <- c(1,5,25,50,25,5,1)
    qline       <- c(3, 2, 5, 1, 5, 2, 3)
    qsize       <- c(.4, .25, .3, .25, .3, .25, .4)
    qcols       <- c("grey10", "grey10", "grey10", "grey50", "grey10", "grey10", "grey10")
    
    # Get the percentiles
    percentiles <- quantile(df[[measure]], qvals, na.rm=T)
    
    # Merge with name (qcat), line type (qline), and line width (qsize)
    # There's a weird error if I include qcols so won't do that here
    percentiles_df          <- as.data.frame(cbind(percentiles, qcat, qline, qsize))
    percentiles_df$qline    <- as.factor(qline)
    percentiles_df$qcat     <- as.factor(qcat)
    attr(percentiles_df, "qcols") <- qcols
    
    return(percentiles_df)
}

# This function will add percentile lines in the background
# plot: ggplot object
# pdf: percentile data frame
compile_percentiles <- function(pdf, measure) {
  cols <- attr(pdf, "qcols")
  ret <- lapply(1:nrow(pdf), function(i) {
    p <- pdf[i,]
    if (!is.null(cols)) {
      plot <- geom_hline(aes(yintercept=percentiles), data=p, 
                         size=as.numeric(p$qsize), linetype=as.numeric(p$qline), 
                         color=cols[i])
      #as.character(p$qcolor[1])
    } else {
      plot <- geom_hline(aes(yintercept=percentiles), data=p, 
                         size=as.numeric(p$qsize[1]), linetype=as.numeric(p$qline[1]), 
                         color="grey50")
    }
    return(plot)
  })
  return(ret)
}


###
# FUNCTIONS - TO DO THE PLOTTING
###


# Now we finally have one function that does the plotting bit
# It will also call the percentile functions above
# Also assume a site column and a global (all site) column
plot_measure <- function(df, measure, desc, site.col="site.name", plot=TRUE, 
                         outfile=NULL, rm.outlier=FALSE) 
{
    cat("Plotting measure", measure, "-", desc, "\n")
    
    # 1. Remove any missing (NA) values
    df <- remove_nas(df, measure)
    
    # 2. Remove outliers > 3xIQR
    if (rm.outlier) df <- remove_outliers(df, measure)
    
    # Add global column if needed
    if (!("global" %in% colnames(df))) {
      df$global <- "All Sites"
    }
    
    # 3. Start plot
    pg1=ggplot(df, aes_string(x=site.col, y=measure))
    
    # 4. Add the percentile lines (1%, 5%, 25%, 50%, 75%, 95%, 99%)
    perc_df <- calc_percentiles(df, measure)
    pg2=pg1 + compile_percentiles(perc_df, measure)  
  
    # 5. Add main plot
    # - violin plot + boxplot for all the data
    # - jitter plot for each site (adjust the color)
    # - x and y labels
    nsites <- length(unique(df[[site.col]]))
    pg3=pg2 + 
      geom_violin(aes(x=global), color="gray50") + 
      geom_boxplot(aes(x=global), width=.1, fill="gray50", outlier.size=0) + 
      geom_jitter(aes_string(color=site.col), position = position_jitter(width = .1)) + 
      scale_color_manual(values=c(brewer.pal(4,"Dark2"), cmi_site_colors_ramp(nsites))) + 
      ylab(desc) +
      xlab("") 
    
    # 6. Setup text, margins, etc
    pg4=pg3 +
      theme_bw() + 
      theme(axis.title.x      = element_text(family = "Times", face = "plain", 
                                  size=18)) +  
      theme(axis.title.y      = element_text(family = "Times", face = "plain", 
                                  size=18, angle=90, vjust=0.25)) +  
      theme(axis.text.x       = element_text(family = "Times", face = "plain", 
                                  size=14, vjust=0.95, hjust=1, angle=45)) + 
      theme(axis.text.y       = element_text(family = "Times", face = "plain", 
                                  size=16, angle=90, hjust=0.5)) + 
      theme(axis.ticks.length = unit(.15, "lines")) + 
      theme(axis.ticks.margin = unit(.15,"lines")) + 
      theme(plot.margin       = unit(c(1, 1, 0.25, 1), "lines")) + 
      theme(legend.position   = "none")

    # End
    pg=pg4
    
    # 7. Plot
    if (plot) {
        cat("...plotting\n")
        print(pg)
    }
    
    # 8. Save
    if (!is.null(outfile)) {
        cat("...saving to", outfile, "\n")
        ggsave(outfile, pg, height=3, width=6, dpi=100)
    }
    
    return(pg)
}
