### to check the completeness and containmination of MaxBin2 bins with checkM ###

#create symbolic links to the bins
#ln -s ../../../03_binning/03_binning_refine/AT1_polished/DAS_out/AT1_polished_DASTool_bins AT1_polished_bins
#ln -s ../../../03_binning/03_binning_refine/AT2_polished/DAS_out/AT2_polished_DASTool_bins AT2_polished_bins
#ln -s ../../../03_binning/03_binning_refine/combined_polished/DAS_out/combined_polished_DASTool_bins combined_polished_bins

#run checkM on combined polished das_tool bins
singularity run -B /fast:/fast /fast/sw/containers/checkm-genome-1.2.2.sif checkm lineage_wf combined_polished_bins combined_polished_out -t 30 -x fa -f DAStool_combined_polished_checkm_results.txt


### check relative abundance and ANI with coverM ###

#set link to data
ln -s ../../00_raw_reads/ONT/AT1_AT2_combined.fastq.gz
ln -s /fast/jc341271/Ch4.BBD_metagenome/03_binning/03_binning_refine/combined_polished/DAS_out/combined_polished_DASTool_bins
cat combined_polished_DASTool_bins/*.fa > combined_polished_DASTool_bins.fa  

#calculate relative abundance
#generate BAM files through mapping
singularity run -B /fast:/fast $SING/coverm-0.6.1.sif coverm make --single AT1_AT2_combined.fastq.gz -r combined_polished_DASTool_bins.fa -p minimap2-ont -o combined_DAStool_mag_bam -t 20
#used bam to create fna files in combined_genome folder for ANI-dereplicate
singularity run -B /fast:/fast $SING/coverm-0.6.1.sif coverm genome --single AT1_AT2_combined.fastq.gz --genome-fasta-directory combined_genome/ -r combined_polished_DASTool_bins.fa -p minimap2-ont -m relative_abundance -o combined_relative_abundance -t 20

#Dereplicate genomes at 95% ANI (using fastANI) before mapping unpaired reads:
singularity run -B /fast:/fast $SING/coverm-0.6.1.sif coverm genome --single AT1_AT2_combined.fastq.gz --genome-fasta-directory combined_genome/ --dereplication-ani -o combined_ANI_dereplication -t 20


