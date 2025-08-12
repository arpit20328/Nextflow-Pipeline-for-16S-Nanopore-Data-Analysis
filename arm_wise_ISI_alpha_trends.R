library(ggplot2)
library(dplyr)

# Prompt for number of patients
cat("Enter number of patients:\n")
num_patients <- as.integer(readLines("stdin", n = 1))

# Initialize lists
subject_names <- character(num_patients)
categories <- character(num_patients)
isi_values <- list()
alpha_values <- list()

# Define new timepoints
timepoints <- factor(c("Baseline", "Day0", "Day15", "Day30", "Day60", "Day90", "Day120", "Day150", "Day180"),
                     levels = c("Baseline", "Day0", "Day15", "Day30", "Day60", "Day90", "Day120", "Day150", "Day180"))

# Collect input for each patient
for (i in 1:num_patients) {
  cat(paste0("Enter patient ", i, " name:\n"))
  subject_names[i] <- readLines("stdin", n = 1)
  
  cat(paste0("Enter category for ", subject_names[i], " (Interventional/Control):\n"))
  categories[i] <- readLines("stdin", n = 1)
  
  cat(paste0("Enter ISI values for ", subject_names[i], " at all timepoints (space-separated, use NA if not present):\n"))
  isi_values[[i]] <- as.numeric(strsplit(readLines("stdin", n = 1), "\\s+")[[1]])
  
  cat(paste0("Enter Alpha diversity values for ", subject_names[i], " at all timepoints (space-separated, use NA if not present):\n"))
  alpha_values[[i]] <- as.numeric(strsplit(readLines("stdin", n = 1), "\\s+")[[1]])
}

# Create combined data frames
df_patient <- data.frame()
df_alpha <- data.frame()

for (i in 1:num_patients) {
  temp_df_isi <- data.frame(
    Subject = subject_names[i],
    Category = categories[i],
    Timepoint = timepoints,
    ISI = isi_values[[i]]
  )
  df_patient <- rbind(df_patient, temp_df_isi)
  
  temp_df_alpha <- data.frame(
    Subject = subject_names[i],
    Category = categories[i],
    Timepoint = timepoints,
    Alpha = alpha_values[[i]]
  )
  df_alpha <- rbind(df_alpha, temp_df_alpha)
}

# Convert factors
df_patient$Subject <- factor(df_patient$Subject, levels = subject_names)
df_alpha$Subject <- factor(df_alpha$Subject, levels = subject_names)
df_patient$Category <- factor(df_patient$Category, levels = c("Interventional", "Control"))
df_alpha$Category <- factor(df_alpha$Category, levels = c("Interventional", "Control"))

# ---------------------------
# ISI Plot
# ---------------------------
ggplot(df_patient, aes(x = Timepoint, y = ISI, group = Subject, color = Subject)) +
  geom_line(size = 1.2, na.rm = TRUE) +
  geom_point(size = 3, na.rm = TRUE) +
  geom_text(aes(label = ifelse(!is.na(ISI), round(ISI, 2), "")), 
            vjust = -1.2, size = 3) +
  geom_hline(yintercept = 2, linetype = "dotted", color = "red") +
  annotate("text", x = 1, y = 2.15, label = "ISI = 2", hjust = 0, vjust = -0.2, size = 3.5, color = "red") +
  labs(title = "Rifaximin Trial ISI Trends",
       x = "Time Point",
       y = "ISI Value",
       color = "Subjects") +
  theme_minimal() +
  facet_wrap(~Category) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ---------------------------
# Alpha Diversity Plot
# ---------------------------
ggplot(df_alpha, aes(x = Timepoint, y = Alpha, group = Subject, color = Subject)) +
  geom_line(size = 1.2, na.rm = TRUE) +
  geom_point(size = 3, na.rm = TRUE) +
  geom_text(aes(label = ifelse(!is.na(Alpha), Alpha, "")), 
            vjust = -1.2, size = 3) +
  labs(title = "Rifaximin Trial Alpha Diversity Trends",
       x = "Time Point",
       y = "Alpha Diversity",
       color = "Subjects") +
  theme_minimal() +
  facet_wrap(~Category) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
