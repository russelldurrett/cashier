#!/usr/bin/env bash
# cluster barcodes in files of the format: 
# sample readname umi barcode umi_centroid umi_count 

version="0.1"

# get arguments 
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -V | --version )
    echo $version
    exit
    ;;
  -v | --verbose ) 
    echo "verbose mode - all commands will be printed"
    set -x 
    ;; 
  -i | --input )
    shift; input_file=$1
    ;;
  -d | --distance )
    shift; distance=$1
    ;;
  -bd | --barcode-distance )
    shift; barcode_distance=$1
    ;;
  -s | --sep )
    shift; separator=$1
    ;;
  -t | --threads )
    shift; threads=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi


if [ -z "$input_file" ]; then echo "must supply input file with -i "; exit; fi 
if [ -z "$separator" ]; then separator=" "; fi 
if [ -z "$distance" ]; then distance=1; fi 
if [ -z "$barcode_distance" ]; then barcode_distance=$distance; fi 
if [ -z "$threads" ]; then threads=1; fi 


sample_name=$(echo $input_file | rev | cut -d'/' -f 1 | rev | cut -d'.' -f 1 | cut -d'_' -f 1 ) 

echo "input file: " $input_file
echo "sample name: " $sample_name

echo 'clustering barcodes'
# cluster to generate starcode output, pass through awk column aggregator and sort 
sorted_starcode_barcode_file=${input_file%.txt}.barcodeclustered.bd${barcode_distance}.sorted.stc
echo "printing starcode barcode clustering output to: " $sorted_starcode_barcode_file
cat $input_file | cut -d' ' -f 4 | starcode -d $barcode_distance -t $threads --print-clusters | awk '{split($0,arr,"\t"); split(arr[3],sequences,",");  for (i in sequences) print arr[1], arr[2], sequences[i] }' | sort -k3 | uniq > $sorted_starcode_barcode_file

echo "joining clustered barcode data with input file"
output_file=${input_file%.txt}.clustered.bd${barcode_distance}.txt
join -t " " -1 4 -2 3 -o '1.1,1.2,1.3,0,1.5,1.6,2.1,2.2' <(sort -k 4 $input_file) $sorted_starcode_barcode_file > $output_file

head $output_file
echo "final clustered file saved to: " $output_file; 







