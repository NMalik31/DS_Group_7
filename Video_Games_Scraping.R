library(tidyverse)
library(rvest)
library(dplyr)

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
game_ranks

#Release Dates
release_dates <- games_html %>% html_elements(".date") %>% html_attr("title")
release_dates

#Scores
game_score <- games_html %>% html_elements(".score") %>% html_text()
game_score

#Audience Rating
game_rating <- games_html %>% html_elements(".rating") %>% html_text()
game_rating

#Total Votes
game_votes <- games_html %>% html_elements(".votes") %>% html_text()
game_votes <- gsub(" votes", "", game_votes)
game_votes

#Game Price
priced_games <- games_html %>% html_elements(".price") %>% html_text()
free_games <- games_html %>% html_elements(".free") %>% html_text()
free_games_labels <- rep("Free", length(free_games))
game_prices <- games_html %>% html_elements(".price, .free") %>% html_text()
game_prices

#Links to Individual Game Pages and Extracting data Through these individual pages
game_links <- games_html %>% html_elements(".title a") %>% html_attr("href")
game_links <- game_links[3 : 252]
game_links
##Game Developer and Publisher
game_devs <- character(length = length(game_links))
game_publishers <- character(length = length(game_links))

##Lowest Game Price (Discounted)
game_lowest <- numeric(length = length(game_links))

##Single/Multi Player
game_plyr <- character(length = length(game_links))

##Game Genre
game_tag1 <- character(length = length(game_links))

##Game Theme
game_themes <- character(length = length(game_links))

##Loop to iterate through each link for scraping
for (i in 1 : length(game_links))
{
  game_page <- read_html(game_links[i])
  #game_devs[i] <- game_page %>% html_elements(".dev") %>% html_text()
  #game_publishers[i] <- game_page %>% html_elements(".pub") %>% html_text()
  
  #game_plyr[i] <- game_page %>% 
                  #html_elements('li[data-cat="plyr"] a') %>%
                  #html_text(trim = TRUE)
  #game_tag1[i] <- game_page %>%
                  #html_elements("li[data-cat='g1'] a") %>%
                  #html_text(trim = TRUE) 
  #game_themes[i] <- game_page %>%
                    #html_elements("li[data-cat='theme'] a") %>%
                    #html_text(trim = TRUE) 
  
  devs <- game_page %>% html_elements(".dev") %>% html_text(trim = TRUE)
  game_devs[i] <- if (length(devs) > 0) devs else NA  # Assign NA if not found
  
  # Extract game publisher
  publishers <- game_page %>% html_elements(".pub") %>% html_text(trim = TRUE)
  game_publishers[i] <- if (length(publishers) > 0) publishers else NA  # Assign NA if not found
  
  # Extract single/multi player
  plyr <- game_page %>% 
    html_elements('li[data-cat="plyr"] a') %>%
    html_text(trim = TRUE)
  game_plyr[i] <- if (length(plyr) > 0) plyr else NA  # Assign NA if not found
  
  # Extract game genre
  # Extract game genre tags (g1, g2, g3)
  tag1 <- game_page %>%
    html_elements("li[data-cat='g1'] a") %>%
    html_text(trim = TRUE)
  
  tag2 <- game_page %>%
    html_elements("li[data-cat='g2'] a") %>%
    html_text(trim = TRUE)
  
  tag3 <- game_page %>%
    html_elements("li[data-cat='g3'] a") %>%
    html_text(trim = TRUE)
  
  # Assign the first found tag to game_tag1
  if (length(tag1) > 0) {
    game_tag1[i] <- tag1[1]  # Take the first g1 tag if present
  } else if (length(tag2) > 0) {
    game_tag1[i] <- tag2[1]  # Take the first g2 tag if g1 is not present
  } else if (length(tag3) > 0) {
    game_tag1[i] <- tag3[1]  # Take the first g3 tag if neither g1 nor g2 are present
  } else {
    game_tag1[i] <- NA  # Assign NA if no tags are found
  }
  
  # Extract game themes
  themes <- game_page %>%
    html_elements("li[data-cat='theme'] a") %>%
    html_text(trim = TRUE)
  game_themes[i] <- if (length(themes) > 0) themes else NA  # Assign NA if not found
}
game_links
