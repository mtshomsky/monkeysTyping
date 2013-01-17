my $gblDataFile = shift();

if (!$gblDataFile)
{
    print "Usage: prepare_monkey_database.pl <text file>\n";
    print "\nExplaination: This program scrubs a text to contain \n".
	  "only letters and spaces; along with, delimiters between sentences.\n";
}

my $gblPurifiedFile = $gblDataFile . '.dat';


# some global variables

# valid delimeter
my $periodReplacement = 'ASDFASDFASDFASDFASDFASDFASDF';
my $spaceReplacement  = 'JKLJKLJKLJKLJKLJKLJKLJKLJKLJ';

# valid patterns
my $invalidPattern = '\.|\W|_|\d|\ ';

# final text
my $finalText = '';



open (INFILE, "<$gblDataFile") or die "File Error: Cannot open $rawFile : $!\n";

while (<INFILE>)
{
    chomp;

    my $line = $_;
       
    while ($line =~ /[$invalidPattern]/gs)
    {    

	#collapse spaces
	$line =~ s/\s+/ /gs;
	
	#replace periods with a valid text delimeter
	$line =~ s/\./$periodReplacement/gs;	
	$line =~ s/\ /$spaceReplacement/gs;
	$line =~ s/\n/$periodReplacement/gs;

	#replace any semicolon with a newline
	$line =~ s/:/\n/gs;
	
	#remove any non alpha-numeric character
	$line =~ s/\W//gs;
	
	#remove any underscore
	$line =~ s/_//gs;
	
	#remove any numeric character
	$line =~ s/\d//gs;
    }

#    $line =~ m/\s*(.*)/gs;
#    $line = "->$line<-";

    if ($line)
    {	
	# remove delimeters
	$line =~ s/$periodReplacement/\n/gs;
	$line =~ s/$spaceReplacement/ /gs;
	
	$finalText .= $line;
    }
}

close INFILE;


open (OUTFILE, ">$gblPurifiedFile");
print OUTFILE "$finalText";
close OUTFILE;
