### Using Prokka, GhostKOALA, and EggNOG-mapper for annotation ###

#prokka
alias prokka='apptainer run -B /pvol/:/pvol /pvol/data/sif/prokka.sif prokka'
while read bin;do 
  prokka --outdir $bin --prefix $bin "../Binning/das_tool/combined_polished/DAS_out/combined_polished_DASTool_bins/${bin}.fa";
done < ../gtdbtk/DAS_tool/combined_polished/combined_polished_topbins_list.txt

#GhostKOALA
## amino acid sequences in FASTA format were uploaded to the GhostKOALA Automatic KO assignment and KEGG mapping web service (https://www.kegg.jp/ghostkoala/)
## the "Prokaryptes + Viruses" reference GENES dataset was selected

#EggNOG-mapper V2
## Protein sequences in FASTA format were uploaded to the EggNOG-mapper genome-wide functional annotation web service (http://eggnog-mapper.embl.de/) for annotation.
## used eggNOG 5 database
## 
