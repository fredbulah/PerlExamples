#!/bin/bash -x

perl -MTest::StubGenerator -e 'my $stub = Test::StubGenerator->new({ file => "Utils.pm" }); print $stub->gen_testfile;' > Module.t
