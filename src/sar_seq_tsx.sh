#!/bin/bash
#
# Usage: 
# sar_seq_tsx.sh yyyymmdd1 yyyymmdd2 ... yyyymmddn dims enl significance 
#

echo '***** Multitemporal PolSAR Change Detection **********'
echo '***** Terra-SAR-X singlepol imagery ******************'
echo '******************************************************'

n=$[$#-3]
declare -i nn
nn=$n-2
significance="${@: -1}"
enl=("${@: -2}")
dims=("${@: -3}")
last=("${@: -4}")
outfn='sarseq('$1'-'$nn'-'$last').tif'

echo 'number of images ' $n
echo 'ENL              ' $enl
echo 'spatial subset   ' $dims

imdir='/home/imagery/'

fn1=$(ls -l $imdir | grep $1 | awk '{print $9}')'/C1/Intensity_HH.bin'
fn1=$imdir$fn1

shift

for ((i=1; i<$n; i++))
do  
    fn2=$(ls -l $imdir | grep $1 | awk '{print $9}')'/C1/Intensity_HH.bin'
    fn2=$imdir$fn2
    fni=$(python /home/register.py -d $dims $fn1 $fn2 | tee /dev/tty | grep written | awk '{print $5}')
    [[ $fni = None ]] && exit 1
    fn[i]=$fni
    shift  
done

fn1=$(python /home/subset.py -d $dims $fn1 | tee /dev/tty | grep written | awk '{print $4}')

s="$fn1 ${fn[*]}"
fns=${s//" "/","}

python /home/sar_seq.py -s $significance -m $fns $outfn $enl 
 