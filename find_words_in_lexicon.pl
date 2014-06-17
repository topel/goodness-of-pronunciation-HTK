#!/usr/bin/perl

# ARGS:
#
# File 1: reference lexicon (with prons)
# File 2: vocab
#
# Print out words and prons of File 2, found in File 1


if ( @ARGV  != 3 ){
#    print "usage: compte_NbVariantes_mots.pl <word_list> <sentseg.log> <output_file>\n";
 print "usage: find_words_in_lexicon.pl <ref lexicon> <vocab> <verbose (0 or 1)>\n";
 print "Print all the pronciations for words given in <vocab>\n";
 print "verbose flag: print number of oov\n";
    exit;
}


%hash_prons_ref = (); # Hash des prons du lexique de ref
#indice par les mots du lexique

%nb_prons = (); # Hash nombre de prons par mot

#%tableau_cpt_voyelles_pron = (); # vecteur des comptes des voyelles
#par prononciation indice sur les voyelles

$lexicon = $ARGV[0];
$input = $ARGV[1];
$verbose=$ARGV[2];



sub readLexicon()
{
    $flag=0;
    @tab=[];

    open (LEXICON, $lexicon) || die "Can't open $lexicon";
    while(<LEXICON>){
	chomp;
	@champ = split /\t/,$_;
	$mot=$champ[0];

	#print "$mot-$champ[1]\n";
	#$hash_prons_ref{$mot} = $champ[1];

	if(exists $hash_prons_ref{$mot}{$nb_prons{$mot}}){
	    $nb_prons{$mot}++;
	    $hash_prons_ref{$mot}{$nb_prons{$mot}}= $champ[1];
	 #   print "BOB $mot $nb_prons{$mot} $hash_prons_ref{$mot}{$nb_prons{$mot}}\n";	
	}
	else{	

	    $nb_prons{$mot}=1;
	    $hash_prons_ref{$mot}{$nb_prons{$mot}}= $champ[1];
	#    print "$mot $nb_prons{$mot} $hash_prons_ref{$mot}{$nb_prons{$mot}} \n";
	}

    } # fin while

#print "\n\n";
    
    close LEXICON;
}

# main
&readLexicon();

# foreach my $bob (keys %hash_prons_ref){
# #    print "$bob $nb_prons{$bob} ";
# #    foreach my $bob2 (keys %{$hash_prons_ref->{ $bob }}){
#     foreach my $bob2 (1 .. $nb_prons{$bob}){
# 	print "$bob $hash_prons_ref{$bob}{$bob2}\n";
#     }
# }

# perl reference http://www.cs.mcgill.ca/~abatko/computers/programming/perl/howto/hash/#function_to_build_a_hash_of_hashes__return_a_reference 
#  for my $k1 ( sort keys %$rHoH ) {
#         print "k1: $k1\n";
#         for my $k2 ( keys %{$rHoH->{ $k1 }} ) {
#             print "k2: $k2 $rHoH->{ $k1 }{ $k2 }\n";
#         }
#     }
#    print "$hash_prons_ref{'THE'}\n";

$oov=0;
open (IN, $input) || die "Can't open $input";
while(<IN>){
    chomp;
if(exists $nb_prons{$_}){
    foreach my $pron (1 .. $nb_prons{$_}){
	print $_ . "\t" . $hash_prons_ref{$_}{$pron}. "\n";
    }
}
    else{
	$oov+=1;
	print(STDOUT "PROBLEM $_ is not in the lexicon\n");
	#exit(1);
    }
}
close IN;

print(STDERR "OOV types = $oov\n") if($verbose);
