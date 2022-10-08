library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)
library(lubridate)

# # Helper function
# get_data <- function(data, element_class) {
#   text_data <- data %>% 
#     html_nodes(element_class) %>% 
#     html_text2()
#   
#   return(text_data)
# }

# URL of the new games in all platforms in the last 90 days from metacritic.
url <- "https://www.metacritic.com/browse/games/score/metascore/90day/all/filtered"

# Read and print the content of metacritic's New Games page.
new_games <- url %>% 
  read_html()
new_games

# Shows the html structure of the New Games page.
new_games %>% 
  html_structure()

# Finds all the h3 element under the .title class which is under .clamp-summary-wrap class.
# Then extract the raw text inside the h3 element. Assign the result as titles.
titles <- new_games %>% 
  html_nodes(".clamp-summary-wrap > .title > h3") %>% 
  html_text()
titles

# Finds the element inside .platform class having .data class. Then extract the raw text inside that element. 
# Assign the result as platform. 
platform <- new_games %>% 
  html_nodes(".platform > .data") %>% 
  html_text()
platform

# Finds all of the span element inside .clamp-details class and extract the contained raw text from it. 
# Assign the result as release_date.
release_date <- new_games %>% 
  html_nodes(".clamp-details > span") %>% 
  html_text()
release_date

# Takes the element with class .summary then extract the text inside of it. Save th result as game_descr.
description <- new_games %>% 
  html_nodes(".summary") %>% 
  html_text()
description

# Finds the div element inside a element under the element having .clamp-metascore as class and extract the text inside.
# Save the result as meta_score.
meta_score <- new_games %>% 
  html_nodes(".clamp-metascore > a > div") %>% 
  html_text()
meta_score

# Finds the div element inside a element under the element having .clamp-usercore as class and extract the text inside.
# Save the result as user_score.
user_score <- new_games %>% 
  html_nodes(".clamp-userscore > a > div") %>% 
  html_text()
user_score

new_games_df <- tibble(game_title = titles,
                       release_date = as.Date(release_date, format = "%B %d, %Y"),
                       platform = platform %>% str_replace_all("[^[:alnum:]]", " ") %>% trimws("both"),
                       games_descr = description %>% str_replace_all("[^[:alnum:]]", " ") %>% trimws("both"),
                       meta_score = meta_score,
                       user_score = user_score)
new_games_df %>% head()
