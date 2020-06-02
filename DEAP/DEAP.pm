#**************************************************************************************************#
#FEATURE                : <DEAP> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <LUAN NGUYEN THANH>
#cd /home/ylethingoc/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation_ATS/DEAP/
#/usr/bin/runtest.sh `pwd` 
#perl -cw DEAP.pm
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::Luan::Automation_ATS::DEAP::DEAP; 

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
our ($ses_core, $ses_glcas, $ses_logutil,$ses_calltrak, $ses_tapi, $ses_ats, $ses_cli1, $ses_cli, $gwc_id);
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
# For GLCAS
our @cas_server = ('10.250.185.92', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';
our $wait_for_event_time = 30;

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};
our ($root_pass) = $alias_hashref->{LOGIN}->{1}->{ROOTPASSWD};

my $as = SonusQA::Utils::resolve_alias($TESTBED{ "as:1:ce0"});
my $ip = $as->{MGMTNIF}->{1}->{IP};
$gwc_id = 13; #GWC gr303


 
# Line Info
our %db_line = (
                'gr303_1' => {
                            -line => 48,
                            -dn => 2124414010,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 01',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'gr303_2' => {
                            -line => 47,
                            -dn => 2124414011,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 02',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'pbx' => {#pbx
                            -line => 46,
                            -dn => 2124414012,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 03',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'Sip_pbx' => { #Sip_pbx
                            -line => 45,
                            -dn => 2124414013,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 04',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'sip_1' => {#sip_1
                            -line => 45,
                            -dn => 2124414013,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 04',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'sip_2' => {#sip_2
                            -line => 40,
                            -dn => 2124409578,
                            -region => 'US',
                            -len => 'SL10   00 0 00 78',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0 ',
                            },

                );

our %tc_line = (
                'tms1243150' => ['gr303_1','gr303_2'],
                'tms1243135' => ['sip_1','gr303_1'],
                'tms1243136' => ['sip_1','gr303_1'],
                'tms1309895' => ['sip_1','gr303_1'],
                'tms1309896' => ['sip_1','gr303_1'],
                'tms1309897' => ['sip_1','gr303_1'],
);

#################### Trunk info ###########################
our %db_trunk = (
                't15_g9_isup' =>{
                                -acc => 203,
                                -region => 'US',
                                -clli => 'AUTOG9C7IT2W',
                            },
                't15_g6_pri' =>{
                                -acc => 554,
                                -region => 'US',
                                -clli => 'T15G6OC3N4PRI2W',
                            },
                't15_sipt' =>{
                                -acc => 610,
                                -region => 'US',
                                -clli => 'T15SSTIBNT2LP',
                            },
                't15_sst' =>{
                                -acc => 775,
                                -region => 'US',
                                -clli => 'SSTSHAKEN',
                            },
                't15_sst_sipp' =>{
                                -acc => 771,
                                -region => 'US',
                                -clli => 'SSTSHAKEN2',
                            },            
                't15_pri' =>{
                                -acc => 504,  #200 #504
                                -region => 'US',
                                -clli => 'G6VZSTSPRINT2W' , # T15G9PRINT2W #G6VZSTSPRINT2W
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

sub Luan_cleanup {
    my $subname = "Luan_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil,$ses_calltrak,
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub Luan_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "Luan_checkResult";
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
                    "tms1243150",	#ABH-1783 - Verify qdnwrk command for MGCP lines have Teen Service SDN
                    # "tms1243135",	#AKF-40036 - Verify the test call from TD trunk to the line with RSUS OPRT option
                    # "tms1243136",	#AKF-40309 - Provision TTU Circuit as IBERT Tester in table FMRESINV
                    # "tms1309895",	#AKF-40665- Verify the Core Rex Test and GWC Rex Test can not run at the same time
                    # "tms1309896",	#AKF-40375 Verify AMA Billing Module Code 130 Facility Release field has correct values
                    # "tms1309897",	#AKF-40363 - Verify calling party number is displayed on phone via PRI trunk
                   
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
# |                                 Luan                                      |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Luan Nguyen ##########################
sub tms1243150 { #ABH-1783 - Verify qdnwrk command for MGCP lines have Teen Service SDN
    $logger->debug(__PACKAGE__ . " Inside test case tms1243150");

########################### Variables Declaration #############################
    $tcid = "tms1243150";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/DEAP");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@TRKOPTS ,@temp );

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my ($dialed_num, @callTrakLogs, $ses_core1);
    my $sdn_num = 2124418765;
    my $passed = 0;
    my $add_feature_lineA = 0;
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# Add SDN to line A
    unless ($ses_core->callFeature(-featureName => "SDN $sdn_num 2 E \$", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line $list_dn[0]");
		print FH "STEP: add SDN for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SDN for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;

###################### Call flow ###########################
#telnet cmtg 10023
	$ses_core1->{conn}->print("telnet cmtg 10023\n");
    sleep(5);
    $ses_core1->execCmd("cmtg tma15\@11\n");
	unless ($ses_core1->{conn}->waitfor(-match => '/logged in/')){
		$logger->error(__PACKAGE__ . ": The input password is incorect, fail to login ossgate ");
		print FH "STEP: Login into ossgate  fail - FAIL\n";
		return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully login into to ossgate");
		print FH "STEP: Login into ossgate  pass - PASS\n";
	}
#prompt
    $ses_core1->{conn}->prompt('/TOTAL COUNT OF WORKING DN/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
#qdnwrk 
    my @output =  $ses_core1->execCmd("QDNWRK ALL IBN \$ D",1000);
    foreach (@output) {
        if (/Teen Service Secondary DN/) {
            print FH "STEP: Teen Service Secondary DN - PASS\n";
            $passed = 1;
            last;
        }
    }
    if($passed==0){
        print FH "STEP: Teen Service Secondary DN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }

################################## Cleanup tms1243150 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1243150 ##################################");

    # Remove service from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => "SDN $sdn_num", -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SDN from line $list_dn[0]");
            print FH "STEP: Remove SDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SDN from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
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
