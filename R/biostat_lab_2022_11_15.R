# Script for lab work for Biostatistics I
# 2022-11-15

library(tidyverse)
library(foreign)
library(readxl)
library(httr)

df <- read.dta('http://www.stats4life.se/data/wcgs.dta')

theme_set(theme_bw())

ggplot(df, aes(x = height, y = weight)) +
  geom_point(color = 'cornflowerblue', size = 2, shape = 15) +
  geom_smooth(method = "lm", se = FALSE, color = 'black', size = 1) +
  labs(x = 'Height (Inch)',
       y = 'Body Weight (lbs)')

# Part I: Basic descriptive commands
# 1. Count the number of new CHD cases occurred during the follow-up time
cases <- df |>
  filter(chd69 == 'Yes') |>
  summarize(n = n()) |>
  pull(n)

message(cat("Number of new CHD cases is:", cases))
rm(cases)

# 2. Count the number of CHD cases among smokers and non-smokers
message("Number of CHD cases grouped by smoking status")
df |>
  filter(chd69 == 'Yes') |>
  group_by(smoke) |>
  summarize(chd_cases = n())

# 3. Produce a table of descriptive statistics (median, 25th percentile, and 75th
# percentile) of systolic blood pressure by CHD status.
message("Descriptive statistics for systolic blood pressure")
df |>
  group_by(chd69) |>
  summarize(median = median(sbp), p25 = quantile(sbp, probs = 0.25), p75 = quantile(sbp, probs = 0.75))

# 4. Dichotomise diastolic blood pressure (above/below median) and examine the
# observed CHD risk in the two groups.
df |>
  filter(!is.na(dbp), !is.na(chd69)) |>
  mutate(high_dbp = factor(ifelse(dbp > median(dbp), 1, 0), labels = c('False', 'True'))) |>
  group_by(high_dbp) |>
  summarize(chd_risk = (mean(as.numeric(chd69)) - 1) * 100)


# 5.There are two strange observations: A person with a total cholesterol level of
# 645 units and a person smoking 99 cigarettes per day. Replace them to missing.
df <- df %>%
  mutate(chol = ifelse(chol > 640, NA, .),
         ncigs = ifelse(ncigs > 95, NA, .))

# Part II: Visualisations
# 1. Produce a scatter plot of weight and height
ggplot(df, aes(x = weight, y = height)) +
  geom_point(color = 'cornflowerblue') +
  labs(x = 'Weight (lbs)',
       y = 'Height (inches)')

# 2. Produce a histogram of the body mass index distribution with a normal distribution curve
ggplot(df, aes(bmi)) +
  geom_histogram(aes(y = ..density..), binwidth = 1, color = 'black', fill = 'cornflowerblue') +
  stat_function(fun = dnorm, 
                args = list(mean = mean(df$bmi),
                            sd = sd(df$bmi)),
                col = 'black',
                size = 1) +
  labs(x = 'Body Mass Index (kg/m2)',
       y = 'Frequency')

# 3. Overlay a smoothed histogram (kernel density) of the total cholesterol
# distribution among cases and non-cases of CHD.
ggplot(df, aes(x = chol, color = chd69)) +
  geom_density() +
  scale_colour_brewer(palette = 'Set1') +
  labs(x = 'Cholesterol (mg/dL)',
       y = 'Density',
       color = 'CHD')

# Extra I:
# Create our own set
df2 <- data.frame(date = 1:10, outbreaks = c(10,8,12,15,20,19,23,21,20,20))

ggplot(df2, aes(x = date, y = outbreaks)) +
  geom_point(color = 'cornflowerblue', size = 2) +
  geom_smooth(method = 'lm', se = FALSE, color = 'orange') +
  theme_bw() +
  scale_x_continuous(breaks = seq(from = 0, to = 10, by = 2)) +
  labs(x = "Day",
       y = "Outbreaks (n)")

rm(df2)

# Extra II:
# Import data
tmp <- tempfile(fileext = '.xlsx')
r1 <- GET('https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-2020-12-14.xlsx', write_disk(tmp))
df2 <- read_xlsx(tmp)

rm(list = c('tmp', 'r1'))

# 2. Pick and choose countries that you would like to compare or highlight.
df_select <- df2 |>
  filter(countriesAndTerritories %in% c('Sweden', 'Germany', 'Italy'))

# 3. Develop a visualization showing a country comparison of COVID-19 trends
ggplot(df_select, aes(x = dateRep, y = `Cumulative_number_for_14_days_of_COVID-19_cases_per_100000`, color = countriesAndTerritories)) +
  geom_point() +
  scale_color_brewer(palette = 'Set1') +
  labs(title = 'Comparison of COVID-19 cases',
       x = 'Time (days)',
       y = '14-days cumulative COVID-19 cases',
       color = 'Country')

# 4. Export the figure into png format
ggsave('covid-19_country_comparison.png')