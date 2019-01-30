#!/usr/bin/perl -w
####################################################
#
#	Question 2:   hash
#	Submitted by: Fred Bulah
#	Email:        fredbulah@comcast.net
#	Mobile:       305-974-7460 | 973-214-7560
#
####################################################


=pod

=head1 NAME        

	q2_hash -- create sorted hashes

=head1 SYNOPSIS    

	q2_hash
	q2_hash -h 

=head1 PROBLEM STATEMENT

	Question 2: 

	Write a Perl program to create an associative array ("hash") named "last_name" 
	whose keys are the five first names "Mary", "James", "Thomas", "William", "Elizabeth". 
	Set the corresponding values for these keys to be "Li", "O'Day", "Miller", "Garcia", "Davis". 
	Then print out the five full names, each on its own line, sorted primarily by length of last name 
	and with a secondary sort alphabetically by first name. 

=head1 DESCRIPTION 

	q2_hash creates the hash and sorts it as specified in Question 2.
	
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


print "\n";
print "$0: creating the last_name hash\n";

my(%last_name) = (
	"Mary"      => "Li",
	"James"     => "O'Day",
	"Thomas"    => "Miller",
	"William"   => "Garcia", 
	"Elizabeth" => "Davis"
);

print "\n";
print "$0: last_name hash sorted ascecending by length of the last names:\n\n";

printf("%-10s %-15s %-20s\n", "LAST NAME", "FIRST_NAME", "LAST NAME LENGTH");
printf("%-10s %-15s %-20s\n", "=========", "==========", "================");

my($key);

foreach $key (sort {length($last_name{$a}) cmp length($last_name{$b})} keys %last_name) 
	{
   printf("%-10s %-15s %3d\n", $last_name{$key}, $key, length($last_name{$key}));
	}

print "\n";
print "$0: last_name hash sorted ascecending by first name:\n\n";

printf("%-10s %-15s\n", "FIRST NAME", "LAST NAME");
printf("%-10s %-15s\n", "=========", "==========");

foreach $key (sort { $a cmp $b } keys %last_name) 
	{
   printf("%-10s %-15s\n", $key, $last_name{$key});
	}

