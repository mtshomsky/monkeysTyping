package monkeyRand;

#
# Todo:
#      [\] Perl native random function not fully supported
#          [X] Add switches
#          [] add supporting functions
#      [X] Save and Restore implemented
# 


# debugging
my $gblDebug = ''; #'' = false

# constants
my $constLinearCongruentialGenerator = 0;
my $constPerlRand = 1;

# Auto Save/Resume Settings
my $constAutoResume = 'true';  # autoload settings
my $constAutoSave = 'true';  # autoload settings
my $gblResumed = '';  #'' = false
my $constSavePeriod = 10; # save every this many cycles
my $gblSaveCounter = 0;     

# Algorithm Settings
my @gblAlgName = ('LCG', 'PerlRandom');



# saving
my $gblSaveFile = 'monkeyRand.save';


#
# monkeyRand data
#
sub new
{
    my @prvRandData = ();
    my %objData;
    my @prvSaveable = ();

    $objData->{version} = 'Jan142006';
    push @prvSaveable, 'version'; #saveable attribute

    # Boolean value for initialization
    $objData->{initialized} = '';
    push @prvSaveable, 'initialized'; #saveable attribute
    
    # Algorithm for random sequences
    #$objData->{algorithm} = $constPerlRand; 
    $objData->{algorithm} = $constLinearCongruentialGenerator; 
    push @prvSaveable, 'algorithm'; #saveable attribute

    # Data used by the randomization algorithm
    $objData->{paramArray} = \@prvRandData;
    push @prvSaveable, 'paramArray'; #saveable attribute

    # Pseudo random sequence lengths
    #
    # Lengths are important because a pseudo-random number generator
    # will start repeating itself after a certain amount of interations
    # here we have two variables.  One variable of the sequence length if
    # there is one; if not, there is a maximum length that can be used.
    # 
    # Length of random sequence before it repeats
    $objData->{sequenceLength} = 0;
    # An initial number sequence used in detecting a pseudorandom number wrapping around
    $objData->{initialSequence} = '';   #initial sequence
    $objData->{runningSequence} = 0;    #running sequence test
    $objData->{testSeqLength} = 10;     #length

    # Random Number Seed for LCG algorithm
    $objData->{randNumberSeed} = 0;
    $objData->{randNumberSeedUsed} = ''; #blank for false
    push @prvSaveable, 'randNumberSeed';     #saveable attribute
    push @prvSaveable, 'randNumberSeedUsed'; #saveable attribute

    # Maximum (if necessary)
    $objData->{maxLength} = 30000;  

    # Stream comparitors to determine if numbers have been already generated
    $objData->{initSequence} = '';
    $objData->{midSequence} = '';
    $objData->{testSequence} = '';
    $objData->{midCounter} = 0;

    # Save the pointer for saveables
    $objData->{saveablePtr} = \@prvSaveable;

    bless ($objData);    

}

sub print
{
    my $self = shift();
    my @params = @{ $self->{paramArray} };

    print 'monkeyRand: Alg='.$gblAlgName[$self->{algorithm}]." Param= @params".':'. 
          'Seed='.$self->{randNumberSeed};
}

sub stringAlg
{
    my $self = shift();
    my @params = @{ $self->{paramArray} };

    return "Random algorithm=".$gblAlgName[$self->{algorithm}];
}

sub string
{
    my $self = shift();
    my $returnme = '';

    if ($self->{algorithm} == $constLinearCongruentialGenerator)
    {

	# the randData array holds the following
	# index | Data
	# ------------------------
	#     0 | s1
	#     1 | a
	#     2 | b
	#     3 | c
	#     4 | m
	
	my $lclS = $$randData[0];
	my $lclA = $$randData[1];
	my $lclB = $$randData[2];
	my $lclC = $$randData[3];
	my $lclM = $$randData[4];
	
	$returnme =  'DATA: ALG: ' .$gblAlgName[$self->{algorithm}].
	    'S='.$lclS.', A='.$lclA.', B='.$lclB.', C='.$lclC.' + Seed:'.$self->{randNumberSeed}.
            ', M='.$lclM;
    }

    return $returnme;
}

sub save
{
    my $self = shift();

     # Generate a list of this objects Keys
    my @lclStuffToSave = @{ $self->{saveablePtr} };
    my $lclStoreMe = '';

    foreach $lclAttr (@lclStuffToSave)
    {
	# Go through the key list and store the data in a string

	# if its an array, save commadelimited info
	if ($lclAttr =~ m/[A|a]rray/)
	{	    
	    my @lclArray = @{ $self->{$lclAttr} };
	    
	    my $lclCommaDelimited = join ',', @lclArray;
	    
	    $lclStoreMe .=' <'. $lclAttr . '>' .
		$lclCommaDelimited .
		'</'. $lclAttr . '>'."\n";
	} else	{
	    # if its scalar, save it
	    $lclStoreMe .=' <'. $lclAttr . '>' .
		$self->{$lclAttr} .
		'</'. $lclAttr . '>'."\n";
        }

    }

    # open file and save it
    open (MONKEYSAVE, ">$gblSaveFile");
    print MONKEYSAVE "$lclStoreMe\n";
    close MONKEYSAVE;

}

sub restore
{
    $self = shift();

    # open file and restore it
    open (MONKEYRESTORE, "<$gblSaveFile");
    while (<MONKEYRESTORE>)
    {
	chomp;
	
	my $line = $_;

	/\<(.*?)\>/;
	my $attribute = $1;

	/\>(.*?)\</;
	my $value = $1; 
	

	# if its an array, read commadelimited info
	if ($attribute =~ m/[A|a]rray/)
	{	    
	    our @gblArray = split /,/, $value;	    

	    $self->{$attribute} = \@gblArray;	    


	} else	{

	    $self->{$attribute} = $value;	    

        }
	
			   
    }
    close MONKEYRESTORE;
}

# streamRepeatTest
#
# Description: This procedure goes through and populates a stream to check if
#              the random number generator is repeating itself.  
#              This function saves off an initial sequence, then runs a comparison
#              on all following sequences

sub streamRepeatTest
{
   my $self = shift();
   my $argNum = shift();
   my $returnme = '';

   my $lclInitSequence =  $self->{initSequence};
   my $lclMidSequence  =  $self->{midSequence};
   my $lclTestSequence =  $self->{testSequence};
   my $lclMaxStreamSize = 5;
   my $lclActivateMidCounterThreshold = 20;

   my $lclInitSize = $lclInitSequence;
   my $lclMidSize  = $lclMidSequence;
   my $lclTestSize = $lclTestSequence;
   $lclInitSize =~ s/\d*//gs; $lclInitSize = length($lclInitSize);
   $lclMidSize  =~ s/\d*//gs; $lclMidSize  = length($lclMidSize);
   $lclTestSize =~ s/\d*//gs; $lclTestSize = length($lclTestSize);

   #  Increment the mid counter and then activate testing against the
   #  Middle sequence.   
   my $lclActivateMidCounter = '';
   if ($self->{midCounter} > $lclActivateMidCounterThreshold)
   {
       $lclActivateMidCounter = 'true';
   } 
 
   # if we reached this point, then the two buffers should be equal, clear out the test 
   # sequence
   if ($self->{midCounter} == ($lclMaxStreamSize + $lclActivateMidCounterThreshold))
   {
    # clear out the test buffer
       $self->{testSequence} = '';
   }

   # stop counting after this threshold
   if ($self->{midCounter} < ($lclMaxStreamSize + $lclActivateMidCounterThreshold+1))
   {
   ++$self->{midCounter};
   }


   # debug
   if ($gblDebug)
   {
     print "monkeyRand.pm: StreamRepeatTest\n";
     print "     init buffer = $lclInitSequence\n";
     print "     mid  buffer = $lclMidSequence\n";
     print "     test buffer = $lclTestSequence\n";
   }


   if ($lclActivateMidCounter)
   {
   	if ($lclMidSize < $lclMaxStreamSize)
   	{
	   $self->{midSequence} .= $argNum .',';
	}  else  {

	   if ( $lclTestSize >= $lclMaxStreamSize)
	   {
	   	if ($lclTestSequence eq $lclMidSequence)
	   	{
	      	$returnme = 'Repeated Mid Sequence = '.$lclTestSequence;	
	   	}
	   }
        }
   }


   # if the stored number is less than some constant fill it up
   if ($lclInitSize < $lclMaxStreamSize)
   {
	$self->{initSequence} .= $argNum .',';

   } else {
	
	# we already have an initial number sequence
	# test to see if we have enough save in the test Sequence to check
	# if we've generated the same sequence
	if ( $lclTestSize < $lclMaxStreamSize)
	{
	   # we didn't have enough to test, so tack on the number
	   $self->{testSequence} .=  $argNum .',';

	} else {

	   # we do have enough to test if the test sequence is the same as the initial sequence
	   if ($lclTestSequence eq $lclInitSequence)
	   {
	      $returnme = 'Repeated Initial Sequence = '.$lclTestSequence;	
	   }

	   # update the buffer
	   $self->{testSequence} =~ s/^\d*?\,//;     # remove the first number 
	   $self->{testSequence} .=  $argNum .',';  # add a number to the end

	}
   }

  return $returnme;

}

sub clearStreamRepeatTestBuffers
{
   my $self = shift();
   my $argNum = shift();
   my $returnme = '';

   $self->{initSequence} = '';
   $self->{midSequence} = '';
   $self->{testSequence} = '';

   $self->{midCounter} = 0;

   return 1;
}

sub applyRandomSeed
{
    $self = shift();
    $argNumber = shift();

    if (!$argNumber)
	{
	 $argNumber = 0;
	}

    if (!$self->{randNumberSeedUsed})
	{
    	# Create Random Number
    	$self->{randNumberSeed} = int(rand(3767)) + int(rand(389));

    	$self->{randNumberSeedUsed} = 'true'; #blank for false
	}

    # Generate and Add Random Number to existing number
    $argNumber += $self->{randNumberSeed};

    return $argNumber;
}


sub applyLinearSeed
{
    $self = shift();
    $argNumber = shift();

    if (!$argNumber)
	{
	 $argNumber = 0;
	}

    if (!$self->{randNumberSeed})
    {
	$self->{randNumberSeed} = 0;
    }

    if (!$self->{randNumberSeedUsed})
	{
    	# update the random number seed next time we get here
    	$self->{randNumberSeed}++;

    	$self->{randNumberSeedUsed} = 'true'; #blank for false
	}

    # Generate and Add Random Number to existing number
    $argNumber += $self->{randNumberSeed};

    return $argNumber;
}

sub generateRandom
{
    $self = shift();
    $argMax = shift() if @_;
    
    $returnme = '';

    # Auto resume object data if the settings are in place
    if ($constAutoResume)
    {	
	if (!$gblResumed)
	{
	    $self->restore();

	    $gblResumed = 'true';
	}
    }
    
    #LCG
    if ($self->{algorithm} == $constLinearCongruentialGenerator)
    {
	$returnme = $self->lcgRand();
    }

    #Perl Native
    if ($self->{algorithm} == $constPerlRand)
    {
	$returnme = rand($argMax);
    }

    if ($argMax)
    {
	if ($returnme > $argMax)
	{
	    $returnme %= $argMax;
	}
    }

    # Auto save object data if the settings are in place
    if ($constAutoSave)
    {	
	++$gblSaveCounter;

	if ($gblSaveCounter > $constSavePeriod)
	{
	    $gblSaveCounter = 0;
	    $self->save();
	}
    }

    my $lclRepetitionTest = $self->streamRepeatTest($returnme);

    if ($lclRepetitionTest)
	{
	   # reset seed and save off debug info
	   $self->reseedLCG();
	   $self->clearStreamRepeatTestBuffers();

	   if ($gblDebug)
	   {
	      print "R1: Stream has repeated: $lclRepetitionTest, and therefore reseeded\n";
	   }
	}

    return $returnme;
}

sub lcgModMult
{
    my $self = shift();

    my $a = shift();
    my $b = shift();
    my $c = shift();
    my $m = shift();
    my $Xprev = shift();

    # X_n = (a*(X_n-1)^2 + b*(X_n-1) + c) mod m


    # a*(X_n-1)^2
    my $returnme = $a * ($Xprev * $Xprev);

    # b*(X_n-1)
    $returnme += $b * $Xprev;

    # + c
    $returnme += $c;

    # mod m
    $returnme %= $m;
    
    return $returnme;
}

sub reseedLCG
{
  my $self = shift();

  # set randomNumberSeedUsed to false so that the 
  # LCG alg will be reseeeded
  $self->{randNumberSeedUsed} = '';

             

  return 1;
}

sub lcgRand
{
    my $self = shift();
    
    # rand data
    $randData = $self->{paramArray};

    if (!($self->{initialized}))
    {
	$self->lcgRandInit()
    }


    # the randData array holds the following
    # index | Data
    # ------------------------
    #     0 | s1
    #     1 | a
    #     2 | b
    #     3 | c
    #     4 | m
    
    my $lclS = $$randData[0];
    my $lclA = $$randData[1];
    my $lclB = $$randData[2];
    my $lclC = $$randData[3];
    my $lclM = $$randData[4];


    # choose linear or random seed here

    #$lclC = $self->applyRandomSeed($lclC);
    $lclC = $self->applyLinearSeed($lclC);


    # undef also means 0
    if ($lclA == undef || $lclB == undef ||
	$lclC == undef || $lclM == undef)	
    {
	print "monkeyRand: Error: Uninitialized data\n";
	print "            $lclA, $lclB, $lclC, $lclM, $lclS\n";
		
	exit (0);
    }

    # modmult (a, b, c, m, s)
    $lclS = $self->lcgModMult($lclA, $lclB, $lclC, $lclM, $lclS);

    #save off random data
    $$randData[0] = $lclS;

    return $lclS;    
}

sub lcgRandInit
{
    my $self = shift();

    # rand data
    my $randData = $self->{paramArray};

    # the randData array holds the following
    # index | Data
    # ------------------------
    #     0 | s1
    #     1 | a
    #     2 | b
    #     3 | c
    #     4 | m
    #     5 | blank

    my $lclS = $$randData[0];
    my $lclA = $$randData[1];
    my $lclB = $$randData[2];
    my $lclC = $$randData[3];
    my $lclM = $$randData[4];

    $lclS = 106;
    $lclA = 1283;
    $lclB = 211;
    $lclC = 1663;
    $lclM = 11979;

    $$randData[0] = $lclS;
    $$randData[1] = $lclA;
    $$randData[2] = $lclB;
    $$randData[3] = $lclC;
    $$randData[4] = $lclM;
    $$randData[5] = '';

    $self->{initialized} = 'true';
    $self->{randNumberSeedUsed} = ''; #blank for false
          
}


return 1;
