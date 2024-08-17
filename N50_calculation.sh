
awk '{if(NR%4==2) print length($0)}' your_file.fastq | sort -nr | awk 'BEGIN {total=0; half=0; sum=0} {lengths[NR]=$1; total+=$1} END {half=total/2; for (i=1; i<=NR; i++) {sum+=lengths[i]; if (sum >= half) {print "N50:", lengths[i]; exit}}}'
