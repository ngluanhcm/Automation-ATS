#**************************************************************************************************#
#FEATURE                : <ADQ729> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Tai Nguyen Huu>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ729::ADQ729; 

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
our (%input, $ses_core, $ses_glcas, $ses_logutil,@output);
our %core_account = ( 
                    -username => ['testshell1','testshell2','testshell3','testshell4','testshell5','testshell6','testshell7','testshell8'], 
                    -password => ['automation','automation','automation','automation','automation','automation','automation','automation']
                    );
our @cas_server = ('10.250.185.232', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';

our @db_list_dn = (4005007106, 4005007123, 4005007124, 4005007229);
our @db_list_line = (20, 3, 4, 18);
our @db_list_region = ('US','US','US','US');
our @db_list_len = (' V52    01 0 00 06','V52   01 0 00 23','V52   01 0 00 24','V52   02 0 00 29');
our @db_list_line_info = ('IBN AUTO_GRP 0 0','IBN AUTO_GRP 0 0','IBN AUTO_GRP 0 0','IBN AUTO_GRP 0 0');

our %db_trunk = (
                'g6_isup' =>{
                                -acc => 105,
                                -region => 'US',
                                -clli => 'T20G6E1C7ETSI2W',
                            },
                'g6_pri' => {
                                -acc => 104,
                                -region => 'US',
                                -clli => 'T20G6E1PRITEXT2W',
                            },
                'cas_r2' => {
                                -acc => 209,
                                -region => 'US',
                                -clli => 'AUTOG9R2MEXICO2W',
                            },
                'tw_isup' =>{
                                -acc => 501,
                                -region => 'US',
                                -clli => 'AUTOG9C7TAIWAN2W',
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


sub ADQ729_cleanup {
    my $subname = "ADQ729_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    if (defined $ses_glcas) {
        $ses_glcas->DESTROY();
        undef $ses_glcas;
    }
    if (defined $ses_core) {
        $ses_core->DESTROY();
        undef $ses_core;
    }
    if (defined $ses_logutil) {
        $ses_logutil->DESTROY();
        undef $ses_logutil;
    }
    return 1;
}

sub ADQ729_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ729_checkResult";
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

sub ADQ729_datafill {
    my $tcid = "ADQ729_datafill";
    $logger->debug(__PACKAGE__ . " Datafill necessary info before running TCs");
    my $tuple;

################################## LOGIN ######################################

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        return 0;
    }
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        return 0;
    }

# Datafill table PXCODE, PXRTE for all Trunk in DB
    foreach my $trk (keys %db_trunk) {
        foreach my $cust_grp ('FETCEPT','AUTO_GRP') {
            if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table PXCODE")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'table PXCODE'");
            }
            unless ($ses_core->execCmd("rwok on")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
            }
            $tuple = "FETCEPT $db_trunk{$trk}{-acc} $db_trunk{$trk}{-acc} RTE DEST $db_trunk{$trk}{-acc} \$";
            if (grep /NOT FOUND/, $ses_core->execCmd("pos FETCEPT $db_trunk{$trk}{-acc} $db_trunk{$trk}{-acc}")) {
                if (grep /ERROR/, $ses_core->execCmd("add $tuple")) {
                    $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple in PXCODE");
                } else {
                    if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                        $ses_core->execCmd("Y");
                    }
                }
            }
            unless ($ses_core->execCmd("abort;quit")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
            }

            if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table PXRTE")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'table PXRTE'");
            }
            unless ($ses_core->execCmd("rwok on")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
            }
            $tuple = "FETCEPT $db_trunk{$trk}{-acc} T OFRT $db_trunk{$trk}{-acc} \$";
            if (grep /NOT FOUND/, $ses_core->execCmd("pos FETCEPT $db_trunk{$trk}{-acc}")) {
                if (grep /ERROR/, $ses_core->execCmd("add $tuple")) {
                    $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple in PXRTE");
                } else {
                    if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                        $ses_core->execCmd("Y");
                    }
                }
            }
            unless ($ses_core->execCmd("abort;quit")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
            }
        }
    }

# CLEANUP
    &ADQ729_cleanup();
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ729_datafill","ADQ729_001","ADQ729_002","ADQ729_003","ADQ729_004",
                    "ADQ729_006","ADQ729_007","ADQ729_008","ADQ729_009","ADQ729_010",
                    "ADQ729_011","ADQ729_012","ADQ729_013","ADQ729_014","ADQ729_015",
                    "ADQ729_016","ADQ729_017","ADQ729_018","ADQ729_019","ADQ729_020",
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
# |   EO call service - R20 Sourcing Features - phase 1 (POH, ICTO, MTC)                                                              |
# +------------------------------------------------------------------------------+
# |   ADQ 729                                                                    |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Tai Nguyen ##########################
# W13
sub ADQ729_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_001");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ729_001";
    my $tcid = "ADQ729_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1], $db_list_line_info[2]);

    my $wait_for_event_time = 30;
    my $feature_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add DNH group
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }

# Add POH to line A and LOD to line B
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[0]");
		print FH "STEP: add POH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[0] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => "LOD $list_dn[1]", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LOD for line $list_dn[1]");
		print FH "STEP: add LOD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add LOD for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;
# Call flow
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] busy - PASS\n";
    }

    # Make call
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
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
        $logger->error(__PACKAGE__ . " $tcid: C calls A and the call is not fowarded to B ");
        print FH "STEP: C calls A and the call is fowarded to B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and the call is fowarded to B - PASS\n";
    }

################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

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

    # remove DNH from line A
    unless ($feature_added) {
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);    
}

sub ADQ729_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_002");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ729_002";
    my $tcid = "ADQ729_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = @db_list_line_info;
    
    my $wait_for_event_time = 30;
    my $dnh_added = 1;
    my $mdn_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add DNH group: A is pilot, B is member; Add POH to line A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[0]");
		print FH "STEP: add POH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[0] - PASS\n";
    }
    $dnh_added = 0;

# Add MDN to line C as primary
    @output = $ses_core->execCmd("ado \$ $list_dn[2] mdn sca y y $list_dn[2] tone y 3 y nonprivate \$ y y");
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
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[2]' ");
        print FH "STEP: add MDN to line $list_dn[2] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[2] as primary - PASS\n";
    }

# Add MDN to line D as member
    @output = $ses_core->execCmd("ado \$ $list_dn[3] mdn sca n y $list_dn[2] ANCT \$ y y");
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
    unless(grep /NUMBER ON INTERCEPT ANCT/, $ses_core->execCmd("qdn $list_dn[3]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[3]' ");
        print FH "STEP: add MDN to line $list_dn[3] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[3] as member - PASS\n";
    }
    $mdn_added = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] busy - PASS\n";
    }

    # Make call
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
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
        $logger->error(__PACKAGE__ . " $tcid: C calls A and the call is not fowarded to B ");
        print FH "STEP: C calls A and the call is fowarded to B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and the call is fowarded to B - PASS\n";
    }
    unless ($ses_glcas->offhookCAS(-line_port => $list_line[3],-wait_for_event_time => $list_line[3])) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot go offhook D ");
        print FH "STEP: Go offhook D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Go offhook D - PASS\n";
    }
    sleep(5);
    # check speech path among B, C and D
    %input = (
                -list_port => [$list_line[1],$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path among B, C, and D ");
        print FH "STEP: checking speech path among B, C, and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: checking speech path among B, C, and D - PASS\n";
    }


################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

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
    # Remove MDN from line C and D
    unless ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[2] $list_len[3] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[3] from MDN group");
            print FH "STEP: remove line $list_dn[3] from MDN group - FAIL\n";
        } else {
            print FH "STEP: remove line $list_dn[3] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[2] mdn $list_dn[2] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[2] - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[3] $list_line_info[3] $list_len[3] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[3] ");
            print FH "STEP: NEW line $list_dn[3] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[3] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_003");
    
############ Variables Declaration ####################################################
    my $sub_name = "ADQ729_003";
    my $tcid = "ADQ729_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1], $db_list_line_info[2]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'cas_r2'}{-acc};
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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
# Add DNH group and CFU to line A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => 'CFU N', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[0]");
		print FH "STEP: add CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

    my $cfu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CFWP');
    unless ($cfu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFU access code for line $list_dn[0]");
		print FH "STEP: get CFU access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFU access code for line $list_dn[0] - PASS\n";
    }

# Add PRK to line B
    unless ($ses_core->callFeature(-featureName => "PRK", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add PRK for line $list_dn[1]");
		print FH "STEP: add PRK for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add PRK for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 0;

    my $prk_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'PRKS');
    unless ($prk_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[1]");
		print FH "STEP: get PRK access code for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get PRK access code for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;
# Call flow
    # Activate CFU to line B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfu_acc . $list_dn[1] . '#';
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[0] - PASS\n";
    }
    # Make call
    ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C calls A and the call is not fowarded to B ");
        print FH "STEP: C calls A and the call is fowarded to B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and the call is fowarded to B - PASS\n";
    }
    # B activate PRK
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\*$prk_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '\*$prk_acc' successfully");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    sleep(15); # wait for PRK timeout 

    # Check line B rering
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not rering after PRK timeout ");
        print FH "STEP: Check line B rering - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B rering - PASS\n";
    }
    # check speech path between B and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE','DIGITS'], 
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
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
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
    # remove DNH and CFU from line A
    unless ($add_feature_lineA) {
        foreach ('DNH','CFU'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }
    # remove PRK from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'PRK', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove PRK from line $list_dn[1]");
            print FH "STEP: Remove PRK from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove PRK from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_004");
    
############################## Variables Declaration ##################################
    my $sub_name = "ADQ729_004";
    my $tcid = "ADQ729_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ##############################line DB#####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1], $db_list_line_info[2]);

    ##############################Trunk DB#####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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
# Add DNH group and CFD to A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
		print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # B dials DISA number
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $disa_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $disa_num successfully");
    }
    sleep(5);

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
    }
    sleep(2);

    # B dials trunk access code + line A
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
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

    # Check line C ring after CFD timeout
    sleep(20); # Wait for CFD timeout
    $index = 0;

    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line C is not ring after CFD timeout ");
        print FH "STEP: Check line C ring after CFD timeout - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring after CFD timeout - PASS\n";
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
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
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

    # remove DNH and CFD from line A
    unless ($add_feature_lineA) {
        foreach ('DNH','CFD') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[0]");
                print FH "STEP: remove $_ for line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[0] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);

}

sub ADQ729_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_005");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_005";
    my $tcid = "ADQ729_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ##############################line DB#####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1]);
    my @list_line = ($db_list_line[0], $db_list_line[1]);
    my @list_region = ($db_list_region[0],$db_list_region[1]);
    my @list_len = ($db_list_len[0],$db_list_len[1]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1]);

    ##############################Trunk DB#####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add DNH group and POH to A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }  
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[0]");
		print FH "STEP: add POH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add ACB to line B
    unless ($ses_core->callFeature(-featureName => "ACB NOAMA", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[1]");
		print FH "STEP: add ACB for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add ACB for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 0;

    my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[1]");
		print FH "STEP: get ACB access code for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get ACB access code for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow

    # Make line A busy
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[0] busy - PASS\n";
    }

    # line B call line A via trunk and hear busy tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(5);
    my %input = (
                -line_port => $list_line[1],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect busy tone line $list_line[1]");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    sleep(5);
    # line B activate ACB
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    $dialed_num = "\*$acb_acc\#";
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    sleep(5);
    # return line A to service
    if (grep /\sMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
        unless ($ses_core->execCmd("rts")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
        }
        unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[0] print")) {
            $logger->error(__PACKAGE__ . " $tcid: line $list_dn[0] is not IDL after 'rts' ");
            print FH "STEP: make line $list_dn[0] idle - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: make line $list_dn[0] idle - PASS\n";
        }
        foreach ('abort','quit all') {
            unless ($ses_core->execCmd("$_")) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot execute command '$_)' ");
            }
        }
    }
    sleep(10);
    # Check line B ring after A IDL
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not ring after A IDL ");
        print FH "STEP: Check line B ring after A IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring after A IDL - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }

    # Check line A ring after B offhook
    $index = 0; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(5);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line A is not ring after B offhook ");
        print FH "STEP: Check line A ring after B offhook - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ring after B offhook - PASS\n";
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
    # remove DNH from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
        }
    }
    # remove ACB from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ACB', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ACB from line $list_dn[1]");
            print FH "STEP: Remove ACB from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ACB from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_006");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_006";
    my $tcid = "ADQ729_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1]);
    my @list_line = ($db_list_line[0], $db_list_line[1]);
    my @list_region = ($db_list_region[0],$db_list_region[1]);
    my @list_len = ($db_list_len[0],$db_list_len[1]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add DNH group and POH to A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }  
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[0]");
		print FH "STEP: add POH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add AUL and DOR to line B
    foreach ("AUL $list_dn[0]",'DOR') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # line B call line A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
    }
    sleep(12);

    # Check call is not routed to line A
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(3);
    }
    if ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: The call still route to line A ");
        print FH "STEP: Check call is not routed to line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check call is not routed to line A - PASS\n";
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
            print FH "STEP: cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: cleanup GLCAS - PASS\n";
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
        unless (grep /Log empty/, $ses_logutil->execCmd("open amab")) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
        }
    }

    # remove DNH from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
                unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
                print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
            }
        }
        
    }
    # remove AUL and DOR from line B
    unless ($add_feature_lineB) {
        foreach ('AUL','DOR') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[1]");
                print FH "STEP: remove $_ for line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[1] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);

}

sub ADQ729_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_007");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_007";
    my $tcid = "ADQ729_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1]);
    my @list_line = ($db_list_line[0], $db_list_line[1]);
    my @list_region = ($db_list_region[0],$db_list_region[1]);
    my @list_len = ($db_list_len[0],$db_list_len[1]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add WML to line A
    unless ($ses_core->callFeature(-featureName => "WML y y $list_dn[1] 10 N", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add WML for line $list_dn[0]");
		print FH "STEP: add WML for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add WML for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add DNH group and POH to line B
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[1], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[1] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[1]");
		print FH "STEP: add POH for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Check line B ring after A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line $list_line[0] - PASS\n";
    }
    sleep(10); # wait for WML timeout

    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not ring after A offhook ");
        print FH "STEP: Check line B ring after A offhook - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring after A offhook - PASS\n";
    }

    # check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }

    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE','DIGITS'], 
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


################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

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

    # remove WML from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'WML', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove WML from line $list_dn[0]");
            print FH "STEP: Remove WML from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove WML from line $list_dn[0] - PASS\n";
        }
    }
    # remove DNH from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_008");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_008";
    my $tcid = "ADQ729_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1], $db_list_line_info[2]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line A
    foreach ('CEPT','ICTO') {
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
    $add_feature_lineA = 0;

# Add AUL to line B
    unless ($ses_core->callFeature(-featureName => "AUL $list_dn[0]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add AUL for line $list_dn[1]");
		print FH "STEP: add AUL for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add AUL for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call Flow
    # Offhook B to Make call to A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
        print FH "STEP: offhook line $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line $list_line[1] - PASS\n";
    }
    
    # Check line A ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line A is not ringing ");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }

    # check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE','DIGITS'], 
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

    # A flashes
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
    }

    # Make call A to C
    my ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;

    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(12);

    # Check line C ringing and offhook C
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line C is not ringing ");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }

    # check speech path between B and C
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    sleep(5);
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE','DIGITS'], 
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
    # B and C hang up
    foreach ($list_line[1], $list_line[2]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
        }
    }


################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # remove CEPT and ICTO from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[0]");
            print FH "STEP: Remove ICTO from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[0] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[0]");
                print FH "STEP: Remove CEPT from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[0] - PASS\n";
            }
        }
    }

    # remove AUL from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'AUL', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove AUL from line $list_dn[1]");
            print FH "STEP: Remove AUL from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove AUL from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_009");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_009";
    my $tcid = "ADQ729_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = ($db_list_line_info[0], 'IBN FETCEPT 0 0', $db_list_line_info[2], $db_list_line_info[3]);

    my $wait_for_event_time = 30;
    my $add_feature_lineCD = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line B
    foreach ('CEPT','ICTO') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineB = 0;

# Add CPU to line C and D (C and D must have the same custgroup)
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[2] $list_len[3] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[2] and $list_dn[3]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[3] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[3]")) {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[3] - PASS\n";
    }
    $add_feature_lineCD = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'CPU');
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and B flash
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # Make call B to C
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
    }
    sleep(12);

    # Check line C ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line C is not ringing ");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }

    # D dials CPU access code to pick up the call for C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
    }
    sleep(12);

    # check speech path between B and D
    %input = (
                -list_port => [$list_line[1],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and D ");
        print FH "STEP: check speech path between B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between B and D - PASS\n";
    }

    # check speech path between A and D
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and D ");
        print FH "STEP: check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and D - PASS\n";
    }


################################## Cleanup 009 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");

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
        @output = $ses_logutil->execCmd("open amab");
        if (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: AMAB is not generated on core after the call");
            $result = 0;
            print FH "STEP: Check AMAB exist - FAIL\n";
        } else {
            print FH "STEP: Check AMAB exist - PASS\n";
        }
        my $flag = 1;
        foreach ("CALLING DN.*$list_dn[0]","CALLED DN.*$list_dn[1]") {
            unless (grep /$_/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: AMAB is not correct");
                $flag = 0;
                last;
            }
        }
        unless($flag){
            $result = 0;
            print FH "STEP: Check AMAB is correct - FAIL\n";
        } else {
            print FH "STEP: Check AMAB is correct - PASS\n";
        } 
    }

    # remove CEPT and ICTO from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[1]");
            print FH "STEP: Remove ICTO from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[1] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[1]");
                print FH "STEP: Remove CEPT from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove CPU from line C and D
    unless ($add_feature_lineCD) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[2]");
            print FH "STEP: Remove CPU from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[2] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[3], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[3]");
            print FH "STEP: Remove CPU from line $list_dn[3] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[3] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_010");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_010";
    my $tcid = "ADQ729_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = ($db_list_line_info[0], 'IBN FETCEPT 0 0', $db_list_line_info[2], $db_list_line_info[3]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line B
    foreach ('CEPT','ICTO') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineB = 0;

# Add 3WC to line C
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[2]");
		print FH "STEP: add 3WC for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and B flash
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # Make call B to C and B onhook
    my ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['onA','offB'],
                -send_receive => [],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C then B onhook ");
        print FH "STEP: B calls C then B onhook - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C then B onhook - PASS\n";
    }

    # Check speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE','DIGITS'], 
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

    # C flashes and calls D
    %input = (
                -line_port => $list_line[2], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[2]");
    }

    ($dialed_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;

    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(12);

    # Check line D ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[3] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line D is not ringing ");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }

################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # remove CEPT and ICTO from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[1]");
            print FH "STEP: Remove ICTO from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[1] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[1]");
                print FH "STEP: Remove CEPT from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove 3WC from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[2]");
            print FH "STEP: Remove 3WC from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_011");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_011";
    my $tcid = "ADQ729_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1], $db_list_line_info[2], $db_list_line_info[3]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Create DNH group (A is pilot, B,C are member), Add POH, CEPT and ICTO to line A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1],$list_dn[2]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }
    foreach ('POH','CEPT','ICTO') {
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
# Case 1: line B is not busy
    # Make call D to A and A flash
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
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls A and they have speech path ");
        print FH "STEP: D calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and they have speech path - PASS\n";
    }

    # Make call A to B
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
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

    # Onhook A; check speech path between B and D
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    %input = (
                -list_port => [$list_line[3],$list_line[1]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and D ");
        print FH "STEP: check speech path between B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between B and D - PASS\n";
    }

    # B and D hang up the handset
    foreach ($list_line[1], $list_line[3]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
        }
    }
    sleep(5);

# Case 2: line B is busy
    # Make line B busy
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy'");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[1] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[1] busy - PASS\n";
    }
    # Make call D to A and A flash
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
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls A and they have speech path ");
        print FH "STEP: D calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and they have speech path - PASS\n";
    }

    # Make call A to B
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(12);

    # Check line C is not ringing
    %input = (
                -line_port => $list_line[0], 
                -busy_tone_duration => 2000, 
                -cas_timeout => 50000,
                -wait_for_event_time => 30
                ); 
    unless ($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot detect busy tone for line A");
        print FH "STEP: Check line C is not ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C is not ringing - PASS\n";
    }

    # A flashes to reconnect to D
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
    }

    # check speech path between A and D
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and D");
        print FH "STEP: check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and D - PASS\n";
    }

################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # return line B to service
    if (grep /\sMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        unless ($ses_core->execCmd("rts")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
        }
        unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
            $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL after 'rts' ");
            print FH "STEP: make line $list_dn[1] idle - FAIL\n";
        } else {
            print FH "STEP: make line $list_dn[1] idle - PASS\n";
        }
        foreach ('abort','quit all') {
            unless ($ses_core->execCmd("$_")) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot execute command '$_)' ");
            }
        }
    }

    # remove ICTO, CEPT from line A, remove DNH group.
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[0]");
            print FH "STEP: Remove ICTO from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[0] - PASS\n";
                unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[0]");
                print FH "STEP: Remove CEPT from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[0] - PASS\n";
            }
        }
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[2]");
            print FH "STEP: Remove DNH from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[2] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
                print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
                    unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                    $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
                    print FH "STEP: Remove DNH from line $list_dn[0] - FAIL\n";
                } else {
                    print FH "STEP: Remove DNH from line $list_dn[0] - PASS\n";
                }
            }
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_012");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_012";
    my $tcid = "ADQ729_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = ($db_list_line_info[0], 'IBN FETCEPT 0 0', $db_list_line_info[2], $db_list_line_info[3]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'isup'}{-acc};
    my $trunk_region = $db_trunk{'isup'}{-region};
    my $trunk_clli = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line B
    foreach ('CEPT','ICTO') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineB = 0;

# Add SIMRING to line C and D
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ SIMRING $list_dn[2] $list_dn[3] \$ act y 123 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add SIMRING for line $list_dn[2] and $list_dn[3]");
        $ses_core->execCmd("abort");
    }
    unless (grep /SIMRING/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add SIMRING for line $list_dn[2] and $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SIMRING for line $list_dn[2] and $list_dn[3] - PASS\n";
    }
    $add_feature_lineC = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and B flash
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # Make call B to C
    my ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(12);

    # Check line D ringing and offhook D
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[3] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line D is not ringing ");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }

    # Onhook B and check speech path between A and D
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and D");
        print FH "STEP: check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and D - PASS\n";
    }

    # A and D hang up the handset
    foreach ($list_line[0], $list_line[3]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
        }
    }

################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # remove CEPT and ICTO from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[1]");
            print FH "STEP: Remove ICTO from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[1] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[1]");
                print FH "STEP: Remove CEPT from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove SIMRING from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[2]");
            print FH "STEP: Remove SIMRING from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_013");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_013";
    my $tcid = "ADQ729_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ($db_list_line_info[0], 'IBN FETCEPT 0 0', $db_list_line_info[2]);

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line B
    foreach ('CEPT','ICTO') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineB = 0;

# Add DOR to line C
    unless ($ses_core->callFeature(-featureName => "DOR", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add DOR for line $list_dn[2]");
		print FH "STEP: add DOR for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DOR for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and B flash
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
                -send_receive => ['DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # Make call B to C and B onhook
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
    }
    sleep(12);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }

    # Check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGITS'], 
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

################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # remove CEPT and ICTO from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[1]");
            print FH "STEP: Remove ICTO from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[1] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[1]");
                print FH "STEP: Remove CEPT from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove DOR from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'DOR', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DOR from line $list_dn[2]");
            print FH "STEP: Remove DOR from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove DOR from line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_014");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_014";
    my $tcid = "ADQ729_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = @db_list_dn;
    my @list_line = @db_list_line;
    my @list_region = @db_list_region;
    my @list_len = @db_list_len;
    my @list_line_info = ($db_list_line_info[0], 'IBN FETCEPT 0 0', $db_list_line_info[2], $db_list_line_info[3]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CEPT and ICTO to line B
    foreach ('CEPT','ICTO') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineB = 0;

# Add CFD to line C
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[3]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[2]");
		print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and B flash
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
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path ");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # Make call B to C
    my ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;

    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    sleep(12);

    # Check line D ringing and onhook B
    my $index;
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[3] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line D is not ringing ");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }

    # check speech path between A and D
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and D ");
        print FH "STEP: check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and D - PASS\n";
    }

################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

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
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # remove CEPT and ICTO from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[1]");
            print FH "STEP: Remove ICTO from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[1] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[1]");
                print FH "STEP: Remove CEPT from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove CFD from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
            print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);

}

sub ADQ729_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_015");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_015";
    my $tcid = "ADQ729_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[2], $db_list_dn[1]);
    my @list_line = ($db_list_line[2], $db_list_line[1]);
    my @list_region = ($db_list_region[2],$db_list_region[1]);
    my @list_len = ($db_list_len[2],$db_list_len[1]);
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add MCTS and AUL to line A
    foreach ('MCTS',"AUL $list_dn[1]") {
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'MCT'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Offhook A to Make call to B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line $list_line[0] - PASS\n";
    }

    # Check line B ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not ringing ");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }

    # check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGITS'], 
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

################################## Cleanup 015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 015 ##################################");

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
    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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
        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        if (grep /MCT107/, @cat) {
            print FH "STEP: Check MCT107 log exist - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: MCT107 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT107 log exist - FAIL\n";
        }
    }

    # remove AUL and MCTS from line A
    unless ($add_feature_lineA) {
        foreach ('AUL','MCTS') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[0]");
                print FH "STEP: remove $_ for line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[0] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_016");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_016";
    my $tcid = "ADQ729_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1]);
    my @list_line = ($db_list_line[0], $db_list_line[1]);
    my @list_region = ($db_list_region[0],$db_list_region[1]);
    my @list_len = ($db_list_len[0],$db_list_len[1]);
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add WML to line A
    unless ($ses_core->callFeature(-featureName => "WML y y $list_dn[1] 10 N", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add WML for line $list_dn[0]");
		print FH "STEP: add WML for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add WML for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add MCTT to line B
    unless ($ses_core->callFeature(-featureName => 'MCTT', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add MCTT for line $list_dn[1]");
		print FH "STEP: add MCTT for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MCTT for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'MCT'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Offhook A to Make call to B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line $list_line[0] - PASS\n";
    }

    sleep(10); # wait for WML time out

    # Check line B ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not ringing ");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }

    # check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGITS'], 
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

################################## Cleanup 016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 016 ##################################");

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
    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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
        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        unless (grep /MCT108/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: MCT108 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT108 log exist - FAIL\n";
        } else {
            print FH "STEP: Check MCT108 log exist - PASS\n";
        }
    }

    # remove WML from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'WML', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove WML from line $list_dn[0]");
            print FH "STEP: Remove WML from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove WML from line $list_dn[0] - PASS\n";
        }
    }

    # remove MCTT from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'MCTT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove MCTT from line $list_dn[1]");
            print FH "STEP: Remove MCTT from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove MCTT from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_017");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_017";
    my $tcid = "ADQ729_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1]);
    my @list_line = ($db_list_line[0], $db_list_line[1]);
    my @list_region = ($db_list_region[0],$db_list_region[1]);
    my @list_len = ($db_list_len[0],$db_list_len[1]);
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add MCTT to line B
    unless ($ses_core->callFeature(-featureName => 'MCTT', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add MCTT for line $list_dn[1]");
		print FH "STEP: add MCTT for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MCTT for line $list_dn[1] - PASS\n";
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'MCT'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call A to B and they have speech path
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
                -send_receive => ['TESTTONE 100','DIGITS 123_456'],
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

################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

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
    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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
        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        unless (grep /MCT108/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: MCT108 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT108 log exist - FAIL\n";
        } else {
            print FH "STEP: Check MCT108 log exist - PASS\n";
        }
    }

    # remove MCTT from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'MCTT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove MCTT from line $list_dn[1]");
            print FH "STEP: Remove MCTT from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove MCTT from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_018");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_018";
    my $tcid = "ADQ729_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ('IBN FETCEPT 0 0', $db_list_line_info[1], $db_list_line_info[2]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add MCTS, CEPT and ICTO to line A
    foreach ('CEPT','ICTO','MCTS') {
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
    $add_feature_lineA = 0;

# Add DNH group and POH to line B
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[1], -addMem => 'No', -listMemDN => [])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[1] - PASS\n";
    }
    foreach ('POH','MCTT') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'MCT'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call C to A and A flash
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and they have speech path ");
        print FH "STEP: C calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and they have speech path - PASS\n";
    }

    # Make call A to B
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
    }
    sleep(12);

    # Check line B ringing
    my $index; 
    for ($index = 0; $index < 10; $index++) {
        if (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
            last;
        }
        sleep(3);
    }
    unless ($index < 10) {
        $logger->error(__PACKAGE__ . " $tcid: line B is not ringing ");
        print FH "STEP: Make call A to B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Make call A to B - PASS\n";
    }

    # Onhook A and check speech path between B and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    sleep(5);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and C ");
        print FH "STEP: Onhook A and check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook A and check speech path between B and C - PASS\n";
    }

################################## Cleanup 018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 018 ##################################");

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

    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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
        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        unless (grep /MCT108/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: MCT108 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT108 log exist - FAIL\n";
        } else {
            print FH "STEP: Check MCT108 log exist - PASS\n";
        }
        unless (grep /MCT107/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: MCT107 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT107 log exist - FAIL\n";
        } else {
            print FH "STEP: Check MCT107 log exist - PASS\n";
        }
    }

    # remove MCTS, CEPT and ICTO from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'MCTS', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove MCTS from line $list_dn[0]");
            print FH "STEP: Remove MCTS from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MCTS from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'ICTO', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ICTO from line $list_dn[0]");
            print FH "STEP: Remove ICTO from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove ICTO from line $list_dn[0] - PASS\n";
            unless ($ses_core->callFeature(-featureName => 'CEPT', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CEPT from line $list_dn[0]");
                print FH "STEP: Remove CEPT from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove CEPT from line $list_dn[0] - PASS\n";
            }
        }
    }

    # remove MCTT and DNH from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'MCTT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove MCTT from line $list_dn[1]");
            print FH "STEP: Remove MCTT from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove MCTT from line $list_dn[1] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_019");

############################# Variables Declaration #############################
    my $sub_name = "ADQ729_019";
    my $tcid = "ADQ729_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ('IBN RESTP 0 0', $db_list_line_info[1], $db_list_line_info[2]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $ofcvar_config = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Add CLF to line A
    unless ($ses_core->callFeature(-featureName => 'CLF', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CLF for line $list_dn[0]");
		print FH "STEP: add CLF for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CLF for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add CFB to line B
    unless ($ses_core->callFeature(-featureName => "CFB n $list_dn[0]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFB for line $list_dn[1]");
		print FH "STEP: add CFB for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFB for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 0;

# Make line B busy and config table OFCVAR
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[1] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[1] busy - PASS\n";
    }
    unless ($ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
    }
    # config table ofcvar
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCVAR")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCVAR'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CLF_ACCESS_CODE NN")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CLF_ACCESS_CODE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NN/, $ses_core->execCmd("pos CLF_ACCESS_CODE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of CLF_ACCESS_CODE");
        print FH "STEP: change PARMVAL of CLF_ACCESS_CODE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL of CLF_ACCESS_CODE - PASS\n";
    }
    $ofcvar_config = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'LINE'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make call C to B, A ring and check speech path then A flashes
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['DELAY 12','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls B and call is forwarded to A ");
        print FH "STEP: C calls B and call is forwarded to A then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls B and call is forwarded to A then A flashes - PASS\n";
    }

################################## Cleanup 019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 019 ##################################");

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
    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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
        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        if (grep /_MALICIOUS_/, @cat) {
            print FH "STEP: Check LINE126 log exist - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: LINE126 log is not generated");
            $result = 0;
            print FH "STEP: Check LINE126 log exist - FAIL\n";
        }
    }

    # Rollback table OFCVAR
    unless ($ofcvar_config) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCVAR")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCVAR'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep CLF_ACCESS_CODE 33")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CLF_ACCESS_CODE");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /33/, $ses_core->execCmd("pos CLF_ACCESS_CODE")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PARMVAL of CLF_ACCESS_CODE");
            print FH "STEP: rollback PARMVAL of CLF_ACCESS_CODE - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PARMVAL of CLF_ACCESS_CODE - PASS\n";
        }
    }

    # return line B to service
    if (grep /\sMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        unless ($ses_core->execCmd("rts")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
        }
        unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
            $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL after 'rts' ");
            print FH "STEP: make line $list_dn[1] idle - FAIL\n";
        } else {
            print FH "STEP: make line $list_dn[1] idle - PASS\n";
        }
        foreach ('abort','quit all') {
            unless ($ses_core->execCmd("$_")) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot execute command '$_)' ");
            }
        }
    }

    # remove CLF from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CLF', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CLF from line $list_dn[0]");
            print FH "STEP: Remove CLF from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CLF from line $list_dn[0] - PASS\n";
        }
    }

    # remove CFB from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line $list_dn[1]");
            print FH "STEP: Remove CFB from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFB from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
}

sub ADQ729_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ729_020");
    
############################# Variables Declaration #############################
    my $sub_name = "ADQ729_020";
    my $tcid = "ADQ729_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ729");

    ############################## line DB #####################################
    my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
    my @list_line = ($db_list_line[0], $db_list_line[1], $db_list_line[2]);
    my @list_region = ($db_list_region[0], $db_list_region[1], $db_list_region[2]);
    my @list_len = ($db_list_len[0], $db_list_len[1], $db_list_len[2]);
    my @list_line_info = ($db_list_line_info[0], $db_list_line_info[1], 'IBN FETCEPT 0 0');

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $ofcvar_config = 1;
    my $flag = 1;

################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
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

# Create DNH group (A is pilot, B are member), Add POH to line A
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }
    unless ($ses_core->callFeature(-featureName => 'POH', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line $list_dn[0]");
		print FH "STEP: add POH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add POH for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add CFB to line B
    unless ($ses_core->callFeature(-featureName => "CFB n $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFB for line $list_dn[1]");
		print FH "STEP: add CFB for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFB for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 0;

# Add CLF and MCTT to line C
    foreach ('MCTT','CLF') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[2]");
            print FH "STEP: add $_ for line $list_dn[2] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[2] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineC = 0;

# Config table ofcvar
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCVAR")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCVAR'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CLF_ACCESS_CODE NN")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CLF_ACCESS_CODE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NN/, $ses_core->execCmd("pos CLF_ACCESS_CODE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of CLF_ACCESS_CODE");
        print FH "STEP: change PARMVAL of CLF_ACCESS_CODE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL of CLF_ACCESS_CODE - PASS\n";
    }
    $ofcvar_config = 0;

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
    %input = (
                -username => [$core_account{-username}[1],$core_account{-username}[2]], 
                -password => [$core_account{-password}[1],$core_account{-password}[2]], 
                -logutilType => ['SWERR', 'TRAP', 'MCT', 'LINE'],
             ); 
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start logutil - PASS\n";
    }
    $logutil_start = 0;

# Call flow
    # Make line B busy
    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not MB after 'bsy' ");
        print FH "STEP: make line $list_dn[1] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: make line $list_dn[1] busy - PASS\n";
    }
    # Make call A to B, C ring and check speech path
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and call is forwarded to C then C flashes ");
        print FH "STEP: A calls B and call is forwarded to C then C flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and call is forwarded to C then C flashes - PASS\n";
    }
    sleep(3);

################################## Cleanup 020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 020 ##################################");

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

    # Stop Logutil
    sleep(5);
    my (@cat,$logutil_path);
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

        $logutil_path = $ses_logutil->{sessionLog2};
        @cat = `cat $logutil_path`;
        if (grep /MCT108/, @cat) {
            print FH "STEP: Check MCT108 log exist - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: MCT108 log is not generated");
            $result = 0;
            print FH "STEP: Check MCT108 log exist - FAIL\n";
        }

        if (grep /_MALICIOUS_/, @cat) {
            print FH "STEP: Check LINE126 log exist - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: LINE126 log is not generated");
            $result = 0;
            print FH "STEP: Check LINE126 log exist - FAIL\n";
        }
    }

    # Rollback table OFCVAR
    unless ($ofcvar_config) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCVAR")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCVAR'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep CLF_ACCESS_CODE 33")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CLF_ACCESS_CODE");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /33/, $ses_core->execCmd("pos CLF_ACCESS_CODE")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PARMVAL of CLF_ACCESS_CODE");
            print FH "STEP: rollback PARMVAL of CLF_ACCESS_CODE - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PARMVAL of CLF_ACCESS_CODE - PASS\n";
        }
    }

    # return line B to service
    if (grep /\sMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")) {
        unless ($ses_core->execCmd("rts")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'rts' ");
        }
        unless (grep /\sIDL\s/, $ses_core->execCmd("post d $list_dn[1] print")) {
            $logger->error(__PACKAGE__ . " $tcid: line $list_dn[1] is not IDL after 'rts' ");
            print FH "STEP: make line $list_dn[1] idle - FAIL\n";
        } else {
            print FH "STEP: make line $list_dn[1] idle - PASS\n";
        }
        foreach ('abort','quit all') {
            unless ($ses_core->execCmd("$_")) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot execute command '$_)' ");
            }
        }
    }

    # remove DNH from line B and A
    unless ($add_feature_lineA) {
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

    # remove CFB from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line $list_dn[1]");
            print FH "STEP: Remove CFB from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFB from line $list_dn[1] - PASS\n";
        }
    }

    # remove CLF and MCTT from line C
    unless ($add_feature_lineC) {
        foreach ('CLF','MCTT') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[2]");
                print FH "STEP: remove $_ for line $list_dn[2] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[2] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ729_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ729_checkResult($tcid, $result);
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
