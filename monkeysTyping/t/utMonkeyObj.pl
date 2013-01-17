# monkey.pl
use lib '../lib';

use monkeyObj;
use monkeyDb;

print "organGrinder: v0.9\n";
print "| Initializing ...\n";

my $monkey = new monkeyObj;
$monkey->setAlphabetDefault();
print "| Alphabet = \n| ";
$monkey->printAlphabet();

# clearSuccess
# setAlphabetDefault
# printAlphabet
# setAlphabet
# updateTime
# getText
# clearMasterpiece
# clearRandData
# generateSentence
# generateSentenceAndMoveToNextAlphabet
# generateNumberSequence

