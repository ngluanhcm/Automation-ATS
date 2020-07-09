#**************************************************************************************************#
#FEATURE                : <SHAKEN AEN_19> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <LUAN NGUYEN THANH>
#cd /home/ylethingoc/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation_ATS/SHAKEN19_SV/
#/usr/bin/runtest.sh `pwd` 
#perl -cw SHAKEN19_SV.pm
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::Luan::Automation_ATS::SHAKEN19_SV::SHAKEN19_SV; 

use strict;
use Tie::File;
use File::Copy;
use Cwd qw(cwd);
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX qw(strftime);
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
        "SIPP" => [1],
        "AS"  => [1],
               );

################################################################################
# VARIABLES USED IN THE SUITE Defined HERE                                     #
################################################################################
our $dir = cwd;
our $user_name;
if ($dir =~ /home\/(\w\w*)\/ats_repos/ ) {
    $user_name = $1;
}
our ($execution_logs, $token, %args, $testsuiteId, $baseUrl);
our $projectId = "5efd67a425db4504809aa84d";
my $executionDate = strftime "%Y-%m-%d %H:%M:%S", localtime;
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
my $userA = "2124489599";
my $userB = "4409578";
my $userC = "5008888";
our $SIPp_folder = "/usr/src/bilge/sipp-3.5.2";
our $ipsst = "10.250.161.132";
our $ipats = "10.250.188.90";
our $SIPp_folder_file = "/home/$ENV{ USER }/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation_ATS/SHAKEN19_SV";

our $SIPp_A;
our $soapui;
our $SIPp_A_cmd;
 
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
                            -dn => 4005008888,
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
   
our %tc_line = ('TC0' => ['pbx','sip_1','gr303_1'],
                'tms1287010' => ['sip_1','sip_2'],
                'tms1287011' => ['sip_1','sip_2'],
                'tms1287012' => ['gr303_1','sip_2'],
                'tms1287013' => ['gr303_1','sip_2'],
                'tms1287014' => ['gr303_1','sip_2'],
                'tms1287015' => ['gr303_1','sip_2'],
                'tms1287016' => ['sip_2','sip_1'],
                'tms1287017' => ['sip_1','sip_2'],
                'tms1287018' => ['gr303_1','gr303_2','sip_1'],
                'tms1287019' => ['gr303_1','gr303_2','sip_2'],
                'tms1287020' => ['gr303_1','gr303_2','sip_2'],
                'tms1287021' => ['gr303_1','gr303_2','sip_2'],                
                'tms1287022' => ['gr303_1','gr303_2','sip_2'],
                'tms1287023' => ['gr303_1','sip_2'],
                'tms1287024' => ['gr303_1','sip_2'],                
                'tms1287025' => ['gr303_1','gr303_2','sip_2'],
                'tms1287026' => ['gr303_1','gr303_2','sip_1'],
                'tms1287027' => ['gr303_1','gr303_2','sip_1'],
                'tms1287028' => ['gr303_1','sip_2'],
                'tms1287029' => ['gr303_1','gr303_2','sip_1'],
                'tms1287030' => ['gr303_1','gr303_2','sip_1'],
                'tms1287031' => ['gr303_1','gr303_2','sip_2'],
                'tms1287032' => ['gr303_1','gr303_2'],
                'tms1287033' => ['gr303_1','sip_1'],
                'tms1287034' => ['gr303_1','sip_1'],
                'tms1287035' => ['gr303_1','sip_1'],
                'tms1287036' => ['gr303_1','sip_1'],
                'tms1287037' => ['gr303_1','sip_1'],
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
                't15_pri_loop' =>{
                                -acc => 504,  #200 #504
                                -region => 'US',
                                -clli => 'G6VZSTSPRINTW2' , # T15G9PRINT2W #G6VZSTSPRINT2W
                            },

                't15_bpx' =>{
                                -acc => 987,  #200 #504
                                -region => 'US',
                                -clli => 'PBX_BCM50' , # T15G9PRINT2W #G6VZSTSPRINT2W
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
                    $ses_core, $ses_glcas, $ses_logutil,$ses_calltrak, $ses_tapi, $SIPp_A, $soapui
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

# sub Luan_checkResult {
#     my ($tcid, $result, $execution_logs) = (@_);
#     my $subname = "Luan_checkResult";
#     $logger->debug(__PACKAGE__ . ".$tcid: Test result : $result");
#     if ($result) { 
#         $logger->debug(__PACKAGE__ . ".$tcid  Test case passed ");
#             SonusQA::ATSHELPER::printPassTest($tcid);
#             return (1, $execution_logs);
#     } else {
#         $logger->debug(__PACKAGE__ . ".$tcid  Test case failed ");
#             SonusQA::ATSHELPER::printFailTest($tcid);
#             return (0, $execution_logs);
#     }
# }

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

sub check_log{
    my ($value1, $value2, @logs) = (@_);
    my $subname = "check_log";
        unless ((grep /$value1/, @logs) and (grep /$value2/, @logs)) {
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
            return 0;
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
            return 1;
        }
}

sub cha_table_ofcvar{
    my ($option, $chg_value) = (@_);
    my $subname = "rep_table_ofcvar";

    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /$option/, $ses_core->execCmd("pos $option")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $option' ");
    }
    foreach ('cha', $chg_value ,'y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /$chg_value/, $ses_core->execCmd("pos $option")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of $option");
        print FH "STEP: change PARMVAL $chg_value of $option - FAIL\n";
        return 0;
    } else {
        print FH "STEP: change PARMVAL $chg_value of $option - PASS\n";
        return 1;
    }
}

sub table_ofcvar_default{
    my $subname = "table_ofcvar_default";

    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        return 0;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
    unless (grep /STRSHKN_ORIGID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        return 0;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_Verstat_Mapping PASS PASS PASS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_Verstat_Mapping ");
        print FH "STEP: Default Values of STRSHKN_Verstat_Mapping  - FAIL\n";
        return 0;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_Verstat_Mapping - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_Verstat_Mapping  - FAIL\n";
                return 0;
                goto CLEANUP;
        }  
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_PASS_VERSTAT Y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_PASS_VERSTAT ");
        print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - FAIL\n";
        return 0;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - FAIL\n";
                return 0;
                goto CLEANUP;
        }  
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_BUILD_PASS_VERSTAT Y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_BUILD_PASS_VERSTAT ");
        print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - FAIL\n";
        return 0;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - FAIL\n";
                return 0;
        }  
    }
}

sub changecsvfileA {
    my $subname = "changecsvfileA";
    $logger->debug(__PACKAGE__ . ": ###################### Change CSV A ##########################");
    %input = (-csvFile => "$SIPp_folder_file/kbs_A.csv",
			  -replacement => { 1 => $userA,
				                2 => $userB,
								3 => $userC,
                                        }
                                     );
    unless($soapui->modifyCSVfile(%input)){
	$logger->error(__PACKAGE__ . ": Could not modify CSV A}");
	print FH "STEP: Modify CSV A- FAILED\n";
	return 0;              
    } else {
       print FH "STEP: Modify CSV A- PASSED\n";
    }
    return 1;
}

sub RUN_SIPP {
    $logger->info(__PACKAGE__ ."########################## RUN SIPP #################################" );
    $SIPp_A->execCmd("cd $SIPp_folder");
    $SIPp_A->{CMDERRORFLAG} = 0;
}

sub ACallBViaSSTBySipp{
    my ($ipsst, $SIPp_folder_file, $ipats, $namexml ) = (@_);
    my $subname = "ACallBViaSSTBySipp";

    $SIPp_A_cmd = "./sipp $ipsst -p 5060 -sf $SIPp_folder_file/$namexml -i $ipats -m 1 -inf $SIPp_folder_file/kbs_A.csv";
	$SIPp_A->startCustomClient($SIPp_A_cmd);
	unless($SIPp_A->waitCompletionClient()){
		$logger->error(__PACKAGE__ . ": SIPp_A script is FAILED "),
		print FH "STEP: Make call SIPp_A script - FAILED\n";
		return 0;
	} else {
		print FH "STEP: Make call SIPp_A script - PASSED\n";
		$logger->error(__PACKAGE__ . "STEP: Make call SIPp_A script - PASSED\n");
	}

}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    # "TC0", #set up lab
                    # "tms1287009",	#After restart warm, checking the OFCVAR Options
                    # "tms1287010",	#Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP Line
                    # "tms1287011",	#Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP_PBX
                    # "tms1287012",	#Verifying verstat parameter to be sent properly from Local Line to SIP Line
                    # "tms1287013",	#Verifying verstat parameter to be sent properly from Local Line to SIP_PBX
                    # "tms1287014",	#Verifying verstat parameter to be sent properly from PRI to SIP Line
                    # "tms1287015",	#FVerifying verstat parameter to be sent properly from PRI to SIP_PBX
                    # "tms1287016",	#Verifying verstat parameter to be sent properly from SIP-PBX to SIP Line
                    # "tms1287017",	#Verifying verstat parameter to be sent properly from SIP_PBX to SIP_PBX
                    # "tms1287018",	#Callp service - 3WC join conference via SST trunk 
                    # "tms1287019",	#Callp service - CFU forward to SIP line via SST trunk
                    # "tms1287020",	#Callp service - CXR tranfer to SIP line via SST trunk
                    # "tms1287021",	#Callp service - CFB forward to SIP line via SST trunk
                    # "tms1287022",	#Callp service - CFD forward to SIP line via SST trunk
                    # "tms1287023",	#Callp service - SCL call to SIP line via SST trunk
                    # "tms1287024",	#Callp service - SCS call to SIP line via SST trunk
                    "tms1287025",	#Callp service - CHD hold a call and make a new call to SIP line via SST trunk
                    # "tms1287026",	#Callp service - CWT verify call waiting from SIP line via SST trunk
                    # "tms1287027",	#Callp service - Verify DNH feature works fine with via SST trunk
                    # "tms1287028",	#Callp service - 1FR line make a basic call via SST trunk
                    # "tms1287029",	#Callp service - MLH make a basic call via SST trunk
                    # "tms1287030",	#Callp service - MADN (SCA) make a basic call via SST trunk
                    "tms1287031",	#Callp service - Simring make a call via SST trunk
                    # "tms1287032",	#Callp service - SDN make a call via SST trunk
                    # "tms1287033",	#OM_Verify Display oms : STRSHKN1 is support 
                    # "tms1287034",	#OM_Verify Display oms : STRSHKN2 is support 
                    # "tms1287035",	#Checking StrShkn Verstat OMs to be pegged properly for non-local calls
                    # "tms1287036",	#Checking any StrShkn Attestation_Verstat OMs NOT to be pegged for local call
                    # "tms1287037",	#Checking any StrShkn Verstat OMs NOT to be pegged for non-local calls if verstat value is built by core
                );

############################### Run Test #####################################
# sub runTests {
#     unless ( &configured ) {
#         $logger->error(__PACKAGE__ . ": Could not configure for test suite ".__PACKAGE__); 
#         return 0;
#     }

#     $logger->debug(__PACKAGE__ . " ======: before Opening Harness");
#     my $harness;
#     unless($harness = SonusQA::HARNESS->new( -suite => __PACKAGE__, -release => "$TESTSUITE->{TESTED_RELEASE}", -variant => $TESTSUITE->{TESTED_VARIANT}, -build => $TESTSUITE->{BUILD_VERSION}, -path => "ats_repos/test/setup/work")){ # Use this for real SBX Hardware.
#         $logger->error(__PACKAGE__ . ": Could not create harness object");
#         return 0;
#     }
#     $logger->debug(__PACKAGE__ . " ======: Opened Harness");  

#     my $baseUrl = "http://10.1.0.75:3000";
#     my %args = (-baseUrl => $baseUrl, -username => 'ntluan2', -password => '12345678a@A');
#     unless($token = (SonusQA::HARNESS::login(%args))){
#         $logger->error(__PACKAGE__ . ": Failed to Login Analytic page");
#         return 0;
#     }
# 	$logger->debug(__PACKAGE__ . ": token ===  : $token");
#     my @tests_to_run;

#     # If an array is passed in use that. If not run every test.
#     if ( @_ ) {
#         @tests_to_run = @_;
#     }
#     else {
#         @tests_to_run = @TESTCASES;
#     }

# 	# Add testsuite 
# 	%args = (-token => $token, -baseUrl => $baseUrl, -projectId => $projectId, -source => "QATEST::C20_EO::Luan::Automation_ATS::SHAKEN19_SV", 
# 				-testsuiteName => 'SHAKEN19_SV', -executionDate => $executionDate, -totalTCs => scalar @tests_to_run);

# 	unless($testsuiteId = (SonusQA::HARNESS::addTestsuite(%args))) {
# 		$logger->error(__PACKAGE__ . ": Failed to Add new testsuite 'SHAKEN19_SV'");
#         return 0;
# 	}   
# 	my %testcaseInfo = (-token => $token,-baseUrl => $baseUrl, -testsuiteId => $testsuiteId);
#     $harness->{SUBROUTINE}= 1;    
#     $harness->runTestsinSuite( \@tests_to_run, \%testcaseInfo);
# }

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
sub TC0 {
    $logger->debug(__PACKAGE__ . " Inside test case TC0");

########################### Variables Declaration #############################
    $tcid = "TC0";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num );

    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
# - Make sure SSTSHAKEN datafill in Core and enable SHAKEN in SST GUI
# - check translation from line -> SST , line -> pri in core cust = auto_grp
# - set plg tones bycountry  usa in g6
# - check trunk SSTSHAKEN2 in core and SST GUI access link map with ATS server and turn aon outgoing and incoming
# - line sip_2 is real phone
# - sip pbx line 5008888 insv in PC
###################### set up lab ###########################
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_pri'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# jf start
  if (grep /confirm/, $ses_core->execCmd("jf start")) {
        $ses_core->execCmd("Y");
        print FH "STEP: jf start - PASS \n";
    } else {
        print FH "STEP: jf start JOURNAL FILE ALREADY STARTED\n";
    }
# translation line to SST
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    unless (grep /SSTSHAKEN/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'traver l $list_dn[0] $dialed_num b' ");
        print FH "STEP: fix translation line to SST\n";
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CONFIRM/, $ses_core->execCmd("rep 775 N D SSTSHAKEN 3 \$ N \$ \$ ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep 775 N D SSTSHAKEN 3 \$ N \$ \$ ' ");
        }else{
            $ses_core->execCmd("Y");
        }
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0' ");
        }
        $ses_core->execCmd("SUBTABLE RTEREF");
        unless (grep /CONFIRM/, $ses_core->execCmd("add 775 T OFRT 775")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add 775 T OFRT 775' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        $ses_core->execCmd("quit all");
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0' ");
        }
        $ses_core->execCmd("SUBTABLE HNPACODE");
        unless (grep /CONFIRM/, $ses_core->execCmd("add 775 775 FRTE 775")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add 775 775 FRTE 775' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        unless (grep /SSTSHAKEN/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: traver l $list_dn[0] $dialed_num b fail");
        print FH "STEP: translation line to SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: translation line to SST - PASS\n";
    }
    }else{
        print FH "STEP: translation line to SST - PASS\n"; 
    }
# translation line to Pri
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    unless (grep /$db_trunk{'t15_pri'}{-clli}/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'traver l $list_dn[0] $dialed_num b' ");
        print FH "STEP: fix translation line to pri\n";
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /KEY NOT FOUND/, $ses_core->execCmd("rep $db_trunk{'t15_pri'}{-acc} N D $db_trunk{'t15_pri'}{-clli} 3 \$ N \$ \$ ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep 775 N D SSTSHAKEN 3 \$ N \$ \$ ' ");
            $ses_core->execCmd("Y");
        }else{
            $ses_core->execCmd("abort");
            $ses_core->execCmd("add $db_trunk{'t15_pri'}{-acc} N D $db_trunk{'t15_pri'}{-clli} 3 \$ N \$ \$ ");
            $ses_core->execCmd("Y");
        }
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0' ");
        }
        $ses_core->execCmd("SUBTABLE RTEREF");
        unless (grep /CONFIRM/, $ses_core->execCmd("add $db_trunk{'t15_pri'}{-acc} T OFRT $db_trunk{'t15_pri'}{-acc} ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_pri'}{-acc} T OFRT $db_trunk{'t15_pri'}{-acc} ' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        $ses_core->execCmd("quit all");
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0' ");
        }
        $ses_core->execCmd("SUBTABLE HNPACODE");
        unless (grep /CONFIRM/, $ses_core->execCmd("add $db_trunk{'t15_pri'}{-acc} $db_trunk{'t15_pri'}{-acc} FRTE $db_trunk{'t15_pri'}{-acc} ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_pri'}{-acc} $db_trunk{'t15_pri'}{-acc} FRTE $db_trunk{'t15_pri'}{-acc} ' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        unless (grep /$db_trunk{'t15_pri'}{-clli}/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: traver l $list_dn[0] $dialed_num b fail");
        print FH "STEP: translation line to SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: translation line to SST - PASS\n";
    }
    }else{
        print FH "STEP: translation line to SST - PASS\n"; 
    }
# translation Pri to SST
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    unless (grep /$db_trunk{'t15_sst'}{-clli}/, $ses_core->execCmd("traver tr $db_trunk{'t15_pri_loop'}{-clli} $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'traver tr $db_trunk{'t15_pri_loop'}{-clli} $dialed_num b' ");
        print FH "STEP: fix translation pri to SST\n";

        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 212 Y 1023 0 \( 177\) \( 1\) \( 0\) \( 0\) \( 0\) 0 \$")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 212 Y 1023 0 \( 177\) \( 1\) \( 0\) \( 0\) \( 0\) 0 \$' ");
        }
        $ses_core->execCmd("SUBTABLE RTEREF");
        unless (grep /CONFIRM/, $ses_core->execCmd("add $db_trunk{'t15_sst'}{-acc} T OFRT $db_trunk{'t15_sst'}{-acc} ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_sst'}{-acc} T OFRT $db_trunk{'t15_sst'}{-acc} ' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        $ses_core->execCmd("quit all");
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 212 Y 1023 0 \( 177\) \( 1\) \( 0\) \( 0\) \( 0\) 0 \$")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 212 Y 1023 0 \( 177\) \( 1\) \( 0\) \( 0\) \( 0\) 0 \$' ");
        }
        $ses_core->execCmd("SUBTABLE HNPACODE");
        unless (grep /CONFIRM/, $ses_core->execCmd("add $db_trunk{'t15_sst'}{-acc} $db_trunk{'t15_sst'}{-acc} FRTE $db_trunk{'t15_sst'}{-acc} ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_sst'}{-acc} $db_trunk{'t15_sst'}{-acc} FRTE $db_trunk{'t15_sst'}{-acc} ' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        unless (grep /$db_trunk{'t15_sst'}{-clli}/, $ses_core->execCmd("traver tr $db_trunk{'t15_pri_loop'}{-clli} $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: traver tr $db_trunk{'t15_pri_loop'}{-clli} $dialed_num b fail");
        print FH "STEP: translation line to SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: translation line to SST - PASS\n";
    }
    }else{
        print FH "STEP: translation line to SST - PASS\n"; 
    }
# del config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    my @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ( /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    my $TRKOPTS_config = 1;
# delconfig table LTDATA
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table LTDATA; format pack;list all;"); 
    foreach (@TRKOPTS){
		if (/(\w+.*\s)\((STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in LTDATA");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
            $ses_core->execCmd("pos $1 $2 ");
			$ses_core->execCmd("del");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    my $LTDATA_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
        }
# Disable SOC
    my @temp;
    if (grep /exceeded/, $ses_core->execCmd("SOC")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'SOC' ");
            print FH "STEP: execute command 'SOC' - FAIL\n";
            $result = 0;
            goto CLEANUP;
    }
    if (grep /Shaken.*ON/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Ensable ");
        if (grep /entering/, $ses_core->execCmd("assign STATE IDLE to CS2C0009")) {
            if (grep /disabled/, $ses_core->execCmd("Stir\/Shaken")) {
                print FH "STEP: Disable option CS2C0009 - PASS \n";
            }
        }             
    }else{
        print FH "STEP: Disable option CS2C0009 - PASS \n";
    }

# Enable SOC
    if (grep /Shaken.*IDLE/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Disable ");
        if (grep /Done/, $ses_core->execCmd("assign rtu JFCM9397UKE4YRCGBWGZ to CS2C0009")) {            
                print FH "STEP: Enable rtu  CS2C0009 - PASS \n";         
        }else{
            print FH "STEP: Enable rtu  CS2C0009 - Failed \n";
            $result = 0;
            goto CLEANUP;
        }
        if (grep /enabled/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Enable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Enable option CS2C0009 - PASS \n";
    }
# config table OKPARMS
    unless (grep /TABLE:.*OKPARMS/, $ses_core->execCmd("table OKPARMS")) {
         $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OKPARMS' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos STRSHKN_ENABLED")) {
         $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ENABLED' ");
    }else{
         print FH "STEP: check STRSHKN_ENABLED in table OKPARMS - Pass\n";
    }
    unless (grep /STRSHKN_ORIGID/, $ses_core->execCmd("pos STRSHKN_ORIGID")) {
         $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ORIGID' ");
    }else{
         print FH "STEP: check STRSHKN_ORIGID in table OKPARMS - Pass\n";
    }
# config table TRKOPTS
    if ($TRKOPTS_config) {
        unless (grep /TABLE:.*TRKOPTS/, $ses_core->execCmd("table TRKOPTS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table TRKOPTS' ");
        }
        if (grep /ERROR/, $ses_core->execCmd("add SSTSHAKEN STRSHKN STRSHKN")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add SSTSHAKEN STRSHKN STRSHKN' ");
            print FH "STEP: add SSTSHAKEN STRSHKN STRSHKN - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }else{
            $ses_core->execCmd("y");
            print FH "STEP: add SSTSHAKEN STRSHKN STRSHKN - Pass\n";
        }
    }
# config table LTDATA
    if ($LTDATA_config) {
        unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
        }
        $ses_core->execCmd("add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA");
        $ses_core->execCmd("y");
        print FH "STEP: add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA - Pass\n";
    }
# config table ofcvar
    &table_ofcvar_default();
################################## Cleanup 000 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 000 ##################################");


    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287009 { #After restart warm, checking the OFCVAR Options
    $logger->debug(__PACKAGE__ . " Inside test case tms1287009");
########################### Variables Declaration #############################
    $tcid = "tms1287009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name,@TRKOPTS , );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
# config table ofcvar
    &table_ofcvar_default();
# Warm Swact Core by cmd: restart warm active
    $ses_core->execCmd("logout");
    sleep(8);
    $ses_core->{conn}->print("cli");
    if($ses_core->{conn}->waitfor(-match => '/>/', -timeout => 10)){
            print FH "STEP: Go to CLI - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Go to CLI - FAIL" );
        print FH "STEP: Go to CLI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    unless (grep /in\-sync/, $ses_core->execCmd("sosAgent vca show VCA")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot execCmd sosAgent vca show VCA");
        print FH "STEP: execCmd sosAgent vca show VCA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd sosAgent vca show VCA - PASS\n";
    }

    $ses_core->execCmd("sh");
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[4..7]], -password => [@{$core_account{-password}}[4..7]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    $ses_core->execCmd("restart warm active");
    @output = $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/Connection closed/', -timeout => 300)){
        $logger->error(__PACKAGE__ . ".$tcid: restart warm active");
        print FH "STEP: execCmd restart warm active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd restart warm active - PASS\n";
    }
    $ses_core->{conn}->print("cli");
    if($ses_core->{conn}->waitfor(-match => '/>/', -timeout => 10)){
            print FH "STEP: Go to CLI - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Go to CLI - FAIL" );
        print FH "STEP: Go to CLI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    $ses_core->execCmd("sosAgent vca show VCA");
    sleep (800);
    $ses_core->{conn}->print("cli");
    if($ses_core->{conn}->waitfor(-match => '/>/', -timeout => 10)){
            print FH "STEP: Go to CLI - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Go to CLI - FAIL" );
        print FH "STEP: Go to CLI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    unless (grep /in\-sync/, $ses_core->execCmd("sosAgent vca show VCA")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot execCmd sosAgent vca show VCA");
        print FH "STEP: execCmd sosAgent vca show VCA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd sosAgent vca show VCA - PASS\n";
    }
    $ses_core->execCmd("sh");
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[4..7]], -password => [@{$core_account{-password}}[4..7]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    } 
# Check table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
        print FH "STEP: Check Values of strshkn_enabled  - FAIL\n";
        return 0;
        goto CLEANUP;
    }else{
        print FH "STEP: Check Values of strshkn_enabled  - PASS\n";
    }
    unless (grep /ADMINENTERED KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
        print FH "STEP: Check Values of strshkn_origID  - FAIL\n";
        return 0;
        goto CLEANUP
    }else{
        print FH "STEP: Check Values of strshkn_origID  - PASS\n";
    }
    unless (grep /PASS PASS PASS/, $ses_core->execCmd("pos STRSHKN_Verstat_Mapping")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_Verstat_Mapping' ");
        print FH "STEP: Check Values of STRSHKN_Verstat_Mapping  - FAIL\n";
        return 0;
        goto CLEANUP
    }else{
        print FH "STEP: Check Values of STRSHKN_Verstat_Mapping  - PASS\n";
    }
    unless (grep /Y/, $ses_core->execCmd("pos STRSHKN_PASS_VERSTAT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_PASS_VERSTAT' ");
        print FH "STEP: Check Values of STRSHKN_PASS_VERSTAT  - FAIL\n";
        return 0;
        goto CLEANUP
    }else{
        print FH "STEP: Check Values of STRSHKN_PASS_VERSTAT  - PASS\n";
    }
    unless (grep /Y/, $ses_core->execCmd("pos STRSHKN_BUILD_PASS_VERSTAT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_BUILD_PASS_VERSTAT' ");
        print FH "STEP: Check Values of STRSHKN_BUILD_PASS_VERSTAT  - FAIL\n";
        return 0;
        goto CLEANUP
    }else{
        print FH "STEP: Check Values of STRSHKN_BUILD_PASS_VERSTAT  - PASS\n";
    }
################################## Cleanup tms1287009 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287009 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}

sub tms1287010 { #Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1287010");

########################### Variables Declaration #############################
    $tcid = "tms1287010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }
    unless($SIPp_A = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0" },-sessionLog => "$tcid"."_SIPp_A")){
          $logger->error(__PACKAGE__ . ": Could not create UAC object for tms_alias => TESTBED{ ‘as:2:ce0’ }");
          return 0;
    } else {
        print FH "STEP: Login UAC server - PASSED\n";
    }
    unless($soapui = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_SOAPLog")){
        $logger->error(__PACKAGE__ . ": Could not create SOAP_UI object for tms_alias => TESTBED{ ‘as:1:ce0’ }");            
        print FH "STEP: Login ATS server - FAILED\n";
        return 0;              
    } else {
        print FH "STEP: Login ATS server - PASSED\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS PASS");
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst_sipp'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }   
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst_sipp'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# changecsvfileA
    $result = &changecsvfileA();
# RUN SIPP
    $result = &RUN_SIPP();
# A calls B via trunk and hears ringback then B ring via sipp
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286694.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);

    }
      
################################## Cleanup tms1287010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287010 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287011 { #Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1287011");

########################### Variables Declaration #############################
    $tcid = "tms1287011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }
    unless($SIPp_A = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0" },-sessionLog => "$tcid"."_SIPp_A")){
          $logger->error(__PACKAGE__ . ": Could not create UAC object for tms_alias => TESTBED{ ‘as:2:ce0’ }");
          return 0;
    } else {
        print FH "STEP: Login UAC server - PASSED\n";
    }
    unless($soapui = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_SOAPLog")){
        $logger->error(__PACKAGE__ . ": Could not create SOAP_UI object for tms_alias => TESTBED{ ‘as:1:ce0’ }");            
        print FH "STEP: Login ATS server - FAILED\n";
        return 0;              
    } else {
        print FH "STEP: Login ATS server - PASSED\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS PASS");
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst_sipp'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
  
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst_sipp'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# changecsvfileA
    $result = &changecsvfileA();
# RUN SIPP
    $result = &RUN_SIPP();
# A calls B via trunk and hears ringback then B ring via sipp
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286686.xml");

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   
    }
       
################################## Cleanup tms1287011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287011 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287012 { #Verifying verstat parameter to be sent properly from Local Line to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1287012");

########################### Variables Declaration #############################
    $tcid = "tms1287012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS PASS");
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
    sleep(2);
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   
    
    }
      
################################## Cleanup tms1287012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287012 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287013 { #Verifying verstat parameter to be sent properly from Local Line to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1287013");

########################### Variables Declaration #############################
    $tcid = "tms1287013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS PASS");

# # Check Trunk status
#     my $idl_num;
#     foreach ($db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_bpx'}{-clli}) {
#         $idl_num = 0;
#         @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
#         foreach (@output) {
#             if (/tk_idle .* (\d+)/) {
#                 $idl_num = $1;
#                 last;
#             }
#         }
#         unless ($idl_num) {
#             $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
#             print FH "STEP: Check trunk $_ status - FAIL\n";
#             $flag = 0;
#             last;
#         } else {
#             print FH "STEP: Check trunk $_ status- PASS\n";
#         }
#     }
#     unless ($flag) {
#         $result = 0;
#         goto CLEANUP;
#     }
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_bpx'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# Detect C rings after timeout of CFD
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
   
    }
    
################################## Cleanup tms1287013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287013 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287014 { #Verifying verstat parameter to be sent properly from PRI to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1287014");

########################### Variables Declaration #############################
    $tcid = "tms1287014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN AUTOGENERATED")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN AUTOGENERATED' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  AUTOGENERATED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  AUTOGENERATED - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    my $ofrt_config = 1;
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_pri'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A calls B via trunk to trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE'], #'RINGBACK','RINGING'
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI to SST ");
        print FH "STEP: A calls B via PRI to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via Pri to SST - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+FAILED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);
    }
     
################################## Cleanup tms1287014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287014 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        $ses_core->execCmd("abort");
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287015 { #Verifying verstat parameter to be sent properly from PRI to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1287015");

########################### Variables Declaration #############################
    $tcid = "tms1287015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN AUTOGENERATED")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN AUTOGENERATED' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  AUTOGENERATED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  AUTOGENERATED - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    my $ofrt_config = 1;
# # Check Trunk status
#     my $idl_num;
#     foreach ($db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_bpx'}{-clli}) {
#         $idl_num = 0;
#         @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
#         foreach (@output) {
#             if (/tk_idle .* (\d+)/) {
#                 $idl_num = $1;
#                 last;
#             }
#         }
#         unless ($idl_num) {
#             $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
#             print FH "STEP: Check trunk $_ status - FAIL\n";
#             $flag = 0;
#             last;
#         } else {
#             print FH "STEP: Check trunk $_ status- PASS\n";
#         }
#     }
#     unless ($flag) {
#         $result = 0;
#         goto CLEANUP;
#     }
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_pri'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A calls B via trunk to trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE'], #'RINGBACK','RINGING'
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via PRI to SST ");
        print FH "STEP: A calls B via PRI to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via Pri to SST - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);
    }
   
################################## Cleanup tms1287015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287015 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        $ses_core->execCmd("abort");
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287016 { #Verifying verstat parameter to be sent properly from SIP-PBX to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1287016");

########################### Variables Declaration #############################
    $tcid = "tms1287016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }
    unless($SIPp_A = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0" },-sessionLog => "$tcid"."_SIPp_A")){
          $logger->error(__PACKAGE__ . ": Could not create UAC object for tms_alias => TESTBED{ ‘as:2:ce0’ }");
          return 0;
    } else {
        print FH "STEP: Login UAC server - PASSED\n";
    }
    unless($soapui = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_SOAPLog")){
        $logger->error(__PACKAGE__ . ": Could not create SOAP_UI object for tms_alias => TESTBED{ ‘as:1:ce0’ }");            
        print FH "STEP: Login ATS server - FAILED\n";
        return 0;              
    } else {
        print FH "STEP: Login ATS server - PASSED\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");

# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst_sipp'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst_sipp'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# changecsvfileA
    $result = &changecsvfileA();
# RUN SIPP
    $result = &RUN_SIPP();
# A calls B via trunk and hears ringback then B ring via sipp
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286695.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);

    }
 
################################## Cleanup tms1287016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287016 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287017 { #Verifying verstat parameter to be sent properly from SIP_PBX to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1287017");

########################### Variables Declaration #############################
    $tcid = "tms1287017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }
    unless($SIPp_A = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0" },-sessionLog => "$tcid"."_SIPp_A")){
          $logger->error(__PACKAGE__ . ": Could not create UAC object for tms_alias => TESTBED{ ‘as:2:ce0’ }");
          return 0;
    } else {
        print FH "STEP: Login UAC server - PASSED\n";
    }
    unless($soapui = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_SOAPLog")){
        $logger->error(__PACKAGE__ . ": Could not create SOAP_UI object for tms_alias => TESTBED{ ‘as:1:ce0’ }");            
        print FH "STEP: Login ATS server - FAILED\n";
        return 0;              
    } else {
        print FH "STEP: Login ATS server - PASSED\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
###################### Call flow ###########################
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst_sipp'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# changecsvfileA
    $result = &changecsvfileA();
# RUN SIPP
    $result = &RUN_SIPP();
# A calls B via trunk and hears ringback then B ring via sipp
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286686.xml");

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   
    }
  
################################## Cleanup tms1287017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287017 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287018 { #Callp service - 3WC join conference via SST
    $logger->debug(__PACKAGE__ . " Inside test case tms1287018");

########################### Variables Declaration #############################
    $tcid = "tms1287018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");

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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# Add 3WC to line A
    unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: add 3WC for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
    
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[2]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Make call A to B and A flash
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and A flash");
        print FH "STEP: A calls B via SST and A flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and A flash - PASS\n";
    }
# Make call A to C and A flash , A,B,C join conf
    $dialed_num = $list_dn[2] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
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
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C via SST and A flash");
        print FH "STEP: A calls C via SST and A flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C via SST and A flash - PASS\n";
    }
# Check speech path between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and C ");
        print FH "STEP: check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and B - PASS\n";
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
  
################################## Cleanup tms1287018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287018 ##################################");

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
    # remove 3WC from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
            print FH "STEP: Remove 3WC from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[0] - PASS\n";
        }
    }
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287019 { #Callp service - CFU forward to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case tms1287019");

########################### Variables Declaration #############################
    $tcid = "tms1287019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");
   

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
    $initialize_done = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# Activate CFU to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    my $dialed_num = '*' . $cfu_acc . $list_dn[2] . '#';
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
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[1]");
        print FH "STEP: activate CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[1] - PASS\n";
    }
# Make call A to B  fw to C
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST  fw to C");
        print FH "STEP: A calls B via SST  fw to C  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST  fw to C - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}

    
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);           
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287019 ##################################");

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
   # remove CFB from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line $list_dn[1]");
            print FH "STEP: Remove CFB from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFB from line $list_dn[1] - PASS\n";
        }
    }
    
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287020 { #Callp service - CXR tranfer to SIP line via SST trunk 
    $logger->debug(__PACKAGE__ . " Inside test case tms1287020");

########################### Variables Declaration #############################
    $tcid = "tms1287020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");

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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
# Add CXR to line B
    unless ($ses_core->callFeature(-featureName => "CXR CTALL Y 12 STD", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[1]");
		print FH "STEP: add CXR for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Make call A to B and B flash
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and B flash");
        print FH "STEP: A calls B via SST and B flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and B flash - PASS\n";
    }
# B transfers call to C
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears  dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
    }

    $dialed_num = $list_dn[2] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial C successfully");
        print FH "STEP: B dials C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials C - PASS\n";
    }
    sleep(5);
# onhook B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}    
    sleep(5);

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   
    
    }
  
################################## Cleanup tms1287020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287020 ##################################");

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
   # remove CXR from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[1]");
            print FH "STEP: Remove CXR from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[1] - PASS\n";
        }
    }
    
    # Get PCM trace
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287021 { #Callp service - Callp service - CFB forward to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case tms1287021");

########################### Variables Declaration #############################
    $tcid = "tms1287021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");


# Add CFB to line B
    unless ($ses_core->callFeature(-featureName => "CFB N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFB for line $list_dn[1]");
		print FH "STEP: add CFB for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFB for line $list_dn[1] - PASS\n";
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
    $initialize_done = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# Offhook B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
# Make call A to B  fw to C
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST  fw to C");
        print FH "STEP: A calls B via SST  fw to C  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST  fw to C - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}    
    sleep(5);
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   

    }
   
################################## Cleanup tms1287021 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287021 ##################################");

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
   # remove CFB from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line $list_dn[1]");
            print FH "STEP: Remove CFB from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFB from line $list_dn[1] - PASS\n";
        }
    }
    
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287022 { #Callp service - Callp service - CFD forward to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case tms1287022");

########################### Variables Declaration #############################
    $tcid = "tms1287022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");


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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Make call A to B ;B does't answers
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ;B does't answers");
        print FH "STEP: A calls B via SST ;B does't answers  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST ;B does't answers - PASS\n";
    }
# Detect C rings after timeout of CFD
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   

    }
   
################################## Cleanup tms1287022 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287022 ##################################");

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
   # remove CFD from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[1]");
            print FH "STEP: Remove CFD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[1] - PASS\n";
        }
    }
    
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}

sub tms1287023 { #Callp service - SCL call to SIP line via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287023");

########################### Variables Declaration #############################
    my $tcid = "tms1287023";
    $tcid = "tms1287023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $flag = 1;
    my @callTrakLogs;
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");
# Get access code SPDC/SCPL for line A 
	my $spdc_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'SPDC');
    unless ($spdc_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SPDC access code for line $list_dn[0]");
		print FH "STEP: Get SPDC access code for line $list_dn[0] is $spdc_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get SPDC access code for line $list_dn[0] is $spdc_acc - PASS\n";
    }	

	my $scpl_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'SCPL');
    unless ($scpl_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SCPL access code for line $list_dn[0]");
		print FH "STEP: Get SCPL access code for line $list_dn[0] is $scpl_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get SCPL access code for line $list_dn[0] is $scpl_acc - PASS\n";
    }	

# Add SCL to line A
    unless ($ses_core->callFeature(-featureName => "SCL L30", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCL for line $list_dn[0]");
		print FH "STEP: add SCL for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCL for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;

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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A dials SCS code + NN + DN (B) and hear confirmation tone then onhook
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
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = "\*$scpl_acc";
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hears confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears confirmation tone - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = '11' . $trunk_access_code . $1;

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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

    sleep(3);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(3);

# A dials SPDC code + NN 
    $dialed_num = "\*$spdc_acc" . '11';
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A dials SPDC code + NN and check speech path between line A and B");
        print FH "STEP: A dials SPDC code + NN and check speech path between line A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials SPDC code + NN and check speech path between line A and B - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);   

    }
  
################################## Cleanup tms1287023 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287023 ##################################");

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
        if (grep /SCL/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => "SCL", -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCL from line $list_dn[0]");
            print FH "STEP: Remove SCL from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SCL from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287024 { #Callp service - SCS call to SIP line via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287024");

########################### Variables Declaration #############################
    my $tcid = "tms1287024";
    $tcid = "tms1287024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $flag = 1;
    my $calltrak_start = 0;
    my @callTrakLogs;
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");
# Get access code SPDC/SCPS for line A 
	my $spdc_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'SPDC');
    unless ($spdc_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SPDC access code for line $list_dn[0]");
		print FH "STEP: Get SPDC access code for line $list_dn[0] is $spdc_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get SPDC access code for line $list_dn[0] is $spdc_acc - PASS\n";
    }	

	my $scps_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'SCPS');
    unless ($scps_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SCPS access code for line $list_dn[0]");
		print FH "STEP: Get SCPS access code for line $list_dn[0] is $scps_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get SCPS access code for line $list_dn[0] is $scps_acc - PASS\n";
    }	

# Add SCS to line A
    unless ($ses_core->callFeature(-featureName => "SCS", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCS for line $list_dn[0]");
		print FH "STEP: add SCS for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add SCS for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;

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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A dials SCS code + N + DN (B) and hear confirmation tone then onhook
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
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = "\*$scps_acc";
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hears confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears confirmation tone - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }


    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = '0' . $trunk_access_code . $1;

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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

    sleep(3);
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(3);

# A dials SPDC code + N and check speech path between line A and B
    $dialed_num = "\*$spdc_acc" . '0';
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A dials SPDC code + N and check speech path between line A and B");
        print FH "STEP: A dials SPDC code + N and check speech path between line A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials SPDC code + N and check speech path between line A and B - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);       
    }
  
################################## Cleanup tms1287024 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287024 ##################################");

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
        if (grep /SCS/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => "SCS", -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCS from line $list_dn[0]");
            print FH "STEP: Remove SCS from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SCS from line $list_dn[0] - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}	
sub tms1287025 { #Callp service - CHD hold a call and make a new call to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case tms1287025");

########################### Variables Declaration #############################
    $tcid = "tms1287025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
    unless (grep /STRSHKN_ORIGID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
   

# Add CHD to line B
	unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CHD for line A $list_dn[1]");
		print FH "STEP: add CHD for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CHD for line B $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;
# Get CHD accesscode
	my $chd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'CHD');
    unless ($chd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CHD access code for line  $list_dn[1]");
		print FH "STEP: get CHD access code for line B $list_dn[1] is $chd_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CHD access code for line B $list_dn[1] is $chd_acc - PASS\n";
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Make call A to B and B flash
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST and B flash");
        print FH "STEP: A calls B via SST and B flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST and B flash - PASS\n";
    }
# B activates CHD 
	sleep(1);
	$dialed_num = "\*$chd_acc";
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: B dials acc_code CHD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials acc_code CHD - PASS\n";
    }
# B calls C
	# B dials DN (C)
    $dialed_num = $list_dn[2] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

	 %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial C successfully");
		print FH "STEP: B dials C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials C - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}
# Onhook B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(5);
# Check line B re-ringing
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
        print FH "STEP: Check line B re-ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B re-ring - PASS\n";
    }
# Offhook line B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287025 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287025 ##################################");

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
   # remove CHD from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CHD from line $list_dn[1]");
            print FH "STEP: Remove CHD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[1] - PASS\n";
        }
    }
    
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287026 { #Callp service - CWT verify call waiting from SIP line via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287026");

########################### Variables Declaration #############################
    $tcid = "tms1287026";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
    unless (grep /STRSHKN_ORIGID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
   

# Add CWT, CWI to line B 
    foreach ('CWT','CWI') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: Add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Add $_ for line $list_dn[1] - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
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
    $initialize_done = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Make call C to B and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls B via SST");
        print FH "STEP: C calls B via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls B via SST  - PASS\n";
    }
# A calls B and hear ringback tone
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
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

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
# # Check Ringback tone line A
#     %input = (
#                 -line_port => $list_line[0], 
#                 -freq1 => 450,
#                 -freq2 => 400,
#                 -tone_duration => 100,
#                 -cas_timeout => 50000, 
#                 -wait_for_event_time => $wait_for_event_time,
#                 );
#     unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
#         $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
#         print FH "STEP: A hear ringback tone - FAIL\n";
#         $result = 0;
#         goto CLEANUP;
#     } else {
#         print FH "STEP: A hear ringback tone - PASS\n";
#     }
# B flash to answer A
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
    sleep(2);

# Check speech path A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287026 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287026 ##################################");

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
    # remove CWI from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CWI', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CWI from line $list_dn[1]");
            print FH "STEP: Remove CWI from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CWI from line $list_dn[1] - PASS\n";
        }
    }
   # remove CWT from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CWT', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CWT from line $list_dn[1]");
            print FH "STEP: Remove CWT from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CWT from line $list_dn[1] - PASS\n";
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287027 { #Callp service - Verify DNH feature works fine with via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287027");

########################### Variables Declaration #############################
    $tcid = "tms1287027";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs, $dnh_added );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /STRSHKN_ENABLED/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
    unless (grep /STRSHKN_ORIGID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
   

# Add DNH group: A is pilot, B is member
    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
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
    $initialize_done = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Change line A status into MB in Mapci
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
        print FH "STEP: Make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Make line $list_dn[0] busy - PASS\n";
    }
    unless ($ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
    }
	
# C calls A and check speech path C&B 
    $dialed_num = $list_dn[0] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and check speech path C with B via SST");
        print FH "STEP: C calls A and C&B 2way speech path via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and C&B 2way speech path via SST - PASS\n";
    }


# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287027 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287027 ##################################");

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
    # Return line A status into IDL in Mapci
	unless ($ses_core -> execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0]; rts;")) {
       $logger->error(__PACKAGE__ . ": Could not rts $list_dn[0] ");
       print FH "STEP: Rts $list_dn[0] - FAIL\n";
       $result = 0; 
    } else {
       print FH "STEP: Rts $list_dn[0] - PASS\n"; 
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

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287028 { #Callp service - 1FR line make a basic call via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287028");

########################### Variables Declaration #############################
    $tcid = "tms1287028";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $un_line = 2124414321;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");

# chg line to 1FR
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[0], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => '3 212_AUTO L212_NILLA_0',
                );
        unless ($ses_core->resetLine(%input)) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] cannot reset");
            print FH "STEP: chg line $list_dn[0] to 1FR - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: chg line $list_dn[0] to 1FR - PASS\n";
        }
		
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[0])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not IDL");
            print FH "STEP: Check line $list_dn[0] status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[0] status- PASS\n";
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[1])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line B ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[1] status CPB - PASS\n";
            last;
        }
	}
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);  
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);

    }
  
################################## Cleanup tms1287028 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287028 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287029 { #Callp service - MLH make a basic call via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287029");

########################### Variables Declaration #############################
    $tcid = "tms1287029";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs, $mlh_added );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");


# Add MLH group: A is pilot, B is member
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add MLH
    $ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] IBN \$ DGT \$ 6 y y")) {
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
	$mlh_added = 1;
	

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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# Change line A status into MB in Mapci
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
        print FH "STEP: Make line $list_dn[0] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Make line $list_dn[0] busy - PASS\n";
    }
    unless ($ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
    }
	
# C calls A and check speech path C&B 
    $dialed_num = $list_dn[0] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and check speech path C with B via SST");
        print FH "STEP: C calls A and C&B 2way speech path via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and C&B 2way speech path via SST - PASS\n";
    }


# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287029 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287029 ##################################");

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
    # Return line A status into IDL in Mapci
	unless ($ses_core -> execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0]; rts;")) {
       $logger->error(__PACKAGE__ . ": Could not rts $list_dn[0] ");
       print FH "STEP: Rts $list_dn[0] - FAIL\n";
       $result = 0; 
    } else {
       print FH "STEP: Rts $list_dn[0] - PASS\n"; 
	}  
	
    # remove MLH
    if ($mlh_added) {
        $ses_core->execCmd("quit all");
        $ses_core->execCmd("servord");
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot delete member $list_dn[1] from MLH group");
            print FH "STEP: delete member $list_dn[1] from MLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from MLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
	

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287030 { #Callp service - MADN (SCA) make a basic call via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287030");

########################### Variables Declaration #############################
    $tcid = "tms1287030";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs, $mdn_added );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");


# Add MDN to line A as primary, Line B as member
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 3 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: add MDN to line $list_dn[0] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[0] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] ANCT \$ y y")){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'abort' ");
    }
    unless(grep /NUMBER ON INTERCEPT ANCT/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: add MDN to line $list_dn[1] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add MDN to line $list_dn[1] as member - PASS\n";
    }
    $mdn_added = 1;

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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;

# C calls A, A and B ring
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

    %input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[2]");
        print FH "STEP: C hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hear dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: C dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $dialed_num - PASS\n";
    }

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

# A answer and check speech path between A and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

    # Check speech path line A and C
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

# B offhook and check speech path among A, B and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    sleep(2);

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

# B onhook and check speech path between A and C again
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);
    # Check speech path line A and C
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

# B offhook and check speech path among A, B and C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    sleep(2);

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

# B onhook and check speech path between A and C again
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);
    # Check speech path line A and C
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
   
################################## Cleanup tms1287030 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287030 ##################################");

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
    # Remove MDN from line A and B 
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot remove line $list_dn[1] from MDN group");
            print FH "STEP: Remove line $list_dn[1] from MDN group - FAIL\n";
        } else {
            print FH "STEP: Remove line $list_dn[1] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[0] - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$tcid: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287031 { #Callp service - Simring make a call via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287031");

########################### Variables Declaration #############################
    $tcid = "tms1287031";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }


    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }
    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");


# Add simring for B and C
    $ses_core->execCmd("quit all");
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'servord'");
    }
    $ses_core->execCmd("est \$ SIMRING $list_dn[1] $list_dn[2] \+");
    unless ($ses_core->execCmd("\$ ACT N 1234 Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }

    @output = $ses_core->execCmd("qsimr $list_dn[1]");
    unless ((grep /Member DN 1 .* $list_dn[2]/, @output) and (grep /Pilot DN: .* $list_dn[1]/, @output)) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group SIMRING for line $list_dn[1] and $list_dn[2]");
		print FH "STEP: Create group SIMRING for line $list_dn[1] and $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group SIMRING for line $list_dn[1] and $list_dn[2] - PASS\n";
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
    $initialize_done = 1;

# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[2]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# A calls B and C ring
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['NONE','NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B ");
        print FH "STEP: A calls B  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B  - PASS\n";
    }
# Detect Sip Line Ring
	for (my $i = 0; $i <= 10; $i++){
        unless (grep /CPB/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->debug(__PACKAGE__ . " $tcid: Waiting for line C ringing");
            sleep (2);
        } else {
            print FH "STEP: Check line $list_dn[2] status CPB - PASS\n";
            last;
        }
	}

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);

    }
   
################################## Cleanup tms1287031 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287031 ##################################");

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

    # Remove service from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[1]");
            print FH "STEP: Remove SIMRING from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[1] - PASS\n";
        }
    }

    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287032 { #SDN make a call via SST trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1287032");

########################### Variables Declaration #############################
    $tcid = "tms1287032";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $add_feature_lineA = 0;
    my $un_line = 2124414321;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
     unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..8]], -password => [@{$core_account{-password}}[3..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
    }
# Add SDN $un_line 3P to line A
	unless ($ses_core->callFeature(-featureName => "SDN $un_line 3 P \$ \$", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line $list_dn[0]");
		print FH "STEP: Add SDN for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SDN for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst_sipp'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;


# A calls B and check speech path C&A 
    $dialed_num = $un_line =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $dialed_num,
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offA'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path C with A via SST");
        print FH "STEP: A calls B and A&C 2way speech path via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and C&A 2way speech path via SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+KINGOFKINGOFCVAR','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);  
    }
  
################################## Cleanup tms1287032 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287032 ##################################");

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
    # remove SDN from line A  
    $ses_core->execCmd("servord");
    if ($add_feature_lineA) {
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_dn[0] SDN $un_line \$ y y")) {
			unless($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . ".$tcid: Cannot command abort after Deo fail");
			print FH "STEP: Remove SDN from line $list_dn[0] - FAIL\n";
            }
        } else {
            print FH "STEP: Remove SDN from line $list_dn[0] - PASS\n";
        }
	}
	
    # Get PCM trace
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287033 { #OM_Verify Display oms : STRSHKN1 is support 
    $logger->debug(__PACKAGE__ . " Inside test case tms1287033");

########################### Variables Declaration #############################
    $tcid = "tms1287033";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
# option LTDATA STRSHKN ADMINENTERED 16 char
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /ADMINENTERED/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN 16 char");
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED - PASS\n";
    }
# config table ofcvar
    &table_ofcvar_default();
###################### Call flow ###########################
# omshow STRSHKN1 active
    $ses_core->{conn}->prompt('/\>/');
    unless (grep /STRSHKN1/, $ses_core->execCmd("omshow STRSHKN1 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN1 active");
        print FH "STEP: cannot omshow STRSHKN1 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN1 active - PASS\n";
    }
################################## Cleanup tms1287033 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287033 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    # &Luan_checkResult($tcid, $result, $execution_logs);
    &Luan_checkResult($tcid, $result);
}
sub tms1287034 { #OM_Verify Display oms : STRSHKN2 is support 
    $logger->debug(__PACKAGE__ . " Inside test case tms1287034");

########################### Variables Declaration #############################
    $tcid = "tms1287034";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
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
# option LTDATA STRSHKN ADMINENTERED 16 char
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /ADMINENTERED/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN 16 char");
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED - PASS\n";
    }
# config table ofcvar
    &table_ofcvar_default();
###################### Call flow ###########################
# mshow STRSHKN2 active
    $ses_core->{conn}->prompt('/\>/');
    unless (grep /STRSHKN2/, $ses_core->execCmd("omshow STRSHKN2 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN2 active");
        print FH "STEP: cannot omshow STRSHKN2 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN2 active - PASS\n";
    }
################################## Cleanup tms1287034 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287034 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    # &Luan_checkResult($tcid, $result, $execution_logs);
    &Luan_checkResult($tcid, $result);
}
sub tms1287035 { #Checking StrShkn Verstat OMs to be pegged properly for non-local calls 
    $logger->debug(__PACKAGE__ . " Inside test case tms1287035");

########################### Variables Declaration #############################
    $tcid = "tms1287035";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTB;
    my $ATTESTB1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..5]], -password => [@{$core_account{-password}}[3..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $ATTESTB = $1;
        }
    }
# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $ATTESTB1 = $1;
            last;
        }
    }
    if($ATTESTB != $ATTESTB1){
        print FH "STEP: ATTESTB ++  - PASS\n";
    }else{
        print FH "STEP: ATTESTB ++  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup tms1287035 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287035 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}  
sub tms1287036 { #Checking any StrShkn Attestation_Verstat OMs NOT to be pegged for local call 
    $logger->debug(__PACKAGE__ . " Inside test case tms1287036");

########################### Variables Declaration #############################
    $tcid = "tms1287036";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..5]], -password => [@{$core_account{-password}}[3..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $ATTESTA = $1;
        }
    }
# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $ATTESTA1 = $1;
            last;
        }
    }
    if($ATTESTA != $ATTESTA1){
        print FH "STEP: ATTESTA ++  - PASS\n";
    }else{
        print FH "STEP: ATTESTA ++  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
     
################################## Cleanup tms1287036 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287036 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1287037 { #Checking any StrShkn Verstat OMs NOT to be pegged for non-local calls if verstat value is built by core
    $logger->debug(__PACKAGE__ . " Inside test case tms1287037");

########################### Variables Declaration #############################
    $tcid = "tms1287037";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19_SV");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs );
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for Logutil - PASS\n";
    }
    unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_calltrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 for calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 for calltrak - PASS\n";
    }

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

    unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[3..5]], -password => [@{$core_account{-password}}[3..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core for Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core for Calltrak - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    &table_ofcvar_default();
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
 
# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli}) {
        $idl_num = 0;
        @output = $ses_core->execTRKCI(-cmd => 'TD', -nextParameter => $_);
        foreach (@output) {
            if (/tk_idle .* (\d+)/) {
                $idl_num = $1;
                last;
            }
        }
        unless ($idl_num) {
            $logger->error(__PACKAGE__ . " $tcid: number of IDL member of trunk $_ is less than 1");
            print FH "STEP: Check trunk $_ status - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check trunk $_ status- PASS\n";
        }
    }
    unless ($flag) {
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
                -username => [@{$core_account{-username}}[6..9]], 
                -password => [@{$core_account{-password}}[6..9]], 
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
# start Calltrak 
    %input = (-traceType => 'msgtrace', 
              -trunkName => [$db_trunk{'t15_sst'}{-clli}], 
              -dialedNumber => [$list_dn[0],$list_dn[1]]); 
    unless ($ses_calltrak->startCalltrak(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start Calltrak");
        print FH "STEP: start Calltrak - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: start Calltrak - PASS\n";
    }
    $calltrak_start = 1;
# omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $ATTESTA = $1;
        }
    }
# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
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
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via SST ");
        print FH "STEP: A calls B via SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /(\d+)\s+\d+\s+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $ATTESTA1 = $1;
            last;
        }
    }
    if($ATTESTA != $ATTESTA1){
        print FH "STEP: ATTESTA ++  - PASS\n";
    }else{
        print FH "STEP: ATTESTA ++  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
     
################################## Cleanup tms1287037 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1287037 ##################################");

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
    # Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
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
