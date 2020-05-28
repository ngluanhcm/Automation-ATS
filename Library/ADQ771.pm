#**************************************************************************************************#
#FEATURE                : <ADQ771> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Tai Nguyen Huu>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ771::ADQ771; 

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
        # "SELENIUM" => [1],
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
our ($ses_core, $ses_glcas, $ses_logutil, $ses_usnbd, $ses_swact, $ses_Selenium);
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
# For screen capture
our $ats_ip = "10.250.176.6";
our $ats_usrname = "ptthuy";
our $ats_passwd = "Welcome123";
our $seleniumSource = "D:\\Auto_ATS_Selenium\\selenium";
# Login to CIM
our $url = "https://172.28.249.6/oss/login.jsp";
our $web_userName = 'tech@genband.com';
our $web_passWord = "tech97";
our $browser = "firefox";

our $audio_gwc = 22;
our $audio_gwc_ip = '10.102.182.68';
our $tapilog_dir = '/home/ptthuy/Tapitrace/';

our $detect = 'RINGBACK'; # Change into 'RINGBACK' if ringback is ok to check
our $li_user = 'liadmin';
our $li_pass = 'liadmin';

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};

# Line Info
our %db_line = (
                'gr303_1' => {
                            -line => 1,
                            -dn => 2124411039,
                            -region => 'US',
                            -len => 'AZTK   01 2 00 39',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'gr303_2' => {
                            -line => 2,
                            -dn => 2124411040,
                            -region => 'US',
                            -len => 'AZTK   01 2 00 40',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'gr303_3' => {
                            -line => 15,
                            -dn => 2124411041,
                            -region => 'US',
                            -len => 'AZTK   01 2 00 41',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
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
                'lcm_3' => {
                            -line => 16,
                            -dn => 2124411260,
                            -region => 'US',
                            -len => 'T005   00 0 01 06',
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
                'rlcm_3' => {
                            -line => 17,
                            -dn => 2124411201,
                            -region => 'US',
                            -len => 'T000   00 0 00 01',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'abi_1' => {
                            -line => 3,
                            -dn => 2124410502,
                            -region => 'US',
                            -len => 'HOST   21 0 00 02',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                'abi_2' => {
                            -line => 4,
                            -dn => 2124410503,
                            -region => 'US',
                            -len => 'HOST   21 0 00 03',
                            -info => 'IBN NY_PUB 0 0 NILLATA 0',
                            },
                );

our %tc_line = (
                'ADQ771_001' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_002' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_003' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_004' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_005' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_006' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_007' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_008' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_009' => ['gr303_1','gr303_2','gr303_3'],
                'ADQ771_010' => ['gr303_1','lcm_1','lcm_2','gr303_3'],
                'ADQ771_011' => ['gr303_1','gr303_2','lcm_1','gr303_3'],
                'ADQ771_012' => ['gr303_2','gr303_1','gr303_3','lcm_1'],
                'ADQ771_013' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_014' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_015' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_016' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_017' => ['abi_1','gr303_1','gr303_2','gr303_3'],
                'ADQ771_018' => ['gr303_1','lcm_1','gr303_2','gr303_3'],
                'ADQ771_019' => ['rlcm_1','rlcm_2','rlcm_3'],
                'ADQ771_020' => ['rlcm_1','gr303_3','rlcm_2','rlcm_3'],
                'ADQ771_021' => ['rlcm_1','rlcm_2','rlcm_3'],
                'ADQ771_022' => ['rlcm_1','rlcm_2','rlcm_3'],
                'ADQ771_023' => ['rlcm_1','rlcm_2','rlcm_3'],
                'ADQ771_024' => ['rlcm_1','rlcm_2','gr303_3','rlcm_3'],
                'ADQ771_025' => ['rlcm_1','gr303_3','rlcm_2','rlcm_3'],
                'ADQ771_026' => ['rlcm_1','gr303_2','rlcm_2','rlcm_3'],
                'ADQ771_027' => ['rlcm_1','gr303_1','rlcm_2','rlcm_3'],
                'ADQ771_028' => ['rlcm_1','gr303_3','rlcm_2','rlcm_3'],
                'ADQ771_029' => ['lcm_1','lcm_2','lcm_3'],
                'ADQ771_030' => ['lcm_1','gr303_3','lcm_2','lcm_3'],
                'ADQ771_031' => ['lcm_1','gr303_3','lcm_2','lcm_3'],
                'ADQ771_032' => ['lcm_1','gr303_3','lcm_2','lcm_3'],
                'ADQ771_033' => ['lcm_1','lcm_2','gr303_1','gr303_2'],
                'ADQ771_034' => ['lcm_1','abi_1','gr303_1','abi_2'],
                'ADQ771_035' => ['abi_2','abi_1','gr303_1','gr303_2'],
);

our %db_trunk = (
                't15_g9_isup' =>{
                                -acc => 731,
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
                't15_isup' =>{
                                -acc => 913,
                                -region => 'US',
                                -clli => 'G6VZSTSC7IT2W',
                            },
                't15_pri' =>{
                                -acc => 504,
                                -region => 'US',
                                -clli => 'G6VZSTSPRINT2W',
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

sub ADQ771_cleanup {
    my $subname = "ADQ771_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_usnbd,
                    $ses_swact, $ses_Selenium
                    );
    foreach (@end_ses) {
        if (defined $_) {
            if ($_ == $ses_Selenium) {
                $ses_Selenium->quit();
            }
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ771_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ771_checkResult";
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

sub usnbd {
    sleep (4);
    unless ($ses_usnbd = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LISessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for LI - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 for LI - PASS\n";
    }
    return $ses_usnbd;
}

sub swact {
    sleep(6);
    unless ($ses_swact = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_SwactSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for swact - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 for swact - PASS\n";
    }
    return $ses_swact;
}

sub selenium {
    sleep(2);
    unless($ses_Selenium = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "selenium:1:ce0"}, -sessionlog => $tcid."_SeleniumLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘selenium:1:ce0’ }");
        print FH "STEP: Login Server 53 for GUI - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login Server 53 for GUI - PASS\n";
    }
    return $ses_Selenium;
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ771_001", # Verify LI USNDB (mode SW & COMBINED) with LNP CCC
                    "ADQ771_002", # Verify LI USNDB (mode SW & PAIRED) with LNP CCC
                    "ADQ771_003", # Verify that warm swact AUD GWC during LI call with DE COMBINED mode
                    "ADQ771_004", # GR303_POTS_IBN lines basic call with LI involved 
                    "ADQ771_005", # GR303_POTS_IBN lines call to IBN line then CXR to IBN line with LI involved
                    "ADQ771_006", # GR303_POTS_IBN lines call to IBN line then CFD to IBN line with LI involved
                    "ADQ771_007", # GR303_POTS_IBN line basic call via trunk SST with LI involved
                    "ADQ771_008", # GR303_POTS_IBN line basic call via trunk PRI with LI involved
                    "ADQ771_009", # GR303_POTS_IBN line basic call via trunk ISUP with LI involved
                    "ADQ771_010", # GR303_POTS_IBN Verify the CWT feature works fine with LI involved
                    "ADQ771_011", # GR303_POTS_IBN Verify that 3WC joins meet me conference with LI involved
                    "ADQ771_012", # GR303_POTS_IBN Verify the CFU allows the system to forward all calls to a predetermined destination number unconditionally with LI involved
                    "ADQ771_013", # GR303_POTS_IBN line basic call with LI involved (2 LEA)
                    "ADQ771_014", # GR303_POTS_IBN line basic call with LI involved (2 LEA) via trunk SST
                    "ADQ771_015", # GR303_POTS_IBN line basic call with LI involved (2 LEA) via trunk ISUP
                    "ADQ771_016", # GR303_POTS_IBN line basic call with LI involved (2 LEA) via trunk PRI
                    "ADQ771_017", # GR303_POTS_IBN Verify Simring feature with pots line has LI involved
                    "ADQ771_018", # GR303_POTS_IBN lines call to IBN simring group then CXR to DLP POTS line has CFD to Voicemail with LI involved
                    "ADQ771_019", # DLP_RLCM_IBN line basic call with LI involved
                    "ADQ771_020", # DLP_RLCM_IBN line call to IBN line then CXR to IBN line with LI involved
                    "ADQ771_021", # DLP_RLCM_IBN line basic call via trunk SST with LI involved
                    "ADQ771_022", # DLP_RLCM_IBN line basic call via trunk PRI with LI involved
                    "ADQ771_023", # DLP_RLCM_IBN line basic call via trunk ISUP with LI involved
                    "ADQ771_024", # DLP_RLCM_IBN_MADN SCA basic call with LI involved
                    "ADQ771_025", # DLP_RLCM_IBN line basic call with LI involved (2 LEA)
                    "ADQ771_026", # DLP_RLCM_IBN line basic call with LI involved (2 LEA) via trunk SST
                    "ADQ771_027", # DLP_RLCM_IBN line basic call with LI involved (2 LEA) via trunk ISUP
                    "ADQ771_028", # DLP_RLCM_IBN line basic call with LI involved (2 LEA) via trunk PRI
                    "ADQ771_029", # DLP_LCM_IBN line basic call with LI involved
                    "ADQ771_030", # DLP_LCM_IBN line basic call with LI involved (2 LEA)
                    "ADQ771_031", # DLP_LCM_IBN line call to IBN line then CXR to IBN line with LI involved
                    "ADQ771_032", # DLP_LCM_IBN line basic call with LI involved (2 LEA) via trunk SST
                    "ADQ771_033", # DLP_LCM_IBN Verify DRING works properly with DLP-LCM line has LI involved
                    "ADQ771_034", # DLP_LCM_IBN Basic call inter-op with DLP, ABI, GR303 with LI involved 
                    "ADQ771_035", # DLP_LCM_1FR Basic call inter-op with DLP, ABI, GR303 with LI involved
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
# |   EO - LI New Features of old Releases (CMV17/18/19) -                       |
# | feature LI NP - CCC, LI overlapping, prepended Routing digit, PRI Diversion  |
# +------------------------------------------------------------------------------+
# |   ADQ771                                                                     |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Tai Nguyen ##########################

sub ADQ771_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_001");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_001";
    $tcid = "ADQ771_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    # Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");

    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# Check line C Ring and offhook
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

# LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_002");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_002";
    $tcid = "ADQ771_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP and check speech path");
        print FH "STEP: A calls B via ISUP and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via ISUP
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via ISUP");
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - PASS\n";
    }

# LEA D can monitor incoming of line A via ISUP
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via ISUP");
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_003");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_003";
    $tcid = "ADQ771_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify, $gwc_id);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    my $thr5 = threads->create(\&swact);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();
    $ses_swact = $thr5->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[2] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
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

# Warm swact audio GWC
    unless ($ses_swact->warmSwactGWC(-gwc_id => $audio_gwc)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to warm swact GWC$audio_gwc");
        print FH "STEP: Warm swact GWC$audio_gwc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Warm swact GWC$audio_gwc - PASS\n";
    }

# Check speech path line A and B after warm-swact
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B after warm-swact");
        print FH "STEP: Check speech path between A and B after warm-swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B after warm-swact - PASS\n";
    }

# LEA C can monitor the call between A and B after warm swact
    %input = (
                -list_port => [$list_line[1], $list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B after warm swact");
        print FH "STEP: LEA C monitor the call between A and B after warm swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C monitor the call between A and B after warm swact - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_004");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_004";
    $tcid = "ADQ771_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[2] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    # sleep(5);
    # %input = (
    #             -line_port => $list_line[2],
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    #     $result = 0;
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C monitor the call between A and B - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_005");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_005";
    $tcid = "ADQ771_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CXR to line B
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR add $ccr_id VOICE COMBINED LINE DE $list_dn[3] Y N $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C then onhook
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
    sleep(8);

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);

# Offhook C and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CXR from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_006");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_006";
    $tcid = "ADQ771_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CFD to line B
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
		print FH "STEP: add CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# Activate CFD
    unless ($ses_core->execCmd("Servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    unless ($ses_core->execCmd("changecfx $list_len[1] CFD $list_dn[2] A")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'changecfx'");
    }

    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFD for line $list_dn[2]");
        print FH "STEP: line B activate CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line B activate CFD for line $list_dn[2] - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and the call forward to line C
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and the call forward to line C");
        print FH "STEP: A calls B and the call forward to line C - FAIL\n";
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and the call forward to line C - PASS\n";
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

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
        if (grep /CFD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CFD from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[1]");
            print FH "STEP: Remove CFD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_007");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_007";
    $tcid = "ADQ771_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_sipt'}{-acc};
    my $trunk_region = $db_trunk{'t15_sipt'}{-region};
    my $trunk_clli = $db_trunk{'t15_sipt'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
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

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# Delete LATA1 2124411041 in table LATAXLA
    unless (grep/LATAXLA/, $ses_core->execCmd("table LATAXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table LATAXLA'");
    }
    unless (grep /NOT FOUND/, $ses_core->execCmd("pos LATA1 2124411041")) {
        @output = $ses_core->execCmd("del LATA1 2124411041");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }
    
# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via SST and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and check speech path");
        print FH "STEP: A calls B via SST and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and check speech path - PASS\n";
    }

# Check line C Ring and offhook
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

# LEA C can monitor the call between A and B via SST
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B via SST");
        print FH "STEP: LEA can monitor the call between A and B via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B via SST - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_008");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_008";
    $tcid = "ADQ771_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");

    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via PRI and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI and check speech path");
        print FH "STEP: A calls B via PRI and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via PRI and check speech path - PASS\n";
    }

# LEA cannot monitor the call between A and B via PRI
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C still ring");
        print FH "STEP: LEA cannot monitor the call between A and B via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA cannot monitor the call between A and B via PRI - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_009");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_009";
    $tcid = "ADQ771_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP and check speech path");
        print FH "STEP: A calls B via ISUP and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP and check speech path - PASS\n";
    }

# Check line C Ring and offhook
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

# LEA C can monitor the call between A and B via ISUP
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B via ISUP");
        print FH "STEP: LEA can monitor the call between A and B via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B via ISUP - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_010");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_010";
    $tcid = "ADQ771_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineA = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CWT, CWI to line A
    foreach ('CWT','CWI') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[0]");
            print FH "STEP: add $_ for line $list_dn[0] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[0] - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
    $add_feature_lineA = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# C calls A and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and check speech path");
        print FH "STEP: C calls A and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and check speech path - PASS\n";
    }

# B calls A and hear ringback tone, A hear CWT tone
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
        print FH "STEP: B hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
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

    # Check CWT tone line A
    %input = (
                -line_port => $list_line[0],
                -callwaiting_tone_duration => 300,
                -cas_timeout => 20000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A hears Call waiting tone");
        print FH "STEP: A hears Call waiting tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears Call waiting tone - PASS\n";
    }

    # Check Ringback tone line B
    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect ringback tone line $list_dn[1]");
        print FH "STEP: B hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears ringback tone - PASS\n";
    }

# A flash to answer B
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_dn[0]");
        print FH "STEP: A Flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A Flash - PASS\n";
    }
    sleep(2);

# Check speech path A and B
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

# LEA D monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and B");
        print FH "STEP: LEA D monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and B - PASS\n";
    }

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
        sleep(5);
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
        if (grep /CWI|CWT/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[2]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[0]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove service from line A
    if ($add_feature_lineA) {
        foreach ('CWI','CWT') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_011");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_011";
    $tcid = "ADQ771_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: add 3WC for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C and check speech path then B flash
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
    
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and check speech path then B flash");
        print FH "STEP: B calls C and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and check speech path then B flash - PASS\n";
    }

# Check speech path among A, B, C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path among A, B, C");
        print FH "STEP: Check speech path among A, B, C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path among A, B, C - PASS\n";
    }

# LEA D can monitor the call between A, B and C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A, B and C");
        print FH "STEP: LEA D monitor the call between A, B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A, B and C - PASS\n";
    }

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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove 3WC from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
            print FH "STEP: Remove 3WC from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_012");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_012";
    $tcid = "ADQ771_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $cfu_act_code = 47;
    my $cfu_deact_code = 35;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
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

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos FEATXLA $cfu_act_code")) {
        @output = $ses_core->execCmd("add FEATXLA $cfu_act_code FEAT N N CFWP");
    } else {
        @output = $ses_core->execCmd("rep FEATXLA $cfu_act_code FEAT N N CFWP");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CFWP/, $ses_core->execCmd("pos FEATXLA $cfu_act_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill FEATXLA $cfu_act_code in table IBNXLA");
        print FH "STEP: Datafill FEATXLA $cfu_act_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill FEATXLA $cfu_act_code in table IBNXLA - PASS\n";
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos FEATXLA $cfu_deact_code")) {
        @output = $ses_core->execCmd("add FEATXLA $cfu_deact_code FEAT N N CFWC");
    } else {
        @output = $ses_core->execCmd("rep FEATXLA $cfu_deact_code FEAT N N CFWC");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CFWC/, $ses_core->execCmd("pos FEATXLA $cfu_deact_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill FEATXLA $cfu_deact_code in table IBNXLA");
        print FH "STEP: Datafill FEATXLA $cfu_deact_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill FEATXLA $cfu_deact_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Add CFU to line B
    unless ($ses_core->callFeature(-featureName => "CFU N", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[1]");
		print FH "STEP: add CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# B dials CFU code to activate CFU
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
        print FH "STEP: B hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = '*' . $cfu_act_code . $list_dn[2];
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

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
    }

    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[1]");
        print FH "STEP: activate CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[1] - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }

# A calls B and the call forward to line C
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and the call forward to line C");
        print FH "STEP: A calls B and the call forward to line C - FAIL\n";
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and the call forward to line C - PASS\n";
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

# Hang up all lines
    foreach ($list_line[0],$list_line[2],$list_line[3]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
        }
    }
    print FH "STEP: Hang up all lines - PASS\n";

# B dials CFU code to deactivate CFU
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
        $result = 0;
        goto CLEANUP;
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[1], -cas_timeout => 50000);

    $dialed_num = '*' . $cfu_deact_code;
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

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[1], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[1]");
    }

    unless (grep /CFU.*\sI\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[1]");
        print FH "STEP: activate CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[1] - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }

# A calls B and the call does not forward to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    $dialed_num = $list_dn[1];
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

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C still ring after deactivating code");
        print FH "STEP: The call does not forward to line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: The call does not forward to line C - PASS\n";
    }

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
        if (grep /CFU/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CFU from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFU from line $list_dn[1]");
            print FH "STEP: Remove CFU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFU from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_013");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_013";
    $tcid = "ADQ771_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE DE $list_dn[2] $list_dn[3] y y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor outgoing of line A
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A");
        print FH "STEP: LEA C can monitor outgoing of line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A - PASS\n";
    }

# LEA D can monitor incoming of line A
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A");
        print FH "STEP: LEA D can monitor incoming of line A- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_014");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_014";
    $tcid = "ADQ771_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_sipt'}{-acc};
    my $trunk_region = $db_trunk{'t15_sipt'}{-region};
    my $trunk_clli = $db_trunk{'t15_sipt'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via SST and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and check speech path");
        print FH "STEP: A calls B via SST and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via SST
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via SST");
        print FH "STEP: LEA C can monitor outgoing of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via SST - PASS\n";
    }

# LEA D can monitor incoming of line A via SST
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via SST");
        print FH "STEP: LEA D can monitor incoming of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via SST - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_015");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_015";
    $tcid = "ADQ771_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP and check speech path");
        print FH "STEP: A calls B via ISUP and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via ISUP
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via ISUP");
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - PASS\n";
    }

# LEA D can monitor incoming of line A via ISUP
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via ISUP");
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_016");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_016";
    $tcid = "ADQ771_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;

################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via PRI and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI and check speech path");
        print FH "STEP: A calls B via PRI and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via PRI and check speech path - PASS\n";
    }

# LEA C, D can monitor incoming, outgoing side of line A via PRI
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C still ring");
        print FH "STEP: LEA C cannot monitor outgoing of line A via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C cannot monitor outgoing of line A via PRI - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D still ring");
        print FH "STEP: LEA D cannot monitor outgoing of line A via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D cannot monitor outgoing of line A via PRI - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_017";
    $tcid = "ADQ771_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineC = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[1] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $deposit_num = '2124409001';
    my $add_subcriber = 0;
    my $flag = 1;

    # my $Image_Path = 'D:\\Auto_ATS_Selenium\\selenium\\'.$tcid.'_IMAGE_'.$datestamp.'.png';
    # my $Image_Path1 = 'D:\\Auto_ATS_Selenium\\selenium\\'.$tcid.'_IMAGE_'.$datestamp.'_Message.png';
    # my ($sessionId, $localUrl,$button,$textbox,$value,$element);
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    # my $thr5 = threads->create(\&selenium);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();
    # $ses_Selenium = $thr5->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }
    # unless (($sessionId, $localUrl) = $ses_Selenium->initialize(-sourceCodePath => $seleniumSource, -browser => $browser, -url => $url)) {
    #     $logger->error(__PACKAGE__ . ": Failed to launch  URL: $url" );
    #     print FH "STEP: Launch the url '$url' - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Launch the url '$url' - PASS \n";
    # }
    # $logger->debug(__PACKAGE__ . ": sessionId == $sessionId === localUrl : $localUrl " );

############### Test Specific configuration & Test Tool Script Execution #################

########################### Subcribe voicemail #################################
# Input username & password to login CIM
    # # Input user
    # $textbox = "//input[\@id='login']";
    # $value = $web_userName;
    # unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #     $logger->error(__PACKAGE__ . ": Failed to send username '$value' to username texbox" );
    #     print FH "STEP: Input username '$value' - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Input username '$value' - PASS \n";
    # }
    
    # # Input password
    # $textbox = "//input[\@id='passwd']";
    # $value = $web_passWord;
    # unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #     $logger->error(__PACKAGE__ . ": Failed to send password '$value' to password texbox");
    #     print FH "STEP: Input password '$value' - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Input password '$value' - PASS \n";
    # }
	
    # # Click login
    # $button = "//button[\@type='submit'][\@name='submit']";
    # unless ($ses_Selenium->clickElement(-xPath => $button)) {
    #     $logger->error(__PACKAGE__ . ": Failed to click 'Login' button");
    #     print FH "STEP: Click 'Login' button - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Click 'Login' button - PASS \n";
    # }
	# sleep(3);
	
    # $ses_Selenium->switchToFrameName(-name => "mainframe");

    # $element = "//font[normalize-space\(\)='Find']";
    # unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #     $logger->error(__PACKAGE__ . ": Failed to Login CIM");
    #     print FH "STEP: Login CIM - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Login CIM - PASS \n";
    # }

# Check subcriber
    # $button = "//font[normalize-space\(\)='Find']";
    # unless ($ses_Selenium->clickElement(-xPath => $button)) {
    #     $logger->error(__PACKAGE__ . ": Failed to click 'Find' button");
    #     print FH "STEP: Click 'Find' button - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Click 'Find' button - PASS \n";
    # }
    # sleep(2);

    # $textbox = "//input[\@name='findPhoneNumber']";
    # $value = $list_dn[2];
    # unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #     $logger->error(__PACKAGE__ . ": Failed to send '$value' to findPhoneNumber texbox" );
    #     print FH "STEP: Input '$value' to find - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Input '$value' to find - PASS \n";
    # }

    # $button = "//input[\@name='FindPhone'][\@type='BUTTON']";
    # unless ($ses_Selenium->clickElement(-xPath => $button)) {
    #     $logger->error(__PACKAGE__ . ": Failed to click 'Find' phone number button");
    #     print FH "STEP: click 'Find' phone number button - FAIL \n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: click 'Find' phone number button - PASS \n";
    # }
	# sleep(3);

    # $element = "//font[normalize-space\(\)='\(Subscriber Found\)']";
    # unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #     $logger->debug(__PACKAGE__ . ": Subscriber $list_dn[2] is not found - need to add new");
    # } else {
    #     print FH "STEP: Subscriber $list_dn[2] is added successfully - PASS \n";
    #     $add_subcriber = 1;
    # }

# Add new subcriber if line has not yet registered
    # unless ($add_subcriber) {
    # # Step 1: Select Offer
    #     $button = "//font[normalize-space\(\)='Add']";
    #     unless ($ses_Selenium->clickElement(-xPath => $button)) {
    #         $logger->error(__PACKAGE__ . ": Failed to click 'Add' button");
    #         print FH "STEP: Click 'Add' button - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Click 'Add' button - PASS \n";
    #     }

    #     $element = "//select[\@id='offerMenu'][\@name='offer']";
    #     unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #         $logger->error(__PACKAGE__ . ": Registration Offer menu has not existed");
    #         print FH "STEP: Registration Offer menu appears - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Registration Offer menu appears - PASS \n";
    #     }

    #     $element = "//select[\@id='offerMenu'][\@name='offer']";
    #     unless ($ses_Selenium->selectByVisibleText(-xPath => $element, -visibleText => "CIM Proto VM")) {
    #         $logger->error(__PACKAGE__ . ": Failed to select CIM Proto VM");
    #         print FH "STEP: Select CIM Proto VM - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Select CIM Proto VM - PASS \n";
    #     }

    #     $button = "//input[\@value='Next'][\@name='NEXT']";
    #     $ses_Selenium->clickElement(-xPath => $button);    
    #     sleep(3);

    #     $element = "//font[normalize-space\(\)='\(Step 2 - Enter Subscriber Information\)']";
    #     unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #         $logger->error(__PACKAGE__ . ": Failed to click 'Next' button");
    #         print FH "STEP: Click 'Next' button - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Click 'Next' button - PASS \n";
    #     }

    # # Step 2: Enter Subscriber Information
    #     $textbox = "//input[\@name='custLastName'][\@class='inputs']";
    #     $value = $list_dn[2];
    #     unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #         $logger->error(__PACKAGE__ . ": Failed to send '$value' to last name texbox" );
    #         print FH "STEP: Input '$value' for last name - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Input '$value' for last name - PASS \n";
    #     }

    #     $textbox = "//input[\@name='cfbnaNumber'][\@class='inputs']";
    #     $value = $list_dn[2];
    #     unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #         $logger->error(__PACKAGE__ . ": Failed to send '$value' to phone number texbox" );
    #         print FH "STEP: Input '$value' for phone number - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Input '$value' for phone number - PASS \n";
    #     }

    #     $element = "//select[\@class='inputs'][\@name='switchId']";
    #     unless ($ses_Selenium->selectByVisibleText(-xPath => $element, -visibleText => "TMA15")) {
    #         $logger->error(__PACKAGE__ . ": Failed to select TMA15 for Switch");
    #         print FH "STEP: Select TMA15 for Switch - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Select TMA15 for Switch - PASS \n";
    #     }

    #     $textbox = "//input[\@name='pin'][\@class='inputs']";
    #     $value = '1234';
    #     unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
    #         $logger->error(__PACKAGE__ . ": Failed to send '$value' to pin texbox" );
    #         print FH "STEP: Input '$value' for PIN - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Input '$value' for PIN - PASS \n";
    #     }

    #     $button = "//input[\@value='Next'][\@name='NEXT']";
    #     $ses_Selenium->clickElement(-xPath => $button);    
    #     sleep(3);

    #     $element = "//font[normalize-space\(\)='\(Step 3 - Summary\)']";
    #     unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #         $logger->error(__PACKAGE__ . ": Failed to click 'Next' button");
    #         print FH "STEP: Click 'Next' button - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Click 'Next' button - PASS \n";
    #     }

    # # Step 3: Summary
    #     $button = "//input[\@value='Create Account'][\@name='NEXT']";
    #     $ses_Selenium->clickElement(-xPath => $button);  
    #     sleep(3);

    #     $element = "//font[normalize-space\(\)='\(Confirmation\)']";
    #     unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #         $logger->error(__PACKAGE__ . ": Failed to click 'Create Account' button");
    #         print FH "STEP: Click 'Create Account' button - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Click 'Create Account' button - PASS \n";
    #     }

    #     $button = "//input[\@value='GoTo'][\@name='AGAIN']";
    #     $ses_Selenium->clickElement(-xPath => $button);   
    #     sleep(3);

    #     $element = "//font[normalize-space\(\)='\(Subscriber Found\)']";
    #     unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
    #         $logger->error(__PACKAGE__ . ": Failed to click 'Go to' button");
    #         print FH "STEP: Click 'Go to' button - FAIL \n";
    #         $result = 0;
    #         goto CLEANUP;
    #     } else {
    #         print FH "STEP: Click 'Go to' button - PASS \n";
    #     }
    # }

########################### Done Subcribe voicemail #################################
# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add 3WC to line B, add CFD to line C
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: add 3WC for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

    unless ($ses_core->callFeature(-featureName => "CFD N $deposit_num", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[2]");
		print FH "STEP: add CFD for line C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line C $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;

# Activate CFD
    unless ($ses_core->execCmd("Servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    unless ($ses_core->execCmd("changecfx $list_len[2] CFD $deposit_num A")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'changecfx'");
    }

    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFD for line $deposit_num");
        print FH "STEP: line C activate CFD for line $deposit_num- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: line C activate CFD for line $deposit_num - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[1] NILC NILLATA",
            "SURV ADD DN $list_dn[1] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C and the call forward to voicemail
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }
    sleep(12); #wait for CFD timeout

# B leave a message and LEA D can monitor
    # B press #
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B cannot press \#");
    }
    
    # LEA D can monitor when B leave message on voice mail
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor when B leave message on voice mail");
        print FH "STEP: LEA D can monitor when B leave message on voice mail - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor when B leave message on voice mail - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at Press \# to end message");
        print FH "STEP: Press \# to end message - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Press \# to end message - PASS\n";
    }
    sleep(2);

    # B press # then onhook
    %input = (
                -line_port => $list_line[1],
                -dialed_number => '#',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B cannot press \#");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: B press # and onhook - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B press # and onhook - PASS\n";
    }

################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

    # Take screen shot
    # sleep(3);
    # unless ($ses_Selenium->takeScreenshot(-sessionId => $sessionId, -localUrl => $localUrl, -path => $Image_Path, -ip => $ats_ip, -username => $ats_usrname, -password => $ats_passwd)) {
    #     $logger->error(__PACKAGE__ . ": Failed to take screenshot " );
    #     print FH "STEP: Take screenshot - FAIL \n";
    # } else {
    #     print FH "STEP: Take screenshot  - PASS \n";
    # }

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
        if (grep /3WC|CFD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLING DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove 3WC from line B, CFD from line C
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
            print FH "STEP: Remove 3WC from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[1] - PASS\n";
        }
    }
    if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
            print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_018");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_018";
    $tcid = "ADQ771_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineC = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $deposit_num = '2124409001';
    my $add_subcriber = 0;
    my $flag = 1;

    my $Image_Path = 'D:\\Auto_ATS_Selenium\\selenium\\'.$tcid.'_IMAGE_'.$datestamp.'.png';
    my $Image_Path1 = 'D:\\Auto_ATS_Selenium\\selenium\\'.$tcid.'_IMAGE_'.$datestamp.'_Message.png';
    my ($sessionId, $localUrl,$button,$textbox,$value,$element);
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    my $thr5 = threads->create(\&selenium);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();
    $ses_Selenium = $thr5->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }
    unless (($sessionId, $localUrl) = $ses_Selenium->initialize(-sourceCodePath => $seleniumSource, -browser => $browser, -url => $url)) {
        $logger->error(__PACKAGE__ . ": Failed to launch  URL: $url" );
        print FH "STEP: Launch the url '$url' - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Launch the url '$url' - PASS \n";
    }
    $logger->debug(__PACKAGE__ . ": sessionId == $sessionId === localUrl : $localUrl " );

############### Test Specific configuration & Test Tool Script Execution #################

########################### Subcribe voicemail #################################
Input username & password to login CIM
    # Input user
    $textbox = "//input[\@id='login']";
    $value = $web_userName;
    unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
        $logger->error(__PACKAGE__ . ": Failed to send username '$value' to username texbox" );
        print FH "STEP: Input username '$value' - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Input username '$value' - PASS \n";
    }
    
    # Input password
    $textbox = "//input[\@id='passwd']";
    $value = $web_passWord;
    unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
        $logger->error(__PACKAGE__ . ": Failed to send password '$value' to password texbox");
        print FH "STEP: Input password '$value' - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Input password '$value' - PASS \n";
    }
	
    # Click login
    $button = "//button[\@type='submit'][\@name='submit']";
    unless ($ses_Selenium->clickElement(-xPath => $button)) {
        $logger->error(__PACKAGE__ . ": Failed to click 'Login' button");
        print FH "STEP: Click 'Login' button - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Click 'Login' button - PASS \n";
    }
	sleep(3);
	
    $ses_Selenium->switchToFrameName(-name => "mainframe");

    $element = "//font[normalize-space\(\)='Find']";
    unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
        $logger->error(__PACKAGE__ . ": Failed to Login CIM");
        print FH "STEP: Login CIM - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login CIM - PASS \n";
    }

Check subcriber
    $button = "//font[normalize-space\(\)='Find']";
    unless ($ses_Selenium->clickElement(-xPath => $button)) {
        $logger->error(__PACKAGE__ . ": Failed to click 'Find' button");
        print FH "STEP: Click 'Find' button - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Click 'Find' button - PASS \n";
    }
    sleep(2);

    $textbox = "//input[\@name='findPhoneNumber']";
    $value = $list_dn[2];
    unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
        $logger->error(__PACKAGE__ . ": Failed to send '$value' to findPhoneNumber texbox" );
        print FH "STEP: Input '$value' to find - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Input '$value' to find - PASS \n";
    }

    $button = "//input[\@name='FindPhone'][\@type='BUTTON']";
    unless ($ses_Selenium->clickElement(-xPath => $button)) {
        $logger->error(__PACKAGE__ . ": Failed to click 'Find' phone number button");
        print FH "STEP: click 'Find' phone number button - FAIL \n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: click 'Find' phone number button - PASS \n";
    }
	sleep(3);

    $element = "//font[normalize-space\(\)='\(Subscriber Found\)']";
    unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
        $logger->debug(__PACKAGE__ . ": Subscriber $list_dn[2] is not found - need to add new");
    } else {
        print FH "STEP: Subscriber $list_dn[2] is added successfully - PASS \n";
        $add_subcriber = 1;
    }

Add new subcriber if line has not yet registered
    unless ($add_subcriber) {
    # Step 1: Select Offer
        $button = "//font[normalize-space\(\)='Add']";
        unless ($ses_Selenium->clickElement(-xPath => $button)) {
            $logger->error(__PACKAGE__ . ": Failed to click 'Add' button");
            print FH "STEP: Click 'Add' button - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Click 'Add' button - PASS \n";
        }

        $element = "//select[\@id='offerMenu'][\@name='offer']";
        unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
            $logger->error(__PACKAGE__ . ": Registration Offer menu has not existed");
            print FH "STEP: Registration Offer menu appears - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Registration Offer menu appears - PASS \n";
        }

        $element = "//select[\@id='offerMenu'][\@name='offer']";
        unless ($ses_Selenium->selectByVisibleText(-xPath => $element, -visibleText => "CIM Proto VM")) {
            $logger->error(__PACKAGE__ . ": Failed to select CIM Proto VM");
            print FH "STEP: Select CIM Proto VM - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Select CIM Proto VM - PASS \n";
        }

        $button = "//input[\@value='Next'][\@name='NEXT']";
        $ses_Selenium->clickElement(-xPath => $button);    
        sleep(3);

        $element = "//font[normalize-space\(\)='\(Step 2 - Enter Subscriber Information\)']";
        unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
            $logger->error(__PACKAGE__ . ": Failed to click 'Next' button");
            print FH "STEP: Click 'Next' button - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Click 'Next' button - PASS \n";
        }

    # Step 2: Enter Subscriber Information
        $textbox = "//input[\@name='custLastName'][\@class='inputs']";
        $value = $list_dn[2];
        unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
            $logger->error(__PACKAGE__ . ": Failed to send '$value' to last name texbox" );
            print FH "STEP: Input '$value' for last name - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Input '$value' for last name - PASS \n";
        }

        $textbox = "//input[\@name='cfbnaNumber'][\@class='inputs']";
        $value = $list_dn[2];
        unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
            $logger->error(__PACKAGE__ . ": Failed to send '$value' to phone number texbox" );
            print FH "STEP: Input '$value' for phone number - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Input '$value' for phone number - PASS \n";
        }

        $element = "//select[\@class='inputs'][\@name='switchId']";
        unless ($ses_Selenium->selectByVisibleText(-xPath => $element, -visibleText => "TMA15")) {
            $logger->error(__PACKAGE__ . ": Failed to select TMA15 for Switch");
            print FH "STEP: Select TMA15 for Switch - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Select TMA15 for Switch - PASS \n";
        }

        $textbox = "//input[\@name='pin'][\@class='inputs']";
        $value = '1234';
        unless ($ses_Selenium->inputText(-xPath => $textbox, -text => $value)) {
            $logger->error(__PACKAGE__ . ": Failed to send '$value' to pin texbox" );
            print FH "STEP: Input '$value' for PIN - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Input '$value' for PIN - PASS \n";
        }

        $button = "//input[\@value='Next'][\@name='NEXT']";
        $ses_Selenium->clickElement(-xPath => $button);    
        sleep(3);

        $element = "//font[normalize-space\(\)='\(Step 3 - Summary\)']";
        unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
            $logger->error(__PACKAGE__ . ": Failed to click 'Next' button");
            print FH "STEP: Click 'Next' button - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Click 'Next' button - PASS \n";
        }

    # Step 3: Summary
        $button = "//input[\@value='Create Account'][\@name='NEXT']";
        $ses_Selenium->clickElement(-xPath => $button);  
        sleep(3);

        $element = "//font[normalize-space\(\)='\(Confirmation\)']";
        unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
            $logger->error(__PACKAGE__ . ": Failed to click 'Create Account' button");
            print FH "STEP: Click 'Create Account' button - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Click 'Create Account' button - PASS \n";
        }

        $button = "//input[\@value='GoTo'][\@name='AGAIN']";
        $ses_Selenium->clickElement(-xPath => $button);   
        sleep(3);

        $element = "//font[normalize-space\(\)='\(Subscriber Found\)']";
        unless ($ses_Selenium->elementShouldExisted(-xPath => $element)) {
            $logger->error(__PACKAGE__ . ": Failed to click 'Go to' button");
            print FH "STEP: Click 'Go to' button - FAIL \n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Click 'Go to' button - PASS \n";
        }
    }

########################### Done Subcribe voicemail #################################
# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CXR to line B, add CFD to line C
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

    unless ($ses_core->callFeature(-featureName => "CFD N $deposit_num", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[2]");
		print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C then onhook
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(12); # wait for CFD timeout

# A leave a message and LEA D can monitor
    # A press #
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A cannot press \#");
    }
    
    # LEA D can monitor when A leave message on voice mail
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor when A leave message on voice mail");
        print FH "STEP: LEA D can monitor when A leave message on voice mail - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor when A leave message on voice mail - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at Press \# to end message");
        print FH "STEP: Press \# to end message - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Press \# to end message - PASS\n";
    }
    sleep(2);

    # A press # then onhook
    %input = (
                -line_port => $list_line[0],
                -dialed_number => '#',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A cannot press \#");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: A press # and onhook - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A press # and onhook - PASS\n";
    }

################################## Cleanup 018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 018 ##################################");

    # Take screen shot
    # sleep(3);
    # unless ($ses_Selenium->takeScreenshot(-sessionId => $sessionId, -localUrl => $localUrl, -path => $Image_Path, -ip => $ats_ip, -username => $ats_usrname, -password => $ats_passwd)) {
    #     $logger->error(__PACKAGE__ . ": Failed to take screenshot " );
    #     print FH "STEP: Take screenshot - FAIL \n";
    # } else {
    #     print FH "STEP: Take screenshot  - PASS \n";
    # }

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
        if (grep /CXR|CFD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLING DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CXR from line B, CFD from line C
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }
    if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
            print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_019";
    $tcid = "ADQ771_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[2] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C monitor the call between A and B - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_020");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_020";
    $tcid = "ADQ771_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CXR to line B
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C then onhook
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
    sleep(8);

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);

# Offhook C and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CXR from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_021 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_021");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_021";
    $tcid = "ADQ771_021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_sipt'}{-acc};
    my $trunk_region = $db_trunk{'t15_sipt'}{-region};
    my $trunk_clli = $db_trunk{'t15_sipt'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
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

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via SST and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and check speech path");
        print FH "STEP: A calls B via SST and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and check speech path - PASS\n";
    }

# Check line C Ring and offhook
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

# LEA C can monitor the call between A and B via SST
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B via SST");
        print FH "STEP: LEA can monitor the call between A and B via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B via SST - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_022 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_022");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_022";
    $tcid = "ADQ771_022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via PRI and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI and check speech path");
        print FH "STEP: A calls B via PRI and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via PRI and check speech path - PASS\n";
    }

# LEA C cannot monitor the call between A and B via PRI
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C still ring");
        print FH "STEP: LEA C cannot monitor the call between A and B via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C cannot monitor the call between A and B via PRI - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        $list_dn[2] =~ /\d{3}(\d+)/;
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_023 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_023");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_023";
    $tcid = "ADQ771_023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE SW $dialed_num y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP and check speech path");
        print FH "STEP: A calls B via ISUP and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP and check speech path - PASS\n";
    }

# Check line C Ring and offhook
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

# LEA C can monitor the call between A and B via ISUP
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B via ISUP");
        print FH "STEP: LEA can monitor the call between A and B via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B via ISUP - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_024 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_024");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_024";
    $tcid = "ADQ771_024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $mdn_added = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# Add MDN to line B as primary, Line D as member
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca y y $list_dn[1] tone y 12 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: add MDN to line $list_dn[1] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[1] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[3] mdn sca n y $list_dn[1] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[3]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[3]' ");
        print FH "STEP: add MDN to line $list_dn[3] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[3] as member - PASS\n";
    }
    $mdn_added = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[2] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B, B and D ring
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    $dialed_num = $list_dn[1];
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

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
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
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }

# B answer and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    sleep(2);

    # Check speech path line A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# D offhook and check speech path among A, B, D
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # Check speech path among A, B, D
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path among A, B, D");
        print FH "STEP: Check speech path among A, B, D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path among A, B, D - PASS\n";
    }

# LEA C can monitor the call among A, B and D
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[3]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call among A, B and D");
        print FH "STEP: LEA C monitor the call among A, B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C monitor the call among A, B and D - PASS\n";
    }

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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove MDN from line B and D
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[3] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[3] from MDN group");
            print FH "STEP: remove line $list_dn[3] from MDN group - FAIL\n";
        } else {
            print FH "STEP: remove line $list_dn[3] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[1] mdn $list_dn[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[1] - PASS\n";
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

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_025 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_025");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_025";
    $tcid = "ADQ771_025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE DE $list_dn[2] $list_dn[3] y y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor outgoing of line A
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A");
        print FH "STEP: LEA C can monitor outgoing of line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A - PASS\n";
    }

# LEA D can monitor incoming of line A
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A");
        print FH "STEP: LEA D can monitor incoming of line A- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A - PASS\n";
    }

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_026 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_026");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_026";
    $tcid = "ADQ771_026";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_sipt'}{-acc};
    my $trunk_region = $db_trunk{'t15_sipt'}{-region};
    my $trunk_clli = $db_trunk{'t15_sipt'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via SST and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and check speech path");
        print FH "STEP: A calls B via SST and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via SST
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via SST");
        print FH "STEP: LEA C can monitor outgoing of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via SST - PASS\n";
    }

# LEA D can monitor incoming of line A via SST
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via SST");
        print FH "STEP: LEA D can monitor incoming of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via SST - PASS\n";
    }

################################## Cleanup 026 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 026 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_027 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_027");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_027";
    $tcid = "ADQ771_027";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_isup'}{-acc};
    my $trunk_region = $db_trunk{'t15_isup'}{-region};
    my $trunk_clli = $db_trunk{'t15_isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via ISUP and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP and check speech path");
        print FH "STEP: A calls B via ISUP and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via ISUP
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via ISUP");
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via ISUP - PASS\n";
    }

# LEA D can monitor incoming of line A via ISUP
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via ISUP");
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via ISUP - PASS\n";
    }

################################## Cleanup 027 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 027 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_028 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_028");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_028";
    $tcid = "ADQ771_028";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;

################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via PRI and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI and check speech path");
        print FH "STEP: A calls B via PRI and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via PRI and check speech path - PASS\n";
    }

# LEA C, D cannot monitor incoming, outgoing side of line A via PRI
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C still ring");
        print FH "STEP: LEA C cannot monitor outgoing of line A via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C cannot monitor outgoing of line A via PRI - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    if ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D still ring");
        print FH "STEP: LEA D cannot monitor outgoing of line A via PRI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D cannot monitor outgoing of line A via PRI - PASS\n";
    }

################################## Cleanup 028 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 028 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_029 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_029");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_029";
    $tcid = "ADQ771_029";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[2] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C monitor the call between A and B - PASS\n";
    }

################################## Cleanup 029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 029 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[2], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[2]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_030 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_030");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_030";
    $tcid = "ADQ771_030";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE DE $list_dn[2] $list_dn[3] y y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[2], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[2]");
    #     print FH "STEP: C hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: C hear C-tone - PASS\n";
    # }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path - PASS\n";
    }

# LEA C can monitor outgoing of line A
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A");
        print FH "STEP: LEA C can monitor outgoing of line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A - PASS\n";
    }

# LEA D can monitor incoming of line A
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A");
        print FH "STEP: LEA D can monitor incoming of line A- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A - PASS\n";
    }

################################## Cleanup 030 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 030 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_031 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_031");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_031";
    $tcid = "ADQ771_031";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add CXR to line B
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and check speech path then B Flash
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path then B flash");
        print FH "STEP: A calls B and check speech path then B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then B flash - PASS\n";
    }

# B calls C then onhook
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears recall dial tone - PASS\n";
    }
    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
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
    sleep(8);

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);

# Offhook C and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

################################## Cleanup 031 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 031 ##################################");

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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove CXR from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_032 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_032");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_032";
    $tcid = "ADQ771_032";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_sipt'}{-acc};
    my $trunk_region = $db_trunk{'t15_sipt'}{-region};
    my $trunk_clli = $db_trunk{'t15_sipt'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, $dialed_num1, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change LCC of LEA into 1FR (Line C and D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA C into 1FR (Line $list_dn[2]) - PASS\n";
    }
    $change_lcc = 1;
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;

    ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    ($dialed_num1) = ($list_dn[3] =~ /\d{3}(\d+)/);
    $dialed_num1 = $trunk_access_code . $dialed_num1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE PAIRED LINE SW $dialed_num $dialed_num1 y $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");
    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B via SST and check speech path
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => [$detect,'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and check speech path");
        print FH "STEP: A calls B via SST and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and check speech path - PASS\n";
    }

# Check line C and D Ring then offhook C and D
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

# LEA C can monitor outgoing of line A via SST
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor outgoing of line A via SST");
        print FH "STEP: LEA C can monitor outgoing of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor outgoing of line A via SST - PASS\n";
    }

# LEA D can monitor incoming of line A via SST
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor incoming of line A via SST");
        print FH "STEP: LEA D can monitor incoming of line A via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor incoming of line A via SST - PASS\n";
    }

################################## Cleanup 032 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 032 ##################################");

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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[3]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback LCC into IBN");
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback LCC to IBN - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_033 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_033");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_033";
    $tcid = "ADQ771_033";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $line_c_info = "IBN AUTO_GRP 0 0 NILLATA 0";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[1] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my ($cust_grp) = ($list_line_info[1] =~ /\w+\s(\w+)\s/);
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
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

# Datafill in table CUSTSTN
    unless (grep/CUSTSTN/, $ses_core->execCmd("table CUSTSTN")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table CUSTSTN'");
    }
    
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $cust_grp DRING DRING")) {
        @output = $ses_core->execCmd("add $cust_grp DRING DRING Y 2 Y 3 ALL 5 N N Y 1 N Y 5 N");
    } else {
        @output = $ses_core->execCmd("rep $cust_grp DRING DRING Y 2 Y 3 ALL 5 N N Y 1 N Y 5 N");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /DRING/, $ses_core->execCmd("pos $cust_grp DRING DRING")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill $cust_grp DRING DRING in table CUSTSTN");
        print FH "STEP: Datafill $cust_grp DRING DRING in table CUSTSTN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill $cust_grp DRING DRING in table CUSTSTN - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Change CUSTGRP of Line C into AUTO_GRP (Line C)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[2], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $line_c_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] cannot change custgrp into auto_grp");
        print FH "STEP: Change CUSTGRP of Line C into AUTO_GRP (Line $list_dn[2]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change CUSTGRP of Line C into AUTO_GRP (Line $list_dn[2]) - PASS\n";
    }

# Add DRING to line B
    unless ($ses_core->callFeature(-featureName => "DRING Y 5 Y 2 ALL 2 N N N Y 4 N Y 5", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add DRING for line $list_dn[1]");
		print FH "STEP: add DRING for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DRING for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[1] NILC NILLATA",
            "SURV ADD DN $list_dn[1] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# A calls B and they have speech path
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
                -ring_on => [1400,500,1000],
                -ring_off => [600,500,2000],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

# LEA D can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and B");
        print FH "STEP: LEA D monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and B - PASS\n";
    }

# Hang up line A and B
    foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
    sleep(2);

# C calls B and they have speech path
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
                -ring_on => [1450,500,1000],
                -ring_off => [550,500,2000],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls B and they have speech path");
        print FH "STEP: C calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls B and they have speech path - PASS\n";
    }

# LEA D can monitor the call between C and B
    %input = (
                -list_port => [$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between C and B");
        print FH "STEP: LEA D monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between C and B - PASS\n";
    }

################################## Cleanup 033 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 033 ##################################");

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
        if (grep /DRING/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[2]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove DRING from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'DRING', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DRING from line $list_dn[1]");
            print FH "STEP: Remove DRING from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove DRING from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback Line C and D
    if ($change_lcc) {
        for (my $i = 2; $i <= $#list_dn; $i++){
            %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[$i], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[$i]
                    );
            unless ($ses_core->resetLine(%input)) {
                $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] cannot rollback to IBN and NY_PUB");
                print FH "STEP: Line $list_dn[$i] rollback to IBN and NY_PUB - FAIL\n";
            } else {
                print FH "STEP: Line $list_dn[$i] rollback to IBN and NY_PUB - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_034 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_034");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_034";
    $tcid = "ADQ771_034";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineA = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $rag_code = 86;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }
    
    if (grep /NOT FOUND/, $ses_core->execCmd("pos FEATXLA $rag_code")) {
        @output = $ses_core->execCmd("add FEATXLA $rag_code FEAT N N RAG");
    } else {
        @output = $ses_core->execCmd("rep FEATXLA $rag_code FEAT N N RAG");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /RAG/, $ses_core->execCmd("pos FEATXLA $rag_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill FEATXLA $rag_code in table IBNXLA");
        print FH "STEP: Datafill FEATXLA $rag_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill FEATXLA $rag_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add RAG to line A and CXR to line B
    unless ($ses_core->callFeature(-featureName => "RAG", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add RAG for line $list_dn[0]");
		print FH "STEP: add RAG for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add RAG for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# B calls C and they have speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and they have speech path");
        print FH "STEP: B calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path - PASS\n";
    }

# A calls B and hears BUSY tone then A flash
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => "$list_dn[1]\#",
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and hears BUSY tone then A flash");
        print FH "STEP: A calls B and hears BUSY tone then A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and hears BUSY tone then A flash - PASS\n";
    }

# A dials RAG code and hear confirmation tone then onhook
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hear recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear recall dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = '*' . $rag_code;
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

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear confirmation tone - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

# Hang up line C and B
    foreach (@list_line[1..2]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
    sleep(2);

# A rings and offhook, then B rings
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line A does not ring");
        print FH "STEP: Check line A ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(3);

    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line B does not ring");
        print FH "STEP: Check line B ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring - PASS\n";
    }

# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# B flash and calls C then onhook
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_dn[1]");
        print FH "STEP: B Flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B Flash - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        $result = 0;
        goto CLEANUP;
    }
    $list_dn[2] =~ /\d{3}(\d+)/;
    $dialed_num = $trunk_access_code . $1 . '#';
    %input = (
                -line_port => $list_line[1], # Line B
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
    sleep(3);
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }

# Offhook C and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

################################## Cleanup 034 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 034 ##################################");

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
        if (grep /RAG|CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove RAG from line A and CXR from line B
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'RAG', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove RAG from line $list_dn[0]");
            print FH "STEP: Remove RAG from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove RAG from line $list_dn[0] - PASS\n";
        }
    }
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
}

sub ADQ771_035 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ771_035");

########################### Variables Declaration #############################
    my $sub_name = "ADQ771_035";
    $tcid = "ADQ771_035";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ771");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    my $trunk_region = $db_trunk{'t15_pri'}{-region};
    my $trunk_clli = $db_trunk{'t15_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineA = 0;
    my $add_feature_lineB = 0;
    my $add_surv = 0;
    my $change_lcc = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $lea_info = "302 212_IBN L212_IBN";
    my $agency = "TAI_AGENCY";
    my $ccr_id = 750;
    my ($surv_name) = ($list_dn[0] =~ /\d{6}(\d+)/);
    $surv_name = 'TAI'. $surv_name;
    my $rag_code = 86;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&usnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_usnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_usnbd->loginCore(-username => [$li_user], -password => [$li_pass])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core for LI");
        print FH "STEP: Login TMA15 core for LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for LI - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }
    
    if (grep /NOT FOUND/, $ses_core->execCmd("pos FEATXLA $rag_code")) {
        @output = $ses_core->execCmd("add FEATXLA $rag_code FEAT N N RAG");
    } else {
        @output = $ses_core->execCmd("rep FEATXLA $rag_code FEAT N N RAG");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /RAG/, $ses_core->execCmd("pos FEATXLA $rag_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill FEATXLA $rag_code in table IBNXLA");
        print FH "STEP: Datafill FEATXLA $rag_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill FEATXLA $rag_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Change LCC of LEA into 1FR (Line D)
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[3], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $lea_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC into 1FR");
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change LCC of LEA D into 1FR (Line $list_dn[3]) - PASS\n";
    }
    $change_lcc = 1;

# Add RAG to line A and CXR to line B
    unless ($ses_core->callFeature(-featureName => "RAG", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add RAG for line $list_dn[0]");
		print FH "STEP: add RAG for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add RAG for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# LI provisioning
    unless(grep /USNBD/, $ses_usnbd->execCmd("USNBD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'USNBD'");
    }
    $add_surv = 1;
    @cmd = (
            "AGENCY ADD $agency 212 NYPUB L212 $list_dn[0] NILC NILLATA",
            "SURV ADD DN $list_dn[0] CaseId_TAI $surv_name Y Y N N N N $agency",
            "CCR ADD $ccr_id VOICE COMBINED LINE DE $list_dn[3] y n $agency",
            );
    @verify = (
                'AGENCY ADD DONE',
                'SURV ADD DONE',
                'CCR ADD DONE',
            );
    for (my $i = 0; $i <= $#cmd; $i++) {
        unless(grep /$verify[$i]/, $ses_usnbd->execCmd($cmd[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command '$cmd[$i]'");
            print FH "STEP: $cmd[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: $cmd[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
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

###################### Call flow ###########################
    # start PCM trace
    @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
# Assoc and activate LI
    $ses_usnbd->{conn}->print("CCR ASSOC $ccr_id $surv_name");

    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
        print FH "STEP: Check line D rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D rings - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    # %input = (
    #             -line_port => $list_line[3], 
    #             -freq1 => 1633,
    #             -freq2 => 852,
    #             -tone_duration => 25,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: cannot detect C-tone line $list_dn[3]");
    #     print FH "STEP: D hear C-tone - FAIL\n";
    # } else {
    #     print FH "STEP: D hear C-tone - PASS\n";
    # }

    unless($ses_usnbd->{conn}->waitfor(-match => '/>$/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot done command assoc");
        print FH "STEP: Assoc $ccr_id $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Assoc $ccr_id $surv_name - PASS\n";
    }

    unless(grep /SURV ACT DONE/, $ses_usnbd->execCmd("SURV ACT $surv_name")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'SURV ACT $surv_name'");
        print FH "STEP: Activate $surv_name - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Activate $surv_name - PASS\n";
    }

# B calls C and they have speech path
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and they have speech path");
        print FH "STEP: B calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path - PASS\n";
    }

# A calls B and hears BUSY tone then A flash
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => "$list_dn[1]",
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and hears BUSY tone then A flash");
        print FH "STEP: A calls B and hears BUSY tone then A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and hears BUSY tone then A flash - PASS\n";
    }

# A dials RAG code and hear confirmation tone then onhook
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hear recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear recall dial tone - PASS\n";
    }

    # $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 624,
                -freq2 => 478,
                -tone_duration => 25,
                -cas_timeout => 50000,
                );
    $ses_glcas->startDetectSpecifiedToneCAS(%input);

    $dialed_num = '*' . $rag_code;
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
    sleep(2);

    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
    #     $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
    #     print FH "STEP: A hear confirmation tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hear confirmation tone - PASS\n";
    # }

    unless ($ses_glcas->stopDetectSpecifiedToneCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hear confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear confirmation tone - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

# Hang up line C and B
    foreach (@list_line[1..2]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
    sleep(2);

# A rings and offhook, then B rings
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line A does not ring");
        print FH "STEP: Check line A ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ring - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(3);

    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line B does not ring");
        print FH "STEP: Check line B ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring - PASS\n";
    }

# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# B flash and calls C then onhook
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_dn[1]");
        print FH "STEP: B Flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B Flash - PASS\n";
    }

    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
        $result = 0;
        goto CLEANUP;
    }
    $list_dn[2] =~ /\d{3}(\d+)/;
    $dialed_num = $trunk_access_code . $1 . '#';
    %input = (
                -line_port => $list_line[1], # Line B
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
    sleep(3);
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }

# Offhook C and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# LEA D can monitor the call between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D monitor the call between A and C");
        print FH "STEP: LEA D monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D monitor the call between A and C - PASS\n";
    }

################################## Cleanup 035 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 035 ##################################");

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
        if (grep /RAG|CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("open amab;back all");
        unless ((grep /CALLING DN.*$list_dn[0]/, @output) and (grep /CALLING DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[1]/, @output) and (grep /CALLED DN.*$list_dn[2]/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: missing AMAB in logutil");
            $result = 0;
            print FH "STEP: Check AMAB - FAIL\n";
        } else {
            print FH "STEP: Check AMAB - PASS\n";
        }
    }

    # Rollback LI
    if ($add_surv) {
        @cmd = (
                "SURV DEACT $surv_name",
                "CCR DISASSOC $ccr_id",
                "CCR DEL $ccr_id",
                "SURV DEL $surv_name",
                "AGENCY DEL $agency",
                );
        foreach (@cmd) {
            unless($ses_usnbd->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command '$_'");
                print FH "STEP: $_ - FAIL\n";
            } else {
                print FH "STEP: $_ - PASS\n";
            }
        }
    }

    # Remove RAG from line A and CXR from line B
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'RAG', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove RAG from line $list_dn[0]");
            print FH "STEP: Remove RAG from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove RAG from line $list_dn[0] - PASS\n";
        }
    }
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }

    # Rollback LCC of LEA to IBN
    if ($change_lcc) {
        %input = (
                        -function => ['OUT','NEW'],
                        -lineDN => $list_dn[3], 
                        -lineType => '', 
                        -len => '', 
                        -lineInfo => $list_line_info[3]
                    );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[3] cannot change LCC of LEA into IBN");
            print FH "STEP: Rollback LCC of LEA to IBN - FAIL\n";
        } else {
            print FH "STEP: Rollback LCC of LEA to IBN - PASS\n";
        }
    }

    close(FH);
    &ADQ771_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ771_checkResult($tcid, $result);
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