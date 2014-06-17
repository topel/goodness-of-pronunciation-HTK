#!/bin/bash
 
# ./gop_EN.sh ~/research/imerse/F01FR1phrase01_britain.wav ~/research/imerse/F01FR1phrase01_britain.sent 
 
# wav=$1
sentence_file=$1

scripts_dir=`pwd`
# models_dir=$scripts_dir/EN2
models_dir=$scripts_dir/EN_voxforge

outdir=tmp.$$
mkdir -p $outdir
echo "Output in: $outdir/"
echo


sr=16000
# mode=posterior
# mode=likelihood

# base=`basename $wav .wav`
raw=recorded.raw
base=`basename $raw .raw`

cd ../portaudio/bin

./paex_record_noPlayBack

mv $raw $scripts_dir/
cd $scripts_dir

# audio=${base}_16k.wav
audio=${base}.wav


sox -c 1 -r 16k -e floating-point -b 32 -L $raw -t wav  -r 16k -e signed -b 16 $outdir/$audio
# sox -t wav ../$wav -t wav -r $sr -e signed-integer -b 16 $audio

# endTime="-1"
# echo "$audio 1 SpkID 0.0 $endTime <o,F1,unknown> $word" > $base.stm

cd $outdir
 
# beep=
# cmudict=../cmudict.0.7a_wo_stress_LC
cmudict=../voxforge_dic_LC

# config=$scripts_dir/htk.lb2.conf
config=$scripts_dir/htk.voxforge.conf


dic=dictionnary
find_words_in_lexicon=../find_words_in_lexicon.pl
labfile=$base.lab

# cat ../F01FR1phrase01_britain.TextGrid  | tail -1 | sed 's,\s\+text = ",,g' | sed 's,",,g' | perl -n -e '{use utf8; use encoding "utf8"; $_=lc(); print;}' | sed 's,\s\+$,,g' > ../F01FR1phrase01_britain.sentence

# tr ' ' '\n' < $sentence_file | perl -n -e '{use utf8; use encoding "utf8"; $_=lc(); print;}' | awk '{if(NF>0){print}}' > $labfile
tr ' ' '\n' < ../$sentence_file | perl -n -e '{$_=lc(); print;}' | awk '{if(NF>0){print}}' > $labfile

echo "SENT-START	[]	sil" > $dic
echo "SENT-END	[]	sil" >> $dic
verbose=1
$find_words_in_lexicon $cmudict $labfile $verbose  | sed 's,$, sp,g' >> $dic
echo ".	[]	sil" >> $dic
echo "silence	[]	sil" >> $dic

# generate phone level MLF file from the sentence lab file (one word per line)
mlf_phones=$base.phones.mlf

echo "." >> $labfile
HLEd -d $dic -i $mlf_phones $scripts_dir/mkphones0.led $labfile 
rm $mlf_phones

# forced alignment
mlf_input=input.mlf

echo "#!MLF!#" > $mlf_input
echo "${base}.lab" >> $mlf_input
cat $labfile >> $mlf_input

mlf_align=aligned.mlf

scp_input=input.scp
echo $audio > $scp_input


log_align=align.log

echo
echo "Force aligning..."

HVite -l '*' \
-C $config \
-T 1 \
-b silence \
-a \
-H $models_dir/hmmdefs \
-H $models_dir/macros \
-i $mlf_align \
-m \
-t 250.0 \
-I $mlf_input \
-S $scp_input \
$dic \
$models_dir/list 2>&1 | tee -a $log_align

# free phone loop reco

# Grammar parsing: free phone loop
# HParse $models_dir/network $models_dir/network.htk

# Recognition
echo
echo "Free phone loop reco..."

mlf_reco=recognized.mlf
log_reco=reco.log

HVite \
-C $config \
-T 1 \
-b sil \
-w $models_dir/network.htk \
-H $models_dir/hmmdefs \
-H $models_dir/macros \
-t 250.0 150.0 2000.0 \
-l ./ \
-i $mlf_reco \
-S $scp_input \
$models_dir/dictionary \
$models_dir/list 2>&1 | tee -a  $log_reco


# infile=align_reco_optimal_per_frame.log
# paste $log_align $log_reco | awk '{print $2, $4, $5, $6, $7, $11, $14}' > $infile


# wavesurfer 
surfer_reco=surfer_recognized.lab
awk '{if(NF>3){printf "%.2f %.2f %s\n", $1*(10**-7), $2*(10**-7), $3}}' $mlf_reco > $surfer_reco

# infile=align_reco_optimal_per_frame.log
# paste $log_align $log_reco | awk '{print $2, $4, $5, $6, $7, $11, $14}' > $infile

infile=$mlf_align
infile2=$mlf_reco
info_outfile=gop.txt

if [ -e $info_outfile ]; then rm $info_outfile; fi

first_word=true
unconstrained=0
unconstrained_phone=0
forced=0
forced_phone=0
dur_totale_mot=0
found=false

echo
echo

while read line; do

  nb_fields=`echo $line | awk '{print NF}'`;
  if [ $nb_fields -lt 4 ]; then continue; fi;

  if [ $nb_fields -eq 5 ]; then 
    
    if [ "$first_word" = false ]; then
    
      if [ $word = "silence" ] || [ $word = "." ] ; then continue; fi;
      
      endSeconds=`echo "$startSeconds $dur_totale_mot" | awk '{printf "%.2f", $1+$2*(10**-2)}'`
      gop=`echo "$forced $dur_totale_mot $unconstrained" | awk '{printf "%.4f", $1*$2-$3}'`
      # echo "FORCED=$forced UNC=$unconstrained"
      
      # !!!! REVOIR LE CALCUL GOP_MOT pour l'instant c'est WROOOOOOOOOOOOOOONG!!!! 
#      echo "Word \"$word\" detected in file \"$audio\" (second $startSeconds to $endSeconds) gave an overall GOP measure of $gop"
#      echo
      
      unconstrained=0
      forced=0
      dur_totale_mot=0
      word=`echo $line | awk '{print $5}'`;
      startSeconds=`echo $line | awk '{printf "%.2f", $1*(10**-7)}'`;
      if [ $word = "silence" ] || [ $word = "." ] ; then continue; fi;
      # break
    else
      word=`echo $line | awk '{print $5}'`;
      if [ $word = "silence" ] || [ $word = "." ] ; then continue; fi;
      startSeconds=`echo $line | awk '{printf "%.2f", $1*(10**-7)}'`;
      first_word=false
    fi
  fi;
  
  phone=`echo $line | awk '{print $3}'`; 
  
  if [ $phone = "sp" ]; then continue; fi;

  beg=`echo $line | awk '{printf "%d", $1}'`;
  end=`echo $line | awk '{printf "%d", $2}'`;
  sc=`echo $line | awk '{print $4}'`;
  startSeconds_phone=`echo "$beg" | awk '{printf "%.2f", $1*(10**-7)}'`
  endSeconds_phone=`echo "$end" | awk '{printf "%.2f", $1*(10**-7)}'`

  dur=`echo "$end $beg" | awk '{printf "%d", ($1-$2)*(10**-5)}'`
  dur_totale_mot=`echo "$dur_totale_mot $dur" | awk '{printf "%d", $1+$2}'`

#  forced_phone=`echo "$sc $dur" | awk '{printf $1/$2}'`
#  forced_phone=$sc/$dur
  forced_phone=$sc
  
  if [ $phone != "cl" ] && [ $phone != "vcl" ]; then 
    forced=`echo "$forced $forced_phone" | awk '{printf "%.4f", $1+$2}'`
  fi;

  unconstrained_phone=0

  #if [ $phone = "cl" ]; then
    #echo "    1: $new_word WORD=$word $phone $beg $end $dur $dur_totale_mot $sc forced_phone=$forced_phone $forced "
  #fi
  
  info="W=$word P=$phone $dur "
  
  while read line2; do

    nb_fields2=`echo $line2 | awk '{print NF}'`;
    if [ $nb_fields2 -lt 4 ]; then continue; fi;

    phone2=`echo $line2 | awk '{print $3}'`; 
    beg2=`echo $line2 | awk '{printf "%d", $1}'`;
    end2=`echo $line2 | awk '{printf "%d", $2}'`;
    sc2=`echo $line2 | awk '{printf "%.4f", $4}'`;

    dur_total_free_phone=`echo "$end2 $beg2" | awk '{printf "%d", ($1-$2)*(10**-5)}'`

    
    if [ $beg2 -ge $end ]; then
      break
    fi
    if [ $end2 -le $beg ]; then
      continue
    fi

    if [ $phone = $phone2 ]; then found=true; fi
    
    if [ $beg2 -le $beg ]; then
      if [ $end2 -le $end ]; then
	dur2=`echo "$beg $end2" | awk '{printf "%d", ($2-$1)*(10**-5)}'`
      else
	dur2=`echo "$beg $end" | awk '{printf "%d", ($2-$1)*(10**-5)}'`
      fi
    else
      if [ $end2 -le $end ]; then
	dur2=`echo "$beg2 $end2" | awk '{printf "%d", ($2-$1)*(10**-5)}'`
      else
	dur2=`echo "$beg2 $end" | awk '{printf "%d", ($2-$1)*(10**-5)}'`
      fi
    fi

#    if [ $dur2 -gt 1 ]; then
#      if [ $phone != "cl" ] && [ $phone != "vcl" ]; then 
	unconstrained=`echo "$unconstrained + $sc2*$dur2/$dur_total_free_phone" | bc -l`
#      fi
      # unconstrained_phone=`echo "$unconstrained_phone + $sc2*$dur2/$dur_total_free_phone" | bc -l`
      unconstrained_phone=`echo "$unconstrained_phone $sc2 $dur2 $dur_total_free_phone" | awk '{printf "%.4f", $1 + $2*$3/$4 }'`
#    fi
    
    # echo "         2.: PHONE: $phone2 $beg2 $end2 $dur2 $sc2 $unconstrained_phone"
    info="$info $phone2 $dur2 "

  done < $infile2

#  gop_phone=`echo "$forced_phone $unconstrained_phone $dur" | awk '{printf "%.4f", $1/$3-$2}'`
  gop_phone=`echo "$forced_phone $unconstrained_phone $dur" | awk '{printf "%.4f", ($1-$2)/$3}'`

  # valeur absolue:
  gop_phone=`echo "$gop_phone" | awk '{if($1<0){printf "%.4f", -$1} else{printf "%.4f", $1}}' | sed 's/-//g'`
  
  
  echo "	Phone \"$phone\" detected in file \"$audio\" (second $startSeconds_phone to $endSeconds_phone) gave an overall GOP measure of $gop_phone"
  
  if [ "$found" = true ]; then
    info="$gop_phone MATCHED $info"
  else
    info="$gop_phone NOT_MATCHED $info"
  fi
  
  echo $info >> $info_outfile

  found=false
#  break

done < $infile
