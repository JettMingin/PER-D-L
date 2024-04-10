#!/usr/bin/perl
use v5.34;
use Term::ExtendedColor qw(:all);
use Text::SimpleTable::AutoWidth;

our %word_hash; #-global hash to store all valid words, to be used in hash-lookup to check users input
my $answer = &wordListerAndPicker;
my @a_tokens = split (//, $answer);
my %a_ltrcount;
# v----this builds a hash counting the times a specific letter appears in the answer
foreach (@a_tokens){
    $a_ltrcount{$_} += 1;
}

#THIS SUB opens a file containing over 4500 five-letter words, builds a global hash of the entire list, randomly chooses one word for the puzzle
sub wordListerAndPicker{
    open FILE, 'five_letter_words.txt';
    chomp (my @arr = <FILE>);
    close FILE;

    @word_hash{@arr} = ();

    my $random = int(rand $#arr);
    return $arr[$random];
}

#THIS SUB stores all previous answers, wipes the screen and display the answer-grid after each turn
sub screenReset{
    state @prev_tries;
    push @prev_tries, $_[0];
    system 'clear';
    #say "$answer - "; #un-comment this line to reveal the answer
    my $title = fg('springgreen1', '### P E R(D)L! ###');
    say $title;
    foreach (@prev_tries){
        print " " x 4 . "$_\n";
    }
    print "\n";
}

my $tries = 6;
my $guess;
system 'clear';
my $title = fg('springgreen1', "### P E R(D)L! ###");
say $title;

until (($tries == 0) || ($guess eq $answer)){

    
    print "$tries tries left - ";
    $tries -= 1;
    chomp ($guess = <STDIN>);
    

    until (exists $word_hash{uc($guess)}){
        print fg('red1', "Please enter an existing 5-letter word: ");
        chomp ($guess = <STDIN>);
    }
    $guess = uc($guess);
    my @g_tokens = split (//, $guess); #-"Guess-Tokens", stores each letter of the user's guess
    my %g_ltrcount; #this hash will count the times a specific letter appears in the user's guess

    my @p_tokens; #-"Print-Tokens", stores formatted letters of the user's guess (green/orange backrounds, or no bg for incorrect letters)
    my %green_count;
    my @green_index;

    #CHECKING FOR GREENS
    #IF WE FIND A GREEN LETTER, INCREASE HASH $green_count{letter} ++ and SAVE INDEX POSITION IN green_index AS 'G'
    #IF ITS NOT A GREEN LETTER, SAVE INDEX POSTION IN green_index AS 'NG'
    foreach my $i (0..$#g_tokens){
        if ($g_tokens[$i] eq $a_tokens[$i]){
            $p_tokens[$i] = bg('springgreen1', fg('gray24', $g_tokens[$i]));
            $green_count{$g_tokens[$i]} += 1;
            $green_index[$i] = 'G';
        }else{
            $p_tokens[$i] = $g_tokens[$i];
            $green_index[$i] = 'NG';
        }
    }


    #CHECKING FOR YELLOWS
    foreach my $i (0..$#g_tokens){
        if ($green_count{$g_tokens[$i]} == $a_ltrcount{$g_tokens[$i]}){ #---IF WE HAVE FOUND ALL GREENS OF A SPECIFIC LETTER, DONT CHECK FOR YELLOW OF THAT LETTER
            next;
        }
        if ($answer =~ /$g_tokens[$i]/){
            $g_ltrcount{$g_tokens[$i]} += 1;
            if($g_ltrcount{$g_tokens[$i]} > $a_ltrcount{$g_tokens[$i]}){ #if a letter occurs more often in our guess than it does in our answer, its excess occurances SHOULDNT be yellow
                $p_tokens[$i] = $g_tokens[$i];
            }elsif ($green_index[$i] eq 'NG'){ #if the letter: (1) matches with the answer, (2) has not exceeded its number of occurances in the answer, and (3) this specifc index hasnt already been determined to be green, make it yellow
            $p_tokens[$i] = bg('yellow3', fg('gray24', $g_tokens[$i]));
            }
        }
    }

    my $result = join(" ", @p_tokens);
    screenReset($result);
}

if (($tries == 0)){
    print fg('red1', "You lost, the answer was: ");
    print fg('springgreen1', "$answer\n");
}elsif(($guess eq $answer)){
    print fg('springgreen1', "You Won! Congratulations!\n");
}
