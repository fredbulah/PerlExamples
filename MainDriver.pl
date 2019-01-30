#!/usr/local/bin/perl
#####################################################################################
#
#	MainDriver:	examples with OO, design patterns, and I/O
#
#	author:	Fred Bulah
#	email:	fredbulah@comcast.net
#	Git:     https://github.com/fredbulah/PerlExamples
#
#####################################################################################
package MainDriver;

=pod

=head1 OVERVIEW

	MainDriver is a collection of simple perl examples that demonstrate the usage of OO, design patterns, I/O 

	Classes:

	VehicleBaseClass:              Base parent class
	CarSubclass:                   Subclass of VehicleBaseClass
	TruckSubclass:                 Subclass of VehicleBaseClass
	VehicleFactory:                Factory that creates Vehicles, Cars, Trucks
	SingletonMotorVehicleAgency:   Singleton class

	Custom Module
	Utils.pm                       A use a module library containg a collection of methods that perform various actions including logging, timestamps,
	                               asynchronos and synchronous process creation, executing commands, file manipulation, and IPC.

	                               It uses nearly all of the various data types including all reference types - arrays, hashes, code, scalars - as
	                               well as various design patterns.

	The last set of examples use methods found in Utils.pm.

=cut 

use lib '.';
use VehicleFactory;
use VehicleBaseClass;
use CarSubclass;
use TruckSubclass;
use SingletonMotorVehicleAgency;
use Cwd qw(getcwd);
use Utils qw(	openLog 
					logMsg
      			closeLog
					exec_cmd
	            getListOfRegularFilesInDirectory
					findFirstExistingDirectoryInListOfFiles
               getListOfAllFilesInDirectory
				);
use Data::Dumper;
use strict;
use warnings;

my($car);
my($truck);
my($singleton);


print "$0: started\n";

#
#	create objects using factory
#

print "$0: creating a Car instance using VehicleFactory\n";

$car  = VehicleFactory->build("CarSubclass", "Tesla", "Model X", 2019);

print "$0: creating a Truck instance using VehicleFactory\n";

$truck = VehicleFactory->build("TruckSubclass", "Ford", "F-150", 2019);

#
#	create objects using constructor
#

print "$0: creating a Car instance using constructor\n";

$car  = CarSubclass->new("BMW", "X5", 2019); print "$0: creating a Truck instance using constructor\n"; 
$car  = TruckSubclass->new("Dodge", "RAM 1500", 2019);
 
#
#	create singleton
#

print "$0: creating a singleton instance SingletonMotorVehicleAgency\n";

$singleton = SingletonMotorVehicleAgency->getInstance();

print "SingletonMotorVehicleAgency:\n", Dumper($singleton), "\n";

my($info) = SingletonMotorVehicleAgency->getInfo();

print "SingletonMotorVehicleAgency->getInfo():\n", Dumper($info), "\n";

#
#	use Util.pm logging mechanism to open, write, and close a simple, non-cds [a former roprietary project] log file
#

my($cdsEnabled)   = 0;

my($logFileName) = openLog("perl-example-test", $cdsEnabled);

print "created log file '$logFileName ... writing test message'\n";

logMsg(1, "perl example test message");


print "closed log file '$logFileName\n";

print "contents of log file '$logFileName':\n";

my($cmd)    = "cat $logFileName";

my($result) = exec_cmd($cmd);

if ( $result->{ 'rc' } == 0 )
	{
	print join( "\n", @{$result->{'values'}} ), "\n";
	}
else
	{
	print "error $result->{'rc'} reading log file '$logFileName':", join( "\n", @$result->{'values'} );
	}

#
#	use Util.pm file methods to find the first directory in the current working directory
#
#	note: there are different ways to get the name of the current working directory. tha value should be the same
#
#	- from the environment variable $PWD
#	- using the Cwd module method getcwd and cwd ... getcwd is preferred because it resolves symbolic links
#
#
#

my($pwd) = "$ENV{'PWD'}";

my($cwd) = getcwd();

if ( $pwd ne $cwd )
	{
	print "warnning: the value of the current working directory \$PWD=$pwd does not match CWD:getcwd()=$cwd ... using $pwd\n";
	}

my(@listOfRegularFilesInCurrentDir) = getListOfRegularFilesInDirectory( "$pwd" );

print "list of regular files in $pwd:\n", join("\n", @listOfRegularFilesInCurrentDir), "\n\n";

my($firstDirInCurrentDir)  = findFirstExistingDirectoryInListOfFiles(@listOfRegularFilesInCurrentDir);

if ( defined($firstDirInCurrentDir) && ($firstDirInCurrentDir ne "") )
	{
	print "warning: getListOfRegularFilesInDirectory() returned a directory=$$firstDirInCurrentDir\n\n";
	}
else
	{
	print "only regular files returned as expected and no directories found\n\n";
	}

closeLog();

#
#	repeat test this time creating a temp directory and using all files found in the directory 
#

my($tmpDirName) = "tmp.$$";

#
# remote it first just in case it exists as a directory or file
#
rmdir($tmpDirName);
unlink($tmpDirName);	

if ( mkdir($tmpDirName) )
	{
	my(@listOfAllFilesInCurrentDir) = getListOfAllFilesInDirectory( "$pwd" );
	@listOfAllFilesInCurrentDir     = grep { $_ ne "$pwd" } @listOfAllFilesInCurrentDir; # remove current directory name from the list
	$firstDirInCurrentDir           = findFirstExistingDirectoryInListOfFiles(@listOfAllFilesInCurrentDir);
	print "list of all files in $pwd=\n\n", join("\n", @listOfAllFilesInCurrentDir), "\n\n";
	#
	#	check if a directory exists ... NB: it may not be the temp directory created so no need to check the name
	#
	if ( defined($firstDirInCurrentDir) && ($firstDirInCurrentDir ne "") && ( -d $firstDirInCurrentDir ) )
		{
		print "first directory found in $pwd=$firstDirInCurrentDir\n\n";
		}
	else
		{
		#
		#	should have at least found the temp directory
		#
		print "error: no directory found in current directory=$pwd\n\n";
		}
	rmdir($tmpDirName);
	}
else
	{
	print "error: could not create temp directory $tmpDirName: error code $!\n";
	}

print "$0: completed\n";


 
#####################################################################################
#	DESTROY: destructor
#####################################################################################
sub DESTROY
{
   print "MainDriver::DESTROY called\n";
}
 
1;
