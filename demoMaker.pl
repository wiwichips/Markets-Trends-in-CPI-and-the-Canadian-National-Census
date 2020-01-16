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
my $counter = 0;

# prompt user for input and get input
print "Filename: ";
my $filename = <>;
chomp $filename;

print "Please enter the column you want to search through: ";
my $column = <>;
chomp $column;
$column = $column - 1;

print "Please enter a string you want to search for: ";
my $string = <>;
chomp $string;

print "Do you want to find an exact match? (Y or N): ";
my $option = <>;
chomp $option;

# Open the files
open my $dataFH, '<:encoding(UTF-8)',$filename
	or die "Cannot open file";
@records = <$dataFH>;
close $dataFH or
	die "Unable to close: the file\n";
	
#open file for writing
open(my $fh, '>:encoding(UTF-8)', "output.csv")
	or die "Could not open file output.csv";

# # for testing purposes, test the variables
# $filename = "cpiCloth.csv";
# $column = 3;
# $string = "clothing";

# Parse the data and check for every row 
foreach my $onwershipData ( @records ){
	if ( $csv->parse($onwershipData)){
		# Put all the comma seperated colums in an array for each row
		my @master_fields = $csv->fields();
		
		# exact match
		if($option eq "Y"){
		
			# check if the string exactly matches the cell
			if($master_fields[$column] eq $string){
				for(my $i = 0; $i < @master_fields - 1; $i++){
					#print $fh $master_fields[$i].",";
					print $fh "\"".$master_fields[$i]."\",";
				}
				print $fh $master_fields[@master_fields - 1]."\n";
			}
		}
		
		#non - exact match
		elsif($option eq "N"){
		
			# check if the string is inside of the column at the current row
			my $lowerCaseString = lc $master_fields[$column];
			if(index($lowerCaseString, $string) != -1){
			
				for(my $i = 0; $i < @master_fields - 1; $i++){
					#print $fh $master_fields[$i].",";
					print $fh "\"".$master_fields[$i]."\","
					

				}
				print $fh $master_fields[@master_fields - 1]."\n";
			}
		}
		else{
			print "Pleae enter either a Y or an N\n";
		}
		
		# print dots every 100 lines to give the user indication the program is running
		$counter = $counter + 1;
		if(!($counter % 1000)){
			print ".";
		}
		
	}
}

close $fh;
close $dataFH;