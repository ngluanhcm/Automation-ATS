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
                't15_isup_atc' =>{
                                -acc => 501,
                                -region => 'US',
                                -clli => 'T15SSTATC',
                            },
                't20_g6_BTUP' =>{
                                -acc => 414,
                                -region => 'US',
                                -clli => 'T20G9BTUP2W',
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
                    # "tms1243150",	#ABH-1783 - Verify qdnwrk command for MGCP lines have Teen Service SDN
                    # "tms1243135",	#AKF-40036 - Verify the test call from TD trunk to the line with RSUS OPRT option
                    # "tms1243136",	#AKF-40309 - Provision TTU Circuit as IBERT Tester in table FMRESINV
                    "tms1309895",	#AKF-40665- Verify the Core Rex Test and GWC Rex Test can not run at the same time
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

    my $logutil_start = 0;

    my ($dialed_num, $ses_core1);
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
sub tms1243135 { #AKF-40036 - Verify the test call from TD trunk to the line with RSUS OPRT option
    $logger->debug(__PACKAGE__ . " Inside test case tms1243135");

########################### Variables Declaration #############################
    $tcid = "tms1243135";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/DEAP");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, );
    
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
    foreach ($db_trunk{'t15_isup_atc'}{-clli}) {
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
#translation line to ATC
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_isup_atc'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    unless (grep /$db_trunk{'t15_isup_atc'}{-clli}/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'traver l $list_dn[0] $dialed_num b' ");
        print FH "STEP: fix translation line to SST\n";
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CONFIRM/, $ses_core->execCmd("rep 501 N D T15SSTATC 3 \$ N \$ \$ ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep 501 N D T15SSTATC 3 \$ N \$ \$ ' ");
        }else{
            $ses_core->execCmd("Y");
        }
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0 \( 33\) ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0 \( 33\) ' ");
        }
        $ses_core->execCmd("SUBTABLE RTEREF");
        unless (grep /CONFIRM/, $ses_core->execCmd("add 501 T OFRT 501")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add 501 T OFRT 501' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        $ses_core->execCmd("quit all");
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0 \( 33\) ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0 \( 33\) ' ");
        }
        $ses_core->execCmd("SUBTABLE HNPACODE");
        unless (grep /CONFIRM/, $ses_core->execCmd("add 501 501 FRTE 501")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add 501 501 FRTE 501' ");
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
    $trunk_access_code = $db_trunk{'t15_isup_atc'}{-acc};
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
################################## Cleanup tms1243135 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1243135 ##################################");

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
sub tms1243136 { #AKF-40309 - Provision TTU Circuit as IBERT Tester in table FMRESINV
    $logger->debug(__PACKAGE__ . " Inside test case tms1243136");

########################### Variables Declaration #############################
    $tcid = "tms1243136";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/DEAP");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@TRKOPTS ,@temp );

    my $logutil_start = 0;
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
# Add TTU trunk
    unless (grep /TABLE: FMRESINV/, $ses_core->execCmd("table FMRESINV")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd table FMRESINV");
        print FH "STEP: exec cmd table FMRESINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: exec cmd table FMRESINV - PASS\n";
    }
    unless (grep /succesfully/, $ses_core->execCmd("add IBERT 4 g TTU 0 all y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd add IBERT");
        print FH "STEP: exec cmd add IBERT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: exec cmd add IBERT - PASS\n";
    }

###################### Call flow ###########################
################################## Cleanup tms1243136 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1243136 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1309895 { #AKF-40665- Verify the Core Rex Test and GWC Rex Test can not run at the same time
    $logger->debug(__PACKAGE__ . " Inside test case tms1309895");

########################### Variables Declaration #############################
    $tcid = "tms1309895";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/DEAP");

    my $TRKOPTS_config = 0;
    my $LTDATA_config = 0;
    my $flag = 1;
    my (@TRKOPTS ,@temp );

    my $logutil_start = 0;
    my ($ses_core1);

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
    unless ($ses_core1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA15 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
# check Table Rexsched
    unless (grep /TABLE: REXSCHED/, $ses_core->execCmd("Table Rexsched")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec Table Rexsched");
        print FH "STEP: Table Rexsched - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Table Rexsched - PASS\n";
    }
    unless (grep /CA_REX_TEST/, $ses_core->execCmd("pos CA_REX_TEST Y 1 1 NONE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot check CA_REX_TEST Y 1 1 NONE");
        print FH "STEP: check CA_REX_TEST Y 1 1 NONE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check CA_REX_TEST Y 1 1 NONE - PASS\n";
    }
    unless (grep /GWC_DATA_REFRSH/, $ses_core->execCmd("pos GWC_DATA_REFRSH Y 1 3 NONE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot check GWC_DATA_REFRSH Y 1 3 NONE");
        print FH "STEP: check GWC_DATA_REFRSH Y 1 3 NONE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check GWC_DATA_REFRSH Y 1 3 NONE - PASS\n";
    }
# Rex Test GWC
    $ses_core1->execCmd("cli");
    sleep(5);
    #pos GWC in Mapci
    $ses_core->{conn}->prompt('/\>/');
    my @cmd_result;
    my $status;
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GWC 4")) {
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
    $ses_core1->execCmd("cli");
    sleep(5);
    $ses_core->execCmd("7 NOW",5);
    $ses_core->execCmd("y",5);
  
#  Rex core
    $ses_core1->{conn}->prompt('/cli/');
    $ses_core1->execCmd("sosAgent vca rex VCA");
    # $ses_core1->{conn}->prompt('/\>/'); # prevPrompt is /.*[\$%#\}\|\>\]].*$/
    unless (grep /Rejected/, $ses_core1->execCmd("y",1000)) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd sosAgent vca rex VCA");
        print FH "STEP: Core Rex Test and GWC Rex Test can not run at the same time - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Core Rex Test and GWC Rex Test can not run at the same time - PASS\n";
    }

###################### Call flow ###########################
################################## Cleanup tms1309895 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1309895 ##################################");

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
