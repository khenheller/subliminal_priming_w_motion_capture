# Calculates descriptive statistics and plots the data.
# df - dataframe with sub num, condition, side and variable value.
# var_name - Name of variable we want to plot, as it apears in its dataframe.
describe_stats_single_val <- function(df, var_name){
  # Calc statistics.
  stats <- df %>%
    group_by(cond) %>% summarize(mean = mean(.data[[var_name]]), sd = sd(.data[[var_name]])) %>% ungroup()
  stats
  # Visualize.
  plot1 <- df %>% ggplot(aes(x=.data[[var_name]], color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity") + theme_minimal() + theme(text=element_text(size=15)) + ggtitle(var_name)
  plot2 <- df %>% ggplot(aes(x=cond, y=.data[[var_name]], fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15)) + ggtitle(var_name)
  grid.arrange(plot1, plot2, ncol=2)
}