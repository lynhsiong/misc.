#!/user/bin/perl -w
use strict;

if (@ARGV != 3){die "Usage: $0 <nwk-file> <num> <output-file>\n"};

my ($infile1,$num,$outfile) = @ARGV;

open(FIN,$ARGV[0])||die;
open (OUT,">$outfile") or die "Cannot open $outfile: $!";

#$id="";
while(<FIN>){         
        chomp;
        my $ln=$_;
      FOUT: while($ln=~/\)((\d)\.(\d)(\d)\d+\:)/){
#print $ln;
              my $fnum=$1;
#print $fnum;
              my $num1=$2;
#print $num1;
              my $num2=$3;
#print $num2;
              my $num3=$4;
#print $num3;
                if($num1==0 && $num2<$num){
#                   system( "sed 's/$fnum//' $line" );
                   $ln=~s/\Q$fnum\E/:/;
#print $ln;
                   }
	        else{
#		   system( "sed 's/$fnum/${num1}\.${num2}${num3}/' $line" );
                   $ln=~s/\Q$fnum\E/$num1\.${num2}${num3}:/;
#print $ln;
	           }
              next FOUT    
#print OUT "$ln\n";
          }
      
print OUT "$ln\n";
}
