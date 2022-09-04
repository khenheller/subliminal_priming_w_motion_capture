# Calculates descriptive statistics and plots the data of the reach area.
# df - dataframe with sub num, condition, side and reach area.
library(gridExtra)
describe_stats_ra <- function(df){
  # Calc statistics.
  stats <- df %>%
    group_by(cond) %>% summarize(mean = mean(ra), sd = sd(ra)) %>% ungroup()
  stats
  # Visualize.
  plot1 <- df %>% ggplot(aes(x=ra, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity") + theme_minimal() + theme(text=element_text(size=15))
  plot2 <- df %>% ggplot(aes(x=cond, y=ra, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15))
  grid.arrange(plot1, plot2, ncol=2)
}

