# trial the input disease name
input$disease_name <- "C0751122"

# triggers the submit event
observeEvent(input$submit, {
  disease_name <- input$disease_name
  
  # Assert that the disease name is correctly passed to the API call
  expect_equal(disease_name, "C0751122")
  
  # Assert that the disease data is retrieved and processed correctly
  expect_true(!is.null(desease_data))
  expect_true("geneid" %in% names(desease_data))
  expect_true(length(desease_data$geneid) > 0)
})

# test the gene data
desease_data <- list(geneid = c(1234, 5678))

# test the API calls and processing
GET <- function(url, add_headers) {
  # Assert that the correct API endpoint is called
  expect_equal(url, "https://www.disgenet.org/api/gda/disease/1234")
  
  # 
  response <- list(geneid = desease_data$geneid)
  return(response)
}

# Trigger the submit event
observeEvent(input$submit, {
  # ...
  
  # Assert that the gene data is retrieved and processed correctly
  expect_true(!is.null(gene_df))
  expect_equal(nrow(gene_df), length(desease_data$geneid))
})


# test the gene symbols
gene_symbols <- c("GENE1", "GENE2")

# test the API calls and processing
GET <- function(url, add_headers) {
  # Assert that the correct API endpoint is called
  expect_equal(url, "https://webservice.wikipathways.org/findInteractions?query=GENE1&format=json")
  
  # Return a test response
  response <- list(result = list(id = "PW1"))
  return(response)
}

# Trigger the submit event
observeEvent(input$submit, {
  # ...
  
  # Assert that the pathway data is retrieved and processed correctly
  expect_true(!is.null(dff))
  expect_equal(nrow(dff), length(gene_symbols))
})


# test the drugbank data
drugbank_data <- data.frame(drugbank_id = c("DB1", "DB2"), description = c("Description1", "Description2"))

# test the data integration steps
# ...

# test the resulting network data
network_data <- list(nodes = nodes, edges = edges)

# Trigger the submit event
observeEvent(input$submit, {
  # ...
  
  # Assert that the data integration steps are executed correctly
  expect_true(!is.null(new_df))
  expect_true(nrow(new_df) > 0)
  
  # Assert that the resulting network data is correct
  expect_true(!is.null(network_data))
  expect_true("nodes" %in% names(network_data))
  expect_true("edges" %in% names(network_data))
})



