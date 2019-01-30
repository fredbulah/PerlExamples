#!/usr/local/bin/perl
#####################################################################################
#
#	SingletonMotorVehicleAgency:	singleton class representing Motor Vehicle Agency
#
#	author: Fred Bulah
#	email:  fredbulah@comcast.net
#	Git:    https://github.com/fredbulah/PerlExamples
#	
#
#####################################################################################
package SingletonMotorVehicleAgency;

use lib '.';
use strict;
use warnings;

my $instance = undef;

#####################################################################################
#	getInstance : return instance
#####################################################################################
sub getInstance
{
	$instance =
		{
		'address' => '366 W 31st St, New York, NY 10001',
		'hours'   => '8AM - 4:30PM EST',
		'phone'   => '(212) 645-5550',
		};
	$instance = bless $instance;
	shift unless $instance;
	return $instance;
}

#####################################################################################
#	getInfo : return all fields
#####################################################################################
sub getInfo
{
	return { 'address' => getInstance()->{'address'}, 'phone' => getInstance()->{'phone'}, 'hours' => getInstance()->{'hours'} };
}


#####################################################################################
#	getAddress : return address
#####################################################################################
sub getAddress
{
	return getInstance()->{'address'};
}

#####################################################################################
#	getHours : return hours
#####################################################################################
sub getHours
{
	return getInstance()->{'hours'};
}

#####################################################################################
#	getPhone : return phone
#####################################################################################
sub getPhone
{
	return getInstance()->{'phone'};
}


1;
