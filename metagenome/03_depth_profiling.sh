#To run depth profiling

#### STEP 1: create link to the raw data #######
this is to setup symbolic link for the data that I will need for coverage profiling
#raw data
ln -s ../../../00_raw_reads/ONT/AT-DMSO2_ALL.fastq.gz AT2_ONT.fastq.gz
ln -s ../../../00_raw_reads/ONT/AT1_AT2_ALL.fastq.gz AT1_ONT.fastq.gz
ln -s ../../../01_assembly_flye/metaFlye_combined/assembly.fasta combined_assembly.fasta
ln -s ../../../00_raw_reads/short_reads/AT1-AT2_HHKYHDSX7_TCCATTGCCG-TCGTGCATTC_L002_R1.fastq.gz AT1_illumina_R1.fastq.gz
ln -s ../../../00_raw_reads/short_reads/AT1-AT2_HHKYHDSX7_TCCATTGCCG-TCGTGCATTC_L002_R2.fastq.gz AT1_illumina_R2.fastq.gz
ln -s ../../../00_raw_reads/short_reads/AT-DMSO2_HHKYHDSX7_CTAGTGCTCT-TACTGTTCCA_L002_R1.fastq.gz AT2_illumina_R1.fastq.gz
ln -s ../../../00_raw_reads/short_reads/AT-DMSO2_HHKYHDSX7_CTAGTGCTCT-TACTGTTCCA_L002_R2.fastq.gz AT2_illumina_R2.fastq.gz
ln -s ../../../00_raw_reads/short_reads/AT-DMSO3_HHKYHDSX7_ACGCCTTGTT-ACGTTCCTTA_L002_R1.fastq.gz AT3_illumina_R1.fastq.gz
ln -s ../../../00_raw_reads/short_reads/AT-DMSO3_HHKYHDSX7_ACGCCTTGTT-ACGTTCCTTA_L002_R2.fastq.gz AT3_illumina_R2.fastq.gz

##### STEP 2 : calculate the coverage for both long-read and short reads #####
#to calculate the coverage for AT1 long-read
#this is to calculate the depth/coverage of each contigs to assist with the binning. I will need the coverage from both long and short reads data.
#
##for long reads data##
###Create Index: mapping the reads to the the raw assembly (using minimap2)
#The ‘‘-x’’ argument tells minimap2 which preset to use; option‘‘-a’’ sets output file format to SAM
singularity run -B /fast:/fast $SING/minimap2-2.24.sif minimap2 -a -x map-ont -t 20 combined_assembly.fasta AT1_ONT.fastq.gz -o AT1_ONT_index.sam

#samtools view: SAM/BAM and BAM/SAM conversion http://www.htslib.org/doc/1.11/samtools-view.html
#samtools sort: sort alighment file. -O for output format, -@ for threads, -o for write final output to FILE rather than standard output
#
samtools view -b AT1_ONT_index.sam | samtools sort -O bam -@ 10 > AT1_index_ONT.bam
#
#This is the commeand to calculates the coverage of sequences in the BAM file into AT2_cov.txt
samtools depth -a AT1_index_ONT.bam | awk 'BEGIN{ctg=""; av=0; n=0}{if($1!=ctg && ctg!=""){print ctg, av/n; av=0; n=0} ctg=$1; av+=$3; n+=1}END{if(n>0) print ctg, av/n}' > AT1_ONT_coverage.txt

#
#double check if the command line works and get all the contigs
#grep "contig_" AT2_cov.txt | wc -l
#55666 contigs
#
#
##for short reads ##
###Create Index: mapping the reads to the assembly (using BWA-MEM)
#singularity run -B /fast:/fast $SING/bwa-0.7.17.sif bwa index combined_assembly.fasta
singularity run -B /fast:/fast $SING/bwa-0.7.17.sif bwa mem combined_assembly.fasta AT1_illumina_R1.fastq.gz AT1_illumina_R2.fastq.gz > AT1_illumina_index.sam
samtools view -b AT1_illumina_index.sam | samtools sort -O bam -@ 10 > AT1_illumina_index.bam
samtools depth -a AT1_illumina_index.bam | awk 'BEGIN{ctg=""; av=0; n=0}{if($1!=ctg && ctg!=""){print ctg, av/n; av=0; n=0} ctg=$1; av+=$3; n+=1}END{if(n>0) print ctg, av/n}' > AT1_illumina_coverage.txt 

#### STEP 3: sort all the contiga coverage .txt in order and combine into a final table ####

#mkdir 03_sorted_coverage
#sort the contigs by name
#sort AT1_cov_illumina.txt > 03_sorted_coverage/AT1_cov_illumina_sorted.txt
#sort AT1_cov_ONT.txt > 03_sorted_coverage/AT1_cov_ONT_sorted.txt
#sort AT2_cov_illumina.txt > 03_sorted_coverage/AT2_cov_illumina_sorted.txt
#sort AT2_cov_ONT.txt > 03_sorted_coverage/AT2_cov_ONT_sorted.txt
#sort AT3_cov_illumina.txt > 03_sorted_coverage/AT3_cov_illumina_sorted.txt

#Combine all the coverages files into one coverage txt. one contigs in one line, use tab to sepearate samples

awk '{a[$1] = a[$1] "\t" $2} END {for (contig in a) print contig a[contig]}' AT*_cov_*.txt > summary_coverage.txt

#

