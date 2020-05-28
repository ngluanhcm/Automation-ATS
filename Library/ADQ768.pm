#**************************************************************************************************#
#FEATURE                : <ADQ768> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Tai Nguyen Huu>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ768::ADQ768; 

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
our ($ses_core, $ses_glcas, $ses_logutil, $ses_tapi);
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

# For Tapi
our $audio_gwc = 27;
our $audio_gwc_ip = '10.102.182.76';
our $tapilog_dir = '/home/ptthuy/Tapitrace/';

our $detect = 'RINGBACK'; # Change into 'RINGBACK' if ringback is ok to check

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};

########################### Line info ####################################
our %db_line = (
                'lcm_1' => {
                            -line => 5,
                            -dn => 2124411266,
                            -region => 'US',
                            -len => 'T005   00 0 01 12',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'lcm_2' => {
                            -line => 6,
                            -dn => 2124411267,
                            -region => 'US',
                            -len => 'T005   00 0 01 13',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'rlcm_1' => {
                            -line => 7,
                            -dn => 2124411205,
                            -region => 'US',
                            -len => 'T000   00 0 00 05',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'rlcm_2' => {
                            -line => 8,
                            -dn => 2124411203,
                            -region => 'US',
                            -len => 'T000   00 0 00 03',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                );

our %tc_line = (
                'ADQ768_001' => ['lcm_1','lcm_2'],
                'ADQ768_002' => ['lcm_1','lcm_2'],
                'ADQ768_003' => ['lcm_1','lcm_2'],
                'ADQ768_004' => ['lcm_1','lcm_2'],
                'ADQ768_005' => ['lcm_1','lcm_2'],
                'ADQ768_006' => ['lcm_1','lcm_2'],
                'ADQ768_007' => ['lcm_1','lcm_2'],
                'ADQ768_008' => ['lcm_1','lcm_2'],
                'ADQ768_009' => ['lcm_1','lcm_2'],
                'ADQ768_010' => ['lcm_1','lcm_2'],
                'ADQ768_011' => ['lcm_1','lcm_2'],
                'ADQ768_012' => ['lcm_1','lcm_2'],
                'ADQ768_013' => ['lcm_1','lcm_2'],
                'ADQ768_014' => ['lcm_1','lcm_2'],
                'ADQ768_015' => ['lcm_1','lcm_2'],
                'ADQ768_016' => ['lcm_1','lcm_2'],
                'ADQ768_017' => ['lcm_1','lcm_2'],
                'ADQ768_018' => ['lcm_1','lcm_2'],
                'ADQ768_019' => ['lcm_1','lcm_2'],
                'ADQ768_020' => ['lcm_1','lcm_2'],
                'ADQ768_021' => ['lcm_1','lcm_2'],
                'ADQ768_022' => ['lcm_1','lcm_2'],
                'ADQ768_023' => ['lcm_1','lcm_2'],
                'ADQ768_024' => ['lcm_1','lcm_2'],
                'ADQ768_025' => ['lcm_1','lcm_2'],
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

sub ADQ768_cleanup {
    my $subname = "ADQ768_cleanup";
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

sub ADQ768_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ768_checkResult";
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
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    return $ses_core;
}

sub glcas {
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    return $ses_glcas;
}

sub logutil {
    sleep (2);
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    return $ses_logutil;
}

sub tapi {
    sleep (4);
    unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Tapi trace - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 for Tapi trace - PASS\n";
    }
    return $ses_tapi;
}

sub setBusyInTMTCNTL {
    unless (grep/TMTCNTL/, $ses_core->execCmd("table TMTCNTL")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'table TMTCNTL'");
    }
    unless (grep/LNT/, $ses_core->execCmd("pos LNT")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'pos LNT'");
    }
    unless ($ses_core->execCmd("sub")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'sub'");
    }
    unless (grep /BUSY .* Y .* S .* BUSY\W/, $ses_core->execCmd("pos BUSY")) {
        @output = $ses_core->execCmd("rep BUSY Y S BUSY");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    @output = $ses_core->execCmd("pos BUSY");
    return @output;
}

sub startTapiTrace {
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core for tapitrace - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'enable both gwc $audio_gwc'");
        return 0;
    } else {
        return 1;
    }
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ768_001", # Verify TONE_SLOW_INTERRUPTED is played correctly for LCM line
                    "ADQ768_002", # Verify TONE_FAST_INTERRUPTED is played correctly for LCM line
                    "ADQ768_003", # Verify TONE_DIST_AUD_RING is played correctly for LCM line
                    "ADQ768_004", # Verify TONE_SPECIAL_DIAL is played correctly for LCM line
                    "ADQ768_005", # Verify TONE_SPECIAL_INFORMATION is played correctly for LCM line
                    "ADQ768_006", # Verify TONE_WARNING is played correctly for LCM line
                    "ADQ768_007", # Verify TONE_CONGESTION is played correctly for LCM line
                    "ADQ768_008", # Verify TONE_RECALL_DIAL is played correctly for LCM line
                    "ADQ768_009", # Verify TONE_HELD is played correctly for LCM line
                    "ADQ768_010", # Verify TONE_MESSAGE_WAITING is played correctly for LCM line
                    "ADQ768_011", # Verify TONE_INTRUSION_PENDING is played correctly for LCM line
                    "ADQ768_012", # Verify TONE_INTRUSION is played correctly for LCM line
                    "ADQ768_013", # Verify TONE_INTRUSION_REMINDER is played correctly for LCM line
                    "ADQ768_014", # Verify TONE_TOLL_BREAK_IN is played correctly for LCM line
                    "ADQ768_015", # Verify TONE_CONFERENCE_ENTER is played correctly for LCM line
                    "ADQ768_016", # Verify TONE_CONFERENCE_EXIT is played correctly for LCM line
                    "ADQ768_017", # Verify TONE_CONFERENCE_LOCK is played correctly for LCM line
                    "ADQ768_018", # Verify CONFERENCE_TIME_LIMIT_WARNING is played correctly for LCM line
                    "ADQ768_019", # Verify TONE_CALLER_WAITING is played correctly for LCM line
                    "ADQ768_020", # Verify TONE_EXPENSIVE_ROUTE_WARNING is played correctly for LCM line
                    "ADQ768_021", # Verify TONE_OFF_HOOK_QUEUEING is played correctly for LCM line
                    "ADQ768_022", # Verify TONE_NACK is played correctly for LCM line
                    "ADQ768_023", # Verify TONE_VACTANT is played correctly for LCM line
                    "ADQ768_024", # Verify TONE_RECEIVER_OFF_HOOK is played correctly for LCM line
                    "ADQ768_025", # Verify TONE_CONFIRMATION is played correctly for LCM line
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
# |   EO - DLP_RLCM call features (interopt with different line/trunk types)     |
# +------------------------------------------------------------------------------+
# |   ADQ768                                                                     |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Tai Nguyen ##########################

sub ADQ768_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_001");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_001";
    $tcid = "ADQ768_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_SLOW_INTERRUPTED';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_SLOW_INTERRUPTED for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{test\/slow/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{test\/slow/, @tapi_output) {
            print FH "STEP: check the message SG{test/slow} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{test/slow}' displays on tapi log");
            print FH "STEP: check the message SG{test/slow} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_002");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_002";
    $tcid = "ADQ768_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_FAST_INTERRUPTED';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_FAST_INTERRUPTED for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{test\/fast/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{test\/fast/, @tapi_output) {
            print FH "STEP: check the message SG{test/fast} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{test/fast}' displays on tapi log");
            print FH "STEP: check the message SG{test/fast} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_003");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_003";
    $tcid = "ADQ768_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_DIST_AUD_RING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_DIST_AUD_RING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    sleep(5);

################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{cg\/cr/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{cg\/cr/, @tapi_output) {
            print FH "STEP: check the message SG{cg/cr} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{cg/cr}' displays on tapi log");
            print FH "STEP: check the message SG{cg/cr} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_004");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_004";
    $tcid = "ADQ768_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_SPECIAL_DIAL';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_SPECIAL_DIAL for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hear special dial tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect special dial tone line $list_dn[1]");
        print FH "STEP: B hear special dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear special dial tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{xcg\/spec/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{xcg\/spec/, @tapi_output) {
            print FH "STEP: check the message SG{xcg/spec} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{xcg/spec}' displays on tapi log");
            print FH "STEP: check the message SG{xcg/spec} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_005");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_005";
    $tcid = "ADQ768_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_SPECIAL_INFORMATION';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_SPECIAL_INFORMATION for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    sleep(5);

################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{cg\/sit/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{cg\/sit/, @tapi_output) {
            print FH "STEP: check the message SG{cg/sit} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{cg/sit}' displays on tapi log");
            print FH "STEP: check the message SG{cg/sit} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_006");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_006";
    $tcid = "ADQ768_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_WARNING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_WARNING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hears warning tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 1399,
                -freq2 => 0,
                -tone_duration => 200,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect warning tone line $list_dn[1]");
        print FH "STEP: B hear warning tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear warning tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{cg\/wt/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{cg\/wt/, @tapi_output) {
            print FH "STEP: check the message SG{cg/wt} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{cg/wt}' displays on tapi log");
            print FH "STEP: check the message SG{cg/wt} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_007");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_007";
    $tcid = "ADQ768_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CONGESTION';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CONGESTION for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hears congestion tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 619,
                -freq2 => 479,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect congestion tone line $list_dn[1]");
        print FH "STEP: B hear congestion tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear congestion tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{cg\/ct/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{cg\/ct/, @tapi_output) {
            print FH "STEP: check the message SG{cg/ct} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{cg/ct}' displays on tapi log");
            print FH "STEP: check the message SG{cg/ct} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_008");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_008";
    $tcid = "ADQ768_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_RECALL_DIAL';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_RECALL_DIAL for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hears recall dial tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect recall dial tone line $list_dn[1]");
        print FH "STEP: B hear recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear recall dial tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{srvtn\/rdt/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{srvtn\/rdt/, @tapi_output) {
            print FH "STEP: check the message SG{srvtn/rdt} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{srvtn/rdt}' displays on tapi log");
            print FH "STEP: check the message SG{srvtn/rdt} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_009");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_009";
    $tcid = "ADQ768_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_HELD';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_HELD for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hears hold tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 619,
                -freq2 => 0,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect hold tone line $list_dn[1]");
        print FH "STEP: B hear hold tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear hold tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 009 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{srvtn\/ht/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{srvtn\/ht/, @tapi_output) {
            print FH "STEP: check the message SG{srvtn/ht} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{srvtn/ht}' displays on tapi log");
            print FH "STEP: check the message SG{srvtn/ht} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_010");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_010";
    $tcid = "ADQ768_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_MESSAGE_WAITING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_MESSAGE_WAITING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);
    unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not busy");
        print FH "STEP: line A status is CPB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line A status is CPB - PASS\n";
    }

# B calls A and hears message waiting tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 441,
                -freq2 => 350,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect message waiting tone line $list_dn[1]");
        print FH "STEP: B hear message waiting tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear message waiting tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{srvtn\/mwt/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: " . Dumper(\@tapi_output));

        if (grep /SG\{srvtn\/mwt/, @tapi_output) {
            print FH "STEP: check the message SG{srvtn/mwt} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{srvtn/mwt}' displays on tapi log");
            print FH "STEP: check the message SG{srvtn/mwt} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_011");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_011";
    $tcid = "ADQ768_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_INTRUSION_PENDING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_INTRUSION_PENDING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{int\/pend/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{int\/pend/, @tapi_output) {
            print FH "STEP: check the message SG{int/pend} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{int/pend}' displays on tapi log");
            print FH "STEP: check the message SG{int/pend} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_012");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_012";
    $tcid = "ADQ768_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_INTRUSION';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_INTRUSION for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{int\/int/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{int\/int/, @tapi_output) {
            print FH "STEP: check the message SG{int/int} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{int/int}' displays on tapi log");
            print FH "STEP: check the message SG{int/int} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_013");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_013";
    $tcid = "ADQ768_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_INTRUSION_REMINDER';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_INTRUSION_REMINDER for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{int\/rem/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{int\/rem/, @tapi_output) {
            print FH "STEP: check the message SG{int/rem} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{int/rem}' displays on tapi log");
            print FH "STEP: check the message SG{int/rem} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_014");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_014";
    $tcid = "ADQ768_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_TOLL_BREAK_IN';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_TOLL_BREAK_IN for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{int\/tbi/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{int\/tbi/, @tapi_output) {
            print FH "STEP: check the message SG{int/tbi} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{int/tbi}' displays on tapi log");
            print FH "STEP: check the message SG{int/tbi} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_015");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_015";
    $tcid = "ADQ768_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CONFERENCE_ENTER';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CONFERENCE_ENTER for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 015 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{conftn\/enter/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{conftn\/enter/, @tapi_output) {
            print FH "STEP: check the message SG{conftn/enter} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{conftn/enter}' displays on tapi log");
            print FH "STEP: check the message SG{conftn/enter} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_016");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_016";
    $tcid = "ADQ768_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CONFERENCE_EXIT';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CONFERENCE_EXIT for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 016 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{conftn\/exit/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{conftn\/exit/, @tapi_output) {
            print FH "STEP: check the message SG{conftn/exit} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{conftn/exit}' displays on tapi log");
            print FH "STEP: check the message SG{conftn/exit} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_017";
    $tcid = "ADQ768_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CONFERENCE_LOCK';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CONFERENCE_LOCK for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{conftn\/lock/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{conftn\/lock/, @tapi_output) {
            print FH "STEP: check the message SG{conftn/lock} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{conftn/lock}' displays on tapi log");
            print FH "STEP: check the message SG{conftn/lock} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_018");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_018";
    $tcid = "ADQ768_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'CONFERENCE_TIME_LIMIT_WARNING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set CONFERENCE_TIME_LIMIT_WARNING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 018 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{conftn\/timelim/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{conftn\/timelim/, @tapi_output) {
            print FH "STEP: check the message SG{conftn/timelim} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{conftn/timelim}' displays on tapi log");
            print FH "STEP: check the message SG{conftn/timelim} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_019";
    $tcid = "ADQ768_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CALLER_WAITING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CALLER_WAITING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear caller waiting tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 479,
                -freq2 => 436,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect caller waiting tone line $list_dn[1]");
        print FH "STEP: B hear caller waiting tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear caller waiting tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 019 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{cg\/cr/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{cg\/cr/, @tapi_output) {
            print FH "STEP: check the message SG{cg/cr} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{cg/cr}' displays on tapi log");
            print FH "STEP: check the message SG{cg/cr} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_020");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_020";
    $tcid = "ADQ768_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_EXPENSIVE_ROUTE_WARNING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_EXPENSIVE_ROUTE_WARNING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 020 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{biztn\/erwt/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{biztn\/erwt/, @tapi_output) {
            print FH "STEP: check the message SG{biztn/erwt} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{biztn/erwt}' displays on tapi log");
            print FH "STEP: check the message SG{biztn/erwt} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_021 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_021");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_021";
    $tcid = "ADQ768_021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_OFF_HOOK_QUEUEING';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_OFF_HOOK_QUEUEING for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    sleep(5);

################################## Cleanup 021 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 021 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{biztn\/ofque/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{biztn\/ofque/, @tapi_output) {
            print FH "STEP: check the message SG{biztn/ofque} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{biztn/ofque}' displays on tapi log");
            print FH "STEP: check the message SG{biztn/ofque} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_022 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_022");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_022";
    $tcid = "ADQ768_022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_NACK';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_NACK for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear nack tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 619,
                -freq2 => 479,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect nack tone line $list_dn[1]");
        print FH "STEP: B hear nack tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear nack tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 022 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 022 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{xcg\/nack/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{xcg\/nack/, @tapi_output) {
            print FH "STEP: check the message SG{xcg/nack} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{xcg/nack}' displays on tapi log");
            print FH "STEP: check the message SG{xcg/nack} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_023 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_023");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_023";
    $tcid = "ADQ768_023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_VACANT';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_VACANT for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear VACT tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    %input = (
                -line_port => $list_line[1], 
                -freq1 => 619,
                -freq2 => 479,
                -tone_duration => 25,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect VACT tone line $list_dn[1]");
        print FH "STEP: B hear VACT tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear VACT tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 023 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 023 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{xcg\/vac/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{xcg\/vac/, @tapi_output) {
            print FH "STEP: check the message SG{xcg/vac} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{xcg/vac}' displays on tapi log");
            print FH "STEP: check the message SG{xcg/vac} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_024 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_024");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_024";
    $tcid = "ADQ768_024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_RECEIVER_OFF_HOOK';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_RECEIVER_OFF_HOOK for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    sleep(5);

################################## Cleanup 024 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 024 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{xcg\/roh/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{xcg\/roh/, @tapi_output) {
            print FH "STEP: check the message SG{xcg/roh} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{xcg/roh}' displays on tapi log");
            print FH "STEP: check the message SG{xcg/roh} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
}

sub ADQ768_025 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ768_025");

########################### Variables Declaration #############################
    my $sub_name = "ADQ768_025";
    $tcid = "ADQ768_025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ768");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $tapi_start = 0;
    my $change_busy = 0;
    my $tone_set = 'TONE_CONFIRMATION';
    my $dialed_num;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        # %input = (
        #             -function => ['OUT','NEW'], 
        #             -lineDN => $list_dn[$i], 
        #             -lineType => '', 
        #             -len => '', 
        #             -lineInfo => $list_line_info[$i]
        #         );
        # unless ($ses_core->resetLine(%input)) {
        #     $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot reset");
        #     print FH "STEP: Reset line $list_dn[$i] - FAIL\n";
        #     $flag = 0;
        #     last;
        # } else {
        #     print FH "STEP: Reset line $list_dn[$i] - PASS\n";
        # }
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

# Check BUSY in table TMTCNTL
    unless (grep /BUSY .* Y .* S .* BUSY/, &setBusyInTMTCNTL) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Check BUSY in table TMTCNTL");
        print FH "STEP: Check BUSY in table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check BUSY in table TMTCNTL - PASS\n";
    }

# Set TONE_CONFIRMATION for BUSY in table tones
    unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
    }
    $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 \+");
    @output = $ses_core->execCmd("$tone_set N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$tone_set/, $ses_core->execCmd("pos BUSY")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Set $tone_set for BUSY in table tones");
        print FH "STEP: Set $tone_set for BUSY in table tones - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Set $tone_set for BUSY in table tones - PASS\n";
    }
    $change_busy = 1;
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    $initialize_done = 1;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
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
    $logutil_start = 1;

# Start tapi trace
    unless (&startTapiTrace) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot start tapi trace");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 1;

###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

# A Offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

# B calls A then hear confirmation tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = $list_dn[0];
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "$dialed_num\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: B dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
        print FH "STEP: B hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hear confirmation tone - PASS\n";
    }

    sleep(5);

################################## Cleanup 025 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 025 ##################################");

    # Cleanup call
    if ($initialize_done) {
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
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ptthuy/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
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

    # Stop Tapi
    my @tapi_output;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    if ($tapi_start) {
        sleep(5);
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
            print FH "STEP: stop tapitrace - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: stop tapitrace - PASS\n";
        }

        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                foreach (@{$tapiterm_out{$gwc_id}{$tn}}) {
                    $_ =~ s/\0//g;
                    if (/SG\{srvtn\/conf/) {
                        push(@tapi_output, $_);
                    }
                }
            }
        }
        $logger->error(__PACKAGE__ . " $tcid: you see that" . Dumper(\@tapi_output));

        if (grep /SG\{srvtn\/conf/, @tapi_output) {
            print FH "STEP: check the message SG{srvtn/conf} displays on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'SG{srvtn/conf}' displays on tapi log");
            print FH "STEP: check the message SG{srvtn/conf} displays on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback BUSY tuple in table TONES
    if ($change_busy) {
        unless (grep/TONES/, $ses_core->execCmd("table TONES")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table TONES'");
        }
        @output = $ses_core->execCmd("rep busy 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_BSY N");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_BSY/, $ses_core->execCmd("pos BUSY")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot Set TONE_BSY for BUSY in table tones");
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Rollback TONE_BSY for BUSY in table tones - PASS\n";
        }
    }

    close(FH);
    &ADQ768_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ768_checkResult($tcid, $result);
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