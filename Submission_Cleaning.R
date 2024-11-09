library(tidyverse)
library(rvest)
library(dplyr)
library(httr)
#####LOOP MAI ERRORS RESOLVE KARNE HAI


html <- "https://steam250.com/top250"
games_html <- read_html(html)

#Game Ttitles
game_titles <- games_html %>% html_elements(".title a") %>% html_text()
game_titles <- game_titles[3 : 252]

#Rank According To Score
game_ranks <- games_html %>% html_elements(".title") %>% html_text()
game_ranks <- game_ranks[3 : 252]
game_ranks <- substr(game_ranks, 1, 4)


#Release Dates
release_dates <- games_html %>% html_elements(".date") %>% html_attr("title")
release_dates <- c(release_dates, "27 April 2017")


#Scores
game_score <- games_html %>% html_elements(".score") %>% html_text()


#Audience Rating
game_rating <- games_html %>% html_elements(".rating") %>% html_text()


#Total Votes
game_votes <- games_html %>% html_elements(".votes") %>% html_text()
game_votes <- gsub(" votes", "", game_votes)


#Game Price
priced_games <- games_html %>% html_elements(".price") %>% html_text()
free_games <- games_html %>% html_elements(".free") %>% html_text()
free_games_labels <- rep("Free", length(free_games))
game_prices <- games_html %>% html_elements(".price, .free") %>% html_text()



game_dataset = data.frame("Ranks" = game_ranks,
                          "Titles" = game_titles,
                          "Release Date" = release_dates,
                          "Price" = game_prices,
                          "Score" = game_score,
                          "Player Ratings" = game_rating,
                          "Number of Votes" = game_votes)

game_dataset <- tibble(game_dataset)
game_dataset
