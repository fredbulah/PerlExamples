#!/usr/local/bin/perl
#####################################################################################
#
#	VehicleFactory:	Vehicle Factory
#
#	author:	Fred Bulah
#	email:	fredbulah@comcast.net
#	Git:     https://github.com/fredbulah/PerlExamples
#
#####################################################################################
package VehicleFactory;

use lib '.';
use strict;
use warnings;

#our @ISA = qw(VehicleBaseClass);    # inherits from VehicleBaseClass
 
#####################################################################################
#	build: create a car instance
#####################################################################################
sub build
{
	my $self           = shift;
	my $requested_type = shift;
	my $location       = "$requested_type.pm";
	my $class          = "$requested_type";

	require $location;

	return $class->new(@_);
}

#####################################################################################
#	DESTROY: destructor
#####################################################################################
sub DESTROY
{
   print "   VehicleFactory::DESTROY called\n";
}
 
1;
