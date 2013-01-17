package monkeyDb;


#
# Todo:
#       [] fix communication of results to monkey object
#
#
#

use monkeyObj;


# debugging 
my $gblDebug = ''; #'' = false
my $gblSmartDebug = ''; #'' = false
my $gblShowWhatTextMatched = 'true'; #''=false


#
# monkeyDb Object Data
#
sub new 
{

    my %prvHash;
    my $objData = {}; 	

    # file name
    $objData->{file} = '';

    # text hash	
    $objData->{hashedTextFile} = \%privateHash;

    # entire Text
    $objData->{totalFile} = '';

    bless ( $objData );
}

#
# setFile
#
sub setFile
{
    my $self = shift();
    my $filename = shift();

    $self->{file} = $filename;
    
}


#
# allCheck
#
sub allCheck
{
    my $self = shift();    
    my $argCheckThis = shift();
    my $argMonkey = shift();    # monkey object is used for constraints and to
                                # return successes 
                                # do that as a function or something
    my $returnMe = '';    
    my @checkList = ();
    my $isFirstMatch = 'true';


    #  
    # Create the words from left to right
    # EX: dog 
    #     dogg 
    #     doggy
    #
    
    # pull out characters
    my $tmpWord2Explode = substr ($argCheckThis, $argMonkey->{minLength}, length($argCheckThis)+1);
    my @explodedWord = split(//, $tmpWord2Explode); #each char as an element
    my $tmpAccumulator = substr ($argCheckThis, 0, ($argMonkey->{minLength}));

    if ($gblDebug)
    {
	print "monkeyDb: allCheck: $tmpWord2Explode <--\n\n";
	print "monkeyDb: allCheck: $tmpAccumulator <--\n\n";
    }

    # generate the list of sequences
    foreach $letter (@explodedWord)
    {
	# add the word to the checklist
	push @checkList, $tmpAccumulator;

	# update the accumulator
	$tmpAccumulator .= $letter;	
    }


    #  
    # Create the words from right to left
    # EX:   ggy
    #      oggy
    #     doggy
    # pull out characters

    $tmpWord2Explode = substr ($argCheckThis, 0, 
			       length($argCheckThis) - $argMonkey->{minLength});
    # we reverse because we'll be adding onto the last portion of the string
    $tmpWord2Explode = reverse $tmpWord2Explode;

    @explodedWord = split(//, $tmpWord2Explode); #each char as an element
    $tmpAccumulator = substr ($argCheckThis, length($argCheckThis) - $argMonkey->{minLength}, 
			       length($argCheckThis));

    if ($gblDebug)
    {
	print "monkeyDb: allCheck: $tmpWord2Explode <--\n\n";
	print "monkeyDb: allCheck: $tmpAccumulator <--\n\n";
    }

    # generate the list of sequences
    foreach $letter (@explodedWord)
    {
	# add the word to the checklist
	push @checkList, $tmpAccumulator;

	# update the accumulator
	$tmpAccumulator = $letter . $tmpAccumulator;	
    }


    # go through the list
    foreach $checkMe (@checkList)
    {	
	
	my $lclLineResult = '';
	my $lclRegularResult = '';
	my $lclBackwardsResult = '';

	if ($gblDebug)
	{
	    print "monkeyDb: allCheck: running check on -> checkme= $checkMe\n";
	}


	# go through and perform various checks on the string in question
	#
	#  line check    - checks the line hash if there's an exact match
 	#  regular check - checks using a regular expression
	#  backwards check - like regular check but reverses the search string first

	$lclLineResult .= $self->lineCheck($checkMe);
	# if we found a match store the pattern
	if ($lclLineResult && $isFirstMatch) 
	{
	 $argMonkey->{successString}.="lineCheck:$checkMe - ";
	 $argMonkey->{successString}.="masterpiece:$argCheckThis\n";
	 $isFirstMatch = '';
	}	

	$lclRegularResult .= $self->regularCheck($checkMe);
	# if we found a match store the pattern
	if ($lclRegularResult && $isFirstMatch) {
	  $argMonkey->{successString}.="regularCheck:$checkMe - ";
	  $argMonkey->{successString}.="masterpiece:$argCheckThis - ";
	  $argMonkey->{successString}.="intext: $lclRegularResult \n";
	  $isFirstMatch = '';
	}	

	$lclBackwardsResult .= $self->backwardsCheck($checkMe);
	# if we found a match store the pattern
	if ($lclBackwardsResult && $isFirstMatch) 
	{ 
	 $argMonkey->{successString}.="backwardsCheck:$checkMe - ";
	 $argMonkey->{successString}.="masterpiece:$argCheckThis - ";
	 $argMonkey->{successString}.="intext: $lclBackwardsResult \n";
	 $isFirstMatch = '';
	}

	# If something was found, make sure it is returned to the caller
	$returnMe = $lclLineResult.$lclRegularResult.$lclBackwardsResult;
	if ($returnMe) {
		$argMonkey->{successString}.="SuccessfulString:$checkMe\n";
		$isFirstMatch = '';	
	}	

    }
	
    return $returnMe;
}

#
# lineCheck
#
sub lineCheck
{
    my $self = shift();    
    my $argCheckMe = shift();

    # Remove unnecessary characters
    $argCheckMe = $self->purifyLine($argCheckMe);

    # Check the hash for an answer
    my $hashedText = %{ $self->{hashedTextFile} }->{$argCheckMe};

    return $hashedText;
}

#
# regularCheck
#
sub regularCheck
{
    my $self = shift();    
    my $argCheckMe = shift();

    # Remove unnecessary characters
    $argCheckMe = $self->purifyLine($argCheckMe);

    # Check the hash for an answer
    my $hashedText = ($self->{totalFile} =~ m/$argCheckMe/gs);

    if ($gblShowWhatTextMatched)
    {
	$self->{totalFile} =~ m/(.{0,10}$argCheckMe.{0,10})/gs;
        $hashedText = $1;
    }
    
    return $hashedText;
}

#
# backwardsCheck
#
sub backwardsCheck
{
    my $self = shift();    
    my $argCheckMe = shift();

    # Remove unnecessary characters    
    $argCheckMe = reverse ($argCheckMe);

    # Check the hash for an answer
    my $hashedText = $self->regularCheck($argCheckMe);

    if ($gblShowWhatTextMatched)
    {
	$self->{totalFile} =~ m/(.{0,10}$argCheckMe.{0,10})/gs;
        $hashedText = $1;
	reverse ($hashedText);
    }

    return $hashedText;
}


#
# showKeys
#
sub showKeys
{
    my $self = shift();

    my %lclHash = %{ $self->{hashedTextFile} };
    my @lclKeys =  keys	%lclHash;

    print "Monkey DB: Hash Indices:\n @lclKeys \n";
}

#
# loadFile
#
sub loadFile
{
    my $self = shift();
    my $argFile = shift if (@_);

    if ($argFile)
    {
	$self->setFile($argFile);
    }

    open (INFILE, "<$self->{file}");

    while (<INFILE>)
    {
	chomp;

	my $orig = $_;	

	#remove unwanted parts of the line
	my $purifiedLine = $self->purifyLine($orig);

	#accumulate all text into one string
	$self->{totalFile} .= $purifiedLine;
	
	if ($self->{totalFile} =~ m/\s/g)
	{
	    print "monkeyDb: Error: Regexp Error, spaces exist in total file\n";
	    $self->print();
	    exit(0);
	}

	if ($gblDebug)
	{
	    print "monkeyDb: reading in line: $orig\n";
	    print "monkeyDb: storing into hash table: $purifiedLine\n";
	    sleep(1);
	}
	
	# add the line to the hash with the original text
	%{ $self->{hashedTextFile} }->{$purifiedLine} = $orig;
	
	$objData->{hashedTextFile} = \%privateHash;
		
    }
 
   close INFILE;
}

#
# purify line
#
sub purifyLine
{
    my $self = shift();
    my $lclline = shift();

    #remove spaces
    $lclline =~ s/\s//gs;
    
    #set to lowercase
    $lclline = lc($lclline);

    return $lclline;
}


#
# print
# 
sub print
{
    my $self = shift();
    print "monkeyDb: file = $self->{file}\n";    
    print "monkeyDb: file contents: \n $self{totalFile}\n";
}

return 1;
