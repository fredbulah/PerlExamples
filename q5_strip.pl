#!/usr/bin/perl -w
####################################################
#
#	Question 5balanced parens and brackets
#	Submitted by: Fred Bulah
#	Email:        fredbulah@comcast.net
#	Mobile:       305-974-7460 | 973-214-7560
#
####################################################

=pod

=head1 NAME        

	q5_strip -- utility to strip comments from JSON-like text blocks 

=head1 SYNOPSIS    

	q5_strip [-j] filenames
	q5_strip [-j] -t 
	q5_strip -h 

=head1 PROBLEM STATEMENT

	Question 5: Suppose we want to preprocess JSON strings to strip out C style line comments.  An example might look like this:
	// this is a comment
	{ // another comment
	   true, "foo", // 3rd comment
	   "http://www.ariba.com" // comment after URL
	}
	Write a function to strip line comments without using regular expressions.  Think about the other corner cases.

=head1 DESCRIPTION 

	q5_strip removes comments from JSON-like code blocks as presented in Question 5. 

	Note: The problem posed in Question does not use true JSON format as defined in the JSON specification which is based on hierarchically grouped
	attribute-valur pairs. The sample:

	 // this is a comment
	 { // another comment
	    true, "foo", // 3rd comment
	    "http://www.ariba.com" // comment after URL
	 }

	does not pass standard validators like the ones found here:
	https://jsonformatter.curiousconcept.com/ 
	https://jsonlint.com/.  

	In point of fact comments are not part of the current JSON specification. 
	NB: there is draft JSON5 spec that does allow comments: https://www.jsonschemavalidator.net/

	q5_strip strips comments from the JSON-like syntax presented in Question 5, and can also strip comments from legal JSON format blocks.  Per the requirments 
	it does so without using regular expressions and instead uses the built-in methods index(), substr() in combination with raw, exact character matches.

	q5_strip differentiates between comments and URLs in JSON-like format, and filters out comments in allowed locations in beta strict (draft) JSON format

	q5_strip does no input format validation.  The inputs are expected to be properly formatted to produce the expected results. However q5_strip will not
	fail on bad input and will attempt to find and remove the commments and simply output the original lines if none are found. Several internal tests
	are malformatted inputs to prove this assertion.

	The options are as follows:

	-D      set debug mode
	-j      input uses legal strict JSON format
	-t      run internal rests only
	-h      display help useage message only

=head1 METHODS


	main:	main driver

	stripComments($fh):                         parent strip function that iterates through the input file invokes the appropriate strip method

	stripCommentsValidJSON($params):            strips comments from a valid JSON block 

	stripCommentsInvalidJSON($params):          strips comments from a JSON-like block

	countOccurencesOfCharInString($char, $str): counts occurrences of a char in a string

	truncateCommentAfterLastQuote($line):       truncate comment after last quote character found in the line

	findAllOccurrences($line, $pattern):        find all occurrences of a pattern in a line

	isValueInList($value, @list):               determine whether a value occurs in a list

	getListIntersectionAndDiff($list1, $lis2):  get interesection and difference between 2 list

	ltrim($string): trim leading blanks from a string

	trim($string):       trim leading and trailing blanks

	runTests:            run internal tests

	runTestSet:          runs a specific test set

	writeFile:           write lines to a file

	readOpenFile($fh):   read an open file

	openFile($fileName): open a file

	closeFile($fh):      close a file

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
use warnings;
use Fcntl;
use Getopt::Std;

our($DEBUG)             = 0;

our($COMMENT_START)     = "//";
our($LEN_COMMENT_START) = length($COMMENT_START);

our($URL_START)         = qw(http://);
our($LEN_URL_START)     = length($URL_START);

####################################################
#
#	get command line options
#
#	valid options
#
#	-h    shows usage message
#	-t    runs internal tests
#	-j    use valid jason
#	-D		debug mode
#
####################################################
my(%opts);

getopts('Dhtj', \%opts);

usage(undef, 0) if ( exists( $opts{'h'} ) );

#
#	'D' switch sets DEBUG mode
#
$DEBUG = ( exists( $opts{ 'D' } ) );

#
#	'j' switch sets valid JSON mode
#
my($validJSON) = ( exists( $opts{ 'j' } ) );

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
#	process commenad line arguments as seprate JSON files
#
my(@fileNames) = @ARGV;

main( $validJSON, @fileNames );

####################################################
#	main:
####################################################
sub main
{
	my($validJSON, @filenames) = @_;
	my($fileName);
	my($outFileName);
	my($fh);
	my(@inputLines);
	my(@outputLines);

	foreach $fileName (@filenames)
		{
		print "$0: stripping comments from file '$fileName'\n";
		$fh = openFile($fileName);
		@inputLines  = readOpenFile($fh);
		@outputLines = stripComments($fh, $fileName, $validJSON);
		closeFile($fh);
		$outFileName = "stripped-$fileName";
		writeFile($outFileName, \@outputLines);
		print "$0: completed stripping comments from file '$fileName', output saved to file '$outFileName':\n\n";
		print "input:\n",  join("\n",  @inputLines),  "\n\n";
		print "output:\n", join("\n",  @outputLines), "\n\n";
		}

}

####################################################
#	stripComments: strip comments from JSON block
####################################################
sub stripComments
{
	my($fh, $fileName, $validJSON) = @_;
	my($line);
	my($lineNum);
	my($ixComment);
	my($ixUrl);
	my($offset);
	my($params);
	my(@lines);
	my($temp);
	my($URL_START)          = qw(http://);
	my($LEN_URL_START)      = length($URL_START);
	my($stripFunctionRef)   = ($validJSON ? \&stripCommentsValidJSON : \&stripCommentsInvalidJSON);

	#
	#	iterate JSON block line-by-line and save lines stripped of comments in the array @lines
	#
	$lineNum = -1;
	while (my $line = <$fh>) 
		{
		chomp $line;
		$lineNum++;
		print "stripComments: line($lineNum)=<$line>\n" if ( $DEBUG );
		#
		#	handle case where entire line is comment first; it can be skipped
		#
		$ixComment = index($line, $COMMENT_START);
		if ( $ixComment == 0 )
			{
			print "stripComments: comment found on line $lineNum=<$line>\n" if ( $DEBUG );
			next;
			}
		#
		#	check for leading blanks and comment
		#
		$temp = ltrim($line);
		if ( index($temp, $COMMENT_START) == 0 )
			{
			print "stripComments: comment found on line $lineNum=<$line>\n" if ( $DEBUG );
			next;
			}
		#
		#	execute the strip comment function: one handles valid json, the other non-valid
		#
		$params = { 'line' => $line, 'lineNum' => $lineNum, 'fileName' => $fileName, 'lines' => \@lines };
		eval
			{
			$stripFunctionRef->( $params );
			};
		if ( $@ )
			{
			print "stripComments: error $@ processing file '$fileName' ... aborted\n";
			return ();
			}
		}

	print "stripComments: returning lines:\n", join("\n", @lines), "\n" if ( $DEBUG );

	return @lines;

}

########################################################################################################
#	stripCommentsValidJSON: string comments from JSON block
#	assumptions:
#	- syntactically correct, valid, best practice formatted JSON
#	- each line is:
#		-	single attribute/value definition:  "attribute": "value",<optional comment>
#		-	single attribute group identifier:	"group":  { | [ ,<optional comment>
#		-	hierarchical formatting: [ | { | } | ] <optional comment>
#
#	Example:
#
#	{  
#	   "name":"Bob",
#	   "sex":"Male",
#	   "address":{  
#	      "city":"San Jose",
#	      "state":"California"
#	   },
#	   "friends":[  
#	      {  
#	         "name":"Alice",
#	         "age":"20"
#	      },
#	      {  
#	         "name":"Laura",
#	         "age":"23"
#	      },
#	      {  
#	         "name":"Daniel",
#	         "age":"30"
#	      }
#	   ]
#	}
#
#k#######################################################################################################
sub stripCommentsValidJSON
{
	my($params) = @_;

	#
	#	determine if this is an attribute/value or group identifier line by tokenizing the line around ",' and ":"
	#
	my($line, $lineNum, $fileName, $lines) = ( $params->{'line'}, $params->{'lineNum'}, $params->{'fileName'}, $params->{'lines'} );
	my($colon)    = ":";
	my($comma)    = ",";
	my($lenComma) = length($comma);
	my($ix);
	if (($ix = index($line, $comma)) > 0)	# check for comma
		{
		#
		#	check to see if the comma is inside a comment
		#
		my($ixLastComment) = rindex($line, $COMMENT_START);
		if (($ixLastComment > 0) && $ixLastComment < $ix )
			{
			$line = substr($line, 0, $ixLastComment - 1);
			}
		else
			{
			#
			#	truncate the line past the comma to remove any comment
			#
			$line = substr($line, 0, $ix + $lenComma);
			}
		}
	else
		{
		#
		#	no comma found, line contains:
		#
		#		- bracket or brace plus optional comment:  open-brace | [ // comment
		#		- group identifier, colon, brace, plus optional comment:  'group': [ | open-brace // comment
		#		- attribute/value:  "attr" : "value" [ // comment ]
		#
		#	ignore leading text and truncate from the position of the comment start '//' to the end of the line
		#
		#	should be exactly 0, 2, or 4 quote charaters
		#
		my($ctQuotes)   = countOccurencesOfCharInString( '"', $line );
		if (($ctQuotes != 0) && ($ctQuotes != 2) && ($ctQuotes != 4))
			{
			die "stripCommentsValidJSON: Error: malformed JSON line <$line>: unmatched quotes\n";
			}
		if ( $ctQuotes == 0 )
			{
			if (($ix = index($line, $COMMENT_START)) > 0)
				{
				$line = substr($line, 0, $ix - 1);
				}
			}
		else 
			{
			#
			# count quotes is 2 or 4
			#
			$line = truncateCommentAfterLastQuote($line);
			}
		}

	push(@$lines, $line);


}

########################################################################################################
#
########################################################################################################
sub countOccurencesOfCharInString
{
	my($char, $str) = @_;
	my $count = () = $str =~ /\Q$char/g;
	return $count;
}

########################################################################################################
#
########################################################################################################
sub truncateCommentAfterLastQuote
{
	my($line)                    = @_;
	my($ixLastQuote)             = rindex($line, '"');
	my($ixCommentAfterLastQuote) = index($line, $COMMENT_START, $ixLastQuote + 1);
	if ($ixCommentAfterLastQuote > 0)
		{
		$line = substr($line, 0, $ixCommentAfterLastQuote - 1);
		}
	return $line;

}

########################################################################################################
#	stripCommentsInvalidJSON: string comments from JSON block
########################################################################################################
sub stripCommentsInvalidJSON
{
	my($params)                            = @_;
	my($line, $lineNum, $fileName, $lines) = ( $params->{'line'}, $params->{'lineNum'}, $params->{'fileName'}, $params->{'lines'} );
	my($ixComment);
	my($ixUrl);
	my($offset);

	#
	#	handle case were entire line is comment first; it can be skipped
	#
	$ixComment = index($line, $COMMENT_START);
	if ( $ixComment == 0 )
		{
		return;
		}
	#
	#	find all urls and comments in the line
	#
	my(@urlOccurrences)     = findAllOccurrences($line, $URL_START);
	my(@commentOccurrences) = findAllOccurrences($line, $COMMENT_START);
	#
	#	if there are no urls and no comments add the line to the list
	#
	if (($#urlOccurrences < 0) && ($#commentOccurrences < 0))
		{
		push(@$lines, $line);
		return;
		}
	#
	#	if there are no urls but at least 1 comment truncate up to the start of the first comment indicator
	#
	if (($#urlOccurrences < 0) && ($#commentOccurrences >= 0))
		{
		$line = substr( $line, 0, $commentOccurrences[0] );
		push(@$lines, $line);
		return;
		}
	#
	#	check if urls exist
	#
	if ($#urlOccurrences >= 0)
		{
		#
		#	urls exist but no comments indicates an error condition since '//' occurs in both
		#
		if ($#commentOccurrences < 0)
			{
			die "$0: ERROR: found urls but no comments on line $lineNum= '$line' in file '$fileName'\n";	
			}
		#
		#	mix of urls and comments in same line
		#	check if any comments are not part of urls by first getting the intersection of the lists of '//' and 'http://'
		#
		my($isectAndDiff) = getListIntersectionAndDiff( \@urlOccurrences, \@commentOccurrences);
		my($isect)        = $isectAndDiff->{'isect'};
		my($diff)         = $isectAndDiff->{'diff'};
		#
		#	handle case where there is no intersection, meaning '//' and 'http://' occurrences are separate
		#
		if ( $#{$isect} < 0 )
			{
			#
			#	comments start before url, the entire line is a comment, skip it
			#
			if ( $commentOccurrences[0] < $urlOccurrences[0] )
				{
				return;
				}
			#
			#	the url starts before comment
			#	find the next comment occurrence past the URL and truncate from that point
			#
			else
				{
				my($nextCommentPos);
				my($ixComments);
				for($ixComments = 0, $nextCommentPos = $commentOccurrences[$ixComments]; 
				    $nextCommentPos < $urlOccurrences[0] + length($URL_START);
					 $ixComments++, $nextCommentPos = $commentOccurrences[$ixComments]) 
						 {
						 }
				$line = substr($line, 0, $nextCommentPos - 1);
				push(@$lines, $line);
				}
			}
		else
			{
			#
			#	handle case where there is an intersection, meaning some comments '//' were flagged as part of urls 'http://'
			#	if there are no differences in the lists of occurrences then the line has no comments
			#	otherwise, if the lowest value of the differences list is only in the comments list, then the line is a comment
			#	otherwise, if the lowest value of the differences list is only in the urls list, then the line is source and not a comment
			#
			if ( $#{$diff} < 0 )
				{
				#	no differences in the lists, the line has no comments
				push(@$lines, $line);
				}
			elsif ( isValueInList( $diff->[0], @commentOccurrences ) )
				{
				#	lowest value of the differences list is only in the comments list, the line is a comment
				return;
				}
			else
				{
				#	lowest value of the differences list is only in the urls list, the line is source and not a comment
				push(@$lines, $line);
				}
			}
		}

	return;

}

########################################################################################################
#	findAllOccurrences: find all occurences of s in line
########################################################################################################
sub findAllOccurrences
{
	my($line, $s) = @_;
	my(@occurrences) = ();

	print "findAllOccurrences: entry: line=<$line> s=<$s>\n" if ( $DEBUG );

	my $offset = 0;
 	my $result = index($line, $s, $offset);

	while ($result != -1)
  		{
  		push(@occurrences, $result);
		$offset = $result + 1;
		$result = index($line, $s, $offset);
		}

	print "findAllOccurrences: return: occurrences=(", join("|", @occurrences), ") ct=$#occurrences", 
	       ($#occurrences > 0) ? ": $#occurrences occurrences found" : ": no occurrences found" , "\n" if ( $DEBUG );

	return @occurrences;
}

####################################################
#	isValueInList: return true if value is in list
####################################################
sub isValueInList
{
	my($value, @list) = @_;

	print "value=$value list=(", join("|", @list), "\n" if ( $DEBUG );

	my %params = map { $_ => 1 } @list;

	my($rc) = exists($params{$value});

	print $rc ? "$value exists in list" : "$value is not in list", "\n" if ( $DEBUG );

	return exists($params{$value});
}

########################################################################################################
#	getListIntersectionAndDiff: get list intersection and diff
########################################################################################################
sub getListIntersectionAndDiff
{
	my($list1, $list2) = @_;

	my($e, %union, %isect);

	foreach $e (@$list1, @$list2) { $union{$e}++ && $isect{$e}++ }

	my($isect) = [ sort { $a <=> $b } keys %isect ];

	my($diff);

	foreach $e (keys( %union ))
		{
		push(@$diff, $e) if ( !exists( $isect{$e} ) );
		}

	$diff = [ sort { $a <=> $b } @$diff ];

	return { 'isect' => $isect, 'diff' => $diff };

}


####################################################
#	trim: trim leading and trailing blanks
####################################################
sub trim
{ 
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s
};

####################################################
#	runTests: run internal tests
####################################################
sub runTests
{

	#
	#	invalid json data
	#

	my(@invalidJSON1) = (
"// this is a comment",
"{ // another comment",
"   true, \"foo\", // 3rd comment",
"   \"http://www.ariba.com\" // comment after URL",
"}",
);

	my(@strippedInvalidJSON1) = (
	"{",
	"  true, \"foo\",",
	" \"http://www.ariba.com\"",
	"}"
	);

	my(@invalidJSON2) = (
"{",
"   // comment before URL \"http://www.ariba.com\" // comment after URL",
"}",
);

	my(@strippedInvalidJSON2) = (
"{",
"}",
);

	my(@invalidJSON3) = (
"[{ [{ a:b,"
	);

	my(@strippedInvalidJSON3) = (
"[{ [{ a:b,"
);

	my(@invalidJSON4) = (
"This is a // junk file",
"that [ contains bad json-like and json formatted text",
);

	my(@strippedInvalidJSON4) = (
"This is a",
"that [ contains bad json-like and json formatted text",
);

	my(@invalidJSON5) = (
"This is a junk file",
"that contains no json formatting",
);

	my(@strippedInvalidJSON5) = (
"This is a junk file",
"that contains no json formatting",
);

	my(@INVALID_JSON_TESTS) = (
		{ 'input' => \@invalidJSON1, 'expected' => \@strippedInvalidJSON1 },
		{ 'input' => \@invalidJSON2, 'expected' => \@strippedInvalidJSON2 },
		{ 'input' => \@invalidJSON3, 'expected' => \@strippedInvalidJSON3 },
		{ 'input' => \@invalidJSON4, 'expected' => \@strippedInvalidJSON4 },
		{ 'input' => \@invalidJSON5, 'expected' => \@strippedInvalidJSON5 },
	);

	#
	#	run invalid json tests
	#
	my($validJSON) = 0;
	runTestSet("invalid-json-test.txt", $validJSON, @INVALID_JSON_TESTS);

	#
	#	valid json data
	#

	my(@validJSON1) = (
	"{ // comment 1  ",
	"   \"name\":\"Bob\", // comment 2 http://abc.com",
	"   \"sex\":\"Male\",",
	"   \"address\":{  ",
	"      \"city\":\"San Jose\",",
	"      \"state\":\"California\",",
	"      \"url\":\"http://www.sanjose.com\" // comment 3",
	"   },",
	"   \"friends\":[ // comment 4  ",
	"      {  ",
	"         \"name\":\"Alice\",",
	"         \"age\":\"20\"",
	"      }, // comment 5,",
	"      // comment 6",
	"      {  ",
	"         \"name\":\"Laura\",",
	"         \"age\":\"23\"",
	"      },",
	"      {  ",
	"         \"name\":\"Daniel\",",
	"         \"age\":\"30\"",
	"      }",
	"   ]",
	"}",
	);

	my(@strippedValidJSON1) = (
	"{  ",
	"   \"name\":\"Bob\",",
	"   \"sex\":\"Male\",",
	"   \"address\":{  ",
	"      \"city\":\"San Jose\",",
	"      \"state\":\"California\",",
	"      \"url\":\"http://www.sanjose.com\"",
	"   },",
	"   \"friends\":[  ",
	"      {  ",
	"         \"name\":\"Alice\",",
	"         \"age\":\"20\"",
	"      },",
	"      {  ",
	"         \"name\":\"Laura\",",
	"         \"age\":\"23\"",
	"      },",
	"      {  ",
	"         \"name\":\"Daniel\",",
	"         \"age\":\"30\"",
	"      }",
	"   ]",
	"}",
	);

	my(@VALID_JSON_TESTS) = (
		{ 'input' => \@validJSON1, 'expected' => \@strippedValidJSON1 },
	);

	#
	#	run valid json tests
	#
	$validJSON = 1;
	runTestSet("valid-json-test.txt", $validJSON, @VALID_JSON_TESTS);

}

####################################################
#	runTestSet: run internal tests
####################################################
sub runTestSet
{
	my($testSetFileName, $validJSON, @testDataSet) = @_;

	my($fh);
	my(@lines);
	my(@results);
	my($result);
	my(@actual);
	my($maxIxExpected);
	my($maxIxActual);

	foreach( my($testNum) = 0; $testNum <= $#testDataSet; $testNum++ )
		{
		writeFile($testSetFileName, $testDataSet[$testNum]->{'input'});
		$fh                 = openFile($testSetFileName);
		@actual             = stripComments($fh, $testSetFileName, $validJSON);
		$result->{'input'}  = join("\n", @{$testDataSet[$testNum]->{'input'}});
		$result->{'actual'} = @actual;
		$result->{'status'} = undef;
		$maxIxExpected      = $#{$testDataSet[$testNum]->{'expected'}};
		$maxIxActual        = $#actual;

		print "TEST# $testNum file=$testSetFileName\n",
		      "-------------------------------------\n",
				"input:\n",      $result->{'input'}, 
		      "\nexpected:\n", join("\n", @{$testDataSet[$testNum]->{'expected'}}), 
				"\nactual:\n",   join("\n", @actual), "\n"; 

		if ( $maxIxExpected != $maxIxActual )
			{
			$result->{'status'} = "FAILED";
			push(@{$result->{'errors'}}, "max index expected lines=$maxIxExpected != max index actual lines=$maxIxActual");
			}
		my($ix);
		for($ix = 0; $ix <= $maxIxExpected; $ix++)
			{
			if ( trim($testDataSet[$testNum]->{'expected'}[$ix]) ne trim($actual[$ix]) )
				{
				$result->{'status'} = "FAILED";
				push(@{$result->{'errors'}}, "expected[$ix]=<$testDataSet[$testNum]->{'expected'}[$ix]> != <$actual[$ix]>");
				}
			}
		if ( !defined( $result->{'status'} ) )
			{
			$result->{'status'} = "PASSED";
			}
		push(@results, $result);
		print "\n\n";
		}

		printf("%6s %-15s\n", "TEST#", "STATUS");
		printf("%6s %-15s\n", "-----", "------");

		for( my $testNum = 0; $testNum <= $#results; $testNum++ )
			{
			printf("%6d %-15s\n", $testNum, $results[$testNum]->{'status'});
			if ( $results[$testNum]->{'status'} =~ /FAILED/ )
				{
				print("ERRORS:\n", join("\n", @{$results[$testNum]->{'errors'}}), "\n");
				}
			}

}

####################################################
#	writeFile
####################################################
sub writeFile
{
	my($fileName, $data) = @_;
	#
	#	write the test file
	#
	open( my $fh, '>', "$fileName" ) or die "$0: Could not open file '$fileName' $!\n";

	print $fh join("\n", @$data);
	
	close($fh);
}

####################################################
#	readOpenFile
####################################################
sub readOpenFile
{
	my($fh) = @_;
	my(@lines);

	while( <$fh> )
		{
		chomp;
		push(@lines, $_);
		}

	seek $fh, 0, 0;	# reset pointer to beginning of the file

	return @lines;
	
}

####################################################
#	openFile
####################################################
sub openFile
{
	my($fileName) = @_;
	my($fh);
	
	#
	#	file tests: make sure the file exists, is plain text, not empty, and readable
	#
	if ( ! -e "$fileName" )
		{
		die "$0: error: file '$fileName' does not exist\n";
		}

	if ( ! -f "$fileName" )
		{
		die "$0: error: file '$fileName' is not a plain file\n";
		}

	if ( -z "$fileName" )
		{
		die "$0: error: file '$fileName' is empty\n";
		}

	if ( ! -r "$fileName" )
		{
		die "$0: error: file '$fileName' is not readable\n";
		}

	open($fh, '<:encoding(UTF-8)', $fileName) or die "$0: Could not open file '$fileName': : $!\n";

	return $fh;

}

####################################################
#	closeFile: close file
####################################################
sub closeFile
{
	my($fh) = @_;

	if ( $fh->fileno == fileno STDIN )
		{
		return;
		}

	close($fh);

}

####################################################
#	ltrim: trim leading whitespace
####################################################
sub ltrim
{
	my($s) = @_;
	if (!defined($s)) { return $s };
	if ( $s eq "" )   { return $s };
	my(@chars) = split(//, $s);
	my($char)  = shift @chars;
	while ($char eq ' ')
		{
		$char = shift @chars;
		}
	unshift @chars, $char;
	my($t) = join('', @chars);
	return $t;
}

####################################################
#	usage: display usage message
####################################################
sub usage
{
	my($msg, $exitCode) = @_;
	print "$msg\n" if ( defined($msg) );
	print "usage:\n";
	print "\t$0 [ -D ] -t                  # run internal tests only in JSON-like format\n";
	print "\t$0 [ -D ] -j  -t              # run internal tests only in strict JSON format\n";
	print "\t$0 [ -D ] filenames           # run against supplied filenames in JSON-like format\n"; 
	print "\t$0 [ -D ][ -j ][ filenames    # run internal tests only in strict JSON format\n";
	print "\t$0 -h                         # dipslays this help messagfe\n";
	exit $exitCode;
}

