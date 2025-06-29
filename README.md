# GameScape: Data Scraping and Analysis of the Top 250 E-Games using R

**MTH208 – Data Science Lab - I**  
**Instructor:** Dr. Dootika Vats  
**Group 7:**  Neelaksha Malik, Mainak Sarkar, Tenzin Tsomu, Harsh Deep

---

## Acknowledgement

We would like to extend our heartfelt thanks to Professor Dootika Vats for her invaluable guidance and support throughout the development of our GameScape Data Analysis project. Her expert feedback, encouragement, and dedication have played a crucial role in the success of this project. We are deeply grateful for her patience and commitment in helping us overcome the challenges we encountered along the way.

---

## 1. Introduction

### 1.1 About E-Games

E-games, or electronic games, refer to video games played on digital platforms such as consoles, PCs, and mobile devices. With the rise of internet connectivity and gaming technology, e-games have become a major global industry, attracting millions of players and viewers worldwide.

**Key features include:**
- **Variety of Game Genres:** Action, adventure, sports, strategy, role-playing, and more.
- **Online Multiplayer Platforms:** Allow players to connect and compete globally.
- **Esports Competitions:** Professional tournaments with large audiences and prizes.
- **Streaming and Content Creation:** Platforms like Twitch and YouTube enable game streaming and content creation.
- **Mobile Gaming Growth:** Massive popularity of mobile games.
- **Virtual and Augmented Reality:** Immersive new gaming experiences.

E-games have revolutionized entertainment, offering new forms of competition, creativity, and community.

### 1.2 Objective

The primary objective was to develop an interactive Shiny app that provides comprehensive analysis of the top 250 highest-rated games on Steam. Users can explore and filter games based on rank, score, release date, and price, and view detailed stats and visual insights.

#### 1.2.1 Statistical Analysis
- Collected and processed data on price, user ratings, critic reviews, and release dates.
- Used data visualization techniques to present key insights.

#### 1.2.2 Filtering Mechanisms
- Developed filters for rank, price, release year, rating, and favorites.
- Provided a user-friendly search interface.

#### 1.2.3 Providing Choices
- Enabled visual comparisons using bar charts, histograms, scatter plots, and box plots.
- Offered an interactive approach to comparing games.

---

## 2. Data Collection and Preparation

We scraped data from various sources, including:
1. Rank according to score
2. Release dates
3. Scores
4. Audience ratings
5. Total votes
6. Game prices

The raw datasets contained missing values and discrepancies, so we cleaned and organized the data.

**Libraries Used:**
- rvest
- tidyverse
- dplyr
- httr

---

## 3. Visualizing the Dataset

### 3.1 Libraries Used for Visualization:
- shiny
- DT
- dplyr
- ggplot2
- bslib

### 3.2 Shiny App Overview

Our Shiny app offers an interactive platform to explore Steam’s top 250 games. It is divided into several tabs:

- **Overview Tab:** Summary of dataset statistics and a boxplot of game scores.
- **Search and Filter Tab:** Filter games by various criteria; includes an interactive scatter plot of price vs votes.
- **Top Games Tab:** List and bar plot of top games by user-selected criteria.

### 3.3 Sample Visualizations

**Box Plot of Ratings:**  
Most games have ratings between 8.5 and 8.6, with few outliers. This suggests that extreme opinions are rare, and the filtering mechanism helps users make informed decisions.

**Scatter Plot (Number of Votes vs Price):**  
Most votes are concentrated in the $15–$25 price range, indicating typical consumer purchasing power. Games priced at $60 or more receive fewer votes.

**Bar Chart (Top 10 Game Titles by Price):**  
The most expensive games are priced around $50–$60, and are typically popular, high-quality titles. This suggests that players are willing to pay a premium for well-known games.

---

## 4. Conclusion

- The analysis reveals key relationships among price, score, and audience reviews.
- These insights can guide consumers in making informed purchases.
- The project offers a comprehensive analysis of the top 250 E-games, drawing actionable conclusions from the data.

---

## 5. References

Most data sourced from: [https://steam250.com/](https://steam250.com/)
