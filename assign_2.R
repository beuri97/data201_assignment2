library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)

url <- "https://www.metacritic.com/game"
url %>% 
  read_html() %>% 
  html_structure()


data <- url %>% 
  read_html()

name <- data %>% 
  html_nodes(".title > h3") %>% 
  html_text2()
name

clamp_detail <- data %>% 
  html_nodes(".clamp-details > span") %>% 
  html_text()
clamp_detail

meta_score <- data %>% 
  html_nodes(".clamp-metascore > a > div.metascore_w.large.game.positive") %>% 
  html_text()
meta_score

discription <- data %>% 
  html_nodes(".summary") %>% 
  html_text2()
discription


datas <- tibble(Game = name, Release = clamp_detail, Meta_Score = meta_score, Detail = discription)
datas