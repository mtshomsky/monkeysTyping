use strict;

use lib '../lib';
use monkeyRand;


my $rGen = new monkeyRand;

my $cntr = 0;

while ($cntr++ < 15)
{
    $rGen->print();
    print ' || Random num='.$rGen->generateRandom(26) . "\n";    

}
