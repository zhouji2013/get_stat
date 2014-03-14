use strict;
use warnings;

use File::Find; 
use File::Basename;

my $dir = 'C:/Users/zji/git/geworkbench-web/src';

my $largestFileName = "";
my $largestFileSize = 0;

my %loc;
my %componentPackage;
my %componentLoc;
my %componentFileCount;
my %componentLongest;

my $total = 0;
my $x = 0;

sub process_file {
	
	if ($File::Find::name =~ m/\.java$/) {
		$x++;
		
		my $bname = basename $File::Find::name;
		my $componentName = "";
		
		if($File::Find::name =~ m/geworkbenchweb\/(\w+).+\.java/) {
			$componentName = $1;
		} else {
			$componentName = "UNRECOGNIZED-PACKAGE";
		}
		$componentPackage{$bname} = $componentName;
		
		# count line number
		my $t = 0;
		open(INPUT, "< $File::Find::name") or die "Couldn't open for reading: $!\n"; 
		while (<INPUT>) { $t++; }
		close(INPUT);
		
		if($t>$largestFileSize) {
			$largestFileSize = $t;
			$largestFileName = $bname;
		}
		
		$loc{$bname} = $t;
		$componentLoc{$componentName} += $t;
		$componentFileCount{$componentName}++;
		if(!$componentLongest{$componentName} || $t > $componentLongest{$componentName}) {
			$componentLongest{$componentName} = $t;
		}
		
		$total += $t;
	}
} 

find(\&process_file, $dir); 

#print %loc;
print "----------------------------------------\n";
print "filename\tLOC\tpackage\n";
print "----------------------------------------\n";
foreach my $filename ( sort { $loc{$a} <=> $loc{$b} }  keys %loc ) {
	print $filename, "\t", $loc{$filename}, "\t", $componentPackage{$filename}, "\n";
}

print "----------------------------------------\n";
print "package\tLOC\tfile count\tlongest\n";
print "----------------------------------------\n";
foreach my $cname ( sort { $componentLoc{$a} <=> $componentLoc{$b} }  keys %componentLoc ) {
	print $cname, "\t", $componentLoc{$cname}, "\t", $componentFileCount{$cname}, "\t", $componentLongest{$cname}, "\n";
}

print "===summary===\n";
print "File count ".$x."\n";
print "Total LOC ".$total."\n";
print "Largest file ".$largestFileName."\n";
print "Largest file LOC ".$largestFileSize."\n";
