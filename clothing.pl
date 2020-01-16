#!/usr/bin/perl
#
# Author:	Will Pringle (Kinshasa)
# Purpose:	Compare the data between immigration and clothing
#
use Text::CSV  1.32;
use strict;
use warnings;
# variables
my $COMMA = q{,};
my @records;
my $csv          = Text::CSV->new({ sep_char => $COMMA });
my $province = "";
my $value;
my $total;
my $flag = 0;
my @ontario;
my $cumulative;
my @provinceNames = ("Ontario", "Quebec","Nova Scotia", "New Brunswick", "Manitoba",
"British Columbia", "Prince Edward Island", "Saskatchewan", "Alberta", "Newfoundland and Labrador");
my @provinceString = ("","","","","","","","","","");

# Open the file
open my $dataFH, '<:encoding(UTF-8)',"bigDemo.csv"
	or die "Cannot open file";
@records = <$dataFH>;
close $dataFH or
	die "Unable to close: the file\n";

# Parse the data and check for every row 
foreach my $onwershipData ( @records ){
	if ( $csv->parse($onwershipData)){
		# Put all the comma seperated colums in an array for each row
		my @master_fields = $csv->fields();
		
		$province = $master_fields[3];
		$value = $master_fields[9];
		$total = $master_fields[12];
	
		# check through each province
		for(my $j = 0; $j < 10; $j++){
			# Take in information for the current month
			if($province eq $provinceNames[$j]){
				if($value eq "Immigrants"){
					$flag = 1;
					$cumulative = $total;
				}
				
				# this string ALWAYS appears right after the data,
				# so when it occurs, the information will not be read
				if($value eq "Non-permanent residents"){
					$flag = 0;
					
					# moving the 2001 to 2010 range to right after the 1991 to 2000 range
					$ontario[4] = $ontario[6];
					for(my $i = 1; $i < 5; $i++){;
						$provinceString[$j] = $provinceString[$j].$ontario[$i].", ";
					}
				}
				
				# This will ensure the data is in the right order
				if($flag && ($value ne "Immigrants")){
					$total = $total / $cumulative; #divide by total to get cumulative frequency
					$ontario[$flag-1] = $total;
					$flag = $flag + 1;
				}
			}
		}
	}
}

my @provinceTotal = (0,0,0,0,0,0,0,0,0,0); # total value for a province over every decade
my $current = 198; # current decade

my $cpiValue;
my $date;
my $geo;
my @provinceStringCpi = ("","","","","","","","","","");

# Open the second file
open my $dataFH2, '<:encoding(UTF-8)',"cpiCloth.csv"
	or die "Cannot open file";
@records = <$dataFH2>;
close $dataFH2 or
	die "Unable to close: the file\n";

my @twod;

#initialize twod
for(my $i = 0; $i < 10; $i++){
	for(my $j = 0; $j < 4; $j++){
		$twod[$i][$j] = 0;
	}
}

foreach my $onwershipData ( @records ){
	if ( $csv->parse($onwershipData)){
		# Put all the comma seperated colums in an array for each row
		my @master_fields = $csv->fields();
		
		$date = $master_fields[0];
		$date = substr $date, 0, 3;
		
		$geo = $master_fields[1];
		$cpiValue = $master_fields[10];
		
		# for every province
		for(my $i = 0; $i < 10; $i++){
			# if the product contains the string clothing or Clothing
			if(index($master_fields[3], "clothing") != -1 || index($master_fields[3], "Clothing") != -1){
				# check if within decade
				if($date == $current){
					# if the location is the given province
					if($geo eq $provinceNames[$i]){
					
						$provinceTotal[$i] = $provinceTotal[$i] + $cpiValue;
						
						for(my $j = 0; $j < 4; $j++){
							if($date == $j + 198){
								if($twod[$i][$j] != 0){
									$twod[$i][$j] = $twod[$i][$j] + $cpiValue;
								}else{
									$twod[$i][$j] = $twod[$i][$j] + $cpiValue;
								}
							}
						}
					
					}
				}
				elsif($date != $current && $date > 197){
					$current = $date;
				}
			}
		}
	}
}

#convert into a string for each with relative frequency
for(my $i = 0; $i < 10; $i++){
	for(my $j = 0; $j < 4; $j++){
		
		if($provinceTotal[$i] ==0){
			$provinceTotal[$i] = 1;
		}
		$twod[$i][$j] = $twod[$i][$j] / $provinceTotal[$i];
		
		$provinceStringCpi[$i] = $provinceStringCpi[$i].$twod[$i][$j].", ";
	}
}

for(my $i = 0; $i < 10; $i++){
	$provinceStringCpi[$i] = substr $provinceStringCpi[$i], 0, length($provinceStringCpi[$i]) -2;
	$provinceString[$i] = substr $provinceString[$i], 0, length($provinceString[$i]) -2;
	
	print "\nInformation for ".$provinceNames[$i]."\n";
	print "IMMIGR: ".$provinceString[$i]."\nCLOTHES ".$provinceStringCpi[$i]."\n";
}

