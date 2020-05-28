#**************************************************************************************************#
#FEATURE                : <ADQ1086> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Dinh Van Hoang>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::ADQ1086::ADQ1086; 

use strict;
use Tie::File;
use File::Copy;
use Cwd qw(cwd);
use Data::Dumper;
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
our (%input, %input1, $ses_core, $ses_glcas, $ses_logutil,$ses_tapi,$ID,$ses_core_li,$ses_cli, $ses_gms,@output);
our %core_account = ( 
                    -username => ['testshell1','testshell2','testshell3','testshell4','testshell5','testshell6','testshell7','testshell8'], 
                    -password => ['automation','automation','automation','automation','automation','automation','automation','automation']
                    );
our %core_account_li = ( 
                    -username => ['liadmin'], 
                    -password => ['liadmin']
                    );							
our @cas_server = ('10.250.185.232', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';
our $tapilog_dir = '/home/ctttuyen/TAPI/';
our $pass_li = '123456';
our $li_user = 'liadmin';



# Line Info
our %db_line = (
                'V52_1' => {
                            -line => 17,
                            -dn => 1514004315,
                            -region => 'US',
                            -len => 'V52   00 0 00 15',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'V52_2' => {
                            -line => 9,
                            -dn => 1514004314,
                            -region => 'US',
                            -len => 'V52   00 0 00 14',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                 'V52_3' => {
                            -line => 31,
                            -dn => 1514004316,
                            -region => 'US',
                            -len => 'V52   00 0 00 16',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
				'V52_4' => {
                            -line => 35,
                            -dn => 1514004318,
                            -region => 'UK',
                            -len => 'V52   00 0 00 18',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
				'V52_5' => {
                            -line => 15,
                            -dn => 1514004313,
                            -region => 'UK',
                            -len => 'V52   00 0 00 13',
                            -info => 'IBN AUTO_GRP 0 0',
                            },			
						
                );
				
our %tc_line = (
                
				'ADQ1086_003' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_004' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_005' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_006' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_007' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_008' => ['V52_1','V52_2','V52_3','V52_4'],
                'ADQ1086_009' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_010' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_011' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_012' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_013' => ['V52_1','V52_2','V52_3','V52_4','V52_5'],
				'ADQ1086_014' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_015' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_016' => ['V52_1','V52_2'],
				'ADQ1086_017' => ['V52_1','V52_2','V52_4','V52_3'],
				'ADQ1086_018' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_019' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_020' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_021' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_022' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_023' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_024' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_025' => ['V52_1','V52_2','V52_3'],
				'ADQ1086_026' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_027' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_028' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_029' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1086_030' => ['V52_1','V52_2','V52_3','V52_4'],
							
				
);				

#################### Trunk info ###########################
our %db_trunk = (
                'g6_pri' =>{
                                -acc => 606,
                                -region => 'US',
                                -clli => 'G6STM1PRITEXT2W',
                            },
							
				'sst' =>{
                                -acc => 388,
                                -region => 'US',
                                -clli => 'T2SSTETSIV2',
                            },
			   'tw_isup' =>{
                                -acc => 506,
                                -region => 'US',
                                -clli => 'AUTOG9C7ETSI2W',
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



sub ADQ1086_cleanup {
    my $subname = "ADQ1086_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_gms, $ses_tapi, $ses_cli, $ses_core_li
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ1086_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ1086_checkResult";
    $logger->debug(__PACKAGE__ . ".$tcid: Test result : $result");
    if ($result) { 
        $logger->debug(__PACKAGE__ . "$tcid  Test case passed ");
            SonusQA::ATSHELPER::printPassTest($tcid);
            return 1;
    } else {
        $logger->debug(__PACKAGE__ . "$tcid  Test case failed ");
            SonusQA::ATSHELPER::printFailTest($tcid);
            return 0;
    }
}


##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                     "ADQ1086_007",
					 "ADQ1086_008",
					 "ADQ1086_009",
					 "ADQ1086_010",
					 "ADQ1086_011",   
					 "ADQ1086_012",
					 "ADQ1086_013",
					 "ADQ1086_014",
					 "ADQ1086_015",
					 "ADQ1086_016",  
					 "ADQ1086_017",  
					 "ADQ1086_018",  
					 "ADQ1086_019",
					 "ADQ1086_020",
					 "ADQ1086_021",
					 "ADQ1086_022",
					 "ADQ1086_023",
					 "ADQ1086_024",
					 "ADQ1086_025",
					 "ADQ1086_026",
					 "ADQ1086_027",
					 "ADQ1086_028",
					 "ADQ1086_029",
					 "ADQ1086_030",
					# "ADQ1086_004", # This tc takes long time because it relates to GWC
					# "ADQ1086_005",# This tc takes long time because it relates to GWC
					# "ADQ1086_006",# This tc takes long time because it relates to GWC
					# "ADQ1086_003", # Must book lab before runing this tc
                    
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
# |   ADQ1086 call service - R20 Sourcing Features - phase 1 (POH, ICTO, MTC)                                                              |
# +------------------------------------------------------------------------------+
# |   ADQ 1086                                                                  |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

# Here some notes that you need to check before you are run this suite:
# + Make sure all trunks are IDL ( the trunk which input in script)
# + Acess to core LI successful by user/pass: liadmin/liadmin  --> dnbdord/123456
# + Check Configure Tone Generation on GMS = US
# + TC3-->TC6: These tcs relative to core swap GMS, nedd to book lab before runing.

# + The TCs have DNH group is failed due to this field :XLAPLAN_RATEAREA_SERVORD_ENABLED MANDATORY_PROMPTS in "table ofcvar"
# --> Disable it by command: rep XLAPLAN_RATEAREA_SERVORD_ENABLED OFF



sub ADQ1086_003 { # Warm & Cold restart Core during 3WC
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_003"); 
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_003";
    my $tcid = "ADQ1086_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my $get_logutil = 1;



    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################ Add features or edit table ######################
# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: Add 3WC for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
####################### Call Flow #######################
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C - PASSED\n";
	}
# Excute "restart warm active".
	unless (grep /CI/, $ses_core -> execCmd("quit all")) {
       $logger->error(__PACKAGE__ . ": Could not be in CI mode");
       print FH "STEP: Turn back CI mode - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
	   print FH "STEP: Turn back CI mode - PASSED \n"; 
	}
	
	unless (grep /YES|Y|NO|N/, $ses_core -> execCmd("restart warm active")) {
       $logger->error(__PACKAGE__ . ": Enter command 'restart warm active' incorrectly");
       print FH "STEP: Enter command 'restart warm active'  - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
		$ses_core ->{conn}->prompt('/.+\$/');
		if (grep /Connection closed/, $ses_core -> execCmd("Y")) {
			print FH "STEP: Verify Core has restarted - PASSED \n"; 
		} else {
			print FH "STEP: Verify Core has restarted - FAILED \n";
		}
	}
		
# Verify the system is covered
	$ses_core->{conn}->prompt($ses_core->{DEFAULTPROMPT});
	unless (grep /cli/, $ses_core -> execCmd("cli")) {
       $logger->error(__PACKAGE__ . ": Could not be in cli mode");
    }
	my @array;
	for (my $i = 0; $i <= 20; $i++){
		unless (grep /in\-sync/, @array = $ses_core -> execCmd("sosAgent vca show VCA")){
			$logger->error(__PACKAGE__ . ": Core is in out-of-sync");
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			print FH "Core is out-of-service after WARM restart. Please wait\n";
			sleep (60);
		} else {
			print FH "Core is in-sync again. Congratulate\n";
			print FH "STEP: Verify system is recoverd successfully after Warm restart - PASSED\n";
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			last;
		}
	}
# Verify speech path between A, B, C again
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C agin - PASSED\n";
	}
# Excute "restart cold active" 1st.
	unless ($ses_core -> execCmd("sh")) {
       $logger->error(__PACKAGE__ . ": Can't enter command 'sh' ");
	}
	unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core again");
		print FH "STEP: Login TMA2m core again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core again - PASSED\n";
    }
	unless (grep /YES|Y|NO|N/, $ses_core -> execCmd("restart cold active")) {
       $logger->error(__PACKAGE__ . ": Enter command 'restart cold active' incorrectly");
       print FH "STEP: Enter command 'restart cold active' - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
		$ses_core ->{conn}->prompt('/.+\$/');
		if (grep /Connection closed/, $ses_core -> execCmd("Y")) {
			print FH "STEP: Verify Core has restarted during Cold restart - PASSED \n"; 
		} else {
			print FH "STEP: Verify Core has restarted during Cold restart - FAILED \n";
		}
	}
		
# Verify the system is covered
	$ses_core->{conn}->prompt($ses_core->{DEFAULTPROMPT});
	unless ($ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't be in cli mode");
		print FH "STEP: Turn back cli mode to verify system in-sync - FAILED\n";
		$result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Turn back cli mode to verify system in-sync - PASSED\n";
	}
	for (my $i = 0; $i <=20; $i++){
		unless (grep /in\-sync/, @array = $ses_core -> execCmd("sosAgent vca show VCA")){
			$logger->error(__PACKAGE__ . ": Core is out of service");
			print FH "Core is out of service after cold restart. Please wait\n";
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			sleep (120);
		} else {
			print FH "Core is in-sync again. Congratulate\n";
			print FH "STEP: Verify core is in-sync back - PASSED\n";
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			last;
		}
	}
# Verify speech path between A, B, C again
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	if ($ses_glcas->checkSpeechPathCAS(%input)) { ## After restart COLD core, speech path is expected failed
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C agin - PASSED\n";
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
# Make 3WC again
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C - PASSED\n";
	}
# Restart reload active
	unless ($ses_core -> execCmd("sh")) {
       $logger->error(__PACKAGE__ . ": Can't enter command 'sh' ");
	}
	unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core again to reload active unit");
		print FH "STEP: Login TMA2m core again to reload active unit - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core again to reload active unit - PASSED\n";
    }
	unless (grep /YES|Y|NO|N/, $ses_core -> execCmd("restart reload active")) {
       $logger->error(__PACKAGE__ . ": Enter command 'restart reload active' incorrectly");
       print FH "STEP: Enter command 'restart reload active' - FAILED\n";
       $result = 0;	  
	   goto CLEANUP;
     } else {
		$ses_core ->{conn}->prompt('/.+\$/');
		if (grep /Connection closed/, $ses_core -> execCmd("Y")) {
			print FH "STEP: Enter 'restart reload active' - PASSED \n"; 
		} else {
			print FH "STEP: Enter 'restart reload active' - FAILED \n";
		}
	}
		
# Verify the system is covered
	$ses_core->{conn}->prompt($ses_core->{DEFAULTPROMPT});
	unless ($ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't be in cli mode");
		print FH "STEP: Turn back cli mode to verify system in-sync - FAILED\n";
		$result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Turn back cli mode to verify system in-sync - PASSED\n";
	}
	for (my $i = 0; $i <=20; $i++){
		unless (grep /in\-sync/, @array = $ses_core -> execCmd("sosAgent vca show VCA")){
			$logger->error(__PACKAGE__ . ": Core is out of service");
			print FH "Core is out of service after cold restart. Please wait\n";
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			sleep (60);
		} else {
			print FH "Core is in-sync again. Congratulate\n";
			print FH "STEP: Verify core is in-sync back - PASSED\n";
			$logger->debug(__PACKAGE__ . " $tcid: ".Dumper(\@array));
			last;
		}
	}
# Verify speech path between A, B, C again
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	if ($ses_glcas->checkSpeechPathCAS(%input)) { ## After restart reload core, speech path is expected failed
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C again - PASSED\n";
	}
#  Onhook A, B and C

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
# Make 3WC again
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timADQ1086ut => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C - PASSED\n";
	}

################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        #$ses_logutil ->{conn}->prompt('/.+\$/');
		#unless ($ses_logutil->execCmd("sh"))
		unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog_afterCoreUp")) {
			$logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
			print FH "STEP: Login TMA2m to verify logutil after Core's up - FAILED\n";
			return 0;
		} else {
			print FH "STEP: Login TMA2m to verify logutil after Core's up - PASSED\n";
		}
		unless ($ses_logutil->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core again");
		print FH "STEP: Login TMA2m core to turn back session Logutil - FAILED\n";
        $result = 0;
        #goto CLEANUP;
		} else {
        print FH "STEP: Login TMA2m core to turn back session Logutil - PASSED\n";
		}
		unless (grep /LOGUTIL/, $ses_logutil->execCmd("logutil")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot be in logutil mode");
			print FH "STEP: Login Logutil mode again - FAILED\n";
        } else {
			print FH "STEP: Login Logutil mode again - PASSED\n";
		}
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_004 { # Warm & Cold Swact GWC during 3WC
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_004"); 
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_004";
    my $tcid = "ADQ1086_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $gwc_id = 3;
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
    }
	
	unless ($ses_cli = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CLISessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab with CLI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab with CLI mode - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################ Add features or edit table ######################
# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: Add 3WC for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
####################### Call Flow #######################
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
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

# Execute warm swact GWC during 3WC
	
	unless ($ses_cli -> warmSwactGWC(-gwc_id => -$gwc_id, -timeout => 120)){
		$logger->error(__PACKAGE__ . ": Could not warm swact GWC");
		print FH "STEP: Execute WARM Swact GWC - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "Execute WARM Swact GWC - PASSED\n";
	}
	
# Verify speech path between A, B, C again after WARM SWACT GWC
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C after WARM SWACT GWC");
        print FH "STEP: Check speech path between A, B & C after WARM SWACT GWC - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C after WARM SWACT GWC - PASSED\n";
	}
# Execute COLD Swact GWC
	unless ($ses_cli -> coldSwactGWC(-gwc_id => -$gwc_id, -timeout => 120)){
		$logger->error(__PACKAGE__ . ": Could not cold swact GWC");
		print FH "STEP: Execute COLD Swact GWC - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "Execute COLD Swact GWC - PASSED\n";
	}
	
# Verify A, B, C will drop speech path
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['none'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Verify speech path between A, B & C will drop after COLD swact GWC-$gwc_id - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Verify speech path between A, B & C will drop after COLD swact GWC-$gwc_id  - PASSED\n";
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
# Make 3WC again
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C => System recovered after COLD swact GWC-$gwc_id - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C => System recovered after COLD swact GWC-$gwc_id - PASSED\n";
	}
################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_005 { # Lock and unlock GWC during 3WC
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_005"); 
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_005";
    my $tcid = "ADQ1086_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $gwc_id = 3;
	my @list_file_name;
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
    }
	
	unless ($ses_cli = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CLISessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab with CLI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab with CLI mode - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################ Add features or edit table ######################

# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: Add 3WC for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
####################### Call Flow #######################
# Start PCM trace
    @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot start record PCM");
		}
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
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
# Excute "lock gwc".
	# Login cli mode from CLI session
	$ses_cli ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_cli -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	my @state_unit;
	unless (grep /active||standby/, @state_unit = $ses_cli -> execCmd("aim si-assignment show gwc-$gwc_id")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show gwc-$gwc_id");
		print FH "STEP: Enter command aim si-assignment show gwc-$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc-$gwc_id - PASSED\n";
	}
	# Determine unit active on GWC-3
	my $unit_active;
	foreach (@state_unit){
		if ($_ =~ /\s+(\d+)\s+SI_1\s+active/){
			$unit_active = $1;
			print FH "The unit active on GWC-$gwc_id is: $unit_active\n";
		} 
	}
	# Execue lock gwc for unit active
	unless ($ses_cli -> execCmd("aim service-unit lock gwc-$gwc_id $unit_active f")){
		$logger->error(__PACKAGE__ . ": Can't lock gwc-$gwc_id");
	}
	sleep (10);
	unless (grep /active/, $ses_cli -> execCmd("aim si-assignment show gwc-$gwc_id")){
		$logger->error(__PACKAGE__ . ": Failed to lock gwc-$gwc_id");
		print FH "STEP: Locked unit $unit_active active on gwc-$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Locked unit $unit_active active on gwc-$gwc_id - PASSED\n";
	}
# Verify speech path between A, B, C again after locked unit active
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C again after locked unit active - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C agin after locked unit active  - PASSED\n";
	}
# Execute lock the remain unit on GWC-3
	my $unit_remain = 1 - $unit_active;
	unless ($ses_cli -> execCmd("aim service-unit lock gwc-$gwc_id $unit_remain f")){
		$logger->error(__PACKAGE__ . ": Can't lock gwc-$gwc_id");
	}
	
	for (my $i = 0; $i <=10; $i++){
		if (grep /active/, $ses_cli -> execCmd("aim si-assignment show gwc-$gwc_id")){
			print FH "Please wait the unit $unit_remain remain is being locked on gwc-$gwc_id \n";
			sleep (5);
		} else {
			print FH "STEP: Locked unit $unit_remain remain on gwc-$gwc_id - PASSED\n";
			last;
		}
	}
	sleep (10);
# Check all line will be LMB after all unit are locked
	for (my $i = 0; $i <= $#list_dn; $i++){
		unless (grep /LMB/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not LMB");
            print FH "STEP: Verify the line $list_dn[$i] is LMB - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Verify the line $list_dn[$i] is LMB - PASSED\n";
        }
    }
	sleep (10);
# Verify A, B, C will drop speech path
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['none'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Verify speech path between A, B & C will drop after all units are locked - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Verify speech path between A, B & C will drop after all units are locked  - PASSED\n";
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
# Execute unlock all units locked.
	unless ($ses_cli -> execCmd("aim service-unit unlock gwc-$gwc_id $unit_active")){
		$logger->error(__PACKAGE__ . ": Can't lock gwc-$gwc_id");
	}
	sleep (10);
	unless ($ses_cli -> execCmd("aim service-unit unlock gwc-$gwc_id $unit_remain")){
		$logger->error(__PACKAGE__ . ": Can't lock gwc-$gwc_id");
	}
	#sleep (60);
	for (my $i=0; $i < 20; $i++) {
		unless (grep /standby/, $ses_cli -> execCmd("aim si-assignment show gwc-$gwc_id")){
			$logger->error(__PACKAGE__ . ": All unit are unlocked on gwc-$gwc_id failed");
			print FH "Please wait all units are going up on gwc-$gwc_id\n";
			sleep (20);
		} else {
			print FH "STEP: Verify all units are unlocked successfully on gwc-$gwc_id - PASSED\n";
			last;
		}
	}
	sleep (30);
# Verify all line will be IDL after all unit are unlocked
	for (my $i = 0; $i <= $#list_dn; $i++){
		unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Verify the line $list_dn[$i] is IDL - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Verify the line $list_dn[$i] is IDL - PASSED\n";
        }
    }
	sleep (20);
# Make a new 3WC again to verify all unit unlocked successfully
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Verify all the units on gwc-$gwc_id are recovered - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Verify all the units on gwc-$gwc_id are recovered - PASSED\n";
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
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
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
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_006 { # Reset GMS during 3WC
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_006"); 
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_006";
    my $tcid = "ADQ1086_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $gwc_id = 3;
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
    }
	
	unless ($ses_cli = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CLISessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab with CLI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab with CLI mode - PASSED\n";
    }
	
	unless ($ses_gms = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:2:ce0"}, -sessionLog => $tcid."_GMSSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:2:ce0'}" );
        print FH "STEP: Login GMS TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GMS TMA2m Lab - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################ Add features or edit table ######################
# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: Add 3WC for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
####################### Call Flow #######################
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
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
# su root mode of GMS TMA2m
	 unless ($ses_gms->enterRootSessionViaSU('')) {
        $logger->debug(__PACKAGE__ . " : Could not enter sudo root session");
        print FH "STEP: Enter root session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
    	print FH "STEP: Enter root session - PASSED\n";
    }
# Execute command reboot
	$ses_gms ->{conn}->prompt('/.+#/');
	unless (grep /The system is going down for reboot NOW!/, $ses_gms -> execCmd("reboot")) {
       $logger->error(__PACKAGE__ . ": Could not reboot GMS");
       print FH "STEP: Enter command 'reboot' GMS - FAILED\n";
       $result = 0;
	   goto CLEANUP;
     } else {
       print FH "STEP: Enter command 'reboot' GMS - PASSED \n"; 
	   }
# Verify GMS is shutting down with Inserv = 0
	my @array;
	my ($insv_port, $bsy_port);
	for (my $i = 0; $i < 20; $i++ ){
		unless (grep /MAPCI/, $ses_core -> execCmd("mapci nodisp;mtc;pm; post gwc $gwc_id")) {
		   $logger->error(__PACKAGE__ . ": Could not login mapci mode");
		   }
		unless (grep /Conf3/, @array = $ses_core -> execCmd("listres")){
		   $logger->error(__PACKAGE__ . ": Could not list out all port from GMS");
		   print FH "STEP: List out the resources of GMS for 3WC - FAILED\n";
		   $result = 0;
		   goto CLEANUP;
		 } else {
		   print FH "List out the resources of GMS for 3WC in the $i time after 20s - PASSED \n"; 
		   }
		foreach (@array){
			if ($_ =~ /Conf3\s+\d+\s+(\d+)\s+(\d+).+/) {
				$insv_port = $1;
				$bsy_port = $2;
			}
		}
		if ($insv_port == 0 && $bsy_port > 0) {
			print FH "GMS is in progress shutting down\n";
			last;
		}
		sleep (20);
		
	}
# Verify GMS is recovered with InservPort > 0
	for (my $i = 0; $i < 20; $i++ ){
		unless (grep /MAPCI/, $ses_core -> execCmd("mapci nodisp;mtc;pm; post gwc $gwc_id")) {
		   $logger->error(__PACKAGE__ . ": Could not login mapci mode");
		   }
		unless (grep /Conf3/, @array = $ses_core -> execCmd("listres")){
		   $logger->error(__PACKAGE__ . ": Could not list all port from GMS");
		   print FH "STEP: List out the resources of GMS for 3WC - FAILED\n";
		   $result = 0;
		   goto CLEANUP;
		 } else {
		   print FH "List out the resources of GMS for 3WC in the $i time after 30s - PASSED \n"; 
		   }
		foreach (@array){
			if ($_ =~ /Conf3\s+\d+\s+(\d+)\s+(\d+).+/) {
				$insv_port = $1;
				$bsy_port = $2;
			}
		}
		if ($insv_port > 0 && $bsy_port == 0) {
			print FH "GMS rebooted successfully\n";
			last;
		}
		sleep (30);
	}
	
# Verify A, B, C will drop speech path
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['none'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Verify speech path between A, B & C will drop after reset GMS - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Verify speech path between A, B & C will drop after reset GMS - PASSED\n";
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
# Make 3WC again
# A calls B, and B flashs
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: A calls B - PASSED\n";
    }
# B calls C, and B flashs again
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: B can't call C");
        print FH "STEP: B calls C - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls C - PASSED\n";
    }
# Verify speech path between A, B, C
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C");
        print FH "STEP: Check speech path between A, B & C => GMS recovered after reset GMS - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C => GMS recovered after reset GMS - PASSED\n";
	}
################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    # Stop Logutil
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_007");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_007";
    my $tcid = "ADQ1086_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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

# Add SCA to line A 
	
	
   $ses_core->execCmd("servord");
   sleep(1);
   @output = $ses_core->execCmd("ado \$ $list_dn[0] sca NOAMA act $list_dn[1] 3 $list_dn[2] 3 \$ N \$ y y");
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
    unless(grep /SCA NOAMA ACT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: add SCA to line $list_dn[0] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCA to line $list_dn[0] as member - PASS\n";
    }
    $feature_added = 0;


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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
    # Call flow
    # Make call B to A 
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
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path ");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    
    }
    sleep(5);
	
	# Call flow
    # Make call C to A 
     %input1 = (
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
		unless ($ses_glcas->makeCall(%input1)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and they have speech path ");
        print FH "STEP: C calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and they have speech path - PASS\n";
    }		
     
	
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    
    }
	sleep(5);
	
	# Call flow
    # Offhook E to Make call to A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
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
    }
    sleep(2);
    
    # Check line A doesn't ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
	$logger->error(__PACKAGE__ . " $tcid: line A is not ringing ");
        print FH "STEP: Check line A doesn't ringing - FAIL\n";
		$result = 0;
        goto CLEANUP;
        
    } else {
        print FH "STEP: Check line A doesn't ringing - PASS\n";
		
		
    }
				
################################## Cleanup  ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup  ##################################");

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
    # return line A to service
    if (grep /\sMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
        unless ($ses_core->execCmd("rts")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
        }
        unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
            $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL after 'rts' ");
            print FH "STEP: make line $list_dn[0] idle - FAIL\n";
        } else {
            print FH "STEP: make line $list_dn[0] idle - PASS\n";
        }
        foreach ('abort','quit all') {
            unless ($ses_core->execCmd("$_")) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot execute command '$_)' ");
            }
        }
    }

   

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_008");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_008";
    my $tcid = "ADQ1086_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");
	
	my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});


   
    
    my $wait_for_event_time = 30;
    my $dnh_added = 1;
    my $mdn_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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

###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
# Make A call B, B rings and answers
    
    # Make call
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }
	
	
   # Make C call D, D rings and answers
    
    # Make call
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[2],
                -regionB => $list_region[3],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls D and they have speech path ");
        print FH "STEP: C calls D and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls D and they have speech path - PASS\n";
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
    
    # Manual make busy line A
	unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
	sleep(1);
    unless (grep /\sCPD\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not CPD after 'bsy' ");
        print FH "STEP: make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] busy - PASS\n";
    }
	 sleep(1);
	# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
	 sleep(1);
	 
	# Check line A is busy	
	unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] busy - PASS\n";
    }
	 
	 
	# Manual return line A is idl
	unless ($ses_core->execCmd("rts")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
    }
	sleep(1);
    unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL after 'rts' ");
        print FH "STEP: make line $list_dn[0] idl - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] idl - PASS\n";
    }
	 sleep(1);
	 
	# Check status of line D is CPB
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[3] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[3] is not CPB status");
        print FH "STEP: Check D is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check D is CPB status - PASSED\n";
	}
	
	 
	# Manucl enter "frls" to line D
	unless ($ses_core->execCmd("frls")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
	sleep(1);
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[3] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[3] is not MB after 'frls' ");
        print FH "STEP: make line $list_dn[3] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[3] busy - PASS\n";
    }
	
	 
	# Manual return line D 

	unless ($ses_core->execCmd("rts")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
    }
	sleep(2);
    unless (grep /\sCPB\s/, $ses_core->execCmd("post d $list_dn[3] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[3] is not CPB after 'rts' ");
        print FH "STEP: make line $list_dn[3] CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[3] CPB - PASS\n";
    }
	
	# Onhook C and D
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[3]");
        print FH "STEP: Onhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line D - PASS\n";
    }
	 sleep(1);
	 
	# Verify new call is successfully
	
	# Make A call B, B rings and answers
    
    # Make call
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }
	
	# Make C call D, D rings and answers
    
    # Make call
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[2],
                -regionB => $list_region[3],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls D and they have speech path ");
        print FH "STEP: C calls D and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls D and they have speech path - PASS\n";
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
    

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}

sub ADQ1086_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_009");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_009";
    my $tcid = "ADQ1086_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'cas_r2'}{-acc};
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
# Add CNF  to line A
   
    unless ($ses_core->callFeature(-featureName => 'CNF C06', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CNF for line $list_dn[0]");
		print FH "STEP: add CNF for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CNF for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

     my $cnf_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CONF');
    unless ($cnf_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CNF access code for line $list_dn[0]");
		print FH "STEP: get CNF access code for line $list_dn[0] is $cnf_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CNF access code for line $list_dn[0] is $cnf_acc - PASS\n";
    }

# Add CFD  to line C
   
    
	
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[3]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
		print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
   
    $add_feature_lineC = 0;

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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
    # Activate CFD from line C to line E
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    ($dialed_num) = '*' . $cfd_acc . $list_dn[3] . '#';
    %input = (
                -line_port => $list_line[2],
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
    
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[4]");
        print FH "STEP: activate CFD for line $list_dn[4] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[4] - PASS\n";
    }
	# Onhook line C
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
   
    
	# Make A call B, B rings and answers, A flash
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
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls B and they have no speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

	
	# A dials *cnf_acc
	
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cnf_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cnf_acc successfully");
		print FH "STEP: A dials cnf_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials cnf_acc - PASS\n";
    }

     sleep(1);		
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

     # A flashes again and calls C 
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
		print FH "STEP: A flash again - FAIL\n";
        $result = 0;
      goto CLEANUP;
    } else {
        print FH "STEP: A flash again - PASS\n";
    }
	


	# Make A call C and call forward to E
    
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 10','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls C and the call is not fowarded to E ");
        print FH "STEP: A calls C and the call is fowarded to E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C and the call is fowarded to E - PASS\n";
    }
	
	
	# A dials *cnf_acc again
	
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cnf_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cnf_acc successfully");
		 print FH "STEP: A dials cnf_acc again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials cnf_acc again - PASS\n";
    }


	# Verify A,E,B join conferance have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and E and B ");
        print FH "STEP: check speech path between A and E and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and E and B - PASS\n";
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
    # remove CWT and CWI and CFD from line C
    unless ($add_feature_lineC) {
        
            unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
                print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
            } else {
                print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
            }
        
    }
    # remove CNF from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CNF', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CNF from line $list_dn[0]");
            print FH "STEP: Remove CNF from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CNF from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}

sub ADQ1086_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_010");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_010";
    my $tcid = "ADQ1086_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
	my $trunk_access_code_sip = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
# Add PRK  to line A
   
    unless ($ses_core->callFeature(-featureName => 'PRK', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add PRK for line $list_dn[0]");
		print FH "STEP: add PRK for line $list_dn[0]  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add PRK for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

     my $prk_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'PRKS');
    unless ($prk_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[0]");
		print FH "STEP: get PRK access code for line $list_dn[0] is $prk_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get PRK access code for line $list_dn[0] is $prk_acc - PASS\n";
    }

# Add 3WC  to line C
   
    
	
	unless ($ses_core->callFeature(-featureName => "3WC $list_dn[4]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: add 3WC for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[2] - PASS\n";
    }
   
    $add_feature_lineC = 0;

    my $prk_acc_R = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'PRKR');
    unless ($prk_acc_R) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[2]");
		print FH "STEP: get PRK access code for line $list_dn[2] is $prk_acc_R - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get PRK access code for line $list_dn[2] is $prk_acc_R- PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
   
	# Make A call D via PRI trunk , D rings and answers, A flash
	($dialed_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $dialed_num,
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
	
	# A dials *prk_acc
	
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$prk_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $prk_acc successfully");
		print FH "STEP: A dials prk_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials prk_acc - PASS\n";
    }
	
	 # Verify D hears busy tone or ringback tone after flash *prk_acc
	
	sleep(1);
    my %input = (
                -line_port => $list_line[3],
                -busy_tone_duration => 2000,
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

    # Make B call C via SIP trunk , C rings and answers, C flash
	 ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_sip . $dialed_num;
	%input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'C'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B calls C and they have no speech path ");
        print FH "STEP: B calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path - PASS\n";
    }

     # C dials *prk_acc_R + DN(A)
	
    ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = '*'.$prk_acc_R.$dialed_num.'#';
	
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	print FH "dials num is $dialed_num \n";		
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: C dials prk_acc and dials A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials prk_acc and dials A - PASS\n";
    }
	

	# Check speech path between C and D 
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
	# C flash again
	%input = (
                -line_port => $list_line[2], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[2]");
		print FH "STEP: C flash again- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C flash again - PASS\n";
		
    }
	
	# Check speech path between B, C, D
	 %input = (
                -list_port => [$list_line[1],$list_line[2], $list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and C,D");
        print FH "STEP: Check speech path between B and C,D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and C,D - PASS\n";
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
    # remove 3WC C
    unless ($add_feature_lineC) {
       
            unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[2]");
                print FH "STEP: Remove 3WC from line $list_dn[2] - FAIL\n";
            } else {
                print FH "STEP: Remove 3WC from line $list_dn[2] - PASS\n";
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
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}

sub ADQ1086_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_011");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_011";
    my $tcid = "ADQ1086_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[0], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number is $disa_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number is $disa_num - PASS\n";
    }
    my $authen_code = $ses_core->getAuthenCode($list_dn[0]);
    unless ($authen_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get authencation code");
		print FH "STEP: get authencation code is $authen_code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get authencation code is $authen_code - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
# Call flow
    #Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	 # A dials DISA number via SIP trunk
	($dialed_num) = ($disa_num =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	
	my %input = (
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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
	
	# A dials DISA number
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: A dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
	
	# A hears confirm tone 
	sleep(2);
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
    sleep(5);

    # A dials authen code
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $authen_code,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $authen_code successfully");
        print FH "STEP: A dials authen code $authen_code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials authen code $authen_code- PASS\n";
    }
    sleep(1);
	# A hears recall dials tone
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }
	
	# A dials DN(B)
	 %input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] ");
        print FH "STEP: A dials DN B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials DN B - PASS\n";
    }
    sleep(1);
	
	# A hears ringback tone

	%input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASS\n";
    }
	
	# B ringging tone
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
	
	# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

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
    

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}




sub ADQ1086_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_012");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_012";
    my $tcid = "ADQ1086_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

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
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
	
	
    # Add A into MADN group
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
        print FH "STEP: add SCA to line $list_dn[0] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCA to line $list_dn[0] as member - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
	
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	 
	# C call A 
	# Offhook C and call A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: Dials line A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Dials line A $list_dn[0] - PASS\n";
    }
    
	
	# Check both A,B are ringing	
  	 
    # A ring and answers
	sleep(2);
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
	
	# B ring and answers
	sleep(2);
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
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[1] - PASS\n";
    }
	
    # Verify A,C still have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C ");
        print FH "STEP: check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and C - PASS\n";
    }
	
	
   # Offhook B and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	 # Verify A,C, B still have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[2],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C, B ");
        print FH "STEP: check speech path between A and C, B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and C, B - PASS\n";
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
    
	 # remove MADN and SCA  from line A and B
  
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
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}

sub ADQ1086_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_013");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ1086_013";
    my $tcid = "ADQ1086_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    ############################## line DB #####################################
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};	
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;

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
	
	my $un_line;
	# Out line C
    $ses_core->execCmd("servord");
	$ses_core->execCmd("out \$ $list_dn[4] $list_len[4] bldn y y");
	unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[4]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[4] ");
        print FH "STEP: Out line $list_dn[4]   - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Out line $list_dn[4]   - PASS\n";
		$un_line = $list_dn[4];
    }
	
    # Enter into table PRECONF then add 3 0 $un_line D IBN AUTO_GRP 10 Y Y Y Y N Y $ y y
	unless(grep /TABLE:\s+PRECONF/, $ses_core_li->execCmd("table preconf")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter to table preconf ");
        print FH "STEP: Enter to table preconf - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter to table preconf - PASS\n";
    }
	
	# add 3 0 $un_line D IBN AUTO_GRP 10 Y Y Y Y N Y $
	unless(grep/ENTER Y TO CONTINUE PROCESSING/, $ses_core_li->execCmd("add 3 0 $un_line D IBN auto_grp 10 Y Y Y Y N Y \$")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add $un_line");
        print FH "STEP: Add $un_line - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add $un_line - PASS\n";
    }
	
	# Enter Y to add
	unless(grep /TUPLE TO BE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to add ");
        print FH "STEP: Enter Y to add - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to add - PASS\n";
    }
	
	# Enter Y to confirm 
	unless(grep /TUPLE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to confirm ");
        print FH "STEP: Enter Y to confirm - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to confirm - PASS\n";
    }
	
	# Add 3 1 DN(A) P 30 $
	
	unless(grep /ENTER Y TO CONTINUE PROCESSING/, $ses_core_li->execCmd(" add 3 1 $list_dn[0] P 30 \$ ")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add $list_dn[0] ");
        print FH "STEP: Add 3 1 $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3 1 $list_dn[0] - PASS\n";
    }
	
	# Enter Y to add
	unless(grep /TUPLE TO BE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to add ");
        print FH "STEP: Enter Y to add - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to add - PASS\n";
    }
	
	# Enter Y to confirm 
	unless(grep /TUPLE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to confirm ");
        print FH "STEP: Enter Y to confirm - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to confirm - PASS\n";
    }
	
	# Add 3 2 DN(B) P 60 $
	
	unless(grep /ENTER Y TO CONTINUE PROCESSING/, $ses_core_li->execCmd(" add 3 2 $list_dn[1] P 60 \$ ")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add $list_dn[0] ");
        print FH "STEP: Add 3 2 $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3 2 $list_dn[1] - PASS\n";
    }
	
	# Enter Y to add
	unless(grep /TUPLE TO BE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to add ");
        print FH "STEP: Enter Y to add - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to add - PASS\n";
    }
	
	# Enter Y to confirm 
	unless(grep /TUPLE ADDED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to confirm ");
        print FH "STEP: Enter Y to confirm - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter Y to confirm - PASS\n";
    }
	
	# Out session
	
	unless(grep /CI/, $ses_core_li->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot quit session ");
        print FH "STEP: Quit session - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Quit session - PASS\n";
    }
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	
	
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
	
	# Add SURV to line A and LEA to line C   ##### PXAUTO
	
	 my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);  	 
    $lea_num = $trunk_access_code . $lea_num;
	 print FH "Lea num is $lea_num\n";
	$ses_core_li->execCmd("add TMA2M YES FTPV4 047 135 041 070 021 ibn $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes PXAUTO px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line C  ");
        print FH "STEP: Add LEA number to line C $list_dn[2]- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line C $list_dn[2] - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line A  ");
        print FH "STEP: Add LEA number to line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line A - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID:\s+(\d+)/ ) {
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
	
	
    # Get DISA number and authencation code
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[0], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number is $disa_num- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number is $disa_num- PASS\n";
    }
    my $authen_code = $ses_core->getAuthenCode($list_dn[0]);
    unless ($authen_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get authencation code");
		print FH "STEP: get authencation code is $authen_code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get authencation code is $authen_code - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
	
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
	
	#  D calls $un_line, A,B,C rings and A answers,  $un_line,
	%input = (
                -line_port => $list_line[3],
                -dialed_number => $un_line,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $un_line successfully");
		print FH "STEP: E dials $un_line - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: E dials $un_line - PASS\n";
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
	
	# Offhook A and answers
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Verify A,D have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and D");
        print FH "STEP: Check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and D - PASS\n";
    }
	
	# Both B and C continue rings

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
	
	
	# C answers, offhook C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	# LEA C can monitor the call between A and D
    %input = (
                -list_port => [$list_line[0],$list_line[3]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and D");
        print FH "STEP: LEA can monitor the call between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and D - PASS\n";
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
	
	# Out session
	
	unless(grep /CI/, $ses_core_li->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot quit session ");
        print FH "STEP: Quit session - FAIL\n";
        $result = 0;
        
    } else {
        print FH "STEP: Quit session - PASS\n";
    }
	# Enter into table PRECONF then del 3 0 1514004313 D IBN AUTO_GRP 10 Y Y Y Y N Y $ y y
	unless(grep /TABLE:\s+PRECONF/, $ses_core_li->execCmd("table preconf")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter to table preconf ");
        print FH "STEP: Enter to table preconf - FAIL\n";
        $result = 0;    
    } else {
        print FH "STEP: Enter to table preconf - PASS\n";
    }
	
	# Del 3 0 $un_line D IBN AUTO_GRP 10 Y Y Y Y N Y $
	unless(grep /ENTER Y TO CONTINUE PROCESSING/, $ses_core_li->execCmd("del 3 0 $un_line D IBN auto_grp 10 Y Y Y Y N Y \$")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Del $un_line ");
        print FH "STEP: Del $un_line - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Del $un_line - PASS\n";
    }
	
	# Enter Y to del
	unless(grep /TUPLE TO BE DELETED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to del ");
        print FH "STEP: Enter Y to del - FAIL\n";
        $result = 0;
        
    } else {
        print FH "STEP: Enter Y to del - PASS\n";
    }
	
	# Enter Y to confirm 
	unless(grep /TUPLE DELETED/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter Y to confirm ");
        print FH "STEP: Enter Y to confirm - FAIL\n";
        $result = 0;   
    } else {
        print FH "STEP: Enter Y to confirm - PASS\n";
    }
	
	# New line for running the next TC
	 if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[4] $list_line_info[4] $list_len[4] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[4] ");
            print FH "STEP: NEW line $list_dn[4] for running the next tc - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[4] for running the next tc - PASSED\n";
        }

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);
}



sub ADQ1086_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_014");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_014";
    my $tcid = "ADQ1086_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
	
    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};	
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
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

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	# Verify the tuple AUTO_GRP exists or not
     # Login to table MMCONF
	unless (grep /TABLE:\s+MMCONF/, $ses_core->execCmd("Table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table MMCONF");
		print FH "STEP: Login to table MMCONF - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table MMCONF - PASSED\n";
	}
	
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 151 400 0000 0 Y Y N 150 FLASHONLY \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 151 400 0000 0 Y Y N 150 FLASHONLY \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /FLASHONLY/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos AUTO_GRP 0'");
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - PASS\n";
    }
	# Out session
	
	unless(grep /CI/, $ses_core_li->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot quit session ");
        print FH "STEP: Quit session - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Quit session - PASS\n";
    }
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
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
	
	# Add SURV to line A and LEA to line D
	$ses_core_li->execCmd("add TMA2M YES FTPV4 047 135 041 070 021 ibn $list_dn[0] +");
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes PXAUTO px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line A  ");
        print FH "STEP: Add SURV to line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line A - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID:\s+(\d+)/ ) {
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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
############################# Call-flow #################################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
		
	# B off-hooks, dials MMCONF number (1514000000)
	# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B $list_dn[1] - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B $list_dn[1] - PASSED\n";
    }
	# B hears dial tone
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASSED\n";
    }
    
	#B dials MMCONF number
	
	%input = (
                -line_port => $list_line[1],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: B dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B dials MMCONF 1514000000 - PASSED\n";
	}
	 # Detect ring back tone on B
    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ring back tone on line $list_dn[1]");
        print FH "STEP: B hears ringback tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears ringback tone - PASSED\n";
    }
	
    # A off-hooks, dials MMCONF number (1514000000) 
	# A off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A($list_dn[0]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A($list_dn[0]) - PASSED\n";
    }
	# A hears dial tone.
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
  
	# A dials MMCONF number
	
	%input = (
                -line_port => $list_line[0],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time,
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF 1514000000");
		print FH "STEP: A dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials MMCONF 1514000000 - PASSED\n";
	}
	
	# Check LEA D ring
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
	sleep(5);
	#Check speech path between A and B in CONF
	%input = (
				-list_port => [$list_line[0], $list_line[1]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A & B");
        print FH "STEP: Check speech path between A & B - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A & B - PASSED\n";
	}
	
	# LEA D answer
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
        print FH "STEP: offhook LEA $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook LEA $list_line[3] - PASS\n";
    }
	# LEA D can monitor the call between A and B
	%input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B");
        print FH "STEP: LEA can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B - PASS\n";
    }
	

# C dials MMCONF
	# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C($list_dn[2]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C($list_dn[2]) - PASSED\n";
    }
	# C hears dial tone
	%input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[2]");
        print FH "STEP: C hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASSED\n";
    }
    
	#C dials MMCONF number
	
	%input = (
                -line_port => $list_line[2],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF 1514000000");
		print FH "STEP: C dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: C dials MMCONF 1514000000 - PASSED\n";
	}
	sleep(5);
	#Check speech path between A,B and C in CONF
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A B C");
        print FH "STEP: Check speech path between A B C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A B C - PASSED\n";
	}
	# LEA D can monitor the call between A B C
	%input = (
                -list_port => [$list_line[0],$list_line[1], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A B C");
        print FH "STEP: LEA can monitor the call between A B C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A B C - PASS\n";
    }
	
################################## Cleanup TC029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC029 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
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
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}




sub ADQ1086_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_015");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_015";
    my $tcid = "ADQ1086_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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

# Add CXR to line A
	unless ($ses_core->callFeature(-featureName => "cxr ctall n std", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[0]");
		print FH "STEP: add CXR for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[0] - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# Make call
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
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C calls A ");
        print FH "STEP: C calls A and answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and answer - PASS\n";
    }
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
        print FH "STEP: A dials $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $list_dn[1] - PASS\n";
    }
	sleep (15);

   
	%input = (
                -line_port => $list_line[0],
                -ring_count => 1,
				-ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
	unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_line[0] ");
        print FH "STEP: A hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASS\n";
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
	
	# Onhook A
	  
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
	sleep (10);
	# C hear ringback tone
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
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
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
    # remove CXR from line A
    unless ($add_feature_lineA) {
        foreach ('CXR') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[0]");
                print FH "STEP: remove $_ for line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[0] - PASS\n";
            }
        }
	}

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_016");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_016";
    my $tcid = "ADQ1086_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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
	# Get DISA number and authencation code
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[0], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number - PASS\n";
    }
    my $authen_code = $ses_core->getAuthenCode($list_dn[0]);
    unless ($authen_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get authencation code");
		print FH "STEP: get authencation code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get authencation code - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call

%input = (
                -line_port => $list_line[0],
                -cas_timeout => 50000,
                );
	unless ($ses_glcas->startDetectConfirmationToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot start detect ConfirmationTone line $list_line[0] ");
        print FH "STEP: start detect ConfirmationTone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start detect ConfirmationTone - PASS\n";
    }
# A dials DISA number
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
	($dialed_num) = ($disa_num =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $disa_num successfully");
    }
    sleep(5);
	
	# A hears confirmation tone
	
	sleep(5);
	%input = (
                -line_port => $list_line[0],
                -wait_for_event_time => $wait_for_event_time
                );
	unless ($ses_glcas->stopDetectConfirmationToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ConfirmationTone line $list_line[0] ");
        print FH "STEP: A hears ConfirmationTone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ConfirmationTone - PASS\n";
    }

    # A dials authen code
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $authen_code,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $authen_code successfully");
		print FH "STEP: A dials authen code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials authen code - PASS\n";
    }
    sleep(2);
	# A hears recall dial tone
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect recall dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }
	
	# Onhook A

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
   
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}




sub ADQ1086_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_017");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_017";
    my $tcid = "ADQ1086_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
	my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);   
	my $get_pcm = 1; 
	my $get_logutil = 1;
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

# Add 3WC to line A
	unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: add 3WC for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[2] - PASS\n";
    }
    
    $add_feature_lineA = 0;
	
# Verify the tuple exists or not
 # Login to table TMTCNTL
	unless (grep /TABLE:\s+TMTCNTL/, $ses_core->execCmd("Table tmtcntl;pos offtreat;sub")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table TMTCNTL");
		print FH "STEP: Login to table TMTCNTL - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table TMTCNTL - PASSED\n";
	}
	
	unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos BUSY")) {
        if (grep /ERROR/, $ses_core->execCmd("add BUSY Y S T60 \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple BUSY Y S T60");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep BUSY Y S T60 \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple BUSY Y S T60");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
	
	unless (grep /T60/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos AUTO_GRP 0'");
        print FH "STEP: Datafill tuple BUSY Y S T60  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple BUSY Y S T60 - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

    # Make call
	# B calls C, C ring and answers
	%input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and they have speech path ");
        print FH "STEP: B calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path - PASS\n";
    }
	
	# A calls D, D rings and answers
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls D and they have speech path ");
        print FH "STEP: A calls D and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls D and they have speech path - PASS\n";
    }
	
	# A flashs and hears recall dial tone
	
	# A hears recall dials tone
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }
    
	# A dials DN(B)
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
		print FH "STEP: A dials line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials line B - PASS\n";
    }
	
	
	# Check A hears busy tone
	%input = (
                -line_port => $list_line[0],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
	
    unless ($ses_glcas->detectBusyToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect busy tone line $list_dn[0]");
        print FH "STEP: A hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears busy tone - PASS\n";
    }
	# A flash again then, verify A,D hears busy tone
	sleep(1);
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
	
	# Check A, D hears busy tone
	sleep (2);
	%input = (
                -line_port => $list_line[0],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
	
    unless ($ses_glcas->detectBusyToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect busy tone line $list_dn[0]");
        print FH "STEP: A hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears busy tone - PASS\n";
    }
	%input = (
                -line_port => $list_line[3],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
	
    unless ($ses_glcas->detectBusyToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect busy tone line $list_dn[3]");
        print FH "STEP: D hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hears busy tone - PASS\n";
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
    # remove CNF from line A
    # remove 3WC C
    unless ($add_feature_lineA) {
       
            unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
                print FH "STEP: Remove 3WC from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove 3WC from line $list_dn[0] - PASS\n";
            }        
    }

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_018");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_018";
    my $tcid = "ADQ1086_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);   
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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
	# Get DISA number and authencation code
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[1], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number - PASS\n";
    }
    my $authen_code = $ses_core->getAuthenCode($list_dn[1]);
    unless ($authen_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get authencation code");
		print FH "STEP: get authencation code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get authencation code - PASS\n";
    }

# Add CXR to line B
	unless ($ses_core->callFeature(-featureName => "cxr ctall n std", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[1] - PASS\n";
    }
    
    $add_feature_lineB = 0;

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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
# Call flow
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call

# A calls B, B rings and answers
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls B ");
        print FH "STEP: A calls B and answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and answer - PASS\n";
	}
    
	%input = (
                -line_port => $list_line[1],
                -cas_timeout => 50000,
                );
	unless ($ses_glcas->startDetectConfirmationToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot start detect ConfirmationTone line $list_line[1] ");
        print FH "STEP: start detect ConfirmationTone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start detect ConfirmationTone - PASS\n";
    }
	# B dials DISA number
   
	($dialed_num) = ($disa_num =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $disa_num successfully");
    }
    sleep(5);
	
	# B hears confirmation tone
	%input = (
                -line_port => $list_line[1],
                -wait_for_event_time => $wait_for_event_time
                );
	unless ($ses_glcas->stopDetectConfirmationToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ConfirmationTone line $list_line[1] ");
        print FH "STEP: B hears ConfirmationTone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears ConfirmationTone - PASS\n";
    }

    # B dials authen code
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $authen_code,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $authen_code successfully");
		print FH "STEP: B dials authen code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials authen code - PASS\n";
    }
    sleep(2);
	# B hears recall dial tone
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect recall dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }

   # B dials C, C rings and answers
   %input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
        print FH "STEP: B dials C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials C - PASS\n";
    }
	sleep (5);
    
    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
				-ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
				
	
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[1]");
        print FH "STEP: B hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears ringback tone - PASS\n";
    }

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
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
	%input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and C");
        print FH "STEP: Check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and C - PASS\n";
    }
	# # B flash again
	# %input = (
                # -line_port => $list_line[1],
                # -flash_duration  => 600,
                # -wait_for_event_time => $wait_for_event_time
                # );
	# unless($ses_glcas->flashWithDurationCAS(%input)) {
        # $logger->error(__PACKAGE__ . ": Cannot flash $list_line[1] successfully");
        # print FH "STEP: B flash - FAIL\n";
        # $result = 0;
    # } else {
        # print FH "STEP: B flash - PASS\n";
    # }
	# sleep (5);
	
	# Onhook B
	  
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
	sleep (5);
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
    # remove CXR from line B
    unless ($add_feature_lineB) {
        foreach ('CXR') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[1]");
                print FH "STEP: remove $_ for line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[1] - PASS\n";
            }
        }
	}	

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}


sub ADQ1086_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_019");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_019";
    my $tcid = "ADQ1086_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

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
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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
	
# Add SIMRING to line A,B and C
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ SIMRING $list_dn[0] $list_dn[1] $list_dn[2] \$ act y 123 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add SIMRING for line $list_dn[0] and $list_dn[1] and $list_dn[2]");
        $ses_core->execCmd("abort");
    }
    unless (grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] and $list_dn[2]- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] and $list_dn[2] - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # Make call D to A
    ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
		print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(5);
	
	# Check line A, B and C ringing

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

	
	# C to pick up the call
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
	
	# check speech path between C and D
    %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and D ");
        print FH "STEP: check speech path between C and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between C and D - PASS\n";
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
	
	# remove SIMRING from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[0]");
            print FH "STEP: Remove SIMRING from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}


sub ADQ1086_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_020");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_020";
    my $tcid = "ADQ1086_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

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
    my $add_feature_lineAC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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
	
# Add SIMRING to line A and B
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ SIMRING $list_dn[0] $list_dn[1] \$ act y 123 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add SIMRING for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineA = 0;
# Add CPU to line A and C (A and C must have the same custgroup)
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[2] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[2]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[2] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[2] - PASS\n";
    }
    $add_feature_lineAC = 0;

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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # Make call D to A
    ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
		print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(5);
	
	# Check line A, B ringing

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

	
	# C dials CPU access code to pick up the call for A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -line_port => $list_line[2],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
    }
    sleep(12);
	
	# check speech path between C and D
    %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and D ");
        print FH "STEP: check speech path between C and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between C and D - PASS\n";
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
    # remove CPU from line A and C
    unless ($add_feature_lineAC) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[2]");
            print FH "STEP: Remove CPU from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[2] - PASS\n";
        }
    }
	
	# remove SIMRING from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[0]");
            print FH "STEP: Remove SIMRING from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_021 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_021");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_021";
    my $tcid = "ADQ1086_021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

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
    my $add_feature_lineAC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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
	
# Add SIMRING to line A and B
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ SIMRING $list_dn[0] $list_dn[1] \$ act y 123 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add SIMRING for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineA = 0;
# Add CPU to line B and C (B and C must have the same custgroup)
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[1] $list_len[2] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[1] and $list_dn[2]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[1] and $list_dn[2] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add CPU for line $list_dn[1] and $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[1] and $list_dn[2] - PASS\n";
    }
    $add_feature_lineAC = 0;

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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # Make call D to A
    ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
		print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(5);
	
	# Check line A, B ringing

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

	
	# B dials CPU access code to pick up the call for A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -line_port => $list_line[2],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
    }
    sleep(12);
	
	# check speech path between C and D
    %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and D ");
        print FH "STEP: check speech path between C and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between C and D - PASS\n";
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
    # remove CPU from line B and C
    unless ($add_feature_lineAC) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[1]");
            print FH "STEP: Remove CPU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[1] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[2]");
            print FH "STEP: Remove CPU from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[2] - PASS\n";
        }
    }
	
	# remove SIMRING from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[0]");
            print FH "STEP: Remove SIMRING from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_022 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_022");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_022";
    my $tcid = "ADQ1086_022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
	my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
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

# Add SCA and CFD to line A
	unless ($ses_core->callFeature(-featureName => "SCA noama ACT $list_dn[2] 3 \$ N", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCA for line $list_dn[0]");
		print FH "STEP: add SCA for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCA for line $list_dn[0] - PASS\n";
    }
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[1]", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
		print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
    }
    
    $add_feature_lineA = 0;
	# Activate CFD to line C
    
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFD for line $list_dn[0]");
        print FH "STEP: activate CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[0] - PASS\n";
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
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

    # Make call
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		print FH "STEP: Offhoof line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhoof line B - PASS\n";
    }
    
      
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
    }
    sleep(12);
	
	
	# Check line A ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line A is not ringing ");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
				
	# Check line C ring after CFD time out 
    sleep(20); # Wait for CFD time out
    $index = 0;

    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line C is not ring after CFD time out ");
        print FH "STEP: Check line C ring after CFD time out - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring after CFD time out - PASS\n";
    }
			
				
	
	# check speech path between B and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
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
    # remove SCA and CFD from line A
    unless ($add_feature_lineA) {
        foreach ('SCA','CFD') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[0]");
                print FH "STEP: remove $_ for line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[0] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_023 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_023");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_023";
    my $tcid = "ADQ1086_023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add SCRJ to line A with B in list & line A has CFW to forward to C
    unless ($ses_core->callFeature(-featureName => "SCRJ NOAMA ACT $list_dn[1] 1 \$ CFU N ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCRJ and CFU for line $list_dn[0]");
		print FH "STEP: Add SCRJ and CFU for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SCRJ and CFU for line $list_dn[0] - PASSED\n";
    }
	#Active CFU forward to C
    unless ($ses_core->execCmd ("changecfx $list_len[0] CFU $list_dn[2] A")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot active CFU for line $list_dn[0]");
		print FH "STEP: Active CFU for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Active CFU for line $list_dn[0] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
####################### Call Flow #######################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call and expect B can't call to A because B is in SCRJ list although A has CFU to C
   %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => ['NO TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->debug(__PACKAGE__ . " $tcid: B can't call to A because B is in the SCRJ list ");
        print FH "STEP: B can't call to A - PASSED\n";
               
    } else {
        $logger->error(__PACKAGE__ . " $tcid: SCRJ feature on A doesn't work correctly");
		$result = 0;
		print FH "STEP: B can't call to A - FAILED\n";
    }

################################## Cleanup 023 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 023 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_024 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_024");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_024";
    my $tcid = "ADQ1086_024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	#$ses_core ->{conn}->prompt('/>/');
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add ACB to line A
    unless ($ses_core->callFeature(-featureName => "ACB NOAMA ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: Add ACB for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add ACB for line $list_dn[0] - PASSED\n";
    }
# Add DRCW to DN(B)
    unless ($ses_core->callFeature(-featureName => "DRCW NOAMA ACT $list_dn[0] 3 \$ ", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add DRCW for line $list_dn[1]");
		print FH "STEP: Add DRCW for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add DRCW for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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

###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call from C to B to make B is in busy
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call B ");
        print FH "STEP: C calls B - FAILED\n";
        $result = 0;      
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: C calls B successfully");
		print FH "STEP: C calls B- PASSED\n";
    }
	
# A calls B, A receives busy tone. Line A hangs up
	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A doesn't receive busy tone from B ");
        print FH "STEP: A hears Busy tone from B - FAILED\n";
        $result = 0;      
    } else {
   		print FH "STEP: A hears Busy tone from B - PASSED\n";
    }
# A hangs up
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
# A offhook and dial ACB activation code and hangs up
    #Get ACB access code
	my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[0]");
		print FH "STEP: get ACB access code for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code ACB is: $acb_acc \n";
        print FH "STEP: get ACB access code for line $list_dn[0] - PASSED\n";
    }
	#A active ACB
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    $dialed_num = "\*$acb_acc\#";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial $dialed_num successfully");
		print FH "STEP: $list_dn[0] active ACB - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: $list_dn[0] active ACB - PASSED\n";
	}
	# A on-hooks
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
		print FH "STEP: $list_dn[0] on-hook after activating ACB - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: $list_dn[0] on-hook after activating ACB - PASSED\n";
	}
    sleep(5);
	#B on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
		print FH "STEP: $list_dn[1] on-hook to drop call with C - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: $list_dn[1] on-hook to drop call with C - PASSED\n";
	}
    sleep(5);
	# C on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
		print FH "STEP: $list_dn[2] on-hook to drop call with B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: $list_dn[2] on-hook to drop call with B - PASSED\n";
	}
	# Check A rings after B is IDLE
	my $index;
	for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: Line A is not ring after B is IDL ");
        print FH "STEP: Check line A rings after B IDL - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A rings after B IDL - PASSED\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
		print FH "STEP: A off-hooks to wait B answer - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A off-hooks to wait B answer - PASSED\n";
	}
	#Check line B rings after A off-hook
	$index = 0; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: Line B is not ring after A off-hook ");
        print FH "STEP: Check line B rings after A off-hook - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B rings after A off-hook - PASSED\n";
    }
	# B off-hooks and have speech path with A
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASSED\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASSED\n";
    }
	# A and B on-hook to finish TC
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
################################## Cleanup TC024 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC024 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_025 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_025");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_025";
    my $tcid = "ADQ1086_025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	#$ses_core ->{conn}->prompt('/>/');
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add ACB to line A
    unless ($ses_core->callFeature(-featureName => "ACB NOAMA ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: Add ACB for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add ACB for line $list_dn[0] - PASSED\n";
    }	
	$add_feature_lineB = 0;
# Add CFD to DN(B)
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2] ", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: Add CFD for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CFD for line $list_dn[1] - PASSED\n";
    }
    $add_feature_lineB = 0;

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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

###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# Make call from C to B to make B is in busy
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call B ");
        print FH "STEP: C calls B - FAILED\n";
        $result = 0;
        goto CLEANUP;     
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: C calls B successfully");
		print FH "STEP: C calls B- PASSED\n";
    }
	
# A calls B, A receives busy tone. Line A hangs up
	%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A doesn't receive busy tone from B ");
        print FH "STEP: A hears Busy tone from B - FAILED\n";
        $result = 0;
        goto CLEANUP;      
    } else {
   		print FH "STEP: A hears Busy tone from B - PASSED\n";
    }
# A hangs up
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
# A offhook and dial ACB activation code and hangs up
    #Get ACB access code
	my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[0]");
		print FH "STEP: Get ACB access code for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code ACB is: $acb_acc \n";
        print FH "STEP: Get ACB access code for line $list_dn[0] - PASSED\n";
    }
	#A active ACB
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    $dialed_num = "\*$acb_acc\#";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial $dialed_num successfully");
		print FH "STEP: A ($list_dn[0]) active ACB - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) active ACB - PASSED\n";
	}
	# A on-hooks
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
		print FH "STEP: A ($list_dn[0]) on-hooks after activating ACB - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) on-hooks after activating ACB - PASSED\n";
	}
    sleep(5);
	#B on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
		print FH "STEP: B ($list_dn[1]) on-hooks to drop call with C - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B ($list_dn[1]) on-hooks to drop call with C - PASSED\n";
	}
    sleep(5);
	# C on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
		print FH "STEP: C ($list_dn[2]) on-hooks to drop call with B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: C ($list_dn[2]) on-hooks to drop call with B - PASSED\n";
	}
	# Check A rings after B is IDLE
	my $index;
	for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: Line A is not ring after B is IDL ");
        print FH "STEP: Check line A rings after B IDL - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A rings after B IDL - PASSED\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
		print FH "STEP: A off-hooks to wait B answer - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A off-hooks to wait B answer - PASSED\n";
	}
	#Check line B rings after A off-hook
	$index = 0; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: Line B is not ring after A off-hook ");
        print FH "STEP: Check line B rings after A off-hook - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B rings after A off-hook - PASSED\n";
    }
	sleep(3); #Wait time out of B to forward to C
	#Check line C rings
	$index = 0; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: B can't forward to C");
        print FH "STEP: Check line C rings after B forwards - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C rings after B forwards - PASSED\n";
    }
	# C off-hooks and have speech path with A
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASSED\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASSED\n";
    }
	# A and C on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
################################## Cleanup TC025 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC025 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
	
	# remove ABC feature for line A
  
     unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'ACB', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ACB from line A $list_dn[0]");
            print FH "STEP: Remove ACB from line A $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove ACB from line A $list_dn[0] - PASS\n";
        }
    }
	
	# remove CFD feature for line B
  
     unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line B $list_dn[1]");
            print FH "STEP: Remove CFD from line B $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line B $list_dn[1] - PASS\n";
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_026 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_026");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_026";
    my $tcid = "ADQ1086_026";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add CNF to line A
    unless ($ses_core->callFeature(-featureName => "CNF C06 ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: Add CNF for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CNF for line $list_dn[0] - PASSED\n";
    }

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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call from A to B and verify speech path
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
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call B ");
        print FH "STEP: A calls B - FAILED\n";
        $result = 0;
        goto CLEANUP;     
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: A calls B successfully");
		print FH "STEP: A calls B- PASSED\n";
    }
	
# A flashs and dial CNF activation code to bring B into CNF
    #Get CNF access code
	my $cnf_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CONF');
    unless ($cnf_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CNF access code for line $list_dn[0]");
		print FH "STEP: Get CNF access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code CNF is: $cnf_acc \n";
        print FH "STEP: Get CNF access code - PASSED\n";
    }
	# # A flashs
	# %input = (
                # -line_port => $list_line[0], 
                # -flash_duration => 600, 
                # -wait_for_event_time => $wait_for_event_time
             # ); 
    # unless($ses_glcas->flashWithDurationCAS(%input)) {
        # $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		# print FH "STEP: A flashes to dial CONF access code - FAILED\n";
    # } else {
		# print FH "STEP: A flashes to dial CONF access code - PASSED\n";
		# }
	#A dials CONF access code to invite B join CONF
    $dialed_num = "\*$cnf_acc\#";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code - PASSED\n";
	}
	sleep (2);
# A flashs again and verify speech path with B
	# # A flashs again
	# %input = (
                # -line_port => $list_line[0], 
                # -flash_duration => 600, 
                # -wait_for_event_time => $wait_for_event_time
             # ); 
    # unless($ses_glcas->flashWithDurationCAS(%input)) {
        # $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		# print FH "STEP: A flashes again - FAILED\n";
    # } else {
		# print FH "STEP: A flashes again - PASSED\n";
		# }
	#Verify speech path between A and B again
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and B");
        print FH "STEP: Verify speech path between A and B again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and B again - PASSED\n";
    }
# A flashs again and make call to C
	#A flashs again
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to make call to C - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to make call to C - PASSED\n";
		}
	
	# Make call from A to C and verify speech path, then flash again.
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
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call C ");
        print FH "STEP: A calls C - FAILED\n";
        $result = 0;   
		goto CLEANUP;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: A calls C successfully");
		print FH "STEP: A calls C - PASSED\n";
    }
	# #A flashs again to invite C join CONF
	# %input = (
                # -line_port => $list_line[0], 
                # -flash_duration => 600, 
                # -wait_for_event_time => $wait_for_event_time
             # ); 
    # unless($ses_glcas->flashWithDurationCAS(%input)) {
        # $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		# print FH "STEP: A flashes again to invite C - FAILED\n";
    # } else {
		# print FH "STEP: A flashes again to invite C - PASSED\n";
		# }
	# A continues to dial CONF access code to invite C join CONF
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dial CONF access code to invite C join CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite C join CONF - PASSED\n";
		}
	#Check speech path between A, B & C
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
	 # D off-hooks to make it BUSY
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line D - $list_line[3]");
        print FH "STEP: Offhook line D to make it busy- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D to make it busy - PASSED\n";
    }
	#A flashs again to make call D
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to make call to D - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to make call to D - PASSED\n";
		}
	# A calls D and hears BUSY tone, then flash again to turn back CONF with B and C
		%input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[0],
                -regionB => $list_region[3],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => [''],
                -send_receive => [''],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A doesn't receive busy tone from D ");
        print FH "STEP: A hears Busy tone from D and flash again - FAILED\n";
        $result = 0;
        goto CLEANUP;      
    } else {
   		print FH "STEP: A hears Busy tone from D and flash again - PASSED\n";
    }
	#A dials CONF access code to turn back CONF
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code to turn back CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to turn back CONF - PASSED\n";
		}
	#Check speech path between A, B & C again
	%input = (
				-list_port => [$list_line[0], $list_line[1], $list_line[2]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, B & C again");
        print FH "STEP: Check speech path between A, B & C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, B & C again - PASSED\n";
	}
	# A,B and C on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A - $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B - $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C - $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
################################## Cleanup TC026 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC026 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_027 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_027");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_027";
    my $tcid = "ADQ1086_027";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
    my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	#$ses_core ->{conn}->prompt('/>/');
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add CNF to line A
    unless ($ses_core->callFeature(-featureName => "CNF C06 ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: Add CNF for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CNF for line $list_dn[0] - PASSED\n";
    }
# Create DNH group include B and C with B's pilot
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[1], -addMem => 'Yes', -listMemDN => [$list_dn[2]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[1]");
		print FH "STEP: Create group DNH group with B - $list_dn[1] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH group with B - $list_dn[1] is pilot - PASSED\n";
    }
	
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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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

###################### Call flow ###########################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Make call from A to D and verify speech path
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
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call D ");
        print FH "STEP: A calls D - FAILED\n";
        $result = 0;
        goto CLEANUP;      
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: A calls D successfully");
		print FH "STEP: A calls D - PASSED\n";
    }
	
# A flashs and dial CNF activation code to bring D into CNF
    #Get CNF access code
	my $cnf_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CONF');
    unless ($cnf_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CNF access code for line $list_dn[0]");
		print FH "STEP: Get CNF access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code CNF is: $cnf_acc \n";
        print FH "STEP: Get CNF access code - PASSED\n";
    }
	
	#A dials CONF access code to invite D join CONF
    $dialed_num = "\*$cnf_acc\#";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite D join CONF - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite D join CONF - PASSED\n";
	}
	sleep (2);
	#Verify speech path between A and D again
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and D");
        print FH "STEP: Verify speech path between A and D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and D - PASSED\n";
    }
# Make Pilot B busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line B - $list_line[1]");
        print FH "STEP: Offhook line B to make it busy- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B to make it busy - PASSED\n";
    }
# A flashs again to make call B
	#A flashs again
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to make call to B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to make call to B - PASSED\n";
		}
	
# Make call from A to B and C will ring and verify speech path between A and C, then flash again.
    # Check A hears dial tone
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
    # Check A is CPB
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
	#A dials DN(B)
	%input = (
                -line_port => $list_line[0],
               	-dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial DN(B) - $list_dn[1]");
		print FH "STEP: A dials B ($list_dn[1]) while B is Busy - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials B ($list_dn[1]) while B is Busy - PASSED\n";
	}
    sleep(2);
    
	#Detect ring back tone on A
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ring back tone on line $list_dn[0]");
        print FH "STEP: A hears ringback tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASSED\n";
    }
	# Detect ringing tone on C which is a member of DNH
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
        print FH "STEP: Check line C - $list_dn[2] ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C - $list_dn[2] ringing - PASSED\n";
    }
	# C off-hooks to answer A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASSED\n";
    }
	#Verify speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and C");
        print FH "STEP: Verify speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and C - PASSED\n";
    }

	#A flashs again to invite C join CONF
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to invite C - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to invite C - PASSED\n";
		}
	# A continues to dial CONF access code to invite C join CONF
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite C join CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite C join CONF - PASSED\n";
		}
	#Check speech path between A, D & C
	%input = (
				-list_port => [$list_line[0], $list_line[2], $list_line[3]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, D & C");
        print FH "STEP: Check speech path between A, D & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, D & C - PASSED\n";
	}
		
	# A,B,C and D on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A - $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B - $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C - $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line D - $list_line[3]");
        print FH "STEP: Onhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line D - PASSED\n";
    }
################################## Cleanup TC027 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC027 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_028 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_028");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_028";
    my $tcid = "ADQ1086_028";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	#$ses_core ->{conn}->prompt('/>/');
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
       $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add CNF to line A
    unless ($ses_core->callFeature(-featureName => "CNF C06 ", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: Add CNF for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CNF for line $list_dn[0] - PASSED\n";
    }
# Add CFD to line B
	unless ($ses_core->callFeature(-featureName => "CFD P ", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: Add CFD for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CFD for line $list_dn[1] - PASSED\n";
    }
# Active CFD on B by changecfx
	unless ($ses_core->execCmd ("changecfx $list_len[1] CFD $list_dn[3] A")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot active CFD for line $list_dn[1]");
		print FH "STEP: Active CFD for line $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Active CFD for line $list_dn[1] - PASSED\n";
    }
    $feature_added = 0;
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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
############################# Call-flow #################################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
# Make call from A to C and verify speech path
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
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A can't call C ");
        print FH "STEP: A calls C - FAILED\n";
        $result = 0;
        goto CLEANUP;      
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: A calls C successfully");
		print FH "STEP: A calls C- PASSED\n";
    }
	
# A dials CNF activation code to bring C into CNF
    #Get CNF access code
	my $cnf_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CONF');
    unless ($cnf_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CNF access code for line $list_dn[0]");
		print FH "STEP: Get CNF access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code CNF is: $cnf_acc \n";
        print FH "STEP: Get CNF access code - PASSED\n";
    }
	
	#A dials CONF access code to invite C join CONF
    $dialed_num = "\*$cnf_acc\#";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite C join CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite C join CONF - PASSED\n";
	}
	sleep (2);

	#Verify speech path between A and C again
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and C");
        print FH "STEP: Verify speech path between A and C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and C again- PASSED\n";
    }
# A flashs again and make call to B
	#A flashs again
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to make call to B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to make call to B - PASSED\n";
		}
	
# Make call from A to B, B doesn't answer and forward to D and verify speech path between A and D, then flash again.
    # Check A hears dial tone
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
    # Check A is CPB
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
	#A dials DN(B)
	%input = (
                -line_port => $list_line[0],
               	-dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial DN(B) - $list_dn[1]");
		print FH "STEP: A dials B ($list_dn[1]) while B doesn't answer - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials B ($list_dn[1]) while B doesn't answer - PASSED\n";
	}
    # Detect ring back tone on A
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ring back tone on line $list_dn[0]");
        print FH "STEP: A hears ringback tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASSED\n";
    }
	# Detect ringing tone on B
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
        print FH "STEP: Check line B - $list_dn[1] ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B - $list_dn[1] ringing - PASSED\n";
    }
	sleep (12); #wait forward to D while B doesn't answer
	# Detect ringing tone on D
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
        print FH "STEP: Check line D - $list_dn[3] ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D - $list_dn[3] ringing - PASSED\n";
    }
	# D off-hooks to answer A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D($list_dn[3]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D($list_dn[3]) - PASSED\n";
    }
	#Verify speech path between A and D
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and D");
        print FH "STEP: Verify speech path between A and D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and D - PASSED\n";
    }
	#A flashs again to invite D join CONF
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to invite D to join CONF - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A flashes again to invite D join CONF - PASSED\n";
		}
	# A continues to dial CONF access code to invite D join CONF
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial CNF access code ($dialed_num) successfully");
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite D($list_dn[3]) join CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials CONF access code to invite D($list_dn[3]) join CONF - PASSED\n";
		}
	#Check speech path between A, D & C
	%input = (
				-list_port => [$list_line[0], $list_line[2], $list_line[3]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A, D & C");
        print FH "STEP: Check speech path between A, D & C - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A, D & C - PASSED\n";
	}
	# A,D and C on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A($list_line[0])");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line D($list_line[3])");
        print FH "STEP: Onhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line D - PASSED\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C($list_line[2])");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
################################## Cleanup TC028 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC028 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_029 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_029");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_029";
    my $tcid = "ADQ1086_029";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
	
    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Verify or datafill tuple of MMC in table MMCONF for AUTO_GRP
	#########################################################
	# Login to table MMCONF
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table MMCONF");
		print FH "STEP: Login to table MMCONF - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table MMCONF - PASSED\n";
	}
	unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 151 400 0000 0 Y Y N 150 CODEADDON \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 151 400 0000 0 Y Y N 150 CODEADDON \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CODEADDON/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos AUTO_GRP 0'");
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - PASS\n";
    }
	###########################################################
	
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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
############################# Call-flow #################################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks, dials MMCONF number (1514000000) and hears ring back tone
	# A off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A($list_dn[0]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A($list_dn[0]) - PASSED\n";
    }
	# A hears dial tone.
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
    
	#A dials MMCONF number
	
	%input = (
                -line_port => $list_line[0],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: A dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials MMCONF 1514000000 - PASSED\n";
	}
    # Detect ring back tone on A
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ring back tone on line $list_dn[0]");
        print FH "STEP: A hears ringback tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASSED\n";
    }
# B off-hooks, dials MMCONF number (1514000000) and verify speech path with A
	# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B($list_line[1]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B($list_line[1]) - PASSED\n";
    }
	# B hears dial tone.
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASSED\n";
    }
  
	#B dials MMCONF number
	
	%input = (
                -line_port => $list_line[1],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: B dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B dials MMCONF 1514000000 - PASSED\n";
	}
	sleep (10);
	#Check speech path between A and B in CONF
	%input = (
				-list_port => [$list_line[0], $list_line[1]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A & B");
        print FH "STEP: Check speech path between A & B - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A & B - PASSED\n";
	}
# A locks  the conference, verify speech path A & B again, C join conference but hear busy tone.
	# Get MMLK access code from IBNXLA table
	my $mmlk_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'MMLK');
    unless ($mmlk_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get MMLK access code for line $list_dn[0]");
		print FH "STEP: Get MMLK access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code MMLK is: $mmlk_acc \n";
        print FH "STEP: Get MMLK access code - PASSED\n";
    }
	# A flashs MMLK number to lock conference
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to dial MMLK - FAILED\n";
    } else {
		print FH "STEP: A flashes again to dial MMLK - PASSED\n";
		}
	# A dials MMLK
	$dialed_num = "\*$mmlk_acc\#";
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial MMLK access code ($dialed_num)");
		print FH "STEP: A ($list_dn[0]) dials MMLK access code to lock CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials MMLK access code to lock CONF - PASSED\n";
		}
	#Check speech path between A and B again
	%input = (
				-list_port => [$list_line[0], $list_line[1]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A & B");
        print FH "STEP: Check speech path between A & B again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A & B again - PASSED\n";
	}
# C dials MMCONF and hear busy tone
	# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C($list_dn[2]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C($list_dn[2]) - PASSED\n";
    }
	# C hears dial tone.
	%input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[2]");
        print FH "STEP: C hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASSED\n";
    }
   
	#C dials MMCONF number
	
	%input = (
                -line_port => $list_line[2],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: C dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: C dials MMCONF 1514000000 - PASSED\n";
	}
	# C hear busy tone
	%input = (
                -line_port => $list_line[2], 
                -busy_tone_duration => 2000, 
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless ($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot detect busy tone on line C");
        print FH "STEP: Verify C hears BSY tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify C hears BSY tone - PASSED\n";
    }
	# A,B and C on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A($list_line[0])");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B($list_line[1])");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C($list_dn[2])");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
################################## Cleanup TC029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC029 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
}

sub ADQ1086_030 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1086_030");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1086_030";
    my $tcid = "ADQ1086_030";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!; #open execution_logs file or creat new file and write logs in this
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1086");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $pcm_start = 0;
    my $flag = 1;
	my (@list_file_name, $dialed_num,  %info);	
	my $get_pcm = 1; 
	my $get_logutil = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m Lab - PASSED\n";
    }
	
    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA2m core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m core - PASSED\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for Logutil- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for Logutil- PASSED\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => $TESTBED{'glcas:1:ce0'}");
		print FH "STEP: Login GLCAS_Server53 - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login GLCAS_Server53 - PASSED\n";
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
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep(1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status- PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Verify or datafill tuple of MMC in table MMCONF for AUTO_GRP
		
	#########################################################
	# Login to table MMCONF
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot find the table MMCONF");
		print FH "STEP: Login to table MMCONF - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: Login to table MMCONF - PASSED\n";
	}
	unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 151 400 0000 0 Y Y N 150 CODEADDON \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 151 400 0000 0 Y Y N 150 CODEADDON \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CODEADDON/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos AUTO_GRP 0'");
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AUTO_GRP 0 in table MMCONF - PASS\n";
    }
	###########################################################
	
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
    $initialize_done = 0;
    
 # Start logutil
    if ($get_logutil){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
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
############################# Call-flow #################################
#Start PCM trace
    if ($get_pcm){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks, dials MMCONF number (1514000000) and hears ring back tone
	# A off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A($list_dn[0]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A($list_dn[0]) - PASSED\n";
    }
	# A hears dial tone.
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
    
	#A dials MMCONF number
	
	%input = (
                -line_port => $list_line[0],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: A dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials MMCONF 1514000000 - PASSED\n";
	}
    # Detect ring back tone on A
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ring back tone on line $list_dn[0]");
        print FH "STEP: A hears ringback tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears ringback tone - PASSED\n";
    }
# B off-hooks, dials MMCONF number (1514000000) and verify speech path with A
	# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B($list_dn[1]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B($list_dn[1]) - PASSED\n";
    }
	# B hears dial tone.
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASSED\n";
    }
  
	#B dials MMCONF number
	
	%input = (
                -line_port => $list_line[1],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: B dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B dials MMCONF 1514000000 - PASSED\n";
	}
	sleep (10);
	#Check speech path between A and B in CONF
	%input = (
				-list_port => [$list_line[0], $list_line[1]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A & B");
        print FH "STEP: Check speech path between A & B - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A & B - PASSED\n";
	}
# A locks  the conference, verify speech path A & B again, C join conference but hear busy tone.
	# Get MMLK access code from IBNXLA table
	my $mmlk_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'MMLK');
    unless ($mmlk_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get MMLK access code for line $list_dn[0]");
		print FH "STEP: Get MMLK access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code MMLK is: $mmlk_acc \n";
        print FH "STEP: Get MMLK access code - PASSED\n";
    }
	# Get MMUL access code
	my $mmul_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'MMUL');
    unless ($mmul_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get MMUL access code for line $list_dn[0]");
		print FH "STEP: Get MMUL access code - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code MMUL is: $mmul_acc \n";
        print FH "STEP: Get MMUL access code - PASSED\n";
    }
	# A flashs MMLK number to lock conference
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to dial MMLK - FAILED\n";
    } else {
		print FH "STEP: A flashes again to dial MMLK - PASSED\n";
		}
	# A dials MMLK
	$dialed_num = "\*$mmlk_acc\#";
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial MMLK access code ($dialed_num)");
		print FH "STEP: A ($list_dn[0]) dials MMLK access code to lock CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials MMLK access code to lock CONF - PASSED\n";
		}
	#Check speech path between A and B again
	%input = (
				-list_port => [$list_line[0], $list_line[1]], 
				-checking_type => ['TESTTONE'], 
				-tone_duration => 2000, 
				-cas_timeout => 50000
			);
	unless ($ses_glcas->checkSpeechPathCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect speech path between A & B");
        print FH "STEP: Check speech path between A & B again - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
        print FH "STEP: Check speech path between A & B again - PASSED\n";
	}
# C dials MMCONF and hear busy tone
	
	# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C($list_dn[2]) - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C($list_dn[2]) - PASSED\n";
    }
	# C hears dial tone.
	%input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[2]");
        print FH "STEP: C hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASSED\n";
    }
    
	#C dials MMCONF number
	
	%input = (
                -line_port => $list_line[2],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: C dials MMCONF 1514000000 - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: C dials MMCONF 1514000000 - PASSED\n";
	}
	# C hear busy tone
	%input = (
                -line_port => $list_line[2], 
                -busy_tone_duration => 2000, 
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless ($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot detect busy tone on line C");
        print FH "STEP: Verify C hears BSY tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify C hears BSY tone - PASSED\n";
    }
	# C on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C($list_dn[2])");
        print FH "STEP: Onhook line C($list_dn[2]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C($list_dn[2]) - PASSED\n";
    }
# A flashs and unlock the conference
	# A flashs
	
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[0]");
		print FH "STEP: A flashes again to dial MMUL - FAILED\n";
    } else {
		print FH "STEP: A flashes again to dial MMUL - PASSED\n";
		}
	# A dials MMUL
	$dialed_num = "\*$mmul_acc\#";
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": A cannot dial MMUL access code ($dialed_num)");
		print FH "STEP: A ($list_dn[0]) dials MMUL access code to unlock CONF- FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A ($list_dn[0]) dials MMUL access code to unlock CONF - PASSED\n";
		}
# Verify C can join Conference
	# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C($list_dn[2]) again - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C($list_dn[2]) again - PASSED\n";
    }
	# C hears dial tone.
	%input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[2]");
        print FH "STEP: C hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASSED\n";
    }
    
	#C dials MMCONF number
	%input = (
                -line_port => $list_line[2],
               	-dialed_number => '1514000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial MMCONF - 1514000000");
		print FH "STEP: C dials MMCONF 1514000000 again - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: C dials MMCONF 1514000000 again - PASSED\n";
	}
	# Verify speech path between A,B and C in CONF
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
	# A,B and C on-hook to finish TC
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A($list_line[0])");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B($list_line[1])");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line C($list_line[2])");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
################################## Cleanup TC029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup TC029 ##################################");

    # Cleanup call
    unless ($initialize_done) {
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
    sleep(5);
    unless ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open trap")) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check trap - PASSED\n";
        }
        unless (grep /Log empty/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
        if (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }
  
    close(FH);
    &ADQ1086_cleanup();
    &ADQ1086_checkResult($tcid, $result);    
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