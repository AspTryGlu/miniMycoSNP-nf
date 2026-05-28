#!/bin/bash

header=$(head -n 1 input.csv)
tail -n +2 input.csv | split -l 1 -d --additional-suffix=.csv - parte_

for f in parte_*.csv; do
  (echo "$header"; cat "$f") > "tmp_$f" && mv "tmp_$f" "$f"
done

#source activate nextflow

mkdir -p vcf_files

head -n 2 input.csv > new_samplesheet_only1.csv
#nextflow run CDCgov/mycosnp-nf -profile docker --input new_samplesheet_only1.csv --fasta GCA_008275145.1_ASM827514v1_genomic.fna --outdir results_ref --skip_combined_analysis

for f in parte_*.csv; do
  outdir="results_$f"

  nextflow run CDCgov/mycosnp-nf \
    -profile docker \
    --input "$f" \
    --ref_dir results_ref/reference \
    --outdir "$outdir"

  # COPIA VCFs
  cp "$outdir"/samples/*/variant_calling/haplotypecaller/*.vcf.gz* \
     vcf_files/ 2>/dev/null || true

  #  LIMPIEZA 
  rm -rf work/ .nextflow*
  rm -rf "$outdir/lane"
  rm -f  "$outdir"/samples/*/faqcs/*.fastq.gz
  rm -rf "$outdir/pipeline_info"
done

