#!/usr/bin/perl
#####################################################################################
#
#	Utils.pm:	   utilities to support CDS project
#	
#	author:        fred bulah
#	email:		   fmbulah@comcast.net
#	Last update:	04/21/2011
#	Copyright (C)  Culture City Live Inc.  All Rights Reserved
#
#	$Id$
#
#####################################################################################


=pod

=head1 NAME

	Utils.pm: collection of utilities to support the cds project.
	Methods in the EXPORT_OK list are the interfaces that can be imported by clients

=cut

package Utils;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
use Data::Dumper;
use File::Basename qw( fileparse );
use File::Find;
use FileHandle;
use Fcntl qw(O_RDWR O_TRUNC);
use Filesys::Df;
use IPC::SysV qw(IPC_CREAT IPC_SET GETVAL SETVAL GETNCNT GETZCNT);
use POSIX qw(sys_wait_h strftime);

$VERSION    = 1.00;
@ISA        = qw(Exporter);
@EXPORT     = qw( decrementaccesscontrolsemaphore
                  incrementaccesscontrolsemaphore
                  devicehasenoughspaceforfile
                  getcdsconfiguration
                  getlistoffilesindirectory
                  getlistofallfilesindirectory
                  getcontrolfilecontentsaslistoffilenames
                  getavailablespaceondevice
                  getfilesize
                  findfirstexistingdirectoryinlist
                  copyfileasync
                  copyfilesync
                  forkprocessasync
                  forkprocesssync
                  forkprocess
                  writemessagetofile
                  getfilenamefromfullpath
                  getudevinfo
                  getlogfilename
                  getnumberofwaitingprocesses
                  geterrno
                  geterrmsg
                  seterrno
                  seterrmsg
                  clearerrno
                  clearerrmsg
                  closelog
                  exec_cmd
                  fail_exit
                  ts
                  setdebug
                  openlog
                  logmsg
                  setloglevel
                  printhash
                  writepidkillscript
                  openGUIMessages
                  closeGUIMessages
                  sendGUIMessage
                  receiveGUIMessage
                  getUSBStateIdFromState
                  getUSBStateFromStateId
                  getInitialUSBStateId
                  getInitialUSBState
                  getNextUSBStateId
                  getNextUSBState
                  getUSBStateColorName
                  setUSBStateColorName
                  $debug
                  $blksize_1k
                  $ix_filesize
                  $copy_prog
                  $usbevent_cmd
                  $extension
                  $cf_data_cache_dir
                  $cf_device
                  $cf_file_filter
                  $cf_location
                  $cf_source_dir
                  $log_file_name
                  $errnog
                  $GUI_MESSAGES
                  $ERRMSG
                  $E_NO_ERROR
                  $E_CANNOT_OPEN_LOGFILE
                  $E_NO_DATA_CACHE_DIR_IN_CONFIG
                  $E_DATA_CACHE_DOES_NOT_EXIST
                  $E_DATA_CACHE_NOT_WRITABLE
                  $E_DATA_CACHE_NOT_READABLE
                  $E_DEVICE_MOUNT_POINT_DOES_NOT_EXIST
                  $E_DEVICE_MOUNT_POINT_NOT_WRITABLE
                  $E_DEVICE_MOUNT_POINT_NOT_READABLE
                  $E_NO_RECORDER_INFO_IN_CONFIG
                  $E_NO_ACCESS_CTRL_SEMKEY
                  $E_SEMGET_FAILED
                  $E_SEMOP_FAILED
                  $E_SEMCTL_FAILED
                  $E_SRC_DIR_DOES_NOT_EXIST
                  $E_SRC_DIR_NAME_EMPTY
                  $E_CANNOT_OPEN_GUI_MESSAGES_FILE
                  );

@EXPORT_OK  = qw( decrementAccessControlSemaphore
                  incrementAccessControlSemaphore
                  deviceHasEnoughSpaceForFile
                  getCdsConfiguration
                  getListOfRegularFilesInDirectory
                  getListOfAllFilesInDirectory
                  getControlFileContentsAsListOfFileNames
                  getAvailableSpaceOnDevice
                  getFileSize
                  findFirstExistingDirectoryInListOfFiles
                  copyFileAsync
                  copyFileSync
                  forkProcessAsync
                  forkProcessSync
                  forkProcess
                  writeMessageToFile
                  getFileNameFromFullPath
                  getUdevInfo
                  exec_cmd
                  fail_exit
                  ts
                  setDebug
                  openLog
                  getLogFileName
                  getNumberOfWaitingProcesses
                  getErrno
                  getErrmsg
                  setErrno
                  setErrmsg
                  clearErrno
                  clearErrmsg
                  closeLog
                  logMsg
                  setLogLevel
                  printHash
                  writePidKillScript
                  openGUIMessages
                  closeGUIMessages
                  sendGUIMessage
                  receiveGUIMessage
                  getUSBStateIdFromState
                  getUSBStateFromStateId
                  getInitialUSBStateId
                  getInitialUSBState
                  getNextUSBStateId
                  getNextUSBState
                  getUSBStateColorName
                  setUSBStateColorName
                  $BLKSIZE_1K
                  $IX_FILESIZE
                  $CF_DATA_CACHE_DIR
                  $CF_DEVICE
                  $CF_FILE_FILTER
                  $CF_LOCATION
                  $CF_SOURCE_DIR
                  $COPY_PROG
                  $USBEVENT_CMD
                  $EXTENSION
                  $LOG_FILE_NAME
                  $ERRNO
                  $ERRMSG
                  $GUI_MESSAGES
                  $E_NO_ERROR
                  $E_CANNOT_OPEN_LOGFILE
                  $E_NO_DATA_CACHE_DIR_IN_CONFIG
                  $E_DATA_CACHE_DOES_NOT_EXIST
                  $E_DATA_CACHE_NOT_WRITABLE
                  $E_DATA_CACHE_NOT_READABLE
                  $E_DEVICE_MOUNT_POINT_DOES_NOT_EXIST
                  $E_DEVICE_MOUNT_POINT_NOT_WRITABLE
                  $E_DEVICE_MOUNT_POINT_NOT_READABLE
                  $E_NO_RECORDER_INFO_IN_CONFIG
                  $E_NO_ACCESS_CTRL_SEMKEY
                  $E_SEMGET_FAILED
                  $E_SEMOP_FAILED
                  $E_SEMCTL_FAILED
                  $E_SRC_DIR_DOES_NOT_EXIST
                  $E_SRC_DIR_NAME_EMPTY
                  $E_CANNOT_OPEN_GUI_MESSAGES_FILE
                  );

####################################################
#
#	error exit status codes
#
####################################################
our($ERRNO);
our($ERRMSG);
our($SUCCESS)                              =  0;
our($E_NO_ERROR)                           =  $SUCCESS;
our($E_CANNOT_OPEN_LOGFILE)                =  1;
our($E_NO_DATA_CACHE_DIR_IN_CONFIG)        =  1;
our($E_DATA_CACHE_DOES_NOT_EXIST)          =  2;
our($E_DATA_CACHE_NOT_WRITABLE)            =  3;
our($E_DATA_CACHE_NOT_READABLE)            =  4;
our($E_DEVICE_MOUNT_POINT_DOES_NOT_EXIST)  =  5;
our($E_DEVICE_MOUNT_POINT_NOT_WRITABLE)    =  6;
our($E_DEVICE_MOUNT_POINT_NOT_READABLE)    =  7;
our($E_NO_RECORDER_INFO_IN_CONFIG)         =  8;
our($E_NO_ACCESS_CTRL_SEMKEY)              =  9;
our($E_SEMGET_FAILED)                      = 10;
our($E_SEMOP_FAILED)                       = 11;
our($E_SEMCTL_FAILED)                      = 12;
our($E_SRC_DIR_DOES_NOT_EXIST)             = 13;
our($E_SRC_DIR_NAME_EMPTY)                 = 14;
our($E_CANNOT_OPEN_GUI_MESSAGES_FILE)      = 15;

####################################################
#	package globals
####################################################
our($DEBUG)               = 0;
our($BLKSIZE_1K)          = 1000;
our($CDS_CONFIG_FILE)     = "/etc/cds/cds_configuration.xml";
our($IX_FILESIZE)         = 7;
our($COPY_PROG)           = "/usr/local/bin/xcpf";
our($USBEVENT_CMD)        = "/usr/local/bin/usbevent.sh";
our($EXTENSION)           = ".txt";
our($LOG_FILE_NAME)       = undef;
our($CF_DATA_CACHE_DIR)   = 'data_cache';                     # parameter name in cds_configuration.xml
our($CF_DEVICE)           = 'device';                         # parameter name in cds_configuration.xml
our($CF_LOCATION)         = 'location';                       # parameter name in cds_configuration.xml
our($CF_SOURCE_DIR)       = 'source_dir';                     # parameter name in cds_configuration.xml
our($CF_FILE_FILTER)      = 'files';                          # parameter name in cds_configuration.xml
our($CF_DATA_CACHE)       = 'data_cache';                     # parameter name in cds_configuration.xml
our($CF_ACCESS_CTRL_KEY)  = 'access_control_key';             # parameter name in cds_configuration.xml
our($YYYYMMDD_HHMMSS_FMT) = "%Y%m%d_%H%M%S";

####################################################
#	GUI support
####################################################
our($GUI_MESSAGES)                = "/cds/gui_messages";
our($DISCONNECTED_IDLE_STATE_ID)  = 0;
our($CONNECTED_READY_STATE_ID)    = 1;
our($COPYING_DATA_BUSY_STATE_ID)  = 2;
our($DISCONNECTED_IDLE_STATE)     = "DISCONNETED/IDLE";
our($CONNECTED_READY_STATE)       = "CONNECTED/READY";
our($COPYING_DATA_BUSY_STATE)     = "COPYING DATA/BUSY";

my(@USB_STATES)   = (
	$DISCONNECTED_IDLE_STATE,  # $DISCONNECTED_IDLE_STATE_ID = 0
	$CONNECTED_READY_STATE,    # $CONNECTED_READY_STATE_ID   = 1
	$COPYING_DATA_BUSY_STATE,  # $COPYING_DATA_BUSY_STATE_ID = 2
	);

my(%USB_STATES)   = (
	$DISCONNECTED_IDLE_STATE   =>  $DISCONNECTED_IDLE_STATE_ID,  # 0
	$CONNECTED_READY_STATE     =>  $CONNECTED_READY_STATE_ID,    # 1
	$COPYING_DATA_BUSY_STATE   =>  $COPYING_DATA_BUSY_STATE_ID,  # 2
	);

my(%USB_STATE_COLORS)   = (
	$DISCONNECTED_IDLE_STATE   => "orange",
	$CONNECTED_READY_STATE     => "green",
	$COPYING_DATA_BUSY_STATE   => "yellow",
);

our($DEFAULT_USB_STATE_COLOR) = "white";

our($CT_USB_STATES) = $#USB_STATES + 1;

####################################################
#	package locals
####################################################
my($CDS_CONFIG_XML);
my($CDS_CONFIG);
my($DEVPATH)              = "DEVPATH";
my($UDEVINFOCMDTEMPLNAME) = "/sbin/udevadm info --query all --name=%s";
my($UDEVINFOCMDTEMPLPATH) = "/sbin/udevadm info --query all --path=%s";
my($LOG_LEVEL)            = 1;
my($LOGFILE_NAME_TEMPLATE)= "%s/%s.%d.%s.log";
my($LOGFILEHANDLE);
my($GUI_MESSAGES_FILEHANDLE);

########################################################################################################
#	getListOfRegularFilesInDirectory: return a list of regular files in a directory. If a filter is 
#	                                  passed, then each only files whose names match that 
#                                    case-sensitive filter are returned
########################################################################################################
sub getListOfRegularFilesInDirectory
{
	my($directoryName, $filter) = @_;
	my(@filteredList);

	logMsg( 1, "getListOfRegularFilesInDirectory: directoryName=$directoryName filter=$filter\n" );

	# return empty list if no directory name is supplied or the name supplied is not a directoy

	if ( !$directoryName )
		{
		logMsg( 1, "getListOfRegularFilesInDirectory: return empty list: directoryName=<$directoryName> is empty\n" );
		setErrno($E_SRC_DIR_NAME_EMPTY);
		setErrmsg("ERROR $!: SOURCE DIRECTORY $directoryName IS EMPTY" );
		return undef;
		}

	if ( ! -d "$directoryName" )
		{
		logMsg( 1, "getListOfRegularFilesInDirectory: return empty list: directoryName=<$directoryName> does not exist or is invalid\n" );
		setErrno($E_SRC_DIR_DOES_NOT_EXIST);
		setErrmsg("ERROR $!: SOURCE DIRECTORY $directoryName DOES NOT EXIST OR IS INVALID" );
		return undef;
		}

	#
	# get list of all regular files underneath the directory. 
	#
	if ( defined( $filter ) )
		{
		find sub { push(@filteredList, $File::Find::name) if ( -f && ($_ =~ /$filter/) ) }, ( $directoryName );
		}
	else
		{
		find sub { push(@filteredList, $File::Find::name) if ( -f ) }, ( $directoryName );
		}

	logMsg( 1, "getListOfRegularFilesInDirectory: return filteredList=\n\t" . join ( "\n\t", @filteredList ) . "\n" );

	return @filteredList

}

########################################################################################################
#
#	getListOfAllFilesInDirectory: return list of all files in a directory
#
########################################################################################################
sub getListOfAllFilesInDirectory
{
	my($dir)    = @_;
	my @listOfFiles;
	my($wanted) = sub {
		push @listOfFiles, $File::Find::name;
		return;
		};
	find( $wanted, $dir);
	return @listOfFiles;	
}

########################################################################################################
#
#	deviceHasEnoughSpaceForFile: verify that the supplied file system device path has enough space
#	                             to store the given file
########################################################################################################
sub deviceHasEnoughSpaceForFile
{
	my($devPath, $fileName ) = @_;
	logMsg( 1, "deviceHasEnoughSpaceForFile: entry: devPath=$devPath file=$fileName\n" );
	my($currDeviceFreeSpace) = getAvailableSpaceOnDevice( $devPath );
	my($fileSize)            = getFileSize( $fileName );
	my($fileCanFit)          = $currDeviceFreeSpace > ($fileSize + $BLKSIZE_1K);
	logMsg( 1, "deviceHasEnoughSpaceForFile: return: canFit=$fileCanFit size=$fileSize fresSpeace=$currDeviceFreeSpace\n" );
	return $fileCanFit;
}

########################################################################################################
#	getAvailableSpaceOnDevice:	get available space on a device 
########################################################################################################
sub getAvailableSpaceOnDevice
{
	my($devPath) = @_;
	my($ref) = df($devPath);
 	return $ref->{bavail} * $BLKSIZE_1K;
}

########################################################################################################
#	getFileSize: return the size of a file
########################################################################################################
sub getFileSize
{
	my($fileName) = @_;

	return undef if ( !defined($fileName) );

	return undef if ( ! -e $fileName );

	return (stat($fileName))[$IX_FILESIZE];
}

########################################################################################################
#	findFirstExistingDirectoryInListOfFiles: find the first directory in a list of files
########################################################################################################
sub findFirstExistingDirectoryInListOfFiles
{
	my(@fileList) = @_;
	logMsg( 1, "findFirstExistingDirectoryInListOfFiles: fileList=\n" . join("\n", @fileList) . ")\n");
	foreach ( @fileList )
		{
		my($e) = 0;
		my($d) = 0;
		my($l) = "";
		$e = 1 if ( -e "$_" );
		$d = 1 if ( -d "$_" );
		my(@l) = `ls -l "$_" 2>&1`;
		my(@m) = `ls -l "/media" 2>&1`;
		my(@f) = `df 2>&1`;
		logMsg( 1, "findFirstExistingDirectoryInListOfFiles: dir=$_ e=$e d=$d l=\n" . join( "\n", @l) . "\nm=\n" . 
		                                                                              join( "\n", @m) . "\nf=\n" . 
																												join( "\n", @f) . "\n" );
		if ( -e "$_" &&  -d "$_" )
			{
			logMsg( 1, "findFirstExistingDirectoryInListOfFiles: return $_\n");
			return $_;
			}
		}
	logMsg( 1, "findFirstExistingDirectoryInListOfFiles: return undef because no directories were found in list\n");
	return undef;
}

########################################################################################################
#	copyFileAsync: asynchronously copy a file by forking a child process
########################################################################################################
sub copyFileAsync
{
	my($sourceFile, $destPath) = @_;
	logMsg(1, "copyFileAsync: sourceFile=$sourceFile destPath=$destPath pid=$$\n" );
	my($cmd) = qq($COPY_PROG $sourceFile $destPath);
	forkProcessAsync( $LOG_FILE_NAME, ( $cmd ) );
	logMsg(1, "copyFileAsync: return after executing '$cmd'\n");
}


########################################################################################################
#	copyFileSync: synchronously copy a file
########################################################################################################
sub copyFileSync
{
	my($sourceFile, $destPath) = @_;
	logMsg(1, "copyFileSync: sourceFile=$sourceFile destPath=$destPath pid=$$\n" );
	my($cmd)    = qq($COPY_PROG $sourceFile $destPath);
	my($result) = exec_cmd($cmd);
	if ( $result->{rc} == 0 )
		{
		logMsg(1, "copyFileSync: return $result->{rc} successfully copied $sourceFile to $destPath\n");
		}
	else
		{
		logMsg(1, "copyFileSync: error $result->{rc} copying $sourceFile to $destPath: " . join(" ", @{$result->{values}}) . "\n");
		}

	return $result->{rc};
}

########################################################################################################
#	forkProcessAsync: fork a process asynchronously to run the supplied command
########################################################################################################
sub forkProcessAsync
{
	my($errLogFile, @cmd) = @_;
	return( forkProcess(0, $errLogFile, @cmd) );
}

########################################################################################################
#	forkProcessAsync: fork a process synchronously to run the supplied command
########################################################################################################
sub forkProcessSync
{
	my($errLogFile, @cmd) = @_;
	return( forkProcess(1, $errLogFile, @cmd ) );
}

########################################################################################################
#	forkProcessAsync: fork a process asynchronously to run the supplied command
########################################################################################################
sub forkProcess
{
	my($syncFlag, $errLogFile, @cmd) = @_;
	my($pid);

	logMsg(1, "forkProcess: syncFlag=$syncFlag errLogFile=$errLogFile cmd=@cmd\n" );

	if ( $pid = fork() )
		{
		if ( $syncFlag )
			{
			$SIG{CHLD} = sub { 1 while( $pid = waitpid(-1, WNOHANG) ) > 0 };
			}
		return $pid;
		}
	elsif ( defined( $pid ) )
		{
		writePidKillScript( $pid );
		exec( @cmd ) or writeMessageToFile( $errLogFile, "exec failed for cmd: " . join(" ", @cmd) . "\n" );
		exit 0;
		}
	else
		{
		return undef;
		}
}

########################################################################################################
#	writeMessageToFile: write a text message to a file
########################################################################################################
sub writeMessageToFile
{
	my($fileName, $msg) = @_;
	my($rc) = 0;
	if ( defined($fileName) )
		{
		if ( open( FILE, ">$fileName" ) )
			{
			print FILE $msg;
			close(FILE);
			$rc = 1;
			}
		}
	else
		{
		print STDERR $msg;
		}
	return $rc;
}

########################################################################################################
#	getFileNameFromFullPath: extract the file name portion from a full path spec
########################################################################################################
sub getFileNameFromFullPath
{
	my($filePath) = @_;
	my($file, undef, undef) = fileparse( $filePath, qr/\.[^.]*/ );
	return $file;
}

########################################################################################################
#	exec_cmd: run a command from a subshell
########################################################################################################
sub exec_cmd
{
	my($cmd)    = @_;

	my(@rc)     = `$cmd 2>&1`;

	my($result) = { 'rc' => $?, 'values' => [ @rc ] }; 

	return $result;

}

########################################################################################################
#	fail_exit:  exit with a error code
########################################################################################################
sub fail_exit
{
	my($errno) = @_;
	exit $errno;
}

#####################################################################################
#  ts_YYYYMMDD_HHMMSS: timestamp in YYYYMMDD_HHMMSS format
#####################################################################################
sub ts_YYYYMMDD_HHMMSS
{
	return ts($YYYYMMDD_HHMMSS_FMT);
}

#####################################################################################
#  ts: output timestamp in the supplied format
#####################################################################################
sub ts
{
	my($fmt) = @_;
	$fmt = (defined($fmt) ? $fmt : $YYYYMMDD_HHMMSS_FMT);
	return strftime $fmt, localtime( time() );
}

#####################################################################################
#  setDebug
#####################################################################################
sub setDebug
{
   $DEBUG = shift;
}

#####################################################################################
#  openLog: create a logfile
#####################################################################################
sub openLog
{
	my($logFilePrefix, $cdsEnabled) = @_;
	$LOG_FILE_NAME     = getLogFileName( $logFilePrefix, $cdsEnabled ) if ( !defined( $LOG_FILE_NAME ) );
	$LOGFILEHANDLE     = FileHandle->new( ">$LOG_FILE_NAME" );
	if ( defined( $LOGFILEHANDLE ) )
		{
		$LOGFILEHANDLE->autoflush();
		}
	else
		{
		print STDERR "$0: *** FATAL ERROR *** $! OPENING LOG FILE '$LOG_FILE_NAME' ... EXITING WITH STATUS CODE = $E_CANNOT_OPEN_LOGFILE\n";
		exit $E_CANNOT_OPEN_LOGFILE;
		}

	return $LOG_FILE_NAME;

}

#####################################################################################
#  
#####################################################################################
sub getLogFileName
{
	my($logFilePrefix, $cdsEnabled) = @_;
	my($cds_config);
	my($logFileName);
	#
	# the non-cds default log file goes into the current dirctory
	#
	if ( !$cdsEnabled )
		{
		$logFileName = sprintf( $LOGFILE_NAME_TEMPLATE, $ENV{'PWD'}, $logFilePrefix, $$, ts_YYYYMMDD_HHMMSS() );
		}
	else
		{
		$cds_config  = getCdsConfiguration();
		$logFileName = sprintf( $LOGFILE_NAME_TEMPLATE, $cds_config->{'logs'}{'directory'}, getFileNameFromFullPath($logFilePrefix), $$, ts_YYYYMMDD_HHMMSS() );
		}
	return $logFileName;
}

#####################################################################################
#  
#####################################################################################
sub closeLog
{
	$LOGFILEHANDLE->close() if ( defined( $LOGFILEHANDLE ) );
}

#####################################################################################
#  
#####################################################################################
sub logMsg
{
	my($level, $msg) = @_;
	print $LOGFILEHANDLE ts() . " $msg" if ( defined($LOGFILEHANDLE) && ($level <= $LOG_LEVEL) );
}

#####################################################################################
#  
#####################################################################################
sub setErrno
{
	$ERRNO = $_[0];
}

#####################################################################################
#  
#####################################################################################
sub setErrmsg
{
	$ERRMSG = @_;
}

#####################################################################################
#  
#####################################################################################
sub clearErrno
{
	setErrno($E_NO_ERROR);
}

#####################################################################################
#  
#####################################################################################
sub clearErrmsg
{
	setErrmsg(undef);
}


#####################################################################################
#  
#####################################################################################
sub getErrno
{
	return $ERRNO;
}

#####################################################################################
#  
#####################################################################################
sub getErrmsg
{
	return $ERRMSG;
}

#####################################################################################
#  
#####################################################################################
sub setLogLevel
{
	my($level) = @_;
	$LOG_LEVEL = $level;
}

####################################################
#
####################################################
sub printHash
{
	my($msg, %hash) = @_;
	logMsg(1, "$msg\n");
	my($h);
	foreach (sort(keys(%hash)))
		{
		$h .= "$_=$hash{$_}\n";
		}
	logMsg(1, $h);
	return;
}

#####################################################################################
#  
#####################################################################################
sub writePidKillScript
{
	my($pid)        = @_;
	my($scriptName) =  "/tmp/kill_$$.sh";
	open( SCRIPT, ">$scriptName" ) or return;
	print SCRIPT "kill $pid\n";
	close(SCRIPT);
	chmod 0755, $scriptName;
}

#####################################################################################
#
#	GUI support  
#
#####################################################################################

#####################################################################################
#  
#####################################################################################
sub openGUIMessages
{
	my($truncate) = @_;
	my($flag)     = ($truncate ? O_RDWR | O_TRUNC : O_RDWR);
	$GUI_MESSAGES_FILEHANDLE = FileHandle->new( "$GUI_MESSAGES", $flag );
	if ( defined( $GUI_MESSAGES_FILEHANDLE ) )
		{
		$GUI_MESSAGES_FILEHANDLE->autoflush();
		}
	else
		{
		print STDERR "$0: *** FATAL ERROR *** $! OPENING GUI MESSAGES FILE '$GUI_MESSAGES' ... EXITING WITH STATUS CODE = $E_CANNOT_OPEN_GUI_MESSAGES_FILE\n";
		exit $E_CANNOT_OPEN_GUI_MESSAGES_FILE;
		}
}

#####################################################################################
#  
#####################################################################################
sub closeGUIMessages
{
	undef $GUI_MESSAGES_FILEHANDLE;
}

#####################################################################################
#	sendGUIMessage  
#####################################################################################
sub sendGUIMessage
{
	my($msgType, $usbId, $usbStateId) = @_;

	#
	#	make sure supplied state is valid
	#
	if ( !grep { $_ == $usbStateId } values(%USB_STATES) )
		{
		print "sendGUIMessage: ERROR: INVALID STATE: $usbStateId\n";
		return -1;
		}

	print $GUI_MESSAGES_FILEHANDLE "$msgType|$usbId|$usbStateId\n";

}

#####################################################################################
#	receiveGUIMessage  
#####################################################################################
sub receiveGUIMessage
{
	my($gui_messages_fh) = @_;

	my($msgHash);

	chomp($msgHash->{'msg'} = <$gui_messages_fh>);

	($msgHash->{'usbId'}, $msgHash->{'stateId'}) = split( /\|/, $msgHash->{'msg'} );

	$msgHash->{'state'} = getUSBStateFromStateId( $msgHash->{'stateId'} );

	$msgHash->{'color'} = getUSBStateColorName( $msgHash->{'state'} );

	return $msgHash;

}

#####################################################################################
#	getUSBStateIdFromState
#####################################################################################
sub getUSBStateIdFromState
{
	my($usbState) = @_;
	return $USB_STATES{ $usbState };
}

#####################################################################################
#	getUSBStateFromStateId
#####################################################################################
sub getUSBStateFromStateId
{
	my($usbStateId) = @_;
	return $USB_STATES[ $usbStateId ];
}

#####################################################################################
#	getInitialUSBStateId
#####################################################################################
sub getInitialUSBStateId
{
	return $DISCONNECTED_IDLE_STATE_ID;
}

#####################################################################################
#	getInitialUSBState
#####################################################################################
sub getInitialUSBState
{
	return getUSBStateFromStateId( getInitialUSBStateId() );
}

#####################################################################################
#	getNextUSBStateId
#####################################################################################
sub getNextUSBStateId
{
	my($stateId) = @_;

	return ($stateId + 1) % $CT_USB_STATES;
}

#####################################################################################
#	getNextUSBState
#####################################################################################
sub getNextUSBState
{
	my($messageState) = @_;
	return getUSBStateFromStateId( getNextUSBStateId( $USB_STATES{ $messageState } ) );
}

#####################################################################################
#	getUSBStateColorName
#####################################################################################
sub getUSBStateColorName
{
	my($usbState) = @_;
	if ( !grep { $_ eq $usbState } @USB_STATES )
		{
		return $DEFAULT_USB_STATE_COLOR;
		}
	return $USB_STATE_COLORS{ $usbState };
}

#####################################################################################
#	setUSBStateColor
#####################################################################################
sub setUSBStateColorName
{
	my($usbState, $color) = @_;
	if ( !grep { $_ eq $usbState} @USB_STATES )
		{
		return -1;
		}
	$USB_STATE_COLORS{ $usbState } = $color;
	return 0;
}

######################################################################################################
#	getCdsConfiguration: get cds configuration file
######################################################################################################
sub getCdsConfiguration
{
	if ( !defined($CDS_CONFIG) )
		{
		$CDS_CONFIG_XML = new XML::Simple;
		$CDS_CONFIG     = $CDS_CONFIG_XML->XMLin($CDS_CONFIG_FILE);
		}
	return $CDS_CONFIG;
}

######################################################################################################
#	decrementAccessControlSemaphore: decrement an access control semaphopre
######################################################################################################
sub decrementAccessControlSemaphore
{
	my($mode)      =  0666 | IPC_CREAT;
	my($semct)     =  1;	# semaphone count; only a single access control semaphore exists so this will always be 1
	my($semnum)    =  0;	# semaphone number; only a single access control semaphore exists so this will always be 0
	my($decrOp)    = -1;	# decrement operation
	my($semflags)  =  0;	# no special flags
	my($cdsConfig) =  getCdsConfiguration();
	my($semkey)    =  $cdsConfig->{$CF_DATA_CACHE}->{$CF_ACCESS_CTRL_KEY};

	logMsg( 1, "decrementAccessControlSemaphore: entry: semkey=$semkey\n");

	if ( !defined($semkey) )
		{
		setErrno($E_NO_ACCESS_CTRL_SEMKEY);
		setErrmsg("ACCESS CONTROL KEY NOT FOUND IN CONFIGURATION TAG=$CF_DATA_CACHE.$CF_ACCESS_CTRL_KEY)");
		return -1;
		}

	logMsg( 1, "decrementAccessControlSemaphore: before semget: semkey=$semkey semct=$semct mode=$mode\n");

	clearErrno();
	clearErrmsg();

	my($semid) = semget($semkey, $semct, $mode);

	logMsg( 1, "decrementAccessControlSemaphore: after semget: semid=$semid semkey=$semkey semct=$semct mode=$mode\n");

	if ( !defined($semid) )
		{
		logMsg( 1, "decrementAccessControlSemaphore: FAILED: ERROR=$E_SEMGET_FAILED: ERRNO=$! ACQUIRING ACCESS CONTROL SEMAPHORE");
		setError($E_SEMGET_FAILED);
		setErrmsg("ERROR $! ACQUIRING ACCESS CONTROL SEMAPHORE");
		return -1;
		}

	logMsg( 1, "decrementAccessControlSemaphore: after semget before pack: semid=$semid semkey=$semkey semct=$semct mode=$mode\n");

	#
	#	set the semaphore op to decrement and then decrement the semaphone ... the invoking process will block until the semaphore is incremented
	#
	my($semop) = pack("s!3", $semnum, $decrOp, $semflags);

	logMsg( 1, "decrementAccessControlSemaphore: executing semop(semid=$semid semnop=$semop)\n" );

	my($rc)    = semop($semid, $semop);

	if ( !$rc )
		{
		setErrno($E_SEMOP_FAILED);
		setErrmsg("SEMOP $semop FAILED DURING DECREMENT WITH ERROR $!");
		return -1;
		}

	logMsg( 1, "decrementAccessControlSemaphore: return 0\n" );

	return 0;

}

######################################################################################################
#	incrementAccessControlSemaphore
#
#	increment access control semaphore if there
#	are any processes waiting for the semaphore
#	to be returned to zero
#	
######################################################################################################
sub incrementAccessControlSemaphore
{
	my($ds);
	my($mode)      =  0666;
	my($cdsConfig) =  getCdsConfiguration();
	my($semct)     =  1;	# semaphone count; only a single access control semaphore exists so this will always be 1
	my($semkey)    =  $cdsConfig->{$CF_DATA_CACHE}->{$CF_ACCESS_CTRL_KEY};

	logMsg( 1, "incrementAccessControlSemaphore: entry: semkey=$semkey\n");

	if ( !defined($semkey) )
		{
		setErrno($E_NO_ACCESS_CTRL_SEMKEY);
		setErrmsg("ACCESS CONTROL KEY NOT FOUND IN CONFIGURATION TAG=$CF_DATA_CACHE.$CF_ACCESS_CTRL_KEY)");
		logMsg( 1, "incrementAccessControlSemaphore: ACCESS CONTROL KEY NOT FOUND IN CONFIGURATION TAG=$CF_DATA_CACHE.$CF_ACCESS_CTRL_KEY)\n");
		return -1;
		}

	logMsg( 1, "incrementAccessControlSemaphore: before semget: semkey=$semkey semct=$semct mode=$mode\n");

	my($semid) = semget($semkey, $semct, $mode);

	logMsg( 1, "incrementAccessControlSemaphore: after semget: semid=$semid semkey=$semkey semct=$semct mode=$mode\n");

	if ( !defined($semid) )
		{
		setError($E_SEMGET_FAILED);
		setErrmsg("ERROR $! ACQUIRING ACCESS CONTROL SEMAPHORE");
		logMsg( 1, "incrementAccessControlSemaphore: ERROR $! ACQUIRING ACCESS CONTROL SEMAPHORE\n");
		return -1;
		}

	logMsg( 1, "incrementAccessControlSemaphore: semid=$semid\n");

	my($ncnt)   = semctl($semid, 0, GETNCNT, \$ds);

	logMsg( 1, "incrementAccessControlSemaphore: ncnt=$ncnt\n");

	if ( !defined($ncnt) )
		{
		setError($E_SEMCTL_FAILED);
		setErrmsg("ERROR $! RETRIEVING ACCESS CONTROL SEMAPHORE NCNT");
		logMsg( 1, "incrementAccessControlSemaphore: ERROR $! RETRIEVING ACCESS CONTROL SEMAPHORE NCNT\n");
		return -1;
		}

	my($semop)  = pack("s!3", 0, 1, 0);
	my($n);
	my($rc);
	my(@errs);
	
	#
	#	increment the semaphore once for every process 
	#	that is waiting for the access control semaphore
	#	count to return to zero signifying that the
	#	cache contains data and ready to be read
	#
	for($n = 0; $n < $ncnt; $n++ )
		{
		$rc  = semop($semid, $semop);
		if ( !$rc )
			{
			push(@errs, "SEMOP $semop FAILED DURING INCREMENT OF SEMAPHORE $n WITH ERROR $!");
			}
		}

	if ( $#errs >= 0 )
		{
		setErrno($E_SEMOP_FAILED);
		setErrmsg(join("\n", @errs));
		logMsg( 1, "incrementAccessControlSemaphore: semop failed: " . join("\n", @errs) . "\n");
		return -1;
		}

	setErrno($E_NO_ERROR);
	setErrmsg(undef);

	logMsg( 1, "incrementAccessControlSemaphore: return: success\n");

	return 0;

}

######################################################################################################
#	getNumberOfWaitingProcesses: get number of processes waiting for semaphore 
######################################################################################################
sub getNumberOfWaitingProcesses
{
	my($ds);
	my($mode)      =  0666;
	my($cdsConfig) =  getCdsConfiguration();
	my($semct)     =  1;	# semaphone count; only a single access control semaphore exists so this will always be 1
	my($semkey)    =  $cdsConfig->{$CF_DATA_CACHE}->{$CF_ACCESS_CTRL_KEY};

	logMsg( 1, "getNumberOfWaitingProcesses: entry: semkey=$semkey\n");

	if ( !defined($semkey) )
		{
		setErrno($E_NO_ACCESS_CTRL_SEMKEY);
		setErrmsg("ACCESS CONTROL KEY NOT FOUND IN CONFIGURATION TAG=$CF_DATA_CACHE.$CF_ACCESS_CTRL_KEY)");
		logMsg( 1, "getNumberOfWaitingProcesses: ACCESS CONTROL KEY NOT FOUND IN CONFIGURATION TAG=$CF_DATA_CACHE.$CF_ACCESS_CTRL_KEY)\n");
		return -1;
		}

	my($semid) = semget($semkey, $semct, $mode);

	if ( !defined($semid) )
		{
		setError($E_SEMGET_FAILED);
		setErrmsg("ERROR $! ACQUIRING ACCESS CONTROL SEMAPHORE");
		logMsg( 1, "getNumberOfWaitingProcesses: ERROR $! ACQUIRING ACCESS CONTROL SEMAPHORE\n");
		return -1;
		}

	logMsg( 1, "getNumberOfWaitingProcesses: semid=$semid\n");

	my($ncnt)   = semctl($semid, 0, GETNCNT, \$ds);

	logMsg( 1, "getNumberOfWaitingProcesses: return: ncnt=$ncnt\n");

	return $ncnt;

}

########################################################################################################
#	getControlFileContentsAsListOfFileNames: read a file containing a list of names and return the list
########################################################################################################
sub getControlFileContentsAsListOfFileNames
{
	my($controlFileName)      = @_;
	my(@controlFileContents)  = ();
	if ( ! -e "$controlFileName" || ! -f "$controlFileName" )
		{
		return ();
		}
	if ( open( CTL_FILE, "< $controlFileName" ) )
		{
		chomp( @controlFileContents = <CTL_FILE>);
		close( CTL_FILE );
		}
	return @controlFileContents;
}

1;

