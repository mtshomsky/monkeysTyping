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

print "| loading file 'test.txt' \n";
my $monkeyDatabase = new monkeyDb;
$monkeyDatabase->loadFile('test.txt');

my $printDelay = 1;
my $printDelayCntr = $printDelay;

print "| printing output every, $printDelay, loops\n";
print "| ...Initialize Complete\n";


while (1)
{ 
    $monkey->generateSentence();

    #print every so often
    if ($printDelayCntr < 0)
    {
	$monkey->print();
	$printDelayCntr = $printDelay;
    } else {
	--$printDelayCntr;
    }


    my $masterpiece = $monkey->getText();
    # Unit Test (uncomment)  
    # my $masterpiece = "The Tragedie of Macbeth  Actus Primus";

    my $result = $monkeyDatabase->allCheck($masterpiece, $monkey);

    
    
    if ($result)
    {
	print "match: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
	print "match: Monkey matched a line in the database";
	print "match: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nmatch: ";
	$monkey->print();	
	print "match: checked text: $masterpiece\n";
	print "match: result: ->$result<-\n";
	print "match: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";

	#reset the result
	$result = '';
	$monkey->clearSuccess();
    }
}
