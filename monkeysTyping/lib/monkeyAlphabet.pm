package monkeyAlphabet;

# debugging
my $gblDebug = ''; #''; = false
#my $gblDebug = '';# = false

# GLOBAL Variables
#######################################


# Allow different modes of Alphabet Generation
my $gblConstOneAlphabet = 0;               #  Constant: only one alphabet
my $gblConstLazyFactorial = 1;		   #  Factorial: all alphabets without repeating
my $gblConstFullCombination = 2;           #  Full: all combinations including repeating
my $gblConstFactorial = 3;		   #  Factorial: all alphabets without repeating


# Alphabets
#
# English Alphabet Array
my @EN_AlphabetArray = 
    ('a','b','c','d','e','f','g','h','i','j','k','l','m',
     'n','o','p','q','r','s','t','u','v','w','x','y','z');
# Test Alphabet
my @TEST_AlphabetArray = ('a','b','c','d');

# Initialize the hash that points to the appropriate alphabet
my %gblAlphabet;
$gblAlphabet{'EN'} = \@EN_AlphabetArray;
$gblAlphabet{'TEST'} = \@TEST_AlphabetArray;

#######################################


sub new 
{    
    # Private Hash and HashIterator
    my %indexTranslations;
    my @hashIterator;

    # Object Data
    my $objData = {};
    $objData->{INCTYPE} = $gblConstOneAlphabet; #$gblConstFullCombination;#$gblConstFactorial;
    #$objData->{INCTYPE} = $gblConstFactorial; #$gblConstFullCombination;#$gblConstFactorial;
    #$objData->{INCTYPE} = $gblConstFullCombination;#$gblConstFactorial;
    $objData->{encounteredFirstAlphabet} = '';
    $objData->{factorialIncData} = 0; # stores whether or not we increment an odd or even num of times
    $objData->{factorialStart} = ''; #stores first combination, initialized by increment
    $objData->{lang} = 'EN';
#    $objData->{lang} = 'TEST';
    $objData->{alphabet} = $gblAlphabet{$objData->{lang}}; #arry ptr
    $objData->{alphabetSize} = $#{ $gblAlphabet{ $objData->{lang} } } + 1;
    $objData->{indexTranslation} = \%indexTranslations;
    $objData->{iterator} = \@hashIterator;
    $objData->{alphabetString} = join ',', @{ $objData->{alphabet} }; #this should fail

    bless $objData;
}

sub setIncrementFullCombination
{
    my $self = shift();
    
    $self->{INCTYPE} = $gblFullCombination;   
}

sub setIncrementConstFactorial
{
    my $self = shift();
    
    $self->{INCTYPE} = $gblFullConstFactorial;   
}

sub setIncrementOneAlphabet
{
    my $self = shift();
    
    $self->{INCTYPE} = $gblConstOneAlphabet;
}



sub getAlphabetString 
{
    my $self = shift();
    
    return $self->{alphabetString};
}

sub init
{
    my $self = shift();

    if ($gblDebug)
    {
	print "--- monkeyAlphabet: BEGIN INITIALIZE \n";
    }

    $self->setToZero();

    if ($self->{INCTYPE} != $gblConstOneAlphabet)
	{
    	# generate index translation tables  
    	$self->generateIndexTranslationTable();

    	# increment it for good measure 
    	# consider removing
    	$self->getAlphabetSetAndIncrement();

    	$self->setToZero();
	}

    $self->{alphabetString} = join ',', @{ $objData->{alphabet} };

    if ($gblDebug)
    {
	print "--- monkeyAlphabet: END INITIALIZE \n";
    }
}

sub setToZero
  {
    my $self = shift();


    # note to self: Why did i init this to an alphabet?

    #if ($self->{INCTYPE} == $gblConstFactorialCombination)
    #  {
    #	# set iterator to alphabet
    #	for ($lclCurrentDigit = $self->{alphabetSize} - 1;
    #	     $lclCurrentDigit >= 0;
    #	     $lclCurrentDigit--)
    #	  {
    #	    ${ $self->{iterator} }[$lclCurrentDigit] = ${ $self->{alphabet} }[$lclCurrentDigit];
    #	  }
    # }
    
    if ($self->{INCTYPE} == $gblConstFullCombination)	
      {
	# set iterator to 0
	for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
	     $lclCurrentDigit >= 0;
	     $lclCurrentDigit--)
	  {
	    ${ $self->{iterator} }[$lclCurrentDigit] = 0;
	  }
      }

    
    if ($self->{INCTYPE} == $gblConstLazyFactorialCombination)	
      {
	# set iterator to 0
	for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
	     $lclCurrentDigit >= 0;
	     $lclCurrentDigit--)
	  {
	    ${ $self->{iterator} }[$lclCurrentDigit] = 0;
	  }
      }

    if ($self->{INCTYPE} == $gblConstFactorialCombination)
      {
	# set iterator to 0
	for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
	     $lclCurrentDigit >= 0;
	     $lclCurrentDigit--)
	  {
	    ${ $self->{iterator} }[$lclCurrentDigit] = $lclCurrentDigit;
	  }
      }
  }


sub setLanguage
{
    my $self = shift();
}

sub getAlphabetSetAndIncrement
{
    my $self = shift();

    # If this is the first time the alphabet has been accessed 
    # and we have set the alphabet to factorial then we must
    # assure that there are no duplicates.  Incrementing once
    # will set it to the first in the series

    if (($self->{INCTYPE} == $gblConstFactorialCombination) &&
	($self->ifDuplicateEntries()))
    {
	$self->Increment();
    }

    if ($gblDebug)
    {
	print "getAlphabetSet: \n";
	$self->printIterator();
	print "\n";
    }

    my @alphabetSet = ();
    my @current = @{ $self->{iterator} };

    foreach $iteratorValue (@current)
    {
	# add the alphabet value to the set
	push @alphabetSet, ${ $self->{alphabet} }[$iteratorValue];

    }

    if ($gblDebug)  { print "getAlphabetSetAndIncrement: Before:  @alphabetSet, "; }

    $self->Increment();

    if ($gblDebug)  { print "getAlphabetSetAndIncrement: After:  @alphabetSet\n"; }

    $self->{alphabetString} = join ',', @alphabetSet;
    return \@alphabetSet;
}

# Initialize the hash

sub generateIndexTranslationTable
{
    my $self = shift();

    while (!$self->atLastIterator())
    {
	# move through each 
	$self->Iterate();
    }    

    # we've gotten to the last value, turn it over to zero
    $self->Iterate();
}

# 
#  This will iterate through the large numbers and place items into
#  the private hash 
#
sub Iterate
{
    my $self = shift();
    
    # Debug
    if ($gblDebug) {$self->printIterator(); print "<-- before:\n";}
    
    $self->Increment();
    
    # Got kinda lazy and packed up the array into a comma separated
    # string and stored into the private hash.  It can be retrieved
    # later, but an array will have to be formed by splitting it
    
    # This is inefficient, consider revising
    
    my $csData = join ',', @{ $self->{iterator} };
    ${$self->{indexTranslation}}{$self->IteratorHashValue()} = $csData;
    
    # Debug
    if ($gblDebug) {$self->printIterator(); print "<-- after:\n";}
    
}

sub notAtLastIterator
{
    my $self = shift;
    my $atLastIterator = $self->atLastIterator();
    my $returnme = '1'; # true by default
    
    if ($atLastIterator)
    {
	$returnme = ''; # set to false if at last iterator
    }
}


sub atLastIterator
  {
    my $self = shift();
    my $returnme = '';

    if ($self->{INCTYPE} == $gblConstFullCombination)
	  {
	# if you want to increment through every combination of alphabets
	# return the absolute last value
	$returnme =  $self->atLastIteratorAllCombinations;
      }
    
    if ($self->{INCTYPE} == $gblConstFactorialCombination)
      {
	# if you want to increment through only rearranged alphabets
	# when you return to the first alphabet set again, then you've reached
	# all combinations of the alphabet

	# says whether we've reached the initial alphabet
	$returnme = $self->atLastIteratorFactorial();
      }
    
    return $returnme;
  }


#
# returns a boolean value if you've reached the maximum iteration value
#
sub atLastIteratorFactorial
{
    my $self = shift();
    my $count = 0;
    my $returnme = '';
    my $currentIter = $self->IteratorHashValue();
  

    # we need factorial start to be set in order for this to work
    if (!$self->{factorialStart})
    {
	$self->Increment();
	return $returnme;
    }
 
    # the first sequence is saved off in factorialStart
    if ($self->{factorialStart} eq $currentIter)
    {
	$returnme = $currentIter;
    }
    

    if ($gblDebug)
    {
	if ($returnme)
	{
	    print "monkeyAlphabet: atLastIteratorFACTORIAL = LAST ITERATOR\n";
	}

        print "monkeyAlphabet: atLastIterator =".$returnme.
	      " iter= @{$self->{iterator}} \n";	
    }  

    return $returnme;
}

#
# returns a boolean value if you've reached the maximum iteration value
#
sub atLastIteratorAllCombinations
{
    my $self = shift();
    my $count = 0;
    my $returnme = '';
    # max digit
    my $lclMaxDigit = $self->{alphabetSize} - 1;
    
    for ($lclIter=0; $lclIter < $self->{alphabetSize}; $lclIter++)
    {
	if (${ $self->{iterator} }[$lclIter] == $lclMaxDigit )
	{
	    ++$count;
	}
    }
    
    if ($count == $self->{alphabetSize})
    {
	$returnme = $count;
    } else {
	$returnme = '';
    }

    if ($gblDebug)
    {
	if ($returnme)
	{
	    print "monkeyAlphabet: atLastIteratorAllCombinations = LAST ITERATOR\n";
	}

        print "monkeyAlphabet: atLastIterator =".$returnme.
	      " iter= @{$self->{iterator}} \n";	
    }  
    return $returnme;
}

# 
sub IteratorHashValue
{
    my $self = shift();
    my $lclIter = 0;
    my $returnme = '';
    
    for ($lclIter=0; $lclIter<$self->{alphabetSize}; $lclIter++)
    {
	# Translate each iterator digit into a letter from 
	# the chosen alphabet

	$returnme =
	    ${$self->{alphabet}}[ ${$self->{iterator}}[$lclIter] ] .
	    $returnme;
    }

    return $returnme;
}

sub Increment
  {
    my $self = shift();

    if ($self->{INCTYPE} == $gblConstFullCombination)
      {
	# if you want to increment through every combination of alphabets
	$self->AllCombinationsIncrement();
      }

    if ($self->{INCTYPE} == $gblConstFactorialCombination)
      {
	# if you want to increment through only rearranged alphabets
        $self->FactorialIncrementLazy();
      }
  }



#  Increment the iterator, move through only some combinations
#  
#  EX: Alphabet[0]: a b c,  0 1 2
#               1   a c b   0 2 1
#               2   b a c   1 0 2
#               3   b c a   1 2 0
#               4   c a b   2 0 1
#               5   c b a   2 1 0
#
#               0   a b c
#               1   b c a
#               2   c a b
#               3   a b c  #detect you are done
#
#
#
#  Combinations = 3! = 3 * 2 * 1 = 6 combinations

sub FactorialIncrementExperimental
{
    my $self = shift();

    # get the index to the least significant digit
    my $lclLeastSignificantDigitIdx = $self->{alphabetSize} - 1;
    
    # max digit
    my $lclMaxDigit = $self->{alphabetSize} - 1;

    if ($gblDebug) {print "\nMonkeyAlphabet:  Increment: $lclMaxDigit\n";}

    # Depending on initial, even increments, odd increments, do the following

    if ($self->{factorialIncData} == 0) 
      {
	# in the initial case, nothing is done to increment
	
	# set it to one, to represent the next time around is an odd number of increments
	$self->{factorialIncData} = 1;

	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 2 : $self->{factorialIncData}\n";}

      }
    elsif ($self->{factorialIncData} == 1)
      {

	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 3 : $self->{factorialIncData}\n";}
	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 3 : last = $tmp\n";}
	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 3 : 2nd2last = ${ $self->{iterator} }[$lclLeastSignificantDigitIdx - 1] \n";}


	# in the case that we've incremented an odd amount of times
	# SWAP the least significant two digits
	
	my $tmp = ${ $self->{iterator} }[$lclLeastSignificantDigitIdx];

	
	# the last digit = the second to last digit
	${ $self->{iterator} }[$lclLeastSignificantDigitIdx] = ${ $self->{iterator} }[$lclLeastSignificantDigitIdx - 1];
	
	# the second to last digit equals the last digit
	${ $self->{iterator} }[$lclLeastSignificantDigitIdx - 1] = $tmp;
		
	# set it to two, to represent the next time around is an even number of increments
	$self->{factorialIncData} = 2;

	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 3 : last = $tmp\n";}
	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 3 : 2nd2last = ${ $self->{iterator} }[$lclLeastSignificantDigitIdx - 1] \n"};

      }
    elsif ($self->{factorialIncData} == 2)
      {

	if ($gblDebug) {print "\nMonkeyAlphabet: FAC 4 : $self->{factorialIncData}\n";}

	# in the case that we've incremented an even amount of times
	# increment the 3rd to last digit, using whatever is left in the set
	
	#   Heuristic
        #
	#   The endian alphabet will look as follows
	#
        #   0     N-2  N-1       N
        #   | ...  |    |        |
	#   --------    ---------
	#   Counter     Swappable
	#   --------    ---------
	#   0 000  1    2        3
	#
	#
	# Steps
	# 1: If current position (initially N-2) is equal to the max, set it to 0
	# 2: Increment the counter, by moving N-2 t to the next digit up.
	#   2a: Update the position to focus on to be N = N-1 (initially it is N-2)
	# 3: If the updated digit is in N-1 or N,
	#    then choose the next digit up from that until it is neither of the digits in N-1 or N
	#    Also, make sure that any digit you choose isn't being used to the right of the decimal
	#

	for ($lclCurrentDigit = $self->{alphabetSize} - 2;
	     $lclCurrentDigit >= 0;
	     $lclCurrentDigit--)
	  {

	    # Step 3
	    my @lclDigitsToLeastArray = ();
	    my $lclMinDigit = $lclMaxDigit;

	    # create a list of all digits to the right of the current pointer
	    for (my $lclHereToBeginning = $lclCurrentDigit;
		 $lclHereToBeginning <= $lclLeastSignificantDigitIdx;
		 $lclHereToBeginning++)
	      {
		push @lclDigitsToLeastArray,
		  ${ $self->{iterator} }[$lclHereToBeginning];
	      }

	    # Set to a string so we can search it
	    my $lclDigitsToLeast =  join ',' , @lclDigitsToLeastArray;
	       $lclDigitsToLeast = ','.$lclDigitsToLeast;


	    # determine the smallest number to the left of the current digit
	    for (my $lclHereToBeginning = 0 ;
		 $lclHereToBeginning < $lclCurrentDigit;
		 $lclHereToBeginning++)
	      {
		if (${ $self->{iterator} }[$lclHereToBeginning] < $lclMinDigit)
		  {
		    $lclMinDigit = ${ $self->{iterator} }[$lclHereToBeginning];
		  }		
	      }

	    # if the current digit reached the maximum,
	    # then set it to zero and move to the next significant digit
	    if (${ $self->{iterator} }[$lclCurrentDigit] > $lclMaxDigit)
	      {	
		# STEP 1 (Set to the least significant digit)
		${ $self->{iterator} }[$lclCurrentDigit] = $lclMinDigit;

		# STEP 2		
		if ( # we haven't reached the end digit (most significant)
		    ($lclCurrentDigit-1) >= 0
		   )
		  {
		    # Increment the digit
		    #
		    # Increment the number and make sure it's not equal to anything
		    # to the right of the variable, and make sure it's less than lclMaxDigit
		    while
		      ($lclDigitsToLeast =~ m/\,${ $self->{iterator} }[$lclCurrentDigit-1]\,/ &&
		       ${ $self->{iterator} }[$lclCurrentDigit-1] < $lclMaxDigit)
			{
			  ++${ $self->{iterator} }[$lclCurrentDigit-1];
			}
		  }				
	      } else {
		# Increment the current digit
		#
		# Increment the number and make sure it's not equal to anything
		# to the right of the variable, and make sure it's less than lclMaxDigit
		while
		  ($lclDigitsToLeast =~ m/\,${ $self->{iterator} }[$lclCurrentDigit]\,/ &&
		   ${ $self->{iterator} }[$lclCurrentDigit] < $lclMaxDigit)
		    {
		      ++${ $self->{iterator} }[$lclCurrentDigit];
		    }
	      }		
	  }
	
	# set it to one, to represent the next time around is an odd number of increments
	$self->{factorialIncData} = 1;
      }


    # increment the least significant digit
    #++${ $self->{iterator} }[$lclCurrentDigit];
	
    #for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
#	 $lclCurrentDigit >= 0; 
#	 $lclCurrentDigit--)
#    {
#      # if the current digit reached the maximum,
#      # then set it to zero and move to the next significant digit
#      if (${ $self->{iterator} }[$lclCurrentDigit] > $lclMaxDigit)
#      {	
#	    ${ $self->{iterator} }[$lclCurrentDigit] = 0;
#            if (($lclCurrentDigit-1)>=0)
#            {
#		++${ $self->{iterator} }[$lclCurrentDigit-1];
#            } 
#      }
#    }
}

sub FactorialIncrementLazy
{
#  Note:  Not an efficent way of moving through limited combinations
#         But it is easy to program
#         

    my $self = shift();


    # I have faith that it wont loop forever
    #
    ## number of letter in the alphabet squared
    #my $lclInfLoopStopper = $self->{alphabetSize};
    #for ($lclI=0; $lclI < $self->{alphabetSize}; $lclI++)
    #{
    #	$lclInfLoopStopper *= $lclInfLoopStopper;
    #	my $debugLoop = 0;
    #}

    my $lclInfLoopStopper = 1;

    
    # !!requires a new test subroutine
    while ($lclInfLoopStopper>0)
    {

	# once again I have faith
	#
	#--$lclInfLoopStopper;
	#++$debugLoop;

	$self->AllCombinationsIncrement();

	if (!$self->ifDuplicateEntries())
	{
	    # save off the first non-duplicate sequence
	    if (!$self->{factorialStart})
	    {
		print "!!factorialIncrementLazy: saving off sequence:".$self->IteratorHashValue()."\n";
		

		$self->{factorialStart} = $self->IteratorHashValue();
	    }
	    
	    # we found a duplicate, quit
	    last;
	}
	
    }


    if ($gblDebug) 
    {
	print "factorialIncrementLazy: saving off sequence:".$self->IteratorHashValue()."\n";
    }

    # add a warning
    if ($lclInfLoopStopper <= 0)
    {
	print "factorialIncrementLazy: Warning: Alphabet Set may contain duplicate entries-- Looped:$debugLoop\n --> ".$self->IteratorHashValue()."\n";
    }  
}

# ifDuplicateEntries
#
# Description: returns 1 if there are duplicate entries
#
# 
sub ifDuplicateEntries
{
    my $self = shift();
    my $duplicatesExist = ''; #false by default

    
    # we use this hash to search for duplicates
    my %lclHash = ();


    my $debugString = '';

    	
    for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
	 $lclCurrentDigit >= 0; 
	 $lclCurrentDigit--)
    {
	my $hashIndex = ${ $self->{iterator} }[$lclCurrentDigit];

	$debugString .= ${ $self->{iterator} }[$lclCurrentDigit];

	
	# if the hash index doesn't exist set it to 1
	if (!$lclHash{$hashIndex})
	{
	    $lclHash{$hashIndex} = 1;
	# else it does exist and we need to increment it again
	#      which means we have duplicates
	} else {
	    ++$lclHash{$hashIndex};
	    $duplicatesExist = 'index:'.$hashIndex . ':' .$lclHash{$hashIndex};
	    last; #end the loop here, we found a duplicate
        }	
    }

    if ($gblDebug) { print "ifDuplicateEntries: ->$duplicatesExist<- : $debugString\n";}
	
    return $duplicatesExist;
}


#  Increment the iterator
#  
#  Note: The array runs from least significant to most significant
#            Array Index:  0   1   2   3   4   5
#        Value if binary:  2^5 2^4 2^3 2^2 2^1 2^0
#
sub AllCombinationsIncrement
{
    my $self = shift();

    # get the index to the least significant digit
    my $lclCurrentDigit = $self->{alphabetSize} - 1;
    
    # max digit
    my $lclMaxDigit = $self->{alphabetSize} - 1;

    if ($gblDebug) {print "\nMonkeyAlphabet: Increment: $lclMaxDigit\n";}

    # increment the least significant digit
    ++${ $self->{iterator} }[$lclCurrentDigit];
	
    for ($lclCurrentDigit = $self->{alphabetSize} - 1; 
	 $lclCurrentDigit >= 0; 
	 $lclCurrentDigit--)
    {
      # if the current digit reached the maximum,
      # then set it to zero and move to the next significant digit
      if (${ $self->{iterator} }[$lclCurrentDigit] > $lclMaxDigit)
      {	
	    ${ $self->{iterator} }[$lclCurrentDigit] = 0;
            if (($lclCurrentDigit-1)>=0)
            {
		++${ $self->{iterator} }[$lclCurrentDigit-1];
            } 
      }
    }
}

# 
#  print the iterator
#
sub printIterator
{
    my $self = shift();
    my @tmpItr = @{ $self->{iterator} };
    
    print "monkeyAlphabet: maxSize = $self->{alphabetSize}, iterator = @tmpItr";    
}

1;






