# ***************************************************************************
# Exploring the relation between mental health and dietary fiber intake.
# Only for demonstration purposes!
#
# By Thomas Roosdorp
# 2023-01-13
# ****************************************************************************

# CREATING DUMMY DATA -------------------------------------

# How many dummy respondents to generate data for
n <- 30

set.seed(1245)

var_names <- c("id", "age", "gender", "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10", "q11", "q12", "q13", "q14", "q15", "q16", "q17", "q18")

df <- data.frame()

for (seq_along(n)) {
  add_row(df)
}

# Generate multi-choice result

# Generate missing data

# VALIDATION AND CLEANING DATA ------------------------------
summary(df)

df_clean <- distinct(df, id)

# Check age

# Remove missing recursively

# Label variables

# Factor values

# DESCRIBING THE DATA ------------------------------------


# ORGANIZING THE DATA ------------------------------------

# Dummy encoding

# EXPLORATORY VISUALIZATION -------------------------------

# ANALYSIS ---------------------------------------------
