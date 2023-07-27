#Rstudio version: 2022.12.0+353

library(httr) #Version: 1.4.5 
library(biomaRt) #Version: 2.54.1 
library(jsonlite) #Version: 1.8.4 
library(dplyr) #Version: 1.1.1 
library(shiny) #Version: 1.7.4
library(viridis) #Version: 0.6.2 
library(visNetwork) #Version: 2.1.2
library(stringdist) #Version: 0.9.10 


ui <- fluidPage(
  titlePanel("RareGenoScope"),
  sidebarLayout(
    sidebarPanel(
      textInput("disease_name", "Enter Disease Name:", value = ""),
      actionButton("submit", "Submit")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Network Data",
                 h4(),
                 downloadButton("download_nodes", "Download Nodes"),
                 downloadButton("download_edges", "Download Edges")),
        tabPanel( "Network Graph",
                  visNetworkOutput("network"),
                  downloadButton("download_graph", "Download Graph")
                  
        )
      )
    )
  )
)

server <- function(input, output) { 
  graph_data <- reactiveValues(nodes = NULL, edges = NULL)
  
  observeEvent(input$submit, {
    disease_name <- input$disease_name
    
    disease_name_check <- read.delim(" File directory  /disease_associations.tsv")
    
    if (!is.null(disease_name) && disease_name %in% disease_name_check$diseaseName && disease_name_check$NofGenes[disease_name_check$diseaseName == disease_name] > 0) {
      
      filtered_data <- disease_name_check[disease_name_check$diseaseName == disease_name, ]
      cat("Disease Name:", as.character(disease_name), "\n")
      
      disease_id <- filtered_data$diseaseId[1]
      
      # API calls and processing
      api_host <- "https://www.disgenet.org/api"
      api_key <- "Insert API token"
      authorization_headers <- c(Authorization=paste("Bearer ",api_key, sep=""))
      
      disease_api <- GET(paste("https://www.disgenet.org/api/gda/disease/", disease_id, sep = ""), add_headers(.headers = authorization_headers))
      
      disease_data <- content(disease_api, "text") %>% fromJSON(flatten = TRUE)
      
      
      print(disease_data)
      
      # get gene data
      genes<-disease_data$geneid
      print(genes)
      
      gene_data <- list()
      
      for (i in seq_along(genes)) {
        gene_api <- GET(paste(api_host, "/gene/", genes[[i]], sep = ""), add_headers(.headers = authorization_headers))
        gene_data[[i]] <- content(gene_api, "parsed")
      }
      
      # Combine all gene data into a single data frame
      gene_df <- bind_rows(gene_data)
      print(gene_df)
      
      
      genes=c(disease_data$geneid)
      # Get STRING IDs
      string_ids <- gene_df$symbol
      
      # Specify the species (e.g. "9606" for Homo sapiens)
      species <- "9606"
      
      # Build query list
      query_list <- list(
        identifiers = paste(string_ids, collapse = "%0d"),
        species = species,
        required_score = 100
      )
      
      # Query the API for PPIs
      ppis_api <- GET("https://string-db.org/api/tsv/network", query = query_list)
      ppis_data <- read.table(text = content(ppis_api, "text"), header = TRUE, sep = "\t")
      
      head(ppis_data)
      head(disease_data)
      
      pathway_data=list()
      #install.packages("visNetwork")
      for (i in seq_along(string_ids)) {
        print(string_ids[[i]])
        pathway_api <- GET(paste("https://webservice.wikipathways.org/findInteractions?query=", string_ids[[i]], "&format=json", sep = ""))
        wp <- content(pathway_api, "text")
        wp <- fromJSON(wp, flatten = TRUE)
        pathway_data[i] <- wp$result$id[1]
        #print (wp$result$id[1])
      }
      
      dff <- data.frame()
      
      # Iterate over the pathway_data list and add each element as a new row to the data frame
      for (i in seq_along(pathway_data)) {
        # Check if the element at index i is NULL
        if (is.null(pathway_data[[i]])) {
          print("NULL")
          # add null row
          # dff <- rbind(dff, data.frame(c(NA)))
          
        } else {
          # If it is not NULL, convert it to a data frame and add it as a new row to dff
          dff <- rbind(dff, data.frame(pathway_data[[i]]))
        }
      }
      
      # Print the resulting data frame
      print(dff)
      
      
      # Create a sample data frame with nodes and edges
      nodes <- data.frame(id = c(disease_data$gene_symbol),
                          label = c(disease_data$gene_symbol)
      )
      
      
      nodes <- distinct(nodes, id, .keep_all = TRUE)
      
      
      edges <- data.frame(from = c(ppis_data$preferredName_A, head(new_df)$gene_symbol),
                          to = c(ppis_data$preferredName_B, head(new_df)$drug_id))
      
      edges <- edges[edges$from != edges$to, ]
      
      
      
      drugbank_data<-read.csv("File directory /drugbank.csv", header = TRUE, sep = ",")
      
      disease_data$disease_name[1]
      
      # find similar drugs
      drugbank_data$Similarity <- NA
      
      # find similarity of gene name and drug description
      # create empty df with columns
      new_df <- data.frame(gene_symbol = character(),
                           drug_id = character(),
                           Similarity = numeric(),
                           stringsAsFactors = FALSE)
      
      
      for (i in seq_len(min(1L, length(desease_data$gene_symbol)))) {
        for (j in seq_along(drugbank_data$description)) {
          new_df <- rbind(new_df, data.frame(desease_data$gene_symbol[i], drugbank_data$drugbank_id[j], stringdist(desease_data$gene_symbol[i], drugbank_data$description[j], method = "jw")))
        }
      }
      
      
      # rename columns
      colnames(new_df) <- c("gene_symbol", "drug_id", "Similarity")
      new_df <- new_df[new_df$Similarity >0.99, ]
      head(new_df)
      
      head(new_df)
      # remove duplicates
      new_df <- new_df[!duplicated(new_df$drug_id), ]
      head(new_df)
      
      colors <- viridis(nrow(nodes), alpha = 0.7)
      nodes$color <- colors
      
      network_data <- list(nodes = nodes, edges = edges)
      
      
      output$network <- renderVisNetwork({
        visNetwork(network_data$nodes, network_data$edges) %>%
          visOptions(highlightNearest = TRUE, selectedBy = "label")
      })
      
      # add edges to network
      edges <- data.frame(from = c(ppis_data$preferredName_A, head(new_df)$gene_symbol),
                          to = c(ppis_data$preferredName_B, head(new_df)$drug_id)
      )
      
      nodes <- data.frame(id = c(disease_data$gene_symbol, head(new_df)$drug_id),
                          label = c(disease_data$gene_symbol, head(new_df)$drug_id)
                          
      )
      
      output$download_network <- downloadHandler(
        filename = "network.png",
        content = function(file) {
          exportNetwork(visNetwork(network_data$nodes, network_data$edges), file, "png")
        }
      )
      
      
      
      
      
      # # Save edges data frame as a CSV file
      # write.csv(edges, "edges.csv", row.names = FALSE)
      # write.csv(nodes, "nodes.csv", row.names = FALSE)
      # 
      
      
      
      # Download nodes file
      output$download_nodes <- downloadHandler(
        filename = "nodes.csv",
        content = function(file) {
          write.csv(nodes, filename, row.names = FALSE)
        }
      )
      
      
      
      # Download edges file
      output$download_edges <- downloadHandler(
        filename = "edges.csv",
        content = function(file) {
          
          ensembl <- useMart("ensembl")
          ensembl = useDataset("hsapiens_gene_ensembl", mart = ensembl)
          
          gene_symbols <- nodes$label
          
          # Map the gene symbols in the "from" column to Ensembl IDs
          results_from <- getBM(
            attributes = c("ensembl_gene_id", "hgnc_symbol"),
            filters = "hgnc_symbol",
            values = edges$from,
            mart = ensembl
          )
          
          # Map the gene symbols in the "to" column to Ensembl IDs
          results_to <- getBM(
            attributes = c("ensembl_gene_id", "hgnc_symbol"),
            filters = "hgnc_symbol",
            values = edges$to,
            mart = ensembl
          )
          
          nodes <- left_join(nodes, results, by = c("label" = "hgnc_symbol"))
          
          # Merge the Ensembl IDs with the original data frame
          edges <- edges %>%
            left_join(results_from, by = c("from" = "hgnc_symbol")) %>%
            left_join(results_to, by = c("to" = "hgnc_symbol"))
          
          determine_entity_type <- function(x) {
            if (startsWith(x, "ENSP")) {
              return("Protein")
            } else if (startsWith(x, "DB")) {
              return("Drug")
            } else {
              return("Gene")
            }
          }
          
          # Apply the function to create a new column for entity type∂ç
          edges$entitytype <- sapply(edges$to, determine_entity_type)
          edges$entitytype <- sapply(edges$from, determine_entity_type)
          
          # Apply the function to merge the Ensembl IDs with the existing column
          edges$ensembl_gene_id <- sapply(edges$ensembl_gene_id.y, select_first_ensembl_id)
          edges$ensembl_gene_id[is.na(edges$ensembl_gene_id)] <- edges$to[is.na(edges$ensembl_gene_id)]
          
          # Remove the intermediate 'ensembl_gene_id' column
          edges <- subset(edges, select = -ensembl_gene_id.y)
          
          # Find rows where both "from" and "to" values exist elsewhere in the file
          duplicate_rows <- edges[duplicated(edges$from) & duplicated(edges$to), ]
          
          # Remove duplicate rows from the original data frame
          edges <- edges[!duplicated(edges) | !edges %in% duplicate_rows, ]
          
          
          
          write.csv(edges, filename, row.names = FALSE)
          
          
        }
      )
    }
  })
}


# Run the Shiny app
shinyApp(ui = ui, server = server)






