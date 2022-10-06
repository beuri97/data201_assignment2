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
    html_text()
  
  return(text_data)
}

# New Game Relases
new_games <- tibble(Title = get_data(games_page, "th.product_title"),
                    Platform = get_data(games_page, ".product_platform") %>% 
                               str_replace_all("[\\h+\r\n]", ""),
                    Score = get_data(games_page, ".metascore_anchor > div"),
                    Critics = get_data(games_page, ".critic_count > a > span"))
new_games

platform <- games_page %>% 
  
overview

game_data <- games_page %>% 
  html_nodes("div.product_score_data") %>% 
  html_text()
game_data

# Top games info
top_games <- games_page %>% 
  html_nodes(".title > h3") %>% 
  html_text()
top_games

release_date <- games_page %>% 
  html_nodes(".clamp-details > span") %>% 
  html_text()
release_date

meta_score <- games_page %>% 
  html_nodes(".clamp-metascore > a > div.metascore_w.large.game.positive") %>% 
  html_text()
meta_score

game_description <- games_page %>% 
  html_nodes(".summary") %>% 
  html_text()
game_description


datas <- tibble(Game = name, Release = clamp_detail, Meta_Score = meta_score, Detail = discription)
datas

datas %>% 
  write_csv("temporary.csv")
