#align reads to with BBD MAGs (rRNA included)
align_reads_sample(){
  sample_name=$1
  
  input_folder="raw_reads/"
  output_folder="rsem/"
  
  r1=${input_folder}${sample_name}_R1.fastq.gz
  r2=${input_folder}${sample_name}_R2.fastq.gz
  
  out=${output_folder}${sample_name}
  
  mkdir -p ${out}
  
  rsem-calculate-expression -p 20 \
  --paired-end \
   --bowtie2 \
   ${r1} \
   ${r2} \
   genome_bins/BBD_combined_MAGs \
   ${out}
   
}

for treatment in D N;do
  for number in 1 2 3 4 5; do
  echo "Alinging reads for ${treatment}${number}"
  align_reads_sample ${treatment}${number}
 done
done
