# PerlExamples
Perl examples

author:	Fred Bulah
email:	fredbulah@comcast.net
Git:     https://github.com/fredbulah/PerlExamples

This repo contains a set of Perl examples.

The first set is from a Perl quiz issued by a Palo Alto tech firm in 12/2018. There were a set of 5 questions centered around sorting,
regexes, and reporting. The responses to thoe questions are in the scripts qX.pl. There are test text files names ending in .txt.

The files:
	
	README-Palo-Alto-Perl-Quiz.txt
	invalid-json-test-0.txt
	invalid-json-test-1.txt
	invalid-json-test.txt
	q1_histogram.pl
	q2_hash.pl
	q3_q4_bal.pl
	q5_strip.pl
	stripped-valid-json-test.txt
	valid-json-test.txt

Each script has built-in perlpod documentation and the documentation includes the original question aswell as tests.

The second set of examples demonstrate the usage of OO, design patterns, and I/O.

Some of the design patterns included: Singleton, Factory, Command.

There are examples of all variable types and references - array, hash, code - throughout. 

The Utils.pm module is fairly comprehensive and includes all types of functions: process, IPC, I/O, file management.

The second set of examples are contained in the files:

	MainDriver.pl                  Main driver
	VehicleBaseClass:              Base parent class
	CarSubclass:                   Subclass of VehicleBaseClass
	TruckSubclass:                 Subclass of VehicleBaseClass
	VehicleFactory:                Factory that creates Vehicles, Cars, Trucks
	SingletonMotorVehicleAgency:   Singleton class
	Utils.pm                       collection of utilities from a prior project named cds
	UtilsBaseTests.pm              A bare-bones test module generated for Utils.pm using 
	                               https://metacpan.org/pod/Test::StubGenerator 
											 and uses Test::More and Test::Simple as the underlying testing framework.

All are commented, and the MainDriver has perlpod documentation.

