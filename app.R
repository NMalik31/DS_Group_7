library(shiny)
library(DT)
library(dplyr)

# Define the UI for the app
ui <- fluidPage(
  titlePanel("Top 250 Highest Rated Games on Steam"),
  
  # Create tabs for different views and functionalities
  tabsetPanel(
    tabPanel("Overview",
             fluidRow(
               column(12, 
                      h3("Overview of the Top 250 Steam Games"),
                      p("This section gives you a summary of the data, including the number of games, and average score.")
               )
             ),
             fluidRow(
               column(6, 
                      h4("Total Games in Dataset:"),
                      verbatimTextOutput("total_games")
               ),
               column(6, 
                      h4("Average Score of Games:"),
                      verbatimTextOutput("avg_score")
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
                             max = max(as.numeric(gsub(",", "", game_dataset$`Number.of.Votes`)), na.rm = TRUE),
                             value = 0),
                 dateRangeInput("release_date", "Release Date Range:",
                                start = min(as.Date(game_dataset$`Release.Date`, format = "%d %b %Y"), na.rm = TRUE),
                                end = max(as.Date(game_dataset$`Release.Date`, format = "%d %b %Y"), na.rm = TRUE)),
                 selectInput("player_rating", "Player Rating:",
                             choices = unique(game_dataset$`Player.Ratings`), multiple = TRUE),
                 sliderInput("price_range", "Price Range:",
                             min = 0, max = 100, value = c(0, 100), pre = "$"),
                 textInput("search_title", "Search by Title:", "")
               ),
               
               mainPanel(
                 DTOutput("game_table")
               )
             )
    ),
    
    tabPanel("Top Games",
             fluidRow(
               column(12, 
                      h3("Top Games"),
                      p("This section displays the top games based on user input.")
               )
             ),
             sidebarLayout(
               sidebarPanel(
                 sliderInput("top_games_count", "Number of Top Games to Display:",
                             min = 1, max = 50, value = 10)
               ),
               mainPanel(
                 DTOutput("top_game_table")
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
    data$`Number.of.Votes` <- as.numeric(gsub(",", "", data$`Number.of.Votes`))
    
    # Clean the 'Price' column (remove dollar signs and convert to numeric, handle "Free" as 0)
    data$`Price` <- gsub("\\$", "", data$`Price`)  # Remove dollar signs
    data$`Price` <- ifelse(data$`Price` == "Free", 0, data$`Price`)  # Handle "Free" games as 0
    data$`Price` <- as.numeric(data$`Price`)  # Convert to numeric
    
    # Convert 'Release.Date' to Date format
    data$`Release.Date` <- as.Date(data$`Release.Date`, format = "%d %b %Y")
    
    return(data)
  })
  
  # Reactive expression to clean and filter the data based on user inputs
  filtered_data <- reactive({
    data <- clean_data()
    
    # Filter by number of votes
    data <- data %>%
      filter(`Number.of.Votes` >= input$num_votes)
    
    # Filter by release date range
    data <- data %>%
      filter(`Release.Date` >= input$release_date[1] & `Release.Date` <= input$release_date[2])
    
    # Filter by title search (case-insensitive)
    data <- data %>%
      filter(grepl(input$search_title, Titles, ignore.case = TRUE))
    
    # Filter by player rating if specified
    if (length(input$player_rating) > 0) {
      data <- data %>%
        filter(`Player.Ratings` %in% input$player_rating)
    }
    
    # Filter by price range
    data <- data %>%
      filter(`Price` >= input$price_range[1] & `Price` <= input$price_range[2])
    
    # Sort by selected column
    if (input$sort_by == "Rank") {
      data <- data %>%
        arrange(as.numeric(Ranks))  # Ensure Rank is treated as numeric
    } else if (input$sort_by == "Score") {
      data <- data %>%
        arrange(as.numeric(Score))  # Ensure Score is numeric
    } else if (input$sort_by == "Release Date") {
      data <- data %>%
        arrange(`Release.Date`)  # Sort by Date column
    } else if (input$sort_by == "Price") {
      data <- data %>%
        arrange(Price)  # Sort by Price (numeric)
    }
    
    return(data)
  })
  
  # Render the filtered data as a datatable in the 'Search & Filter' tab
  output$game_table <- renderDT({
    # Get the filtered data
    data <- filtered_data()
    
    # Create the datatable
    datatable(
      data,
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE,
      escape = FALSE
    )
  })
  
  # Display total games in the 'Overview' tab
  output$total_games <- renderText({
    nrow(game_dataset)
  })
  
  # Display average score in the 'Overview' tab
  output$avg_score <- renderText({
    mean(as.numeric(game_dataset$Score), na.rm = TRUE)
  })
  
  # Render the selected number of top games in the 'Top Games' tab
  output$top_game_table <- renderDT({
    top_games_data <- game_dataset %>%
      arrange(as.numeric(Ranks)) %>%
      head(input$top_games_count)  # Display the top N games based on the slider
    
    datatable(
      top_games_data,
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE,
      escape = FALSE
    )
  })
}

# Run the app
shinyApp(ui, server)
