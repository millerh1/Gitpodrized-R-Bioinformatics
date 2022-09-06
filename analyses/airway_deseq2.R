library(DESeq2)
library(tidyverse)
library(airway)
library(EnsDb.Hsapiens.v86)

data("airway")

geneLst <- DESeqDataSet(airway, design = ~ dex) %>%  # Sets up DESeq dataset
  DESeq() %>%  # Run analysis
  results(contrast = c("dex", "trt", "untrt")) %>%  # Collect results
  as.data.frame() %>%  # Convert to dataframe
  rownames_to_column(var = "GENEID") %>%  # Genes are now a column
  dplyr::filter(padj < .05) %>%  # Filter for significant results
  mutate(result = case_when(  # Labels over-expressed vs under-expressed genes
    log2FoldChange > 0 ~ "Over-expressed", 
    TRUE ~ "Under-expressed"
  )) %>%
  inner_join(  # Add in the gene symbols
    AnnotationDbi::select(
      EnsDb.Hsapiens.v86,
      keys=keys(EnsDb.Hsapiens.v86),
      columns = "SYMBOL"
    ),
    by = "GENEID"
  ) %>%
  group_by(result) %>%  # Group by result column
  {setNames(group_split(.), group_keys(.)[[1]])} %>%  # Split tibble into list by group with names
  lapply(pull, var = SYMBOL)  # Final conversion to named list of gene vectors

# Display number of genes in each group
lapply(geneLst, length)

# Enrichment analysis
resEnrich <- sapply(names(geneLst), function(groupNow) {
  genesNow <- geneLst[[groupNow]]
  response <- httr::POST(  # Post request to enrichr based on https://maayanlab.cloud/Enrichr/help#api&q=1
    url = 'https://maayanlab.cloud/Enrichr/addList', 
    body = list(
      'list' = paste0(genesNow, collapse = "\n"),
      'description' = groupNow
    )
  )
  response <- jsonlite::fromJSON(httr::content(response, as = "text"))  # Collect response
  paste0("https://maayanlab.cloud/Enrichr/enrich?dataset=",  # Create permalink
                      response$shortId[1])
  
}) %>% setNames(nm = names(geneLst))
print(resEnrich)
