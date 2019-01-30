#!/usr/bin/perl -w
####################################################
#
#	Question 3:   balanced parens and brackets
#	Submitted by: Fred Bulah
#	Email:        fredbulah@comcast.net
#	Mobile:       305-974-7460 | 973-214-7560
#
####################################################

=pod

=head1 NAME        

	q3_q4_bal

=head1 SYNOPSIS    

	q3_q4_bal input-string>
	q3_q4_bal -t 
	q3_q4_bal -h 

=head1 PROBLEM STATEMENT

	Question 3:
	Given a string consists of different types of brackets, write a function to determine the string is balanced.  
	For example, " ([])" and "[]{}" are balanced but "([)]" and "](){" are not.  You can assume these are the only characters in the string: ()[]{}

	Question 4: 
	If the string in Question 3 only consists of ( and ), how would it affect your solution from above? For example: " (())" or " (()("

=head1 DESCRIPTION 

	q3_q4_bal implements a solution to the problems posed in Questions 3 and 4. The problem requires not only a count balance but a syntactic balance as well. 
	q3_a4_bal performs both the numerical and syntantical check and reports success only when both are true.

	q3_q4_bal works on all bracket types: parentheses, square brackets, and curly braces.  This, combined with the fact that the syntactic check requires knowing both the order and count of 
	each specific bracket character, makes the solution unaffected by limiting the string to any one specific bracket type. This answers the question posed in Question 4.

	q3-q4_bal effectively ignores characters that are not bracket types

=head1 METHODS

	isBalanced($inputString):  
		input:   
			$inputString: input string composed of a mix of bracket types - parentheses, square brackets, curly braces - and optional non-bracket characters
		output:  
			true  if the string is balanced with respect to bracket types
			false otherwise: the string is not balanced with respect to bracket types

	runTests():                runs a set of internal tests

	usage($msg, $exitCode:     displays a usage message in reponse to the help flag -h or if invalid inputs are supplied
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

use constant { true => 1, false => 0 };

our(%TYPE_MAP) = (
	'(' => "paren",
	')' => "paren",
	'[' => "square",
	']' => "square",
	'{' => "brace",
	'}' => "brace",
);

our(%OPEN_CLOSE_MAP) = (
	")" => "(",
	"]" => "[",
	"}" => "{",
);

our($VERBOSE) = 0;

####################################################
#
#	get command line options
#
#	valid options
#
#	-h    shows usage message
#	-t    runs internal tests
#	-v    verbose mode
#
####################################################
my(%opts);

getopts('htv', \%opts);

usage(undef, 0) if ( exists( $opts{'h'} ) );

#
#	'v' switch sets versbose mode
#
$VERBOSE = ( exists( $opts{ 'v' } ) );

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

my($result)      = isBalanced( $inputString );

my($status);
my($exitCode);
#
#	the shell exit code is 0 for success, 1 for failure
#
if ($result == true )
	{
	$status   = "balanced";
	$exitCode = 0;
	}
else
	{
	$status   = "not balanced";
	$exitCode = 1;
	}

print "'$inputString' is $status\n";

exit $exitCode;


####################################################
#	isBalanced: determine if inout is balanced
####################################################
sub isBalanced
{
	my($s) = @_;
	
	my(@chars);
	
	my($char);
	
	my($ctVal);
	
	my($currentlyOpenBracketType);

	my($nextCloseChar);

	my($ct)       = 0;

	my($ctByType) = 0;

	my(%countsByType) = (
	'paren'  => 0,
	'brace'  => 0,
	'square' => 0,
	);

	my(%nextCloseCharMap) = (
	'('  => ')',
	'['  => ']',
	'{'  => '}',
	);

	if ( $s !~ /[\[\(\{\]\)\}]/ )
		{
		print "input string $s contains no bracket types ... balanced by default\n" if ( $VERBOSE );
		return true;
		}

	print "procssing s=$s ct=$ct\n" if ( $VERBOSE );

	@chars = split( //, $s);
	#
	#	iterate through all the characters
	#
	foreach(@chars)
		{
		print "char=<$_>\n" if ( $VERBOSE );
		if ( /[\[\(\{]/ )
			{
			$ctByType           = ++$countsByType{ $TYPE_MAP{ $& } };
			$nextCloseChar      = $nextCloseCharMap{ $& };
			$ct++;
			print "found open: <$_> count parens/square brackets/curly braces=$ct count-by-type '$&'=$ctByType\n" if ( $VERBOSE );
			}
		if ( /[\]\)\}]/ )
			{
			$ct--;
			if ( $ct < 0 )
				{
				print "count parens/square brackets/curly braces < 0 (=$ct): string $s is unbalanced\n" if ( $VERBOSE );
				last;
				}
			if ( defined($nextCloseChar) && $& ne $nextCloseChar )
				{
				print "saw close character $& before expected next close bracket character '$nextCloseChar': string $s is unbalanced\n" if ( $VERBOSE );
				$ctByType = -1;
				last;
				}
			$nextCloseChar = undef;
			$ctByType = --$countsByType{ $TYPE_MAP{ $& } };
			if ( $ctByType < 0 )
				{
				print "count-by-type '$&' < 0 (=$ctByType): string $s is unbalanced\n" if ( $VERBOSE );
				last;
				}
			print "found close: <$_> count parens/square brackets/curly braces=$ct count-by-type '$&'=$ctByType\n" if ( $VERBOSE );
			}
		}
		#
		#	check the results
		#
		if ( $ctByType < 0 )
			{
			print "final: string $s is unbalanced\n" if ( $VERBOSE );
			return false;
			}
		foreach ( keys(%countsByType) )
			{
			if ($countsByType{$_} < 0)
				{
				print "final: string $s is unbalanced\n" if ( $VERBOSE );
				return false;
				}
			}
		if ( $ct == 0 )
			{
			print "final: string $s is balanced\n" if ( $VERBOSE );
			return true;
			}
		else
			{
			print "string $s is unbalanced: count parens/square brackets/curly braces != 0 (=$ct)\n" if ( $VERBOSE );
			return false;
			}

}

####################################################
#	runTests: run internal tests
####################################################
sub runTests
{

	my($actual);
	my($expected);
	my($key);
	my($status);
	my($testNum);
	my(@results);
	my($result);
	my(%trueFalse) = ( 1 => "true", 0 => "false" );

	my(%TESTS) = (
		"([])"                  => true,
		"[]{}"                  => true,
		"][{}"                  => false,
		"("                     => false,
		"(([][{}]("             => false,
		"(ab)[xy{}z]"           => true,
		"[xy{z]}"               => false,
		"[][][][[]]]][]]]]][[[" => false,
	);
	my(@TEST_KEYS) = (
		"([])",
		"[]{}",
		"][{}",
		"(",
		"(([][{}](",
		"(ab)[xy{}z]",
		"[xy{z]}",
		"[][][][[]]]][]]]]][[[",
	);



	foreach $key (@TEST_KEYS) ## keys( %TESTS))
		{
		$result = {};
		$result->{'expected'} = $TESTS{ $key };
		$result->{'key'}      = $key;
		eval
			{
			$result->{'actual'}   = isBalanced($key);
			};
		if ( $@ )
			{
			print "runTests: error $@ on test $testNum\n";
			$result->{'status'}   = "FAILED";
			}
		else
			{
			$result->{'status'}   = ( $result->{'actual'} == $result->{'expected'} ? "PASSED" : "FAILED" );
			}
		push(@results, $result);
		}
	
	$testNum = 0;

	printf("\n\n");
	printf( "%-6s %-21s %-10s %-10s %-10s\n",   "TEST #", "INPUT",  "STATUS", "EXPECTED", "ACTUAL");
	printf( "%-6s %-21s %-10s %-10s %-10s\n\n", "------", "------", "------", "--------", "------");
	foreach $result (@results)
		{
		printf( "%-6d %-21s %-10s %-10s %-10s\n", $testNum, $result->{'key'}, $result->{'status'}, $trueFalse{$result->{'expected'}}, $trueFalse{$result->{'actual'}} );
		$testNum++;
		}
}

####################################################
#	usage: display usage message
####################################################
sub usage
{
	my($msg, $exitCode) = @_;
	print "$msg\n" if ( defined($msg) );
	print "usage:\n";
	print "\t$0 [-v] inpur-string\n";        # run against supplied input string
	print "\t$0 [-v] -t\n";                  # run internal tests only 
	print "\t$0 -h\n";                  # dipslays this help messagfe\n";
	exit $exitCode;
}

