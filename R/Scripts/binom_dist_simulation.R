# Function to simulate the random generation on a larger scale

library(ggplot2)

sim_test <- function(obs = 100, theta = 0.5) {
  est_theta <- mean(rbinom(obs, size = 1, prob = theta))
}

# Create standard aesthetics
plot_aes <- function(.x) {
  .x +
    geom_histogram(color = 'black', fill = 'cornflowerblue') +
    theme_bw() +
    labs(x = 'Mean',
         y = 'Frequency')
}

mean <- replicate(100, sim_test(obs = 10000, theta = 0.2))
mean <- as.data.frame(mean)

# Sort of shows a normal distribution
ggplot(mean, aes(mean)) |>
  plot_aes()

mean_large <- replicate(100000, sim_test(obs = 10000, theta = 0.2))
mean_large <- as.data.frame(mean_large)

# If we increase the number of trials it will be more of a normal distribution
ggplot(mean_large, aes(mean_large)) |>
  plot_aes()