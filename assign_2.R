library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)
library(fuzzyjoin)

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
platforms
  

# New Game Releases
new_games <- tibble(Title = get_data(games_page, "th.product_title"),
                    Platform = get_data(games_page, ".product_platform") %>% 
                      str_extract(regex("(?<=(on ))[a-zA-Z0-9^]+")),
                    Score = get_data(games_page, ".metascore_anchor > div"),
                    Critics = get_data(games_page, ".critic_count > a > span"))
new_games 

# Top games info
top_games <- games_page %>% 
  html_nodes(".title > h3") %>% 
  html_text2()
top_games

release_date <- games_page %>% 
  html_nodes(".clamp-details > span") %>% 
  html_text2()
release_date

meta_score <- games_page %>% 
  html_nodes(".clamp-metascore > a > div.metascore_w.large.game.positive") %>% 
  html_text2()
meta_score

game_description <- games_page %>% 
  html_nodes(".summary") %>% 
  html_text2()
game_description

datas <- tibble(Game = top_games, Release = release_date, Meta_Score = meta_score, Detail = game_description)
datas

datas %>% 
  write_csv("temporary.csv")
  
genre <- games_page %>% 
  html_nodes("ul.genre_nav > li > a") %>% 
  html_text2()
genre <- tibble(Genre = genre)

legacy <- games_page %>% 
  html_nodes(".platforms.legacy_platforms > li") %>% 
  html_text2()
legacy <- tibble(Legacy = legacy)

coming_soon_product <- games_page %>% 
  html_nodes(".product_title > a") %>% 
  html_text2()
coming_soon_product <- tibble(coming_soon_product)