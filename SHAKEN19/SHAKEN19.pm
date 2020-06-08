#**************************************************************************************************#
#FEATURE                : <SHAKEN AEN_19> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <LUAN NGUYEN THANH>
#cd /home/ylethingoc/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation_ATS/SHAKEN19/
#/usr/bin/runtest.sh `pwd` 
#perl -cw SHAKEN19.pm
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::Luan::Automation_ATS::SHAKEN19::SHAKEN19; 

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
our $SIPp_folder_file = "/home/$ENV{ USER }/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation_ATS/SHAKEN19";

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
                'tms1286676' => ['sip_1','gr303_2'],
                'tms1286677' => ['sip_1','gr303_1'],
                'tms1286678' => ['sip_1','gr303_1'],
                'tms1286679' => ['sip_1','gr303_1'],
                'tms1286680' => ['sip_1','gr303_1'],
                'tms1286681' => ['sip_1','gr303_1'],
                'tms1286682' => ['sip_1','gr303_1'],
                'tms1286683' => ['gr303_1','gr303_2'],
                'tms1286684' => ['sip_2','sip_1'],
                'tms1286685' => ['sip_2','sip_1'],
                'tms1286686' => ['sip_2','sip_1'],
                'tms1286687' => ['gr303_1','sip_1'],
                'tms1286688' => ['gr303_1','Sip_pbx'],
                'tms1286689' => ['gr303_1','sip_1'],
                'tms1286690' => ['gr303_1','Sip_pbx'],
                'tms1286691' => ['sip_2','sip_1'],
                'tms1286692' => ['sip_2','sip_1'],
                'tms1286693' => ['gr303_1','sip_1'],
                'tms1286694' => ['sip_2','gr303_1'],
                'tms1286695' => ['sip_2','sip_1'],
                'tms1286696' => ['sip_2','sip_1'],
                'tms1286697' => ['sip_2','sip_1'],
                'tms1286698' => ['sip_2','sip_1'],
                'tms1286699' => ['sip_2','sip_1'],
                'tms1286700' => ['gr303_1','sip_1'],
                'tms1286701' => ['gr303_1','sip_1'],
                'tms1286702' => ['gr303_1','sip_1'],
                'tms1286703' => ['gr303_1','sip_1'],
                'tms1286704' => ['gr303_1','sip_1'],
                'tms1286705' => ['gr303_1','sip_1'],
                'tms1286706' => ['gr303_1','sip_1'],
                'tms1286707' => ['gr303_1','sip_1'],
                'tms1286708' => ['gr303_1','sip_1'],
                'tms1286709' => ['gr303_1','sip_1'],
                'tms1286710' => ['gr303_1','sip_1'],
                'tms1286711' => ['gr303_1','sip_1'],
                'tms1286712' => ['sip_2','gr303_1'],
                'tms1286713' => ['sip_2','gr303_1'],
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
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
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
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
                    # "tms1286666",	#Provisioning_Activate de-activate SOC CS2C0009
                    # "tms1286667",	#Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS PASS
                    # "tms1286668",	#Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS FAIL
                    # "tms1286669",	#Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
                    # "tms1286670",	#Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat Y
                    # "tms1286671",	#Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat N
                    # "tms1286672",	#Provisioning_office parameters datafil control STRSHKN_Pass_Verstat Y
                    # "tms1286673",	#Provisioning_office parameters datafil control STRSHKN_Pass_Verstat N
                    # "tms1286674",	#OFCVAR tabaudit test
                    # "tms1286675",	#After restart warm, checking the OFCVAR Options
                    # "tms1286676",	#Core warm swact during signaling association , callp no dropped and we can establish a new call with Attestation and Tagging properly
                    # "tms1286677",	#GWC warm swact during signaling association ,callp no dropped and we can establish a new call with Attestation and Tagging properly
                    # "tms1286678",	#SST warm swact during signaling association, callp no dropped and we can establish a new call with Attestation and Tagging properly
                    # "tms1286679",	#Core cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
                    # "tms1286680",	#GWC cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
                    # "tms1286681",	#SST cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
                    # "tms1286682",	#Bsy_RTS the originator or DPT trunk during signaling association , callp dropped and we can establish a new call with Attestation and Tagging properly after recovered.
                    # "tms1286683",	#BSY_RTS_FRLS the originator or DPT trunk during signaling association , callp dropped and we can establish a new call with Attestation and Tagging properly after recovered.
                    # "tms1286684",	#For non_local calls, test by including different optional parameter in ATP with STRSHKN optional parameter
                    # "tms1286685",	#Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP Line
                    # "tms1286686",	#Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP_PBX
                    # "tms1286687",	#Verifying verstat parameter to be sent properly from Local Line to SIP Line
                    # "tms1286688",	#Verifying verstat parameter to be sent properly from Local Line to SIP_PBX
                    # "tms1286689",	#FAILwithjira Verifying verstat parameter to be sent properly from PRI to SIP Line
                    # "tms1286690",	#VFAILwithjira erifying verstat parameter to be sent properly from PRI to SIP_PBX
                    # "tms1286691",	#Verifying verstat parameter to be sent properly from SIP-PBX to SIP Line
                    # "tms1286692",	#Verifying verstat parameter to be sent properly from SIP_PBX to SIP_PBX
                    # "tms1286693",	#Verify he attestation value shall be used to build and pass a Verstat value to the terminating SIP endpoint Where line, PRI and SIP PBX originations (ie. line_PRI_SIP PBX to line scenarios) determine an attestation data in C20
                    # "tms1286694",	#Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A only.
                    # "tms1286695",	#Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A & B only
                    # "tms1286696",	#Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A, B and C.
                    # "tms1286697",	#Verify Verstat results shall be configurable based on the attestation level.   TN-Validation-Failed can be defined as B & C
                    # "tms1286698",	#Verify Verstat results shall be configurable based on the attestation level.   TN-Validation-Failed can be defined as C only.
                    # "tms1286699",	#Verify Verstat results shall be configurable based on the attestation level.   No-TN-Validation shall be applied where no attestation data is received.
                    # "tms1286700",	#After core and gwc mtc actions, checking the feature is still working.
                    # # "tms1286701",	#While SOC is IDLE, checking the feature is not working
                    # "tms1286702",	#While STRSHKN_Pass_Verstat is N, make sure the feature is NOT working for non-local calls
                    # "tms1286703",	#While STRSHKN_Build_Pass_Verstat is N , make sure the feature is NOT working for local calls
                    # "tms1286704",	#OM_Verify Display oms : STRSHKN1 is support 
                    # "tms1286705",	#OM_Verify Display oms : STRSHKN2 is support 
                    # "tms1286706",	#Checking StrShkn Verstat OMs to be pegged properly for non-local calls
                    # "tms1286707",	#Checking any StrShkn Attestation_Verstat OMs NOT to be pegged for local call
                    # "tms1286708",	#Checking any StrShkn Verstat OMs NOT to be pegged for non-local calls if verstat value is built by core
                    # "tms1286709",	#OM_Verify New OM STRSHKN value VERSTATA
                    # "tms1286710",	#OM_Verify New OM STRSHKN values : VERSTATB
                    # "tms1286711",	#OM_Verify New OM STRSHKN value VERSTATC
                    # "tms1286712",	#OM_Verify New OM STRSHKN value VPASSED
                    # "tms1286713",	#OM_Verify New OM STRSHKN value VFAILED
                    # "tms1303242",	#After restart cold, checking the OFCVAR Options
                    # "tms1303243",	#After restart reload, checking the OFCVAR Options
                    #  "tms1303244",	#Error path_set STRSHKN_ENABLED Y Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
                    #  "tms1303245",	#Error path_set STRSHKN_ENABLED Y N when The Stir Shaken SOC CS2B0009 is NOT Enabled
                    #  "tms1303246",	#Error path_set STRSHKN_ENABLED N Y when The Stir Shaken SOC CS2B0009 is NOT Enabled            
                    #  "tms1303247",	#Error path_Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping FAIL  FAIL FAIL
             
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
sub TC0 {
    $logger->debug(__PACKAGE__ . " Inside test case TC0");

########################### Variables Declaration #############################
    $tcid = "TC0";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
# - retest "TC25","TC26","TC31" with correcly line type
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
#jf start
  if (grep /confirm/, $ses_core->execCmd("jf start")) {
        $ses_core->execCmd("Y");
        print FH "STEP: jf start - PASS \n";
    } else {
        print FH "STEP: jf start JOURNAL FILE ALREADY STARTED\n";
    }
#translation line to SST
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
#translation line to Pri
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    unless (grep /$db_trunk{'t15_pri'}{-clli}/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'traver l $list_dn[0] $dialed_num b' ");
        print FH "STEP: fix translation line to SST\n";
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
################################## Cleanup 000 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 000 ##################################");


    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286666 { #Provisioning_Enable Disable SOC CS2C0009
    $logger->debug(__PACKAGE__ . " Inside test case tms1286666");

########################### Variables Declaration #############################
    $tcid = "tms1286666";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name,@TRKOPTS ,@temp );
    
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
# del config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ( /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    $TRKOPTS_config = 1;
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
    $LTDATA_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
        }
# Disable SOC
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
################################## Cleanup tms1286666 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286666 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286667 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS PASS
    $logger->debug(__PACKAGE__ . " Inside test case tms1286667");

########################### Variables Declaration #############################
    $tcid = "tms1286667";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS PASS");
################################## Cleanup tms1286667 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286667 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub tms1286668 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS FAIL
    $logger->debug(__PACKAGE__ . " Inside test case tms1286668");

########################### Variables Declaration #############################
    $tcid = "tms1286668";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS PASS FAIL");

################################## Cleanup tms1286668 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286668 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub tms1286669 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
    $logger->debug(__PACKAGE__ . " Inside test case tms1286669");

########################### Variables Declaration #############################
    $tcid = "tms1286669";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL FAIL");

################################## Cleanup tms1286669 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286669 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub tms1286670 { #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat Y
    $logger->debug(__PACKAGE__ . " Inside test case tms1286670");

########################### Variables Declaration #############################
    $tcid = "tms1286670";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Build_Pass_Verstat","Y");
   
################################## Cleanup tms1286670 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286670 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286671 { #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat N
    $logger->debug(__PACKAGE__ . " Inside test case tms1286671");
########################### Variables Declaration #############################
    $tcid = "tms1286671";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Build_Pass_Verstat","N");

################################## Cleanup tms1286671 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286671 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub tms1286672 { #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat  Y
    $logger->debug(__PACKAGE__ . " Inside test case tms1286672");

########################### Variables Declaration #############################
    $tcid = "tms1286672";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Pass_Verstat","Y");

################################## Cleanup tms1286672 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286672 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286673 { #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat  N
    $logger->debug(__PACKAGE__ . " Inside test case tms1286673");
########################### Variables Declaration #############################
    $tcid = "tms1286673";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Pass_Verstat","N");

################################## Cleanup tms1286673 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286673 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286674 { #OFCVAR tabaudit test
    $logger->debug(__PACKAGE__ . " Inside test case tms1286674");
########################### Variables Declaration #############################
    $tcid = "tms1286674";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
# OFCVAR tabaudit test
    $ses_core->execCmd("quit all");
    unless (grep /TABAUDIT/, $ses_core->execCmd("TABAUDIT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'TABAUDIT' ");
    }
    $ses_core->execCmd("INCLUDE OFCVAR");
    $ses_core->{conn}->prompt('/\>/');
    unless (grep /confirm/, $ses_core->execCmd("EXECUTE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'EXECUTE' ");
        print FH "STEP: execute command 'EXECUTE'  - FAIL\n";
        return 0;
        goto CLEANUP;
    } else {
        if (grep /failed 0/, $ses_core->execCmd("Y")) {            
                print FH "STEP: OFCVAR tabaudit test  - PASS\n";       
        }else{
            print FH "STEP: OFCVAR tabaudit test  - FAIL\n";
                return 0;
                goto CLEANUP;
        }  
    }

################################## Cleanup tms1286674 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286674 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286675 { #After restart warm, checking the OFCVAR Options
    $logger->debug(__PACKAGE__ . " Inside test case tms1286675");
########################### Variables Declaration #############################
    $tcid = "tms1286675";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
################################## Cleanup tms1286675 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286675 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286676 { #Core warm swact during signaling association , callp no dropped and we can establish a new call with Attestation and Tagging properly
    $logger->debug(__PACKAGE__ . " Inside test case tms1286676");

########################### Variables Declaration #############################
    $tcid = "tms1286676";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    
    $logger->debug(__PACKAGE__ . " $tcid: Sleep 800s wait core active" );
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
# Check speech path between A and B
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
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286676 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286676 ##################################");

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
sub tms1286677 { #GWC warm swact during signaling association ,callp no dropped and we can establish a new call with Attestation and Tagging properly
    $logger->debug(__PACKAGE__ . " Inside test case tms1286677");

########################### Variables Declaration #############################
    $tcid = "tms1286677";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless ($ses_cli1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
# Execute warm swact GWC during Call
	# Login cli mode from CLI session
    $ses_core->execCmd("logout");
    sleep(8);
	$ses_core ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	sleep(1);
	my @state_unit;
	unless (grep /active||standby/, @state_unit = $ses_core -> execCmd("aim si-assignment show gwc$gwc_id")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show gwc$gwc_id");
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - PASSED\n";
	}
	# Determine unit active on GWC-15
	my $unit_active;
	foreach (@state_unit){
		if ( /\s+(\d+)\s+SI_1\s+active/){
			$unit_active = $1;
			print FH "The unit active on GWC-$gwc_id is: $unit_active\n";
		} 
	}
    unless ($unit_active) {
        print FH "Can't get unit active \n";
        $result = 0;
        goto CLEANUP;
    }

	sleep(1);
	# Execue swact gwc for unit active  
	unless (grep /confirm/,$ses_core -> execCmd("aim service-unit swact gwc$gwc_id $unit_active f")){
		$logger->error(__PACKAGE__ . ": Can't swact gwc$gwc_id");
		print FH "STEP: swact unit $unit_active active on gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: swact unit $unit_active active on gwc$gwc_id - PASSED\n";
	}
	
	$ses_core->{conn}->print("y");
	sleep (15);
	
	# Check status of unit active after swact 
	$ses_cli1 ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_cli1 -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	unless (grep /active/, $ses_cli1 -> execCmd("aim si-assignment show gwc$gwc_id")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show gwc$gwc_id");
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - PASSED\n";
	}
	
	sleep(3);
# Check speech path between A and B
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
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286677 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286677 ##################################");

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
sub tms1286678 { #SST warm swact during signaling association, callp no dropped and we can establish a new call with Attestation and Tagging properly
    $logger->debug(__PACKAGE__ . " Inside test case tms1286678");

########################### Variables Declaration #############################
    $tcid = "tms1286678";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless ($ses_cli1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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

# Execute warm swact SST during Call
	# Login cli mode from CLI session
    $ses_core->execCmd("logout");
    sleep(8);
	$ses_core ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	sleep(1);
	my @state_unit;
	unless (grep /active||standby/, @state_unit = $ses_core -> execCmd("aim si-assignment show sst000")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show sst000");
		print FH "STEP: Enter command aim si-assignment show sst000 - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show sst000 - PASSED\n";
	}
	# Determine unit active on SST-15
	my $unit_active;
	foreach (@state_unit){
		if ( /\s+(\d+)\s+SI_1\s+active/){
			$unit_active = $1;
			print FH "The unit active on GWC-$gwc_id is: $unit_active\n";
		} 
	}
    unless ($unit_active) {
        print FH "Can't get unit active \n";
        $result = 0;
        goto CLEANUP;
    }
	sleep(1);
	# Execue swact SST for unit active  
	$ses_core -> execCmd("aim service-unit swact sst000 $unit_active f");
	print FH "STEP: swact unit $unit_active active on sst000 - PASSED\n";
	sleep (15);
	
	# Check status of unit active after swact 
	$ses_cli1 ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_cli1 -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	unless (grep /active/, $ses_cli1 -> execCmd("aim si-assignment show sst000")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show sst000");
		print FH "STEP: Enter command aim si-assignment show sst000 - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show sst000 - PASSED\n";
	}
	
	sleep(3);
# Check speech path between A and B
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
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286678 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286678 ##################################");

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

sub tms1286679 { #Core cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
    $logger->debug(__PACKAGE__ . " Inside test case tms1286679");

########################### Variables Declaration #############################
    $tcid = "tms1286679";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless ($ses_cli1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
    unless ($ses_cli1->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
# Cold Swact Core by cmd: restart cold active
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
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
    unless (grep /in\-sync/, $ses_core->execCmd("sosAgent vca show VCA")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot execCmd sosAgent vca show VCA");
        print FH "STEP: execCmd sosAgent vca show VCA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd sosAgent vca show VCA - PASS\n";
    }

    $ses_core->execCmd("sh");
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
    $ses_core->execCmd("restart cold active");
    @output = $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/Connection closed/', -timeout => 200)){
        $logger->error(__PACKAGE__ . ".$tcid: restart cold active");
        print FH "STEP: execCmd restart cold active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd restart cold active - PASS\n";
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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }  
# detectNoTestToneCAS
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[0], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[1], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  still have speech path with $list_dn[0]");
        $flag = 0;
    }
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[1], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[0], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  still have speech path with $list_dn[1]");
        $flag = 0;
    }
    unless ($flag){
        print FH "STEP: Speech path is down after restart cold Core  - FAIL\n";
        $result = 0;
    }else{
        print FH "STEP: Speech path is down after restart cold Core - PASS\n";
    }
# Check line status of A and B
    unless (grep /IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[0]");
        print FH "STEP: Check line A status IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A status IDL - PASS\n";
    }
    unless (grep /IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[1] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[1]");
        print FH "STEP: Check line B status IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B status IDL - PASS\n";
    }
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286679 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286679 ##################################");

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
sub tms1286680 { #GWC cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
    $logger->debug(__PACKAGE__ . " Inside test case tms1286680");

########################### Variables Declaration #############################
    $tcid = "tms1286680";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless ($ses_cli1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
# Execute cold swact GWC during Call
	# Login cli from CLI session
    $ses_core->execCmd("logout");
    sleep(8);
	$ses_core ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	sleep(1);
	my @state_unit;
	unless (grep /active||standby/, @state_unit = $ses_core -> execCmd("aim si-assignment show gwc$gwc_id")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show gwc$gwc_id");
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - PASSED\n";
	}

	# Execue swact gwc 
	unless (grep /confirm/,$ses_core -> execCmd("gwc gwc-sg-mtce cold-swact gwc$gwc_id ")){
		$logger->error(__PACKAGE__ . ": Can't swact gwc$gwc_id");
		print FH "STEP: gwc gwc-sg-mtce cold-swact gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: gwc gwc-sg-mtce cold-swact gwc$gwc_id - PASSED\n";
	}
	
	$ses_core->{conn}->print("y");
	sleep (200);
	
	# Check status of unit active after swact 
	$ses_cli1 ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_cli1 -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	unless (grep /active/, $ses_cli1 -> execCmd("aim si-assignment show gwc$gwc_id")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show gwc$gwc_id");
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - PASSED\n";
	}
	
	sleep(3);
# detectNoTestToneCAS
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[0], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[1], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  still have speech path with $list_dn[0]");
        $flag = 0;
    }
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[1], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[0], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  still have speech path with $list_dn[1]");
        $flag = 0;
    }
    unless ($flag){
        print FH "STEP: Speech path is down after cold swact GWC - FAIL\n";
        $result = 0;
    }else{
        print FH "STEP: Speech path is down after cold swact GWC - PASS\n";
    }
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286680 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286680 ##################################");

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
sub tms1286681 { #SST cold swact during signaling association , callp dropped, check the recovery and we can establish a new call with Attestation and Tagging properly after that
    $logger->debug(__PACKAGE__ . " Inside test case tms1286681");

########################### Variables Declaration #############################
    $tcid = "tms1286681";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless ($ses_cli1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
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
    unless ($ses_cli1->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
# Execute cold swact SST during Call
	# Login cli cold from CLI session
    $ses_core->execCmd("logout");
    sleep(8);
	$ses_core ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_core -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	sleep(1);
	my @state_unit;
	unless (grep /active||standby/, @state_unit = $ses_core -> execCmd("aim si-assignment show sst000")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show sst000");
		print FH "STEP: Enter command aim si-assignment show sst000 - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show sst000 - PASSED\n";
	}
    # Execue swact SST 
	unless (grep /confirm/,$ses_core -> execCmd("sst sst-sg-maintenance cold-swact sst000 ")){
		$logger->error(__PACKAGE__ . ": Can't swact gwc$gwc_id");
		print FH "STEP: sst sst-sg-maintenance cold-swact sst000 - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: sst sst-sg-maintenance cold-swact sst000 - PASSED\n";
	}
	
	$ses_core->{conn}->print("y");
	sleep (200);
	
	# Check status of unit active after swact 
	$ses_cli1 ->{conn}->prompt('/>/');
	unless (grep /cli/, $ses_cli1 -> execCmd("cli")){
		$logger->error(__PACKAGE__ . ": Can't login to cli mode");
		print FH "STEP: Login to cli mode from CLI session - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Login to cli mode from CLI session - PASSED\n";
	}
	unless (grep /active/, $ses_cli1 -> execCmd("aim si-assignment show sst000")){
		$logger->error(__PACKAGE__ . ": Can't enter command aim si-assignment show sst000");
		print FH "STEP: Enter command aim si-assignment show sst000 - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "STEP: Enter command aim si-assignment show gwc$gwc_id - PASSED\n";
	}
	
	sleep(3);
# detectNoTestToneCAS
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[0], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[1], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  still have speech path with $list_dn[0]");
        $flag = 0;
    }
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[1], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[0], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  still have speech path with $list_dn[1]");
        $flag = 0;
    }
    unless ($flag){
        print FH "STEP: Speech path is down after cold swact SST  - FAIL\n";
        $result = 0;
    }else{
        print FH "STEP: Speech path is down after cold swact SST  - PASS\n";
    }
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
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
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286681 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286681 ##################################");

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
sub tms1286682 { #Bsy_RTS the originator or DPT trunk during signaling association , callp dropped and we can establish a new call with Attestation and Tagging properly after recovered.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286682");

########################### Variables Declaration #############################
    $tcid = "tms1286682";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
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
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
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
# pos trk Bsy_RTS in Mapci
    $ses_core->{conn}->prompt('/\>$/');
    my @cmd_result;
    my $status;
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post SSTSHAKEN'");
        print FH "STEP: Execution cmd 'post SSTSHAKEN' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post SSTSHAKEN' - PASS\n";
    }
    my $i = 0;
    foreach(@cmd_result){
         s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
         s/[^a-zA-Z0-9, _, :]K//g;
         s/[^a-zA-Z0-9, _, :]8//g;
         s/[^a-zA-Z0-9, _, :]7//g;
         s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
         s/[^a-zA-Z0-9, _, :]0m//g;
         s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_");
        if( /(SSTSHAKEN\s+\w+)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
            print FH "STEP: Verify SST state on the mapci => Output: $status - PASS\n";
        }       
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;trks;DPTRKS;post g SSTSHAKEN");
    unless (grep /RES/, $ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify SST is busy successfully");
        print FH "STEP: Verify SST is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify SST is busy successfully - PASS\n";
    }
# detectNoTestToneCAS
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[0], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[1], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  still have speech path with $list_dn[0]");
        $flag = 0;
    }
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[1], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[0], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  still have speech path with $list_dn[1]");
        $flag = 0;
    }
    unless ($flag){
        print FH "STEP: Speech path is down after Bsy SST - FAIL\n";
        $result = 0;
    }else{
        print FH "STEP: Speech path is down after Bsy SST - PASS\n";
    }

    $ses_core->execCmd("mapci nodisp;mtc;trks;DPTRKS;post g SSTSHAKEN");
    $ses_core->execCmd("rts");
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN");
    foreach(@cmd_result){
         s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
         s/[^a-zA-Z0-9, _, :]K//g;
         s/[^a-zA-Z0-9, _, :]8//g;
         s/[^a-zA-Z0-9, _, :]7//g;
         s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
         s/[^a-zA-Z0-9, _, :]0m//g;
         s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_"); 
    }
    unless (grep /SSTSHAKEN\s+INS/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify SST is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify SST is returned successfully to Insv state - PASS\n";
    }
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
    
################################## Cleanup tms1286682 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286682 ##################################");

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
sub tms1286683 { #BSY_RTS_FRLS the originator or DPT trunk during signaling association , callp dropped and we can establish a new call with Attestation and Tagging properly after recovered.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286683");

########################### Variables Declaration #############################
    $tcid = "tms1286683";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
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
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
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
# pos trk Bsy_RTS in Mapci
    $ses_core->{conn}->prompt('/\>$/');
    my @cmd_result;
    my $status;
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post SSTSHAKEN'");
        print FH "STEP: Execution cmd 'post SSTSHAKEN' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post SSTSHAKEN' - PASS\n";
    }
    my $i = 0;
    foreach(@cmd_result){
         s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
         s/[^a-zA-Z0-9, _, :]K//g;
         s/[^a-zA-Z0-9, _, :]8//g;
         s/[^a-zA-Z0-9, _, :]7//g;
         s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
         s/[^a-zA-Z0-9, _, :]0m//g;
         s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_");
        if( /(SSTSHAKEN\s+\w+)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
            print FH "STEP: Verify SST state on the mapci => Output: $status - PASS\n";
        }       
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;trks;DPTRKS;post g SSTSHAKEN");
    unless (grep /RES/, $ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify SST is busy successfully");
        print FH "STEP: Verify SST is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify SST is busy successfully - PASS\n";
    }
    # Check speech path between A and B
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

    $ses_core->execCmd("mapci nodisp;mtc;trks;DPTRKS;post g SSTSHAKEN");
    unless (grep /confirm/, $ses_core->execCmd("frls all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot cfrls all");
        print FH "STEP: frls all - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        $ses_core->execCmd("y");
        print FH "STEP: frls all - PASS\n";
    }
# detectNoTestToneCAS
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[0], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[1], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  still have speech path with $list_dn[0]");
        $flag = 0;
    }
    unless ($ses_glcas->sendTestToneCAS(-line_port => $list_line[1], -test_tone_duration => '1000', -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[1]  cannot send test tone");
    }
    unless ($ses_glcas->detectNoTestToneCAS(-line_port => $list_line[0], -cas_timeout => 50000 , -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_line[0]  still have speech path with $list_dn[1]");
        $flag = 0;
    }
    unless ($flag){
        print FH "STEP: Speech path is down after locking frls SST - FAIL\n";
        $result = 0;
    }else{
        print FH "STEP: Speech path is down after locking frls SST- PASS\n";
    }
    $ses_core->execCmd("rts");
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN");
    foreach(@cmd_result){
         s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
         s/[^a-zA-Z0-9, _, :]K//g;
         s/[^a-zA-Z0-9, _, :]8//g;
         s/[^a-zA-Z0-9, _, :]7//g;
         s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
         s/[^a-zA-Z0-9, _, :]0m//g;
         s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_"); 
    }
    unless (grep /SSTSHAKEN\s+INS/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify SST is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify SST is returned successfully to Insv state - PASS\n";
    }
# Hang up line A,B
    foreach ($list_line[0], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }


# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
    #onhook A
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(2);
    #onhook B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
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
        unless ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup tms1286683 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286683 ##################################");

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
sub tms1286684 { #For non_local calls, test by including different optional parameter in ATP with STRSHKN optional parameter
    $logger->debug(__PACKAGE__ . " Inside test case tms1286684");

########################### Variables Declaration #############################
    $tcid = "tms1286684";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
      }
    
################################## Cleanup tms1286684 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286684 ##################################");

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
sub tms1286685 { #Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1286685");

########################### Variables Declaration #############################
    $tcid = "tms1286685";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    
################################## Cleanup tms1286685 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286685 ##################################");

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
sub tms1286686 { #Verifying verstat parameter to be sent properly from Incoming SIP Trunk to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1286686");

########################### Variables Declaration #############################
    $tcid = "tms1286686";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    
################################## Cleanup tms1286686 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286686 ##################################");

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
sub tms1286687 { #Verifying verstat parameter to be sent properly from Local Line to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1286687");

########################### Variables Declaration #############################
    $tcid = "tms1286687";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286687 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286687 ##################################");

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
sub tms1286688 { #Verifying verstat parameter to be sent properly from Local Line to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1286688");

########################### Variables Declaration #############################
    $tcid = "tms1286688";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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

# Check Trunk status
    my $idl_num;
    foreach ($db_trunk{'t15_sst'}{-clli},$db_trunk{'t15_bpx'}{-clli}) {
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','VERSTAT DATA\s+:\s+PASSED', @callTrakLogs);
    }
    
################################## Cleanup tms1286688 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286688 ##################################");

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
sub tms1286689 { #Verifying verstat parameter to be sent properly from PRI to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1286689");

########################### Variables Declaration #############################
    $tcid = "tms1286689";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL PASS");
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
                -detect => ['RINGING'], #'RINGBACK','RINGING'
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
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
    
################################## Cleanup tms1286689 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286689 ##################################");

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
sub tms1286690 { #Verifying verstat parameter to be sent properly from PRI to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1286690");

########################### Variables Declaration #############################
    $tcid = "tms1286690";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL PASS");
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
                -detect => ['RINGING'], #'RINGBACK','RINGING'
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
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


# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','VERSTAT DATA\s+:\s+PASSED', @callTrakLogs);
    }
    
################################## Cleanup tms1286690 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286690 ##################################");

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
sub tms1286691 { #Verifying verstat parameter to be sent properly from SIP-PBX to SIP Line
    $logger->debug(__PACKAGE__ . " Inside test case tms1286691");

########################### Variables Declaration #############################
    $tcid = "tms1286691";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL PASS");

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
  
################################## Cleanup tms1286691 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286691 ##################################");

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
sub tms1286692 { #Verifying verstat parameter to be sent properly from SIP_PBX to SIP_PBX
    $logger->debug(__PACKAGE__ . " Inside test case tms1286692");

########################### Variables Declaration #############################
    $tcid = "tms1286692";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL PASS");

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
  
################################## Cleanup tms1286692 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286692 ##################################");

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
sub tms1286693 { #Verify the attestation value shall be used to build and pass a Verstat value to the terminating SIP endpoint Where line, PRI and SIP PBX originations (ie. line_PRI_SIP PBX to line scenarios) determine an attestation data in C20
    $logger->debug(__PACKAGE__ . " Inside test case tms1286693");

########################### Variables Declaration #############################
    $tcid = "tms1286693";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &cha_table_ofcvar("STRSHKN_Verstat_Mapping","PASS FAIL PASS");
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
                -detect => ['RINGING'], #'RINGBACK','RINGING'
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
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
    
################################## Cleanup tms1286693 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286693 ##################################");

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
sub tms1286694 { #Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A only.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286694");

########################### Variables Declaration #############################
    $tcid = "tms1286694";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs, );
    
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
    
################################## Cleanup tms1286694 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286694 ##################################");

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
sub tms1286695 { #Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A & B only.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286695");

########################### Variables Declaration #############################
    $tcid = "tms1286695";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    
################################## Cleanup tms1286695 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286695 ##################################");

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
sub tms1286696 { #Verify Verstat results shall be configurable based on the attestation level. TN-Validation-Passed can be defined as A, B and C.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286696");

########################### Variables Declaration #############################
    $tcid = "tms1286696";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286696.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+C', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+C', @callTrakLogs);
    }
    
################################## Cleanup tms1286696 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286696 ##################################");

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
sub tms1286697 { #Verify Verstat results shall be configurable based on the attestation level.   TN-Validation-Failed can be defined as B & C.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286697");

########################### Variables Declaration #############################
    $tcid = "tms1286697";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286697.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION FAILED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+FAILED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);

    }
    
################################## Cleanup tms1286697 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286697 ##################################");

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
sub tms1286698 { #Verify Verstat results shall be configurable based on the attestation level.   TN-Validation-Failed can be defined as C only.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286698");

########################### Variables Declaration #############################
    $tcid = "tms1286698";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286698.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION FAILED','STRSHKN_ATTESTATION\s+:\s+C', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+FAILED','STRSHKN_ATTESTATION\s+:\s+C', @callTrakLogs);

    }
    
################################## Cleanup tms1286698 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286698 ##################################");

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
sub tms1286699 { #Verify Verstat results shall be configurable based on the attestation level.   No-TN-Validation shall be applied where no attestation data is received..
    $logger->debug(__PACKAGE__ . " Inside test case tms1286699");

########################### Variables Declaration #############################
    $tcid = "tms1286699";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286699.xml");
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+NOINFO','VERSTAT DATA\s+:\s+NO INFO', @callTrakLogs);
    }
    
################################## Cleanup tms1286699 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286699 ##################################");

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
sub tms1286700 { #After core and gwc mtc actions, checking the feature is still working.
    $logger->debug(__PACKAGE__ . " Inside test case tms1286700");

########################### Variables Declaration #############################
    $tcid = "tms1286700";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        $result = &check_log('DATA CHARS\s+:\s+','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
    
################################## Cleanup tms1286700 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286700 ##################################");

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
sub tms1286701 { #While SOC is IDLE, checking the feature is not working
    $logger->debug(__PACKAGE__ . " Inside test case tms1286701");

########################### Variables Declaration #############################
    $tcid = "tms1286701";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs,@temp );
    
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
# Disable SOC
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - Pass\n";
        }
    }
# Enable SOC
    if (grep /Shaken.*IDLE/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Disable ");
        if (grep /Done/, $ses_core->execCmd("assign rtu JFCM9397UKE4YRCGBWGZ to CS2C0009")) {            
                print FH "STEP: Enable rtu  CS2C0009 - PASS \n";         
        }else{
        print FH "STEP: Enable rtu  CS2C0009 - Failed \n";
        }
        if (grep /enabled/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Enable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Enable option CS2C0009 - PASS \n";
    }
 
################################## Cleanup tms1286701 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286701 ##################################");

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
sub tms1286702 { #While STRSHKN_Pass_Verstat is N, make sure the feature is NOT working for non-local calls 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286702");

########################### Variables Declaration #############################
    $tcid = "tms1286702";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
# config table ofcvar STRSHKN_Pass_Verstat
    $result = &cha_table_ofcvar("STRSHKN_Pass_Verstat","N");

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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup tms1286702 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286702 ##################################");

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
sub tms1286703 { #While STRSHKN_Build_Pass_Verstat is N, make sure the feature is NOT working for non-local calls 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286703");

########################### Variables Declaration #############################
    $tcid = "tms1286703";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
# config table ofcvar STRSHKN_Build_Pass_Verstat
    $result = &cha_table_ofcvar("STRSHKN_Build_Pass_Verstat","N");

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
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup tms1286703 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286703 ##################################");

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
sub tms1286704 { #OM_Verify Display oms : STRSHKN1 is support 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286704");

########################### Variables Declaration #############################
    $tcid = "tms1286704";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#option LTDATA STRSHKN ADMINENTERED 16 char
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
#omshow STRSHKN1 active
    $ses_core->{conn}->prompt('/\>/');
    unless (grep /ISDN\s+85/, $ses_core->execCmd("omshow STRSHKN1 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN1 active");
        print FH "STEP: cannot omshow STRSHKN1 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN1 active - PASS\n";
    }
################################## Cleanup tms1286704 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286704 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286705 { #OM_Verify Display oms : STRSHKN2 is support 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286705");

########################### Variables Declaration #############################
    $tcid = "tms1286705";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#option LTDATA STRSHKN ADMINENTERED 16 char
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
#omshow STRSHKN2 active
    $ses_core->{conn}->prompt('/\>/');
    unless (grep /STRSHKN2/, $ses_core->execCmd("omshow STRSHKN2 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN2 active");
        print FH "STEP: cannot omshow STRSHKN2 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN2 active - PASS\n";
    }
################################## Cleanup tms1286705 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286705 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1286706 { #Checking StrShkn Verstat OMs to be pegged properly for non-local calls 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286706");

########################### Variables Declaration #############################
    $tcid = "tms1286706";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#omshow STRSHKN active
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
#omshow STRSHKN active
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
    
################################## Cleanup tms1286706 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286706 ##################################");

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
sub tms1286707 { #Checking any StrShkn Attestation_Verstat OMs NOT to be pegged for local call 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286707");

########################### Variables Declaration #############################
    $tcid = "tms1286707";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#omshow STRSHKN active
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
#omshow STRSHKN active
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
    
################################## Cleanup tms1286707 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286707 ##################################");

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
sub tms1286708 { #Checking any StrShkn Verstat OMs NOT to be pegged for non-local calls if verstat value is built by core
    $logger->debug(__PACKAGE__ . " Inside test case tms1286708");

########################### Variables Declaration #############################
    $tcid = "tms1286708";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#omshow STRSHKN active
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
#omshow STRSHKN active
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
    
################################## Cleanup tms1286708 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286708 ##################################");

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
sub tms1286709 { #OM_Verify New OM STRSHKN values : VERSTATA 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286709");

########################### Variables Declaration #############################
    $tcid = "tms1286709";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#omshow STRSHKN active
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
#omshow STRSHKN active
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
    
################################## Cleanup tms1286709 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286709 ##################################");

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
sub tms1286710 { #OM_Verify New OM STRSHKN values : VERSTATB 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286710");

########################### Variables Declaration #############################
    $tcid = "tms1286710";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+(\d+)\s+/) {
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
#omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+(\d+)\s+/) {
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
        unless ((grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup tms1286710 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286710 ##################################");

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
sub tms1286711 { #OM_Verify New OM STRSHKN values : VERSTATC 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286711");

########################### Variables Declaration #############################
    $tcid = "tms1286711";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTC;
    my $ATTESTC1;
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
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+\d+\s+(\d+)/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $ATTESTC = $1;
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
#omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+\d+\s+(\d+)/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $ATTESTC1 = $1;
            last;
        }
    }
    if($ATTESTC != $ATTESTC1){
        print FH "STEP: ATTESTC ++  - PASS\n";
    }else{
        print FH "STEP: ATTESTC ++  - FAIL\n";
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
    
################################## Cleanup tms1286711 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286711 ##################################");

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
sub tms1286712 { #OM_Verify New OM STRSHKN values : VPASSED 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286712");

########################### Variables Declaration #############################
    $tcid = "tms1286712";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $VPASSED;
    my $VPASSED1;
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
# Check line status
    for (my $i = 0; $i <= $#list_dn; $i++){
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[$i], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $list_line_info[$i]
                );
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
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+\d+\s+\d+\s+(\d+)/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $VPASSED = $1;
        }
    }
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
#omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ( /\d+\s+\d+\s+\d+\s+(\d+)/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $VPASSED1 = $1;
            last;
        }
    }
    if($VPASSED != $VPASSED1){
        print FH "STEP: VPASSED ++  - PASS\n";
    }else{
        print FH "STEP: VPASSED ++  - FAIL\n";
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
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+PASSED','STRSHKN_ATTESTATION\s+:\s+A', @callTrakLogs);
    }
      
################################## Cleanup tms1286712 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286712 ##################################");

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
sub tms1286713 { #OM_Verify New OM STRSHKN values : VFAILED 
    $logger->debug(__PACKAGE__ . " Inside test case tms1286713");

########################### Variables Declaration #############################
    $tcid = "tms1286713";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $VFAILED;
    my $VFAILED1;
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
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    print Dumper \$output[-3];
        if ($output[-3] =~ /(\d+)\s+\d+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived");
            print FH "STEP: omshow STRSHKN active - PASS\n";
            $VFAILED = $1;
        }

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
    $result = &ACallBViaSSTBySipp($ipsst, $SIPp_folder_file, $ipats, "tms1286697.xml");
#omshow STRSHKN active
    @output = $ses_core->execCmd("omshow STRSHKN active");
    print Dumper \$output[-3];
        if ($output[-3] =~ /(\d+)\s+\d+/) {
            $logger->error(__PACKAGE__ . " $tcid: cmd omshow STRSHKN actived check");
            print FH "STEP: omshow STRSHKN active check - PASS\n";
            $VFAILED1 = $1;
        }
    
    if($VFAILED != $VFAILED1){
        print FH "STEP: VFAILED ++  - PASS\n";
    }else{
        print FH "STEP: VFAILED ++  - FAIL\n";
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
        $result = &check_log('STRSHKN_VERSTAT\s+:\s+VERIFICATION FAILED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);
        $result = &check_log('VERSTAT DATA\s+:\s+FAILED','STRSHKN_ATTESTATION\s+:\s+B', @callTrakLogs);

    }
     
################################## Cleanup tms1286713 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1286713 ##################################");

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
sub tms1303242 { #After restart cold, checking the OFCVAR Options
    $logger->debug(__PACKAGE__ . " Inside test case tms1303242");
########################### Variables Declaration #############################
    $tcid = "tms1303242";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
################################## Cleanup tms1303242 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303242 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}    
sub tms1303243 { #After restart reload, checking the OFCVAR Options
    $logger->debug(__PACKAGE__ . " Inside test case tms1303243");
########################### Variables Declaration #############################
    $tcid = "tms1303243";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
################################## Cleanup tms1303243 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303243 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1303244 { #Error path_set STRSHKN_ENABLED Y Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case tms1303244");

########################### Variables Declaration #############################
    $tcid = "tms1303244";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name,@TRKOPTS ,@temp );
    
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
# Disable SOC
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
    $ses_core->execCmd("quit all");
# config table ofcvar
    if( &cha_table_ofcvar("STRSHKN_ENABLED","Y Y")){
        $result = 1;
    }
    $ses_core->execCmd("quit all");
# Enable SOC
   if (grep /exceeded/, $ses_core->execCmd("SOC")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'SOC' ");
            print FH "STEP: execute command 'SOC' - FAIL\n";
            $result = 0;
            goto CLEANUP;
    }
    if (grep /Shaken.*IDLE/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Disable ");
        if (grep /entering/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Disable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Disable option CS2C0009 - PASS \n";
    }
################################## Cleanup tms1303244 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303244 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1303245 { #Error path_set STRSHKN_ENABLED Y N when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case tms1303245");

########################### Variables Declaration #############################
    $tcid = "tms1303245";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name,@TRKOPTS ,@temp );
    
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
# Disable SOC
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
    $ses_core->execCmd("quit all");
# config table ofcvar
    if( &cha_table_ofcvar("STRSHKN_ENABLED","Y N")){
        $result = 1;
    }
    $ses_core->execCmd("quit all");
# Enable SOC
   if (grep /exceeded/, $ses_core->execCmd("SOC")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'SOC' ");
            print FH "STEP: execute command 'SOC' - FAIL\n";
            $result = 0;
            goto CLEANUP;
    }
    if (grep /Shaken.*IDLE/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Disable ");
        if (grep /entering/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Disable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Disable option CS2C0009 - PASS \n";
    }
################################## Cleanup tms1303245 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303245 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1303246 { #Error path_set STRSHKN_ENABLED N Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case tms1303246");

########################### Variables Declaration #############################
    $tcid = "tms1303246";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name,@TRKOPTS ,@temp );
    
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
# Disable SOC
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
    $ses_core->execCmd("quit all");
# config table ofcvar
    if( &cha_table_ofcvar("STRSHKN_ENABLED","N Y")){
        $result = 1;
    }
    $ses_core->execCmd("quit all");
# Enable SOC
   if (grep /exceeded/, $ses_core->execCmd("SOC")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'SOC' ");
            print FH "STEP: execute command 'SOC' - FAIL\n";
            $result = 0;
            goto CLEANUP;
    }
    if (grep /Shaken.*IDLE/,@temp = $ses_core->execCmd("select option CS2C0009")) {
        $logger->error(__PACKAGE__ . " $tcid: option CS2C0009  is Disable ");
        if (grep /entering/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Disable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Disable option CS2C0009 - PASS \n";
    }
################################## Cleanup tms1303246 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303246 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1303247 { #Error path_Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
    $logger->debug(__PACKAGE__ . " Inside test case tms1303247");

########################### Variables Declaration #############################
    $tcid = "tms1303247";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN19");

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
    if( &cha_table_ofcvar("STRSHKN_Verstat_Mapping","FAIL FAIL FAIL")){
        $result = 1;
    }
################################## Cleanup tms1303247 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1303247 ##################################");

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
