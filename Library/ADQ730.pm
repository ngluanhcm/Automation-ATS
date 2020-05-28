#**************************************************************************************************#
#FEATURE                : <ADQ730> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Tai Nguyen Huu>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ730::ADQ730; 

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
our ($ses_core, $ses_glcas, $ses_logutil, $ses_tapi, $ses_swact, $ses_dnbd);
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
our @cas_server = ('10.250.185.232', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';
our $audio_gwc = 15;
our $audio_gwc_ip = '10.250.24.40';
our $tapilog_dir = '/home/ptthuy/Tapitrace/';
our $li_core_user = 'cuong';
our $li_core_pass = 'cuong';
our $dnbd_pass = 'cuong1';
our $li_group_id = 'xuyen';

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};

##################### Line V5.2 ###########################
our @db_list_dn_v52 = (4005007123, 4005007124, 4005007122);
our @db_list_line_v52 = (3, 4, 32);
our @db_list_region_v52 = ('US','US','US');
our @db_list_len_v52 = ('V52   01 0 00 23','V52   01 0 00 24','V52   01 0 00 22');
our @db_list_line_info_v52 = ('IBN AUTO_GRP 0 0','IBN AUTO_GRP 0 0','IBN RESTP 0 0');

##################### Line SIP ###########################
our @db_list_dn_sip = (4005003151,4005003162);
our @db_list_line_sip = (23, 12);
our @db_list_region_sip = ('US','US');
our @db_list_len_sip = ('SL16   00 0 01 51','SL16   00 0 01 62');
our @db_list_line_info_sip = ('IBN AUTO_GRP 0 0','IBN AUTO_GRP 0 0');

##################### Line NCS ###########################
our @db_list_dn_ncs = (4005007701);
our @db_list_line_ncs = (24);
our @db_list_region_ncs = ('US');
our @db_list_len_ncs = ('T900   00 0 00 02');
our @db_list_line_info_ncs = ('IBN AUTO_GRP 0 0');

##################### Line ABI ###########################
our @db_list_dn_abi = (4005004002,4005004003);
our @db_list_line_abi = (10, 11);
our @db_list_region_abi = ('US','US');
our @db_list_len_abi = ('HOST   02 0 00 02','HOST   02 0 00 03');
our @db_list_line_info_abi = ('IBN AUTO_GRP 0 0', 'IBN AUTO_GRP 0 0');

#################### Trunk info ###########################
our %db_trunk = (
                'isup' =>{
                                -acc => 105,
                                -region => 'US',
                                -clli => 'T20G6E1C7ETSI2W',
                            },
                'g9_pri' => {
                                -acc => 407,
                                -region => 'US',
                                -clli => 'T20G9ETSIPRI22W',
                            },
                'cas_r2' => {
                                -acc => 917,
                                -region => 'US',
                                -clli => 'CASG9_TRAF_2W',
                            },
                'sst' => {
                                -acc => 872,
                                -region => 'US',
                                -clli => 'T20SSTBASEV1LP',
                            },
                'etsi_pri' => {
                                -acc => 101,
                                -region => 'US',
                                -clli => 'G6STMETSIPRI2W',
                            },
                'qsig_pri' => {
                                -acc => 416,
                                -region => 'US',
                                -clli => 'DEMO_PRIINTL2W',
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

sub ADQ730_cleanup {
    my $subname = "ADQ730_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, 
                    $ses_tapi, $ses_swact, $ses_dnbd,
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ730_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ730_checkResult";
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

sub ADQ730_datafill {
    my $tcid = "ADQ730_datafill";
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
        foreach my $cust_grp ('FETCEPT','AUTO_GRP','RESTP') {
            if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table PXCODE")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'table PXCODE'");
            }
            unless ($ses_core->execCmd("rwok on")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
            }
            $tuple = "$cust_grp $db_trunk{$trk}{-acc} $db_trunk{$trk}{-acc} RTE DEST $db_trunk{$trk}{-acc} \$";
            if (grep /NOT FOUND/, $ses_core->execCmd("pos $cust_grp $db_trunk{$trk}{-acc} $db_trunk{$trk}{-acc}")) {
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
            $tuple = "$cust_grp $db_trunk{$trk}{-acc} T OFRT $db_trunk{$trk}{-acc} \$";
            if (grep /NOT FOUND/, $ses_core->execCmd("pos $cust_grp $db_trunk{$trk}{-acc}")) {
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

# Datafill TMA20 in table MNETIDS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETIDS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETIDS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos TMA20")) {
        if (grep /ERROR/, $ses_core->execCmd("add TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'TMA20'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort;quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
    }

# Datafill necessary tuple in their own table
    %input = (
                'MNETOFC' => 'AMA_SENSOR_ID TMA20 123456',
                'ISERVOPT' => 'CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y $ Y N N',
                'NCOS' => 'RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT',
                'OFCENG' => 'OFFICE_ID_ON_AMA_TAPE 000000',
                'OFCENG' => 'AMA_SENSOR_ID 000000',
                'CUSTENG' => 'RESTP 3001 512 63 N PUBLIC 3001 CONF6C 4',
                'LINEATTR' => 'RESTP IBN NONE NT 0 0 NILSFC 0 PX RESTP NIL 00 LCABILL',
                'AUTHCDE' => 'AUTO_GRP 1234 IBN 0 Y $ SW $',
            );
    foreach (keys %input) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table $_")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table $_'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        if (grep /NOT FOUND/, $ses_core->execCmd("pos $input{$_}")) {
            if (grep /ERROR/, $ses_core->execCmd("add $input{$_}")) {
                $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple '$input{$_}'");
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

# Disable AMA for SDM
    unless ($ses_core->execCmd("toolsup")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'toolsup'");
    }
    if (grep /Please confirm/, $ses_core->execCmd("reset SDMBCTRL")) {
        $ses_core->execCmd("Y");
    } else {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'reset SDMBCTRL'");
    }
    unless ($ses_core->execCmd("abort;quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
    }
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot disable AMA in SDM mode");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

# CLEANUP
    &ADQ730_cleanup();
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

sub glcas {
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
    return $ses_glcas;
}

sub logutil {
    sleep (2);
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }
    return $ses_logutil;
}

sub tapi {
    sleep(4);
    unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASS\n";
    }
    return $ses_tapi;
}

sub swact {
    sleep(6);
    unless ($ses_swact = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_SwactSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for swact - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for swact - PASS\n";
    }
    return $ses_swact;
}

sub dnbd {
    sleep(4);
    unless ($ses_dnbd = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_DNBDSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for DNBD - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for DNBD - PASS\n";
    }
    return $ses_dnbd;
}
##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ730_datafill",
                    "ADQ730_001","ADQ730_002","ADQ730_003","ADQ730_004","ADQ730_005",
                    "ADQ730_006","ADQ730_007","ADQ730_008","ADQ730_009","ADQ730_010",
                    "ADQ730_011","ADQ730_012","ADQ730_013","ADQ730_014","ADQ730_015",
                    "ADQ730_016","ADQ730_017","ADQ730_018","ADQ730_019","ADQ730_020",
                    "ADQ730_021","ADQ730_022","ADQ730_023","ADQ730_024","ADQ730_025",
					"ADQ730_026","ADQ730_027","ADQ730_028","ADQ730_029","ADQ730_030",
					"ADQ730_031","ADQ730_032","ADQ730_033","ADQ730_034","ADQ730_035",
					"ADQ730_036","ADQ730_037","ADQ730_038","ADQ730_039","ADQ730_040",
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
# |   EO call service - R20 Sourcing Features - phase 2                          |
# |    (Multiple SensorID, DNROUTE & DNINV expansion, CEPT Special Dial tone)    |
# +------------------------------------------------------------------------------+
# |   ADQ730                                                                     |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Tai Nguyen ##########################
# W24

sub ADQ730_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_001");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_001";
    $tcid = "ADQ730_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_v52[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_v52[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_v52[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_v52[0], @db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT, I3WC and CFB to line A
    foreach ('CEPT','I3WC') {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfb_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFBP/) {
            $cfb_acc = $1;
        }
    }
    unless ($cfb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFB access code for line $list_dn[0]");
		print FH "STEP: get CFB access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFB access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y N N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y N N/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFB
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfb_acc . $list_dn[1] . '#';
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
    sleep (2);
    unless (grep /CFB.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFB for line $list_dn[0]");
        print FH "STEP: activate CFB for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFB for line $list_dn[0] - PASS\n";
    }

    # A calls C and they have speech path then A flashes
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
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C then A flashes");
        print FH "STEP: A calls C then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C then A flashes - PASS\n";
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
        if (grep /CFB/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    unless ($tapi_start) {
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/dt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message cg\/dt on tapi log - FAIL\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: check the message srvtn\/rdt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message srvtn\/rdt on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove I3WC, CFB and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFB','I3WC','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_002");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_002";
    $tcid = "ADQ730_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_v52[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_v52[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_v52[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_v52[0], @db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT, I3WC and CFU to line A
    foreach ('CEPT','I3WC',"CFU N") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfu_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFU/) {
            $cfu_acc = $1;
        }
    }
    unless ($cfu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFU access code for line $list_dn[0]");
		print FH "STEP: get CFU access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFU access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y N N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y N N/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFU
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
    sleep (2);
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[0] - PASS\n";
    }

    # A calls C and they have speech path then A flashes
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
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C then A flashes");
        print FH "STEP: A calls C then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C then A flashes - PASS\n";
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
        if (grep /CFU/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    unless ($tapi_start) {
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn.*rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/dt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message cg\/dt on tapi log - FAIL\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: check the message srvtn\/rdt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message srvtn\/rdt on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove I3WC, CFU and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFU','I3WC','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_003");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_003";
    $tcid = "ADQ730_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_v52[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_v52[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_v52[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_v52[0], @db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT, I3WC and CFD to line A
    foreach ('CEPT','I3WC',"CFD P") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfd_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFDP/) {
            $cfd_acc = $1;
        }
    }
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFD access code for line $list_dn[0]");
		print FH "STEP: get CFD access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y N N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y N N/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFD
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfd_acc . $list_dn[1] . '#';
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
    sleep (2);
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFD for line $list_dn[0]");
        print FH "STEP: activate CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[0] - PASS\n";
    }

    # A calls C and they have speech path then A flashes
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
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C then A flashes");
        print FH "STEP: A calls C then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C then A flashes - PASS\n";
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
        if (grep /CFD/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    my $exist2 = 1;
    unless ($tapi_start) {
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                if (grep /srvtn.*rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 0;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/dt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message cg\/dt on tapi log - FAIL\n";
            $result = 0;
        }
        unless ($exist2) {
            print FH "STEP: check the message srvtn\/rdt on tapi log - PASS\n";
        } else {
            print FH "STEP: check the message srvtn\/rdt on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove I3WC, CFD and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFD','I3WC','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_004");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_004";
    $tcid = "ADQ730_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT and CFD to line A
    foreach ('CEPT',"CFD P") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfd_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFDP/) {
            $cfd_acc = $1;
        }
    }
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFD access code for line $list_dn[0]");
		print FH "STEP: get CFD access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y Y Y/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFD
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfd_acc . $list_dn[1] . '#';
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
    sleep (2);
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFD for line $list_dn[0]");
        print FH "STEP: activate CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[0] - PASS\n";
    }

    # A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(5);

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
        if (grep /CFD/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /xcg\/spec/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/spec on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFD and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFD','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_005");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_005";
    $tcid = "ADQ730_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT and CFU to line A
    foreach ('CEPT',"CFU N") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfu_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFU/) {
            $cfu_acc = $1;
        }
    }
    unless ($cfu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFU access code for line $list_dn[0]");
		print FH "STEP: get CFU access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFU access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y Y Y/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFU
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
    sleep (2);
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[0] - PASS\n";
    }

    # A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(5);

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
        if (grep /CFU/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /xcg\/spec/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/spec on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFU and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFU','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_006");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_006";
    $tcid = "ADQ730_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT and CFB to line A
    foreach ("CEPT") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my $cfb_acc;
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFBP/) {
            $cfb_acc = $1;
        }
    }
    unless ($cfb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFB access code for line $list_dn[0]");
		print FH "STEP: get CFB access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFB access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y Y Y/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # Line A activates CFB
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfb_acc . $list_dn[1] . '#';
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
    sleep (2);
    unless (grep /CFB.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFB for line $list_dn[0]");
        print FH "STEP: activate CFB for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFB for line $list_dn[0] - PASS\n";
    }

    # A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(5);

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
        if (grep /CFB/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /xcg\/spec/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/spec on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFB and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFB','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_007");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_007";
    $tcid = "ADQ730_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[0]);
    my @list_line = ($db_list_line_v52[0]);
    my @list_region = ($db_list_region_v52[0]);
    my @list_len = ($db_list_len_v52[0]);
    my @list_line_info = ($db_list_line_info_v52[0]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT and CDND to line A
    foreach ("CEPT",'CDND active') {
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

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y Y Y/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(5);

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
        if (grep /CDND/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /xcg\/spec/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/spec on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CDND and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CDND','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_008");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_008";
    $tcid = "ADQ730_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    my $thr5 = threads->create(\&swact);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();
    $ses_swact = $thr5->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Change custgrp of line A into FETCEPT
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust FETCEPT y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*FETCEPT/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp FETCEPT does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to FETCEPT - PASS\n";
    }
    $change_cust = 0;

# Add CEPT and CFB to line A
    foreach ("CEPT") {
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

    @output = $ses_core->getTableInfo(-table_name => 'PXCODE', -column_name => 'XLANAME', -column_value => 'STARCEPT');
    my ($cfb_acc, $cfb_deact_acc);
    foreach (@output) {
        if (/STARCEPT\s+(\d+)\s.*CFBP/) {
            $cfb_acc = $1;
        }
        if (/STARCEPT\s+(\d+)\s.*CFBC/) {
            $cfb_deact_acc = $1;
        }
    }
    unless ($cfb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFB access code for line $list_dn[0]");
		print FH "STEP: get CFB access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFB access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple CEPT_CFX in table ISERVOPT
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table ISERVOPT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table ISERVOPT'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep CEPT_CFX CEPT_CFX N 0 18 Y Y Y Y Y Y Y Y \$ Y Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple CEPT_CFX");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /\$ Y Y Y/, $ses_core->execCmd("pos CEPT_CFX")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos CEPT_CFX'");
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple CEPT_CFX in table ISERVOPT - PASS\n";
    }

# get GWC ID of line A
    %input = (
                -table_name => 'LGRPINV',
                -column_name => '',
                -column_value => $list_len[0], 
                );
    @output = $ses_core->getTableInfo(%input);
    my $gwc_id;
    foreach (@output) {
        if (/GWC\s+(\d+)/) {
            $gwc_id = $1;
            last;
        }
    }
    unless ($gwc_id) {
        $logger->error(__PACKAGE__ . " $tcid: cannot get GWC ID of line A");
        print FH "STEP: get GWC ID of line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get GWC ID of line A - PASS\n";
        $logger->debug(__PACKAGE__ . ".$sub_name: GWC of line A is $gwc_id");
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0],$list_dn[1]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

################################## Call flow ###################################

# Line A activates CFB
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfb_acc . $list_dn[1] . '#';
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
    sleep (2);
    unless (grep /CFB.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFB for line $list_dn[0]");
        print FH "STEP: activate CFB for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFB for line $list_dn[0] - PASS\n";
    }

# A offhook then onhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(10);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    sleep(2);

# verify message xcg/spec in tapi log
    my $exist1 = 0;
    unless ($tapi_start) {
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
                    if (/xcg\/spec/) {
                        $exist1++;
                    }
                }
            }
        }
        if ($exist1 == 1) {
            print FH "STEP: check the message xcg\/spec appears on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec appears on tapi log - FAIL\n";
            $result = 0;
        }
        $tapi_start = 1;
        $ses_tapi->DESTROY();
        undef $ses_tapi;
    }

# Warm swact GWC of line A
    $gwc_id = 'gwc' . $gwc_id;
    $ses_swact->execCmd("cli");
    @output = $ses_swact->execCmd("aim service-unit show $gwc_id");
    my $count = 0;
    foreach (@output) {
        if(/0\s+unlocked\s+enabled\s+in/) {
            $count++;
        }
        if(/1\s+unlocked\s+enabled\s+in/) {
            $count++;
        }
    }
    unless ($count == 2) {
        $logger->error(__PACKAGE__ . " $tcid: both units of $gwc_id may not be available");
        print FH "STEP: check GWC status before warm swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check GWC status before warm swact - PASS\n";
    }
    @output = $ses_swact->execCmd("aim si-assignment show $gwc_id");
    $count = 0;
    my $active_unit;
    foreach (@output) {
        if (/standby/) {
            $count++;
        }
        if (/$gwc_id\s+(\d)\s+.*\sactive/) {
            $active_unit = $1;
            $count++;
        }
    }
    unless ($count == 2 && $active_unit ne '') {
        $logger->error(__PACKAGE__ . " $tcid: missing unit of $gwc_id");
        print FH "STEP: check both GWC units before warm swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check both GWC units before warm swact - PASS\n";
    }
    unless ($ses_swact->execCmd("aim service-unit swact $gwc_id $active_unit", 120)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at warm swact $gwc_id");
        print FH "STEP: warm swact $gwc_id - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: warm swact $gwc_id - PASS\n";
    }

    my $time_out = 0;
    for (my $i = 0; $i < 12; $i++) {
        @output = $ses_swact->execCmd("aim si-assignment show $gwc_id");
        $count = 0;
        foreach (@output) {
            if (/standby/) {
                $count++;
            }
            if (/active/) {
                $count++;
            }
        }
        if ($count == 2) {
            $time_out = 1;
            last;
        }
        sleep (5);
    }
    unless ($time_out) {
        $logger->error(__PACKAGE__ . " $tcid: missing unit of $gwc_id after warm swact");
        print FH "STEP: check both GWC units after warm swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check both GWC units after warm swact - PASS\n";
    }

    $time_out = 0;
    for (my $i = 0; $i < 12; $i++) {
        @output = $ses_swact->execCmd("aim service-unit show $gwc_id");
        $count = 0;
        foreach (@output) {
            if(/0\s+unlocked\s+enabled\s+in/) {
                $count++;
            }
            if(/1\s+unlocked\s+enabled\s+in/) {
                $count++;
            }
        }
        if ($count == 2) {
            $time_out = 1;
            last;
        }
        sleep(5);
    }
    unless ($time_out) {
        $logger->error(__PACKAGE__ . " $tcid: both units of $gwc_id may not be available after warm swact");
        print FH "STEP: check GWC status after warm swact - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check GWC status after warm swact - PASS\n";
    }

# Start tapi trace
    unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASS\n";
    }
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0],$list_dn[1]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# A offhook again
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(10);

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
        if (grep /CFB/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Stop tapi
    $exist1 = 0;
    unless ($tapi_start) {
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
                    if (/xcg\/spec/) {
                        $exist1++;
                    }
                }
            }
        }
        if ($exist1 >= 1) {
            print FH "STEP: check the message xcg\/spec on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/spec' in tapi log");
            print FH "STEP: check the message xcg\/spec on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFB and CEPT from line A
    unless ($add_feature_lineA) {
        foreach ('CFB','CEPT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_009");
   
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_009";
    $tcid = "ADQ730_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'isup'}{-acc};
    my $trunk_region = $db_trunk{'isup'}{-region};
    my $trunk_clli = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    my $sensor_id2 = '000000';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of line A into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust RESTP y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to RESTP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to RESTP - PASS\n";
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change OFFICE_ID_ON_AMA_TAPE and AMA_SENSOR_ID in table OFCENG
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCENG'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep OFFICE_ID_ON_AMA_TAPE $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple OFFICE_ID_ON_AMA_TAPE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos OFFICE_ID_ON_AMA_TAPE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple OFFICE_ID_ON_AMA_TAPE");
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - PASS\n";
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos AMA_SENSOR_ID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - PASS\n";
    }

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Change ISUP trunk NWID in table TRKOPTS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TRKOPTS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TRKOPTS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        if (grep /ERROR/, $ses_core->execCmd("add $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TMA20/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple $trunk_clli NWID");
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B via ISUP trunk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
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
    my $out_str;
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
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id2.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id2");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id2 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id2 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_010");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_010";
    $tcid = "ADQ730_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g9_pri'}{-acc};
    my $trunk_region = $db_trunk{'g9_pri'}{-region};
    my $trunk_clli = $db_trunk{'g9_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    my $sensor_id2 = '000000';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of line A into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust RESTP y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to RESTP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to RESTP - PASS\n";
    }
    $change_cust = 0;

# Datafill tuple RESTP in table CUSTENG
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table CUSTENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table CUSTENG'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 3001 512 63 N PUBLIC 3001 \+");
    if (grep /ERROR/, $ses_core->execCmd("CONF6C 4 NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP");
        print FH "STEP: Datafill tuple RESTP in table CUSTENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP in table CUSTENG - PASS\n";
    }
    $change_restp = 0;

# Change OFFICE_ID_ON_AMA_TAPE and AMA_SENSOR_ID in table OFCENG
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCENG'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep OFFICE_ID_ON_AMA_TAPE $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple OFFICE_ID_ON_AMA_TAPE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos OFFICE_ID_ON_AMA_TAPE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple OFFICE_ID_ON_AMA_TAPE");
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - PASS\n";
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos AMA_SENSOR_ID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - PASS\n";
    }

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Change PRI trunk NWID in table TRKOPTS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TRKOPTS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TRKOPTS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        if (grep /ERROR/, $ses_core->execCmd("add $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }

    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TMA20/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple $trunk_clli NWID");
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B via PRI trunk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['DELAY 8','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
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
    my $out_str;
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
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id2.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id2");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id2 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id2 - PASS\n";
        }
    }

    # remove option NWID from RESTP
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table CUSTENG")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table CUSTENG'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 3001 512 63 N PUBLIC 3001 \+");
        if (grep /ERROR/, $ses_core->execCmd("CONF6C 4 \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID from RESTP");
            print FH "STEP: remove NWID from RESTP in table CUSTENG - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: remove NWID from RESTP in table CUSTENG - PASS\n";
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_011");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_011";
    $tcid = "ADQ730_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    my $sensor_id2 = '000000';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of line A into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust RESTP y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to RESTP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to RESTP - PASS\n";
    }
    $change_cust = 0;

# Datafill tuple RESTP in table LINEATTR
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table LINEATTR")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table LINEATTR'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP IBN NONE NT 0 0 NILSFC 0 PX RESTP NIL 00 22_NPRT_1 NLCA_NILLA_0\+");
    if (grep /ERROR/, $ses_core->execCmd("LCABILL NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add NWID of RESTP");
        print FH "STEP: Datafill tuple RESTP in table LINEATTR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP in table LINEATTR - PASS\n";
    }
    $change_restp = 0;

# Change OFFICE_ID_ON_AMA_TAPE and AMA_SENSOR_ID in table OFCENG
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCENG'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep OFFICE_ID_ON_AMA_TAPE $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple OFFICE_ID_ON_AMA_TAPE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos OFFICE_ID_ON_AMA_TAPE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple OFFICE_ID_ON_AMA_TAPE");
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - PASS\n";
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos AMA_SENSOR_ID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - PASS\n";
    }

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Change SST trunk NWID in table TRKOPTS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TRKOPTS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TRKOPTS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        if (grep /ERROR/, $ses_core->execCmd("add $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }

    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TMA20/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple $trunk_clli NWID");
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B via SST trunk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['DELAY 8','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
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
    my $out_str;
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
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id2.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id2");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id2 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id2 - PASS\n";
        }
    }

    # Remove NWID in table LINEATTR
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table LINEATTR")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table LINEATTR'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP IBN NONE NT 0 NILSFC 0 PX RESTP NIL 00 \+");
        if (grep /ERROR/, $ses_core->execCmd("LCABILL \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP in table LINEATTR");
            print FH "STEP: Remove NWID in table LINEATTR - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table LINEATTR - PASS\n";
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_012");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_012";
    $tcid = "ADQ730_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'cas_r2'}{-acc};
    my $trunk_region = $db_trunk{'cas_r2'}{-region};
    my $trunk_clli = $db_trunk{'cas_r2'}{-clli};

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    my $sensor_id2 = '000000';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of line A into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust RESTP y y")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $list_dn[0]");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
		print FH "STEP: change Custgrp line $list_dn[0] to RESTP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change Custgrp line $list_dn[0] to RESTP - PASS\n";
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change OFFICE_ID_ON_AMA_TAPE and AMA_SENSOR_ID in table OFCENG
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCENG'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep OFFICE_ID_ON_AMA_TAPE $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple OFFICE_ID_ON_AMA_TAPE");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos OFFICE_ID_ON_AMA_TAPE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple OFFICE_ID_ON_AMA_TAPE");
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple OFFICE_ID_ON_AMA_TAPE in table OFCENG - PASS\n";
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID $sensor_id2")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id2/, $ses_core->execCmd("pos AMA_SENSOR_ID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID in table OFCENG - PASS\n";
    }

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Change CAS trunk NWID in table TRKOPTS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TRKOPTS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TRKOPTS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        if (grep /ERROR/, $ses_core->execCmd("add $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep $trunk_clli NWID NWID TMA20")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '$trunk_clli NWID'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }

    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TMA20/, $ses_core->execCmd("pos $trunk_clli NWID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple $trunk_clli NWID");
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple $trunk_clli NWID in table TRKOPTS - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B via CAS trunk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['DELAY 8','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
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
    my $out_str;
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
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id2.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id2");
            $result = 0;
            print FH "STEP: Check infomation in sensor id $sensor_id2 - FAIL\n";
        } else {
            print FH "STEP: Check infomation in sensor id $sensor_id2 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $list_dn[0] cust auto_grp y y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $list_dn[0]");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $list_dn[0]")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - FAIL\n";
        } else {
            print FH "STEP: change Custgrp line $list_dn[0] to AUTO_GRP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_013");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_013";
    $tcid = "ADQ730_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],$db_list_dn_abi[0]);
    my @list_line = (@db_list_line_v52[0..1],$db_list_line_abi[0]);
    my @list_region = (@db_list_region_v52[0..1],$db_list_region_abi[0]);
    my @list_len = (@db_list_len_v52[0..1],$db_list_len_abi[0]);
    my @list_line_info = (@db_list_line_info_v52[0..1],$db_list_line_info_abi[0]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of all lines into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    foreach (@list_dn) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust RESTP y y")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $_");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $_")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
            print FH "STEP: change Custgrp line $_ to RESTP - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: change Custgrp line $_ to RESTP - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Add 3WC to line B
    unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
        print FH "STEP: add 3WC for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[1] - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B and they have speechpath then B flashes
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # B calls C and they have speechpath then B flashes.
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and they have speech path then B flashes");
        print FH "STEP: B calls C and they have speech path then B flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path then B flashes - PASS\n";
    }
    sleep(10);

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
    my $out_str;
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
        if (grep /3WC/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[1]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
        }
    }

    # remove 3wc from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
            print FH "STEP: Remove 3WC from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[1] - PASS\n";
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        foreach (@list_dn) {
            if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust auto_grp y y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $_");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
            }
            unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $_")) {
                $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - FAIL\n";
            } else {
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_014");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_014";
    $tcid = "ADQ730_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],$db_list_dn_abi[0]);
    my @list_line = (@db_list_line_v52[0..1],$db_list_line_abi[0]);
    my @list_region = (@db_list_region_v52[0..1],$db_list_region_abi[0]);
    my @list_len = (@db_list_len_v52[0..1],$db_list_len_abi[0]);
    my @list_line_info = (@db_list_line_info_v52[0..1],$db_list_line_info_abi[0]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Change custgrp of all lines into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    foreach (@list_dn) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust RESTP y y")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $_");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $_")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
            print FH "STEP: change Custgrp line $_ to RESTP - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: change Custgrp line $_ to RESTP - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Add CFD to line B
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[1]");
        print FH "STEP: add CFD for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[1] - PASS\n";
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
    $logutil_start = 0;

# Call flow
    # A calls B and the call is forwarded to C
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 20','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
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
    my $out_str;
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
        if (grep /CFD/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[1]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
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

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        foreach (@list_dn) {
            if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust auto_grp y y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $_");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
            }
            unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $_")) {
                $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - FAIL\n";
            } else {
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_015");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_015";
    $tcid = "ADQ730_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],$db_list_dn_abi[0]);
    my @list_line = (@db_list_line_v52[0..1],$db_list_line_abi[0]);
    my @list_region = (@db_list_region_v52[0..1],$db_list_region_abi[0]);
    my @list_len = (@db_list_len_v52[0..1],$db_list_len_abi[0]);
    my @list_line_info = (@db_list_line_info_v52[0..1],$db_list_line_info_abi[0]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of all lines into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    foreach (@list_dn) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust RESTP y y")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $_");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $_")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
            print FH "STEP: change Custgrp line $_ to RESTP - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: change Custgrp line $_ to RESTP - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# Add CWT and CWI to line B
    foreach ('CWT','CWI') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag) {
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
    $logutil_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
    # B calls A and they have speech path
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
                -send_receive => ['DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

    # C calls B and B hears Call waiting tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
    }
    %input = (
                -line_port => $list_line[1],
                -callwaiting_tone_duration => 300,
                -cas_timeout => 20000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls B and B hears Call waiting tone");
        print FH "STEP: C calls B and B hears Call waiting tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls B and B hears Call waiting tone - PASS\n";
    }

    # B flashes and check speech path C and B
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and C ");
        print FH "STEP: B flashes, check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flashes, check speech path between B and C - PASS\n";
    }

    # B flashes and check speech path A and B
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
    }
    %input = (
                -list_port => [$list_line[1],$list_line[0]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and A ");
        print FH "STEP: B flashes, check speech path between B and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flashes, check speech path between B and A - PASS\n";
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
    sleep(5);
    my $out_str;
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
        if (grep /CWT|CWI/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[1]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[1] in sensor id $sensor_id1 - PASS\n";
        }
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[2]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[2] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[2] in sensor id $sensor_id1 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
        }
    }

    # remove CWT and CWI from line B
    unless ($add_feature_lineB) {
        foreach ('CWI','CWT') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        foreach (@list_dn) {
            if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust auto_grp y y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $_");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
            }
            unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $_")) {
                $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - FAIL\n";
            } else {
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_016");
   
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_016";
    $tcid = "ADQ730_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],$db_list_dn_abi[0]);
    my @list_line = (@db_list_line_v52[0..1],$db_list_line_abi[0]);
    my @list_region = (@db_list_region_v52[0..1],$db_list_region_abi[0]);
    my @list_len = (@db_list_len_v52[0..1],$db_list_len_abi[0]);
    my @list_line_info = (@db_list_line_info_v52[0..1],$db_list_line_info_abi[0]);

    my $wait_for_event_time = 30;
    my $change_cust = 1;
    my $change_restp = 1;
    my $add_feature_lineBC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
    my %info;
    my $sensor_id1 = '123456';
    
################## LOGIN ##############

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Disable SDM bill
    unless ($ses_core->execCmd("MAPCI;MTC;APPL;SDMBIL;POST AMA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot post AMA in SDM mode");
    }
    unless ($ses_core->execCmd("SDMBCTRL AMA OFF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command SDMBCTRL AMA OFF");
    }
    sleep(2);
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort;quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot quit SDM mode");
    }

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

# Change custgrp of all lines into RESTP
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    foreach (@list_dn) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust RESTP y y")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing custgrp of line $_");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /CUSTGRP.*RESTP/, $ses_core->execCmd("qdn $_")) {
            $logger->error(__PACKAGE__ . " $tcid: custgrp RESTP does not exist after changing");
            print FH "STEP: change Custgrp line $_ to RESTP - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: change Custgrp line $_ to RESTP - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
    $change_cust = 0;

# Datafill tuple RESTP in table NCOS
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
    if (grep /ERROR/, $ses_core->execCmd("NWID TMA20 \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change NWID of RESTP 0");
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple RESTP 0 in table NCOS - PASS\n";
    }
    $change_restp = 0;

# Change AMA_SENSOR_ID TMA20 in table MNETOFC
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MNETOFC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MNETOFC'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep AMA_SENSOR_ID TMA20 $sensor_id1")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple AMA_SENSOR_ID");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /$sensor_id1/, $ses_core->execCmd("pos AMA_SENSOR_ID TMA20")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple AMA_SENSOR_ID TMA20");
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple AMA_SENSOR_ID TMA20 in table MNETOFC - PASS\n";
    }

# add CPU to line B and line C
    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[1] $list_len[2] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[1] and $list_dn[2]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[1] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add CPU for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[3] - PASS\n";
    }
    $add_feature_lineBC = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'CPU');
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
    $logutil_start = 0;

# Call flow
    # A calls B and B does not go offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
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
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }

    # C dials CPU access code to pick up the call for B
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
    
    # Check speech path 
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C ");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
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
    my $out_str;
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
        if (grep /CPU/, $ses_logutil->execCmd("open swerr")) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
        @output = $ses_logutil->execCmd("calldump");
        $out_str = join("\n", @output);
        unless ($out_str =~ /SENSOR ID:0$sensor_id1.*\n.*\n.*\n.*ORIG OPEN DIGITS 1:0$list_dn[0]/) {
            $logger->error(__PACKAGE__ . " $tcid: wrong infomation in sensor id $sensor_id1");
            $result = 0;
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - FAIL\n";
        } else {
            print FH "STEP: Check line $list_dn[0] in sensor id $sensor_id1 - PASS\n";
        }
    }

    # Remove NWID in table NCOS
    unless ($change_restp) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table NCOS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table NCOS'");
        }
        unless ($ses_core->execCmd("rwok on")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
        }
        $ses_core->execCmd("rep RESTP 0 0 0 0 XLAS RESTP IADFET NDGT OCTXLA IADOCT \+");
        if (grep /ERROR/, $ses_core->execCmd("\$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple RESTP 0");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        if (grep /NWID TMA20/, $ses_core->execCmd("pos RESTP 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot remove NWID of RESTP 0");
            print FH "STEP: Remove NWID in table NCOS - FAIL\n";
        } else {
            print FH "STEP: Remove NWID in table NCOS - PASS\n";
        }
    }

    # remove CPU from line B and line C
    unless ($add_feature_lineBC) {
        foreach (@list_dn[1..2]) {
            unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $_, -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $_");
                print FH "STEP: Remove CPU from line $_ - FAIL\n";
            } else {
                print FH "STEP: Remove CPU from line $_ - PASS\n";
            }
        }
    }

    # return custgrp line to AUTO_GRP
    unless ($change_cust) {
        unless ($ses_core->execCmd("servord")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
        }
        foreach (@list_dn) {
            if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("chg \$ line $_ cust auto_grp y y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot change custgrp of line $_");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
            }
            unless (grep /CUSTGRP.*AUTO_GRP/, $ses_core->execCmd("qdn $_")) {
                $logger->error(__PACKAGE__ . " $tcid: custgrp AUTO_GRP does not exist after changing");
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - FAIL\n";
            } else {
                print FH "STEP: change Custgrp line $_ to AUTO_GRP - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_017";
    my $tcid = "ADQ730_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my $flag = 1;
################################### LOGIN #####################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[0..4]], -password => [@{$core_account{-password}}[0..4]])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Verify 'List' command in table DNROUTE and DNINV
    foreach ('DNROUTE','DNINV') {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table $_")) {
            $logger->error(__PACKAGE__ . " $tcid: table name may be wrong");
            print FH "STEP: Go to table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Go to table $_ - PASS\n";
        }
        unless (grep /AREACODE\s+OFCCODE\s+STNCODE\s+DNRESULT/, $ses_core->execCmd("list 5")) {
            $logger->error(__PACKAGE__ . " $tcid: 'list 5' cannot execute in table $_");
            print FH "STEP: check command 'list <number>' in table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: check command 'list <number>' in table $_ - PASS\n";
        }
        unless (grep /BOTTOM/, $ses_core->execCmd("list all")) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot execute list all in table $_");
            print FH "STEP: check command 'list all' in table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: check command 'list all' in table $_ - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
    }

################################## Cleanup 017 ##################################

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_018");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_018";
    my $tcid = "ADQ730_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my $flag = 1;

################################### LOGIN #####################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[5..9]], -password => [@{$core_account{-password}}[5..9]])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Verify 'Del' command in table DNROUTE and DNINV
    foreach ('DNROUTE','DNINV') {
        @output = $ses_core->execCmd("table $_");
        if (grep /UNKNOWN TABLE/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: table name may be wrong");
            print FH "STEP: Go to table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Go to table $_ - PASS\n";
        }

        if (grep /DMOS NOT ALLOWED/, @output) {
            unless (grep /Y TO/, $ses_core->execCmd("del 000 111 2323")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute 'del' in table $_");
            }
            unless (grep /ERROR/, $ses_core->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: 'del' command cannot return ERROR in table $_");
                print FH "STEP: check command 'del' return ERROR in table $_ - FAIL\n";
                $flag = 0;
                last;
            } else {
                print FH "STEP: check command 'del' return ERROR in table $_ - PASS\n";
            }
        } else {
            unless (grep /ERROR/, $ses_core->execCmd("del 000 111 2323")) {
                $logger->error(__PACKAGE__ . " $tcid: 'del' command cannot return ERROR in table $_");
                print FH "STEP: check command 'del' return ERROR in table $_ - FAIL\n";
                $flag = 0;
                last;
            } else {
                print FH "STEP: check command 'del' return ERROR in table $_ - PASS\n";
            }
        }

        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless ($flag) {
        $result = 0;
    }

################################## Cleanup 018 ##################################

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_019";
    my $tcid = "ADQ730_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my $flag = 1;

################################### LOGIN #####################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[10..14]], -password => [@{$core_account{-password}}[10..14]])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Verify 'Count' command in table DNROUTE and DNINV
    foreach ('DNROUTE','DNINV') {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table $_")) {
            $logger->error(__PACKAGE__ . " $tcid: table name may be wrong");
            print FH "STEP: Go to table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Go to table $_ - PASS\n";
        }
        unless (grep /SIZE\s+\=\s+\d+/, $ses_core->execCmd("count")) {
            $logger->error(__PACKAGE__ . " $tcid: 'count' command cannot return number of tuples in table $_");
            print FH "STEP: check command 'count' in table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: check command 'count' in table $_ - PASS\n";
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless ($flag) {
        $result = 0;
    }

################################## Cleanup 019 ##################################

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_020");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_020";
    my $tcid = "ADQ730_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my $flag = 1;

################################### LOGIN #####################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[15..19]], -password => [@{$core_account{-password}}[15..19]])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Verify 'range' command in table DNROUTE and DNINV
    foreach ('DNROUTE','DNINV') {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table $_")) {
            $logger->error(__PACKAGE__ . " $tcid: table name may be wrong");
            print FH "STEP: Go to table $_ - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Go to table $_ - PASS\n";
        }
        @output = $ses_core->execCmd("range");
        foreach my $id ('AREACODE','OFCCODE','STNCODE','DNRESULT') {
            unless (grep /$id/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: column $id is missing");
                $flag = 0;
                last;
            }
        }
        unless ($flag) {
            print FH "STEP: check command 'range' in table $_ - FAIL\n";
            last;
        } else {
            print FH "STEP: check command 'range' in table $_ - PASS\n";
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless ($flag) {
        $result = 0;
    }

################################## Cleanup 020 ##################################

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_021 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_021");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_021";
    $tcid = "ADQ730_021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = @db_list_dn_v52[0..1];
    my @list_line = @db_list_line_v52[0..1];
    my @list_region = @db_list_region_v52[0..1];
    my @list_len = @db_list_len_v52[0..1];
    my @list_line_info = @db_list_line_info_v52[0..1];

    my $wait_for_event_time = 30;
    my $change_t120 = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Datafill tuple T120 in table Tones
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep T120 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_CONGESTION N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TONE_CONGESTION/, $ses_core->execCmd("pos T120")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
        print FH "STEP: Datafill tuple T120 in table TONES - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple T120 in table TONES - PASS\n";
    }
    $change_t120 = 0;

# Get DISA number
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[0], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number - PASS\n";
    }

# Datafill authen code in table AUTHCDE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table AUTHCDE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table AUTHCDE'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 1234")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 1234 IBN 0 Y \$ SW \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 1234'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 1234 IBN 0 Y \$ SW \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'AUTO_GRP 1234'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }

    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /1234/, $ses_core->execCmd("pos AUTO_GRP 1234")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill authen code in table AUTHCDE");
        print FH "STEP: Datafill authen code in table AUTHCDE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill authen code in table AUTHCDE - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0],$list_dn[1]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # A calls B then B flashes
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # B dials DISA call then enter authen code
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $disa_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial DISA $disa_num successfully");
        print FH "STEP: B dials DISA number - FAIL\n";
    } else {
        print FH "STEP: B dials DISA number - PASS\n";
    }
    sleep(3);

    # B dials authen code
    unless($ses_glcas->startDetectCongestionToneCAS(-line_port => $list_line[1], -cas_timeout => 50000)) {
        $logger->error(__PACKAGE__ . ": Cannot start detect Congestion tone line B");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => '7890',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '7890' successfully");
        print FH "STEP: B dials 7890 - FAIL\n";
    } else {
        print FH "STEP: B dials 7890 - PASS\n";
    }
    sleep(2);
    unless($ses_glcas->stopDetectCongestionToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect Congestion tone line B");
        print FH "STEP: B hears congestion tone - FAIL\n";
    } else {
        print FH "STEP: B hears congestion tone - PASS\n";
    }

    # B flashes again, A and B hear congestion tone
    unless($ses_glcas->startDetectCongestionToneCAS(-line_port => $list_line[0], -cas_timeout => 20000)) {
        $logger->error(__PACKAGE__ . ": Cannot start detect Congestion tone line A");
    }
    unless($ses_glcas->startDetectCongestionToneCAS(-line_port => $list_line[1], -cas_timeout => 20000)) {
        $logger->error(__PACKAGE__ . ": Cannot start detect Congestion tone line B");
    }
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: B Flashes - FAIL\n";
    } else {
        print FH "STEP: B Flashes - PASS\n";
    }

    unless($ses_glcas->stopDetectCongestionToneCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect Congestion tone line A");
        print FH "STEP: A hears congestion tone - FAIL\n";
    } else {
        print FH "STEP: A hears congestion tone - PASS\n";
    }
    unless($ses_glcas->stopDetectCongestionToneCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot detect Congestion tone line B");
        print FH "STEP: B hears congestion tone - FAIL\n";
    } else {
        print FH "STEP: B hears congestion tone - PASS\n";
    }

################################## Cleanup 021 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 021 ##################################");

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
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /cg\/ct/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/ct on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'cg\/ct' in tapi log");
            print FH "STEP: check the message cg\/ct on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback tuple T120 in table TONES
    unless ($change_t120) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep T120 0 10 10 1010101010101 LO SILENT_TONE 10 10 TONE_CONGESTION N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_CONGESTION/, $ses_core->execCmd("pos T120")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
            print FH "STEP: Rollback tuple T120 in table TONES - FAIL\n";
        } else {
            print FH "STEP: Rollback tuple T120 in table TONES - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_022 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_022");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_022";
    $tcid = "ADQ730_022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],@db_list_dn_abi[0..1]);
    my @list_line = (@db_list_line_v52[0..1],@db_list_line_abi[0..1]);
    my @list_region = (@db_list_region_v52[0..1],@db_list_region_abi[0..1]);
    my @list_len = (@db_list_len_v52[0..1],@db_list_len_abi[0..1]);
    my @list_line_info = (@db_list_line_info_v52[0..1],@db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $add_feature_lineB = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Add 3WC to line A
    unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
        print FH "STEP: add 3WC for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Add CWT, CWI and CWR to line B
    foreach ('CWT','CWI','CWR') {
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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0; 

# Call flow
    # make call B to D
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[1],
                -regionB => $list_region[3],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls D and they have speech path");
        print FH "STEP: B calls D and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls D and they have speech path - PASS\n";
    }

    # A calls C and they have speech path
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C and they have speech path");
        print FH "STEP: A calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C and they have speech path - PASS\n";
    }

    # A calls B
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

    # B can hear call waiting tone
    %input = (
                -line_port => $list_line[1],
                -callwaiting_tone_duration => 300,
                -cas_timeout => 20000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B cannot hears Call waiting tone");
        print FH "STEP: B hears Call waiting tone - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: B hears Call waiting tone - PASS\n";
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

################################## Cleanup 022 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 022 ##################################");

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
    }

    # Stop tapi
    my $exist1 = 1;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    unless ($tapi_start) {
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
                if (grep /cg\/cr/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/cr on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'cg\/cr' in tapi log");
            print FH "STEP: check the message cg\/cr on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CWT, CWI and CWR from line B
    unless ($add_feature_lineB) {
        foreach ('CWR','CWI','CWT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }

    # remove CFD from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[0]");
            print FH "STEP: Remove CFD from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_023 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_023");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_023";
    $tcid = "ADQ730_023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_sip[0]);
    my @list_line = ($db_list_line_sip[0]);
    my @list_region = ($db_list_region_sip[0]);
    my @list_len = ($db_list_len_sip[0]);
    my @list_line_info = ($db_list_line_info_sip[0]);

    my $wait_for_event_time = 30;
    my $change_t120 = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Datafill tuple T120 in table Tones
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
    }
    $ses_core->execCmd("rep T120 7 50 50 1010101010101010 LO SILENT_TONE \+");
    if (grep /ERROR/, $ses_core->execCmd("30 127 TONE_SPECIAL_INFORMATION N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TONE_SPECIAL_INFORMATION/, $ses_core->execCmd("pos T120")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
        print FH "STEP: Datafill tuple T120 in table TONES - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple T120 in table TONES - PASS\n";
    }
    $change_t120 = 0;

# Get DISA number
    my $disa_num = $ses_core->getDISAnMONAnumber(-lineDN => $list_dn[0], -featureName => 'DISA');
    unless ($disa_num) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get DISA number");
		print FH "STEP: get DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get DISA number - PASS\n";
    }

# Datafill authen code in table AUTHCDE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table AUTHCDE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table AUTHCDE'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 1234")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 1234 IBN 0 Y \$ SW \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 1234'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 1234 IBN 0 Y \$ SW \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'AUTO_GRP 1234'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }

    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /1234/, $ses_core->execCmd("pos AUTO_GRP 1234")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill authen code in table AUTHCDE");
        print FH "STEP: Datafill authen code in table AUTHCDE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill authen code in table AUTHCDE - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

    # A dials DISA call then enter authen code
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    sleep(2);
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "$disa_num#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial DISA $disa_num successfully");
        print FH "STEP: A dials DISA number - FAIL\n";
    } else {
        print FH "STEP: A dials DISA number - PASS\n";
    }
    sleep(5);

    # A dials authen code
    # unless($ses_glcas->startDetectSpecialInformationToneCAS(-line_port => $list_line[0], -cas_timeout => 20000)) {
    #     $logger->error(__PACKAGE__ . ": Cannot start detect Special information tone line A");
    # }
    %input = (
                -line_port => $list_line[0],
                -dialed_number => '7890',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '7890' successfully");
        print FH "STEP: B dials 7890 - FAIL\n";
    } else {
        print FH "STEP: B dials 7890 - PASS\n";
    }
    # sleep(2);
    # unless($ses_glcas->stopDetectSpecialInformationToneCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
    #     $logger->error(__PACKAGE__ . ": Cannot stop detect special information tone line A");
    #     print FH "STEP: detect special information tone line A - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: detect special information tone line A - PASS\n";
    # }

################################## Cleanup 023 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 023 ##################################");

    # Cleanup call
    sleep(5);
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
    }

    # Stop tapi
    my $exist1 = 1;
    unless ($tapi_start) {
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
                if (grep /cg\/sit/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message cg\/sit on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'cg\/sit' in tapi log");
            print FH "STEP: check the message cg\/sit on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback tuple T120 in table TONES
    unless ($change_t120) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep T120 0 10 10 1010101010101 LO SILENT_TONE 10 10 TONE_CONGESTION N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_CONGESTION/, $ses_core->execCmd("pos T120")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
            print FH "STEP: Rollback tuple T120 in table TONES - FAIL\n";
        } else {
            print FH "STEP: Rollback tuple T120 in table TONES - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_024 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_024");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_024";
    $tcid = "ADQ730_024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_sip[0]);
    my @list_line = ($db_list_line_sip[0]);
    my @list_region = ($db_list_region_sip[0]);
    my @list_len = ($db_list_len_sip[0]);
    my @list_line_info = ($db_list_line_info_sip[0]);

    my $wait_for_event_time = 30;
    my $change_t120 = 1;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Add CFD to line A
    unless ($ses_core->callFeature(-featureName => 'CFD P', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
        print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

    my $cfd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CFDP');
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFD access code for line $list_dn[0]");
		print FH "STEP: get CFD access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[0] - PASS\n";
    }

# Datafill tuple T120 in table Tones
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep T120 0 25 25 101010 LO SILENT_TONE 60 60 TONE_NACK N")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TONE_NACK/, $ses_core->execCmd("pos T120")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
        print FH "STEP: Datafill tuple T120 in table TONES - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple T120 in table TONES - PASS\n";
    }
    $change_t120 = 0;

# Datafill tuple NACK in sub LNT of table TMTCNTL
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TMTCNTL")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TMTCNTL'");
    }
    unless (grep /LNT/, $ses_core->execCmd("pos LNT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos LNT'");
    }
    unless ($ses_core->execCmd("sub")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'sub'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos NACK")) {
        if (grep /ERROR/, $ses_core->execCmd("add NACK Y S T120")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'NACK'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep NACK Y S T120")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'NACK'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /T120/, $ses_core->execCmd("pos NACK Y S T120")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple NACK");
        print FH "STEP: Datafill tuple NACK in sub LNT of table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple NACK in sub LNT of table TMTCNTL - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    # unless ($ses_tapi->loginCore(
    #                             -username => [@{$core_account{-username}}[10..14]], 
    #                             -password => [@{$core_account{-password}}[10..14]]
    #                             )) {
    #     $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
    #     print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    # }
    # @output = $ses_tapi->execCmd("gwctraci");
    # unless (grep/GWCTRACI:/, @output) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    # }
    # if (grep /count exceeded/, @output) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    # }
    # if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
    #     unless ($ses_tapi->execCmd("y")) {
    #         $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
    #     }
    # }
    # unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
    #     print FH "STEP: start tapitrace - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: start tapitrace - PASS\n";
    # }
    # $tapi_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

    # A Dials CFD code
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfd_acc . '#';
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A Dial CFD code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A Dial CFD code - PASS\n";
    }
    sleep(3);

    # A dials dials DISA number
    %input = (
                -line_port => $list_line[0],
                -dialed_number => '4005005656',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '4005005656#' successfully");
        print FH "STEP: A dials dials DISA number - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials dials DISA number - PASS\n";
    }
    sleep(5);

################################## Cleanup 024 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 024 ##################################");

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
    }

    # Stop tapi
    my $exist1 = 1;
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    unless ($tapi_start) {
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
                if (grep /xcg\/nack/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/nack on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/nack' in tapi log");
            print FH "STEP: check the message xcg\/nack on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFD from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[0]");
            print FH "STEP: Remove CFD from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[0] - PASS\n";
        }
    }

    # Rollback tuple T120 in table TONES
    unless ($change_t120) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep T120 0 10 10 1010101010101 LO SILENT_TONE 10 10 TONE_CONGESTION N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple T120");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /TONE_CONGESTION/, $ses_core->execCmd("pos T120")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos T120'");
            print FH "STEP: Rollback tuple T120 in table TONES - FAIL\n";
        } else {
            print FH "STEP: Rollback tuple T120 in table TONES - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_025 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_025");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_025";
    $tcid = "ADQ730_025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[0],$db_list_dn_sip[0]);
    my @list_line = ($db_list_line_v52[0],$db_list_line_sip[0]);
    my @list_region = ($db_list_region_v52[0],$db_list_region_sip[0]);
    my @list_len = ($db_list_len_v52[0],$db_list_len_sip[0]);
    my @list_line_info = ($db_list_line_info_v52[0],$db_list_line_info_sip[0]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Add 3WC to line A
    unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
        print FH "STEP: add 3WC for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 0;

# Datafill tuple VACT in table CLLI
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table CLLI")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table CLLI'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT 1046 60 VACT")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /VACT/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos VACT'");
        print FH "STEP: Datafill tuple VACT in table CLLI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in table CLLI - PASS\n";
    }

# Datafill tuple VACT in table Tones
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_VACANT N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep VACT 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_VACANT N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TONE_VACANT/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos VACT'");
        print FH "STEP: Datafill tuple VACT in table TONES - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in table TONES - PASS\n";
    }

# Datafill tuple 13 in table OFR3
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFR3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFR3'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos 13")) {
        if (grep /ERROR/, $ses_core->execCmd("add 13 S D VACT S D LKOUT \$ \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple '13'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep 13 S D VACT S D LKOUT \$ \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '13'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /VACT/, $ses_core->execCmd("pos 13")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos 13'");
        print FH "STEP: Datafill tuple 13 in table OFR3 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple 13 in table OFR3 - PASS\n";
    }

# Datafill tuple VACT in sub LNT of table TMTCNTL
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TMTCNTL")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TMTCNTL'");
    }
    unless (grep /LNT/, $ses_core->execCmd("pos LNT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos LNT'");
    }
    unless ($ses_core->execCmd("sub")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'sub'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT Y T OFR3 13")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep VACT Y T OFR3 13")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /OFR3/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple VACT in table TMTCNTL");
        print FH "STEP: Datafill tuple VACT in sub LNT of table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in sub LNT of table TMTCNTL - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
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
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS 123_456'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and they have speech path");
        print FH "STEP: A calls B and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path - PASS\n";
    }

    # A flashes and dials a valid DN
    %input = (
                -line_port => $list_line[0],
                -dialed_number => '123456',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '123456' successfully");
    }
    sleep(12);

    # A flashes again
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
    }

################################## Cleanup 025 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 025 ##################################");

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
        if (grep /TREATMENT SET.*VACT/, @cat) {
            print FH "STEP: Check TREATMENT VACT exist - PASS\n";
        } else {
            print FH "STEP: Check TREATMENT VACT exist - FAIL\n";
            $result = 0;
        }
    }

    # Stop tapi
    my $exist1 = 1;
    %info = (
                $audio_gwc => {
                        -gwc_ip => $audio_gwc_ip,
                        -terminal_num => [],
                        -int_term_num => [10270],
                        },
                );
    unless ($tapi_start) {
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
                if (grep /xcg\/vac/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/vac on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/vac' in tapi log");
            print FH "STEP: check the message xcg\/vac on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove 3WC from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
            print FH "STEP: Remove 3WC from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_026 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_026");

########################### Variables Declaration #############################
    my $sub_name = "ADQ730_026";
    $tcid = "ADQ730_026";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_sip[0]);
    my @list_line = ($db_list_line_sip[0]);
    my @list_region = ($db_list_region_sip[0]);
    my @list_len = ($db_list_len_sip[0]);
    my @list_line_info = ($db_list_line_info_sip[0]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $change_t120 = 1;
    my $change_q764 = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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

# Datafill tuple VACT in table CLLI
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table CLLI")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table CLLI'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT 1046 60 VACT")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /VACT/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos VACT'");
        print FH "STEP: Datafill tuple VACT in table CLLI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in table CLLI - PASS\n";
    }

# Datafill tuple VACT in table Tones
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table Tones")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TONES'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_VACANT N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep VACT 7 50 50 1010101010101010 LO SILENT_TONE 30 127 TONE_VACANT N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /TONE_VACANT/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos VACT'");
        print FH "STEP: Datafill tuple VACT in table TONES - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in table TONES - PASS\n";
    }

# Datafill tuple 13 in table OFR3
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFR3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFR3'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos 13")) {
        if (grep /ERROR/, $ses_core->execCmd("add 13 S D VACT S D LKOUT \$ \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple '13'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep 13 S D VACT S D LKOUT \$ \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple '13'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /VACT/, $ses_core->execCmd("pos 13")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos 13'");
        print FH "STEP: Datafill tuple 13 in table OFR3 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple 13 in table OFR3 - PASS\n";
    }

# Datafill tuple VACT in sub LNT of table TMTCNTL
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TMTCNTL")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TMTCNTL'");
    }
    unless (grep /LNT/, $ses_core->execCmd("pos LNT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos LNT'");
    }
    unless ($ses_core->execCmd("sub")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'sub'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos VACT")) {
        if (grep /ERROR/, $ses_core->execCmd("add VACT Y T OFR3 13")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep VACT Y T OFR3 13")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 'VACT'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /OFR3/, $ses_core->execCmd("pos VACT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot Datafill tuple VACT in table TMTCNTL");
        print FH "STEP: Datafill tuple VACT in sub LNT of table TMTCNTL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple VACT in sub LNT of table TMTCNTL - PASS\n";
    }

# Datafill tuple Q764 VACT ALLBC in table TMTMAP
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TMTMAP")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TMTMAP'");
    }
    if (grep /ERROR/, $ses_core->execCmd("rep Q764 VACT ALLBC ISUP LOCAL")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple Q764");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /LOCAL/, $ses_core->execCmd("pos Q764 VACT ALLBC")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos Q764 VACT ALLBC'");
        print FH "STEP: Datafill tuple Q764 VACT ALLBC in table TMTMAP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill tuple Q764 VACT ALLBC in table TMTMAP - PASS\n";
    }
    $change_q764 = 0;

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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

    # A Dials SST trunk code + invalid DN
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = $trunk_access_code . '107456#';
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A Dials SST trunk code \+ invalid DN - FAIL\n";
    } else {
        print FH "STEP: A Dials SST trunk code \+ invalid DN - PASS\n";
    }
    sleep (5);

################################## Cleanup 026 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 026 ##################################");

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
    %info = (
            $audio_gwc => {
                    -gwc_ip => $audio_gwc_ip,
                    -terminal_num => [],
                    -int_term_num => [10270],
                    },
            );
    unless ($tapi_start) {
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
                if (grep /xcg\/vac/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message xcg\/vac on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'xcg\/vac' in tapi log");
            print FH "STEP: check the message xcg\/vac on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Rollback tuple Q764 VACT ALLBC in table TMTMAP
    unless ($change_q764) {
        if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TMTMAP")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TMTMAP'");
        }
        if (grep /ERROR/, $ses_core->execCmd("rep Q764 VACT ALLBC ISUP NOLOCAL NRTODEST LOCLNET N")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple Q764 VACT ALLBC");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
        unless (grep /NOLOCAL/, $ses_core->execCmd("pos Q764 VACT ALLBC")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'pos Q764 VACT ALLBC'");
            print FH "STEP: Rollback tuple Q764 VACT ALLBC in table TMTMAP - FAIL\n";
        } else {
            print FH "STEP: Rollback tuple Q764 VACT ALLBC in table TMTMAP - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_027 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_027");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_027";
    $tcid = "ADQ730_027";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],$db_list_dn_abi[0]);
    my @list_line = (@db_list_line_v52[0..1],$db_list_line_abi[0]);
    my @list_region = (@db_list_region_v52[0..1],$db_list_region_abi[0]);
    my @list_len = (@db_list_len_v52[0..1],$db_list_len_abi[0]);
    my @list_line_info = (@db_list_line_info_v52[0..1],$db_list_line_info_abi[0]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
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
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Add CNF to line A
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
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CNF access code");
		print FH "STEP: get CNF access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CNF access code - PASS\n";
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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc 15 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc 15")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc 15'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# Call flow
    # A calls B and then A flashes
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
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and then A flashes");
        print FH "STEP: A calls B and then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and then A flashes - PASS\n";
    }

    # A dials CNF access code then A flashes
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cnf_acc",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial \*$cnf_acc successfully");
        print FH "STEP: A dials CNF access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials CNF access code - PASS\n";
    }

    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
    }

    # A calls C and then A flashes
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C and then A flashes");
        print FH "STEP: A calls C and then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C and then A flashes - PASS\n";
    }

    # A dials CNF access code
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cnf_acc",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial \*$cnf_acc successfully");
        print FH "STEP: A dials CNF access code again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials CNF access code again - PASS\n";
    }
    sleep(3);
    %input = (
                -list_port => [$list_line[1],$list_line[2],$list_line[0]], 
                -checking_type => ['DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path among B, C, and A ");
        print FH "STEP: checking speech path among B, C, and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: checking speech path among B, C, and A - PASS\n";
    }

################################## Cleanup 027 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 027 ##################################");

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

    # Stop tapi
    my $exist1 = 0;
    %info = (
                '15' => {
                        -gwc_ip => '10.250.24.40',
                        -terminal_num => [],
                        -int_term_num => [10270],
                        },
                );
    unless ($tapi_start) {
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
                $exist1 = grep /tn\/enter/, @{$tapiterm_out{$gwc_id}{$tn}};
            }
        }
        
        if ($exist1) {
            print FH "STEP: check the message conftn\/enter on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'conftn\/enter' in tapi log");
            print FH "STEP: check the message conftn\/enter on tapi log - FAIL\n";
            $result = 0;
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
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_028 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_028");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_028";
    $tcid = "ADQ730_028";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1],@db_list_dn_abi[0..1]);
    my @list_line = (@db_list_line_v52[0..1],@db_list_line_abi[0..1]);
    my @list_region = (@db_list_region_v52[0..1],@db_list_region_abi[0..1]);
    my @list_len = (@db_list_len_v52[0..1],@db_list_len_abi[0..1]);
    my @list_line_info = (@db_list_line_info_v52[0..1],@db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill tuple AUTO_GRP 0 in table MMCONF
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MMCONF'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

################################# Call flow ######################################
# A, B, C, D calls MMCONF DN 4005000000
    foreach (@list_line) {
        unless($ses_glcas->offhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot offhook line $_");
        }
        %input = (
                    -line_port => $_,
                    -dialed_number => '4005000000',
                    -digit_on => 300,
                    -digit_off => 300,
                    -wait_for_event_time => $wait_for_event_time
                    ); 
        unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
            $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
            $flag = 0;
            last;
        }
        sleep(8);
    }
    unless($flag) {
        print FH "STEP: A, B, C, D calls MMCONF DN 4005000000 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A, B, C, D calls MMCONF DN 4005000000 - PASS\n";
    }

# check speech path among A, B, C and D
    # %input = (
    #             -list_port => [@list_line], 
    #             -checking_type => ['DIGITS'], 
    #             -tone_duration => 2000,
    #             -cas_timeout => 50000
    #          );
    # unless ($ses_glcas->checkSpeechPathCAS(%input)) {
    #     $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path among A, B, C and D");
    #     print FH "STEP: checking speech path among A, B, C and D - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: checking speech path among A, B, C and D - PASS\n";
    # }

# B and C go onhook to leave CONF
    foreach ($list_line[1], $list_line[2]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
        sleep(2);
    }

# B dials CONF number then goes onhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => '4005000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
        print FH "STEP: B dials 4005000000 to join conference again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials 4005000000 to join conference again - PASS\n";
    }
    sleep(8);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    sleep(2);

################################## Cleanup 028 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 028 ##################################");

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

    # Stop tapi
    my $exist1 = 0;
    %info = (
                $audio_gwc => {
                        -gwc_ip => $audio_gwc_ip,
                        -terminal_num => [],
                        -int_term_num => [10270],
                        },
                );
    unless ($tapi_start) {
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
                $exist1 = grep /tn\/exit/, @{$tapiterm_out{$gwc_id}{$tn}};
            }
        }
        
        if ($exist1 == 3) {
            print FH "STEP: check 3 conftn\/exit messages on tapi log - $exist1 - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'conftn\/exit' 3 times in tapi log");
            print FH "STEP: check 3 conftn\/exit messages on tapi log - $exist1 - FAIL\n";
            $result = 0;
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_029 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_029");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_029";
    $tcid = "ADQ730_029";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1], @db_list_dn_abi[0..1]);
    my @list_line = (@db_list_line_v52[0..1], @db_list_line_abi[0..1]);
    my @list_region = (@db_list_region_v52[0..1], @db_list_region_abi[0..1]);
    my @list_len = (@db_list_len_v52[0..1], @db_list_len_abi[0..1]);
    my @list_line_info = (@db_list_line_info_v52[0..1], @db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $mdn_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill tuple AUTO_GRP 0 in table MMCONF
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MMCONF'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
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

# Add MDN to line B as primary
    $ses_core->execCmd("servord");
    @output = $ses_core->execCmd("ado \$ $list_dn[1] mdn sca y y $list_dn[1] tone y 3 y nonprivate \$ y y");
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
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: add MDN to line $list_dn[1] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[1] as primary - PASS\n";
    }

# Add MDN to line C as member
    @output = $ses_core->execCmd("ado \$ $list_dn[2] mdn sca n y $list_dn[1] BLDN \$ y y");
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
    unless(grep /$list_len[2]/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: add MDN to line $list_dn[2] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[2] as member - PASS\n";
    }
    $mdn_added = 0;

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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

################################# Call flow ######################################
# A, B calls MMCONF DN 4005000000
    foreach (@list_line[0..1]) {
        unless($ses_glcas->offhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot offhook line $_");
        }
        %input = (
                    -line_port => $_,
                    -dialed_number => '4005000000',
                    -digit_on => 300,
                    -digit_off => 300,
                    -wait_for_event_time => $wait_for_event_time
                    ); 
        unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
            $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
            $flag = 0;
            last;
        }
        sleep(12);
    }
    unless($flag) {
        print FH "STEP: A, B calls MMCONF DN 4005000000 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A, B calls MMCONF DN 4005000000 - PASS\n";
    }

# C off-hook to join to conference then check speech path between
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);
    %input = (
                -list_port => [@list_line[0..2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path among A, B and C");
        print FH "STEP: C offhook and check speech path among A, B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C offhook and check speech path among A, B and C - PASS\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
    }
    sleep(2);

# B flashes and D dials DN 4005000000
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: B flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flashes - PASS\n";
    }
    sleep(2);
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => '4005000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
        print FH "STEP: D dials '4005000000' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials '4005000000' - PASS\n";
    }
    sleep(8);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[3]");
    }

# A flashes and D dials DN 4005000000
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
        print FH "STEP: C flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C flashes - PASS\n";
    }
    sleep(2);
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
    %input = (
                -line_port => $list_line[3],
                -dialed_number => '4005000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
        print FH "STEP: D dials '4005000000' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials '4005000000' - PASS\n";
    }
    sleep(8);



# D flashes
    %input = (
                -line_port => $list_line[3], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[3]");
        print FH "STEP: D flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D flashes - PASS\n";
    }
    sleep(2);

################################## Cleanup 029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 029 ##################################");

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

    # Stop tapi
    my $exist1 = 0;
    %info = (
                $audio_gwc => {
                        -gwc_ip => $audio_gwc_ip,
                        -terminal_num => [],
                        -int_term_num => [10270],
                        },
                );
    unless ($tapi_start) {
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
                $exist1 = grep /tn\/lock/, @{$tapiterm_out{$gwc_id}{$tn}};
            }
        }

        if ($exist1 == 2) {
            print FH "STEP: check 2 conftn\/lock messages on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Can see 'conftn\/lock' $exist1 times in tapi log");
            print FH "STEP: check 2 conftn\/lock messages on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # Remove MDN from line B and C
    unless ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[2] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[2] from MDN group");
            print FH "STEP: remove line $list_dn[2] from MDN group - FAIL\n";
        } else {
            print FH "STEP: remove line $list_dn[2] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[1] mdn $list_dn[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[1] - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[2] $list_line_info[2] $list_len[2] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[2] ");
            print FH "STEP: NEW line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_030 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_030");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_030";
    $tcid = "ADQ730_030";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = (@db_list_dn_v52[0..1], @db_list_dn_abi[0..1]);
    my @list_line = (@db_list_line_v52[0..1], @db_list_line_abi[0..1]);
    my @list_region = (@db_list_region_v52[0..1], @db_list_region_abi[0..1]);
    my @list_len = (@db_list_len_v52[0..1], @db_list_len_abi[0..1]);
    my @list_line_info = (@db_list_line_info_v52[0..1], @db_list_line_info_abi[0..1]);

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill tuple AUTO_GRP 0 in table MMCONF
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table MMCONF")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table MMCONF'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos AUTO_GRP 0")) {
        if (grep /ERROR/, $ses_core->execCmd("add AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
            $logger->error(__PACKAGE__ . " $tcid: ERROR when adding tuple 'AUTO_GRP 0'");
        } else {
            if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
                $ses_core->execCmd("Y");
            }
        }
    } else {
        if (grep /ERROR/, $ses_core->execCmd("rep AUTO_GRP 0 400 500 0000 0 Y Y N 150 FLASHONLY \$")) {
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
    $logutil_start = 0;

# Start tapi trace
    unless ($ses_tapi->loginCore(
                                -username => [@{$core_account{-username}}[10..14]], 
                                -password => [@{$core_account{-password}}[10..14]]
                                )) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core for tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for tapitrace - PASS\n";
    }
    @output = $ses_tapi->execCmd("gwctraci");
    unless (grep/GWCTRACI:/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'gwctraci' ");
    }
    if (grep /count exceeded/, @output) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot use 'gwctraci' due to 'count exceeded' ");
    }
    if (grep /This will clear existing trace buffers/, $ses_tapi->execCmd("define both gwc $audio_gwc 0 32766")) {
        unless ($ses_tapi->execCmd("y")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'y' ");
        }
    }
    unless ($ses_tapi->execCmd("enable both gwc $audio_gwc")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'enable both gwc $audio_gwc'");
        print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

################################# Call flow ######################################
# A, B calls MMCONF DN 4005000000
    foreach (@list_line[0..1]) {
        unless($ses_glcas->offhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot offhook line $_");
        }
        %input = (
                    -line_port => $_,
                    -dialed_number => '4005000000',
                    -digit_on => 300,
                    -digit_off => 300,
                    -wait_for_event_time => $wait_for_event_time
                    ); 
        unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
            $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
            $flag = 0;
            last;
        }
        sleep(8);
    }
    unless($flag) {
        print FH "STEP: A, B calls MMCONF DN 4005000000 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A, B calls MMCONF DN 4005000000 - PASS\n";
    }

# B flashes and C dials DN 4005000000
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: B flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flashes - PASS\n";
    }
    sleep(3);
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    %input = (
                -line_port => $list_line[2],
                -dialed_number => '4005000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": C cannot dial '4005000000' successfully");
        print FH "STEP: C dials '4005000000' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials '4005000000' - PASS\n";
    }
    sleep(5);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
    }

# A flashes and C dials DN 4005000000
    %input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             );
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[0]");
        print FH "STEP: A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flashes - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[3]");
    }
    %input = (
                -line_port => $list_line[2],
                -dialed_number => '4005000000',
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial '4005000000' successfully");
        print FH "STEP: D dials '4005000000' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials '4005000000' - PASS\n";
    }
    sleep(8);

# Check speech path among A, B and C
    %input = (
                -list_port => [@list_line[0..2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path among A, B and C");
        print FH "STEP: C offhook and check speech path among A, B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C offhook and check speech path among A, B and C - PASS\n";
    }

################################## Cleanup 030 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 030 ##################################");

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

    # Stop tapi
    my $exist1 = 0;
    %info = (
                $audio_gwc => {
                        -gwc_ip => $audio_gwc_ip,
                        -terminal_num => [],
                        -int_term_num => [10270],
                        },
                );
    unless ($tapi_start) {
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
                $exist1 = grep /SG\{.+\/lock\}/, @{$tapiterm_out{$gwc_id}{$tn}};
            }
        }

        if ($exist1) {
            print FH "STEP: check the message conftn\/unlock on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'conftn\/unlock' in tapi log");
            print FH "STEP: check the message conftn\/unlock on tapi log - FAIL\n";
            $result = 0;
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_031 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_031");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_031";
    $tcid = "ADQ730_031";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_v52[2],$db_list_dn_v52[0]);
    my @list_line = ($db_list_line_v52[2],$db_list_line_v52[0]);
    my @list_region = ($db_list_region_v52[2],$db_list_region_v52[0]);
    my @list_len = ($db_list_len_v52[2],$db_list_len_v52[0]);
    my @list_line_info = ('IBN RESTP 0 0','IBN RESTP 0 0');
    my $deposit_line = 2134409001;

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $tapi_start = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&tapi);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_tapi = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################

# Check line status
    %input = (
                -function => ['OUT','NEW'], 
                -lineDN => $list_dn[1], 
                -lineType => '', 
                -len => '', 
                -lineInfo => $list_line_info[1]
            );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[1] cannot reset");
        print FH "STEP: Reset line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Reset line $list_dn[1] - PASS\n";
    }
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

# Add CFU and MWT to line A
    foreach ("CFU N",'MWT STD N Y DISPLAY N') {
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
    $logutil_start = 0;

# Start tapi trace
    %input = (
                -username => [@{$core_account{-username}}[10..14]],
                -password => [@{$core_account{-password}}[10..14]],
                -testbed => $TESTBED{"c20:1:ce0"},
                -gwc_user => $gwc_user,
                -gwc_pwd => $gwc_pwd,
                -list_dn => [$list_dn[0],$list_dn[1]],
                -list_trk_clli => [],
            );
    %info = $ses_tapi->startTapiTerm(%input);
    unless(%info) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
		print FH "STEP: start tapitrace - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start tapitrace - PASS\n";
    }
    $tapi_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }

    # A active CFU on deposit line
    unless ($ses_core->execCmd("Servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    unless ($ses_core->execCmd("changecfx $list_len[0] CFU $deposit_line A")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'changecfx'");
    }
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[0] - PASS\n";
    }

    # B calls A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    sleep(2);
    my $dialed_num = $list_dn[0] . '#';
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                );
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: B calls A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: B calls A - PASS\n";
    }
    sleep(3);

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
    
    # B leave a message then press #
    unless ($ses_glcas->sendTestToneCAS (-line_port => $list_line[1], -test_tone_duration => 1000, -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ".$sub_name: B cannot send test tone to line A");
    }
    sleep(1);
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B leave a message then press \#");
        print FH "STEP: B leave a message then press \# - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B leave a message then press \# - PASS\n";
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
    sleep(2);

    # A goes offhook and detect stutter tone
    unless($ses_glcas->startDetectStutterDialToneCAS(-line_port => $list_line[0], -tone_duration => 0, -cas_timeout => 30000)) {
        $logger->error(__PACKAGE__ . ": Cannot start detect stutter dial tone");
    }
    sleep(1);
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    unless ($ses_glcas->stopDetectStutterDialToneCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)){
        $logger->error(__PACKAGE__ . " $tcid: Cannot detect stutter tone line A");
    }

################################## Cleanup 031 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 031 ##################################");

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
    unless ($tapi_start) {
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
                if (grep /srvtn.*mwt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                    last;
                }
            }
        }
        unless ($exist1) {
            print FH "STEP: check the message srvtn-mwt on tapi log - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Cannot see 'srvtn-mwt' in tapi log");
            print FH "STEP: check the message srvtn-mwt on tapi log - FAIL\n";
            $result = 0;
        }
    }

    # remove CFU from line A
    unless ($add_feature_lineA) {
        foreach ('CFU') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_032 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_032");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_032";
    $tcid = "ADQ730_032";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'isup'}{-acc};
    my $trunk_region = $db_trunk{'isup'}{-region};
    my $trunk_clli = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code . $lea_num;
    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 ibn $list_dn[1] \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 1")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
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
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
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

    # Check line C ringing and offhook C
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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);

    # LEA can monitor the call between A and B
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
################################## Cleanup 032 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 032 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[0]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_033 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_033");
  
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_033";
    $tcid = "ADQ730_033";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], $db_list_dn_abi[0], @db_list_dn_v52[0..1]);
    my @list_line = ($db_list_line_ncs[0], $db_list_line_abi[0], @db_list_line_v52[0..1]);
    my @list_region = ($db_list_region_ncs[0], $db_list_region_abi[0], @db_list_region_v52[0..1]);
    my @list_len = ($db_list_len_ncs[0], $db_list_len_abi[0], @db_list_len_v52[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], $db_list_line_info_abi[0], @db_list_line_info_v52[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};
    my $trunk_region = $db_trunk{'sst'}{-region};
    my $trunk_clli = $db_trunk{'sst'}{-clli};

    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code . $lea_num;
    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 ibn $list_dn[1] \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no NO yes 1")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
    }

# Add CFB and CBU to line C
    foreach ("CFB N $list_dn[3]","CBU") {
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
    $logutil_start = 0;

# Call flow
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
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
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }

    # Check line D ringing
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
    sleep(2);

    # LEA C can monitor line A
    %input = (
                -list_port => [$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA D can monitor line A");
        print FH "STEP: LEA D can monitor line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor line A - PASS\n";
    }

    # LEA D can monitor line B
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C can monitor line B");
        print FH "STEP: LEA C can monitor line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor line B - PASS\n";
    }

################################## Cleanup 033 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 033 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[0]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*$list_dn[2]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    # remove CBU and CFB from line C
    unless ($add_feature_lineC) {
        foreach ('CBU','CFB') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Cannot remove $_ for line $list_dn[2]");
                print FH "STEP: remove $_ for line $list_dn[2] - FAIL\n";
            } else {
                print FH "STEP: remove $_ for line $list_dn[2] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_034 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_034");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_034";
    $tcid = "ADQ730_034";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'isup'}{-acc};
    my $trunk_region = $db_trunk{'isup'}{-region};
    my $trunk_clli = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code . $lea_num;
    my ($surv_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $surv_num = '0' . $trunk_access_code . $surv_num;

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk CDN outgoing_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # A calls B via ISUP trk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 034 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 034 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[0]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_035 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_035");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_035";
    $tcid = "ADQ730_035";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'isup'}{-acc};
    my $trunk_region = $db_trunk{'isup'}{-region};
    my $trunk_clli = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code . $lea_num;
    my $surv_num = '0' . $list_dn[1];

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk cli incoming_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # B calls A via ISUP trk and they have speech path
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 035 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 035 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[1]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[1]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_036 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_036");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_036";
    $tcid = "ADQ730_036";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code_etsipri = $db_trunk{'etsi_pri'}{-acc};
    my $trunk_region_etsipri = $db_trunk{'etsi_pri'}{-region};
    my $trunk_clli_etsipri = $db_trunk{'etsi_pri'}{-clli};

    my $trunk_access_code_isup = $db_trunk{'isup'}{-acc};
    my $trunk_region_isup = $db_trunk{'isup'}{-region};
    my $trunk_clli_isup = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Activate PTI on trunk
    unless(grep /DNBPRVCI/, $ses_dnbd->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBPRVCI'");
    }
    unless(grep /TRUNK is Active/, $ses_dnbd->execCmd("PTI")) {
        unless (grep /Activated/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot activate PTI on trunk");
        }
    }
    unless($ses_dnbd->execCmd("abort;quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code_isup . $lea_num;
    my $surv_num = '0' . $list_dn[1];

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk cli incoming_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # B calls A via ETSI-PRI trk and they have speech path
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_etsipri . $dialed_num;
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 036 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 036 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[1]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[1]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_037 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_037");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_037";
    $tcid = "ADQ730_037";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code_qsigpri = $db_trunk{'qsig_pri'}{-acc};
    my $trunk_region_qsigpri = $db_trunk{'qsig_pri'}{-region};
    my $trunk_clli_qsigpri = $db_trunk{'qsig_pri'}{-clli};

    my $trunk_access_code_isup = $db_trunk{'isup'}{-acc};
    my $trunk_region_isup = $db_trunk{'isup'}{-region};
    my $trunk_clli_isup = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Activate PTI on trunk
    unless(grep /DNBPRVCI/, $ses_dnbd->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBPRVCI'");
    }
    unless(grep /TRUNK is Active/, $ses_dnbd->execCmd("PTI")) {
        unless (grep /Activated/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot activate PTI on trunk");
        }
    }
    unless($ses_dnbd->execCmd("abort;quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort;quit'");
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code_isup . $lea_num;
    my $surv_num = '0' . $list_dn[1];

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk cli incoming_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # B calls A via QSIG-PRI trk and they have speech path
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_qsigpri . $dialed_num;
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 037 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 037 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[1]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_038 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_038");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_038";
    $tcid = "ADQ730_038";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_abi[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_abi[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_abi[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_abi[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_abi[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code_etsipri = $db_trunk{'etsi_pri'}{-acc};
    my $trunk_region_etsipri = $db_trunk{'etsi_pri'}{-region};
    my $trunk_clli_etsipri = $db_trunk{'etsi_pri'}{-clli};

    my $trunk_access_code_isup = $db_trunk{'isup'}{-acc};
    my $trunk_region_isup = $db_trunk{'isup'}{-region};
    my $trunk_clli_isup = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# Datafill trunk ETSI-PRI in table TRKGRP
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table TRKGRP")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table TRKGRP'");
    }
    unless ($ses_core->execCmd("rwok on")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'rwok on'");
    }
    $ses_core->execCmd("rep $trunk_clli_etsipri PRA 0 NPDGP NCRT MIDL N +");
    if (grep /ERROR/, $ses_core->execCmd("ISDN 538 \$ \$")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple $trunk_clli_etsipri");
    } else {
        if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")) {
            $ses_core->execCmd("Y");
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /538/, $ses_core->execCmd("pos $trunk_clli_etsipri")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change $trunk_clli_etsipri in table TRKGRP");
        print FH "STEP: Datafill trunk ETSI-PRI in table TRKGRP - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill trunk ETSI-PRI in table TRKGRP - PASS\n";
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code_isup . $lea_num;

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 PRI $trunk_clli_etsipri ETSIPRI ISDN 538 \+");
    $ses_dnbd->execCmd("\$ \$ 1111111 10 151515 yes $lea_num yes RESML px 515151 NONE \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # A calls B via ETSI-PRI trk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_etsipri . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 038 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 038 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[0]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_039 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_039");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_039";
    $tcid = "ADQ730_039";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_v52[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_v52[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_v52[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_v52[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_v52[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code_sst = $db_trunk{'sst'}{-acc};
    my $trunk_region_sst = $db_trunk{'sst'}{-region};
    my $trunk_clli_sst = $db_trunk{'sst'}{-clli};

    my $trunk_access_code_isup = $db_trunk{'isup'}{-acc};
    my $trunk_region_isup = $db_trunk{'isup'}{-region};
    my $trunk_clli_isup = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code_sst . $lea_num;
    my ($surv_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $surv_num = '0' . $trunk_access_code_isup . $surv_num;

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk CDN outgoing_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # A calls B via ISUP trk and they have speech path
    my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_isup . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 039 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 039 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[0]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[0]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[0] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
}

sub ADQ730_040 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ730_040");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ730_040";
    $tcid = "ADQ730_040";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ730");

    my @list_dn = ($db_list_dn_ncs[0], @db_list_dn_v52[0..1]);
    my @list_line = ($db_list_line_ncs[0], @db_list_line_v52[0..1]);
    my @list_region = ($db_list_region_ncs[0], @db_list_region_v52[0..1]);
    my @list_len = ($db_list_len_ncs[0], @db_list_len_v52[0..1]);
    my @list_line_info = ($db_list_line_info_ncs[0], @db_list_line_info_v52[0..1]);

    ############################## Trunk DB #####################################
    my $trunk_access_code_sst = $db_trunk{'sst'}{-acc};
    my $trunk_region_sst = $db_trunk{'sst'}{-region};
    my $trunk_clli_sst = $db_trunk{'sst'}{-clli};

    my $trunk_access_code_isup = $db_trunk{'isup'}{-acc};
    my $trunk_region_isup = $db_trunk{'isup'}{-region};
    my $trunk_clli_isup = $db_trunk{'isup'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $add_mon_ord = 1;
    my $act_mon_ord = 1;
    my $flag = 1;
    my %info;
    
################################## LOGIN ######################################

    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    my $thr4 = threads->create(\&dnbd);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
    $ses_dnbd = $thr4->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    unless ($ses_dnbd->loginCore(-username => ['cuong'], -password => ['cuong'])) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for DNBD");
        print FH "STEP: Login TMA20 core for DNBD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core for DNBD - PASS\n";
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
            print FH "STEP: Check line $list_dn[$i] status - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }

# DNBD provisioning
    unless($ses_dnbd->execCmd("DNBDORD")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'DNBDORD'");
    }
    unless(grep /DNBDORDER/, $ses_dnbd->execCmd("$dnbd_pass")) {
        $logger->error(__PACKAGE__ . " $tcid: DNBD password may be wrong");
        print FH "STEP: Access DNBDORD mode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access DNBDORD mode - PASS\n";
    }
    my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $lea_num = $trunk_access_code_sst . $lea_num;
    my $surv_num = '0' . $list_dn[1];

    $ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 trk cli incoming_natl $surv_num \+");
    unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes RESML px 515151 NONE no speech no yes yes 3")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
    }
    @output = $ses_dnbd->execCmd("y");
    my $monitor_id;
    foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)\s?/) {
            $monitor_id = $1;
        }
    }
    unless ($monitor_id ne '') {
        $logger->error(__PACKAGE__ . " $tcid: cannot add Monitor order '$li_group_id'");
        print FH "STEP: add Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add Monitor order '$li_group_id' - PASS\n";
        $add_mon_ord = 0;
    }
    unless(grep /Please confirm/, $ses_dnbd->execCmd("surv act $monitor_id")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv act $monitor_id'");
    }
    unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot activate monitor order id $monitor_id'");
        print FH "STEP: activate Monitor order '$li_group_id' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate Monitor order '$li_group_id' - PASS\n";
        $act_mon_ord = 0;
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
    $logutil_start = 0;

# Call flow
    # B calls A via ISUP trk and they have speech path
    my ($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code_isup . $dialed_num;
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => [''],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A and they have speech path");
        print FH "STEP: B calls A and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls A and they have speech path - PASS\n";
    }

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
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
    }
    sleep(2);


    # LEA C can monitor the call between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA C monitor the call between A and B");
        print FH "STEP: LEA C can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA C can monitor the call between A and B - PASS\n";
    }

################################## Cleanup 040 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 040 ##################################");

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
        unless (grep /CALLING DN.*$list_dn[1]/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing callP AMAB with calling DN $list_dn[1]");
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Check callP AMAB with calling DN $list_dn[1] - PASS\n";
        }
        unless (grep /CALLING DN.*515151/, @cat) {
            $logger->error(__PACKAGE__ . " $tcid: missing LI AMAB with calling DN 515151");
            print FH "STEP: Check LI AMAB with calling DN 515151 - FAIL\n";
        } else {
            print FH "STEP: Check LI AMAB with calling DN 515151 - PASS\n";
        }
    }

    # DNBD un-provisioning
    unless ($act_mon_ord) {
        unless ($add_mon_ord) {
            unless(grep /Please confirm/, $ses_dnbd->execCmd("surv deact $monitor_id")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot command 'surv deact $monitor_id'");
            }
            unless(grep /Done/, $ses_dnbd->execCmd("y")) {
                $logger->error(__PACKAGE__ . " $tcid: cannot deactivate monitor order id $monitor_id'");
                print FH "STEP: deactivate Monitor order '$li_group_id' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: deactivate Monitor order '$li_group_id' - PASS\n";
            }
        }
        unless(grep /Please confirm/, $ses_dnbd->execCmd("del $monitor_id")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'del $monitor_id'");
        }
        unless(grep /Done/, $ses_dnbd->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot delete monitor order id $monitor_id'");
            print FH "STEP: delete monitor order '$li_group_id' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: delete monitor order '$li_group_id' - PASS\n";
        }
    }

    close(FH);
    &ADQ730_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ730_checkResult($tcid, $result);
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