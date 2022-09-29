library(tidyverse)
library(magrittr)
library(purrr)
library(glue)
library(stringr)
library(rvest)
library(xml2)
library(polite)

url <- "https://oce.op.gg/champions"

# a <- url %>% 
#   read_html() %>% 
#   html_nodes("div.css-gfgr92.e5qh6tw3 > select#platinum_plus > option") %>%
#   html_attr("value") 
# tier <- tibble(Tier = a)
# tier  

pos <- url %>% 
  read_html() %>% 
  html_nodes("nav.css-1wrsp9i.e14ouzjd5 > button") %>% 
  html_text()
pos

position <- tibble(Position = pos)
position
