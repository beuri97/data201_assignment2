library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)

url <- "https://www.metacritic.com/game"
games_page <- url %>% 
  read_html()
games_page

games_page %>% 
  html_structure()

# Helper function
get_data <- function(data, element_class) {
  text_data <- data %>% 
    html_nodes(element_class) %>% 
    html_text2()
  
  return(text_data)
}

# Gaming Platforms
platforms <- tibble(Gaming_Platforms = get_data(games_page, ".platforms.current_platforms > li"))
platforms %>% 
  mutate(Ref = games_page %>% html_nodes(".platforms.current_platforms > li > div > span > a") %>% html_attr("href"))
  
# Legacy Platforms
legacy <- tibble(Legacy = get_data(games_page, ".platforms.legacy_platforms > li"))
legacy

# New Game Releases
new_games <- tibble(Title = get_data(games_page, "th.product_title"),
                    Platform = get_data(games_page, ".product_platform"),
                    Score = get_data(games_page, ".metascore_anchor > div"),
                    Critics = get_data(games_page, ".critic_count > a > span"))
new_games 

# Upcoming Games
coming_soon_games <- tibble(Title = get_data(games_page, ".product_title > a"))
coming_soon_games

# Top Games info
top_games <- tibble(Title = get_data(games_page, ".title > h3"),
                    Release = get_data(games_page, ".clamp-details > span"),
                    Meta_Score = get_data(games_page, ".clamp-metascore > a > div.metascore_w.large.game.positive"),
                    Description = get_data(games_page, ".summary"))
top-games
  
# Games Genres
genre <- tibble(Genre = get_data(games_page, "ul.genre_nav > li > a"))
genre



