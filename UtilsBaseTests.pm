#!/usr/bin/perl
#####################################################################################
#
#	UtilsBaseTests:	Utils.pm base tests
#
#	author:	Fred Bulah
#	email:	fredbulah@comcast.net
#	Git:     https://github.com/fredbulah/PerlExamples
#
#####################################################################################

=pod

=head1 DESCRIPTION

This test module was generated for Utils.pm using https://metacpan.org/pod/Test::StubGenerator and uses Test::More and Test::Simple
as the underlying testing framework.

=cut

use strict;
use warnings;

use Test::More qw/no_plan/;

our($obj);

BEGIN { use_ok('Utils'); }

# Create some variables with which to test the Utils objects' methods
# Note: give these some reasonable values.  Then try unreasonable values :)
my $sourceFile      = '';
my $destPath        = '';
my $devPath         = '';
my $fileName        = '';
my $cmd             = '';
my $errno           = '';
my @fileList        = ( '', );
my $syncFlag        = '';
my $errLogFile      = '';
my @cmd             = ( '', );
my $controlFileName = '';
my $filePath        = '';
my $directoryName   = '';
my $filter          = '';
my $logFilePrefix   = '';
my $messageState    = '';
my $stateId         = '';
my $usbState        = '';
my $usbStateId      = '';
my $level           = '';
my $msg             = '';
my $truncate        = '';
my %hash            = ( '' => '', );
my $gui_messages_fh = '';
my $msgType         = '';
my $usbId           = '';
my $color           = '';
my $fmt             = '';
my $pid             = '';

# And now to test the methods/subroutines.
ok( $obj->clearErrmsg(), 'can call $obj->clearErrmsg() without params' );

ok( $obj->clearErrno(), 'can call $obj->clearErrno() without params' );

ok( $obj->closeGUIMessages(),
    'can call $obj->closeGUIMessages() without params' );

ok( $obj->closeLog(), 'can call $obj->closeLog() without params' );

ok( $obj->copyFileAsync( $sourceFile, $destPath ),
    'can call $obj->copyFileAsync()' );
ok( $obj->copyFileAsync(), 'can call $obj->copyFileAsync() without params' );

ok( $obj->copyFileSync( $sourceFile, $destPath ),
    'can call $obj->copyFileSync()' );
ok( $obj->copyFileSync(), 'can call $obj->copyFileSync() without params' );

ok( $obj->decrementAccessControlSemaphore(),
    'can call $obj->decrementAccessControlSemaphore() without params' );

ok(
    $obj->deviceHasEnoughSpaceForFile( $devPath, $fileName ),
    'can call $obj->deviceHasEnoughSpaceForFile()'
);
ok( $obj->deviceHasEnoughSpaceForFile(),
    'can call $obj->deviceHasEnoughSpaceForFile() without params' );

ok( $obj->exec_cmd($cmd), 'can call $obj->exec_cmd()' );
ok( $obj->exec_cmd(),     'can call $obj->exec_cmd() without params' );

ok( $obj->fail_exit($errno), 'can call $obj->fail_exit()' );
ok( $obj->fail_exit(),       'can call $obj->fail_exit() without params' );

ok(
    $obj->findFirstExistingDirectoryInListOfFiles(@fileList),
    'can call $obj->findFirstExistingDirectoryInListOfFiles()'
);
ok( $obj->findFirstExistingDirectoryInListOfFiles(),
    'can call $obj->findFirstExistingDirectoryInListOfFiles() without params' );

ok( $obj->forkProcess( $syncFlag, $errLogFile, @cmd ),
    'can call $obj->forkProcess()' );
ok( $obj->forkProcess(), 'can call $obj->forkProcess() without params' );

ok(
    $obj->forkProcessAsync( $errLogFile, @cmd ),
    'can call $obj->forkProcessAsync()'
);
ok( $obj->forkProcessAsync(),
    'can call $obj->forkProcessAsync() without params' );

ok(
    $obj->forkProcessSync( $errLogFile, @cmd ),
    'can call $obj->forkProcessSync()'
);
ok( $obj->forkProcessSync(),
    'can call $obj->forkProcessSync() without params' );

ok(
    $obj->getAvailableSpaceOnDevice($devPath),
    'can call $obj->getAvailableSpaceOnDevice()'
);
ok( $obj->getAvailableSpaceOnDevice(),
    'can call $obj->getAvailableSpaceOnDevice() without params' );

ok( $obj->getCdsConfiguration(),
    'can call $obj->getCdsConfiguration() without params' );

ok(
    $obj->getControlFileContentsAsListOfFileNames($controlFileName),
    'can call $obj->getControlFileContentsAsListOfFileNames()'
);
ok( $obj->getControlFileContentsAsListOfFileNames(),
    'can call $obj->getControlFileContentsAsListOfFileNames() without params' );

ok( $obj->getErrmsg(), 'can call $obj->getErrmsg() without params' );

ok( $obj->getErrno(), 'can call $obj->getErrno() without params' );

ok(
    $obj->getFileNameFromFullPath($filePath),
    'can call $obj->getFileNameFromFullPath()'
);
ok( $obj->getFileNameFromFullPath(),
    'can call $obj->getFileNameFromFullPath() without params' );

ok( $obj->getFileSize($fileName), 'can call $obj->getFileSize()' );
ok( $obj->getFileSize(), 'can call $obj->getFileSize() without params' );

ok( $obj->getInitialUSBState(),
    'can call $obj->getInitialUSBState() without params' );

ok( $obj->getInitialUSBStateId(),
    'can call $obj->getInitialUSBStateId() without params' );

ok( $obj->getListOfFilesInDirectory( $directoryName, $filter ),
    'can call $obj->getListOfFilesInDirectory()' );
ok( $obj->getListOfFilesInDirectory(),
    'can call $obj->getListOfFilesInDirectory() without params' );

ok( $obj->getLogFileName($logFilePrefix), 'can call $obj->getLogFileName()' );
ok( $obj->getLogFileName(), 'can call $obj->getLogFileName() without params' );

ok( $obj->getNextUSBState($messageState), 'can call $obj->getNextUSBState()' );
ok( $obj->getNextUSBState(),
    'can call $obj->getNextUSBState() without params' );

ok( $obj->getNextUSBStateId($stateId), 'can call $obj->getNextUSBStateId()' );
ok( $obj->getNextUSBStateId(),
    'can call $obj->getNextUSBStateId() without params' );

ok( $obj->getNumberOfWaitingProcesses(),
    'can call $obj->getNumberOfWaitingProcesses() without params' );

ok(
    $obj->getUSBStateColorName($usbState),
    'can call $obj->getUSBStateColorName()'
);
ok( $obj->getUSBStateColorName(),
    'can call $obj->getUSBStateColorName() without params' );

ok(
    $obj->getUSBStateFromStateId($usbStateId),
    'can call $obj->getUSBStateFromStateId()'
);
ok( $obj->getUSBStateFromStateId(),
    'can call $obj->getUSBStateFromStateId() without params' );

ok(
    $obj->getUSBStateIdFromState($usbState),
    'can call $obj->getUSBStateIdFromState()'
);
ok( $obj->getUSBStateIdFromState(),
    'can call $obj->getUSBStateIdFromState() without params' );

ok( $obj->incrementAccessControlSemaphore(),
    'can call $obj->incrementAccessControlSemaphore() without params' );

ok( $obj->logMsg( $level, $msg ), 'can call $obj->logMsg()' );
ok( $obj->logMsg(), 'can call $obj->logMsg() without params' );

ok( $obj->openGUIMessages($truncate), 'can call $obj->openGUIMessages()' );
ok( $obj->openGUIMessages(),
    'can call $obj->openGUIMessages() without params' );

ok( $obj->openLog($logFilePrefix), 'can call $obj->openLog()' );
ok( $obj->openLog(),               'can call $obj->openLog() without params' );

ok( $obj->printHash( $msg, %hash ), 'can call $obj->printHash()' );
ok( $obj->printHash(), 'can call $obj->printHash() without params' );

ok(
    $obj->receiveGUIMessage($gui_messages_fh),
    'can call $obj->receiveGUIMessage()'
);
ok( $obj->receiveGUIMessage(),
    'can call $obj->receiveGUIMessage() without params' );

ok( $obj->sendGUIMessage( $msgType, $usbId, $usbStateId ),
    'can call $obj->sendGUIMessage()' );
ok( $obj->sendGUIMessage(), 'can call $obj->sendGUIMessage() without params' );

ok( $obj->setDebug(), 'can call $obj->setDebug() without params' );

ok( $obj->setErrmsg(), 'can call $obj->setErrmsg() without params' );

ok( $obj->setErrno(), 'can call $obj->setErrno() without params' );

ok( $obj->setLogLevel($level), 'can call $obj->setLogLevel()' );
ok( $obj->setLogLevel(),       'can call $obj->setLogLevel() without params' );

ok(
    $obj->setUSBStateColorName( $usbState, $color ),
    'can call $obj->setUSBStateColorName()'
);
ok( $obj->setUSBStateColorName(),
    'can call $obj->setUSBStateColorName() without params' );

ok( $obj->ts($fmt), 'can call $obj->ts()' );
ok( $obj->ts(),     'can call $obj->ts() without params' );

ok( $obj->ts_YYYYMMDD_HHMMSS(),
    'can call $obj->ts_YYYYMMDD_HHMMSS() without params' );

ok(
    $obj->writeMessageToFile( $fileName, $msg ),
    'can call $obj->writeMessageToFile()'
);
ok( $obj->writeMessageToFile(),
    'can call $obj->writeMessageToFile() without params' );

ok( $obj->writePidKillScript($pid), 'can call $obj->writePidKillScript()' );
ok( $obj->writePidKillScript(),
    'can call $obj->writePidKillScript() without params' );

