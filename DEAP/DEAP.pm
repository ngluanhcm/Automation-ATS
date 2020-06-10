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
                'gpp_2' => {
                            -line => 12,
                            -dn => 4005007605,
                            -region => 'IL',
                            -len => 'GPPV   00 0 00 05',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'gpp_1' => {
                            -line => 13,
                            -dn => 4005007606,
                            -region => 'IL',
                            -len => 'GPPV   00 0 00 06',
                            -info => 'IBN AUTO_GRP 0 0',
                            },

                );

our %tc_line = (
                'tms1243150' => ['gr303_1','gr303_2'],
                'tms1243135' => ['gr303_1','gr303_2'],
                'tms1309896' => ['gpp_1','gpp_2'],
                'tms1309897' => ['gr303_1','gr303_2','gr303_3','gr303_4'],
);
# Info for OSSGATE
our @ossgate = ('cmtg', 'cmtg');
#################### Trunk info ###########################
our %db_trunk = (
                't15_isup_atc' =>{
                                -acc => 229,
                                -region => 'US',
                                -clli => 'G9OC3C7ATCE2W',
                            },
                't20_g6_BTUP' =>{
                                -acc => 414,
                                -region => 'US',
                                -clli => 'T20G9BTUP2W',
                            },
                't20_isup' =>{
                                -acc => 872,
                                -region => 'US',
                                -clli => 'T20SSTBASEV1LP',
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
                    # "tms1243135",	#AKF-40036 - Verify the test call from TD trunk ATC to the line with RSUS OPRT option
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
# Telnet to OSSGATE
	$ses_core1 ->{conn}->prompt('/>/');
	if (grep /Enter username and password/, $ses_core1->execCmd("telnet cmtg 10023")){
		$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate");
		$ses_core1 ->{conn}->prompt('/>/');
		if (grep /logged in/, $ses_core1->execCmd("$ossgate[0] $ossgate[1]")){
			$logger->debug(__PACKAGE__ . " $tcid: Login to ossgate with account $ossgate[0] $ossgate[1]");
			print FH "STEP: Login to OSSGATE - PASSED\n";
		} else {
			$logger->error(__PACKAGE__ . " $tcid: Can't login to ossgate");
			print FH "STEP: Login to OSSGATE - FAILED\n";
			$result = 0;
			goto CLEANUP;
		}
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
sub tms1243135 { #AKF-40036 - Verify the test call from TD trunk ATC to the line with RSUS OPRT option
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
        print FH "STEP: fix translation line to atc\n";
        unless (grep /TABLE:.*HNPACONT/, $ses_core->execCmd("table HNPACONT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table HNPACONT' ");
        }
        unless (grep /213/, $ses_core->execCmd("pos 213 Y 1023 0 \(190\) ")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos 213 Y 1023 0 \( 33\) ' ");
        }
        $ses_core->execCmd("SUBTABLE RTEREF");
        unless (grep /CONFIRM/, $ses_core->execCmd("rep $db_trunk{'t15_isup_atc'}{-acc} N D G9OC3C7ATCE2W 0 \$ N")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_isup_atc'}{-acc} T OFRT $db_trunk{'t15_isup_atc'}{-acc}' ");
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
        unless (grep /CONFIRM/, $ses_core->execCmd("add $db_trunk{'t15_isup_atc'}{-acc} $db_trunk{'t15_isup_atc'}{-acc} FRTE $db_trunk{'t15_isup_atc'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'add $db_trunk{'t15_isup_atc'}{-acc} $db_trunk{'t15_isup_atc'}{-acc} FRTE $db_trunk{'t15_isup_atc'}{-acc}' ");
        }else{
            $ses_core->execCmd("Y");
            $ses_core->execCmd("abort");
        }
        unless (grep /$db_trunk{'t15_isup_atc'}{-clli}/, $ses_core->execCmd("traver l $list_dn[0] $dialed_num b")) {
        $logger->error(__PACKAGE__ . " $tcid: traver l $list_dn[0] $dialed_num b fail");
        print FH "STEP: translation line to ATC - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: translation line to ATC - PASS\n";
    }
    }else{
        print FH "STEP: translation line to ATC - PASS\n"; 
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
# add RSUS OPRT
    $ses_core->execCmd("servord");
    unless (grep /JOURNAL/, $ses_core->execCmd("ado \$ $list_dn[1] RSUS OPRT OPRT \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot add RSUS");
        print FH "STEP: add RSUS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add RSUS - PASS\n";
    }

# A calls B via trunk and hears ringback then B ring and check speech path
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_isup_atc'}{-acc};
    $dialed_num = $trunk_access_code . $1;
    # Offhook A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    # SendDigits
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
    # DetectRinging
    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        print FH "STEP: Check line A ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ring - PASS\n";
    }
    # Offhook A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
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
# check TRKMEM TTU 
    unless (grep /TRKMEM\s+TTU/, $ses_core->execCmd("clliref search ttu")) {
        $logger->error(__PACKAGE__ . " $tcid: missing trunk mem ttu");
        print FH "STEP: check trunk mem ttu (should add TTU 0 0 RMM 4 2 and TTU 0 0 RMM 4 3 )- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check trunk mem ttu - PASS\n";
    }
# Add TTU trunk
    unless (grep /TABLE: FMRESINV/, $ses_core->execCmd("table FMRESINV")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd table FMRESINV");
        print FH "STEP: exec cmd table FMRESINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: exec cmd table FMRESINV - PASS\n";
    }
    
    if (grep /IBERT/, $ses_core->execCmd("pos IBERT 4 g TTU 0 all")) {
        $ses_core->execCmd("del IBERT 4 g TTU 0 all");
        $ses_core->execCmd("y")
    }
    $ses_core->execCmd("add IBERT 4 g TTU 0 all y");
    unless (grep /ADDED/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd add IBERT");
        print FH "STEP: exec cmd add IBERT - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }else {
        print FH "STEP: exec cmd add IBERT - PASS\n";
    }
    $flag = 1;
###################### Call flow ###########################
################################## Cleanup tms1243136 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1243136 ##################################");
    
    # del TTU trunk
    if($flag){
        $ses_core->execCmd("del IBERT 4 g TTU 0 all");
        unless (grep /DELETED/, $ses_core->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot exec cmd add IBERT");
            print FH "STEP: exec cmd del IBERT - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: exec cmd del IBERT - PASS\n";
        }
    }

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
    my $ofrt_config = 0;
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
    unless ($ses_core1->loginCore(-username => [@{$core_account{-username}}[3..5]], -password => [@{$core_account{-password}}[3..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
		print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
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

###################### Call flow ###########################
# SREXDBG in core
    $ses_core1->execCmd("quit all");
    $ses_core1->execCmd("SREXDBG");

# Rex Test GWC
    #pos GWC in Mapci
    $ses_core->{conn}->prompt('/\>/');
    my @cmd_result;
    my $status;
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GWC 4")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post GWC 4'");
        print FH "STEP: Execution cmd 'post  GWC 4' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post GWC 4' - PASS\n";
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
    $ses_core->execCmd("7 NOW",5);
    $ses_core->execCmd("y",5);
    sleep(2);
    # $ses_core->{conn}->print("y\n");
# Rex core
    my @output;
    #prompt
    $ses_core1->{conn}->prompt('/\>/');
    unless (grep /CA_REX_TEST/, @output = $ses_core1->execCmd("LISTOBJ")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execCmd LISTOBJ");
        print FH "STEP: execCmd LISTOBJ - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd LISTOBJ - PASS\n";
    }
    my $MANREQ ;
    foreach (@output) {
        if (/(\d+)\s+CA_REX_TEST.*\{(.*)\}/) {
        $MANREQ = $1." N ".$2;
        last;
        }
    }
    unless (grep /Rex test conflicts with one running/, $ses_core1->execCmd("MANREQ $MANREQ")) {
        $logger->error(__PACKAGE__ . " $tcid: Rex test conflicts with one running - FAIL ");
        print FH "STEP: Rex test conflicts with one running - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Rex test conflicts with one running - PASS\n";
    }
################################## Cleanup tms1309895 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1309895 ##################################");

    close(FH);
    &Luan_cleanup();
    # check the result var to know the TC is passed or failed
    &Luan_checkResult($tcid, $result);
}
sub tms1309896 { #AKF-40375 Verify AMA Billing Module Code 130 Facility Release field has correct values
    $logger->debug(__PACKAGE__ . " Inside test case tms1309896");

########################### Variables Declaration #############################
    $tcid = "tms1309896";
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
    my $ofrt_config = 0;
################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:2:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:2:ce0'}" );
        print FH "STEP: Login TMA20- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:2:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:2:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASS\n";
    }
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..8]], -password => [@{$core_account{-password}}[2..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
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
		sleep(5);
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
    foreach ($db_trunk{'t20_g6_BTUP'}{-clli},$db_trunk{'t20_isup'}{-clli}) {
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
# config table OFRT
    unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
    }
    unless (grep /$db_trunk{'t20_isup'}{-clli}/, $ses_core->execCmd("pos $db_trunk{'t20_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t20_isup'}{-acc}' ");
    }
    foreach ('cha','N','D',$db_trunk{'t20_isup'}{-clli},'3',$db_trunk{'t20_g6_BTUP'}{-acc},'n','$','$','$','y') {
        unless ($ses_core->execCmd($_)) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
            last;
        }
    }
    $ses_core->execCmd("abort");
    unless (grep /$db_trunk{'t20_g6_BTUP'}{-acc}/, $ses_core->execCmd("pos $db_trunk{'t20_isup'}{-acc}")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot change PRFXDIGS G6VZSTSPRINT2W");
        print FH "STEP: change PRFXDIGS $db_trunk{'t20_g6_BTUP'}{-acc} of G6VZSTSPRINT2W - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: change PRFXDIGS $db_trunk{'t20_g6_BTUP'}{-acc} of G6VZSTSPRINT2W - PASS\n";
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
# LINE -> ISUP trk -> BTUP trk -> LINE
    $dialed_num = $list_dn[1] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t20_isup'}{-acc};
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
                -detect => ['NONE','DELAY 10','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LINE -> ISUP trk -> BTUP trk -> LINE ");
        print FH "STEP: LINE -> ISUP trk -> BTUP trk -> LINE  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LINE -> ISUP trk -> BTUP trk -> LINE - PASS\n";
    }

################################## Cleanup tms1309896 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1309896 ##################################");

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
        @output = $ses_logutil->execCmd("catchama");
        unless (grep /present/, @output) {
            $result = 0;
            print FH "STEP: Check catchama - FAIL\n";
        } else {
            print FH "STEP: Check catchama - PASS\n";
        }
        @output = $ses_logutil->execCmd("catchama show rec");
        unless (grep /130C/, @output) {
            $result = 0;
            print FH "STEP: Check MODULE CODE:130C - FAIL\n";
        } else {
            print FH "STEP: Check MODULE CODE:130C - PASS\n";
        }
    }
    # Rollback table OFRT
    if ($ofrt_config) {
        unless (grep /TABLE:.*OFRT/, $ses_core->execCmd("table OFRT")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table OFRT' ");
        }
        unless (grep /CLF_ACCESS_CODE/, $ses_core->execCmd("pos $db_trunk{'t20_isup'}{-acc}")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos $db_trunk{'t20_isup'}{-acc}' ");
        }
        foreach ('cha','N','D',$db_trunk{'t20_isup'}{-clli},'3','$','n','$','$','$','y') {
            unless ($ses_core->execCmd($_)) {
                $logger->error(__PACKAGE__ . " $tcid: cannot execute command '$_' ");
                last;
            }
        }
        $ses_core->execCmd("abort");
        if (grep /$db_trunk{'t20_g6_BTUP'}{-acc}/, $ses_core->execCmd("pos $db_trunk{'t20_isup'}{-acc}")) {
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
sub tms1309897 { #AKF-40363 - Verify calling party number is displayed on phone via PRI trunk
    $logger->debug(__PACKAGE__ . " Inside test case tms1309897");

########################### Variables Declaration #############################
    $tcid = "tms1309897";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/DEAP");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $tapilog_dir = "/home/$user_name/ats_user/logs/DEAP";
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, %info,$tapi_start, $dialed_num, $add_feature_lineD, $add_feature_lineB,$add_feature_lineC);

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
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA2m for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA2m for tapi trace- PASSED\n";
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
# Add CND line D
    unless ($ses_core->callFeature(-featureName => "CND NOAMA", -dialNumber => $list_dn[3], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add CND for line $list_dn[3]");
            print FH "STEP: add CND for line A $list_dn[3] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add CND for line A $list_dn[3] - PASS\n";
        }
    $add_feature_lineD = 1;
# Add CFU line B
    unless ($ses_core->callFeature(-featureName => "CFU N", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[1]");
		print FH "STEP: add CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[1] - PASS\n";
    }
    $add_feature_lineB = 1;
# B activate CFU for line C via SST
    $dialed_num = $list_dn[2] =~ /\d{3}(\d+)/;
    my $trunk_access_code = $db_trunk{'t15_sst'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    unless ($ses_core->execCmd("Servord")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'servord'");
    }
    unless ($ses_core->execCmd("changecfx $list_len[1] CFU $dialed_num A")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'changecfx'");
    }
    unless (grep /CFU.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[1]");
        print FH "STEP: activate CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[1] - PASS\n";
    }
# add simring for C and D (via pri)
    $dialed_num = $list_dn[3] =~ /\d{3}(\d+)/;
    $trunk_access_code = $db_trunk{'t15_pri'}{-acc};
    $dialed_num = $trunk_access_code . $1;

    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'servord'");
    }
    $ses_core->execCmd("est \$ SIMRING $list_dn[2] $dialed_num \+");
    unless ($ses_core->execCmd("\$ ACT N 1234 Y Y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }

    @output = $ses_core->execCmd("qsimr $list_dn[2]");
    unless ((grep /Member DN 1 .* $dialed_num/, @output) and (grep /Pilot DN: .* $list_dn[2]/, @output)) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group SIMRING for line $list_dn[2] and $dialed_num");
		print FH "STEP: create group SIMRING for line $list_dn[2] and $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group SIMRING for line $list_dn[2] and $dialed_num - PASS\n";
    }
    $add_feature_lineC = 1;
# Start tapi trace
	%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
					-list_trk_clli => [],
				);
	%info = $ses_tapi->startTapiTerm(%input);
	unless(%info) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start tapitrace");
			print FH "STEP: Start tapitrace - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
			print FH "STEP: Start tapitrace - PASSED\n";
	}
	$tapi_start = 1;
	
# A call B
    # Offhook A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    # DetectDialTone A
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hear dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear dial tone - PASS\n";
    }
    # SendDigits
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
# DetectRinging C
    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }
# DetectRinging D
    %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D not ring");
        print FH "STEP: Check line D ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ring - PASS\n";
    }

################################## Cleanup tms1309897 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup tms1309897 ##################################");

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
    # Stop tapi
    my $exist1 = 1;
    # my $exist2 = 1;
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
            print FH "STEP: Stop tapitrace - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop tapitrace - PASSED\n";
        }
        foreach my $gwc_id (keys %tapiterm_out) {
            foreach my $tn (keys %{$tapiterm_out{$gwc_id}}) {
                if (grep /3\d3\d3\d3\d3\d3\d3\d3\d3\d3\d3/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 0;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        unless ($exist1) {
            print FH "STEP: Check the message calling party number  on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message calling party number  on tapi log - FAILED\n";
            $result = 0;
        }
        # unless ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
    # Remove CFU from line B
    unless ($add_feature_lineB) {
        foreach ('CFU'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }
    # Remove CND from line D
    if ($add_feature_lineD) {
        unless ($ses_core->callFeature(-featureName => "CND", -dialNumber => $list_dn[3], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SCS from line $list_dn[3]");
            print FH "STEP: Remove CND from line $list_dn[3] - FAIL\n";
        } else {
            print FH "STEP: Remove CND from line $list_dn[3] - PASS\n";
        }
    }
    # Remove SIMRING from line C
        if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[2]");
            print FH "STEP: Remove SIMRING from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[2] - PASS\n";
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
