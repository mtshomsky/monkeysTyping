use strict;

use lib '../lib';
use monkeyAlphabet;

my $rAlpha = new monkeyAlphabet;

my $isVerbose = '';


$rAlpha->setIncrementConstFactorial();
$rAlpha->init();

my $lastCount =0 ;

while (1)
{
    # print the iterator
    $rAlpha->printIterator();

    # get the alphabet and increment it
    my $alphaSetPtr = $rAlpha->getAlphabetSetAndIncrement();
    my @alphaSet = @{ $alphaSetPtr };
    
    # print the current alphabet
    print "\nUT: Alphabet set =  [ @alphaSet ] \n";

    # print the iterator
    $rAlpha->printIterator();

    # if we've gone through the list once then quit
    if ($rAlpha->atLastIterator()) {	++$lastCount; }
    if ($lastCount > 1) { last;}
    

    if ($isVerbose) { sleep (2); } 
}
