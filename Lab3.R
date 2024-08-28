# 1. Load the datasets
ppi <- read.csv(file = "HURI.hgnc.csv", header = T)
degree <- read.csv(file = "Lit_degrees.csv", header = T, sep = "")

##############################################################################

# 2. Analysis of interaction degree
## a. Degree distribution of the PPI network

## Get the unique proteins in each column of proteome dataset
p1 <- unique(ppi$MIF)
p2 <- unique(ppi$MIF.1)

## Calculate the degree of each protein in first column. Find all the neighbors for each protein. 

### Generate a array contains the number of unique proteins of the first column
n <- array(dim = length(p1))

### Create a empty list that will store all the paris of protein-neighbors
neighbor_list_1 <- list()

### Calculate the number of interactions (degrees) for each protein, excluding self-interactions, and store the value in n. Then, store all the neighbors in a list with the protein name as the key.
for (i in 1:length(p1)) {
  ### for each unique protein, extract this protein with all its neighbors:
  tmp1 <- ppi[ppi$MIF == p1[i], ]
  ### exclude self-interaction:
  tmp2 <- tmp1[tmp1$MIF.1 != p1[i],]
  ### calculate the number of neighbors:
  n[i] <- nrow(tmp2)
  ### use protein's name as key, and save all its neighbors in the list: 
  neighbor_list_1[[p1[i]]] <- tmp2$MIF.1
}

### Create a data frame of protein and corresponding degree for the first column:
first_column_interactions <- data.frame("protein" = p1, "degree" = n)

### Repeat the same steps for the second column:
n <- array(dim = length(p2))
neighbor_list_2 <- list()
for (i in 1:length(p2)) {
  tmp1 <- ppi[ppi$MIF.1 == p2[i], ]
  tmp2 <- tmp1[tmp1$MIF != p2[i],]
  n[i] <- nrow(tmp2)
  neighbor_list_2[[p2[i]]] <- tmp2$MIF
}

second_column_interactions <- data.frame("protein" = p2, "degree" = n)

### Create a variable that contains all the unique protein in both columns:
unique_p <- unique(c(ppi$MIF, ppi$MIF.1))

### Create a list which will store all PPIs from both sides of protein:
neighbor_list_all <- list()
### Take the union of neighbors of same protein from both sides, and store that union of neighbors in the list with protein's name as key:  
for (i in 1:length(unique_p)) {
  neighbor_list_all[[unique_p[i]]] <- union(neighbor_list_1[[unique_p[i]]], neighbor_list_2[[unique_p[i]]])
}

### Calculate the total number of neighbors/interactions (degree) of each protein, and store them in a data frame:
num_of_interaction <- data.frame(lengths(neighbor_list_all))
names(num_of_interaction) <- c("degree")

### Create a histogram for degree distribution: 
# pdf("Degree_distribution.pdf", height = 6, width = 8)
hist(num_of_interaction$degree, breaks = 100, xlab = "Degree", main = "Degree distributions", col = "#2b59aa")
# dev.off()

## b. The highest degree protein
degree_ordered <- num_of_interaction[order(num_of_interaction$degree, decreasing = T), , drop = F]
cat("The protein ", row.names(degree_ordered)[1], " has the highest degree, which is ", degree_ordered[1, ], ".", sep = "")

##############################################################################

# 3. Analysis of clustering coefficient (30 points):
## (b) Compute clustering coefficients for every protein in this network. For simplicity, exclude self-interactions in the network. To present your results, plot the clustering coefficient vs. the node degree for all proteins.

### Create a data frame with the first column indicating all the unique proteins (n=8228), and the second column storing corresponding clustering coefficient: 
clustering_coef <- data.frame(matrix(data = 0, nrow = length(unique_p), ncol = 2))
clustering_coef[, 1] = row.names(num_of_interaction)
names(clustering_coef) = c("Protein", "clustering_coefficient")

### Calculate the clustering coefficient for each protein: 
for (i in 1:length(unique_p)) {
  if (num_of_interaction[i, 1] == 0 | num_of_interaction[i, 1] == 1) {
    clustering_coef[i, 2] = 0
  } else {
    sum <- 0
    for (j in 1:length(neighbor_list_all[[row.names(num_of_interaction)[i]]])) {
      num <- length(intersect(neighbor_list_all[[neighbor_list_all[[row.names(num_of_interaction)[i]]][j]]], neighbor_list_all[[row.names(num_of_interaction)[i]]]))
      sum <- sum + num
      clustering_coef[i, 2] = sum/((num_of_interaction[i, 1])*(num_of_interaction[i, 1]-1))
    } 
  }
}

## I also used a package "igraph" to obtain the clustering coefficient to confirm my calculation. 

# install.packages("igraph")
library(igraph)

set.seed(1)
g <- graph_from_data_frame(ppi, directed = F)
cc <- data.frame(transitivity(g, type="localundirected"))

## The coefficients calculated by the igraph package align with my calculation. 

### Merge the clustering coefficients and degree together in one data frame:
num_of_interaction$Protein <- row.names(num_of_interaction)
coefficient_degree <- merge(num_of_interaction, clustering_coef, by = "Protein")

### Create a scatter plot: 
# pdf("coefficient vs. degree.pdf", width = 8, height = 6)
plot(x = coefficient_degree$clustering_coefficient, 
     y = coefficient_degree$degree, 
     pch = 20, 
     cex = 0.5, 
     xlab = "Clustering Coefficient",
     ylab = "Degree")
# dev.off()

## (c) Let’s investigate the properties of two specific proteins, LSM6 and MAPK9. Report the number of interaction partners for both of these proteins and the clustering coefficients. Also, list the actual interacting proteins with each of them. 

### Clustering coefficient and neighbors of LSM6
coefficient_degree[coefficient_degree$Protein == "LSM6", ]
neighbor_list_all[["LSM6"]]
### Clustering coefficient and neighbors of MAPK9
coefficient_degree[coefficient_degree$Protein == "MAPK9", ]
neighbor_list_all[["MAPK9"]]

##############################################################################

## 4. Comparison of systematically mapped and literature curated interaction networks. 

## (a) What is the Pearson correlation between interaction degrees in the systematically mapped network and in the literature-curated network?

### Combine the degree of systematically mapped network (num_of_interaction) and literature-curated network (degree), excluding proteins that are not commonly present in both networks.
merged_degree <- merge(num_of_interaction, degree, by = "Protein")
colnames(merged_degree) <- c("Protein", "mapped_network", "literature_curated")

### Exclude proteins in either network have 0 interaction. 
merged_degree_no_zero <- merged_degree[merged_degree$mapped_network != 0 & merged_degree$literature_curated != 0, ]

### Calculate the correlation coefficient. 
cor(merged_degree_no_zero$mapped_network, merged_degree_no_zero$literature_curated)

### Calculate how many proteins in the systematically mapped network have higher degree than those in the literature-curated network. 
sum(merged_degree_no_zero$mapped_network > merged_degree_no_zero$literature_curated)

## (b) Find an example of a protein with more than 10 interactions in the Luck et al. network, a clustering coefficient of greater than 0.2, and no interactions in the literature curated network.

### Combine the degree and clustering coefficient of systematically mapped network and the degree of literature curated network, excluding proteins that are not commonly present in both networks.
merged_3 <- merge(merged_degree, clustering_coef, by = "Protein")

### Select proteins that qualify all the criteria. 
selected_proteins <- merged_3[merged_3$mapped_network>10 & merged_3$clustering_coefficient > 0.2 & merged_3$literature_curated == 0, ]
selected_proteins <- data.frame(selected_proteins)
### I selected RBM3 protein to discuss its function. 
neighbor_list_all[["RBM3"]]
