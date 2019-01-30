#!/usr/bin/perl -w
####################################################
#
#	Question 1:   histogram
#	Submitted by: Fred Bulah
#	Email:        fredbulah@comcast.net
#	Mobile:       305-974-7460 | 973-214-7560
#
####################################################

=pod

=head1 NAME        

	q1_hist -- utility to strip comments from JSON-like text blocks 

=head1 SYNOPSIS    

	q1_hist input-string
	q1_hist -t 
	q1_hist -h 

=head1 PROBLEM STATEMENT

	Question 1: 
	Write code to generate the following histogram display based on the frequency of occurrence of characters in the first argument to the program. Example:
	
	   $ perl histogram.pl "Mississippi borders Tennessee."
	   s: #######
	   e: #####
	   i: ####
	    : ##
	   n: ##
	   p: ##
	   r: ##
	   .: #
	   M: #
	   T: #
	   b: #
	   d: #
	   o: #

=head1 DESCRIPTION 

	q1_hist generates a historgram of the number of occurrences of the unique characters as presented in Question 1.
	
	The histogram is sorted in descending order and secondarily orders upper case before lower case.  All characters are included, including blank space and period (.)

	q1_hists:
		- splits the input into a list of its characters
		- loads them into a hash to buildAndDisplayHistogramtain the characters as keys and the number of occurrences as the values
		- uses the perl sort facility for the ordering 

	The options are as follows:

	-t      run internal rests only
	-h      display help useage message only

=head1 METHODS

	buildAndDisplayHistogram(): Driver that builds the histogram docomposing the input into a list of its constituent unique characters.

	createHistogramRows( %uniqueCharsWithCts ): Creates the display rows for the histogram display
	input:  
		%uniqueCharsWithCts:  hash whose keys are the unique characters from the input and whose values are the occurrece counts 
	output: 
		@rows: array of strings with '#' characters sorted in descending order by character count

	runTests():              runs a set of internal tests

	testResultsReport():     ouputs the results of the internal tests

	usage($msg, $exitCode:   displays a usage message in reponse to the help flag -h or if invalid inputs are supplied
	input:  
		$msg:      string containing a message to be displayed
		$exitCode: an integer with the shell exit code
	output: 


=head1 BUGS or CAVEATS 

=head1 ACKNOWLEDGEMENTS 

=head1 COPYRIGHT or LICENSE 

=head1 AVAILABILITY 

=head1 AUTHOR 

	Fred Bulah
	Email:        fredbulah@comcast.net
	Mobile:       305-974-7460 | 973-214-7560

=head1 SEE ALSO 

=cut


use strict;

use Getopt::Std;

our($HIST_CHAR) = '#';


####################################################
#
#	get command line options
#
#	valid options
#
#	-h    shows usage message
#	-t    runs internal tests
#	-D    debug
#
####################################################
my(%opts);

getopts('Dht', \%opts);

usage(undef, 0) if ( exists( $opts{'h'} ) );

#
#	'D' switch sets debug mode
#
our($DEBUG) = exists( $opts{ 'D' } );

#
#	't' switch indicates run internal tests only
#
my($testMode) = exists( $opts{ 't' } );

if ( $testMode )
	{
	print "$0: running internal tests only\n";
	runTests();
	exit 0;
	}

#
#	check that a command line argument was supplied
#

usage("$0: Error: No arguments were supplied", 1) if ( $#ARGV < 0 );

#
#	concatenate command line arguments into a single input string
#
my($inputString) = join(" ", @ARGV);

my(@hist)        = buildAndDisplayHistogram( $inputString, 1 );


####################################################
#	buildAndDisplayHistogram: build the historgram
####################################################
sub buildAndDisplayHistogram
{

	my($inputString, $doPrint)  = @_;

	print "buildAndDisplayHistogram: testMoide=$testMode inputString=[$inputString]\n" if ( $DEBUG );

	#
	#	create map with unique characters and their respective counts from the input
	#

	my(@allChars) = split( //, $inputString );

	print "allChars=", join("|", @allChars), "\n" if ($DEBUG);

	my(%uniqueCharsWithCts);

	for( @allChars )
		{
		$uniqueCharsWithCts{ $_ }++;
		}

	#
	#	create histogram from the unique characters and counts
	#

	my(@hist) = createHistogramRows( %uniqueCharsWithCts );

	if ( $doPrint ) 
		{
		print join("\n", @hist);
		}

	return @hist;

}

####################################################
#	createHistogramRows: create the histogram
####################################################
sub createHistogramRows
{
	my(%uniqueCharsWithCts) = @_;

	my(@hist);

	#
	#	primary sort by descending frequency and secondart lexically
	#
	foreach( sort 
					{
					$uniqueCharsWithCts{$b} <=> $uniqueCharsWithCts{$a}
					or
					$a cmp $b
					} (keys(%uniqueCharsWithCts)) )
		{ 
		push(@hist,  "$_: " .  $HIST_CHAR x $uniqueCharsWithCts{$_});
		}

	return @hist;
}

####################################################
#	runTests: run some tests
####################################################
sub runTests
{
	my(@tests) = (

		{ "input" => "11111",  "expected" => [ "1: #####" ] },
		{ "input" => "abbccc", "expected" => [ "c: ###", "b: ##", "a: #" ] },
		{ "input" => "",       "expected" => undef },
		{ "input" => "\n",     "expected" => [ "" ] }

	);

	my(@actual);
	my($maxIxActual);
	my($maxIxExpected);
	my(@testResults);

	foreach ( my($testNum) = 0; $testNum <= $#tests; $testNum++ )
		{
		print "runTests: input={$tests[ $testNum ]}->{ 'input' }\n" if ( $DEBUG );
		@actual                              = buildAndDisplayHistogram( $tests[ $testNum ]->{ 'input' }, 0 );
		$maxIxActual                         = $#actual;
		$maxIxExpected                       = $#{$tests[ $testNum ]->{ 'expected' }};
		#
		#	initialize test results
		#
		$testResults[$testNum] = { 'input' => $tests[ $testNum ]->{ 'input' }, 'result' => "PASSED", 'errors' => [] };
		if ( $#{$tests[ $testNum ]->{ 'expected' } } != $#actual )
			{
			$testResults[$testNum]->{ 'result' } = "FAILED";
			push(@{$testResults[$testNum]->{ 'errors' }}, "maxIxActual=$maxIxActual != maxIxExpected=$maxIxExpected" );
			}
		my($ix);
		my($expected) = $tests[ $testNum ]->{ 'expected' };
		for( my($ix)  = 0; $ix < $maxIxExpected; $ix++ )
			{
			if ( $ix > $maxIxActual ) 
				{
				$testResults[$testNum]->{ 'result' } = "FAILED";
				push(@{$testResults[$testNum]->{ 'errors' }}, "ixExpected=$ix > maxIxActual=$maxIxActual ... no actual data present" );
				last;
				}
			if ( $expected->[$ix] ne $actual[$ix] )
				{
				$testResults[$testNum]->{ 'result' } = "FAILED";
				push(@{$testResults[$testNum]->{ 'errors' }}, "expected[$ix]=$expected->[$ix] != actual[$ix]=$actual[$ix]" );
				}
			}
		}

	testResultsReport(@testResults);

}

####################################################
#	testResultsReport
####################################################
sub testResultsReport
{
	my(@testResults) = @_;

	#
	#	column headings
	#
	printf("%-5s %8s %-s\n", "TEST#", "RESULT", "INPUT");
	printf("%-5s %8s %-s\n", "-----", "------", "-------------------");

	my($testNum);
	my($input);

	for($testNum = 0; $testNum <= $#testResults; $testNum++)
		{
		$input = $testResults[$testNum]->{ 'input' };
		if ( $input eq ""   ) { $input = "<EMPTY STRING>" };
		if ( $input eq "\n" ) { $input = "<NEWLINE>" };
		printf("%5d %8s %-s\n", $testNum, $testResults[$testNum]->{ 'result' }, $input);
		if ( $testResults[$testNum]->{ 'result' } =~ /FAILED/i ) 
			{
			print "ERRORS:\n";
			print join("\n", @{$testResults[$testNum]->{ 'errors' }});
			}
		}

}

####################################################
#	usage: display usage message
####################################################
sub usage
{
	my($msg, $exitCode) = @_;
	print "$msg\n" if ( defined($msg) );
	print "usage: $0 { -h | -t } input-string\n";
	exit $exitCode;
}


