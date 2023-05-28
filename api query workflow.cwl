cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["Rscript", "gene_info.R"]
requirements:
  DockerRequirement:
    dockerPull: r-base
  InitialWorkDirRequirement:
    listing:
      - entryname: "gene_info.R"
        entry: |
          args <- commandArgs(trailingOnly = TRUE)

disease_id <- args[1]
output_file <- args[2]

# API calls and processing
api_host <- "https://www.disgenet.org/api"
api_key <- "insert your API key "
authorization_headers <- c(Authorization=paste("Bearer ",api_key, sep=""))

disease_api <- httr::GET(paste(api_host, "/gda/disease/", disease_id, sep = ""), httr::add_headers(.headers = authorization_headers))
disease_data <- httr::content(disease_api, "text") %>% jsonlite::fromJSON(flatten = TRUE)

genes <- disease_data$geneid

# get gene data
gene_data <- list()
for (i in seq_along(genes)) {
  gene_api <- httr::GET(paste(api_host, "/gene/", genes[[i]], sep = ""), httr::add_headers(.headers = authorization_headers))
  gene_data[[i]] <- httr::content(gene_api, "parsed")
}

# Combine all gene data into a single data frame
gene_df <- dplyr::bind_rows(gene_data)

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
ppis_api <- httr::GET("https://string-db.org/api/tsv/network", query = query_list)
ppis_data <- read.table(text = httr::content(ppis_api, "text"), header = TRUE, sep = "\t")

# Combine and save as CSV
all_data <- list(gene_df = gene_df, ppis_data = ppis_data)
write.csv(all_data, output_file, row.names = FALSE)


inputs:
  disease_id:
    type: string
    inputBinding:
      position: 1
  output_file:
    type: string
    inputBinding:
      position: 2

outputs:
  result_csv:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
