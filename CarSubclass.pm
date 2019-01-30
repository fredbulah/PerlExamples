#!/usr/local/bin/perl
#####################################################################################
#
#	CarSubclass:	Car Subclass of vehicle
#
#	author:	Fred Bulah
#	email:	fredbulah@comcast.net
#	Git:     https://github.com/fredbulah/PerlExamples
#
#####################################################################################
package CarSubclass;

use lib '.';
use VehicleBaseClass;
use strict;
use warnings;

our @ISA = qw(VehicleBaseClass);    # inherits from VehicleBaseClass
 
#####################################################################################
#	id
#####################################################################################
sub id {
    my ($self) = @_;
    print "CarSubclass\n";
    return;
}

#####################################################################################
#	DESTROY: destructor
#####################################################################################
sub DESTROY
{
   print "CarSubclass::DESTROY called\n";
}
 
1;
