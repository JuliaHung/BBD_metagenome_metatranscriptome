#This is to run the bin refining with bins from MetaBAT2 and MaxBin2, and dereplicate bins

#bin files from metabat2
ln -s ../../MetaBAT2/combined_polished/combined_polished_metabat2_Contig2Bin.tsv
#bin files from maxbin2
ln -s ../../Maxbin2/combined_polished/combined_polished_maxbin2_Contig2Bin.tsv
#polished assembly reads
ln -s ../../../assembly/combined_polished/combined_medaka1.assembly.fasta

#run DAS_Tool ed
conda run DAS_Tool -i combined_polished_metabat2_Contig2Bin.tsv,combined_polished_maxbin2_Contig2Bin.tsv -l metabat,maxbin -c combined_medaka1.assembly.fasta -o DAS_out/combined_polished --write_bin_evals --write_bins -t 30 

#to run dRep to calculate ANI and to dereplicate
singularity run -B /fast:/fast $SING/drep-3.2.2.sif dRep dereplicate dREP_out -g ../03_binning_refine/combined_polished/DAS_out/combined_polished_DASTool_bins/*.fa --S_algorithm fastANI --ignoreGenomeQuality -p 12
