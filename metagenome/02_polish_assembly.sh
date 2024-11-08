###Polish the assembly with racon (3 times) and madeka  ####

# link to the raw reads
ln -s ../../00_raw_reads/ONT/AT1_AT2_combined.fastq.gz combined_raw_reads.fastq.gz
# link to the flye assembled reads
ln -s ../../01_assembly_flye/metaFlye_combined/assembly.fasta combined_assembly.fasta

## racon ##
#minimap2 1
singularity run -B /fast:/fast $SING/minimap2-2.17.sif minimap2 -x ava-ont -t 40 combined_assembly.fasta combined_raw_reads.fastq.gz > combined_minimap.1.paf 
#racon 1
singularity run -B /fast:/fast /fast/shared/sifs/racon.sif racon -m 8 -x -6 -g -8 -w 500 -t 40 combined_raw_reads.fastq.gz combined_minimap.1.paf combined_assembly.fasta > combined_racon.1.fasta
#minimap2 2
singularity run -B /fast:/fast $SING/minimap2-2.17.sif minimap2 -x ava-ont -t 40 combined_racon.1.fasta combined_raw_reads.fastq.gz > combined_minimap.2.paf 
#racon 2
singularity run -B /fast:/fast /fast/shared/sifs/racon.sif racon -m 8 -x -6 -g -8 -w 500 -t 40 combined_raw_reads.fastq.gz combined_minimap.2.paf combined_racon.1.fasta > combined_racon.2.fasta
#minimap2 3
singularity run -B /fast:/fast $SING/minimap2-2.17.sif minimap2 -x ava-ont -t 40 combined_racon.2.fasta combined_raw_reads.fastq.gz > combined_minimap.3.paf 
#racon 3
singularity run -B /fast:/fast /fast/shared/sifs/racon.sif racon -m 8 -x -6 -g -8 -w 500 -t 40 combined_raw_reads.fastq.gz combined_minimap.3.paf combined_racon.2.fasta > combined_racon.3.fasta

## medeka ##
# medeka 1 -- align reads to assembly
singularity run -B /fast:/fast /fast/shared/sifs/medaka_1.9.1.sif mini_align -i ../combined_raw_reads.fastq.gz -r ../combined_racon.3.fasta -P -m -t 40 -p calls_to_draft.bam
