#!/usr/bin/perl
use Text::CSV  1.32;
use strict;
use warnings;
# variable
my $COMMA = q{,};
my @records;
my $csv          = Text::CSV->new({ sep_char => $COMMA });
my $year = 0;
my $value;
my $total = 0;
my $amount = 0;
my @decadeAvg;
my $current = "194";
my $decade = 0;
my $stringDecadeAvg ="";

# Open the file
open my $dataFH, '<:encoding(UTF-8)',"cpidemo.csv"
	or die "Cannot open file";

@records = <$dataFH>;

close $dataFH or
	die "Unable to close: $ARGV[0]\n";

# Parse the data and check for every row 
foreach my $onwershipData ( @records ){
	if ( $csv->parse($onwershipData)){

		# Put all the comma seperated colums in an array for each row
		my @master_fields = $csv->fields();

		if(index($master_fields[3], "Taxi") != -1){
			$year = $master_fields[0];
			$year = substr $year, 0, 3;
			$value = $master_fields[10];
			
			if($year eq $current){
				$total = $total + $value;
				$amount = $amount + 1;
			}
			else{
				#put the average in
				$decadeAvg[$decade] = average($total, $amount);
				
				# reset variables for the next decade
				$total = 0;
				$amount = 0;
				
				# begin the counter and total for the next decade
				$decade = $decade + 1;
				$current = $year;
				$total = $total + $value;
				$amount = $amount + 1;
			}
			
			print "year: ".$year."\tvalue: ".$value."\n";
		}
	}
}

# average the last decade
$decadeAvg[$decade] = average($total, $amount);

# put the vector into a string that R can read
foreach my $i (@decadeAvg){
	$stringDecadeAvg = $stringDecadeAvg.$i.",";
}

# 
$stringDecadeAvg = substr($stringDecadeAvg, 0, length( $stringDecadeAvg )-1);

print $stringDecadeAvg."\n"; #instead of this line graph it in R

# function that takes the average of a total and a number
sub average{
	return $_[0] / $_[1];
}