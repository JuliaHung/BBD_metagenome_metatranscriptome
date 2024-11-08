#this script is to assembly combined reads from both AT1 and AT2
python3 /fast/shared/Flye/bin/flye --nano-hq ../00_raw_reads/ONT/AT1_AT2_combined.fastq.gz --threads 40 --out-dir metaFlye_combined/ --meta
