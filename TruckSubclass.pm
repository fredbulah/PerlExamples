#!/usr/local/bin/perl
#####################################################################################
#
#	TruckSubclass:	Truck Subclass of vehicle
#
#	author:	Fred Bulah
#	email:	fredbulah@comcast.net
#	Git:     https://github.com/fredbulah/PerlExamples
#
#####################################################################################
package TruckSubclass;

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
    print "TruckSubclass\n";
    return;
}

#####################################################################################
#	DESTROY: destructor
#####################################################################################
sub DESTROY
{
   print "TruckSubclass::DESTROY called\n";
}
 
1;
