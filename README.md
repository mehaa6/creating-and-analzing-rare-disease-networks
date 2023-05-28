# RareGenoScope Application instructions
This repository contains the R script of the application and the related files to create a rare disease network using the DisGeNET, STRING, WikiPathways, and DrugBank APIs. The script retrieves disease-related genes and their protein-protein interactions, pathways, and similar drugs based on their gene symbols. The network is then visualized using the visNetwork package in a Shiny app. It serves as a pipeline for creating and analzing rare disease networks. 

# Packages
The R script was made using version 2022.12.0+353 of RStudio. You will first need to install the following packages: 

- library(httr) Version: 1.4.5
- library(biomaRt) Version: 2.54.1
- library(jsonlite) Version: 1.8.4
- library(dplyr) Version: 1.1.1
- library(shiny) Version: 1.7.4
- library(viridis) Version: 0.6.2
- library(visNetwork) Version: 2.1.2
- library(stringdist) Version: 0.9.10 


# Other tools that are needed
Obtain an API key from DisGeNET by creating a account and getting it authorized and replace the placeholder api_key in the script. Download the DrugBank dataset in CSV format and update the path to the file in the drugbank_data variable in the Rscript. Run the code and a shiny application will open. Type the name of the disease and click submit. Makesure the first letter each word is captilized. Drugbank file was downloaded from go.drugbank.com and then sorted and converted to csv using python code. this python code can be found in the repository to sort and extract the information from the file. 

# Workflow for the R script
1) Set up the API key and authorization headers for the DisGeNET API.
2) Retrieve the disease-associated genes from the DisGeNET API.
3) Convert the JSON response to a data frame.
4) Get the gene data from DisGeNET.
5) Map the gene symbols to STRING IDs using the STRING API.
6) Query the STRING API for protein-protein interactions (PPIs) among the gene products.
7) Retrieve the pathways for each gene using the WikiPathways API.
8) Combine the pathway data into a single data frame.
9) Visualize the network using the visNetwork package in a Shiny app.
11) Add similar drugs to the network as nodes and edges.
12) Visualize the updated Disease-Gene-Drug-Network using the visNetwork package in a Shiny app.

# Instructions to use application
1) First load and download all the packages listed above. 
2) Next run the application
3) Type in the disease as it is on the DisGeNet website in the search bar of the application 
4) Click submit and wait
5) Visualise the network in Rstudio
6) Download the information you would like such as a node or edge list for export 



