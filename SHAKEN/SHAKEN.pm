#**************************************************************************************************#
#FEATURE                : <SHAKEN> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <LUAN NGUYEN THANH>
#cd /home/ylethingoc/ats_repos/lib/perl/QATEST/C20_EO/Luan/Automation-ATS/SHAKEN/
#/usr/bin/runtest.sh `pwd` 
#perl -cw SHAKEN.pm
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::Luan::Automation-ATS::SHAKEN::SHAKEN; 

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
our ($ses_core, $ses_glcas, $ses_logutil,$ses_calltrak, $ses_tapi, $ses_ats);
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
                'gr303_3' => {
                            -line => 46,
                            -dn => 2124414012,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 03',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'gr303_4' => {
                            -line => 45,
                            -dn => 2124414013,
                            -region => 'US',
                            -len => 'AZTK   00 9 00 04',
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
                            -dn => 2124409575,
                            -region => 'US',
                            -len => 'SL10   00 0 00 75',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0 ',
                            },

                );

our %tc_line = ('TC0' => ['pbx','sip_1'],
                'TC18' => ['Sip_pbx','gr303_2'],
                'TC19' => ['gr303_1','gr303_2'],
                'TC20' => ['gr303_1','gr303_2'],
                'TC21' => ['gr303_1','gr303_2'],
                'TC22' => ['gr303_1','gr303_2'],
                'TC25' => ['Sip_pbx','gr303_2'],
                'TC26' => ['pbx','gr303_2'],
                'TC27' => ['sip_1','gr303_2'],
                'TC28' => ['sip_1','gr303_2'],
                'TC29' => ['gr303_1','gr303_2'],
                'TC31' => ['sip_1','gr303_2'],
                'TC32' => ['sip_1','gr303_2'],
                'TC33' => ['sip_1','gr303_2'],
                'TC34' => ['sip_1','gr303_2'],
                'TC38' => ['sip_1','gr303_2'],
                'TC39' => ['gr303_1','gr303_2'],
                'TC40' => ['Sip_pbx','gr303_2'],
                'TC41' => ['pbx','gr303_2'],
                'TC42' => ['Sip_pbx','gr303_2'],
                'TC43' => ['gr303_1','gr303_2'],
                'TC44' => ['pbx','gr303_2'],
                'TC45' => ['Sip_pbx','gr303_2'],
                'TC46' => ['gr303_1','gr303_2','pbx'],
                'TC49' => ['gr303_1','gr303_2','pbx'],
                'TC50' => ['gr303_1','gr303_2','sip_1'],
                'TC51' => ['gr303_1','sip_1'],
                'TC52' => ['gr303_1','sip_1','gr303_2'],
                'TC53' => ['gr303_1','sip_1','gr303_2'],
                'TC54' => ['gr303_1','sip_1'],
                'TC55' => ['gr303_1','sip_1'],
                'TC56' => ['gr303_1','sip_1'],
                'TC57' => ['gr303_1','sip_1'],
                'TC58' => ['gr303_1','sip_1'],
                'TC59' => ['gr303_1','sip_1'],
                'TC68' => ['gr303_1','sip_1'],
                'TC70' => ['Sip_pbx','gr303_2'],
                'TC71' => ['gr303_1','gr303_2'],
                'TC72' => ['Sip_pbx','gr303_2'],
                'TC80' => ['Sip_pbx','gr303_2'],
                'TC81' => ['Sip_pbx','gr303_2'],
                'TCtest' => ['gr303_1','gr303_2'],

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
                't15_pri' =>{
                                -acc => 504,  #200 #504
                                -region => 'US',
                                -clli => 'T15G9PRINT2W' , # T15G9PRINT2W #G6VZSTSPRINT2W
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
                    $ses_core, $ses_glcas, $ses_logutil,$ses_calltrak, $ses_tapi
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
                    # "TC0", #set up lab
                    # "TC1", #Provisioning_Activate de-activate patch.
                    # "TC2", #Provisioning_office parameters datafil control strshkn_enabled y y
                    # "TC3", #Provisioning_office parameters datafil control strshkn_enabled y n
                    # "TC4", #Provisioning_office parameters datafil control strshkn_enabled n y
                    # "TC5", #Provisioning_office parameters datafil control strshkn_enabled n n
                    # "TC6", #Provisioning_LTDATA option STRSHKN INACTIVE
                    # "TC7", #Provisioning_LTDATA option STRSHKN AUTOGENERATED
                    # "TC8", #Provisioning_LTDATA option STRSHKN USETXTID
                    # "TC9", #Provisioning_LTDATA option STRSHKN ADMINENTERED (char)
                    # "TC11", #Provisioning_TRKOPTS STRSHKN STRSHKN 
                    # "TC12", #Provisioning_office parameters datafil control STRSHKN_ORIGID INACTIVE
                    # "TC13", #Provisioning_office parameters datafil control STRSHKN_ORIGID AUTOGENERATED 
                    # "TC14", #Provisioning_office parameters datafil control STRSHKN_ORIGID USETXTID 
                    # "TC15", #Provisioning_office parameters datafil control STRSHKN_ORIGID ADMINENTERED (char) 
                    # "TC16", #Provisioning_config the OrigId option at one or multiple levels 
                    # "TC17", #Provisioning_DPT trunk group STIR-SHAKEN enabled.
                    # "TC18", #Attestation_A _Verify SIP Lines shall be attested with a value of A
                    # "TC19", #Attestation_A _Verify Non-SIP lines types (NCS, MGCP, H248, ABI lines) shall be attested with a value of A.
                    # "TC20", #Orig_ID_Call Agent shall send the OrigId-value to SST if the DPT trunk group has STIR-SHAKEN enabled.
                    # "TC21", #Orig_ID_Call Agent shall not send the OrigId-value to SST if the DPT trunk group has STIR-SHAKEN Disable.
                    # "TC22", #Orig_ID_Verify All Non-SIP line types shall be supported.
                    # "TC25", #Attestation_B _Verify SIP PBX calls shall be attested with a value of B in all other cases other than above.
                    # "TC26", #Attestation_B _Verify standard PBX calls shall be attested with a value of B in all other cases other than above.
                    # "TC27", #Attestation_A_Verify Attestation Data shall be passed in the outgoing SIP Invite P-Attestation-Indicator parameter
                    # "TC28", #Orig_ID_Verify For the originating trunk group, a unique Orig-ID value configured shall be passed to from Core to SST 
                    # "TC29", #Orig_ID_Verify for an originating line, the orig-ID associated with the line (office wide value) should be passed from Core to SST
                    # "TC31", #Transit_Verify SIP Trunks shall be able to receive SIP Invites with Attestation and Orig_ID values 
                    # "TC32", #Transit_Verify SIP Trunks shall be able to pass received SIP Invites with Attestation and Orig_ID values in trunk to trunk scenarios
                    # "TC33", #Transit_Verify SIP Trunks shall be able to receive SIP Invites with Verification Results in the form of the Verstat parameter 
                    # "TC34", #Transit_Verify SIP Trunks shall be able to pass received SIP Invites with Verifcation results in trunk to trunk scenarios 
                    # "TC38", #Call scenarios_Sip line to dpt trunk with multiple levels are configured 
                    # "TC39", #Call scenarios_Nonsip Line to dpt trunk
                    # "TC40", #Call scenarios_Sippbx line to dpt trunk with Trunk Group option
                    # "TC41", #Call scenarios_PBX line to dpt trunk
                    # "TC42", #Call scenarios_Sip line to isup to dpt trunk
                    # "TC43", #Call scenarios_Non Sip line to isup to dpt trunk
                    # "TC44", #Call scenarios_PBX line to isup to dpt trunk
                    # "TC45", #Call scenarios_SIP PBX line to isup to dpt trunk
                    # "TC46", #Call scenarios_ Non Sip line - 3WC via SST
                    # "TC49", #Callp service - CXR tranfer to SIP line via SST trunk 
                    # "TC50", #Callp service - CFD_CFB forward to SIP line via SST trunk
                    # "TC51", #Callp service - SCL_SCS call to SIP line via SST trunk 
                    # "TC52", #Callp service - CHD hold a call and make a new call to SIP line via SST trunk 
                    # "TC53", #Callp service - Callp service - CWT verify call waiting from SIP line via SST trunk 
                    # "TC54", #Callp service - ACB automatic call back after release the call via SST trunk
                    # "TC55", #Callp service - 1FR line make a basic call via SST trunk 
                    # "TC56", #Callp service - SDN make a call via SST trunk
                    # "TC57", #BSY-RTS-FRLS the originator or DPT trunk during signaling association 
                    # "TC58", #Maintenance_ Core-GWC-SST cold swact during signaling association 
                    # "TC59", #Maintenance_Core-GWC-SST warm swact during signaling association
                    # "TC60", #Error path_provisioning office parameters datafil control strshkn_enabled with patches GSL00 deACTivated 
                    # "TC61", #Error path_Delete strshkn_enabled from table OFCVAR, OKPARMS when Stir-Shaken option still exist in table LTDATA, TRKOPTS 
                    # "TC65", #Error path_Deactivate patches when Stir-Shaken option still exist in table LTDATA, TRKOPTS 
                    # "TC67", #Error path_Provisioning STRSHKN in CUSTSTN 
                    # "TC68", #OM_Verify New OM STRSHKN values : VERSTATA, VERSTATB, VERSTATC 
                    # "TC70", #AttestationA_Verify StirShaken ATP is built for  Supported pri variants for pbx 
                    # "TC71", #Attestation_Verirfy StirShaken ATP is not built for  non-supported variants  
                    # "TC72", #Attestation_Verify StirShaken ATP for  supported variants of SIPPBX and non supported variants of sippbx
                    # "TC73", #OM_Verify Display oms : STRSHKN1 is not support 
                    # "TC74", #OM_Verify Display oms : STRSHKN2 is not support 
                    # "TC75", #STRSHKNCI tool_Verify all STRSHK data
                    # "TC76", #STRSHKNCI tool_Verify OFCVAR STRSHK data with ADMINENTERED
                    # "TC77", #STRSHKNCI tool_Verify LTDATA STRSHK data with ADMINENTERED
                    # "TC78", #STRSHKNCI tool_Verify CUSTSTN STRSHK data not sp 
                    # "TC79", #STRSHKNCI tool_Verify search ORIGID Value 
                    # "TC80", #Attestation_Verify STIR/SHAKEN ATP will not be passed to outgoing non-DPT ISUP trunk at tandem nodes. 
                    # "TC81", #Verstat parm will not be added to STIR/SHAKEN ATP at originating switch.
                    # "TC82", ##STRSHKNCI tool_Verify OFCVAR STRSHK data with INACTIVE
                    # "TC83", ##STRSHKNCI tool_Verify OFCVAR STRSHK data with AUTOGENERATED
                    # "TC84", ##STRSHKNCI tool_Verify OFCVAR STRSHK data with USETXTID
                    # "TC85", #STRSHKNCI tool_Verify LTDATA STRSHK data with INACTIVE
                    # "TC86", #STRSHKNCI tool_Verify LTDATA STRSHK data with AUTOGENERATED
                    # "TC87", #STRSHKNCI tool_Verify LTDATA STRSHK data with USETXTID
                     "TCtest", #Call scenarios_Nonsip Line to dpt trunk
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
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
#Check line status
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
 
#Check Trunk status
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
sub TC1 { #Provisioning_Activate de-activate patch.
    $logger->debug(__PACKAGE__ . " Inside test case TC1");

########################### Variables Declaration #############################
    $tcid = "TC1";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
		if (/(\w+.*STRSHKN STRSHKN)/) {
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
		if ($_ =~ /(\w+.*\s)\((STRSHKN)/) {
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
# # de-Activate patch
#     unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
#             $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
#         }
#     if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
#         if(grep /confirm/, $ses_core->execCmd("Y")){
#             unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
#              $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
#                 print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
#              $result = 0;
#              goto CLEANUP;
#             }else{
#                 print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
# 			}
#         }
#     }elsif(grep /CACM is already N/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
#         print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
#     }
#     else{
#         print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
#         $result = 0;
#         goto CLEANUP;        
#     }
#     if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET MRY73PWH")) {
#         unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
#              $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
#                 print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
#              $result = 0;
#              goto CLEANUP;
#         }else{
#             print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
# 		}
#     }else{
#         print FH "STEP: de-Activate patch MRY73PWH - PASS\n";
#     }
# # Activate patch
#     if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET MRY73PWH")) {
#         unless(grep /successful/, $ses_core->execCmd("Y")){
#             $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch MRY73PWH ");
#             print FH "STEP: Activate patch MRY73PWH - FAIL\n";
#             $result = 0;
#             goto CLEANUP;
#         }else{
#             print FH "STEP: Activate patch MRY73PWH - PASS\n";
#         }
#     }
#     if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET GSL00PUN")) {
#         if(grep /password/, $ses_core->execCmd("Y")){
#             if(grep /confirm/, $ses_core->execCmd("Y")){
#                 unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")){
#                     $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch GSL00PUN ");
#                     print FH "STEP: Activate patch GSL00PUN - FAIL\n";
#                     $result = 0;
#                     goto CLEANUP;
#                 }else{
#                     print FH "STEP: Activate patch GSL00PUN - PASS\n";
#                 }
#             }
#         }
#     }
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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC2 { #Provisioning_office parameters datafil control strshkn_enabled y y
    $logger->debug(__PACKAGE__ . " Inside test case TC2");

########################### Variables Declaration #############################
    $tcid = "TC2";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}   
sub TC3 { #Provisioning_office parameters datafil control strshkn_enabled y n
    $logger->debug(__PACKAGE__ . " Inside test case TC3");

########################### Variables Declaration #############################
    $tcid = "TC3";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y n','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /Y N/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y n of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y n of strshkn_enabled - PASS\n";
    }
################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC4 { #Provisioning_office parameters datafil control strshkn_enabled n y
    $logger->debug(__PACKAGE__ . " Inside test case TC4");

########################### Variables Declaration #############################
    $tcid = "TC4";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    unless (grep /PARMVAL/, $ses_core->execCmd("cha")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'cha' ");
    }
    $ses_core->execCmd("n y");
    if (grep /Error\! In order to change SIP_EP support/, $ses_core->execCmd("y")) {
        print FH "STEP: Can't change strshkn_enabled n y - PASS\n";
    }else{
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'n y' ");
        print FH "STEP: Can't change strshkn_enabled n y - FAIL\n";
    }
################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC5 { #Provisioning_office parameters datafil control strshkn_enabled n n
    $logger->debug(__PACKAGE__ . " Inside test case TC5");

########################### Variables Declaration #############################
    $tcid = "TC5";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    unless (grep /PARMVAL/, $ses_core->execCmd("cha")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'cha' ");
    }
    $ses_core->execCmd("n n");
    if (grep /Error\! In order to change SIP_EP support/, $ses_core->execCmd("y")) {
        print FH "STEP: Can't change strshkn_enabled n n - PASS\n";
    }else{
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'n y' ");
        print FH "STEP: Can't change strshkn_enabled n n - FAIL\n";
    }
################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    close(FH);
    &Luan_cleanup();
    &Luan_checkResult($tcid, $result);
} 
sub TC6 { #Provisioning_LTDATA option STRSHKN INACTIVE
    $logger->debug(__PACKAGE__ . " Inside test case TC6");

########################### Variables Declaration #############################
    $tcid = "TC6";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN INACTIVE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN INACTIVE' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  INACTIVE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  INACTIVE - PASS\n";
    }
################################## Cleanup 06 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 06 ##################################");

    close(FH);
    &Luan_cleanup();
    &Luan_checkResult($tcid, $result);
} 
sub TC7 { #Provisioning_LTDATA option STRSHKN AUTOGENERATED
    $logger->debug(__PACKAGE__ . " Inside test case TC7");

########################### Variables Declaration #############################
    $tcid = "TC7";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
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
################################## Cleanup 07 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 07 ##################################");

    close(FH);
    &Luan_cleanup();
    &Luan_checkResult($tcid, $result);
} 
sub TC8 { #Provisioning_LTDATA option STRSHKN USETXTID
    $logger->debug(__PACKAGE__ . " Inside test case TC8");

########################### Variables Declaration #############################
    $tcid = "TC8";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN USETXTID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN USETXTID' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  USETXTID - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  USETXTID - PASS\n";
    }
################################## Cleanup 08 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 08 ##################################");

    close(FH);
    &Luan_cleanup();
    &Luan_checkResult($tcid, $result);
} 
sub TC9 { #Provisioning_LTDATA option STRSHKN ADMINENTERED (char)
    $logger->debug(__PACKAGE__ . " Inside test case TC9");

########################### Variables Declaration #############################
    $tcid = "TC9";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
#option STRSHKN ADMINENTERED 16 char
    unless (grep /ADMINENTERED/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN 16 char");
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED 16 char - PASS\n";
    }
#option STRSHKN ADMINENTERED 16 < char
    unless (grep /ADMINENTERED/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFLTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFLTDATA' ");
    }
    unless (grep /OrigID value should have size of 16 character/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN < 16 char");
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED < 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED < 16 char - PASS\n";
        $ses_core->execCmd("abort")
    }
#option STRSHKN ADMINENTERED 16 > char
    unless (grep /ADMINENTERED/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA123")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA123' ");
    }
    unless (grep /ERROR/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN > 16 char");
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED > 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  ADMINENTERED > 16 char - PASS\n";
    }
################################## Cleanup 09 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 09 ##################################");

    close(FH);
    &Luan_cleanup();
    &Luan_checkResult($tcid, $result);
} 
sub TC11 { #Provisioning_TRKOPTS STRSHKN STRSHKN 
    $logger->debug(__PACKAGE__ . " Inside test case TC11");

########################### Variables Declaration #############################
    $tcid = "TC11";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    $TRKOPTS_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
        }
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
################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC12 { #Provisioning_office parameters datafil control STRSHKN_ORIGID INACTIVE
    $logger->debug(__PACKAGE__ . " Inside test case TC12");

########################### Variables Declaration #############################
    $tcid = "TC12";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','INACTIVE','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID INACTIVE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID INACTIVE - PASS\n";
    }
################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC13 { #Provisioning_office parameters datafil control STRSHKN_ORIGID AUTOGENERATED 
    $logger->debug(__PACKAGE__ . " Inside test case TC13");

########################### Variables Declaration #############################
    $tcid = "TC13";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','AUTOGENERATED','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /AUTOGENERATED/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID AUTOGENERATED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID AUTOGENERATED - PASS\n";
    }
################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC14 { #Provisioning_office parameters datafil control STRSHKN_ORIGID USETXTID 
    $logger->debug(__PACKAGE__ . " Inside test case TC14");

########################### Variables Declaration #############################
    $tcid = "TC14";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','USETXTID','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /USETXTID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID USETXTID - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID USETXTID - PASS\n";
    }
################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}  
sub TC15 { #Provisioning_office parameters datafil control STRSHKN_ORIGID ADMINENTERED (char)
    $logger->debug(__PACKAGE__ . " Inside test case TC15");

########################### Variables Declaration #############################
    $tcid = "TC15";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
#STRSHKN_ORIGID ADMINENTERED 16 char
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGS12345','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGS12345/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED 16 char - PASS\n";
    }
#STRSHKN_ORIGID ADMINENTERED < 16 char
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED low16','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /low16/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->debug(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED < 16 char - PASS\n";
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED < 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
#STRSHKN_ORIGID ADMINENTERED > 16 char
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED high16char123123123','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /high16char123123123/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED < 16 char - PASS\n";
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED < 16 char - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
################################## Cleanup 015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 015 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC16 { #Provisioning_config the OrigId option at one or multiple levels 
    $logger->debug(__PACKAGE__ . " Inside test case TC16");

########################### Variables Declaration #############################
    $tcid = "TC16";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
        }
    $ses_core->execCmd("add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA");
    unless (grep /TUPLE ALREADY EXISTS/, $ses_core->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
        }else{
            $ses_core->execCmd("abort")
        }
        print FH "STEP: add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA - Pass\n";
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
    ################################## Cleanup 016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 016 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC17 { #Provisioning_DPT trunk group STIR-SHAKEN enabled.
    $logger->debug(__PACKAGE__ . " Inside test case TC17");

########################### Variables Declaration #############################
    $tcid = "TC17";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@list_file_name, @TRKOPTS,);
    
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    $TRKOPTS_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
        }
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
################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC18 { #Attestation_A _Verify SIP Lines shall be attested with a value of A
    $logger->debug(__PACKAGE__ . " Inside test case TC18");

########################### Variables Declaration #############################
    $tcid = "TC18";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
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
sub TC19 { #Attestation_A _Verify Non-SIP lines types (NCS, MGCP, H248, ABI lines) shall be attested with a value of A.
    $logger->debug(__PACKAGE__ . " Inside test case TC19");

########################### Variables Declaration #############################
    $tcid = "TC19";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC20 { #Orig_ID_Call Agent shall send the OrigId-value to SST if the DPT trunk group has STIR-SHAKEN enabled.
    $logger->debug(__PACKAGE__ . " Inside test case TC20");

########################### Variables Declaration #############################
    $tcid = "TC20";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $TRKOPTS_config = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs, @TRKOPTS );
    
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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    $TRKOPTS_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
        }
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC21 { #Orig_ID_Call Agent shall not send the OrigId-value to SST if the DPT trunk group has STIR-SHAKEN Disable.
    $logger->debug(__PACKAGE__ . " Inside test case TC21");

########################### Variables Declaration #############################
    $tcid = "TC21";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $TRKOPTS_config = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @callTrakLogs,  @TRKOPTS );
    
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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table TRKOPTS
    $ses_core->{conn}->prompt('/BOTTOM/');
    @TRKOPTS = $ses_core->execCmd("table TRKOPTS; format pack;list all;"); 
    
    foreach (@TRKOPTS){
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
            $logger->debug(__PACKAGE__ . ": STRSHKN exists in TRKOPTS ");
            $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
			$ses_core->execCmd("del $1 ");
            $ses_core->execCmd("y");
            print FH "STEP: del $1 - Pass\n";
        }
    }		
    $TRKOPTS_config = 1;
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /CI/, $ses_core->execCmd("quit all")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is generated on calltraklogs ");
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
            $result = 0;
        }
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
     # Rollback table TRKOPTS
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
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC22 { #Orig_ID_Verify All Non-SIP line types shall be supported.
    $logger->debug(__PACKAGE__ . " Inside test case TC22");

########################### Variables Declaration #############################
    $tcid = "TC22";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC25 { #Attestation_B _Verify SIP PBX calls shall be attested with a value of B in all other cases other than above.
    $logger->debug(__PACKAGE__ . " Inside test case TC25");

########################### Variables Declaration #############################
    $tcid = "TC25";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC26 { #Attestation_B _Verify standard PBX calls shall be attested with a value of B in all other cases other than above.
    $logger->debug(__PACKAGE__ . " Inside test case TC26");

########################### Variables Declaration #############################
    $tcid = "TC26";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC27 { #Attestation_A_Verify Attestation Data shall be passed in the outgoing SIP Invite P-Attestation-Indicator parameter
    $logger->debug(__PACKAGE__ . " Inside test case TC27");

########################### Variables Declaration #############################
    $tcid = "TC27";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC28 { #Orig_ID_Verify For the originating trunk group, a unique Orig-ID value configured shall be passed to from Core to SST 
    $logger->debug(__PACKAGE__ . " Inside test case TC28");

########################### Variables Declaration #############################
    $tcid = "TC28";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_pri'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y y of strshkn_enabled - PASS\n";
    }
    
    # unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
    #     $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    # }
    # foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
    #     unless ($ses_core->execCmd($_)) {
    #         $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
    #         last;
    #     } else {
    #         print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    #     } 
    # }
    # unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
    #     $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
    #     print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    # }
    # config table OFRT
    unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    $ofrt_config = 1;
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC29 { #Orig_ID_Verify for an originating line, the orig-ID associated with the line (office wide value) should be passed from Core to SST 
    $logger->debug(__PACKAGE__ . " Inside test case TC29");

########################### Variables Declaration #############################
    $tcid = "TC29";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /Y Y/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y y of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y n of strshkn_enabled - PASS\n";
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC31 { #Transit_Verify SIP Trunks shall be able to receive SIP Invites with Attestation and Orig_ID values
    $logger->debug(__PACKAGE__ . " Inside test case TC31");

########################### Variables Declaration #############################
    $tcid = "TC31";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
sub TC32 { #Transit_Verify SIP Trunks shall be able to pass received SIP Invites with Attestation and Orig_ID values in trunk to trunk scenarios
    $logger->debug(__PACKAGE__ . " Inside test case TC32");

########################### Variables Declaration #############################
    $tcid = "TC32";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_pri'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    $ofrt_config = 1;
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
                -detect => ['RINGING'],#'RINGBACK','RINGING'
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}    
sub TC33 { #Transit_Verify SIP Trunks shall be able to receive SIP Invites with no Verification Results in the form of the Verstat parameter 
    $logger->debug(__PACKAGE__ . " Inside test case TC33");

########################### Variables Declaration #############################
    $tcid = "TC33";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs)) {
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_VERSTAT is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_VERSTAT - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_VERSTAT - PASS\n";
        }
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
sub TC34 { #Transit_Verify SIP Trunks shall be able to pass received SIP Invites with no Verifcation results in trunk to trunk scenarios
    $logger->debug(__PACKAGE__ . " Inside test case TC34");

########################### Variables Declaration #############################
    $tcid = "TC34";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_pri'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    $ofrt_config = 1;
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
                -detect => ['RINGING'],#'RINGBACK','RINGING'
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
        if ((grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_VERSTAT is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_VERSTAT - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_VERSTAT - PASS\n";
        }
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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC38 { #Call scenarios_Sip line to dpt trunk with multiple levels are configured
    $logger->debug(__PACKAGE__ . " Inside test case TC38");

########################### Variables Declaration #############################
    $tcid = "TC38";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_pri'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of G6VZSTSPRINT2W - PASS\n";
    }
    $ofrt_config = 1;
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
                -detect => ['RINGING'],#'RINGBACK','RINGING'
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 038 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 038 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of G6VZSTSPRINT2W");
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of G6VZSTSPRINT2W - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC39 { #Call scenarios_Nonsip Line to dpt trunk
    $logger->debug(__PACKAGE__ . " Inside test case TC39");

########################### Variables Declaration #############################
    $tcid = "TC39";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 039 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 039 ##################################");

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
sub TC40 { #Call scenarios_Sippbx line to dpt trunk with Trunk Group option
    $logger->debug(__PACKAGE__ . " Inside test case TC40");

########################### Variables Declaration #############################
    $tcid = "TC40";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 040 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 040 ##################################");

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
sub TC41 { #Call scenarios_PBX line to dpt trunk
    $logger->debug(__PACKAGE__ . " Inside test case TC41");

########################### Variables Declaration #############################
    $tcid = "TC41";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 041 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 041 ##################################");

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
sub TC42 { #Call scenarios_Sip line to isup to dpt trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC42");

########################### Variables Declaration #############################
    $tcid = "TC42";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_g9_isup'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command $db_trunk{'t15_g9_isup'}{-acc} ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_g9_isup'}{-clli}");
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - PASS\n";
    }
    $ofrt_config = 1;
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
    my $trunk_access_code = $db_trunk{'t15_g9_isup'}{-acc};
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
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP to SST ");
        print FH "STEP: A calls B via ISUP to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP to SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: DATA CHARS is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check DATA CHARS - FAIL\n";
        } else {
            print FH "STEP: Check DATA CHARS - PASS\n";
        }
    }
    
################################## Cleanup 042 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 042 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_g9_isup'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC43 { #Call scenarios_NonSip line to isup to dpt trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC43");

########################### Variables Declaration #############################
    $tcid = "TC43";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_g9_isup'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command $db_trunk{'t15_g9_isup'}{-acc} ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_g9_isup'}{-clli}");
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - PASS\n";
    }
    $ofrt_config = 1;
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
    my $trunk_access_code = $db_trunk{'t15_g9_isup'}{-acc};
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
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP to SST ");
        print FH "STEP: A calls B via ISUP to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP to SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: DATA CHARS is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check DATA CHARS - FAIL\n";
        } else {
            print FH "STEP: Check DATA CHARS - PASS\n";
        }
    }
    
################################## Cleanup 043 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 043 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_g9_isup'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC44 { #Call scenarios_PBX line to isup to dpt trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC44");

########################### Variables Declaration #############################
    $tcid = "TC44";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_g9_isup'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command $db_trunk{'t15_g9_isup'}{-acc} ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_g9_isup'}{-clli}");
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - PASS\n";
    }
    $ofrt_config = 1;
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
    my $trunk_access_code = $db_trunk{'t15_g9_isup'}{-acc};
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
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP to SST ");
        print FH "STEP: A calls B via ISUP to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP to SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: DATA CHARS is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check DATA CHARS - FAIL\n";
        } else {
            print FH "STEP: Check DATA CHARS - PASS\n";
        }
    }
    
################################## Cleanup 044 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 044 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_g9_isup'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC45 { #Call scenarios_SIP PBX line to isup to dpt trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC45");

########################### Variables Declaration #############################
    $tcid = "TC45";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_g9_isup'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command $db_trunk{'t15_g9_isup'}{-acc} ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_g9_isup'}{-clli}");
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_g9_isup'}{-clli} - PASS\n";
    }
    $ofrt_config = 1;
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
    my $trunk_access_code = $db_trunk{'t15_g9_isup'}{-acc};
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
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP to SST ");
        print FH "STEP: A calls B via ISUP to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP to SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: DATA CHARS is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check DATA CHARS - FAIL\n";
        } else {
            print FH "STEP: Check DATA CHARS - PASS\n";
        }
    }
    
################################## Cleanup 045 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 045 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_g9_isup'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_g9_isup'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_g9_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_g9_isup'}{-acc} - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC46 { #Call scenarios_ Non Sip line - 3WC via SST
    $logger->debug(__PACKAGE__ . " Inside test case TC46");

########################### Variables Declaration #############################
    $tcid = "TC46";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 046 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 046 ##################################");

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
sub TC49 { #Callp service - CXR tranfer to SIP line via SST trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC49");

########################### Variables Declaration #############################
    $tcid = "TC49";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
#B transfers call to C
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
#onhook B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);
# Offhook C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }

#Check speech path between A and C
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 049 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 049 ##################################");

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
sub TC50 { #Callp service - Callp service - CFD_CFB forward to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case TC50");

########################### Variables Declaration #############################
    $tcid = "TC50";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
   

#Add CFD or CFB to line B
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
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
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
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
    
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 050 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 050 ##################################");

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
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
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
sub TC51 { #Callp service - SCL_SCS call to SIP line via SST trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC51");

########################### Variables Declaration #############################
    $tcid = "TC51";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $flag = 1;
    my $scs_code = 71;
    my $spdc_code = 18;
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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'table IBNXLA'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos IBNFXLA $scs_code")) {
        @output = $ses_core->execCmd("add IBNFXLA $scs_code FEAT N N SCPS");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IBNFXLA $scs_code FEAT N N SCPS");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SCPS/, $ses_core->execCmd("pos IBNFXLA $scs_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IBNFXLA $scs_code in table IBNXLA");
        print FH "STEP: Datafill IBNFXLA $scs_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IBNFXLA $scs_code in table IBNXLA - PASS\n";
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos IBNFXLA $spdc_code")) {
        @output = $ses_core->execCmd("add IBNFXLA $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IBNFXLA $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SPDC/, $ses_core->execCmd("pos IBNFXLA $spdc_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IBNFXLA $spdc_code in table IBNXLA");
        print FH "STEP: Datafill IBNFXLA $spdc_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IBNFXLA $spdc_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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

# A dials SCS code + N + SST + DN (B) and hear confirmation tone then onhook
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

    $dialed_num = "\*$scs_code";
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
    #sleep(3);
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
    $dialed_num = "\*$spdc_code" . '0';
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
                -send_receive => ['TESTTONE'],
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 051 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 051 ##################################");

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

    # Remove service from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => "SCS", -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCS from line $list_dn[0]");
            print FH "STEP: Remove SCS from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove SCS from line $list_dn[0] - PASS\n";
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
sub TC52 { #Callp service - CHD hold a call and make a new call to SIP line via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case TC52");

########################### Variables Declaration #############################
    $tcid = "TC52";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    my $chd_code = 44;
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
# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot execute command 'table IBNXLA'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos IBNFXLA $chd_code")) {
        @output = $ses_core->execCmd("add IBNFXLA $chd_code FEAT N Y CHD");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IBNFXLA $chd_code FEAT N Y CHD");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /CHD/, $ses_core->execCmd("pos IBNFXLA $chd_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IBNFXLA $chd_code in table IBNXLA");
        print FH "STEP: Datafill IBNFXLA $chd_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IBNFXLA $chd_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# Add CHD line A
    unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
		print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
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
# Make call A to C via SST and check speech patch and A flash
    $dialed_num = $list_dn[2] =~ /\d{3}(\d+)/;
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
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C via SST ");
        print FH "STEP: A calls C via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C via SST - PASS\n";
    }
# A Dial CHD code
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        $result = 0;
        goto CLEANUP;
    }
    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);
    $dialed_num = '*' . $chd_code;
    %input = (
                -line_port => $list_line[0], 
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A dials $chd_code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $chd_code - PASS\n";
    }
    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hears confirmation tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears confirmation tone - PASS\n";
    }
    sleep(5);
# Make call A to B via SST and check speech patch
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'n',
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
        print FH "STEP: A calls B via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# A flash and dial CHD code again
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

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        $result = 0;
        goto CLEANUP;
    }

    $dialed_num = '*' . $chd_code;
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A dials $chd_code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $chd_code - PASS\n";
    }
    sleep(2);
# Check speech path A and C
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
# Hang up line C then hang up line a and B
    foreach ($list_line[2], $list_line[1], $list_line[0]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 052 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 052 ##################################");

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
   # remove CHD from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CHD from line $list_dn[0]");
            print FH "STEP: Remove CFD from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[0] - PASS\n";
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
sub TC53 { #Callp service - CWT verify call waiting from SIP line via SST trunk   
    $logger->debug(__PACKAGE__ . " Inside test case TC53");

########################### Variables Declaration #############################
    $tcid = "TC53";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
# Add CWT, CWI to line A
    foreach ('CWT','CWI') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
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
# Make call A to B via SST and check speech patch
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
        print FH "STEP: A calls B via SST - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via SST - PASS\n";
    }
# C calls A and hear ringback tone, A hear CWT tone via SST
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
        print FH "STEP: C hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASS\n";
    }
    $dialed_num = $list_dn[0] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
        print FH "STEP: A dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

    # Check CWT tone line A
    %input = (
                -line_port => $list_line[0],
                -callwaiting_tone_duration => 300,
                -cas_timeout => 20000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C hears Call waiting tone");
        print FH "STEP: A hears Call waiting tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears Call waiting tone - PASS\n";
    }

    # Check Ringback tone line C
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingbackToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[2]");
        print FH "STEP: C hears ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears ringback tone - PASS\n";
    }
# A flash to answer C
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
# Check speech path A and C
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
# A and C go onhook,
    foreach ($list_line[0], $list_line[2]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
        sleep(5);
    }
# Check line A re-ring , A offhook and speech patch A and B
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line A does not rering");
        print FH "STEP: Check line A rering - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A rering - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
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
# A and B go onhook
    foreach ($list_line[1], $list_line[0]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 053 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 053 ##################################");

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
   # remove CHD from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
            print FH "STEP: Remove CFD from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[0] - PASS\n";
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
sub TC54 { #Callp service - ACB automatic call back after release the call via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case TC54");

########################### Variables Declaration #############################
    $tcid = "TC54";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# Add ACB to line A
    unless ($ses_core->callFeature(-featureName => "ACB NOAMA", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[0]");
		print FH "STEP: add ACB for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add ACB for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
# get ACB access code
    my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[0]");
		print FH "STEP: get ACB access code for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get ACB access code for line $list_dn[0] - PASS\n";
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
# Offhook B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

# line A call line B via trunk and hear busy tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
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
    }
    sleep(5);
    my %input = (
                -line_port => $list_line[0],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect busy tone line $list_line[0]");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    sleep(5);
# line A activate ACB
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
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
    }
    sleep(2);
# onhook A
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(2);
# onhook B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    sleep(2);
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
# Offhook A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(3);
# Check line B ringing
 
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
# Offhook B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
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
        print FH "STEP: check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and C - PASS\n";
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 054 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 054 ##################################");

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
   # remove ACB from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'ACB', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
            print FH "STEP: Remove CFD from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[0] - PASS\n";
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
sub TC55 { #Callp service - 1FR line make a basic call via SST trunk 
    $logger->debug(__PACKAGE__ . " Inside test case TC55");

########################### Variables Declaration #############################
    $tcid = "TC55";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
# chg line to 1FR
        %input = (
                    -function => ['OUT','NEW'], 
                    -lineDN => $list_dn[0], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => '3 212_IBN L212_NILLA_0',
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 055 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 055 ##################################");

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
sub TC56 { #Callp service - SDN make a call via SST trunk  
    $logger->debug(__PACKAGE__ . " Inside test case TC56");

########################### Variables Declaration #############################
    $tcid = "TC56";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
# Add  SDN to line A
    my $un_line = "2124418888";
	unless ($ses_core->callFeature(-featureName => "SDN $un_line 4 P \$ \$", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
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

# B calls A via trunk to SDN and hears ringback then A ring and check speech path
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
                -detect => ['RINGBACK','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls A (SDN) via SST ");
        print FH "STEP: B calls A (SDN) via SST  - FAIL\n";
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 056 ################################## 
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 056 ##################################");

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
    # remove SDN feature for line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'SDN', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
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
sub TC57 { #BSY-RTS-FRLS the originator or DPT trunk during signaling association 
    $logger->debug(__PACKAGE__ . " Inside test case TC57");

########################### Variables Declaration #############################
    $tcid = "TC57";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
#pos trk in Mapci
    $ses_core->{conn}->prompt('/\>$/');
    my @cmd_result;
    my $status;
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    my $i = 0;
    foreach(@cmd_result){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_");
        if($_ =~ /(SSTSHAKEN\s+\w+)/){
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
    $ses_core->execCmd("rts");
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;trks;DPTRKS;post g SSTSHAKEN");
    foreach(@cmd_result){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_"); 
    }
    unless (grep /SSTSHAKEN\s+INS/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify SST is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify SST is returned successfully to Insv state - PASS\n";
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 057 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 057 ##################################");

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
sub TC58 { #Maintenance_ Core-GWC-SST cold swact during signaling association  
    $logger->debug(__PACKAGE__ . " Inside test case TC58");

########################### Variables Declaration #############################
    $tcid = "TC58";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    my $ses_core1;
    
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
        print FH "STEP: Login TMA15 core1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core1- PASS\n";
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
    unless ($ses_core1->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core1");
		print FH "STEP: Login TMA15 core1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core1 - PASS\n";
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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
        $logger->debug(__PACKAGE__ . ".$tcid: GWC of line A is $gwc_id");
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
# Cold swact GWC of line A
    $ses_core->execCmd("logout");
    sleep(8);
    #$gwc_id = 'gwc' . $gwc_id;
    $ses_core->execCmd("cli");
    unless ($ses_core -> coldSwactGWC(-gwc_id => -$gwc_id, -timeout => 120)){
		$logger->error(__PACKAGE__ . ": Could not warm swact GWC");
		print FH "STEP: Execute WARM Swact GWC - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "Execute WARM Swact GWC - PASSED\n";
	} 
# Check line A is drop
    unless (grep /IDL/, $ses_core1->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not IDL");
        print FH "STEP: Check line $list_dn[0] status - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line $list_dn[0] status- PASS\n";
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 058 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 058 ##################################");

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
sub TC59 { #Maintenance_Core-GWC-SST warm swact during signaling association  
    $logger->debug(__PACKAGE__ . " Inside test case TC59");

########################### Variables Declaration #############################
    $tcid = "TC59";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    my $ses_core1;
    
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
        print FH "STEP: Login TMA15 core1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core1- PASS\n";
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
    unless ($ses_core1->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core1");
		print FH "STEP: Login TMA15 core1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core1 - PASS\n";
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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
        $logger->debug(__PACKAGE__ . ".$tcid: GWC of line A is $gwc_id");
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
# Warm swact GWC of line A
    $ses_core->execCmd("logout");
    sleep(8);
    #$gwc_id = 'gwc' . $gwc_id;
    $ses_core->execCmd("cli");
    unless ($ses_core -> warmSwactGWC(-gwc_id => -$gwc_id, -timeout => 120)){
		$logger->error(__PACKAGE__ . ": Could not warm swact GWC");
		print FH "STEP: Execute WARM Swact GWC - FAILED\n";
		$result = 0;	  
		goto CLEANUP;
	} else {
		print FH "Execute WARM Swact GWC - PASSED\n";
	}    
   
# Check line A is calling
    unless (grep /CPB/, $ses_core1->coreLineGetStatus($list_dn[0])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] is not CPB");
        print FH "STEP: Check line $list_dn[0] status - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line $list_dn[0] status- PASS\n";
    }
# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 059 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 059 ##################################");

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
sub TC60 { #Error path_provisioning office parameters datafil control strshkn_enabled with patches GSL00 deACTivated.
    $logger->debug(__PACKAGE__ . " Inside test case TC60");

########################### Variables Declaration #############################
    $tcid = "TC60";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
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
		if ($_ =~ /(\w+.*\s)\((STRSHKN)/) {
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
# de-Activate patch
    unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
        }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
        if(grep /confirm/, $ses_core->execCmd("Y")){
            unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
             $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
                print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
             $result = 0;
             goto CLEANUP;
            }else{
                print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
			}
        }
    }elsif(grep /CACM is already N/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
        print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
    }
    else{
        print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
        $result = 0;
        goto CLEANUP;        
    }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET MRY73PWH")) {
        unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
             $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
                print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
             $result = 0;
             goto CLEANUP;
        }else{
            print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
		}
    }else{
        print FH "STEP: de-Activate patch MRY73PWH - PASS\n";
    }
# check config table OKPARMS
    $ses_core->execCmd("quit all");
    unless (grep /TABLE:.*OKPARMS/, $ses_core->execCmd("table OKPARMS")) {
         $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OKPARMS' ");
    }
    unless (grep /TUPLE NOT FOUND/, $ses_core->execCmd("pos STRSHKN_ENABLED")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ENABLED' ");
        $result = 0;
        goto CLEANUP;
    }else{
         print FH "STEP: check STRSHKN_ENABLED in table OKPARMS - Pass\n";
    }
    unless (grep /TUPLE NOT FOUND/, $ses_core->execCmd("pos STRSHKN_ORIGID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ORIGID' ");
        $result = 0;
        goto CLEANUP;
    }else{
         print FH "STEP: check STRSHKN_ORIGID in table OKPARMS - Pass\n";
    }
# Activate patch
    unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
        }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET MRY73PWH")) {
        unless(grep /successful/, $ses_core->execCmd("Y")){
            $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch MRY73PWH ");
            print FH "STEP: Activate patch MRY73PWH - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }else{
            print FH "STEP: Activate patch MRY73PWH - PASS\n";
        }
    }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET GSL00PUN")) {
        if(grep /password/, $ses_core->execCmd("Y")){
            if(grep /confirm/, $ses_core->execCmd("Y")){
                unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")){
                    $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch GSL00PUN ");
                    print FH "STEP: Activate patch GSL00PUN - FAIL\n";
                    $result = 0;
                    goto CLEANUP;
                }else{
                    print FH "STEP: Activate patch GSL00PUN - PASS\n";
                }
            }
        }
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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
################################## Cleanup 060 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 060 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC61 { #Error path_Delete strshkn_enabled from table OFCVAR, OKPARMS when Stir-Shaken option still exist in table LTDATA, TRKOPTS 
    $logger->debug(__PACKAGE__ . " Inside test case TC61");

########################### Variables Declaration #############################
    $tcid = "TC61";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("del strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
        print FH "STEP: Can't del strshkn_enabled - FAIL\n";
    }else{
        unless (grep /NOT DELETE/, $ses_core->execCmd("Y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
            print FH "STEP: Can't del strshkn_enabled - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Can't del strshkn_enabled - PASS\n";
        }
    }
    
################################## Cleanup 061 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 061 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC62 { #Error path_provisioning office parameters datafil control strshkn_enabled with patches GSL00 deACTivated.
    $logger->debug(__PACKAGE__ . " Inside test case TC62");

########################### Variables Declaration #############################
    $tcid = "TC62";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
		if ($_ =~ /(\w+.*STRSHKN STRSHKN)/) {
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
		if ($_ =~ /(\w+.*\s)\((STRSHKN)/) {
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
# de-Activate patch
    unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
        }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
        if(grep /confirm/, $ses_core->execCmd("Y")){
            unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
             $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
                print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
             $result = 0;
             goto CLEANUP;
            }else{
                print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
			}
        }
    }elsif(grep /CACM is already N/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
        print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
    }
    else{
        print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
        $result = 0;
        goto CLEANUP;        
    }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET MRY73PWH")) {
        unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")) {
             $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
                print FH "STEP: de-Activate patch GSL00PUN - FAIL\n";
             $result = 0;
             goto CLEANUP;
        }else{
            print FH "STEP: de-Activate patch GSL00PUN - PASS\n";
		}
    }else{
        print FH "STEP: de-Activate patch MRY73PWH - PASS\n";
    }
# check config table OKPARMS
    $ses_core->execCmd("quit all");
    unless (grep /TABLE:.*OKPARMS/, $ses_core->execCmd("table OKPARMS")) {
         $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OKPARMS' ");
    }
    unless (grep /TUPLE NOT FOUND/, $ses_core->execCmd("pos STRSHKN_ENABLED")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ENABLED' ");
        $result = 0;
        goto CLEANUP;
    }else{
         print FH "STEP: check STRSHKN_ENABLED in table OKPARMS - Pass\n";
    }
    unless (grep /TUPLE NOT FOUND/, $ses_core->execCmd("pos STRSHKN_ORIGID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos STRSHKN_ORIGID' ");
        $result = 0;
        goto CLEANUP;
    }else{
         print FH "STEP: check STRSHKN_ORIGID in table OKPARMS - Pass\n";
    }
# config table TRKOPTS
        unless (grep /TABLE:.*TRKOPTS/, $ses_core->execCmd("table TRKOPTS")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table TRKOPTS' ");
        }
        if (grep /ERROR/, $ses_core->execCmd("add SSTSHAKEN STRSHKN STRSHKN")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add SSTSHAKEN STRSHKN STRSHKN' ");
            print FH "STEP: can't add SSTSHAKEN STRSHKN STRSHKN - Pass\n";
            $ses_core->execCmd("abort");
        }else{
            print FH "STEP: add SSTSHAKEN STRSHKN STRSHKN - fail\n";
            $result = 0;
            goto CLEANUP;
        }
# config table LTDATA
        unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
        }
        if (grep /ERROR/, $ses_core->execCmd("add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA' ");
            print FH "STEP: can't add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA - Pass\n";
            $ses_core->execCmd("abort");
        }else{
            print FH "STEP: add ISDN 85 LSERV LSERV STRSHKN ADMINENTERED KINGOFKINGLTDATA - fail\n";
            $result = 0;
            goto CLEANUP;
        }    
# Activate patch
    unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
        }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET MRY73PWH")) {
        unless(grep /successful/, $ses_core->execCmd("Y")){
            $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch MRY73PWH ");
            print FH "STEP: Activate patch MRY73PWH - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }else{
            print FH "STEP: Activate patch MRY73PWH - PASS\n";
        }
    }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE Y IN PRSUSET GSL00PUN")) {
        if(grep /password/, $ses_core->execCmd("Y")){
            if(grep /confirm/, $ses_core->execCmd("Y")){
                unless(grep /SUCCESSFUL/, $ses_core->execCmd("Y")){
                    $logger->error(__PACKAGE__ . ".$tcid: Cannot Activate patch GSL00PUN ");
                    print FH "STEP: Activate patch GSL00PUN - FAIL\n";
                    $result = 0;
                    goto CLEANUP;
                }else{
                    print FH "STEP: Activate patch GSL00PUN - PASS\n";
                }
            }
        }
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
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
################################## Cleanup 062 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 062 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC65 { #Error path_Deactivate patches when Stir-Shaken option still exist in table LTDATA, TRKOPTS.
    $logger->debug(__PACKAGE__ . " Inside test case TC65");

########################### Variables Declaration #############################
    $tcid = "TC65";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# de-Activate patch
    unless (grep /PRSM/, $ses_core->execCmd("prsm")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'prsm' ");
        }
    if(grep /confirm/, $ses_core->execCmd("ASSIGN ACTIVE N IN PRSUSET GSL00PUN")){
        if(grep /confirm/, $ses_core->execCmd("Y")){
            unless(grep /CAN NOT BE DEACTIVATED/, $ses_core->execCmd("Y")) {
             $logger->error(__PACKAGE__ . ".$tcid: Cannot de-Activate patch GSL00PUN ");
                print FH "STEP: CAN NOT BE DEACTIVATED patch GSL00PUN - FAIL\n";
             $result = 0;
             goto CLEANUP;
            }else{
                print FH "STEP: CAN NOT BE DEACTIVATED patch GSL00PUN - PASS\n";
			}
        }
    }else{
        print FH "STEP: CAN NOT BE DEACTIVATED  GSL00PUN - FAIL\n";
        $result = 0;
        goto CLEANUP;        
    }
################################## Cleanup 065 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 065 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC67 { #Error path_Provisioning STRSHKN in CUSTSTN.
    $logger->debug(__PACKAGE__ . " Inside test case TC67");

########################### Variables Declaration #############################
    $tcid = "TC67";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
#TABLE CUSTSTN
    unless (grep /TABLE:.*CUSTSTN/, $ses_core->execCmd("table CUSTSTN")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table CUSTSTN' ");
        }
    if (grep /ERROR/, $ses_core->execCmd("add STRSHKN_ENABLED")) {
        $logger->debug(__PACKAGE__ . " $tcid: cannot execute command 'add STRSHKN_ENABLED' ");
        print FH "STEP: Cannot add STRSHKN_ENABLED - Pass\n";
    }else{
        print FH "STEP: Cannot add STRSHKN_ENABLED - Fail\n";
        $result = 0;
        goto CLEANUP;
    }
################################## Cleanup 067 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 067 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC68 { #OM_Verify New OM STRSHKN values : VERSTATA, VERSTATB, VERSTATC 
    $logger->debug(__PACKAGE__ . " Inside test case TC68");

########################### Variables Declaration #############################
    $tcid = "TC68";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    my @output = $ses_core->execCmd("omshow STRSHKN active");
    for(@output){
        if ($_ =~ /(\d+)\s+\d+\s+/) {
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
        if ($_ =~ /(\d+)\s+\d+\s+/) {
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 068 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 068 ##################################");

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
sub TC70 { #Attestation_Verify StirShaken ATP is built for  Supported pri variants for pbx 
    $logger->debug(__PACKAGE__ . " Inside test case TC70");

########################### Variables Declaration #############################
    $tcid = "TC70";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 070 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 070 ##################################");

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
sub TC71 { #Attestation_Verirfy StirShaken ATP is not built for  non-supported variants 
    $logger->debug(__PACKAGE__ . " Inside test case TC71");

########################### Variables Declaration #############################
    $tcid = "TC71";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y n','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /Y N/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_enabled");
        print FH "STEP: change PARMVAL y n of strshkn_enabled - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PARMVAL y n of strshkn_enabled - PASS\n";
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
    if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 071 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 071 ##################################");

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
sub TC72 { #Attestation_Verirfy StirShaken ATP is not built for  non-supported variants 
    $logger->debug(__PACKAGE__ . " Inside test case TC72");

########################### Variables Declaration #############################
    $tcid = "TC72";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
    unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 072 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 072 ##################################");

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
sub TC73 { #OM_Verify Display oms : STRSHKN1 is not support 
    $logger->debug(__PACKAGE__ . " Inside test case TC73");

########################### Variables Declaration #############################
    $tcid = "TC73";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs ,@list_line);
    
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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    if (grep /STRSHKN1/, $ses_core->execCmd("omshow STRSHKN1 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN1 active");
        print FH "STEP: cannot omshow STRSHKN1 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN1 active - PASS\n";
    }
################################## Cleanup 073 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 073 ##################################");

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
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC74 { #OM_Verify Display oms : STRSHKN2 is not support 
    $logger->debug(__PACKAGE__ . " Inside test case TC74");

########################### Variables Declaration #############################
    $tcid = "TC74";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $flag = 1;
    my $ATTESTA;
    my $ATTESTA1;
    my (@list_file_name, $dialed_num, @callTrakLogs,@list_line );
    
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

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }


############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#omshow STRSHKN active
    $ses_core->{conn}->prompt('/\>/');
    if (grep /STRSHKN2/, $ses_core->execCmd("omshow STRSHKN2 active")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot omshow STRSHKN1 active");
        print FH "STEP: cannot omshow STRSHKN2 active - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: cannot omshow STRSHKN2 active - PASS\n";
    }
################################## Cleanup 074 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 074 ##################################");

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
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC75 { #STRSHKNCI tool_Verify all STRSHK data 
    $logger->debug(__PACKAGE__ . " Inside test case TC75");

########################### Variables Declaration #############################
    $tcid = "TC75";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY ALL
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY ALL");
     if ((grep /.*OFCVAR.*KINGOFKINGOFCVAR/, @output) and (grep /.*LTDATA.*KINGOFKINGLTDATA/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY ALL Verify all STRSHK data  ");
            print FH "STEP: DISPLAY ALL Verify all STRSHK data  - PASS\n";
        } else {
            print FH "STEP: DISPLAY ALL Verify all STRSHK data  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 075 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 075 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC76 { #STRSHKNCI tool_Verify OFCVAR STRSHK data with AdminEntered
    $logger->debug(__PACKAGE__ . " Inside test case TC76");

########################### Variables Declaration #############################
    $tcid = "TC76";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY OFCVAR
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY OFCVAR");
     if ((grep /.*OFCVAR.*KINGOFKINGOFCVAR/, @output)) {
            $logger->debug(__PACKAGE__ . " $tcid: DISPLAY OFCVAR ");
            print FH "STEP: DISPLAY OFCVAR - PASS\n";
        } else {
            print FH "STEP: DISPLAY OFCVAR  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 076 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 076 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC77 { #STRSHKNCI tool_Verify LTDATA STRSHK data  with ADMINENTERED
    $logger->debug(__PACKAGE__ . " Inside test case TC77");

########################### Variables Declaration #############################
    $tcid = "TC77";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
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
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY LTDATA ISDN 85
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY LTDATA ISDN 85");
     if ((grep /.*LTDATA.*KINGOFKINGLTDATA/, @output)) {
            $logger->debug(__PACKAGE__ . " $tcid: DISPLAY LTDATA ISDN 85 ");
            print FH "STEP: DISPLAY LTDATA ISDN 85 - PASS\n";
        } else {
            print FH "STEP: DISPLAY LTDATA ISDN 85  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 077 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 077 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC78 { #STRSHKNCI tool_Verify CUSTSTN STRSHK data not sp   
    $logger->debug(__PACKAGE__ . " Inside test case TC78");

########################### Variables Declaration #############################
    $tcid = "TC78";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY CUSTSTN
    $ses_core->{conn}->prompt('/\}/'); 
    my @output =  $ses_core->execCmd("DISPLAY CUSTSTN");
     if ((grep /Invalid symbol/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: can't not DISPLAY CUSTSTN ");
            print FH "STEP: DISPLAY LTDATA ISDN 85 - PASS\n";
        } else {
            print FH "STEP: DDISPLAY LTDATA ISDN 85  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 078 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 078 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC79 { #STRSHKNCI tool_Verify search ORIGID Value    
    $logger->debug(__PACKAGE__ . " Inside test case TC79");

########################### Variables Declaration #############################
    $tcid = "TC79";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#search ORIGID Value 
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/'); 
    my @output =  $ses_core->execCmd("search KINGOFKINGOFCVAR");
    if ((grep /.*OFCVAR.*KINGOFKINGOFCVAR/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: search KINGOFKINGOFCVAR ");
            print FH "STEP: search KINGOFKINGOFCVAR - PASS\n";
        } else {
            print FH "STEP: search KINGOFKINGOFCVAR - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    @output =  $ses_core->execCmd("search KINGOFKINGLTDATA");
    if ((grep /.*LTDATA.*KINGOFKINGLTDATA/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: search KINGOFKINGLTDATA ");
            print FH "STEP: search KINGOFKINGLTDATA - PASS\n";
        } else {
            print FH "STEP: search KINGOFKINGLTDATA - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 079 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 079 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC80 { #Attestation_Verify STIR/SHAKEN ATP will not be passed to outgoing non-DPT ISUP trunk at tandem nodes.
    $logger->debug(__PACKAGE__ . " Inside test case TC80");

########################### Variables Declaration #############################
    $tcid = "TC80";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $ofrt_config = 0;
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
    foreach ($db_trunk{'t15_g9_isup'}{-clli}) {
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
    foreach ($db_trunk{'t15_pri'}{-clli}) {
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
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        } else {
            print FH "STEP: STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
        } 
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
# config table OFRT
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command $db_trunk{'t15_pri'}{-acc} ");
    }
    foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','775','n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_pri'}{-clli}");
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_pri'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS 775 of $db_trunk{'t15_pri'}{-clli} - PASS\n";
    }
    unless (grep /ERROR/, $ses_core->execCmd("pos $db_trunk{'t15_sst'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_sst'}{-acc}' ");
        $ses_core->execCmd("abort")
    }
    foreach ('cha','N','D',$db_trunk{'t15_sst'}{-clli},'3',$db_trunk{'t15_g9_isup'}{-acc},'n','$','$','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /$db_trunk{'t15_g9_isup'}{-acc}/, $ses_core->execCmd("pos $db_trunk{'t15_sst'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS $db_trunk{'t15_sst'}{-clli}");
        print FH "STEP: change PRFXDIGS $db_trunk{'t15_g9_isup'}{-acc} of $db_trunk{'t15_sst'}{-clli} - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS $db_trunk{'t15_g9_isup'}{-acc} of $db_trunk{'t15_sst'}{-clli} - PASS\n";
    }
    $ofrt_config = 1;
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
              -trunkName => [$db_trunk{'t15_g9_isup'}{-clli}], 
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
                -detect => ['NONE'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['NONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B via ISUP to SST ");
        print FH "STEP: A calls B via ISUP to SST  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B via ISUP to SST - PASS\n";
    }

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: DATA CHARS is generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check DATA CHARS - FAIL\n";
        } else {
            print FH "STEP: Check DATA CHARS - PASS\n";
        }
    }
    
################################## Cleanup 080 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 080 ##################################");

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
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_pri'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_pri'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /775/, $ses_core->execCmd("pos $db_trunk{'t15_pri'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_pri'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_pri'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_pri'}{-acc} - PASS\n";
        }

        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t15_sst'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t15_sst'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t15_sst'}{-clli},'3','$','n','$','$','y','abort') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        if (grep /$db_trunk{'t15_g9_isup'}{-acc}/, $ses_core->execCmd("pos $db_trunk{'t15_sst'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot rollback PRFXDIGS of $db_trunk{'t15_sst'}{-acc} ");
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_sst'}{-acc} - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: rollback PRFXDIGS of $db_trunk{'t15_sst'}{-acc} - PASS\n";
        }
    }

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC81 { #Verstat parm will not be added to STIR/SHAKEN ATP at originating switch..
    $logger->debug(__PACKAGE__ . " Inside test case TC81");

########################### Variables Declaration #############################
    $tcid = "TC81";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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

# Stop CallTrak
    if ($calltrak_start) {
        unless (@callTrakLogs = $ses_calltrak->stopCalltrak()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak ");
        }
        
        else {
            print FH "STEP: Stop calltrak - PASS\n";
        }
        if ((grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs)) {
           
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup 081 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 081 ##################################");

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
sub TC82 { #STRSHKNCI tool_Verify OFCVAR STRSHK data with INACTIVE
    $logger->debug(__PACKAGE__ . " Inside test case TC82");

########################### Variables Declaration #############################
    $tcid = "TC82";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','INACTIVE','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID INACTIVE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID INACTIVE - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY OFCVAR
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY OFCVAR");
     if ((grep /.*OFCVAR.*Inactive/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY OFCVAR ");
            print FH "STEP: DISPLAY OFCVAR - PASS\n";
        } else {
            print FH "STEP: DISPLAY OFCVAR  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
################################## Cleanup 082 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 082 ##################################");
    # rollback table ofcvar
    $ses_core->execCmd("quit all");
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC83 { #STRSHKNCI tool_Verify OFCVAR STRSHK data with AUTOGENERATED
    $logger->debug(__PACKAGE__ . " Inside test case TC83");

########################### Variables Declaration #############################
    $tcid = "TC83";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','AUTOGENERATED','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /AUTOGENERATED/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID AUTOGENERATED - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID AUTOGENERATED - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY OFCVAR
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY OFCVAR");
     if ((grep /.*OFCVAR.*AutoGenerated/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY OFCVAR ");
            print FH "STEP: DISPLAY OFCVAR - PASS\n";
        } else {
            print FH "STEP: DISPLAY OFCVAR  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
################################## Cleanup 083 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 083 ##################################");
    # rollback table ofcvar
    $ses_core->execCmd("quit all");
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC84 { #STRSHKNCI tool_Verify OFCVAR STRSHK data with USETXTID
    $logger->debug(__PACKAGE__ . " Inside test case TC84");

########################### Variables Declaration #############################
    $tcid = "TC84";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table ofcvar
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_enabled/, $ses_core->execCmd("pos strshkn_enabled")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_enabled' ");
    }
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','USETXTID','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /USETXTID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID USETXTID - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID USETXTID - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY OFCVAR
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY OFCVAR");
     if ((grep /.*OFCVAR.*UseTxtId.*5TMA15TMA15TMA15/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY OFCVAR ");
            print FH "STEP: DISPLAY OFCVAR - PASS\n";
        } else {
            print FH "STEP: DISPLAY OFCVAR  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
################################## Cleanup 084 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 084 ##################################");
    # rollback table ofcvar
    $ses_core->execCmd("quit all");
    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /strshkn_origID/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos strshkn_origID' ");
    }
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /KINGOFKINGOFCVAR/, $ses_core->execCmd("pos strshkn_origID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of strshkn_origID");
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change STRSHKN_ORIGID ADMINENTERED KINGOFKINGOFCVAR - PASS\n";
    }
    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC85 { #STRSHKNCI tool_Verify LTDATA STRSHK data  with INACTIVE
    $logger->debug(__PACKAGE__ . " Inside test case TC85");

########################### Variables Declaration #############################
    $tcid = "TC85";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN INACTIVE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN INACTIVE' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  INACTIVE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  INACTIVE - PASS\n";
    }
	
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY LTDATA ISDN 85
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY LTDATA ISDN 85");
     if ((grep /.*LTDATA.*Inactive/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY LTDATA ISDN 85 ");
            print FH "STEP: DISPLAY LTDATA ISDN 85 - PASS\n";
        } else {
            print FH "STEP: DISPLAY LTDATA ISDN 85  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 085 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 085 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC86 { #STRSHKNCI tool_Verify LTDATA STRSHK data  with AUTOGENERATED
    $logger->debug(__PACKAGE__ . " Inside test case TC86");

########################### Variables Declaration #############################
    $tcid = "TC86";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
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
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY LTDATA ISDN 85
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY LTDATA ISDN 85");
     if ((grep /.*LTDATA.*AutoGenerated/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY LTDATA ISDN 85 ");
            print FH "STEP: DISPLAY LTDATA ISDN 85 - PASS\n";
        } else {
            print FH "STEP: DISPLAY LTDATA ISDN 85  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 086 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 086 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC87 { #STRSHKNCI tool_Verify LTDATA STRSHK data  with USETXTID
    $logger->debug(__PACKAGE__ . " Inside test case TC87");

########################### Variables Declaration #############################
    $tcid = "TC87";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

    my $flag = 1;
  
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# config table LTDATA
    unless (grep /TABLE:.*LTDATA/, $ses_core->execCmd("table LTDATA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table LTDATA' ");
    }
    unless (grep /INACTIVE/, $ses_core->execCmd("rep ISDN 85 LSERV LSERV STRSHKN USETXTID")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep ISDN 85 LSERV LSERV STRSHKN USETXTID' ");
    }
    unless (grep /TUPLE REPLACED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of LTDATA STRSHKN");
        print FH "STEP: change LTDATA STRSHKN  USETXTID - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change LTDATA STRSHKN  USETXTID - PASS\n";
    }
###################### Call flow ###########################
#STRSHKCI mode
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("STRSHKCI");
    sleep(2);
#DISPLAY LTDATA ISDN 85
    $ses_core->{conn}->prompt('/--------------------------------------------------------------------
>/');
    my @output =  $ses_core->execCmd("DISPLAY LTDATA ISDN 85");
     if ((grep /.*LTDATA.*UseTxtId.*15G6VZSTSPRINTW2/, @output)) {
            $logger->error(__PACKAGE__ . " $tcid: DISPLAY LTDATA ISDN 85 ");
            print FH "STEP: DISPLAY LTDATA ISDN 85 - PASS\n";
        } else {
            print FH "STEP: DISPLAY LTDATA ISDN 85  - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
################################## Cleanup 087 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 087 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TCtest { #Call scenarios_Nonsip Line to dpt trunk
    $logger->debug(__PACKAGE__ . " Inside test case TCtest");

########################### Variables Declaration #############################
    $tcid = "TCtest";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/SHAKEN");

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
    foreach ('cha','y y','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    foreach ('cha','ADMINENTERED KINGOFKINGOFCVAR','y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
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
    $dialed_num = $list_dn[1] ;#=~ /\d{3}(\d+)/;
    # my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    # $dialed_num = $trunk_access_code . $1;
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
    }
    
################################## Cleanup test ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup test ##################################");

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
