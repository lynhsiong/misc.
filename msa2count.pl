#!/usr/bin/perl -w

use Bio::AlignIO;
use Bio::SimpleAlign;
use Bio::SearchIO;
use Bio::Align::Graphics;
use Bio::Align::AlignI;

=head
#Get an alignment file
my $file = shift @ARGV;

#Create an AlignI object using AlignIO
my $in=new Bio::AlignIO(-file=>$file, -format=>'clustalw');
#
#Read the alignment
my $aln=$in->next_aln();
#
#Create some domains for highlighting
my @domain_start = ( 25 , 50, 80 );
my @domain_end = ( 40 , 60 , 100 );
my @domain_color = ( 'red' , 'cyan' , 'green' );

#Create Labels for the domains
my @dml = ("CARD", "Proline Rich", "Transmembrane");
my @dml_start = (25, 50, 80);
my @dml_end = (40, 60, 100);
my @dml_color = ("lightpink", "lightblue", "lightgreen");


#Create individual labels
my %labels = ( 145 => "Hep-c target");


my $print_align = new Bio::Align::Graphics( align => $aln,
pad_bottom => 5,
domain_start => \@domain_start,
domain_end => \@domain_end,
dm_color => \@domain_color,
dm_labels => \@dml,
dm_label_start => \@dml_start,
dm_label_end => \@dml_end,
dm_label_color => \@dml_color,
labels => \%labels,
out_format => "png");

$print_align->draw();
=cut

$infile=shift;

$hash=\%Data;

=head
$in = new Bio::SearchIO(-format => 'blast', -file => $infile);

while( $result = $in->next_result ) {
     $hits_num = $result->num_hits;
#     $q_len = $result->query_length;
#print $result->query_name,"\t";
     while( $hit = $result->next_hit ) {
#print $hit->name,"\n";
          while( $hsp = $hit->next_hsp ) {
                     $aln = $hsp->get_aln;
                     $q_id = $result->query_name;
                     $h_id = $hit->name;
                       $hsp_s = $hsp->start('query');
                       $hsp_e = $hsp->end('query');
                     for ($i=$hsp_s;$i<=$hsp_e;$i++){
                         $pos = $aln->column_from_residue_number($q_id, $i);     
                         $seq = $aln->get_seq_by_id($h_id);
                         $res = $seq->subseq($pos, $pos);
                         push @{$hash->{$i}}, $res;                      
                     }
=cut

$alnIO = Bio::AlignIO->new(-format =>"fasta", -file => $infile);
$aln=$alnIO->next_aln();
$num_res=$aln->length;
$num_seq=$aln->num_sequences;
for ($i=1;$i<=$num_res;$i++){
                     foreach $seq ($aln->each_seq) {
                         $res = $seq->subseq($i, $i);
                         push @{$hash->{$i}}, $res;
                     }
}

=head
                     print $result->query_name,"\t",$hit->name,"\n";
                     $aln = $hsp->get_aln;
                     $alnIO = Bio::AlignIO->new(-format =>"fasta", -file => ">hsp.fsa");
                     $alnIO->write_aln($aln);
                   if( defined $aln ){
                     $res="";
                     %count=();
                     foreach $seq ($aln->each_seq) {
                             $res = $seq->subseq($pos, $pos);
                             $count{$res}++;
                             }
                     foreach $res (keys %count) {
                             printf "Res: %s  Count: %2d\n", $res, $count{$res},"\n";
                             }
                   }
=cut
#           }
#       }

$window=20;
     foreach $pos (sort {$a<=>$b} keys %Data) {
             $k=0;
             @arrays = @{$Data{$pos}};
             foreach $ele (@arrays) {
                     if ($ele !~ /-/) {
                        $k++;                        
                     }
             #print $ele;
             }
             %count = ();
             for (@arrays) {
                 if ($_ !~ /-/) {
                 $count{$_} += 1;
                 }
             }
             @values = sort {$a<=>$b} values %count;
             $max=$values[-1];
             foreach $key (keys %count) {
                 if (($key =~ /[atgcATGC]/) && ($count{$key} == $max)) {
                    push @ATGC, $key;
                    last;
                    }
             }
             ($_at,$_gc)=(0,0);
             for ($i=$pos-$window;$i<=$pos;$i+=1) {
               if ( $ATGC[$i] ) {
                 if (($i>=0) && ($ATGC[$i] =~/[at]/)) {
#print $i,"\t",$ATGC[$i],"\n";
                    $_at++;
                 }elsif (($i>=0) && ($ATGC[$i] =~/[gc]/)) {
#print $i,"\t",$ATGC[$i],"\n";
                    $_gc++;
                 }
               }
             }
             $_atgc=$_at+$_gc;
             $GC=$_gc/$_atgc if $_atgc >0;
             $coverage=$k/$num_seq;
             $identity=$max/$k;
             #print $pos,"\t",$k,"\t",$coverage,"\t",$max,"\t",$identity,"\n";
             if (($pos >=$window) && ($_atgc >0)) {
                print $pos,"\t",$coverage,"\t",$identity,"\t",$GC,"\n";
             }else {
                print $pos,"\t",$coverage,"\t",$identity,"\n";
             }
     }
#}
