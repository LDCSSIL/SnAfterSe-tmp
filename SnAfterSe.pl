#**********************************************************************
# This program checks if a sense appears after subentries
#**********************************************************************

#!/usr/bin/perl
use warnings;
use strict;
use Term::ANSIColor;

my $num_args = $#ARGV + 1;
my $filename = $ARGV[0];  #user supplied language data file
my $lx = "";
my $i = 0;

if ($num_args < 1) {
	print "Usage:\n	perl SnAfterSe.pl <inputfile>\n";
	exit;
}

open(FH, '<', $filename) or die $!;

my $has_se = 0;
my $cnt = 0;
my $item_cnt = 0;
my $sn_after_se = 0;
my @sn_se = ();
my @entry = ();
my $total_found = 0;
my $sfm_prefix = '';
my $lx_line_num = 0;
my $j = 0;
while(<FH>){
	
    my $line = $_;
	(my $sfm, my $data) = split / /, $_, 2;
	$i = index($line, ' ');
	my $sfm = substr($line,1,$i-1);

=being
	$i = index($line, ' ');
#	my $len = length($line);
	my $sfm = substr($line,1,$i-1);
	my $data = substr($line, $i, length($line)-$i-2); # minus \r\n spaces
=cut
	$sfm =~ s/^\s+|\s+$/ /g; #trim blanks from marker
if ($j++ <5) {
print "%$sfm%\n";
}
	if ($sfm eq "lx") { 
		if ($sn_after_se) {   #output previous entry having sn(s) after an se 

			$total_found++;
			
			# print the whole entry
			
			print "$lx_line_num ------------------------------------ $total_found";
			print color('yellow'), "\n$entry[0]";

			# print the details of the entry
			for ($i = 1; $i < $item_cnt; $i++ ) {
				if (substr($entry[$i], 1, 2) eq "\sn") {
					print color('red'), "$entry[$i]";
				} 
				elsif (substr($entry[$i], 1, 2) eq "\se") {
					print color('cyan'), "$entry[$i]";
				} else {
					print color('white'), "$entry[$i]";				
				}
			}	
			$sn_after_se = 0;
		}
    
		# get ready for the next lx
		$lx_line_num = $.;
		$lx = $data;
		@sn_se = ();
		@entry = ();
		$has_se = 0;
		$cnt = 0;
		$item_cnt = 0;
	}

	$entry[$item_cnt++] = $line;
		
	$sfm_prefix = substr($sfm,0,2);
	if (($sfm_prefix eq "sn") or ($sfm_prefix eq "se")){       
		if ($sfm_prefix eq "se") {
			$has_se = 1;
		} 
		elsif ($has_se) {
			$sn_after_se = 1;
		}	
		$sn_se[$cnt++] = $sfm;
	}	
}

#print if the last lx contains the sequence
if ($sn_after_se) {   #output entry having sn after se 

	$total_found++;
			
	# print the whole entry
			
	print "$lx_line_num ------------------------------------ $total_found";
	print color('yellow'), "\n$entry[0]";

	# print the details of the entry
	for ($i = 1; $i < $item_cnt; $i++ ) {
		if (substr($entry[$i], 1, 2) eq "sn") {
			print color('red'), "$entry[$i]";
		} 
		elsif (substr($entry[$i], 1, 2) eq "se") {
			print color('cyan'), "$entry[$i]";
		} else {
			print color('white'), "$entry[$i]";				
		}
	}	
}
print "Total number of entires with sn's after an se is $total_found\n";
close(FH);
