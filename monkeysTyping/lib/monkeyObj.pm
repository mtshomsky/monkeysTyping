package monkeyObj;

use monkeyAlphabet;
use monkeyRand;

#
# Todo:
#      [\] Seeding
#      [!!] Statistics
#      [!!] Save
#

# debugging 
my $gblDebug = ''; #'' = false

# global vars
my $gblMaxSentenceLength = 50;   # generated sentence length
my $gblMinWordToMatchLength = 5; # Minimum a word has to be to be discovered in the database


#
# monkeyObj Object Data
#
sub new {

    my $mRand = new monkeyRand;

    my $mAlphabet = new monkeyAlphabet;
    $mAlphabet->init();

    my @alphabetSet = ();    
                               
    my $objData = {	

	# pointer to randomizer
	rnd => \$mRand,

	# pointer to monkey alphabet object
	alphabetMgr => \$mAlphabet,

	# Id
	name => 'default',

	# Index Data
	csvMasterpieceIndices => '',

	# Text Data	
	masterpiece => '',

	# We need to march through these lengths
	sentenceLength => $gblMaxSentenceLength,
	minLength => $gblMinWordToMatchLength,
	    
	# Alphabet Size
	alphabetPtr => undef,

	# Alphabet Size
	alphabetLength => undef,
	    	    
	# Time data
	starttime => time(),	    
	uptime => 0,

	# Random Data
	randData => '',

	# Matched Text
	successString => ''
	    
    };
    
    bless $objData;
}

sub clearSuccess
{
  my $self = shift();
  $self->{successString} = '';
}

sub saveSuccess
{
  #!!!  save
}

sub setAlphabetDefault
{
    my $self = shift();
    my $mObj = ${ $self->{alphabetMgr} };

    my $alphaPtr = $mObj->getAlphabetSetAndIncrement();
    
    $self->{alphabetPtr} = $alphaPtr;
    $self->{alphabetLength} = $#{ $alphaPtr } + 1;

    #my @dbgalphabet = @{ $alphaPtr };
    #print "dbg--> @dbgalphabet <-- \n";
}

sub printAlphabet
{
    my $self = shift();
    my $lclAlphabet = ${ $self->{alphabetMgr} }->getAlphabetString();

    print 'monkeyObj: Alphabet: ->'.$lclAlphabet.' <-';

    print "\n";
}

sub setAlphabet
{
    my $self = shift();
    my $lang = shift();

    # !! multi language has not been created yet
   
    my $alphaPtr = ${ $self->{alphabetMgr} }->getAlphabetSetAndIncrement();
    $self->{alphabetPtr} = $alphaPtr;
    $self->{alphabetLength} = length( @{$alphaPtr} );
}

sub updateTime
{
    my $self = shift();

    $self->{uptime} = time() - $self->{starttime};
}

sub getText 
{
    my $self = shift();

    # throw an error if the text we got doesn't meet the size constraints
    if (length($self->{masterpiece})< ($self->{sentenceLength}-1))
    {
	my $tmpLength = length($self->{masterpiece});
        my $tmpExpected = $self->{sentenceLength}-1;

	print "MonkeyObj Error: Generated Sentence is less than Max\n";
	print "MonkeyObj Error: Length: $tmpLength Expected: $tmpExpected\n";
	print "MonkeyObj Error: resetting to recover\n";
	print "MonkeyObj Error: Masterpiece = $self->{masterpiece}\n";

	#set the masterpiece to something useless
	$self->{masterpiece} = '1z2z3z4z1z3z4z1z2z3z4z1z2z3z4z1z2z3z4z1z2z3z4z1z2z3z4z1z2z3z4z1z2zz3z4';
    }
    
    return $self->{masterpiece};
}

sub clearMasterpiece
{
    my $self = shift();
    
    $self->{masterpiece} = '';
}

sub clearRandData
{
    my $self = shift();
    
    $self->{randData} = '';
}

#
# Create a sentence, add it to masterpiece
# 
sub generateSentence
{
    my $self = shift();
    my $randObj = ${ $self->{rnd} };

    $self->clearMasterpiece();
    $self->clearRandData();

    my $lclCounter = 0;

    # !!!! why is it producing variably sized sentences
    # bah the sentences are not long enough
    #for ($lclCounter = 0; $lclCounter < $self->{sentenceLength}; $lclCounter++)
    # the random # must be outside the limits somewhere


    while (length($self->{masterpiece}) < $self->{sentenceLength})
    {
	#debug
	if ($gblDebug)
	{
	    print "generateSentece: counter = $lclCounter,".
		  "sentence length = $self->{sentenceLength}\n";
	}
	
	# Generate a random letter index and store off the generational data
	my $index = $randObj->generateRandom(($self->{alphabetLength} + 1));

	# I need to store this off better
  	my $lclRandData = $randObj->string(); 
	if ($lclRandData)
	{	
	  $self->{randData} .= '| ->'.$lclRandData . "<- \n";
	}
	

	#debug
	if ($gblDebug)
	{
	    print "index = $index\n";
	}
	
 	# turn the letter index into an actual letter in the masterpiece
        $self->{masterpiece} .= @{ $self->{alphabetPtr} }[$index];
    }
}

#
# Create a sentence, add it to masterpiece
# 
sub generateSentenceAndMoveToNextAlphabet
{
    my $self = shift();
    my $randObj = ${ $self->{rnd} };

    $self->clearMasterpiece();
    $self->clearRandData();

    my $alphabetMgr   =  $self->{alphabetMgr};
    my $randomlistStr =  $self->{csvMasterpieceIndices};
       $randomlistStr =~ s/,+$//;
    my @randomList    =  split /,/,$randomList;

    for ($counter = 0; $counter < $self->{sentenceLength}; $counter++)
    {
	#debug
	if ($gblDebug)
	{
	    print "generateSentece: counter = $counter,".
		  "sentence length = $self->{sentenceLength}\n";
	}
	
	# get random number from list
	
	#!!! I left off here!!!!

	# Generate a random letter and store off the generational data
	#my $index = $randObj->generateRandom(($self->{alphabetLength} + 1));
	#$self->{randData} .= '| '.$randObj->string() . "\n";
	##

	#debug
	if ($gblDebug)
	{
	    print "index = $randomList[$counter]\n";
	}
		
        $self->{masterpiece} .= @{ $self->{alphabetPtr} }[$randomList[$counter]];
    }
    
    do
    {
	${ $alphabetMgr }->Increment();
    
    } while (${ $alphabetMgr }->notAtLastIterator());
	
    $self->{masterpiece} .= @{ $self->{alphabetPtr} }[$index];
}

#
# Create a sentence, add it to masterpiece
# 
sub generateNumberSequence
{
    my $self = shift();
    my $randObj = ${ $self->{rnd} };
    my $randomSequence = '';

    $self->clearMasterpiece();
    $self->clearRandData();

    for ($counter = 0; $counter < $self->{sentenceLength}; $counter++)
    {
	#debug
	if ($gblDebug)
	{
	    print "generateSentece: counter = $counter,".
		  "sentence length = $self->{sentenceLength}\n";
	}
	
	# Generate a random letter and store off the generational data
	my $index = $randObj->generateRandom(($self->{alphabetLength} + 1));
        my $lclRandData = $randObj->string(); 
	if ($lclRandData)
	{
	  $self->{randData} .= '| ->'.$lclRandData . "<- \n";
	}

	#debug
	if ($gblDebug)
	{
	    print "index = $index\n";
	}
	
	$self->{csvMasterpieceIndices} .= $index . ',';
        #$self->{masterpiece} .= @{ $self->{alphabetPtr} }[$index];
    }
}

sub print
{
    my $self = shift();
    updateTime($self);
    
    my $randObj = ${ $self->{rnd} };

    print "|-----------------------------------------------------------------\n";
    print "| monkey ID=$self->{name} uptime=$self->{uptime}\n";
    print "| Alphabet: = "; $self->printAlphabet();
    print "| RandData: ".$randObj->stringAlg().' '.$self->{randData}."\n";
    print "| masterpiece: $self->{masterpiece}\n"; 

   if ($self->{successString})  
   {
    print "| successful match: $self->{successString} \n";
   }
   print "|-----------------------------------------------------------------\n";
}

1;
