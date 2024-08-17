file  = read.csv('D:/trial_results/filtered_barcode15.fastq_rel-abundance.tsv', sep = '\t')
#file = read.csv('D:/RESULTS_BY_ARPIT/40mfol_merged_barcode04.fastq_rel-abundance-threshold-0.0001.tsv', sep = '\t')
tru.m = read.csv('D:/RESULTS_BY_ARPIT/nanopore_zymo899b2208-d886-4419-a3cb-2b421cb5633d_nanopore_v_pc.fastq_rel-abundance.tsv', sep = '\t')
file = file[!file$abundance == 0,]

file$abundance = file$abundance * 100

file$n_n_1  = file$abundance * (file$abundance -1 )
x  = sum(file$abundance)
x = x * (x -1)
D = sum(file$n_n_1) / x
ISI = 1/D

file$pi = file$abundance / sum(file$abundance)
file$lnpi = log(file$pi)
file$pi_lnpi = file$pi *  file$lnpi
H = - sum(file$pi_lnpi, na.rm = TRUE)

length(unique(file$genus))


length(which(file$tax_id %in% tru.m$tax_id))


#barplot
library(ggplot2)
ggplot(file, aes(x = reorder(species, -abundance), y = abundance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(
    title = "Abundance of Species",
    x = "Species",
    y = "Abundance"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12)
  )
