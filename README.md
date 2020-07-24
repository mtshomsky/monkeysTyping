monkeysTyping
=============

This project initially was to explore a pseudo-random-number-generator's exploration of typing shakespeare.
I had a lot of fun doing it, though in retrospect I did a lot of things from scratch.

When/Where did I leave off
===========================
The last time I ran it was in 2006.  I was on a pure perl and java only kick, so I took this as an endeavor to make some
horrible code and watch some monkeys almost type a sentence.  It was also an okay exploration into OO perl and regular expressions. 
I always felt that OO perl could be better, Moose eventually made perl5 less of a beast, this was before all that.  Note, it was
also before I learned about sqllite.  It was gathering dust in an old svn repo I had.

What did I have fun doing?
===========================
- I made a pseudo random number generator, that amuses me for some reason, but it really was helpful to make tests repeatable.
- Seeing the generator get some partial matches off of the gutenburg doc I was testing off of was fun.
- Running this on my Nintendo DS, running linux was fun.
--- (there are barely any dependencies, besides Perl, so porting was easy).

Would I do it again?
====================
- Possibly, maybe.
- Not in PERL



Files
=======

/lib/monkeyAlphabet.pm --> Alphabet object from which to draw letters
/lib/monkeyDb.pm       --> Save off stuff
/lib/monkeyObj.pm      --> A typing monkey (with an instance of monkeyAlphabet, monkeyObj, and monkeyRand)
/lib/monkeyRand.pm     --> Generate a random number or a pseudorandom number (sometimes called a "random" number)

/bin/organGrinder.pl   --> program that creates a monkey and iterates through new sentences

To Run
=======
- goto /bin 
- at the commandline execute: perl organGrinder.pl

Cleanup
=======
- You may have to delete the .save file in /bin ... it's generated everytime you run  organGrinder.pl

