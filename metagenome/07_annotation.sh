### Using Prokka for annotation ###

#prokka
alias prokka='apptainer run -B /pvol/:/pvol /pvol/data/sif/prokka.sif prokka'
while read bin;do 
  prokka --outdir $bin --prefix $bin "../Binning/das_tool/combined_polished/DAS_out/combined_polished_DASTool_bins/${bin}.fa";
done < ../gtdbtk/DAS_tool/combined_polished/combined_polished_topbins_list.txt
