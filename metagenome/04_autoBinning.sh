### MaxBin2  ####

#sybolic links to contigs file (flye assembly) and all the depth files
#ln -s ../../../../02_polishing/combined/02_medaka/combined_medaka1.assembly.fasta combined_assembly_polished.fasta
 
ln -s ../../../01_coverage_profiling/combined_polished/AT1_cov_ONT.txt 
ln -s ../../../01_coverage_profiling/combined_polished/AT2_cov_ONT.txt 
ln -s ../../../01_coverage_profiling/combined_polished/AT2_cov_illumina.txt 
ln -s ../../../01_coverage_profiling/combined_polished/AT1_cov_illumina.txt 
ln -s ../../../01_coverage_profiling/combined_polished/AT3_cov_illumina.txt 


#run the MaxBin2 

mkdir maxbin2_out
singularity run -B /fast:/fast /fast/sw/containers/maxbin2-2.2.7.sif run_MaxBin.pl -contig combined_assembly_polished.fasta -out maxbin2_out/maxbin2 -abund AT1_cov_ONT.txt -abund2 AT1_cov_illumina.txt -abund3 AT2_cov_ONT.txt -abund4 AT2_cov_illumina.txt -abund5 AT3_cov_illumina.txt -thread 30

### MetaBAT2

#create symbolic link to data
ln -s ../../../01_coverage_profiling/combined_polished/summary_coverage.txt combined_polished_contig_coverage.txt
ln -s ../../../../02_polishing/combined/02_medaka/combined_medaka1.assembly.fasta combined_polished.fasta

#make sure the create a new version of the assembly file in which the contigs have the same order as those in the contig_coverage.txt file.
cat combined_polished_contig_coverage.txt | awk '{print $1}' | xargs samtools faidx combined_polished.fasta > combined_polished_ordered.fasta

#run metabat
singularity run -B /fast:/fast /fast/sw/containers/metabat2-2.15.sif metabat -i combined_polished_ordered.fasta -a combined_polished_contig_coverage.txt --cvExt -o bins/metabat --seed 5

grep '>' bins/* > combined_polished_contig_group.txt
grep '>contig_' combined_polished_contig_group.txt | wc -l
#33332 contigs....which means some contigs were not binned

#as some of the long contigs might have not be binned by MetaBAT2.
ln -s ../../../../01_assembly_flye/metaFlye_combined/assembly_info.txt combined_assembly_info.txt 

mkdir -p long_contigs

while read contig;do 
    echo $contig; 
    samtools faidx combined_polished.fasta $contig > long_contigs/$contig.fasta;
done <  <(cat combined_assembly_info.txt | grep -v 'seq_name' | sort -n -k 2 -r | head -n 20 | awk '{print $1}')

#
# Make a sorted list of contigs in metabat bins
grep '>' bins/metabat.[0-9]*.fa | sed -E 's/.*(contig_.*)/\1/' | sort > metabat_contigs.txt

# Make a sorted list of long contigs
cat combined_assembly_info.txt | grep -v 'seq_name' | sort -n -k 2 -r | head -n 20 | awk '{print $1}' | sort > long_contigs.txt

#Use the comm command to print contigs present in long but not present in metabat.
comm -13 metabat_contigs.txt long_contigs.txt > missing_contigs.txt
