library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)
library(lubridate)

# URL of Games of all Time from metacritic.
url <- "https://www.metacritic.com/browse/games/score/metascore/all/all/filtered"

# Read and display the content of metacritic's New Games page.
games <- url %>% 
  read_html()
games

# Shows the html structure of the New Games page.
games %>% 
  html_structure()

# Finds all the h3 element under the .title class which is under .clamp-summary-wrap class.
# Then extract the raw text inside the h3 element. Assign the result as titles.
titles <- games %>% 
  html_nodes(".clamp-summary-wrap > .title > h3") %>% 
  html_text()
titles

# Find the a element with .title class then get the link inside the href attribute.
link <- games %>% 
  html_nodes("a.title") %>% 
  html_attr("href")
link

# Finds the element inside .platform class having .data class. Then extract the raw text inside that element. 
# Assign the result as platform. 
game_platform <- games %>% 
  html_nodes(".platform > .data") %>% 
  html_text()
game_platform

# Finds all of the span element inside .clamp-details class and extract the contained raw text from it. 
# Assign the result as release_date.
release_date <- games %>% 
  html_nodes(".clamp-details > span") %>% 
  html_text()
release_date

# Takes the element with class .summary then extract the text inside of it. Save th result as game_descr.
description <- games %>% 
  html_nodes(".summary") %>% 
  html_text()
description

# Finds the div element inside a element under the element having .clamp-metascore as class and extract the text inside.
# Save the result as meta_score.
meta_score <- games %>% 
  html_nodes(".clamp-metascore > a > div") %>% 
  html_text() %>% 
  as.double()
meta_score

# Finds the div element inside a element under the element having .clamp-usercore as class and extract the text inside.
# Save the result as user_score.
user_score <- games %>% 
  html_nodes(".clamp-userscore > a > div") %>% 
  html_text() %>% 
  as.double()
user_score

# Creates a data frame containing the scraped data from Games of all Time page.
# It is stored as all_games_df.
all_games_df <- tibble(title_plat = paste(titles, platform %>% 
                                            str_replace_all("[^[:alnum:]]", " ") %>% 
                                            trimws("both"), sep = " "),
                       release_date = as.Date(release_date, format = "%B %d, %Y"),
                       game_descr = description %>% str_replace_all("[^[:alnum:]]", " ") %>% trimws("both"),
                       meta_score = meta_score,
                       user_score = user_score)
all_games_df %>% head()

# Helper function to to read in the content of the web page.
read_page_content <- function(link) {
  web_page_content <- link %>% 
    read_html()
  
  return(web_page_content)
}

# Helper function for cleaning the raw text (replacing special characters and trimming the whitespaces on both sides).
clean_text <- function(raw_data) {
  clean_data <- raw_data %>% 
    str_replace_all("[^[:alnum:]]", " ") %>% 
    trimws("both")
  
  return(clean_data)
}

# Helper function to convert character date to actual date type.
convert_date <- function(chr_date) {
  converted_date <- as.Date(chr_date, format = "%B %d, %Y")
  
  return(converted_date)
}

# Helper function to get the title of the games.
get_title <- function(data) {
  title <- data %>%
    html_nodes(".clamp-summary-wrap > .title > h3") %>% 
    html_text()
  
  return(title)
}

# Helper function to get the release date of the games.
get_date <- function(data) {
  date <- data %>%
    html_nodes(".clamp-details > span") %>% 
    html_text()
  
  return(date)
}

# Helper function to get the platform the game is on.
get_platform <- function(data) {
  platform <- data %>%
    html_nodes(".platform > .data") %>% 
    html_text()
  
  return(platform)
}

# Helper function to get the description of the games.
get_description <- function(data) {
  description <- data %>%
    html_nodes(".summary") %>% 
    html_text()
  
  return(description)
}

# Helper function to get the meta and user scores of the games.
get_scores <- function(data) {
  ms <- data %>%
    html_nodes(".clamp-metascore > a > div") %>% 
    html_text()
  
  us <- data %>%
    html_nodes(".clamp-userscore > a > div") %>% 
    html_text()
  
  return(tibble(ms = map_dbl(ms, as.double), us = map_dbl(us, as.double)))
}

# Data frame of links of the web pages we are interested in
pages <- tibble(links = c("https://www.metacritic.com/browse/games/score/metascore/year/all/filtered", 
                          "https://www.metacritic.com/browse/games/score/metascore/90day/all/filtered"))

# Apply the read_page_content to all of the links in the data frame.
# Modify the links variable to take the content of the html file of the games this year web page.
pages <- pages %>% 
  mutate(links = map(links, read_page_content))

# Take the content of the html file of the games this year web page.
game_scores <- pages[[1]][[1]] %>% get_scores()

# Create a data frame with all of the information about the first 100 games listed under
# games this year web page.
games_this_year <- tibble(title = pages[[1]][[1]] %>% get_title(),
                          release_date = pages[[1]][[1]] %>% get_date(),
                          platform_name = pages[[1]][[1]] %>% get_platform(),
                          game_descr = pages[[1]][[1]] %>% get_description(),
                          meta_score = game_scores$ms,
                          user_score = game_scores$us)

# Modify the release_date by converting it to date type.
# Modify the game_description and platform_name by removing special characters and whitespaces.
games_this_year <- games_this_year %>% 
  mutate(release_date = map(release_date, convert_date),
         game_descr = map(game_descr, clean_text),
         platform_name = map(platform_name, clean_text))

# Take the content of the html file of the new games page.
game_scores <- pages[[1]][[2]] %>% get_scores()

# Create a data frame with all of the information about the first 100 games listed under
# new games web page.
new_games <- tibble(title = pages[[1]][[2]] %>% get_title(),
                    release_date = pages[[1]][[2]] %>% get_date(),
                    platform_name = pages[[1]][[2]] %>% get_platform(),
                    game_descr = pages[[1]][[2]] %>% get_description(),
                    meta_score = game_scores$ms,
                    user_score = game_scores$us)

# Modify the release_date by converting it to date type.
# Modify the game_description and platform_name by removing special characters and whitespaces.
new_games <- new_games %>% 
  mutate(release_date = release_date %>% 
           convert_date(),
         game_descr = map_chr(game_descr, clean_text),
         platform_name = map_chr(platform_name, clean_text))

new_games %>% 
  glimpse()

top_20 <- new_games %>% 
  gather(key=score_type,
         value = score, c(meta_score, user_score))
top_10 <-top_20 %>% 
  top_n(10)

meta <- top_10 %>% 
  ggplot(aes(x=title, y=score, fill = score_type)) +
  geom_col(position="dodge")+
  scale_y_continuous(sec.axis = sec_axis(~ . * 10, name = "meta_score"))+
  labs(y="user_score") 
meta

