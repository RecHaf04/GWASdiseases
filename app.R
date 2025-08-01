# app.R - Final Caching Version

# --- 1. LOAD PACKAGES ---
library(shiny)
library(bslib)
library(dplyr)
library(DT)
library(shinycssloaders)
library(httr)
library(jsonlite)
library(htmlwidgets)


dataset_catalog <- list(
  list(id = "staph_aureus", trait = "Staph Aureus"),
  list(id = "staphylococcus", trait = "Staphylococcus"),
  list(id = "escherichia_coli", trait = "Escherichia Coli"),
  list(id = "group_a_streptococcus", trait = "Group A Streptococcus"),
  list(id = "group_b_streptococcus", trait = "Group B Streptococcus"),
  list(id = "streptococcus", trait = "Streptococcus"),
  list(id = "mycobacterium_tuberculosis", trait = "Mycobacterium Tuberculosis"),
  list(id = "mycobacteria", trait = "Mycobacteria"),
  list(id = "neisseria_gonorrhea", trait = "Neisseria Gonorrhea"),
  list(id = "neisseria", trait = "Neisseria"),
  list(id = "H_pylori", trait = "H. pylori"),
  list(id = "clostridium_difficile", trait = "Clostridium Difficile"),
  list(id = "clostridium", trait = "Clostridium"),
  list(id = "chlamydia_trachomatis", trait = "Chlamydia Trachomatis"),
  list(id = "chlamydia", trait = "Chlamydia"),
  list(id = "treponema_pallidum", trait = "Treponema Pallidum (Syphilis)"),
  list(id = "treponema", trait = "Treponema"),
  list(id = "lyme_disease", trait = "Lyme Disease"),
  list(id = "borrelia", trait = "Borrelia"),
  list(id = "enterovirus", trait = "Enterovirus"),
  list(id = "herpes_simplex", trait = "Herpes Simplex"),
  list(id = "varicella_chickenpox", trait = "Varicella (Chickenpox)"),
  list(id = "herpes_zoster", trait = "Herpes Zoster"),
  list(id = "varicella_zoster", trait = "Varicella Zoster Virus"),
  list(id = "infectious_mono", trait = "Infectious Mononucleosis"),
  list(id = "cytomegalovirus", trait = "Cytomegalovirus (CMV)"),
  list(id = "herpesvirus", trait = "Herpesvirus"),
  list(id = "hepatitis_a", trait = "Hepatitis A"),
  list(id = "hepatitis_b_with_delta", trait = "Hepatitis B with Delta"),
  list(id = "hepatitis_b", trait = "Hepatitis B"),
  list(id = "chronic_hepatitis_c", trait = "Chronic Hepatitis C"),
  list(id = "acute_hepatitis_c", trait = "Acute Hepatitis C"),
  list(id = "hepatitis_c", trait = "Hepatitis C"),
  list(id = "hepatovirus", trait = "Hepatovirus"),
  list(id = "molluscum_cont", trait = "Molluscum Contagiosum"),
  list(id = "poxvirus", trait = "Poxvirus"),
  list(id = "plantar_wart", trait = "Plantar Wart"),
  list(id = "anogenital_warts", trait = "Anogenital Warts"),
  list(id = "hpv", trait = "Human Papillomavirus"),
  list(id = "hiv", trait = "Human Immunodeficiency Virus"),
  list(id = "retrovirus", trait = "Retrovirus"),
  list(id = "pneumo", trait = "Pneumoviridae"),
  list(id = "cov2", trait = "Sars-CoV-2"),
  list(id = "corona", trait = "Coronavirus"),
  list(id = "influenza", trait = "Influenza Virus"),
  list(id = "other_viral", trait = "Other Specified Viral Infections"),
  list(id = "candidiasis", trait = "Candidiasis"),
  list(id = "aspergillosis", trait = "Aspergillosis"),
  list(id = "pneumocystosis", trait = "Pneumocystosis"),
  list(id = "trichomoniasis", trait = "Trichomoniasis"),
  list(id = "toxoplasmosis", trait = "Toxoplasmosis"),
  list(id = "giardiasis", trait = "Giardiasis"),
  list(id = "parasites", trait = "Parasites"),
  list(id = "pediculosis", trait = "Pediculosis"),
  list(id = "scabies", trait = "Scabies"),
  list(id = "pediculosis_acarisis_other", trait = "Pediculosis, Acariasis, Other"),
  list(id = "std", trait = "Sexually Transmitted Disease"),
  list(id = "bacterial_infections", trait = "Bacterial Infections"),
  list(id = "viral_infections", trait = "Viral Infections"),
  list(id = "fungal_infections", trait = "Fungal Infections"),
  list(id = "infections", trait = "Infections"),
  list(id = "gangrene", trait = "Gangrene"),
  list(id = "systemic_inflammatory_response", trait = "Systemic Inflammatory Response"),
  list(id = "sepsis", trait = "Sepsis"),
  list(id = "bacteremia", trait = "Bacteremia"),
  list(id = "bacteremia_sepsis_sirs", trait = "Bacteremia, Sepsis, and SIRS"),
  list(id = "mrsa", trait = "Methicillin-resistant Staphylococcus aureus"),
  list(id = "beta_lactam_resistance", trait = "Resistance to Beta-lactam Antibiotics"),
  list(id = "drug_resistance", trait = "Drug Resistant Microorganisms")
)
chr_map <- readRDS("chr_map.rds")

# --- 3. UI ---
ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  title = "GWAS Viewer",
  sidebar = sidebar(
    selectInput("study_selector", h4("Select a Study"),
                choices = setNames(sapply(dataset_catalog, `[[`, "id"), sapply(dataset_catalog, `[[`, "trait"))),
    
    hr(),
    h4("Cross-Phenotype Search"),
    textInput("chr_search", "Chromosome:", placeholder = "e.g., 1 or X"),
    numericInput("pos_search", "Position (HG38):", value = NULL, min = 0),
    actionButton("search_snp_button", "Search Location", class = "btn-success w-100"),
    
  navset_card_tab(
    id = "main_tabs",
    nav_panel("Manhattan Plot", 
              withSpinner(imageOutput("manhattan_plot", height = "auto", click = "manhattan_click")),
              hr(),
              h4("Significant SNPs (P < 1e-5) in Clicked Region"),
              withSpinner(DT::dataTableOutput("peak_info_table"))
    ),
    nav_panel("QQ Plot", withSpinner(imageOutput("qq_plot", height = "auto"))),
    nav_panel("Summary Data", card(
      card_header("Top Significant Hits"),
      htmlOutput("summary_download_link"),
      withSpinner(DT::dataTableOutput("summary_table"))
    )),
    nav_panel("Cross-Phenotype Search", card(
      card_header("Results for Searched SNP"), withSpinner(DT::dataTableOutput("cross_pheno_table")),
      downloadButton("download_cross_pheno", "Download Results", class = "btn-success mt-3")
    )),
    nav_panel("Citations & Data",
              h4("Data Attribution"),
              p("If you use data or images from this tool, please cite..."))
  )
)
# --- 4. SERVER ---
server <- function(input, output, session) {
  API_BASE_URL <- "https://rstudio-connect.hpc.mssm.edu/content/10224b5c-2e87-40ca-8125-ccceeb957d77/"
  chr_map <- readRDS("chr_map.rds")
  
  
  output$manhattan_plot <- renderImage({
    req(input$study_selector)
    list(src = file.path("www", paste0(input$study_selector, ".png")),
         contentType = 'image/png', width = "100%", height = "auto") 
  }, deleteFile = FALSE)
  
  output$qq_plot <- renderImage({
    req(input$study_selector)
    list(src = file.path("www", paste0("qq_", input$study_selector, ".png")),
         contentType = 'image/png', width = "100%", height = "auto")
  }, deleteFile = FALSE)
  
  
  clicked_snp_data <- eventReactive(input$manhattan_click, {
    req(input$manhattan_click)
    clicked_bp_cum <- input$manhattan_click$x
    
    clicked_chr_info <- chr_map %>%
      filter(total <= clicked_bp_cum) %>%
      filter(Chr_numeric == max(Chr_numeric))
    clicked_chr <- clicked_chr_info$Chromosome
    real_pos <- round(clicked_bp_cum - clicked_chr_info$total)
    
    api_url <- paste0(API_BASE_URL, "phewas?chromosome=", clicked_chr, "&position=", real_pos)
    
    tryCatch({
      fromJSON(content(httr::GET(api_url, httr::verbose()), "text", encoding = "UTF-8"))
    }, error = function(e) {
      data.frame(Status = "Could not get click results from API.")
    })
  })
  
  output$peak_info_table <- DT::renderDataTable({
    datatable(clicked_snp_data(), options = list(pageLength = 5))
  })
  
  summary_data <- reactive({
    req(input$study_selector)
    api_url <- paste0(API_BASE_URL, "summary_data?phenoId=", input$study_selector)
    tryCatch({
      fromJSON(content(httr::GET(api_url, httr::verbose()), "text", encoding = "UTF-8"))
    }, error = function(e) {
      data.frame(Status = "Could not retrieve data from API.")
    })
  })
  output$summary_table <- DT::renderDataTable({ datatable(summary_data()) })
  
  output$summary_download_link <- renderUI({
    a("Download Full Summary Statistics Here", href = "YOUR_LINK_HERE", target = "_blank")
  })
  
  cross_pheno_results <- eventReactive(input$search_snp_button, {
    req(input$search_chr, input$search_pos)
    api_url <- paste0(API_BASE_URL, "phewas?chromosome=", input$search_chr, "&position=", input$search_pos)
    tryCatch({
      fromJSON(content(httr::GET(api_url, httr::verbose()), "text", encoding = "UTF-8"))
    }, error = function(e) {
      data.frame(Status = "Could not retrieve data from API.")
    })
  })
  
  output$cross_pheno_table <- DT::renderDataTable({
    datatable(cross_pheno_results(), options = list(pageLength = 10))
  })
  
  output$download_cross_pheno <- downloadHandler(
    filename = function() {
      paste0("cross-pheno-results-chr", input$search_chr, "_", input$search_pos, ".csv")
    },
    content = function(file) {
      write.csv(cross_pheno_results(), file, row.names = FALSE)
    }
  )
  # --- 5. RUN ---
}
shinyApp(ui, server)
