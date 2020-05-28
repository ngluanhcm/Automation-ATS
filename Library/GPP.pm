#**************************************************************************************************#
#FEATURE                : <GPP> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Yen Le>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::YEN::GPP::GPP;

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
our ($ses_core, $ses_glcas, $ses_logutil, $ses_tapi);
our (%input, @output, @cmd_result, $tcid);
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

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});

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

sub GPP_cleanup {
    my $subname = "GPP_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_tapi, 
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub GPP_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "GPP_checkResult";
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

sub core {
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
    return $ses_core;
}

sub logutil {
    sleep (2);
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASS\n";
    }
    return $ses_logutil;
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "GPP_001", # GATWYINV - Provisioning ABI GPP with same IP and different H248 ports
                    "GPP_002", # GATWYINV - Modify IP of an existing ABI GPP while subtending PM state is OFFL
                    "GPP_003", # GATWYINV - Delete a GPP entry while it is still associated with an entry in table LTCINV
                    "GPP_004", # LTCINV - Provisioning full data G6 GPP POTS line
                    "GPP_005", # GPPTRNSL - Delete tuble in table GPPTRNSL when V5 interface is ACT
                    "GPP_006", # Provisioning - Full data & wrong data (prov ID)
                    "GPP_007", # Provisioning - GPP V5.2 POTS & BRI lines
                    "GPP_008", # Provisioning -  BRI ETSI version on C20 ATCA & C20 MA-RMS platform
                    "GPP_009", # Swap DNs-LTID of ISDN BRI line
                    "GPP_010", # Provisioning V5.2 from 1 to 16 links
                    "GPP_011", # BOUNDARY testing for V5.2 LE interface ID, Variant
                    "GPP_012", # GPP mode - QueryPm GPP
                    "GPP_013", # GPP mode - Bsy RTS Inactive unit
                    "GPP_014", # GPP mode - Busy - Return PM
                    "GPP_015", # GPP mode - Offline - Return PM
                    "GPP_016", # GPP mode - Busy return 2 pside message links
                    "GPP_017", # V5 mode - Verify Trnsl- alarm V5 in mode
                    "GPP_018", # V5 mode - Verify QueryPM in V5 mode
                    "GPP_019", # V5 mode - Busy and return link 1 & 2
                    "GPP_020", # V5 mode - Verify ACT and DEACT- Trnsl c and Trnsl p
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
# +------------------------------------------------------------------------------+
# |   R21 Sourcing - APA-500 - ETSI BRI on C20 with V5.2 for Vodafone NZ         |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Yen Le ##########################


sub GPP_001 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_001");
    $logger->debug(__PACKAGE__ . " GATWYINV - Provisioning ABI GPP with same IP and different H248 ports");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_001";
    $tcid = "GPP_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $existing_ip;
    my $logutil_start = 0;
    my $gatwy_no = 1023;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Find existing IP by using command "DIS"
    if (grep /NOT POSITIONED/, @output = $ses_core->execCmd("DIS")) {
        $logger->error(__PACKAGE__ . " $tcid: Table does not have any tuple");
        print FH "STEP: Execution cmd 'DIS' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'DIS' - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /G6ABI.*\(\s+(.*)\)\$/) {
            $existing_ip = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Existing IP is $existing_ip;");
        }
    }

#Check existing G6 ABI to avoid duplicate
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

#New ABI gateway with existing IP in above
    @output = $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ $existing_ip \$ HOST GWC 4 PORT 1 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless (grep/The IP address is a duplicate/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The ouput does not contain duplicate ERROR");
        print FH "STEP: Check ERROR 'The IP address is a duplicate' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Check ERROR 'The IP address is a duplicate' - PASS\n";
    }

    ################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_002 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_002");
    $logger->debug(__PACKAGE__ . " GATWYINV - Modify IP of an existing ABI GPP while subtending PM state is OFFL");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_002";
    $tcid = "GPP_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $new_ip = "11 11 11 11";
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1001 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Change IP of ABI GPP gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        $ses_core->execCmd("rep ABI $gatwy_no G6ABI 'AUTO-DISC' $new_ip \$ HOST GWC 5 +");
        @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
        if (grep/DMOS NOT ALLOWED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to change IP of ABI GPP gateway");
            print FH "STEP: Change IP of ABI GPP gateway - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Change IP of ABI GPP gateway - PASS\n";
        }
    }

    ################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_003 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_003");
    $logger->debug(__PACKAGE__ . " GATWYINV - Delete a GPP entry while it is still associated with an entry in table LTCINV");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_003";
    $tcid = "GPP_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Delete GPP ABI gateway while LTCINV still references this gateway
    if ($ltcinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/Error: Table LTCINV still references this Gateway/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Fail to check Error 'Table LTCINV still references this Gateway'");
            print FH "STEP: Check Error 'Table LTCINV still references this Gateway' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Check Error 'Table LTCINV still references this Gateway' - PASS\n";
        }
    }

    ################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_004 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_004");
    $logger->debug(__PACKAGE__ . " LTCINV - Provisioning full data G6 GPP POTS line");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_004";
    $tcid = "GPP_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Pos new provisioned GPP
    unless (grep/\<line length\>/, $ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not execute command 'format pack'");
    }
    unless (grep/$gatwy_no/, $ses_core->execCmd("pos GPP $gpp_no")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not execute command 'pos' GPP $gpp_no");
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully pos new provisioned GPP");
    }

    ################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_005 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_005");
    $logger->debug(__PACKAGE__ . " GPPTRNSL - Delete tuble in table GPPTRNSL when V5 interface is ACT");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_005";
    $tcid = "GPP_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gppv5_name;
    my $logutil_start = 0;
    my $flag = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Show all tuples to find GPP V5 interface
    unless (grep /AMCNO/, @output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Find GPP V5 interface
    foreach (@output) {
        if ($_ =~ /(GPPV\s+\d+\s+\d+)\s+GPP\s+\d+/) {
            $logger->debug(__PACKAGE__ . " $tcid: GPP V5 interface was found");
            $gppv5_name = $1;
            $flag = 1;
        }
    }
    unless ($flag) {
        $logger->error(__PACKAGE__ . " $tcid: No GPP V5 interface was found");
        print FH "STEP: Find GPP V5 interface  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Find GPP V5 interface  - PASS\n";
    }

#Delete GPP V5 interface
    if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $gppv5_name")) {
        @output = $ses_core->execCmd("y");
    }
    unless (grep/must be in the DEACT||still lines declared/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Tuple was deleted without any ERROR");
        print FH "STEP: Delete tuple and check ERROR generate - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Delete tuple and check ERROR generate - PASS\n";
    }


    ################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_006 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_006");
    $logger->debug(__PACKAGE__ . " V5PROV - Provisioning full data & wrong data (prov ID)");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_006";
    $tcid = "GPP_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $v5prid = 700;
    my $new_v5prid = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE V5PROV
    unless (grep /TABLE: V5PROV/, @output = $ses_core->execCmd("TABLE V5PROV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE V5PROV");
        print FH "STEP: Access TABLE V5PROV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE V5PROV - PASS\n";
    }

#New tuple in TABLE V5PROV with invalid V5PRID
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $v5prid 10 50 1 16 CTRL \$ 51 2 16 PSTN \$ \$ 3 \$ 3 15 \$ 50")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/ERROR/, @output) {
        print FH "STEP: Error generated when new tuple with V5PRID $v5prid - PASS\n";
        @output = $ses_core->execCmd("700");
    }
    foreach (@output) {
        if ($_ =~ /V5_KEY\s+\{(\d+)\s+TO\s+(\d+)\}/) {
            $logger->debug(__PACKAGE__ . " $tcid: Find valid range for V5PRID");
            print FH "STEP: Find valid range for V5PRID, $1 to $2 - PASS\n";
            $v5prid = $2 - 1;
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    
#New tuple in TABLE V5PROV with valid V5PRID
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $v5prid 10 50 1 16 CTRL \$ 51 2 16 PSTN \$ \$ 3 \$ 3 15 \$ 50")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple in TABLE V5PROV");
        print FH "STEP: Add new tuple in TABLE V5PROV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add new tuple in TABLE V5PROV - PASS\n";
        $new_v5prid = 1;
    }

    
    ################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

#Delete tuple in TABLE V5PROV
    if ($new_v5prid) {
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $v5prid")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in TABLE V5PROV");
            print FH "STEP: Delete tuple in TABLE V5PROV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete tuple in TABLE V5PROV - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_007 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_007");
    $logger->debug(__PACKAGE__ . " Provisioning - GPP V5.2 POTS & BRI lines");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_007";
    $tcid = "GPP_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $len_group;
    my $flag = 0;
    my @lengrp ;
    my ($i, $j, $draw, $num);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Show all tuples to find GPP line group
    unless (grep /AMCNO/, @output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Find GPP len group
    foreach (@output) {
        if ($_ =~ /(GPPV\s+\d+\s+\d+)\s+GPP\s+\d+/) {
            $logger->debug(__PACKAGE__ . " $tcid: GPP len group was found");
            $len_group = $1;
            $flag = 1;
        }
    }

    unless ($flag) {
        $logger->error(__PACKAGE__ . " $tcid: No GPP len group was found");
        print FH "STEP: Find GPP len group  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Find GPP len group  - PASS\n";
    }

#Access TABLE LNINV
    unless (grep /TABLE: LNINV/, @output = $ses_core->execCmd("TABLE LNINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LNINV");
        print FH "STEP: Access TABLE LNINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LNINV - PASS\n";
    }

#Find all provisioned lines with len group in above
    unless (grep /BOTTOM/, @output = $ses_core->execCmd("list all \(1 eq \'$len_group \* \*\'\)")) { 
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all provisioned lines");
        print FH "STEP: List all provisioned lines - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all provisioned lines - PASS\n";
    }

    $i = scalar@output;
    unless ($i>2) { #that means no line provisioned under this len group
        $logger->error(__PACKAGE__ . " $tcid: No line provisioned under this len group");
    } else {
        if ($output[$i-2] =~ /.*\s(\d+)\s(\d+)/) {
            $logger->debug(__PACKAGE__ . " $tcid: Found draw and line number");
            $draw = $1;
            $num = $2;
        }
    }

#Add new line for this len group
    if ($i>2) {
        for ($j = $num+1; $j <=99; $j++) {
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $len_group $draw $j V5BRI NPDGP WORKING N NL Y NIL")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE ADDED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE ADDED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple in TABLE LNINV");
                print FH "STEP: Add new tuple in TABLE LNINV - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Add new tuple in TABLE LNINV - PASS\n";
                $flag = 2;
            }

        }
    } else {
        for ($j = 0; $j <=99; $j++) {
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $len_group $draw $j V5BRI NPDGP WORKING N NL Y NIL")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE ADDED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE ADDED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple $len_group $draw $j in TABLE LNINV");
                print FH "STEP: Add new tuple $len_group $draw $j in TABLE LNINV - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Add new tuple $len_group $draw $j in TABLE LNINV - PASS\n";
                $flag = 3;
            }
        }

    }
    
    ################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

#Delete tuple in TABLE V5PROV
    if ($flag == 2) {
        for ($j = $num+1; $j <=99; $j++) { 
            if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $len_group $draw $j")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple $len_group $draw $j in TABLE LNINV");
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE LNINV - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE LNINV - PASS\n";
            }
        }
    } 
    if ($flag == 3) {
        for ($j = 0; $j <=99; $j++) { 
            if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $len_group $draw $j")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in TABLE LNINV");
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE V5PROV - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE V5PROV - PASS\n";
            }
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_008 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_008");
    $logger->debug(__PACKAGE__ . " Provisioning -  BRI ETSI version on C20 ATCA & C20 MA-RMS platform");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_008";
    $tcid = "GPP_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $dn_1 = 4005007650;
    my $dn_2 = 4005007651;
    my $isdn_1 = "isdn 220";
    my $isdn_2 = "isdn 221";
    my $len_1 = "GPPV 00 1 02 20";
    my $len_2 = "GPPV 00 1 02 21";
    my $flag_1 = 0;
    my $flag_2 = 0;
    my $line_state;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post 1st lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_1 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is IDL try to out then reprovisioning");
        $flag_1 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#Post 2nd lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_2 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is IDL try to out then reprovisioning");
        $flag_2 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#out, detach and remove isdn_1
    if ($flag_1) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_1 $isdn_1 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_1");
            print FH "STEP: Try to out line $dn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_1 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_1 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_1");
            print FH "STEP: Try to detach $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_1 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_1");
            print FH "STEP: Try to remove $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_1 - PASS\n";
        }
    }

#reprovisioning isdn_1
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_1");
        print FH "STEP: Try to add $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_1 att $len_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_1");
        print FH "STEP: Try to attach $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_1 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_1 ISDNKSET RESTP 0 0 1 y $isdn_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_1");
        print FH "STEP: Try to new line for $dn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_1 - PASS\n";
    }

#out, detach and remove isdn_2
    if ($flag_2) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_2 $isdn_2 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_2");
            print FH "STEP: Try to out line $dn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_2 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_2 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_2");
            print FH "STEP: Try to detach $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_2 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_2");
            print FH "STEP: Try to remove $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_2 - PASS\n";
        }
    }

#reprovisioning isdn_2
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_2");
        print FH "STEP: Try to add $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_2 att $len_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_2");
        print FH "STEP: Try to attach $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_2 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_2 ISDNKSET RESTP 0 0 1 y $isdn_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_2");
        print FH "STEP: Try to new line for $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_2 - PASS\n";
    }
    sleep (5);
#post 2 lines into MAPCI to make sure they IDL after reprovisioning
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after reprovisioning");
            print FH "STEP: Line $_ is IDL after reprovisioning - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after reprovisioning - PASS\n";
        }
    }

    ################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_009 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_009");
    $logger->debug(__PACKAGE__ . " Swap DNs - LTID of ISDN BRI line");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_009";
    $tcid = "GPP_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $dn_1 = 4005007650;
    my $dn_2 = 4005007651;
    my $isdn_1 = "isdn 220";
    my $isdn_2 = "isdn 221";
    my $len_1 = "GPPV 00 1 02 20";
    my $len_2 = "GPPV 00 1 02 21";
    my $flag_1 = 0;
    my $flag_2 = 0;
    my $line_state;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post 1st lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_1 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is IDL try to out then reprovisioning");
        $flag_1 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#Post 2nd lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_2 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is IDL try to out then reprovisioning");
        $flag_2 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#out, detach and remove isdn_1
    if ($flag_1) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_1 $isdn_1 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_1");
            print FH "STEP: Try to out line $dn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_1 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_1 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_1");
            print FH "STEP: Try to detach $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_1 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_1");
            print FH "STEP: Try to remove $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_1 - PASS\n";
        }
    }

#reprovisioning isdn_1
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_1");
        print FH "STEP: Try to add $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_1 att $len_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_1");
        print FH "STEP: Try to attach $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_1 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_1 ISDNKSET RESTP 0 0 1 y $isdn_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_1");
        print FH "STEP: Try to new line for $dn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_1 - PASS\n";
    }

#out, detach and remove isdn_2
    if ($flag_2) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_2 $isdn_2 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_2");
            print FH "STEP: Try to out line $dn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_2 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_2 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_2");
            print FH "STEP: Try to detach $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_2 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_2");
            print FH "STEP: Try to remove $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_2 - PASS\n";
        }
    }

#reprovisioning isdn_2
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_2");
        print FH "STEP: Try to add $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_2 att $len_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_2");
        print FH "STEP: Try to attach $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_2 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_2 ISDNKSET RESTP 0 0 1 y $isdn_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_2");
        print FH "STEP: Try to new line for $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_2 - PASS\n";
    }
    sleep (5);
#post 2 lines into MAPCI to make sure they IDL after reprovisioning
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after reprovisioning");
            print FH "STEP: Line $_ is IDL after reprovisioning - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after reprovisioning- PASS\n";
        }
    }

#swap dn isdn_1 and isdn_2
    unless (grep/Logical terminal ISDN/,$ses_core->execCmd("swlt \$ dns 4005007650 4005007651 y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not swact DN for $dn_1 and $dn_2");
        print FH "STEP: Try to swap DN for $dn_1 and $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to swap DN for $dn_1 and $dn_2 - PASS\n";
    }
    sleep(5);

#post 2 lines into MAPCI to make sure they IDL after swap
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after swap");
            print FH "STEP: Line $_ is IDL after swap - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after swap - PASS\n";
        }
    }

    ################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");

#swap dn isdn_1 and isdn_2 again
    unless (grep/Logical terminal ISDN/,$ses_core->execCmd("swlt \$ dns 4005007650 4005007651 y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not rollback DN for $dn_1 and $dn_2");
        print FH "STEP: Try to rollback DN for $dn_1 and $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to rollback DN for $dn_1 and $dn_2 - PASS\n";
    }
    sleep(5);
    
#post 2 lines into MAPCI to make sure they IDL after swap
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after rollback");
            print FH "STEP: Line $_ is IDL after rollback - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after rollback - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_010 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_010");
    $logger->debug(__PACKAGE__ . " Provisioning V5.2 from 1 to 16 links");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_010";
    $tcid = "GPP_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;
    my $ltcpsinv = 0;
    my $gpptrnsl = 0;
    my $flag = 0;
    my $v5id = 103;
    my $site_name;
    my $term;
    my @v5id = ();

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Replace tuple to modify 16 ports to D30 V52 N in TABLE LTCPSINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 D30 V52 N 1 D30 V52 N 2 D30 V52 N +");
        $ses_core->execCmd("3 D30 V52 N 4 D30 V52 N 5 D30 V52 N 6 D30 V52 N +");
        $ses_core->execCmd("7 D30 V52 N 8 D30 V52 N 9 D30 V52 N 10 D30 V52 N +");
        $ses_core->execCmd("11 D30 V52 N 12 D30 V52 N 13 D30 V52 N 14 D30 V52 N +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 D30 V52 N 16 D30 V52 N \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rep tuple in TABLE LTCPSINV");
            print FH "STEP: Rep tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rep tuple in TABLE LTCPSINV - PASS\n";
            $ltcpsinv = 1;
        }
    }

#Access TABLE SITE and format pack
    unless (grep /TABLE: SITE/, $ses_core->execCmd("TABLE SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE SITE");
        print FH "STEP: Access TABLE SITE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE SITE - PASS\n";
    }

    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack - PASS\n";
    }

#Find available site name
    CHECKSITE:
    unless (@output = $ses_core->execCmd("dis")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command dis");
    } else {
        $logger->error(__PACKAGE__ . " $tcid:" .Dumper(\@output));
    }
    foreach(@output) {
        unless ($_ =~ /(.*)\s+0\s+0/) {
            $logger->error(__PACKAGE__ . " $tcid: SITE name in used try to find an other");
            $ses_core->execCmd("next");
            goto CHECKSITE;
        } else {
            $site_name = $1;
            $logger->debug(__PACKAGE__ . " $tcid: SITE name $site_name is available");
            print FH "STEP: Site name was found $site_name - PASS\n"; 
        }
    }

#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Check existing V5ID to avoid duplicate
    unless (@output=$ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack list all");
        print FH "STEP: Command format pack list all- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack list all- PASS\n";
    }

    foreach(@output) {
        if ($_ =~ /\(\d+\)\s+\$\s(\d+)/) {
            $logger->debug(__PACKAGE__ . " $tcid: Try to get existing V5ID $1");
            $term = $1;
        }
        if ($v5id == $term) {
            $logger->error(__PACKAGE__ . " $tcid: This V5ID $v5id in used try to use an other");
            $v5id = $v5id - 1;
        } else {
            $flag = 1;
        }
    }
    if ($flag) {
        print FH "STEP: Available V5ID is $v5id- PASS\n";
    }


#New tuple in TABLE GPPTRNSL
    $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $v5id 127 480 V5UMUX RING2 REG")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE GPPTRNSL");
        print FH "STEP: New GPP in TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE GPPTRNSL - PASS\n";
        $gpptrnsl = 1;
    }


    ################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

    #Delete tuple in TABLE GPPTRNSL
    if ($gpptrnsl) {
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("del $site_name 00 0")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Rollback tuple in TABLE LTCPSINV
    if ($ltcpsinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 NILTYPE 1 NILTYPE 2 NILTYPE +");
        $ses_core->execCmd("3 NILTYPE 4 NILTYPE 5 NILTYPE 6 NILTYPE +");
        $ses_core->execCmd("7 NILTYPE 8 NILTYPE 9 NILTYPE 10 NILTYPE +");
        $ses_core->execCmd("11 NILTYPE 12 NILTYPE 13 NILTYPE 14 NILTYPE +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 NILTYPE 16 NILTYPE \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_011 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_011");
    $logger->debug(__PACKAGE__ . " BOUNDARY testing for V5.2 LE interface ID, Variant");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_011";
    $tcid = "GPP_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;
    my $ltcpsinv = 0;
    my $gpptrnsl = 0;
    my $flag = 0;
    my $v5id = 103;
    my $site_name;
    my @valid_v5id = (0, 99565, 16777215);
    my $invalid_v5id = 16777777;


    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################

#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Replace tuple to modify 16 ports to D30 V52 N in TABLE LTCPSINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 D30 V52 N 1 D30 V52 N 2 D30 V52 N +");
        $ses_core->execCmd("3 D30 V52 N 4 D30 V52 N 5 D30 V52 N 6 D30 V52 N +");
        $ses_core->execCmd("7 D30 V52 N 8 D30 V52 N 9 D30 V52 N 10 D30 V52 N +");
        $ses_core->execCmd("11 D30 V52 N 12 D30 V52 N 13 D30 V52 N 14 D30 V52 N +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 D30 V52 N 16 D30 V52 N \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rep tuple in TABLE LTCPSINV");
            print FH "STEP: Rep tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rep tuple in TABLE LTCPSINV - PASS\n";
            $ltcpsinv = 1;
        }
    }

#Access TABLE SITE and format pack
    unless (grep /TABLE: SITE/, $ses_core->execCmd("TABLE SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE SITE");
        print FH "STEP: Access TABLE SITE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE SITE - PASS\n";
    }

    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack - PASS\n";
    }

#Find available site name
    CHECKSITE:
    unless (@output = $ses_core->execCmd("dis")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command dis");
    } else {
        $logger->error(__PACKAGE__ . " $tcid:" .Dumper(\@output));
    }
    foreach(@output) {
        unless ($_ =~ /(.*)\s+0\s+0/) {
            $logger->error(__PACKAGE__ . " $tcid: SITE name in used try to find an other");
            $ses_core->execCmd("next");
            goto CHECKSITE;
        } else {
            $site_name = $1;
            $logger->debug(__PACKAGE__ . " $tcid: SITE name $site_name is available");
            print FH "STEP: Site name was found $site_name - PASS\n"; 
        }
    }

#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack list all
    unless (@output=$ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack list all");
        print FH "STEP: Command format pack list all- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack list all- PASS\n";
    }

#New then delete tuple in TABLE GPPTRNSL with valid V5ID
    foreach (@valid_v5id) {
        $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $_ 127 480 V5UMUX RING2 REG")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE ADDED/, @output) {
            @output = $ses_core->execCmd("y");
        } elsif (grep/The V5ID already/, @output) {
            print FH "STEP: The V5ID $_ is exist dont need to provisioning - PASS\n";
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE ADDED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to new tuple in table GPPTRNSL with V5ID $_");
            print FH "STEP: New tuple in table GPPTRNSL with V5ID $_ - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: New tuple in table GPPTRNSL with V5ID $_ - PASS\n";
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("del $site_name 00 0")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in table GPPTRNSL with V5ID $_");
                print FH "STEP: Delete tuple in table GPPTRNSL with V5ID $_ - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Delete tuple in table GPPTRNSL with V5ID $_ - PASS\n";
            }
        }
    }

#New tuple in TABLE GPPTRNSL with invalid V5ID
    $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $invalid_v5id 127 480 V5UMUX RING2 REG")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Successfully to new tuple with invalid V5ID $invalid_v5id");
        print FH "STEP: Detected invalid V5ID $invalid_v5id - FAIL\n";
    } else {
        print FH "STEP: Detected invalid V5ID $invalid_v5id - PASS\n";
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }


    ################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

#Rollback tuple in TABLE LTCPSINV
    if ($ltcpsinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 NILTYPE 1 NILTYPE 2 NILTYPE +");
        $ses_core->execCmd("3 NILTYPE 4 NILTYPE 5 NILTYPE 6 NILTYPE +");
        $ses_core->execCmd("7 NILTYPE 8 NILTYPE 9 NILTYPE 10 NILTYPE +");
        $ses_core->execCmd("11 NILTYPE 12 NILTYPE 13 NILTYPE 14 NILTYPE +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 NILTYPE 16 NILTYPE \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_012 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_012");
    $logger->debug(__PACKAGE__ . " GPP mode - QueryPm GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_012";
    $tcid = "GPP_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $abi_gateway;
    my $gateway_ip;
    my $query_ip = 1111;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Command format pack in TABLE LTCINV
    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack TABLE LTCINV - PASS\n";
    }

#Pos GPP 1 and find ABI gateway it belongs to
    unless (@output=$ses_core->execCmd("pos $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to pos $gpp in TABLE LTCINV");
        print FH "STEP: Pos $gpp in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Pos $gpp in TABLE LTCINV - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /HOST\s+(.*)\)\s+\$/) {
            $abi_gateway = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Gateway that $gpp belongs to is $abi_gateway");
            print FH "STEP: Gateway of $gpp is $abi_gateway - PASS\n";
        }
    }

#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Command format pack in TABLE GATWYINV
    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack TABLE GATWYINV - PASS\n";
    }

#Pos ABI gateway in TABLE GATWYINV and find it IP
    unless (@output=$ses_core->execCmd("pos $abi_gateway")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to pos $abi_gateway in TABLE GATWYINV");
        print FH "STEP: Pos $abi_gateway in TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Pos $abi_gateway in TABLE GATWYINV - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /AUTO-DISC\s+\((\d+)\s+(\d+)\s+(\d+)\s+(\d+)\)/) { 
            $gateway_ip = $1.".".$2.".".$3.".".$4;
            $logger->debug(__PACKAGE__ . " $tcid: IP of gateway $abi_gateway was found: $gateway_ip");
            print FH "STEP: Detect IP of gateway $abi_gateway $gateway_ip - PASS\n";           
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################ $_");       
    }

#Execute command QueryPM
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (@output = $ses_core->execCmd("QueryPM")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM'");
        print FH "STEP: Execution cmd 'QueryPM'- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'QueryPM'- PASS\n";    
    }

    #$logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
#Detect gateway IP in QueryPM output then compare with IP in TABLE GATWYINV
    foreach(@output) {
        if ($_ =~ /0002.*002\s+(.*)/){
            $query_ip = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Detected IP in QueryPM output $query_ip");
        }
    }
    
    if ($query_ip == $gateway_ip) {
        print FH "STEP: IP $gateway_ip matched - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: IP $gateway_ip does not match");
        print FH "STEP: IP $gateway_ip matched - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }

    ################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_013 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_013");
    $logger->debug(__PACKAGE__ . " GPP mode - Bsy RTS Inactive unit");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_013";
    $tcid = "GPP_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $inact_unit;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }
    
#Execute command QueryPM
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (@output = $ses_core->execCmd("QueryPM")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM'");
        print FH "STEP: Execution cmd 'QueryPM'- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'QueryPM'- PASS\n";    
    }

    #$logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
#Detect Inactive unit
    foreach(@output) {
        if ($_ =~ /(.*)\s+Inact/){
            $inact_unit = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Inactive unit is $inact_unit");
            print FH "STEP: Detected $inact_unit inactive unit -  PASS\n";
        }
    }

#Execute command Bsy inactive unit
    $logger->debug(__PACKAGE__ . " $tcid: Execute command Bsy $inact_unit");
    @output = $ses_core->{conn}->print("Bsy $inact_unit\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 100)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Bsy $inact_unit'");
        print FH "STEP: Bsy $inact_unit - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully Bsy $inact_unit");       
        print FH "STEP: Bsy $inact_unit - PASS\n";
    }
        

#Execute command RTS inactive unit
    $logger->debug(__PACKAGE__ . " $tcid: Execute command RTS $inact_unit");
    @output = $ses_core->{conn}->print("Rts $inact_unit\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 400)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed 'Rts $inact_unit'");
        print FH "STEP: Execution cmd 'Rts $inact_unit' - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully RTS $inact_unit");  
        print FH "STEP: Execution cmd 'Rts $inact_unit' - PASS\n";
    }  

    ################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_014 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_014");
    $logger->debug(__PACKAGE__ . " GPP mode - Busy - Return GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_014";
    $tcid = "GPP_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $state;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Check GPP is InSv or not
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (grep/PM is InSv||PM is ISTb/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not in properly state");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
    }  

#Execute command Bsy pm
    unless (grep/Please confirm/, $ses_core->execCmd("Bsy pm")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy pm'");
        print FH "STEP: Execute command 'Bsy pm' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Bsy pm' - PASS\n";
    }
    $logger->debug(__PACKAGE__ . " $tcid: Performing busy pm");
    $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 200)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform busy pm");
        print FH "STEP: Performed busy pm - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully busy pm");       
        print FH "STEP: Performed busy pm - PASS\n";
    }
    
#Execute command RTS pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing return pm");
    @output = $ses_core->{conn}->print("Rts pm\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 500)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return $gpp");
        print FH "STEP: Performed return $gpp - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return $gpp");  
        print FH "STEP: Performed return $gpp - PASS\n";
    } 

    unless (grep/PM is ISTb||PM is InSv/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not InSv after busy return");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
        $flag = 1;
    }

    ################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_015 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_015");
    $logger->debug(__PACKAGE__ . " GPP mode - Offline - Return GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_015";
    $tcid = "GPP_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    
    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Check GPP is InSv or not
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (grep/PM is InSv||PM is ISTb/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not in properly state");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
    }  

#Perform busy pm
    unless (grep/Please confirm/, $ses_core->execCmd("Bsy pm")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy pm'");
        print FH "STEP: Execute command 'Bsy pm' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Bsy pm' - PASS\n";
    }
    $logger->debug(__PACKAGE__ . " $tcid: Performing busy pm");
    $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 200)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform busy pm");
        print FH "STEP: Performed busy pm - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully busy pm");       
        print FH "STEP: Performed busy pm - PASS\n";
    }

#Perform offline pm
    unless ($ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'OffL'");
        print FH "STEP: Performed offline pm - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Performed offline pm - PASS\n";
    }
        
#Perform busy pm again
    unless (grep/Passed/, $ses_core->execCmd("Bsy pm")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy pm' from offline state");
        print FH "STEP: Performed busy pm from offline state - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Performed busy pm from offline state - PASS\n";
    }
        
#Execute command RTS pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing return pm");
    @output = $ses_core->{conn}->print("Rts pm\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 500)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return $gpp");
        print FH "STEP: Performed return $gpp - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return $gpp");  
        print FH "STEP: Performed return $gpp - PASS\n";
    } 

    unless (grep/PM is ISTb||PM is InSv/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not InSv after busy return");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
        $flag = 1;
    }

    ################################## Cleanup 015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 015 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_016 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_016");
    $logger->debug(__PACKAGE__ . " GPP mode - Busy return 2 pside message links");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_016";
    $tcid = "GPP_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $pslink_1;
    my $pslink_2;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect link 1 and link 2 of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp\s+.*\s+\((\d+)\)\s+\((\d+)\)/) {
            $pslink_1 = $1;
            $pslink_2 = $2;
            print FH "STEP: Link 1 of $gpp is $pslink_1 - PASS\n";
            print FH "STEP: Link 2 of $gpp is $pslink_2 - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect 2 messages link of $gpp");
        print FH "STEP: Detected 2 messages link of $gpp - FAIL\n";
        
    }

    ######################### MTC on link 1 ###############################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy link 1
    if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy 1")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy 1'");
        print FH "STEP: Execute command 'bsy 1' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } elsif (grep/ManB state/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The V5 link 1 is already in ManB no action required");
        print FH "STEP: Detected link 1 is already in ManB  - PASS\n";
    } else {
        print FH "STEP: Execute command 'bsy 1' - PASS\n";
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy 1' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy 1'");
            print FH "STEP: Perform 'bsy 1' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in GPP mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in GPP mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Busy pside message link
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    if (grep/Please confirm/, @output=$ses_core->execCmd("bsy link $pslink_1")) {
        unless(grep/Passed/, $ses_core->execCmd("y")){
            $logger->error(__PACKAGE__ . " $tcid: Could not busy link $pslink_1");
            print FH "STEP: Busy link $pslink_1 in GPP mode - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Busy link $pslink_1 in GPP mode - PASS\n";
        }
    } elsif (grep/Link $pslink_1 is ManB/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: Link $pslink_1 is already in ManB try to it");
        print FH "STEP: Detected link $pslink_1 is already in ManB - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Link $pslink_1 is not in properly state");
        $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
        print FH "STEP: Detected link $pslink_1 is not in properly state - FAIL\n";
    }
#Return pside message link
    $logger->debug(__PACKAGE__ . " $tcid: Trying to return pside link $pslink_1"); 
    $ses_core->{conn}->print("rts link $pslink_1");
    if ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 150)) {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return link $pslink_1");       
        print FH "STEP: Performed return link $pslink_1 - PASS\n";           
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return link $pslink_1");
        print FH "STEP: Performed return link $pslink_1 - FAIL\n"; 
        $result = 0; 
        goto CLEANUP;            
    }

#Access V5 mode again to return link
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode again - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode again - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next again
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next' again");
        print FH "STEP: Execute command 'next;next' again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' again - PASS\n";
    }

#Perform return link 1
    if (grep/Done/, $ses_core->execCmd("rts 1")) {
        print FH "STEP: Perform 'rts 1' successfully - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts 1'");
        print FH "STEP: Perform 'rts 1' successfully - FAIL\n";
        $result = 0;
    }

     ######################### MTC on link 2 ###############################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy link 1
    if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy 2")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy 2'");
        print FH "STEP: Execute command 'bsy 2' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } elsif (grep/ManB state/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The V5 link 2 is already in ManB no action required");
        print FH "STEP: Detected link 2 is already in ManB  - PASS\n";
    }else {
        print FH "STEP: Execute command 'bsy 2' - PASS\n";
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy 2' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy 2'");
            print FH "STEP: Perform 'bsy 2' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in GPP mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in GPP mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Busy pside message link
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    if (grep/Please confirm/, @output=$ses_core->execCmd("bsy link $pslink_2")) {
        unless(grep/Passed/, $ses_core->execCmd("y")){
            $logger->error(__PACKAGE__ . " $tcid: Could not busy link $pslink_2");
            print FH "STEP: Busy link $pslink_2 in GPP mode - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Busy link $pslink_2 in GPP mode - PASS\n";
        }
    } elsif (grep/Link $pslink_2 is ManB/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: Link $pslink_2 is already in ManB try to it");
        print FH "STEP: Detected link $pslink_2 is already in ManB - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Link $pslink_2 is not in properly state");
        $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
        print FH "STEP: Detected link $pslink_2 is not in properly state - FAIL\n";
    }
#Return pside message link
    $logger->debug(__PACKAGE__ . " $tcid: Trying to return pside link $pslink_2"); 
    $ses_core->{conn}->print("rts link $pslink_2");
    if ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 150)) {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return link $pslink_2");       
        print FH "STEP: Performed return link $pslink_2 - PASS\n";           
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return link $pslink_2");
        print FH "STEP: Performed return link $pslink_2 - FAIL\n"; 
        $result = 0; 
        goto CLEANUP;            
    }

#Access V5 mode again to return link
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode again - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode again - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next again
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next' again");
        print FH "STEP: Execute command 'next;next' again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' again - PASS\n";
    }

#Perform return link 1
    if (grep/Done/, $ses_core->execCmd("rts 2")) {
        print FH "STEP: Perform 'rts 2' successfully - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts 2'");
        print FH "STEP: Perform 'rts 2' successfully - FAIL\n";
        $result = 0;
    }

    ################################## Cleanup 016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 016 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_017 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_017");
    $logger->debug(__PACKAGE__ . " V5 mode - Verify Trnsl- alarm V5 in mode");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_017";
    $tcid = "GPP_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $pslink_1;
    my $pslink_2;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect link 1 and link 2 of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp\s+.*\s+\((\d+)\)\s+\((\d+)\)/) {
            $pslink_1 = $1;
            $pslink_2 = $2;
            print FH "STEP: Link 1 of $gpp is $pslink_1 - PASS\n";
            print FH "STEP: Link 2 of $gpp is $pslink_2 - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect 2 messages link of $gpp");
        print FH "STEP: Detected 2 messages link of $gpp - FAIL\n";
        
    }

#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform Trnsl into MAPCI V5 level
    unless (@output=$ses_core->execCmd("Trnsl")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'Trnsl'");
        print FH "STEP: Execute command 'Trnsl' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Trnsl' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));

#Verify output of Trnsl command
    foreach(@output){
        if ($_ =~/link  1.*pslink\s+(\d+)/) {
            if ($1 == $pslink_1){
                print FH "STEP: Verified link 1 in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Link 1 does not match");
                print FH "STEP: Verified link 1 in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
        if ($_ =~/link  2.*pslink\s+(\d+)/) {
            if ($1 == $pslink_2){
                print FH "STEP: Verified link 2 in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Link 2 does not match");
                print FH "STEP: Verified link 2 in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
    }
 
    ################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_018 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_018");
    $logger->debug(__PACKAGE__ . " V5 mode - Verify QueryPM in V5 mode");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_018";
    $tcid = "GPP_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $v5id;
    my $v5prid;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect V5ID and V5PRID of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp.*\$\s+(\d+)\s+(\d+)/) {
            $v5id = $1;
            $v5prid = $2;
            print FH "STEP: V5ID of $gpp is $v5id - PASS\n";
            print FH "STEP: V5PRID of $gpp is $v5prid - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect V5ID and V5PRID of $gpp");
        print FH "STEP: Detected V5ID and V5PRID of $gpp - FAIL\n";
        
    }

#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform Trnsl into MAPCI V5 level
    unless (@output=$ses_core->execCmd("QueryV5")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'QueryV5'");
        print FH "STEP: Execute command 'QueryV5' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'QueryV5' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));

#Verify output of QueryV5 command
    foreach(@output){
        if ($_ =~/V5ID\:\s+(\d+)\s+V5PRID\:\s+(\d+)/) {
            if ($1 == $v5id && $2 == $v5prid){
                print FH "STEP: Verified V5ID and V5PRID in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: V5ID and V5PRID does not match");
                print FH "STEP: Verified V5ID and V5PRID in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
    }
 
    ################################## Cleanup 018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 018 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_019 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_019");
    $logger->debug(__PACKAGE__ . " V5 mode - Busy and return link 1 & 2");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_019";
    $tcid = "GPP_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy-return link 1 & 2
    foreach(1,2) {
        if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy $_")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy $_'");
            print FH "STEP: Execute command 'bsy $_' - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } elsif (grep/ManB state/, @output) {
            $logger->debug(__PACKAGE__ . " $tcid: The V5 link $_ is in the ManB state try to return it");
            goto RTS;
        }else {
            print FH "STEP: Execute command 'bsy $_' - PASS\n";   
        }
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy $_' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy $_'");
            print FH "STEP: Perform 'bsy $_' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    RTS:    
        if (grep/Done/, $ses_core->execCmd("rts $_")) {
            print FH "STEP: Perform 'rts $_' successfully - PASS\n"; 
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts $_'");
            print FH "STEP: Perform 'rts $_' successfully - FAIL\n";
            $result = 0;
        }
        sleep(5);
        
    }
 
    ################################## Cleanup 019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 019 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
}

sub GPP_020 {
    $logger->debug(__PACKAGE__ . " Inside test case GPP_020");
    $logger->debug(__PACKAGE__ . " V5 mode - Busy and return link 1 & 2");

    ########################### Variables Declaration #############################
    my $sub_name = "GPP_020";
    $tcid = "GPP_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/YEN/GPP");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Deact V5 interface
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    if (grep/Please confirm/, @output=$ses_core->execCmd("deact")) {
        if (grep/Done||progress/, $ses_core->execCmd("y")) {
            print FH "STEP: Deacted V5 interface - PASS\n";
        } else {
            print FH "STEP: Deacted V5 interface - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    } else {
        $logger->error(__PACKAGE__ . " $tcid: An error occured please check related logs");
        print FH "STEP: An error occurd - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    sleep(5);

#Return V5 interface
    foreach(1,2,3,4) {
        unless (grep/timeout(.*)required/,@output=$ses_core->execCmd("act")) {
            print FH "STEP: Check 2 mins timeout - PASS\n";
        }
        if (grep/Please confirm/, @output) {
            if (grep/Done||interface||progress/, $ses_core->execCmd("y")) {
                print FH "STEP: Acted V5 interface - PASS\n";
                $flag = 1;
            }
        }      
        sleep(40);
    }

    unless ($flag) {
        print FH "STEP: Acted V5 interface - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }

    ################################## Cleanup 020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 020  ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless ((grep /Log empty/, @output) or (grep /Bus error accessing code|Descriptor range check/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
            $result = 0;
            print FH "STEP: Check Trap - FAIL\n";
        } else {
            print FH "STEP: Check trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &GPP_cleanup();
    # check the result var to know the TC is passed or failed
    &GPP_checkResult($tcid, $result);
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