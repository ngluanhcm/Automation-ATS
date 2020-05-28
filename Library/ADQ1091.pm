#**************************************************************************************************#
#FEATURE                : <Table SITE Expansion> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Phuc Huynh Ngoc>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::ADQ1091::ADQ1091;

use strict;
use Tie::File;
use File::Copy;
use Cwd qw(cwd);
use Data::Dumper;
use threads;
#********************************* LIST OF LIBRARIES***********************************************#

use ATS;
use SonusQA::Utils qw (:all);

#**************************************************************************************************#

use Log::Log4perl qw(get_logger :levels);
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

##################################################################################
#  GLCAS::TEMPLATE                                                              #
##################################################################################
#  This package tests for the GL.                                                #
##################################################################################

##################################################################################
# SETUP                                                                          #
##################################################################################


# Required Testbed elements for this package

my %REQUIRED = ( 
        "C20" => [1],
        "GLCAS" => [1],
               );

################################################################################
# VARIABLES USED IN THE SUITE Defined HERE                                     #
################################################################################
our $dir = cwd;
our $user_name;
if ($dir =~ /home\/(\w\w*)\/ats_repos/ ) {
    $user_name = $1;
}

our ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst) = localtime(time);
our $datestamp = sprintf "%4d%02d%02d-%02d%02d%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
our ($ses_core, $ses_glcas, $ses_logutil, $ses_tapi, $ses_ossgate, $ses_core_li);
our (%input, @output, $tcid);
our %core_account = ( 
                    -username => [
                                    'testshell1','testshell2','testshell3','testshell4','testshell5',
                                    'testshell6','testshell7','testshell8','testshell9','testshell10',
                                    'testshell11','testshell12','testshell13','testshell14','testshell15',
                                    'testshell16','testshell17','testshell18','testshell19','testshell20',],
                    -password => [
                                    'automation','automation','automation','automation','automation',
                                    'automation','automation','automation','automation','automation',
                                    'automation','automation','automation','automation','automation',
                                    'automation','automation','automation','automation','automation'],
                    );
# For LI
our %core_account_li = ( 
                    -username => ['liadmin'], 
                    -password => ['liadmin']
                    );
# Info for OSSGATE
our @ossgate = ('cmtg', 'cmtg');
# For GLCAS
our @cas_server = ('10.250.185.232', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';
our $wait_for_event_time = 30;
our $tapilog_dir = '/home/ntthuyhuong/Tapi_hnphuc/';
our $li_user = 'liadmin';
our $pass_li = "123456";

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{"c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};
our ($root_pass) = $alias_hashref->{LOGIN}->{1}->{ROOTPASSWD};
###############################################################
our @log_type = (1, 1, 1); # get logutil, pcm, tapi respectively

# Line Info
our %db_line = (
                'V52_1' => {
                            -line => 35,
                            -dn => 1514004318,
                            -region => 'US',
                            -len => 'V52   00 0 00 18',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'V52_2' => {
                            -line => 31,
                            -dn => 1514004316,
                            -region => 'US',
                            -len => 'V52   00 0 00 16',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'V52_3' => {
                            -line => 17,
                            -dn => 1514004315,
                            -region => 'US',
                            -len => 'V52   00 0 00 15',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'V52_4' => {
                            -line => 9,
                            -dn => 1514004314,
                            -region => 'US',
                            -len => 'V52   00 0 00 14',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                
                );

our %tc_line = (
                'ADQ1091_001' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_002' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_003' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_004' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_005' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_006' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_007' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_008' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_009' => ['V52_4','V52_2','V52_1','V52_3'],
				'ADQ1091_010' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_011' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_012' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_013' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_014' => ['V52_1','V52_2','V52_3'],
                'ADQ1091_015' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_016' => ['V52_1','V52_2','V52_3'],
				'ADQ1091_017' => ['V52_1','V52_2','V52_3'],
				'ADQ1091_018' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_019' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1091_020' => ['V52_1','V52_2','V52_3','V52_4'],
				
);

#################### Trunk info ###########################
our %db_trunk = (
                'cas_r2' => {
                                -acc => 204,
                                -region => 'US',
                                -clli => 'T2MG9ETSIPRI2W',
                            },
				'sst' =>{
                                -acc => 388,
                                -region => 'US',
                                -clli => 'T2SSTETSIV2',
                            },
				'pri_1' => {
                                -acc => 202,
                                -region => 'US',
                                -clli => 'AUTOETSIPRIEN2W',
                            },		
                'tw_isup' =>{
                                -acc => 506,
                                -region => 'US',
                                -clli => 'AUTOG9C7ETSI2W',
                            },
				'g6_pri' =>{
                                -acc => 606,
                                -region => 'US',
                                -clli => 'G6STM1PRITEXT2W',
                            },
               
                );

##################################################################################
sub configured {
    # Check configured resources match REQUIRED
    if ( SonusQA::ATSHELPER::checkRequiredConfiguration ( \%REQUIRED, \%TESTBED ) ) {
        $logger->info(__PACKAGE__ . ": Found required devices in TESTBED hash"); 
    } else {
        $logger->error(__PACKAGE__ . ": Could not find required devices in TESTBED hash"); 
        return 0;
    }  
}

sub ADQ1091_cleanup {
    my $subname = "ADQ1091_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_ossgate, $ses_tapi, $ses_core_li
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ1091_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ1091_checkResult";
    $logger->debug(__PACKAGE__ . ".$tcid: Test result : $result");
    if ($result) { 
        $logger->debug(__PACKAGE__ . ".$tcid  Test case passed ");
            SonusQA::ATSHELPER::printPassTest($tcid);
            return 1;
    } else {
        $logger->debug(__PACKAGE__ . ".$tcid  Test case failed ");
            SonusQA::ATSHELPER::printFailTest($tcid);
            return 0;
    }
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ1091_001",
					"ADQ1091_002",
					"ADQ1091_003",
					"ADQ1091_004",
					"ADQ1091_005",
					"ADQ1091_006",
                    "ADQ1091_007",
					"ADQ1091_008",
					"ADQ1091_009",
					"ADQ1091_010",
					"ADQ1091_011",
					"ADQ1091_012",
					"ADQ1091_013",
					"ADQ1091_014",
                    "ADQ1091_015",
					"ADQ1091_016",
					"ADQ1091_017",
					"ADQ1091_018",
					"ADQ1091_019",
					"ADQ1091_020",
					
                );

############################### Run Test #####################################
sub runTests {
    unless ( &configured ) {
        $logger->error(__PACKAGE__ . ": Could not configure for test suite ".__PACKAGE__); 
        return 0;
    }

    $logger->debug(__PACKAGE__ . " ======: before Opening Harness");
    my $harness;
    unless($harness = SonusQA::HARNESS->new( -suite => __PACKAGE__, -release => "$TESTSUITE->{TESTED_RELEASE}", -variant => $TESTSUITE->{TESTED_VARIANT}, -build => $TESTSUITE->{BUILD_VERSION}, -path => "ats_repos/test/setup/work")){ # Use this for real SBX Hardware.
        $logger->error(__PACKAGE__ . ": Could not create harness object");
        return 0;
    }
    $logger->debug(__PACKAGE__ . " ======: Opened Harness");  
    my @tests_to_run;

    # If an array is passed in use that. If not run every test.
    if ( @_ ) {
        @tests_to_run = @_;
    }
    else {
        @tests_to_run = @TESTCASES;
    }

    $harness->{SUBROUTINE}= 1;    
    $harness->runTestsinSuite( @tests_to_run );
}

##################################################################################
# +------------------------------------------------------------------------------+
# |                     GL CAS and ATS integration                               |
# +------------------------------------------------------------------------------+
# |            		    Suite Table SITE Expansion                               |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Phuc Huynh Ngoc ##########################

# Here is the list of issue during testing:

# + The TCs have DNH group is failed due to this field :XLAPLAN_RATEAREA_SERVORD_ENABLED MANDATORY_PROMPTS in "table ofcvar"
# --> Disable it by command: rep XLAPLAN_RATEAREA_SERVORD_ENABLED OFF

# + For LI TCs:  Please check account "liadmin/liadmin" then access core LI  by user/pass is: dnbdord ->123456.

# + Please note: Need to manual check all trunks (which were inputted in script) are IDL, the region on GMS = US.........before you are run test suite.

#####

sub ADQ1091_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_001");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_001";
    my $tcid = "ADQ1091_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $dnh_added = 1;
	my $dtm_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
    my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2M Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

   # Add DNH group: A is pilot, B is member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    
    $dnh_added = 0;
	
	# A has DTM 
	unless ($ses_core->callFeature(-featureName => 'DTM', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add DTM for line A $list_dn[0]");
		print FH "STEP: add DTM for line A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DTM for line A $list_dn[0] - PASS\n";
    }
     
    
    $dtm_added = 0;	
	
# Initialize Call 
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
   # Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
# Call Flow
    # Call flow   
	
	# start PCM trace
	
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
    # C calls A 
    
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
	
	%input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
	 unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line C $list_dn[2]");
        print FH "STEP: C hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASS\n";
    }
	# C dials line A
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		 print FH "STEP: C dials line A $list_dn[0] - FAIL\n";
		$result = 0;
        goto CLEANUP;
        
    } else {
        print FH "STEP: C dials line A $list_dn[0] - PASS\n";
    }
    
	# Check line B ringing
	
	%input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
		
     # Offhook B and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Verify C,B have speech path
	 %input = (
                -list_port => [$list_line[2],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }
			
################################## Cleanup  ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_001 ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	
	 # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	
    # remove DNH group
    unless ($dnh_added) {
	     unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
        }
    }

    # remove DTM feature from line A
    unless ($dtm_added) {
        unless ($ses_core->callFeature(-featureName => 'DTM', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DTM from line $list_dn[0]");
            print FH "STEP: Remove DTM from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove DTM from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);    
}

sub ADQ1091_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_002");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_002";
    my $tcid = "ADQ1091_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    
    my $wait_for_event_time = 30;
	my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;	
	my $pcm_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, $ID, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
    unless ($ses_core_li->loginCore(%core_account_li)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
        sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    
	
	
    # Add CWT and CWI and CCW to line A
    foreach ('CWT','CWI','CCW') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[0]");
            print FH "STEP: add $_ for line $list_dn[0] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[0] - PASS\n";
        }
    }
	unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	 $feature_added = 0;
	 
	 # Get CCW accesscode
	my $ccw_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CCW');
    unless ($ccw_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CCW access code for line  $list_dn[0]");
		print FH "STEP: get CCW access code for line A $list_dn[0] is $ccw_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CCW access code for line A $list_dn[0] is $ccw_acc - PASS\n";
    }
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line A and LEA to line D   
	
	 my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);  	 
     $lea_num = $trunk_access_code . $lea_num;
	 print FH "Lea num is $lea_num\n";
	$ses_core_li->execCmd("add TMA2M YES FTPV4 047 135 041 070 021 ibn $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes PXAUTO px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID\s+(\d+)/ ) {
			$ID = $1;
        print FH "Monitor Order ID is: $ID\n";
        }
	}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }

# Initialize call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

    # Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}

    # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
# Call flow
  	
    # start PCM trace

    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	

   # Make A call B, B,D rings and B answers
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
	
	#  A dials B , B,D rings and B answers,  
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
		print FH "STEP: A dials B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials B $list_dn[1] - PASS\n";
    }
	
	# Check line B ringing
	
	%input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
	# Offhook line B
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
		 print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
    
	# Offhook line D
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }		
	
	# Verify A,B have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
	
	 # LEA D can monitor the call 
    %input = (
                -list_port => [$list_line[0], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B - PASS\n";
    }
	# A Start confirmtone 
	 %input = (
                -line_port => $list_line[0],
                -cas_timeout => 50000,
                ); 
    unless($ses_glcas->startDetectConfirmationToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect ConfirmationTone line $list_line[0]");
		print FH "STEP: A start confirm tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A start confirm tone - PASS\n";
    }
	
     # A flash
	 %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line A $list_line[0]");
		print FH "STEP: A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flash - PASS\n";
		
    }
	sleep(2);
	 # A dials CCW accesscode
	
	%input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$ccw_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $ccw_acc successfully");
		print FH "STEP: A dials ccw_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials ccw_acc - PASS\n";
    }
 
	# Stop confirmtone
	# A hears confirm tone 
  	  %input = (
                -line_port => $list_line[0],
                -cas_timeout => 50000,
                ); 
    unless($ses_glcas->stopDetectConfirmationToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect ConfirmationTone line $list_line[0]");
		print FH "STEP: A hears confirm tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears confirm tone - PASS\n";
    }
	
	# Offhook line C
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
	
	# C calls A, C hears busy tone 
	
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
    # C hears busy tone 
	sleep(1);
    my %input = (
                -line_port => $list_line[2],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect busy tone line $list_line[2]");
		print FH "STEP: C hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears busy tone - PASS\n";
    }
  

    # D still monitor A & B successfully
    %input = (
                -list_port => [$list_line[0], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA still can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA still can monitor the call between A and B - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	
	# Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
    
	 # Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }

	  # remove CWT, CWI and CCW from line A
    unless ($feature_added) {
        foreach ('CCW','CWI','CWT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }
	
	# Deact LEA
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;       
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;     
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;       
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;       
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	
    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_003");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_003";
    my $tcid = "ADQ1091_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    ############################## line DB #####################################
	my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################


    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $add_feature_lineB = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
 # Add SIMRING group for line A and line B
	
   	 $ses_core->execCmd("servord");
	 sleep(1);
   @output = $ses_core->execCmd("est \$ SIMRING $list_dn[0] $list_dn[1] \$ ACT Y 123 y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'N' to reject ");
        }
		}
		
		if (grep /Y OR N|Y TO CONFIRM/, @output) {
        @output = $ses_core->execCmd("Y");
        unless(@output) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
        }
        if (grep /Y OR N|Y TO CONFIRM/, @output) {
            unless ($ses_core->execCmd("Y")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
            }
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SIMRING for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineA = 0;
	
# Add CFD  to line B
       	
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: add CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[1] - PASS\n";
    }
    
   
    $add_feature_lineB = 0;

    my $cfd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'CFDP');
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[2]");
		print FH "STEP: get CFD access code for line $list_dn[2] is $cfd_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[2] is $cfd_acc- PASS\n";
    }
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
# Call flow

    # start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
    # Activate CFD from line B to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    my $dialed_num = '*' . $cfd_acc . $list_dn[2] . '#';
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: Send digit to active CFD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Send digit to active CFD - PASS\n";
    }
    
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[2]");
        print FH "STEP: activate CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[1] - PASS\n";
    }
	# Onhook line B
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
   
    
	# D calls A, A and B will ring
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line D $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }

	%input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: D dials $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials $list_dn[0] - PASS\n";
    }

	 # Both A and B rings
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	 %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
	# Wait time for C ringing
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	# Offhook line C
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	
	# Verify speech path between C and D
	 %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and D");
        print FH "STEP: Check speech path between C and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and D - PASS\n";
    }
	
	# A calls B, check speech path

	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls B and they have no speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	
    # remove SIMRING group from line A&B
   unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[0]");
            print FH "STEP: Remove SIMRING from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[0] - PASS\n";
        }
    }
    # remove CFD from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[1]");
            print FH "STEP: Remove CFD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_004");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_004";
    my $tcid = "ADQ1091_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################


    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
	my $add_feature_lineC = 1;
    my $add_feature_lineD = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
# Add SIMRING group for line A and line B
	
   	 $ses_core->execCmd("servord");
	 sleep(1);
   @output = $ses_core->execCmd("est \$ SIMRING $list_dn[0] $list_dn[1] \$ ACT Y 123 y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'N' to reject ");
        }
		}
		
		if (grep /Y OR N|Y TO CONFIRM/, @output) {
        @output = $ses_core->execCmd("Y");
        unless(@output) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
        }
        if (grep /Y OR N|Y TO CONFIRM/, @output) {
            unless ($ses_core->execCmd("Y")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
            }
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SIMRING for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	unless(grep /Pilot DN/, @output = $ses_core->execCmd("qsimr $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot show pilot DN and member DN  ");
        print FH "STEP: Show pilot DN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Show pilot DN - PASS\n";
    }
    $add_feature_lineA = 0;
   
   
	
	# Add CFD  to line B
   	
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: add CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[1] - PASS\n";
    }
    
	unless(grep /CFD/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add CFD for line $list_dn[2] ");
        print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
	
	$add_feature_lineB = 0;
	 my $cfd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'CFDP');
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[2]");
		print FH "STEP: get CFD access code for line $list_dn[2] is $cfd_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[2] is $cfd_acc- PASS\n";
    }
    
	
	# Add 3WC for line D 
	unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[3], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[3]");
		print FH "STEP: add 3WC for line $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[3] - PASS\n";
    }
	
	$add_feature_lineD = 0;
	
	
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
	
# Call flow
   # start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Activate CFD from line B to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		
    }
	
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line B $list_dn[1]");
        print FH "STEP: B hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
    }
    my $dialed_num = '*' . $cfd_acc . $list_dn[2] . '#';
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: Send digit to active CFD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Send digit to active CFD - PASS\n";
    }
    
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[2]");
        print FH "STEP: activate CFD for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line B $list_dn[1] - PASS\n";
    }
	
	# Onhook line B
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
	# D calls A, A and B will ring
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line D $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }

	%input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: D dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials A $list_dn[0] - PASS\n";
    }
	
	# Check line A ringing
	
	%input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	# Check line B ringing
	
	%input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
	# Offhook A and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
	
	# Check speech path between A, D
	 %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between D and A");
        print FH "STEP: Check speech path between D and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between D and A - PASS\n";
    }
	
	# D flashes and activates 6WC to A 
	%input = (
                -line_port => $list_line[3], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[3]");
		print FH "STEP: D flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D flash  - PASS\n";
    }

	# D dials line A 
	%input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: D dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials A $list_dn[0] - PASS\n";
    }
	
	sleep(2);
	# Check line B ringing
	
	%input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	sleep(2);
	# Wait timeout CFD
	# Check line C ringing
	
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	# Offhook line C
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
	
	# Check speech path between C, D
	 %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between D and C");
        print FH "STEP: Check speech path between D and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between D and C - PASS\n";
    }
	
	#  D flashes and activates 3WC again to invite C to conf
	
	%input = (
                -line_port => $list_line[3], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[3]");
		print FH "STEP: D flash again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D flash again - PASS\n";
    }


	
	# Check speech path between C, D, A
	 %input = (
                -list_port => [$list_line[0],$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between D and C, A");
        print FH "STEP: Check speech path between D and C, A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between D and C, A - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }

	 
	 # Get PCM trace
     if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}

    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	
    # remove CFD from line B 
    unless ($add_feature_lineB) {
       
            unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[1]");
            print FH "STEP: Remove CFD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[1] - PASS\n";
        }      
    }
	
	
    # remove 3WC from line D
    unless ($add_feature_lineD) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[3], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[3]");
            print FH "STEP: Remove 3WC from line $list_dn[3] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[3] - PASS\n";
        }
    }
    
	# remove SIMRING group from line A&B
   unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[0]");
            print FH "STEP: Remove SIMRING from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[0] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_005");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_005";
    my $tcid = "ADQ1091_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code_sip = $db_trunk{'sst'}{-acc};
	
    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $add_feature_lineB = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name,  %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

    # Add A, B into MADN group
   $ses_core->execCmd("servord");
   sleep(1);
   @output = $ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 6 y nonprivate \$ y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'N' to reject ");
        }
    }
    if (grep /Y OR N|Y TO CONFIRM/, @output) {
        @output = $ses_core->execCmd("Y");
        unless(@output) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
        }
        if (grep /Y OR N|Y TO CONFIRM/, @output) {
            unless ($ses_core->execCmd("Y")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
            }
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: add MADN to line $list_dn[0] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MADN to line $list_dn[0] as member - PASS\n";
    }
    $add_feature_lineA = 0;
	
	# Add B into MADN group
	@output = $ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] bldn \$ y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'N' to reject ");
        }
    }
    if (grep /Y OR N|Y TO CONFIRM/, @output) {
        @output = $ses_core->execCmd("Y");
        unless(@output) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
        }
        if (grep /Y OR N|Y TO CONFIRM/, @output) {
            unless ($ses_core->execCmd("Y")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
            }
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
   
    $add_feature_lineB = 0;
	
	# Add ACB feature to line C-
	 unless ($ses_core->callFeature(-featureName => "ACB NOAMA", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[2]");
		print FH "STEP: add ACB for line C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add ACB for line C $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 0;
	
	# Get access code ACB
	 my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[3]");
		print FH "STEP: get ACB access code for line $list_dn[2] is $acb_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get ACB access code for line $list_dn[2] is $acb_acc - PASS\n";
    }

# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

    # Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
   # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	} 
	
# Call flow
      # start PCM trace
	
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

	 
    # Make A call D , D rings and answers
	
	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[0],
                -regionB => $list_region[3],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls D and they have no speech path ");
        print FH "STEP: A calls D and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls D and they have speech path - PASS\n";
    }
	
	# C call A, C hears busy tone
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	# C dials line A
	
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
	# C hears busy tone
    sleep(1);
    my %input = (
                -line_port => $list_line[2],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect busy tone line $list_line[2]");
        print FH "STEP: C hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears busy tone - PASS\n";
    }
	
	# Onhook line C 
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
	sleep (2);
	#  C offhooks and dials ACB accesscode then onhooks
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
		
	
	# C dials *acb_acc
	
    %input = (
                -line_port => $list_line[2],
                -dialed_number => "\*$acb_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $acb_acc successfully");
		print FH "STEP: C dials acb_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials acb_acc - PASS\n";
    }
	
	sleep (2);
	# Onhook line C
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
	
	# A,D onhook
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[3]");
        print FH "STEP: Onhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line D - PASS\n";
    }
	
	sleep(2);
	# Wait time for C ringing
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	# Offhook line C
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
	
	# A, B ringing
	
	%input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	 %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
	# Offhook line A
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Verify speech path between A and C
	 %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }
	
	# Offhook line B
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Verify speech path between A and C
	 %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C, B");
        print FH "STEP: Check speech path between A and C, B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C, B - PASS\n";
    }
	
	
################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	
	
	 # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	
	# remove ACB from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'ACB', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ACB from line $list_dn[2]");
            print FH "STEP: Remove ACB from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove ACB from line $list_dn[2] - PASS\n";
        }
    }
    
	# remove MADN from line A and B
     $ses_core->execCmd("servord");
    unless ($add_feature_lineA) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[0] from MADN group");
            print FH "STEP: remove line $list_dn[0] from MADN group - FAIL\n";
        } else {
            print FH "STEP: remove line $list_dn[0] from MADN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
            }
            print FH "STEP: Remove MADN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MADN from line $list_dn[0] - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
	
	

    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);
}


sub ADQ1091_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_006");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_006";
    my $tcid = "ADQ1091_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    ############################## line DB #####################################
	my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
     my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
	 
    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }
     
	  unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M Core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M Core - PASS\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	my $un_line;
	# Out line C
    $ses_core->execCmd("servord");
	$ses_core->execCmd("out \$ $list_dn[2] $list_len[2] bldn y y");
	unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[2] ");
        print FH "STEP: Out line $list_dn[2] for SDN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Out line $list_dn[2] for SDN - PASS\n";
		$un_line = $list_dn[2];
    }
	
	# A has SDN ($un_line)
    $ses_core->execCmd("servord");
	 @output = $ses_core->execCmd("ado \$ $list_dn[0] SDN $un_line 3 p \$ \$ y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'N' to reject ");
        }
		}
		
		if (grep /Y OR N|Y TO CONFIRM/, @output) {
        @output = $ses_core->execCmd("Y");
        unless(@output) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
        }
        if (grep /Y OR N|Y TO CONFIRM/, @output) {
            unless ($ses_core->execCmd("Y")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'Y' to confirm ");
            }
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /SDN/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SDN for line $list_dn[0] ");
        print FH "STEP: add SDN for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SDN for line $list_dn[0] - PASS\n";
    }
	
	 $add_feature_lineA = 0;
	 
	 # B has AUL (via PRI)
	 my ($aul_num) = ($un_line =~ /\d{3}(\d+)/);  	 
     $aul_num = $trunk_access_code . $aul_num;
	 print FH "aul_num is $aul_num \n";
	 
	unless ($ses_core->callFeature(-featureName => "AUL $aul_num", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: add CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[1] - PASS\n";
    }
    
	$add_feature_lineB = 1;
    # Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
# Call flow

    # start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

   
	# Offhook B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
       
    }
  	 
    # A ring and answers

	 %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	
	# Offhook A and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[1] - PASS\n";
    }
	
    # Verify A,B still have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B ");
        print FH "STEP: check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and B - PASS\n";
    }
	
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	
	# Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        
    }
	
    
	 # remove SDN feature for line A
     $ses_core->execCmd("servord");
     unless ($add_feature_lineA) {
	 
	 if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] SDN $un_line \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
            }
            print FH "STEP: Remove SDN from line A $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SDN from line A $list_dn[0] - PASS\n";
        }
	 }
	
	# remove AUL feature for line B
  
     unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'AUL', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove AUL from line B $list_dn[1]");
            print FH "STEP: Remove AUL from line B $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove AUL from line B $list_dn[1] - PASS\n";
        }
    }
	
	# New line C for running the next TC
	 if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[2] $list_line_info[2] $list_len[2] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[2] ");
            print FH "STEP: NEW line $list_dn[2] for running the next tc - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[2] for running the next tc - PASSED\n";
        }

    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_007");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1091_007";
    my $tcid = "ADQ1091_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};	
	 
    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }
     
	  unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M Core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M Core - PASS\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	 my $un_line;
	# Out line C
    $ses_core->execCmd("servord");
	$ses_core->execCmd("out \$ $list_dn[2] $list_len[2] bldn y y");
	unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[2] ");
        print FH "STEP: Out line $list_dn[2] for SDN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Out line $list_dn[2] for SDN - PASS\n";
		$un_line = $list_dn[2];
    }
	
	# A has SDN ($un_line)
    unless ($ses_core->callFeature(-featureName => "SDN $un_line 3 p \$", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line A-$list_dn[0]");
		print FH "STEP: Add SDN for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SDN for line A($list_dn[0]) - PASSED\n";
    }
	
	 $add_feature_lineA = 0;
	 
	 # B has SCS
	 unless ($ses_core->callFeature(-featureName => "SCS", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCS for line $list_dn[1]");
		print FH "STEP: add SCS for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCS for line B $list_dn[1] - PASS\n";
    }
	
    $add_feature_lineB = 0;
	
	# Get access code SCS
	 my $scps_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'SCPS');
    unless ($scps_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SCPS access code for line $list_dn[1]");
		print FH "STEP: get SCPS access code for line $list_dn[1] is $scps_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get SCPS access code for line $list_dn[1] is $scps_acc - PASS\n";
    }
	
	 my $spdc_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'SPDC');
    unless ($spdc_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SPDC access code for line $list_dn[1]");
		print FH "STEP: get SPDC access code for line $list_dn[1] is $spdc_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get SPDC access code for line $list_dn[1] is $spdc_acc - PASS\n";
    }
	
    # Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;

# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
 
    # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	} 
	
# Call flow
	 
	# Call flow			
    # start PCM trace
	 if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
   # B offhook and activate scps_acc 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
      
    }
	
    my ($dialed_num) = ($un_line =~ /\d{3}(\d+)/);
	$dialed_num = $trunk_access_code . $dialed_num;
	 my $scs_num = '*' . $scps_acc . 5 . $dialed_num . '#';
	 print FH "dials num is $scs_num \n";
	 
	 %input = (
                -line_port => $list_line[1],
                -dialed_number => $scs_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
			
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $scs_num successfully");
		print FH "STEP: B activate SCS_num for digit 5- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B activate SCS_num for digit 5- PASS\n";
    }
	
	# Onhook line B
     unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
	sleep(2);
	# B activate spdc_acc num
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
      
    }
	
	# B offhooks and activate SCS to call with digit 5. A rings
	$scs_num = '*' . $spdc_acc . 5 . '#';
	print FH "dials num is $scs_num \n";
	 %input = (
                -line_port => $list_line[1],
                -dialed_number => $scs_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
			
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $scs_num successfully");
		print FH "STEP: B activate SCS_num for digit 5- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B activate SCS_num for digit 5- PASS\n";
    }
	
	# Check line A have special ringing tone
    sleep(4);

	 %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	
	# Offhook A and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[1] - PASS\n";
    }
	
    # Verify A,B still have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B ");
        print FH "STEP: check speech path between A and B - FAIL\n";
        $result = 0;
      goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and B - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	
	# Get PCM trace
  if ($pcm_start) {
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
     
	 # Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	 
	 # remove SDN feature for line A
     $ses_core->execCmd("servord");
     unless ($add_feature_lineA) {
	 
	 if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] SDN $un_line \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
            }
            print FH "STEP: Remove SDN from line A $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SDN from line A $list_dn[0] - PASS\n";
        }
	 }
	 
	# remove SCS feature for line B
  
     unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'SCS', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCS from line B $list_dn[1]");
            print FH "STEP: Remove SCS from line B $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove SCS from line B $list_dn[1] - PASS\n";
        }
    }
	
	# New line C for running the next TC
	 if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[2] $list_line_info[2] $list_len[2] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[2] ");
            print FH "STEP: NEW line $list_dn[2] for running the next tc - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[2] for running the next tc - PASSED\n";
        }

    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_008");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_008";
    my $tcid = "ADQ1091_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineAB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
    my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "configSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
# Add PRK to line A
	unless ($ses_core->callFeature(-featureName => "PRK", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add PRK for line $list_dn[0]");
		print FH "STEP: add PRK for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add PRK for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

    my $prk_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'PRKS');
    unless ($prk_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[0]");
		print FH "STEP: get PRK access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get PRK access code for line $list_dn[0] - PASS\n";
    }
    
# Add CPU to line A and B (A and B must have the same custgroup)
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[1] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineAB = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CPU');
    unless ($cpu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CPU access code");
		print FH "STEP: get CPU access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CPU access code - PASS\n";
    }


# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
# Call flow
# start PCM trace
	
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # Make call C to A
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C cannnot call A ");
        print FH "STEP: C calls A and A answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and A answer - PASS\n";
    }
	 # A activate PRK
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$prk_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '\*$prk_acc' successfully");
		print FH "STEP: A activate PRK - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A activate PRK - PASS\n";
    }
    
	# Check C hear ring back
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
				-ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
	unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_line[2] ");
        print FH "STEP: C hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears ringback tone - PASS\n";
    }
	# Onhook A
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
		print FH "STEP: Onhook A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook A - PASS\n";
    }
    
    sleep(15); # wait for PRK timeout 
	# Check line A rering
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line A is not rering after PRK timeout ");
        print FH "STEP: Check line A rering - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A rering - PASS\n";
    }
	# B dials CPU access code to pick up the call for A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": B Cannot dial $cpu_acc successfully");
		print FH "STEP: B dials CPU access code to pick up the call for A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials CPU access code to pick up the call for A - PASS\n";
    }
		
    sleep(2);
	
	# check speech path between B and C
    %input = (
                -list_port => [$list_line[2],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and C ");
        print FH "STEP: check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between B and C - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
    # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }
    # remove CPU from line A and B
    unless ($add_feature_lineAB) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[1]");
            print FH "STEP: Remove CPU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[1] - PASS\n";
        }
    }
	
	# remove PRK from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'PRK', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove PRK from line $list_dn[0]");
            print FH "STEP: Remove PRK from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove PRK from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);    
}


sub ADQ1091_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_009");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_009";
    my $tcid = "ADQ1091_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;	
	my $pcm_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, %info, $ID);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_ConfigSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }
	
    unless ($ses_core_li->loginCore(%core_account_li)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M LI - PASS\n";
    }


    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	# Get DISA number and authencation code
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[3], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number - PASS\n";
    }
    my $authen_code = $ses_core->getAuthenCode($list_dn[3]);
    unless ($authen_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get authencation code");
		print FH "STEP: get authencation code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get authencation code - PASS\n";
    }
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line D and LEA to line C
	$ses_core_li->execCmd("add TMA2M YES FTPV4 047 135 041 070 021 ibn $list_dn[3] +");
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes PXAUTO px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line D  ");
        print FH "STEP: Add SURV to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line D - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line C  ");
        print FH "STEP: Add LEA number to line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line C - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID\s+(\d+)/ ) {
			$ID = $1;
        print FH "Monitor Order ID is: $ID\n";
        }
	}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	
# Add DNH group
   unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	$dnh_added = 0;
    

# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}

# Call flow
 # start PCM trace

    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
# Check status of line A is CPB
		
   unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
	
# D dials DISA number
    # my ($dialed_num) = ($disa_num =~ /\d{3}(\d+)/);
    # $dialed_num = $trunk_access_code . $dialed_num;
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
	
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $disa_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $disa_num successfully");
		print FH "STEP: D dials DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials DISA number - PASS\n";
    }
	sleep(5);
    
    
	

    # D dials authen code
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $authen_code,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $authen_code successfully");
		print FH "STEP: D dials authen code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials authen code - PASS\n";
    }
	sleep(2);
		# D hears recall dial tone
	%input = (
                -line_port => $list_line[3],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect recall dial tone line $list_dn[3]");
        print FH "STEP: D hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hears recall dial tone - PASS\n";
    }
	
	
	# D dials A, B rings and answers
   %input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: D dials A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials A - PASS\n";
    }
	sleep(5);
    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
				-ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
	
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[3]");
        print FH "STEP: D hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hears ringback tone - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1])) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
	%input = (
                -list_port => [$list_line[1],$list_line[3]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000,
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and D");
        print FH "STEP: Check speech path between B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and D - PASS\n";
    }
	# Check LEA C ring
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line LEA C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line LEA C ringing - PASS\n";
    }
	
	# LEA C answer
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
        print FH "STEP: offhook LEA $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook LEA $list_line[2] - PASS\n";
    }
	# LEA C can monitor the call between D and B
	%input = (
                -list_port => [$list_line[3],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between D and B");
        print FH "STEP: LEA can monitor the call between D and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between D and B - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
    
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }

    # Remove DNH from line A and B
    unless ($dnh_added) {
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
        }
    }
	
	# Deact LEA
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;     
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;      
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;      
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;      
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);    
}



sub ADQ1091_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_010");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_010";
    my $tcid = "ADQ1091_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
    my $trunk_region = $db_trunk{'tw_isup'}{-region};
    my $trunk_clli = $db_trunk{'tw_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, %info, $ID);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "configSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
    unless ($ses_core_li->loginCore(%core_account_li)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M LI - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line C
	$ses_core_li->execCmd("add TMA2M YES FTPV4 047 135 041 070 021 ibn $list_dn[1] +");
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes PXAUTO px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line B  ");
        print FH "STEP: Add SURV to line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line B - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line C  ");
        print FH "STEP: Add LEA number to line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line C - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID\s+(\d+)/ ) {
			$ID = $1;
        print FH "Monitor Order ID is: $ID\n";
        }
	}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	
	my $un_line = '1514004567';
    
	# A has SDN ($un_line)
    unless ($ses_core->callFeature(-featureName => "SDN $un_line 3 p \$", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line A-$list_dn[0]");
		print FH "STEP: Add SDN for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SDN for line A($list_dn[0]) - PASSED\n";
    }
	
# Add 3WC and SDN to line A
	unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: Add 3WC for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[0] - PASSED\n";
    }
	
    $add_feature_lineA = 0;

# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # Make call B to SDN of A
    
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => '1514004567',
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B cannnot call SDN of A ");
        print FH "STEP: B calls SDN of A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls SDN of A - PASS\n";
    }
	# Check LEA C ring
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	sleep(2);
	# LEA C answer
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
        print FH "STEP: offhook LEA $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook LEA $list_line[2] - PASS\n";
    }
	# LEA C can monitor the call between A and B
	%input = (
                -list_port => [$list_line[1],$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B");
        print FH "STEP: LEA can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B - PASS\n";
    }
	# A calls D, and A flashs again
	%input = (
                -line_port => $list_line[0],
                -flash_duration  => 600,
                -wait_for_event_time => $wait_for_event_time
                );
	unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash $list_line[0] successfully");
        print FH "STEP: A flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flash - PASS\n";
    }
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[0],
                -regionB => $list_region[3],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call D");
        print FH "STEP: A calls D - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls D - PASSED\n";
    }
# Verify speech path between A, B, D
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[3]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & D");
        print FH "STEP: Check speech path between A, B & D - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & D - PASSED\n";
	}
	# LEA C can monitor the call between A, B & D
	%input = (
                -list_port => [$list_line[0],$list_line[1], $list_line[3]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A, B & D");
        print FH "STEP: LEA can monitor the call between A, B & D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A, B & D - PASS\n";
    }
	
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
    # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }
	# Deact LEA
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0; 
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;    
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	# remove 3WC and SDN from line A
    unless ($add_feature_lineA) {
        foreach ('3WC','SDN'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }
	
	
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);    
}


sub ADQ1091_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_011");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_011";
    my $tcid = "ADQ1091_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $mlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "configSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	
	
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add MLH
	
    $ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
   
    unless (grep /MLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add MLH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MLH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	$mlh_added = 0;
# Add CFU to line A
	
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] CFU N \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[0]");
		print FH "STEP: add CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[0] - PASS\n";
    }
    
	my $cfu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CFWP');
    unless ($cfu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFU access code for line $list_dn[0]");
		print FH "STEP: get CFU access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFU access code for line $list_dn[0] - PASS\n";
    }
   


# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
	
# Call flow
   # start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
# Activate CFD from line A to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfu_acc . $list_dn[2] . '#';
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: Send digit to active CFU - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Send digit to active CFU - PASS\n";
    }
    
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[0] - PASS\n";
    }
	# Onhook line A
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
 # D calls A and the call is forwarded to C
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[3],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls A and they have speech path");
        print FH "STEP: D calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and they have speech path - PASS\n";
    }

	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
    # Get PCM trace
     if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}

    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }
 # remove CFU from line A

	$ses_core->execCmd ("servord");
    unless ($ses_core->execCmd("deo \$ $list_dn[0] $list_len[0] CFU \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot del CFU for line $list_dn[0]");
		print FH "STEP: del CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: del CFU for line $list_dn[0] - PASS\n";
    }
	
	# remove MLH
    unless ($mlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from MLH group");
            print FH "STEP: delete member $list_dn[1] from MLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from MLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);    
}

sub ADQ1091_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_012");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_012";
    my $tcid = "ADQ1091_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $add_feature_lineAB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my (@list_file_name,  %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "configSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
# Add CXR to line C
	unless ($ses_core->callFeature(-featureName => "cxr ctall n std", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[2]");
		print FH "STEP: add CXR for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[2] - PASS\n";
    }
    
    $add_feature_lineC = 0;
    
# Add CPU to line A and B (A and B must have the same custgroup)
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[1] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineAB = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CPU');
    unless ($cpu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CPU access code");
		print FH "STEP: get CPU access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CPU access code - PASS\n";
    }


# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
   # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
	
# Call flow
      # start PCM trace
	
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	

 # Make call D to C via SST
    my ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[3],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: D cannnot call C ");
        print FH "STEP: D calls C and C answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls C and C answer - PASS\n";
    }
	# C calls B via SST after flash
	($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
        print FH "STEP: C dials $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $list_dn[1] - PASS\n";
    }
	sleep (1);

   # C hears ringback
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
				-ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
	unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_line[2] ");
        print FH "STEP: C hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears ringback tone - PASS\n";
    }
	# B ring

    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
	
	
	# A dials CPU access code to pick up the call for B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
    }
    sleep(12);
	
	# check speech path between C and A
    %input = (
                -list_port => [$list_line[2],$list_line[0]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and A ");
        print FH "STEP: check speech path between C and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between C and A - PASS\n";
    }
	
    
	
	# Onhook C
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
		print FH "STEP: Onhook C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook C - PASS\n";
    }
    
   # check speech path between D and A
    %input = (
                -list_port => [$list_line[3],$list_line[0]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between D and A ");
        print FH "STEP: check speech path between D and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between D and A - PASS\n";
    }
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
   # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }
    # remove CPU from line A and B
    unless ($add_feature_lineAB) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[1]");
            print FH "STEP: Remove CPU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[1] - PASS\n";
        }
    }
	
	# remove CXR from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[0]");
            print FH "STEP: Remove CXR from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);    
}
}


sub ADQ1091_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_013");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_013";
    my $tcid = "ADQ1091_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $dlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $un_line = 1514004313;
	my (@list_file_name, %info);
    
	# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "configSession")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2M core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M core - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => "LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2M for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2M for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	
	
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add DLH
	
    $ses_core->execCmd("est \$ DLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
   
    unless (grep /DLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	$dlh_added = 0;
# Add LOD to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] lod $list_dn[2] \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LOD for line $list_dn[0]");
		print FH "STEP: add LOD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add LOD for line $list_dn[0] - PASS\n";
    }
   


# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASS\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	
	# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
# Call flow

    # start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# A offhooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
	
	# B offhooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
	# Make call D to A
    
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[3],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: D cannnot call A ");
        print FH "STEP: D calls A and C answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and C answer - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

    # Cleanup call
    unless ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
        }
    }
    # Get PCM trace
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# Stop tapi
    my $exist1 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
             
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
       
    }
	# remove LOD from A
	$ses_core->execCmd ("servord");
    unless ($ses_core->execCmd("deo \$ $list_dn[0] $list_len[0] lod \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot del LOD for line $list_dn[0]");
		print FH "STEP: del LOD for line $list_dn[0] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: del LOD for line $list_dn[0] - PASS\n";
    }
	
	# remove DLH
    unless ($dlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ dlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from DLH group");
            print FH "STEP: delete member $list_dn[1] from DLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from DLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
    close(FH);
    &ADQ1091_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1091_checkResult($tcid, $result);    
}

sub ADQ1091_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_014");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_014";
	my $tcid = "ADQ1091_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num, %info);
	
    
# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Add 3WC to line A
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: Add 3WC for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[0] - PASSED\n";
    }
    $feature_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1],$list_dn[2]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# B calls A, A flashs
    
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B can't call A");
        print FH "STEP: B calls A - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls A - PASSED\n";
    }
# A calls C, C rings and no answer, A flashs
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => ['',''],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call C");
        print FH "STEP: A calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls C - PASSED\n";
    }
	sleep (2);
# A on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[2]");
        print FH "STEP: Offhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASSED\n";
    }
# Verify speech path between B and C
	%input = (
				-list_port => [$list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between B & C");
        print FH "STEP: Check speech path between B & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between B & C - PASSED\n";
	}

# Onhook C and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }

################################## Cleanup ADQ1091_014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_014 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	###################Remove features added######################
	# Remove 3WC from line A
	if ($feature_added) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line B ($list_dn[0])");
            print FH "STEP: Remove 3WC from line A ($list_dn[0]) - FAILED\n";
        } else {
            print FH "STEP: Remove 3WC from line A ($list_dn[0]) - PASSED\n";
        }
    }
	################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_015");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_015";
	my $tcid = "ADQ1091_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	
    
# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Add MADN to line A and B with Pilot A
    # Note: 
	 unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot be in 'servord' mode");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 6 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add MADN for line $list_dn[0]");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN to line $list_dn[0] as primary - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[0] as primary - PASSED\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add MADN for line $list_dn[1]");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' ");
    }
    unless(grep /PRIMARY\: N/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN to line $list_dn[1] as member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[1] as member - PASSED\n";
    }
	
# Add SCA to line A with C in list
	unless ($ses_core->callFeature(-featureName => "$list_len[0] sca noama act $list_dn[2] 3 \$ n", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add MADN for line $list_dn[0]");
		print FH "STEP: Add SCA for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SCA for line $list_dn[0] - PASSED\n";
    }
	
	
# Verify the table SLELIST contains C
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SLELIST")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SLELIST");
		print FH "STEP: Login to table SLELIST - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } elsif (grep /$list_len[0] 0 SCA 0 N $list_dn[2]/, $ses_core->execCmd("format pack; list all")) {
		print FH "STEP: Verify C is in SCA list of A - PASSED\n";
	} else {
		print FH "STEP: Verify C is in SCA list of A - FAILED\n";
	}
    $feature_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0] == 1){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Scenario 1: C is in SCA calls to MADN group
# C calls A, A off-hook
    
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B can't call A");
        print FH "STEP: C calls A - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A - PASSED\n";
    }
# B off-hooks to join CONF
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[1]");
        print FH "STEP: Offhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASSED\n";
    }
# Verify speech path between A, B and C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C - PASSED\n";
	}
# Scenario 2: D is out of list SCA of A and D can't call to A
	%input = (
                -lineA => $list_line[3],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[3],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => ['',''],
                -flash => ''
                );
    if ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: D can call A successfully");
        print FH "STEP: Verify D can't call A - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: Verify D can't call A - PASSED\n";
    }
# Onhook A, B and C
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }

################################## Cleanup ADQ1091_015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_015 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	################### Remove features added ######################
	# Remove mdn & sca from line A
	$ses_core->execCmd ("servord");
	if ($feature_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[0] from MADN group");
            print FH "STEP: Remove line B ($list_dn[1]) from MADN group - FAILED\n";
        } else {
            print FH "STEP: Remove line B ($list_dn[1]) from MADN group - PASSED\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after DEO fail");
            }
            print FH "STEP: Remove MADN from line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: Remove MADN from line $list_dn[0] - PASSED\n";
        }
		
        unless ($ses_core->callFeature(-featureName => 'SCA', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCA from line $list_dn[0]");
            print FH "STEP: Remove SCA from line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: Remove SCA from line $list_dn[0] - PASSED\n";
			}
		
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort'");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1]");
            print FH "STEP: NEW line $list_dn[1] - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASSED\n";
        }
    }
	################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_016");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_016";
	my $tcid = "ADQ1091_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	my $trunk_access_code = $db_trunk{'pri_1'}{-acc};
    
# Which logs need to get
	
	 $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Add LNR to line A 
    unless ($ses_core->callFeature(-featureName => "LNR", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LNR for line $list_dn[0]");
		print FH "STEP: Add LNR for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LNR for line $list_dn[0] - PASSED\n";
    }

	
    $feature_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A calls B, B answers and on-hook
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	print FH "The dialed number through PRI on TMA2m: $dialed_num\n";
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                #-dialed_number => $list_dn[1],
				-dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# On-hook A and B
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
# Get LNR access code
	my $lnr_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'LNR');
    unless ($lnr_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get LNR access code for line $list_dn[0]");
		print FH "STEP: Get LNR access code for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code LNR is: $lnr_acc \n";
        print FH "STEP: Get LNR access code for line $list_dn[0] - PASSED\n";
    }
# A dials LNR ACC and B will answer
	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => '*'.$lnr_acc,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B can't answer ");
        print FH "STEP: A dials LNR AC and B answers A - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: C answers A successfully");
		print FH "STEP: A dials LNR AC and B answers A - PASSED\n";
    }
# Onhook A, B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }

################################## Cleanup ADQ1091_016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_016 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	################### Remove features added ######################
	# Remove LNR from line A
	if ($feature_added) {
        unless ($ses_core->callFeature(-featureName => 'LNR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove LNR from line $list_dn[0]");
            print FH "STEP: Remove LNR from line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: Remove LNR from line $list_dn[0] - PASSED\n";
			}
		
    }
	################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_017";
	my $tcid = "ADQ1091_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	my $add_tuple = 0;
    
# Which logs need to get
	
	 $log_type[0] = 0; #logutil
	 $log_type[1] = 0; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    # unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        # $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        # print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        # $result = 0;
        # goto CLEANUP;
    # } else {
        # print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    # }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }



################## Add feature or datafill table ###########################
# Check login table SITE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SITE");
		print FH "STEP: Login to table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table SITE - PASSED\n";
	}

# Determine the size of table SITE
	my @size;
	unless (grep /SIZE/, @size = $ses_core->execCmd("count")) {
            $logger->error(__PACKAGE__ . " $tcid: Count tuple failed");
            print FH "STEP: Find the size of table SITE - FAILED\n";
			$result = 0;
            goto CLEANUP;
          
    } else {
			foreach (@size){
				if ($_ =~ /SIZE\s+\=\s+(\d+)/){
					print FH "The size of table SITE is: $1\n";
				}
			}
        }
# Verify whether there is tuple PHUC 0 3
	if (grep /PHUC/, $ses_core->execCmd("pos PHUC 0")){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("del")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "Verify whether there is the tuple PHUC and delete if it exists\n";
				} else {
				
					print FH "Verify whether there is the tuple PHUC and it exists but can't delete\n";
					$result = 0;
					goto CLEANUP;
				}
			}
		}
	} else {
		print FH "There is not any PHUC tuple\n";
	}
# Add tuple PHUC 0 3 NWMSD \$ into table SITE
	
	if (grep /Y TO CONTINUE/, $ses_core->execCmd("add PHUC 0 3 NWMSD \$")) {
		if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")){
			if (grep /TUPLE ADDED/,$ses_core->execCmd("Y")){
				$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
				print FH "STEP: Add one tuple - PASSED\n";
				$add_tuple = 1;
			} else {
				print FH "STEP: Add one tuple - FAILED\n";
				$result = 0;
				goto CLEANUP;
			}
		}    
	} 
	$add_tuple = 1;
	
	
# Change the tuple

if ($add_tuple){
		$ses_core->execCmd("pos PHUC 0 3 NWMSD");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("change")){
			#
			if (grep /LTDSN/, $ses_core->execCmd("y")){
				if (grep /MODCOUNT/, $ses_core->execCmd("0")){
					if (grep /OPVRCLLI/, $ses_core->execCmd("0")){
						if (grep /ALMDATA/, $ses_core->execCmd("PRLCMVER90")){
							if (grep /Y TO CONFIRM/, $ses_core->execCmd("\$")){
								if (grep /TUPLE CHANGED/, $ses_core->execCmd("y")){
									print FH "STEP: Change the tuple - PASSED\n";
								} else {
									print FH "STEP: Change the tuple - FAILED\n";
									$result = 0;
								}
							}
						}
					}
					
				}
			}
		} elsif (grep /LTDSN/, $ses_core->execCmd("change")){
			if (grep /MODCOUNT/, $ses_core->execCmd("0")){
				if(grep /OPVRCLLI/, $ses_core->execCmd("0")){
					if (grep /ALMDATA/, $ses_core->execCmd("VER90")){
						if (grep /Y TO CONFIRM/, $ses_core->execCmd("\$")){
							if (grep /TUPLE CHANGED/, $ses_core->execCmd("y")){
								print FH "STEP: Change the tuple - PASSED\n";
							} else {
								print FH "STEP: Change the tuple - FAILED\n";
								$result = 0;
							}
						}
					}
				}
			}
		}
	}
# Delete a tuple
	if ($add_tuple){
		$ses_core->execCmd("pos PHUC 0");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("delete")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "STEP: Deleted one tuple - PASSED\n";
				} else {
					print FH "STEP: Deleted one tuple - FAILED\n";
					$result = 0;
				}
			}
		} elsif (grep /Y TO CONTINUE/, $ses_core->execCmd("delete")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "STEP: Deleted one tuple - PASSED\n";
			} else {
				print FH "STEP: Deleted one tuple - FAILED\n";
				$result = 0;
			}
		}
	}
############################################################################

	# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	} 
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

################################## Cleanup ADQ1091_017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_017 ##################################");

    # Cleanup call
    
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            $result = 0;
        }
    }
	################### Remove features added ######################

	#################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_018");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_018";
	my $tcid = "ADQ1091_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	my $add_tuple = 0;
    
# Which logs need to get
	
	 $log_type[0] = 0; #logutil
	 $log_type[1] = 0; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    # unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        # $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        # print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        # $result = 0;
        # goto CLEANUP;
    # } else {
        # print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    # }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }


################## Add feature or datafill table ###########################
# Check login table SITE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SITE");
		print FH "STEP: Login to table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table SITE - PASSED\n";
	}

# Determine the size of table SITE
	my @size;
	unless (grep /SIZE/, @size = $ses_core->execCmd("count")) {
            $logger->error(__PACKAGE__ . " $tcid: Count tuple failed");
            print FH "STEP: Find the size of table SITE - FAILED\n";
			$result = 0;
            goto CLEANUP;
          
    } else {
			foreach (@size){
				if ($_ =~ /SIZE\s+\=\s+(\d+)/){
					print FH "The size of table SITE is: $1\n";
				}
			}
        }
# Verify whether there is tuple PHUC 0
	if (grep /PHUC/, $ses_core->execCmd("pos PHUC 0")){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("del")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "Verify whether there is the tuple PHUC and delete if it exists\n";
				} else {
				
					print FH "Verify whether there is the tuple PHUC and it exists but can't delete\n";
					$result = 0;
					goto CLEANUP;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("del")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "Verify whether there is the tuple PHUC and delete if it exists\n";
			} else {
				print FH "Verify whether there is the tuple PHUC and it exists but can't delete\n";
				$result = 0;
				goto CLEANUP;
			}
		}
	} else {
		print FH "There is not any PHUC tuple\n";
	}
# Add tuple PHUC 0 3 NWMSD \$ into table SITE
	
	if (grep /Y TO CONTINUE/, $ses_core->execCmd("add PHUC 0 3 NWMSD \$")) {
		if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
			if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
				$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
				print FH "STEP: Add one tuple - PASSED\n";
				$add_tuple = 1;
			} else {
				print FH "STEP: Add one tuple - FAILED\n";
				$result = 0;
				goto CLEANUP;
			}
		}    
	} 
	$add_tuple = 1;
# Replace the tuple
	if ($add_tuple){
		if(grep /PHUC/, $ses_core->execCmd("pos PHUC 0")){
			if (/Y TO CONTINUE/, $ses_core->execCmd("rep PHUC 0 3 VER90 \$")){
				if (/Y TO CONFIRM/, $ses_core->execCmd("y")){
					if (/TUPLE REPLACED/, $ses_core->execCmd("y")){
						print FH "STEP: Replace the tuple - PASSED\n";
					} else{
						print FH "STEP: Replace the tuple - FAILED\n";
						$result = 0;
					}
				}
			} elsif (/Y TO CONFIRM/, $ses_core->execCmd("rep PHUC 0 3 VER90 \$")){
				if (/TUPLE REPLACED/, $ses_core->execCmd("y")){
						print FH "STEP: Replace the tuple - PASSED\n";
				} else{
						print FH "STEP: Replace the tuple - FAILED\n";
						$result = 0;
				}
			}
		} 
	}
# Change the tuple

if ($add_tuple){
		$ses_core->execCmd("pos PHUC 0");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("change")){
			#
			if (grep /LTDSN/, $ses_core->execCmd("y")){
				if (grep /MODCOUNT/, $ses_core->execCmd("0")){
					if (grep /OPVRCLLI/, $ses_core->execCmd("0")){
						if (grep /ALMDATA/, $ses_core->execCmd("NWMSD")){
							if (grep /Y TO CONFIRM/, $ses_core->execCmd("\$")){
								if (grep /TUPLE CHANGED/, $ses_core->execCmd("y")){
									print FH "STEP: Change the tuple - PASSED\n";
								} else {
									print FH "STEP: Change the tuple - FAILED\n";
									$result = 0;
								}
							}
						}
					}
					
				} 
			}
		} elsif (grep /LTDSN/, $ses_core->execCmd("change")){
			if (grep /MODCOUNT/, $ses_core->execCmd("0")){
				if(grep /OPVRCLLI/, $ses_core->execCmd("0")){
					if (grep /ALMDATA/, $ses_core->execCmd("NWMSD")){
						if (grep /Y TO CONFIRM/, $ses_core->execCmd("\$")){
							if (grep /TUPLE CHANGED/, $ses_core->execCmd("y")){
								print FH "STEP: Change the tuple - PASSED\n";
							} else {
								print FH "STEP: Change the tuple - FAILED\n";
								$result = 0;
							}
						}
					}
				}
			}
		}
	}
# quit all table and login site table again
	unless (grep /CI/, $ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot quit out table SITE");
		print FH "STEP: Quit out table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Quit out table SITE - PASSED\n";
	}
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SITE");
		print FH "STEP: Login to table SITE again - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table SITE again - PASSED\n";
	}
# Execute some command in SITE table
	unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot format pack for table SITE");
	}
	unless (grep /TOP/, $ses_core->execCmd("list 10")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute list for the table SITE");
		print FH "STEP: Execute 'list 10' for table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Execute 'list 10' for table SITE - PASSED\n";
	}
	unless (grep /\$/, $ses_core->execCmd("top")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute 'top' for the table SITE");
		print FH "STEP: Execute 'top' for table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Execute 'top' for table SITE - PASSED\n";
	}
	unless (grep /\$/, $ses_core->execCmd("bot")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute 'bot' for the table SITE");
		print FH "STEP: Execute 'bot' for table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Execute 'bot' for table SITE - PASSED\n";
	}
	unless (grep /\$/, $ses_core->execCmd("up")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute 'up' for the table SITE");
		print FH "STEP: Execute 'up' for table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Execute 'up' for table SITE - PASSED\n";
	}
	unless (grep /\$/, $ses_core->execCmd("down")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute 'down' for the table SITE");
		print FH "STEP: Execute 'down' for table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Execute 'down' for table SITE - PASSED\n";
	}
# Delete a tuple
	if ($add_tuple){
		$ses_core->execCmd("pos PHUC 0");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("delete")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "STEP: Deleted one tuple - PASSED\n";
				} else {
					print FH "STEP: Deleted one tuple - FAILED\n";
					$result = 0;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("delete")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "STEP: Deleted one tuple - PASSED\n";
			} else {
				print FH "STEP: Deleted one tuple - FAILED\n";
				$result = 0;
			}
		}
	}
############################################################################
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

################################## Cleanup ADQ1091_018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_018 ##################################");

    # Cleanup call
    
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            $result = 0;
        }
    }
	################### Remove features added ######################

	#################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_019";
	my $tcid = "ADQ1091_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	my $add_tuple = 0;
    
# Which logs need to get
	
	 $log_type[0] = 0; #logutil
	 $log_type[1] = 0; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    # unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        # $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        # print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        # $result = 0;
        # goto CLEANUP;
    # } else {
        # print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    # }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
	unless ($ses_ossgate = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_OSSGATESessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for OSSGATE - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for OSSGATE - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }


################## Add feature or datafill table ###########################
# Check login table SITE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SITE");
		print FH "STEP: Login to table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table SITE - PASSED\n";
	}

# Determine the size of table SITE
	my @size;
	my $amount_tuple;
	unless (grep /SIZE/, @size = $ses_core->execCmd("count")) {
            $logger->error(__PACKAGE__ . " $tcid: Count tuple failed");
            print FH "STEP: Find the size of table SITE - FAILED\n";
			$result = 0;
            goto CLEANUP;
          
    } else {
			foreach (@size){
				if ($_ =~ /SIZE\s+\=\s+(\d+)/){
					$amount_tuple = $1;
					print FH "The size of table SITE is: $amount_tuple\n";
				}
			}
        }
# Verify whether there is tuple BZTK 0
	if (grep /BZTK/, $ses_core->execCmd("pos BZTK 0")){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("del")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "Verify whether there is the tuple BZTK and delete if it exists\n";
				} else {
				
					print FH "Verify whether there is the tuple BZTK and it exists but can't delete\n";
					$result = 0;
					goto CLEANUP;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("del")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "Verify whether there is the tuple BZTK and delete if it exists\n";
			} else {
				print FH "Verify whether there is the tuple BZTK and it exists but can't delete\n";
				$result = 0;
				goto CLEANUP;
			}
		}
	} else {
		print FH "There is not any BZTK tuple\n";
	}
	
	
# Verify the size of site table to add more tuple BZTK
	# Add tuple PHUC 0 3 NWMSD \$ into table SITE
	if ($amount_tuple > 256 && $amount_tuple < 2048){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			} 
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}
	} elsif ($amount_tuple < 256){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}    
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}
	} else{
		$ses_core->execCmd("bot");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("delete")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "STEP: Deleted one tuple - PASSED\n";
				} else {
					print FH "STEP: Deleted one tuple - FAILED\n";
					$result = 0;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("delete")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "STEP: Deleted one tuple - PASSED\n";
			} else {
				print FH "STEP: Deleted one tuple - FAILED\n";
				$result = 0;
			}
		}
		# Add tuple BZTK after delete one tuple
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}    
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
		}
	}
	#$add_tuple = 1;
# Telnet to OSSGATE to associate GW with GWC
	$ses_ossgate ->{conn}->prompt('/>/');
	if (grep /Enter username and password/, $ses_ossgate->execCmd("telnet 0 10023")){
		$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate");
		$ses_ossgate ->{conn}->prompt('/>/');
		if (grep /logged in/, $ses_ossgate->execCmd("$ossgate[0] $ossgate[1]")){
			$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate with account $ossgate[0] $ossgate[1]");
			print FH "STEP: Login to OSSGATE - PASSED\n";
		} else {
			$logger->error(__PACKAGE__ . " $tcid: Can't login to ossgate");
			print FH "STEP: Login to OSSGATE - FAILED\n";
			$result = 0;
			goto CLEANUP;
		}
	}
# Login to xml mode
	sleep (3);
	#$ses_ossgate ->{conn}->prompt('/?/');
	unless ($ses_ossgate -> execCmd("\x02")) {
       $logger->error(__PACKAGE__ . ": Could not type Ctr+B");
    } 
	$ses_ossgate ->{conn}->prompt('/>/');
	unless (grep /Mode is xml/, $ses_ossgate -> execCmd("mode xml")) {
       $logger->error(__PACKAGE__ . ": Could not login to xml mode");
       print FH "STEP: Login to xml mode - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Login to xml mode - PASSED \n"; 
	}
# Associate GW with GWC
	# Using GWC 11 for TMA2m, 
	my $str_1 = '<?xml version="1.0" encoding="UTF-8" ?>
<CommandList>
        <Command>
                    <Interface>cs2kCfgMgrIf</Interface>
                    <Methods>
                                <assocMG usn="1" version="1.0">
                                <Parameters>
                                            <mgUIName>test</mgUIName>
                                            <mgProfileName>GENBAND_G6_PLG</mgProfileName>
                                            <mgIpAddr>10.250.169.100</mgIpAddr>
                                            <mgProtocolType>1</mgProtocolType>
                                            <mgProtocolVersion>1.0</mgProtocolVersion>
                                            <mgProtocolPort>2944</mgProtocolPort>
                                            <mgSiteName>BZTK</mgSiteName>
                                            <gwcUIName>GWC-11</gwcUIName>
                                            <reservedTerminations>100</reservedTerminations>
                                            <frameNumber>10</frameNumber>
                                            <unitNumber>9</unitNumber>
                                </Parameters>
                                </assocMG>
                    </Methods>
        </Command>
</CommandList>';
	my $str_2 = '<?xml version="1.0" encoding="UTF-8" ?>
<CommandList>
        <Command>
                    <Interface>cs2kCfgMgrIf</Interface>
                    <Methods>
                                <disAssocMG usn="1" version="1.0">
                                <Parameters>
                                              <mgUIName>test</mgUIName>
                                </Parameters>
                                </disAssocMG>
                    </Methods>
        </Command>
</CommandList>';
	$ses_ossgate->{conn}->prompt('/\/Response/');
	unless (grep /The MG was successfully associated/, $ses_ossgate -> execCmd("$str_1")) {
       $logger->error(__PACKAGE__ . ": Could not associate MG with GWC");
       print FH "STEP: Associate MG with GWC - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Associate MG with GWC - PASSED \n"; 
	}
	
	#Disassociate MG from GWC.
	$ses_ossgate->{conn}->prompt('/\/Response/');
	unless (grep /The MG was successfully disassociated/, $ses_ossgate -> execCmd("$str_2")) {
       $logger->error(__PACKAGE__ . ": Could not associate MG with GWC");
       print FH "STEP: Disassociate MG with GWC - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Disassociate MG with GWC - PASSED \n"; 
	}
############################################################################

	# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

################################## Cleanup ADQ1091_019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_019 ##################################");

    # Cleanup call
    
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            $result = 0;
        }
    }
	################### Remove features added ######################

	#################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}

sub ADQ1091_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1091_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1091_020";
	my $tcid = "ADQ1091_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1091");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my $feature_added = 0;
    my (@list_file_name, $dialed_num,  %info);
	my $add_tuple = 0;
    
# Which logs need to get
	
	 $log_type[0] = 0; #logutil
	 $log_type[1] = 0; #pcm
	 $log_type[2] = 0; #tapi

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
    # unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        # $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        # print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        # $result = 0;
        # goto CLEANUP;
    # } else {
        # print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    # }
	unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil - PASSED\n";
    }
    unless ($ses_ossgate = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_OSSGATESessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for OSSGATE - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for OSSGATE - PASSED\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }


################## Add feature or datafill table ###########################
# Check login table SITE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table SITE");
		print FH "STEP: Login to table SITE - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table SITE - PASSED\n";
	}

# Determine the size of table SITE
	my @size;
	my $amount_tuple;
	unless (grep /SIZE/, @size = $ses_core->execCmd("count")) {
            $logger->error(__PACKAGE__ . " $tcid: Count tuple failed");
            print FH "STEP: Find the size of table SITE - FAILED\n";
			$result = 0;
            goto CLEANUP;
          
    } else {
			foreach (@size){
				if ($_ =~ /SIZE\s+\=\s+(\d+)/){
					$amount_tuple = $1;
					print FH "The size of table SITE is: $amount_tuple\n";
				}
			}
        }
# Verify whether there is tuple BZTK 0
	if (grep /BZTK/, $ses_core->execCmd("pos BZTK 0")){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("del")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "Verify whether there is the tuple BZTK and delete if it exists\n";
				} else {
				
					print FH "Verify whether there is the tuple BZTK and it exists but can't delete\n";
					$result = 0;
					goto CLEANUP;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("del")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "Verify whether there is the tuple BZTK and delete if it exists\n";
			} else {
				print FH "Verify whether there is the tuple BZTK and it exists but can't delete\n";
				$result = 0;
				goto CLEANUP;
			}
		}
	} else {
		print FH "There is not any BZTK tuple\n";
	}
	
    
    # Verify the size of site table to add more tuple BZTK
	# Add tuple PHUC 0 3 NWMSD \$ into table SITE
	if ($amount_tuple > 256 && $amount_tuple < 2048){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			} 
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}
	} elsif ($amount_tuple < 256){
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}    
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}
	} else{
		$ses_core->execCmd("bot");
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("delete")){
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
					print FH "STEP: Deleted one tuple - PASSED\n";
				} else {
					print FH "STEP: Deleted one tuple - FAILED\n";
					$result = 0;
				}
			}
		} elsif (grep /Y TO CONFIRM/, $ses_core->execCmd("delete")){
			if (grep /TUPLE DELETED/, $ses_core->execCmd("y")){
				print FH "STEP: Deleted one tuple - PASSED\n";
			} else {
				print FH "STEP: Deleted one tuple - FAILED\n";
				$result = 0;
			}
		}
		# Add tuple BZTK after delete one tuple
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("add BZTK 0 0 NWMSD \$")) {
			if (grep /Y TO CONFIRM/, $ses_core->execCmd("y")){
				if (grep /TUPLE ADDED/,$ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 NWMSD' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
			}    
		} elsif (grep /Y TO CONFIRM/,$ses_core->execCmd("add BZTK 0 0 VER90 \$")){ # for TMA15/TMA20
				if (grep /TUPLE ADDED/, $ses_core->execCmd("y")){
					$logger->debug(__PACKAGE__ . " $tcid: One tuple added successfully in the SITE table");
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - PASSED\n";
					$add_tuple = 1;
				} else {
					print FH "STEP: Add one tuple 'BZTK 0 0 VER90' - FAILED\n";
					$result = 0;
					goto CLEANUP;
				}
		}
	}
	#$add_tuple = 1;
# Telnet to OSSGATE to associate GW with GWC
	$ses_ossgate ->{conn}->prompt('/>/');
	if (grep /Enter username and password/, $ses_ossgate->execCmd("telnet 0 10023")){
		$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate");
		$ses_ossgate ->{conn}->prompt('/>/');
		if (grep /logged in/, $ses_ossgate->execCmd("$ossgate[0] $ossgate[1]")){
			$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate with account $ossgate[0] $ossgate[1]");
			print FH "STEP: Login to OSSGATE - PASSED\n";
		} else {
			$logger->error(__PACKAGE__ . " $tcid: Can't login to ossgate");
			print FH "STEP: Login to OSSGATE - FAILED\n";
			$result = 0;
			goto CLEANUP;
		}
	}
# Login to xml mode
	sleep (3);
	unless ($ses_ossgate -> execCmd("\x02")) {
       $logger->error(__PACKAGE__ . ": Could not type Ctr+B");
    } 
	$ses_ossgate ->{conn}->prompt('/>/');
	unless (grep /Mode is xml/, $ses_ossgate -> execCmd("mode xml")) {
       $logger->error(__PACKAGE__ . ": Could not login to xml mode");
       print FH "STEP: Login to xml mode - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Login to xml mode - PASSED \n"; 
	}
# Associate GW with GWC
	# Using GWC 11 (with hightest frame is 511) for TMA2m, use gwc 30 (with hightest frame is 818) for TMA15
	my $str_1 = '<?xml version="1.0" encoding="UTF-8" ?>
<CommandList>
        <Command>
                    <Interface>cs2kCfgMgrIf</Interface>
                    <Methods>
                                <assocMG usn="1" version="1.0">
                                <Parameters>
                                            <mgUIName>test</mgUIName>
                                            <mgProfileName>GENBAND_G6_PLG</mgProfileName>
                                            <mgIpAddr>10.250.169.100</mgIpAddr>
                                            <mgProtocolType>1</mgProtocolType>
                                            <mgProtocolVersion>1.0</mgProtocolVersion>
                                            <mgProtocolPort>2944</mgProtocolPort>
                                            <mgSiteName>BZTK</mgSiteName>
                                            <gwcUIName>GWC-11</gwcUIName>
                                            <reservedTerminations>100</reservedTerminations>
                                            <frameNumber>511</frameNumber>
                                            <unitNumber>9</unitNumber>
                                </Parameters>
                                </assocMG>
                    </Methods>
        </Command>
</CommandList>';
	my $str_2 = '<?xml version="1.0" encoding="UTF-8" ?>
<CommandList>
        <Command>
                    <Interface>cs2kCfgMgrIf</Interface>
                    <Methods>
                                <disAssocMG usn="1" version="1.0">
                                <Parameters>
                                              <mgUIName>test</mgUIName>
                                </Parameters>
                                </disAssocMG>
                    </Methods>
        </Command>
</CommandList>';
	$ses_ossgate->{conn}->prompt('/\/Response/');
	unless (grep /The MG was successfully associated/, $ses_ossgate -> execCmd("$str_1")) {
       $logger->error(__PACKAGE__ . ": Could not associate MG with GWC");
       print FH "STEP: Associate MG with GWC - FAILED\n";
       $result = 0;	  
	   #goto CLEANUP;
     } else {
	   print FH "STEP: Associate MG with GWC - PASSED \n"; 
	}
	
	#Disassociate MG from GWC.
	$ses_ossgate->{conn}->prompt('/\/Response/');
	unless (grep /The MG was successfully disassociated/, $ses_ossgate -> execCmd("$str_2")) {
       $logger->error(__PACKAGE__ . ": Could not associate MG with GWC");
       print FH "STEP: Disassociate MG with GWC - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Disassociate MG with GWC - PASSED \n"; 
	}
############################################################################

	# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
					-list_trk_clli => [],
				);
		%info = $ses_tapi->startTapiTerm(%input);
		unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start tapitrace - PASSED\n";
		}
		$tapi_start = 1;
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

################################## Cleanup ADQ1091_020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1091_020 ##################################");

    # Cleanup call
    
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    if ($tapi_start) {
        %input = (
                    -testbed => $TESTBED{"c20:1:ce0"},
                    -gwc_user => $gwc_user,
                    -gwc_pwd => $gwc_pwd,
                    -log_path => $tapilog_dir,
                    -term_num => \%info,
                    -tcid => $tcid,
                );
        my %tapiterm_out = $ses_tapi->stopTapiTerm(%input);
        unless (%tapiterm_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop tapitrace");
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            $result = 0;
        }
    }
	################### Remove features added ######################

	#################################################################
    close(FH);
    &ADQ1091_cleanup();
    &ADQ1091_checkResult($tcid, $result);
}



##################################################################################
sub AUTOLOAD {
  
    our $AUTOLOAD;
  
    my $warn = "$AUTOLOAD  ATTEMPT TO CALL $AUTOLOAD FAILED (INVALID TEST)";
  
    if( Log::Log4perl::initialized() ) {
        
        my $logger = Log::Log4perl->get_logger($AUTOLOAD);
        $logger->warn( $warn );
    }
    else {
        Log::Log4perl->easy_init($DEBUG);
        WARN($warn);
    }
}

1;