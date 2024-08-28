# CSCI-5461-Homework-3

In this homework, you will analyze a recently published systematically mapped human protein-
protein interaction dataset to understand some basic characteristics of the network and how they
relate to biological function. The data files posted below were obtained from the following
publication:
Luck, K., Kim, D., Lambourne, L. et al. A reference map of the human binary protein
interactome. Nature (2020). https://doi.org/10.1038/s41586-020-2188-x

## Data files:
- `HURI.hgnc.csv`: this is the proteome-scale map of the human binary interactome by Luck et
al. In this file, each row represents a pair of interacting proteins, and the interaction is undirected.
- `Lit_degrees.csv`: this file includes the interaction degree of each protein in a literature
curated binary interaction network.

## 1. Understanding the data: 
Briefly describe the experimental approach used to generate the data HURI.hgnc.csv you are about to analyze. 
- Are there any caveats associated with the approach?
- How many protein pairs were screened to generate this data?
- How many total interactions were reported?

> This paper expanded the ORFeome collection to include ORFs for approximately 90% of the protein-coding genes in the human genome, and utilized three different versions of the yeast two-hybrid (Y2H) technique to screen this ORFeome collection nine times for the detection of binary protein-protein interactions (PPIs). After identifying the potential interactions using Y2H, the interactions are further validated using orthogonal assays, which can be used to confirm the findings of the Y2H screening and increase confidence in the identified interactions. This approach screened 17,500 X 17,500 proteins and generated a dataset that consists of about 53,000 PPIs. 

> One of the major caveats associated with the Y2H is its potential for false positives and negatives. For example, Y2H assay can only detect the interactions that occur within the nucleus, so it will miss membrane-bound proteins. Another common problem is the autoactivation of Y2H inducible reporter genes. It happens when one of the proteins activates transcription of the Y2H reporter genes independently of any PPI, and this can increase the false positives.

## 2. Analysis of interaction degree:
- (a) Measure the degree of each protein with at least 1 interaction in the network (exclude self-
interactions). Plot the degree distribution of the protein-protein interaction network (a histogram
is fine).

![Degree_distribution](https://github.com/user-attachments/assets/1b105521-d60c-4a15-b893-67d7b0abce17)

> The degree distribution of this network is highly skewed, indicating many proteins with only a small number of interactions, which is commonly observed in the scale-free network.

- (b) What is the highest degree protein and how many interactions does it have? Describe what is
currently known about the functional role of this protein (you can use http://www.genecards.org
to learn about gene function).

> The protein encoded by MEOX2 (Mesenchyme Homeo Box 2) has the highest degree, which is 495. MEOX2 encoded protein plays a role in the regulation of vertebrate limb myogenesis. It is involved in regulating the differentiation of mesodermal cells into various cell types, including smooth muscle cells, osteoblasts, and chondrocytes. Additionally, MEOX2 has been implicated in angiogenesis, the process of forming new blood vessels, and in the development of the cardiovascular system. Diseases associated with MEOX2 include Female Stress Incontinence and Alzheimer’s Disease.
