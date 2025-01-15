library(shinydashboard)
library(shinyWidgets)

css <- htmltools::HTML(
    "#summarytable > .dataTables_wrapper.no-footer > .dataTables_scroll > .dataTables_scrollBody {
        transform:rotateX(180deg);
    }
    #summarytable > .dataTables_wrapper.no-footer > .dataTables_scroll > .dataTables_scrollBody table{
        transform:rotateX(180deg);
    }"
)

summary_dt = fread(file="./shiny-data/summary.csv")

ui = shinydashboard::dashboardPage(
  header = shinydashboard::dashboardHeader(title="Shiny demo"),
  sidebar = shinydashboard::dashboardSidebar(
    br(),
    br(),
    sidebarMenu(id="sidebarmenu",
      menuItem("Introduction", tabName="introduction"),
      menuItem("Summary table", tabName="table"),
      menuItem("Stock-recruit relationship (SRR)", tabName="srr_plots"),
      menuItem("Natural mortality (M)", tabName="natM_plots")
    ),

    # Only show these on the plotting tabs - not Introduction and Summary table tabs
    conditionalPanel(condition="input.sidebarmenu == 'srr_plots'",
      # srr-show-est
      switchInput(
      inputId = "srr_show_est",  
      label = "Show estimated recruitment",
      value=TRUE,
      onLabel = "TRUE",
      offLabel = "FALSE",
      onStatus = "success", 
      offStatus = "danger"),
      # srr-est-type
      awesomeRadio(
      inputId = "srr_est_type",  
      label = "Plot estimated recruitment as:",
      choices=c("Path","Points","Both"),
      selected = "Path")
    ),
    conditionalPanel(condition="input.sidebarmenu == 'natM_plots'",
      # natM_dropdown
      pickerInput(
        inputId = "natM_dropdown", 
        label = "Select a model:", 
        choices = summary_dt$model_name, 
        options = list(
          `actions-box` = TRUE,
          `deselect-all-text` = "None...",
          `select-all-text` = "Yeah, all !",
          `none-selected-text` = "zero"
        ), 
        multiple = TRUE
      ),
      # natM-plot-type
      awesomeRadio(
      inputId = "natM_plot_type",  
      label = "Plot as:",
      choices=c("Path","Points","Both"),
      selected = "Path")
    ),
    br(),
    br(),
    tags$footer(
      div(style="text-align:center",
        tags$p("version 0.0.1"),
        tags$p(paste("Copyright", format(Sys.time(),"%Y"), "NOAA Fisheries, PIFSC Stock Assessment Group"))
      )
    )
  ), # End of sidebar

  body = shinydashboard::dashboardBody(
    tags$head(tags$style(HTML('.wrapper {height: auto !important; position:relative; overflow-x:hidden; overflow-y:hidden}') )),
    tags$head(tags$style(css)),
    # Start of main tab stuff
    tabItems(
      # **** Introduction ****
      tabItem(tabName="introduction", h2("Introduction"),
        fluidRow(column(12, includeMarkdown("./introduction_index.md")))
      ), # End of introduction tab

      # **** Summary table ****
      tabItem(tabName="table", h2("Summary table"),
        fluidRow(box(title="Model metrics", collapsed=FALSE, solidHeader=TRUE, collapsible=TRUE, status="primary", width=12,
         DT::dataTableOutput("summarytable")))
      ), # End of table tab

      # **** Stock recruitment plots ****
      tabItem(tabName="srr_plots", h2("Stock-recruitment plots"),
        fluidRow(
          box(title="Stock-recruitment relationship (SRR)", solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, status="primary", width=12,
            p("Select at least one model."),
            plotOutput("srr_plots", height="auto"))
        )
      ), # End of srr_plots tab

      # **** Natural mortality recruitment plots ****
      tabItem(tabName="natM_plots", h2("Natural mortality plots"),
        fluidRow(
          box(title="Natural mortality-at-age (M)", solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, status="primary", width=12,
            p("Select at least one model."),
            plotOutput("natM_plots", height="auto"))
        )
      ) # End of natM_plots tab
    ) # End of tabItems
  ) # End of dashboardBody
)
