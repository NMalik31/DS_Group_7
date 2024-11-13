library(shiny)
library(DT)
library(dplyr)
library(ggplot2)
library(bslib)

# Define the UI for the app
ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly"),
  titlePanel("Top 250 Highest Rated Games on Steam"),
  
  tabsetPanel(
    tabPanel("Overview",
             fluidRow(
               column(12, 
                      h3("Overview of the Top 250 Steam Games"),
                      p("This section gives you a summary of the data, including the number of games, average score, and some visual insights.")
               )
             ),
             fluidRow(
               column(4, 
                      h4("Total Games in Dataset:"),
                      verbatimTextOutput("total_games")
               ),
               column(4, 
                      h4("Average Score of Games:"),
                      verbatimTextOutput("avg_score")
               ),
               column(4,
                      h4("Average Number of Votes:"),
                      verbatimTextOutput("avg_votes")
               )
             ),
             fluidRow(
               column(12,
                      plotOutput("score_distribution_plot")
               )
             )
    ),
    
    tabPanel("Search & Filter",
             sidebarLayout(
               sidebarPanel(
                 selectInput("sort_by", "Sort By:",
                             choices = c("Rank", "Score", "Release Date", "Price"),
                             selected = "Rank"),
                 sliderInput("num_votes", "Minimum Number of Votes:",
                             min = 0,
                             max = max(as.numeric(gsub(",", "", game_dataset$Number.of.Votes)), na.rm = TRUE),
                             value = 0),
                 dateRangeInput("release_date", "Release Date Range:",
                                start = min(as.Date(game_dataset$Release.Date, format = "%d %b %Y"), na.rm = TRUE),
                                end = max(as.Date(game_dataset$Release.Date, format = "%d %b %Y"), na.rm = TRUE)),
                 selectInput("player_rating", "Player Rating:",
                             choices = unique(game_dataset$Player.Ratings), multiple = TRUE),
                 sliderInput("price_range", "Price Range:",
                             min = 0, max = 100, value = c(0, 100), pre = "$"),
                 textInput("search_title", "Search by Title:", "")
               ),
               mainPanel(
                 DTOutput("game_table"),
                 plotOutput("votes_vs_price_plot")
               )
             )
    ),
    
    tabPanel("Top Games",
             fluidRow(
               column(12, 
                      h3("Top Games"),
                      p("This section displays the top games based on user input and visual insights.")
               )
             ),
             sidebarLayout(
               sidebarPanel(
                 sliderInput("top_games_count", "Number of Top Games to Display:",
                             min = 1, max = 50, value = 10),
                 selectInput("y_axis_metric", "Y-axis Metric:",
                             choices = c("Price", "Score"))
               ),
               mainPanel(
                 DTOutput("top_game_table"),
                 plotOutput("top_games_barplot")
               )
             )
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Clean and prepare the data once
  clean_data <- reactive({
    data <- game_dataset
    
    # Clean the 'Number.of.Votes' column (remove commas and convert to numeric)
    data$Number.of.Votes <- as.numeric(gsub(",", "", data$Number.of.Votes))
    
    # Clean the 'Price' column (remove dollar signs and convert to numeric, handle "Free" as 0)
    data$Price <- gsub("\\$", "", data$Price)  # Remove dollar signs
    data$Price <- ifelse(data$Price == "Free", 0, data$Price)  # Handle "Free" games as 0
    data$Price <- as.numeric(data$Price)  # Convert to numeric
    
    # Convert 'Release.Date' to Date format
    data$Release.Date <- as.Date(data$Release.Date, format = "%d %b %Y")
    
    return(data)
  })
  
  # Render total games in the 'Overview' tab
  output$total_games <- renderText({
    nrow(clean_data())
  })
  
  # Render average score in the 'Overview' tab
  output$avg_score <- renderText({
    mean(as.numeric(clean_data()$Score), na.rm = TRUE)
  })
  
  # Render average number of votes in the 'Overview' tab
  output$avg_votes <- renderText({
    mean(clean_data()$Number.of.Votes, na.rm = TRUE)
  })
  
  # plot for the Overview tab to show a box plot of game scores
  output$score_distribution_plot <- renderPlot({
    # Ensure the score column is numeric before plotting
    score_data <- as.numeric(clean_data()$Score)
    
    ggplot(data.frame(Score = score_data), aes(y = Score)) +
      geom_boxplot(fill = "steelblue", color = "black") +
      labs(title = "Box Plot of Game Scores", y = "Score", x = "") +
      theme_minimal()
  })
  
  
  # Reactive expression to filter the data based on user inputs
  filtered_data <- reactive({
    data <- clean_data()
    
    # Filter by number of votes
    data <- data %>%
      filter(Number.of.Votes >= input$num_votes)
    
    # Filter by release date range
    data <- data %>%
      filter(Release.Date >= input$release_date[1] & Release.Date <= input$release_date[2])
    
    # Filter by title search (case-insensitive)
    data <- data %>%
      filter(grepl(input$search_title, Titles, ignore.case = TRUE))
    
    # Filter by player rating if specified
    if (length(input$player_rating) > 0) {
      data <- data %>%
        filter(Player.Ratings %in% input$player_rating)
    }
    
    # Filter by price range
    data <- data %>%
      filter(Price >= input$price_range[1] & Price <= input$price_range[2])
    
    # Sort by selected column
    if (input$sort_by == "Rank") {
      data <- data %>%
        arrange(as.numeric(Ranks))  # Ensure Rank is treated as numeric
    } else if (input$sort_by == "Score") {
      data <- data %>%
        arrange(desc(as.numeric(Score)))  # Ensure Score is numeric
    } else if (input$sort_by == "Release Date") {
      data <- data %>%
        arrange(Release.Date)  # Sort by Date column
    } else if (input$sort_by == "Price") {
      data <- data %>%
        arrange(Price)  # Sort by Price (numeric)
    }
    
    return(data)
  })
  
  # Render the filtered data as a datatable in the 'Search & Filter' tab
  output$game_table <- renderDT({
    data <- filtered_data()
    datatable(
      data,
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE,
      escape = FALSE
    )
  })
  
  # Render a scatter plot of votes vs. price in the 'Search & Filter' tab
  output$votes_vs_price_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = Price, y = Number.of.Votes)) +
      geom_point(color = "steelblue") +
      labs(title = "Number of Votes vs. Price", x = "Price ($)", y = "Number of Votes") +
      theme_minimal()
  })
  
  # Render the selected number of top games in the 'Top Games' tab
  output$top_game_table <- renderDT({
    top_games_data <- clean_data() %>%
      arrange(as.numeric(Ranks)) %>%
      head(input$top_games_count)  # Display the top N games based on the slider
    
    datatable(
      top_games_data,
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE,
      escape = FALSE
    )
  })
  
  # Render a bar plot for the top games in the 'Top Games' tab
  output$top_games_barplot <- renderPlot({
    top_data <- clean_data() %>%
      arrange(as.numeric(Ranks)) %>%
      head(input$top_games_count)
    
    y_metric <- input$y_axis_metric
    
    ggplot(top_data, aes_string(x = "Titles", y = y_metric)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(title = paste("Top", input$top_games_count, "Games by", y_metric),
           x = "Game Titles", y = y_metric) +
      theme_minimal()
  })
}

# Run the app
shinyApp(ui, server)