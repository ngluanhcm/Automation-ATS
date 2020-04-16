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
                'TC11' => ['gr303_1','sip_1'],
                'TC12' => ['gr303_1','Sip_pbx'],
                'TC13' => ['gr303_1','sip_1'],
                'TC14' => ['gr303_1','Sip_pbx'],
                'TC15' => ['gr303_1','sip_1'],
                'TC16' => ['gr303_1','Sip_pbx'],
                'TC17' => ['Sip_pbx','sip_1'],
                'TC18' => ['Sip_pbx','Sip_pbx'],
                'TC19' => ['gr303_1',''],
                'TC20' => ['gr303_1',''],
                'TC21' => ['gr303_1',''],
                'TC22' => ['gr303_1',''],
                'TC23' => ['gr303_1',''],
                'TC24' => ['gr303_1',''],
                'TC25' => ['gr303_1',''],
                'TC26' => ['gr303_1',''],
                'TC27' => ['gr303_1',''],
                'TC28' => ['gr303_1',''],
                'TC29' => ['gr303_1',''],
                'TC30' => ['gr303_1',''],
                'TC31' => ['gr303_1',''],
                'TC32' => ['gr303_1',''],
                'TC33' => ['gr303_1',''],
                'TC34' => ['gr303_1',''],
                'TC35' => ['gr303_1',''],
                'TC36' => ['Sip_pbx','sip_1'],


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

sub cha_table_ofcvar{
    my ($option, $chg_value) = (@_);
    my $subname = "rep_table_ofcvar";

    unless (grep /TABLE:.*OFCVAR/, $ses_core->execCmd("table ofcvar")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table ofcvar' ");
    }
    unless (grep /$option/, $ses_core->execCmd("pos $option")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $option' ");
    }
    foreach ('cha', $chg_value ,'y','abort') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    unless (grep /$chg_value/, $ses_core->execCmd("pos $option")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of $option");
        print FH "STEP: change PARMVAL $chg_value of $option - FAIL\n";
        return 0;
    } else {
        print FH "STEP: change PARMVAL $chg_value of $option - PASS\n";
    }
    return 1;
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "TC0", #set up lab
                    "TC1", #Provisioning_Activate de-activate SOC CS2C0009
                    "TC2", #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS PASS
                    "TC3", #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS FAIL
                    "TC4", #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
                    "TC5", #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat Y
                    "TC6", #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat N
                    "TC7", #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat Y
                    "TC8", #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat N
                    "TC9", #OM_Verify Display oms : STRSHKN1 is support 
                    "TC10", #OM_Verify Display oms : STRSHKN2 is support 
                    "TC11", #Error path_set STRSHKN_ENABLED Y Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
                    "TC12", #Error path_set STRSHKN_ENABLED Y N when The Stir Shaken SOC CS2B0009 is NOT Enabled
                    "TC13", #Error path_Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping FAIL  FAIL FAIL
                    "TC14", #Error path_set STRSHKN_ENABLED N Y when The Stir Shaken SOC CS2B0009 is NOT Enabled            
                    "TC15", #OM_Verify New OM STRSHKN values : VERSTATB
                   
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
sub TC1 { #Provisioning_Enable Disable SOC CS2C0009
    $logger->debug(__PACKAGE__ . " Inside test case TC1");

########################### Variables Declaration #############################
    $tcid = "TC1";
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
        if (grep /entering/, $ses_core->execCmd("assign STATE ON to CS2C0009")) {            
                print FH "STEP: Disable option CS2C0009 - PASS \n";         
        }             
    }else{
        print FH "STEP: Disable option CS2C0009 - PASS \n";
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
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_Verstat_Mapping PASS FAIL FAIL")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_Verstat_Mapping ");
        print FH "STEP: Default Values of STRSHKN_Verstat_Mapping  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_Verstat_Mapping - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_Verstat_Mapping  - FAIL\n";
                $result = 0;
                goto CLEANUP;
        }  
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_PASS_VERSTAT N")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_PASS_VERSTAT ");
        print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_PASS_VERSTAT  - FAIL\n";
                $result = 0;
                goto CLEANUP;
        }  
    }
    unless (grep /CONFIRM/, $ses_core->execCmd("rep STRSHKN_BUILD_PASS_VERSTAT N")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PARMVAL of STRSHKN_BUILD_PASS_VERSTAT ");
        print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        if (grep /REPLACED/, $ses_core->execCmd("Y")) {            
                print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - PASS\n";       
        }else{
            print FH "STEP: Default Values of STRSHKN_BUILD_PASS_VERSTAT  - FAIL\n";
                $result = 0;
                goto CLEANUP;
        }  
    }
################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

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
sub TC2 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS PASS
    $logger->debug(__PACKAGE__ . " Inside test case TC2");

########################### Variables Declaration #############################
    $tcid = "TC2";
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
################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC3 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS PASS FAIL
    $logger->debug(__PACKAGE__ . " Inside test case TC3");

########################### Variables Declaration #############################
    $tcid = "TC3";
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

################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC4 { #Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
    $logger->debug(__PACKAGE__ . " Inside test case TC4");

########################### Variables Declaration #############################
    $tcid = "TC4";
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

################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC5 { #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat Y
    $logger->debug(__PACKAGE__ . " Inside test case TC5");

########################### Variables Declaration #############################
    $tcid = "TC5";
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
   
################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC6 { #Provisioning_office parameters datafil control STRSHKN_Build_Pass_Verstat N
    $logger->debug(__PACKAGE__ . " Inside test case TC6");
########################### Variables Declaration #############################
    $tcid = "TC6";
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

################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
} 
sub TC7 { #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat  Y
    $logger->debug(__PACKAGE__ . " Inside test case TC7");

########################### Variables Declaration #############################
    $tcid = "TC7";
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

################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC8 { #Provisioning_office parameters datafil control STRSHKN_Pass_Verstat  N
    $logger->debug(__PACKAGE__ . " Inside test case TC8");
########################### Variables Declaration #############################
    $tcid = "TC8";
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

################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC9 { #OM_Verify Display oms : STRSHKN1 is support 
    $logger->debug(__PACKAGE__ . " Inside test case TC9");

########################### Variables Declaration #############################
    $tcid = "TC9";
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
################################## Cleanup 009 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC10 { #OM_Verify Display oms : STRSHKN2 is support 
    $logger->debug(__PACKAGE__ . " Inside test case TC10");

########################### Variables Declaration #############################
    $tcid = "TC10";
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
################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC11 { #Error path_set STRSHKN_ENABLED Y Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case TC11");

########################### Variables Declaration #############################
    $tcid = "TC11";
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
################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC12 { #Error path_set STRSHKN_ENABLED Y N when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case TC12");

########################### Variables Declaration #############################
    $tcid = "TC12";
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
################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC13 { #Error path_Provisioning_office parameters datafil control STRSHKN_Verstat_Mapping PASS FAIL FAIL
    $logger->debug(__PACKAGE__ . " Inside test case TC13");

########################### Variables Declaration #############################
    $tcid = "TC13";
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
################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC14 { #Error path_set STRSHKN_ENABLED N Y when The Stir Shaken SOC CS2B0009 is NOT Enabled
    $logger->debug(__PACKAGE__ . " Inside test case TC14");

########################### Variables Declaration #############################
    $tcid = "TC14";
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
################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub TC15 { #OM_Verify New OM STRSHKN values : VERSTATB 
    $logger->debug(__PACKAGE__ . " Inside test case TC15");

########################### Variables Declaration #############################
    $tcid = "TC15";
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
        if ($_ =~ /(\d+)\s+\d+\s+/) {
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
        unless ((grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+B/, @callTrakLogs)) {
            #grep /DATA CHARS\s+:\s+KINGOFKINGOFCVAR/, @callTrakLogs) and (grep /STRSHKN_ATTESTATION\s+:\s+A/, @callTrakLogs) and (grep /STRSHKN_VERSTAT\s+:\s+NOINFO/, @callTrakLogs
            $logger->error(__PACKAGE__ . " $tcid: STRSHKN_IE IE is not generated on calltraklogs ");
            $result = 0;
            print FH "STEP: Check STRSHKN_IE IE - FAIL\n";
        } else {
            print FH "STEP: Check STRSHKN_IE IE - PASS\n";
        }
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

1;
