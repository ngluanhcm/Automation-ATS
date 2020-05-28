#**************************************************************************************************#
#FEATURE                : <Table SITE Expansion> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Che Thi Thanh Tuyen>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::ADQ1114::ADQ1114;

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
our ($ses_core, $ses_glcas, $ses_logutil, $ses_tapi, $ses_tapi_1, $ses_calltrak, $ses_core_li, $ses_cli);
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
# For LI
our %core_account_li = ( 
                    -username => ['thong', 'phuc', 'tuyen', 'vinh', 'cuong', 'nghia', 'trong', 'viet'], 
                    -password => ['thong', 'phuc', 'tuyen', 'vinh', 'cuong', 'nghia', 'trong', 'viet']
                    );
					
# Info for OSSGATE
our @ossgate = ('cmtg', 'cmtg');					

# For GLCAS
our @cas_server = ('10.250.185.232', '10024');
our $sftp_user = 'gbautomation';
our $sftp_pass = '12345678x@X';
our $wait_for_event_time = 30;
our $tapilog_dir = '/home/ntthuyhuong/Tapi_hnphuc/';
our $li_user = 'thong';
our $pass_li = '123456';

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{"c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};
our ($root_pass) = $alias_hashref->{LOGIN}->{1}->{ROOTPASSWD};

####################### Which logs need to get ########################################
our @log_type = (1, 1, 1, 1); # get logutil, pcm, tapi, calltrak respectively

# Line Info
# our %db_line = (
                # 'V52_1' => {
                            # -line => 3,
                            # -dn => 4005007123,
                            # -region => 'US',
                            # -len => 'V52    01 0 00 23',
                            # -info => 'IBN AUTO_GRP 0 0',
                            # },
                # 'V52_2' => {
                            # -line => 4,
                            # -dn => 4005007124,
                            # -region => 'US',
                            # -len => 'V52    01 0 00 24',
                            # -info => 'IBN AUTO_GRP 0 0',
                            # },
                 # 'V52_3' => {
                            # -line => 32,
                            # -dn => 4005007122,
                            # -region => 'US',
                            # -len => 'V52    01 0 00 22',
                            # -info => 'IBN AUTO_GRP 0 0',
                            # },
				# 'V52_4' => {
                            # -line => 39,
                            # -dn => 4005007230,
                            # -region => 'US',
                            # -len => 'V52    02 0 00 30',
                            # -info => 'IBN AUTO_GRP 0 0',
                            # },
				# 'V52_5' => {
                            # -line => 43,
                            # -dn => 4005007228,
                            # -region => 'US',
                            # -len => 'V52    02 0 00 28',
                            # -info => 'IBN AUTO_GRP 0 0',
                            # },		
                # );

our %db_line = (
                'V52_1' => {
                            -line => 19,
                            -dn => 4005007114,
                            -region => 'US',
                            -len => 'V52    01 0 00 14',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'V52_2' => {
                            -line => 18,
                            -dn => 4005007229,
                            -region => 'US',
                            -len => 'V52    02 0 00 29',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                 'V52_3' => {
                            -line => 24,
                            -dn => 4005007115,
                            -region => 'US',
                            -len => 'V52    01 0 00 15',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
				'V52_4' => {
                            -line => 10,
                            -dn => 4005004002,
                            -region => 'UK',
                            -len => 'HOST    02 0 00 02',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
				'V52_5' => {
                            -line => 11,
                            -dn => 4005004003,
                            -region => 'UK',
                            -len => 'HOST    02 0 00 03',
                            -info => 'IBN AUTO_GRP 0 0',
                            },			
						
                );

our %tc_line = (
                'ADQ1114_001' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_002' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_003' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_004' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_005' => ['V52_1','V52_2','V52_3','V52_4','V52_5'],
				'ADQ1114_006' => ['V52_1','V52_2','V52_3','V52_4','V52_5'],
				'ADQ1114_007' => ['V52_1','V52_2','V52_3','V52_4','V52_5'],
				'ADQ1114_008' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_009' => ['V52_1','V52_2','V52_3','V52_4','V52_5'],
				'ADQ1114_010' => ['V52_1','V52_2','V52_3','V52_4'],
				'ADQ1114_011' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_012' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_013' => ['V52_1','V52_2', 'V52_3', 'V52_4', 'V52_5'],
				'ADQ1114_014' => ['V52_1','V52_2', 'V52_3', 'V52_4', 'V52_5'],
				'ADQ1114_015' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_016' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_017' => ['V52_1','V52_2', 'V52_3', 'V52_4', 'V52_5'],
				'ADQ1114_018' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_019' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				'ADQ1114_020' => ['V52_1','V52_2', 'V52_3', 'V52_4'],
				
				
);

#################### Trunk info ###########################
our %db_trunk = (
                'cas_r2' => {
                                -acc => 204,
                                -region => 'US',
                                -clli => 'T2MG9ETSIPRI2W',
                            },
				'sst' =>{
                                -acc => 872,
                                -region => 'US',
                                -clli => 'T20SSTBASEV1LP',
                            },
				'pri_1' => {
                                -acc => 202,
                                -region => 'US',
                                -clli => 'AUTOETSIPRIEN2W',
                            },		
                'tw_isup' =>{
                                -acc => 302,
                                -region => 'US',
                                -clli => 'T20G6ANSI2W',
                            },
				'g6_pri' =>{
                                -acc => 104,
                                -region => 'US',
                                -clli => 'T20G6E1PRITEXT2W',
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

sub ADQ1114_cleanup {
    my $subname = "ADQ1114_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_tapi, $ses_tapi_1, $ses_calltrak, $ses_core_li, $ses_cli
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ1114_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ1114_checkResult";
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
                     "ADQ1114_001",
					"ADQ1114_002",
					"ADQ1114_003",
					"ADQ1114_004",
					"ADQ1114_005",
					"ADQ1114_006",
					"ADQ1114_007",
					"ADQ1114_008",
					"ADQ1114_009",
					"ADQ1114_010",
					"ADQ1114_011",
					"ADQ1114_012",
					"ADQ1114_013",
					"ADQ1114_014",
					"ADQ1114_015",
					"ADQ1114_016",
					"ADQ1114_017",
					"ADQ1114_018",
					"ADQ1114_019",
					"ADQ1114_020",
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
# |            		    LI Regression (International)                              |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Che Thi Thanh Tuyen ##########################

# Note:
# + The TCs have DNH group is failed due to this field :XLAPLAN_RATEAREA_SERVORD_ENABLED MANDATORY_PROMPTS in "table ofcvar"
# --> Disable it by command: rep XLAPLAN_RATEAREA_SERVORD_ENABLED OFF
# + Need to manual check all trunks (which were inputted in script) are IDL before you are run test suite.

# + For LI TCs: Before run test suite, please check acc thong/thong then access core LI by user/pass is: dnbdord ->123456. 

sub ADQ1114_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_001");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_001";
    my $tcid = "ADQ1114_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
	my $li_added = 0;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
	
    # Which logs need to get
     $log_type[0] = 1; #logutil
	 $log_type[1] = 1; #pcm
	 $log_type[2] = 0; #tapi
	 $log_type[3] = 0; #calltrack
    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 ibn $list_dn[1] +");
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line B  ");
        print FH "STEP: Add SURV to line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line B - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	############### Add feature for line ###################
	
# Add CFB and CBU to line B

	foreach ('CFB P','CBU') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: add $_ for line A $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: add $_ for line A $list_dn[1] - PASS\n";
        }
    }
	
	 unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
    $add_feature_lineB = 0;

# Active CFB to forward to D
	unless ($ses_core->execCmd ("changecfx $list_len[1] CFB $list_dn[3] A")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot active CFB for line $list_dn[3]");
		print FH "STEP: Active CFB for line B($list_dn[3]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Active CFB for line B($list_dn[3]) - PASSED\n";
    }

   # Verify active CFB for line B
	unless (grep /CFB.*\sA\s/, $ses_core->execCmd("qdn $list_dn[1]")) {	 	 
       $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFB for line $list_dn[2]");	 	 
       print FH "STEP: Verify activate CFB for line B $list_dn[1] - FAIL\n";	 	 
	  $result = 0;	 	 
	   goto CLEANUP;	 	 
	 } else {	 	 
	        print FH "STEP: Verify activate CFB for line B $list_dn[1] - PASS\n";	 	 
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # A calls B, check speech path

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
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls B and they have no speech path ");
        print FH "STEP: A calls B and they have speech path, A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path, A flash - PASS\n";
    }
	
	# Check line D have ringing tone

	 %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	 # D still monitor A & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[0], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA D can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and B - PASS\n";
    }
	
	# Onhook A
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
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
	
	# Onhook D
    unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[3]");
        print FH "STEP: Onhook line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line D - PASS\n";
    }
	
	sleep(2);
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials B , B dosen't rings then D will answers,  
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
		print FH "STEP: C dials B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials B $list_dn[1] - PASS\n";
    }
	
	sleep(2);
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between B and D

	 %input = (
                -list_port => [$list_line[2],$list_line[3]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and D");
        print FH "STEP: Check speech path between C and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and D - PASS\n";
    }
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# remove CFB and CBU from line B
    unless ($add_feature_lineB) {
        foreach ('CFB','CBU'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }
	
    close(FH);
	
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);   
	
}

sub ADQ1114_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_002");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_002";
    my $tcid = "ADQ1114_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
	my $li_added = 0;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 ibn $list_dn[1] +");
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line B  ");
        print FH "STEP: Add SURV to line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line B - PASS\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	############### Add feature for line ###################
	
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

 # A calls B, check speech path

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
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: A calls B and they have no speech path ");
        print FH "STEP: A calls B and they have speech path, A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and they have speech path, A flash - PASS\n";
    }
	
	# Check line D have ringing tone

	 %input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	 # LEA D monitor A & B successfully

    %input = (
                -list_port => [$list_line[0], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA D can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and B - PASS\n";
    }
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials B , B hears cwt tone
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
		print FH "STEP: C dials B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials B $list_dn[1] - PASS\n";
    }
	
	# Check line B hears CWT tone
	
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
	
	# B flashes
	  %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line B $list_line[1]");
		print FH "STEP: B flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flash - PASS\n";
		
    }
	
	# Verify B,C have speech path
	 %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and C");
        print FH "STEP: Check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and C - PASS\n";
    }
	
	# # LEA D hears silent in this time
    # %input = (
                # -list_port => [$list_line[0],$list_line[1]],
                # -cas_timeout => 20000,
                # -lea_port => $list_line[3],
                # ); 
    # if ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        # $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between B and E");
        # print FH "STEP: LEA A hears silent in this time - FAIL\n";
        # $result = 0;
        # goto CLEANUP;
    # } else {
        # print FH "STEP: LEA A hears silent in this time - PASS\n";
    # }
	
	# Onhook line B
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
	
	# Onhook line C

	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }

	
	# Check line B re-ringging
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
        print FH "STEP: Check line B re-rings - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B re-rings - PASS\n";
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
	
	 # LEA D monitor A & B successfully

    %input = (
                -list_port => [$list_line[1], $list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA D can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and B - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# remove CWT and CWI from line B
    unless ($add_feature_lineB) {
        foreach ('CWI','CWT'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_003");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_003";
    my $tcid = "ADQ1114_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
	my $li_added = 0;
	my $mlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	#Add MLH for line A and line B
	
	
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add MLH
	
    $ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 6 y y")) {
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
	$mlh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	

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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials A , B rings and answer
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
	# Check line B ringing
	
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
	
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between C and B

	 %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }
	
	 # D still monitor C & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[1], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B ");
        print FH "STEP: LEA D can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between C and B - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# remove MLH
	$ses_core->execCmd ("servord");
    unless ($mlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from MLH group");
            print FH "STEP: delete member $list_dn[1] from MLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from MLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);   

}

sub ADQ1114_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_004");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_004";
    my $tcid = "ADQ1114_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
	my $li_added = 0;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	# Add DNH group: A is pilot, B is member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	$li_added = 1;

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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials A , B rings and answer
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
	# Check line B ringing
	
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
	
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between C and B

	 %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }
	
	 # D still monitor C & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[1], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B ");
        print FH "STEP: LEA D can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between C and B - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
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
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);   

}

sub ADQ1114_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_005");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_005";
    my $tcid = "ADQ1114_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
	my $li_added = 0;
	my $mlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
       $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	#Add MLH for line A and line B
	
	
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add MLH
	
    $ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 6 y y")) {
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
	$mlh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	# Add CPU to line C and B (C and B must have the same custgroup)
	
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[2] $list_len[1] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[2] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[2]")) {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[1] - FAIL\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[2] and $list_dn[1] - PASS\n";
    }
   
    $add_feature_lineC = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'CPU');
    unless ($cpu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CPU access code");
		print FH "STEP: get CPU access code is $cpu_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CPU access code is $cpu_acc - PASS\n";
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Offhook line E
	unless($ses_glcas->offhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line E $list_line[4]");
        print FH "STEP: offhook line E $list_line[4] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line E $list_line[4] - PASS\n";
    }
	
	#  E dials C, C rings and answer
	%input = (
                -line_port => $list_line[4],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
		print FH "STEP: E dials C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: E dials C $list_dn[2] - PASS\n";
    }
	
	# Check line C ringing
	
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# B dials CPU access code

	sleep(1);
	my $dialed_num = "\*$cpu_acc";
    %input = (
                -line_port => $list_line[1],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: B dials cpu_acc CHD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials cpu_acc CHD - PASS\n";
    }
	
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between E and B

	 %input = (
                -list_port => [$list_line[4],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between E and B");
        print FH "STEP: Check speech path between E and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between E and B - PASS\n";
    }
	
	 # D still monitor E & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[4], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between E and B ");
        print FH "STEP: LEA D can monitor the call between E and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between E and B - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# remove MLH
	$ses_core->execCmd ("servord");
    unless ($mlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from MLH group");
            print FH "STEP: delete member $list_dn[1] from MLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from MLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
	
	# remove CPU from line C and B
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[2]");
            print FH "STEP: Remove CPU from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[2] - PASS\n";
        }
        
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    
	
}




sub ADQ1114_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_006");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_006";
    my $tcid = "ADQ1114_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'sst'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineB = 1;
	my $li_added = 0;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	# Add DNH group: A is pilot, B is member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	$li_added = 1;
	
	#### Add feature CHD for line B
	unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CHD for line A $list_dn[1]");
		print FH "STEP: add CHD for line B $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CHD for line B $list_dn[1] - PASS\n";
    }
	
	$add_feature_lineB = 0;
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
    $initialize_done = 0;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials A , B rings and answer
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
	# Check line B ringing
	
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
	
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between C and B

	 %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }
	
	 # D still monitor C & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[1], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B ");
        print FH "STEP: LEA D can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between C and B - PASS\n";
    }
	
	 # B flashes 
	 sleep(1);
	  %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line B $list_line[1]");
		print FH "STEP: B flash  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B flash  - PASS\n";
		
    }
	
	# B activates CHD 
	sleep(1);
	my $dialed_num = "\*$chd_acc";
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
	
	# B calls E, E rings and answers
	# B dials DN (E)

	 %input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[4],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial E successfully");
		print FH "STEP: B dials E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials E - PASS\n";
    }
	
	# Check line E rings 
	%input = (
                -line_port => $list_line[4],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line E does not ring");
        print FH "STEP: Check line E ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line E ringing - PASS\n";
    }
	
	# Off hook line E 
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line E $list_line[4]");
        print FH "STEP: offhook line E $list_line[4] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line E $list_line[4] - PASS\n";
    }
	
	# Verify B,E have speech path

	 %input = (
                -list_port => [$list_line[1],$list_line[4]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and E");
        print FH "STEP: Check speech path between B and E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and E - PASS\n";
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
	
	# Onhook E
    unless($ses_glcas->onhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[4]");
        print FH "STEP: Onhook line E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line E - PASS\n";
    }
	
	#Check line B re-ringing
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
	
	# D still monitor C & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[1], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B ");
        print FH "STEP: LEA D can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between C and B - PASS\n";
    }
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
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
	
	# remove CHD from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CHD', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CHD from line B $list_dn[1]");
            print FH "STEP: Remove CHD from line B $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CHD from line B $list_dn[1] - PASS\n";
        }
    }
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_007");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_007";
    my $tcid = "ADQ1114_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID, $ID1);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	# Add DNH group: A is pilot, B,C are member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1],$list_dn[2]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0]");
		print FH "STEP: create group DNH for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
	unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
	my ($lea_num1) = ($list_dn[4] =~ /\d{3}(\d+)/);
	$lea_num1 = $trunk_access_code . $lea_num1;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	
	# Add SURV to line C and LEA to line E
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[2] $list_dn[2] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num1 yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line E  ");
        print FH "STEP: Add LEA number to line E $list_dn[4]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line E $list_dn[4] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line E ");
        print FH "STEP: Add LEA number to line E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line E - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID1 = $1;
        }
	}
	print FH "Monitor Order ID is: $ID1\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	# Add CFD  to line A
       	
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[2]", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[0]");
		print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
    }
    
	
	unless(grep /CFD/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add CFD for line $list_dn[0] ");
        print FH "STEP: add CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[0] - PASS\n";
    }
   
    $add_feature_lineA = 0;

    my $cfd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CFDP');
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get PRK access code for line $list_dn[0]");
		print FH "STEP: get CFD access code for line $list_dn[0] is $cfd_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFD access code for line $list_dn[0] is $cfd_acc- PASS\n";
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Activate CFD from line A to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    my $dialed_num = '*' . $cfd_acc . $list_dn[2] . '#';
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: Send digit to active CFD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Send digit to active CFD - PASS\n";
    }
    
    unless (grep /CFD.*\sA\s/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[0]");
        print FH "STEP: activate CFD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFD for line $list_dn[0] - PASS\n";
    }
	# Onhook line A
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line A $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	#  B dials A , A rings but doesn't answer
	%input = (
                -line_port => $list_line[1],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: B dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials A $list_dn[0] - PASS\n";
    }
	
	# Check line A ringing
	
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
	
	
	# Check line D rings 
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }

	sleep(2);
	# Check line C ringing
	
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	
	# Check line E rings 
	%input = (
                -line_port => $list_line[4],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line E does not ring");
        print FH "STEP: Check line E ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line E ringing - PASS\n";
    }
	
	# Off hook line B
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Off hook line C
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	# Off hook line D
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line D $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Off hook line E
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line E $list_line[4]");
        print FH "STEP: offhook line E $list_line[4] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line E $list_line[4] - PASS\n";
    }
	
	# Verify speech path between B and C

	 %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between B and C");
        print FH "STEP: Check speech path between B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and C - PASS\n";
    }
	
	# Check Line D monitors the outgoing speech path of line B
    %input = (
                -list_port => [$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the outgoing speech path of line B");
        print FH "STEP: Line D (LEA) monitors the outgoing speech path of line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the outgoing speech path of line B - PASSED\n";
    }
# Check Line E monitors the incoming speech path of line B
    %input = (
                -list_port => [$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[4],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line B (LEA) can't monitor the incoming speech path of line B");
        print FH "STEP: Line E (LEA) monitors the incoming speech path of line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line E (LEA) monitors the incoming speech path of line B - PASSED\n";
    }
	
	
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deact LEA
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
       
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
       
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	### Deact LAE1
	
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
       
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
		
	# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
       
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	# Out session
	
	unless(grep /CI/, $ses_core_li->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot quit session ");
        print FH "STEP: Quit session - FAIL\n";
        $result = 0;
       
    } else {
        print FH "STEP: Quit session - PASS\n";
    }
	
	
	 # remove DNH group
    unless ($dnh_added) {
	
	    unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[2]");
            print FH "STEP: Remove DNH from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove DNH from line $list_dn[2] - PASS\n";
        }
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
	
	# remove CFD from line A
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line A $list_dn[0]");
            print FH "STEP: Remove CFD from line A $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line A $list_dn[0] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_008");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_008";
    my $tcid = "ADQ1114_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
	my $li_added = 0;
	my $mlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	#Add MLH for line A and line B
	
	
	# Out A, B
	$ses_core->execCmd ("servord");
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[0] ");
            print FH "STEP: OUT line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[0] - PASS\n";
        }
    
	if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[1] $list_len[1] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[1] ");
            print FH "STEP: OUT line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: OUT line $list_dn[1] - PASS\n";
        }
    
	
	# Add MLH
	
    $ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 6 y y")) {
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
	$mlh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	# C has AUL 
	 
	 
      @output = $ses_core->execCmd("ado \$ $list_dn[2] AUL $list_dn[0] \$ y y");
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
    unless(grep /AUL/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add AUL for line $list_dn[2] ");
        print FH "STEP: add AUL for line C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add AUL for line C $list_dn[2] - PASS\n";
    }
    
	$add_feature_lineC = 1;
	

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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	# Check line B ringing
	
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
	
	
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	# Check line D ringing
	
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line D
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between C and B

	 %input = (
                -list_port => [$list_line[2],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }
	
	 # D still monitor C & B successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[2], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B ");
        print FH "STEP: LEA D can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between C and B - PASS\n";
    }
	
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# remove MLH
	$ses_core->execCmd ("servord");
    unless ($mlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from MLH group");
            print FH "STEP: delete member $list_dn[1] from MLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from MLH group - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: out line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: out line $list_dn[0] - PASS\n";
        }

       
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASS\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASS\n";
        }
    }
	
	# remove AUL from line C 
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'AUL', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove AUL from line $list_dn[2]");
            print FH "STEP: Remove AUL from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove AUL from line $list_dn[2] - PASS\n";
        }
        
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_009");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_009";
    my $tcid = "ADQ1114_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $li_added = 0;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA2m Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	# Add DNH group: A is pilot, B is member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	# Add CPU to line A and C (A and C must have the same custgroup)
	
	$ses_core->execCmd ("servord");
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[2] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[2]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[2] - FAIL\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[2] - PASS\n";
    }
   
    $add_feature_lineA = 0;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CPU');
    unless ($cpu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CPU access code");
		print FH "STEP: get CPU access code is $cpu_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CPU access code is $cpu_acc - PASS\n";
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	
	# Offhook line E
	unless($ses_glcas->offhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line E $list_line[4]");
        print FH "STEP: offhook line E $list_line[4] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line E $list_line[4] - PASS\n";
    }
	
	#  E dials C , C rings and answer
	%input = (
                -line_port => $list_line[4],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
		print FH "STEP: E dials C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: E dials C $list_dn[2] - PASS\n";
    }
	
	# Check line C ringing
	
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASS\n";
    }
	
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	
	# A dials CPU access code
	sleep(1);
	my $dialed_num = "\*$cpu_acc";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
		print FH "STEP: A dials cpu_acc CHD - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials cpu_acc CHD - PASS\n";
    }
	# Check line D rings 
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Off hook line D
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line D $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	# Verify speech path between A and E

	 %input = (
                -list_port => [$list_line[0],$list_line[4]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and E");
        print FH "STEP: Check speech path between A and E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and E - PASS\n";
    }
	
	 # D still monitor A & E successfully
	 sleep(2);
    %input = (
                -list_port => [$list_line[0], $list_line[4]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and E ");
        print FH "STEP: LEA D can monitor the call between A and E - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and E - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
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
	
	# remove CPU from line A and C
    unless ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line A $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line A $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[2]");
            print FH "STEP: Remove CPU from line C $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line C $list_dn[2] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_010");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_010";
    my $tcid = "ADQ1114_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};


    my $wait_for_event_time = 30;
    my $add_feature_lineC = 1;
	my $li_added = 0;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 1;
    my $flag = 1;
	my $pcm_start = 0;
	my $calltrak_start = 0;
	my $tapi_start = 0;
	my (@list_file_name, @callTrakLogs, %info, $ID);
    
	# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

    
################## LOGIN ##############

    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }

    unless ($ses_core->loginCore(%core_account)) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n"; 
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil- PASS\n";
    }

    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => 1, - output_record_separator => "\n")){
		$logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
		print FH "STEP: Login Server 53 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 - PASS\n";
    }
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 - PASS\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..8]], -password => [@{$core_account_li{-password}}[0..8]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
    }
	
	# Initialize Calltrak session
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
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
		sleep(1);
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
	
	# Add DNH group: A is pilot, B is member; 

    unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: create group DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    

    unless(grep /DNH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
	# Add SURV and LEA to line ACT
	# Login to DNBDORDER
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;

	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord  ");
        print FH "STEP: Access to dnbdord - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord - PASS\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI  ");
        print FH "STEP: Enter password to LI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASS\n";
    }
	
	# Add SURV to line B and LEA to line D
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	$li_added = 1;
	
	
	# Add CXR for line C 
	
   unless ($ses_core->callFeature(-featureName => "CXR CTALL Y 12 STD", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line C $list_dn[2]");
		print FH "STEP: add CXR for line C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line C $list_dn[2] - PASS\n";
    }
	
	unless(grep /CXR/, $ses_core->execCmd("qdn $list_dn[2]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add CXR for line $list_dn[2] ");
        print FH "STEP: Verify add CXR for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify add CXR for line $list_dn[2] - PASS\n";
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
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 0;
	}
	 # Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[2]],
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
	}
	
	# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";			
		}
		$calltrak_start = 1;
	}
	
# Call flow
# start PCM trace

   if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
	
	
	# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line C $list_line[2]");
        print FH "STEP: offhook line C $list_line[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line C $list_line[2] - PASS\n";
    }
	
	#  C dials A , A rings and answer
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
		print FH "STEP: C dials A $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials A $list_dn[0] - PASS\n";
    }
	
	# Check line A ringing
	
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
	
	
	# Check line D rings 
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASS\n";
    }
	
	# Offhook line A
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line A $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
	# Off hook line D
	
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line D $list_line[3]");
        print FH "STEP: offhook line D $list_line[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line D $list_line[3] - PASS\n";
    }
	
	
	 # D still monitor A & C successfully
    %input = (
                -list_port => [$list_line[0], $list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and C ");
        print FH "STEP: LEA D can monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and C - PASS\n";
    }
	
	# C flashs 
	%input = (
                -line_port => $list_line[2], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash line $list_line[2]");
		print FH "STEP: C flashes again to make call to B - FAILED\n";
    } else {
		print FH "STEP: C flashes again to make call to B - PASSED\n";
		}
	
	# C dials line B
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
		 print FH "STEP: C dials line B $list_dn[1] - FAIL\n";
		$result = 0;
        goto CLEANUP;
        
    } else {
        print FH "STEP: C dials line B $list_dn[1] - PASS\n";
    }
	
	# Check line B ringing
	
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
	
	# Onhook line C
     unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line B $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
	
	sleep(2);
	# Offhook line B
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line B $list_line[1]");
        print FH "STEP: offhook line B $list_line[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line B $list_line[1] - PASS\n";
    }
	
	  # Verify A,B have speech path
	 %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
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
	
	 # D still monitor A & B successfully
    %input = (
                -list_port => [$list_line[0], $list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B ");
        print FH "STEP: LEA D can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA D can monitor the call between A and B - PASS\n";
    }
	
	
################################## Cleanup ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ##################################");

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
    if ($pcm_start){
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ntthuyhuong/PCM_hnphuc',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
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
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                # if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    # $exist2 = 0;
                # }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
        
    }
    
	# Stop CallTrak
   if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
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
	
	# remove CXR from line C
    unless ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[2]");
            print FH "STEP: Remove CXR from line C $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line C $list_dn[2] - PASS\n";
        }
       
    }
	
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);    

}

sub ADQ1114_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_011");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_011";
	my $tcid = "ADQ1114_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Add CCBS to line C
	unless ($ses_core->callFeature(-featureName => "CCBS 1 5", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CCBS for line C-$list_dn[2]");
		print FH "STEP: Add CCBS for line C($list_dn[2]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CCBS for line C($list_dn[2]) - PASSED\n";
    }

# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line A and LEA to line D   
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    $lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk ISUP is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..20]],
					-password => [@{$core_account{-password}}[10..20]],
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Get CCBSA Access Code
	my $ccbsa_code = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'CCBSA');
    unless ($ccbsa_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CCBSA access code for line $list_dn[2]");
		print FH "STEP: Get CCBSA access code for line C ($list_dn[2]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code CCBSA is: $ccbsa_code \n";
        print FH "STEP: Get CCBSA access code for line C($list_dn[2]) - PASSED\n";
    }
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# B off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B to make it busy - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B to make it busy - PASSED\n";
    }
	sleep(1);

# C calls A, C hear BUSY tone and flashs then
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['BUSY'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['none'],
                -send_receive => ['none','none'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, C hear BUSY tone and flashs then - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, C hear BUSY tone and flashs then - PASSED\n";
    }
	sleep (2);
	# Start detect hear confirmation tone
    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[2], -cas_timeout => 50000);
	# C dials CCBS access code
    $dialed_num = "\*$ccbsa_code";
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: C dials $dialed_num to active CCBS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $dialed_num to active CCBS - PASSED\n";
    }
	# Stop detect confirmation tone
    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[2], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[2]");
        print FH "STEP: C hears confirmation tone after activating CCBS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears confirmation tone after activating CCBS - PASSED\n";
    }
	sleep (1);
# C on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line C - PASSED\n";
    }
# A on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }
	sleep (7);
#  Detect C rings
	%input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line C does not ring");
        print FH "STEP: Check line C ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ringing - PASSED\n";
    }
# C off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C - PASSED\n";
    }
#  Detect A rings
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
        print FH "STEP: Check line A ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASSED\n";
    }
# A off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A - PASSED\n";
    }
	sleep (1);
# Check speech path between A and C
	%input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and C");
        print FH "STEP: Verify speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and C - PASSED\n";
    }
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_011 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	
	# Remove DNH from line A and B
	if ($feature_added) {
        # Remove CCBS from C
		unless ($ses_core->callFeature(-featureName => 'CCBS', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CCBS from line C($list_dn[2])");
            print FH "STEP: Remove CCBS from line C ($list_dn[2]) - FAILED\n";
			 $result = 0;
        } else {
            print FH "STEP: Remove CCBS from line C ($list_dn[2]) - PASSED\n";
        }
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH from A
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_012");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_012";
	my $tcid = "ADQ1114_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;
	

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################


# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
	# Add CFGD to line A
	unless ($ses_core->callFeature(-featureName => "CFGD Y Y 12 N", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFGD for line A-$list_dn[0]");
		print FH "STEP: Add CFGD for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CFGD for line A($list_dn[0]) - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line B and LEA to line D   
	my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk ISUP is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# C calls A but A doesn't answer
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['none'],
                -send_receive => ['none','none'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A but A doesn't answer - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A but A doesn't answer - PASSED\n";
    }
	sleep (12);
#  Detect B rings
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
        print FH "STEP: Check line B ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASSED\n";
    }
# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASSED\n";
    }

# Check speech path between B and C
	%input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between B and C");
        print FH "STEP: Verify speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between B and C - PASSED\n";
    }
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between B and C");
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_012 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
        # Remove CFGD from A
		unless ($ses_core->callFeature(-featureName => 'CFGD', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFGD from line A($list_dn[0])");
            print FH "STEP: Remove CFGD from line A ($list_dn[0]) - FAILED\n";
			 $result = 0;
        } else {
            print FH "STEP: Remove CFGD from line A ($list_dn[0]) - PASSED\n";
        }
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH from A
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_013");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_013";
	my $tcid = "ADQ1114_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;
	

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################


# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
	# Add CFB to line D
	unless ($ses_core->callFeature(-featureName => "CFB P", -dialNumber => $list_dn[3], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFB for line D-$list_dn[3]");
		print FH "STEP: Add CFB for line D($list_dn[3]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CFB for line D($list_dn[3]) - PASSED\n";
    }
    $feature_added = 1;
	
	 # Active CFB to forward to A
	unless ($ses_core->execCmd ("changecfx $list_len[3] CFB $list_dn[4] A")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot active CFB for line $list_dn[3]");
		print FH "STEP: Active CFB for line D($list_dn[3]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Active CFB for line D($list_dn[3]) - PASSED\n";
    }
	
	
################## LI provisioning ###########################
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line B and LEA to line D
	my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk ISUP is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num no RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# D off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D to make it busy - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D to make it busy - PASSED\n";
    }
	sleep(1);
	
	 
# C calls A, B answers
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, B answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, B answers - PASSED\n";
    }
	
# Detect E rings
	%input = (
                -line_port => $list_line[4],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line E does not ring");
        print FH "STEP: Check line E ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line E ringing - PASSED\n";
    }
	
# E off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[4], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[4]");
        print FH "STEP: Offhook line E - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line E - PASSED\n";
    }
	sleep (1);
# Line E (LEA) monitors the speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[4],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between B and C");
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_013 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
        # Remove CFB from D
		unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[3], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line D($list_dn[3])");
            print FH "STEP: Remove CFB from line D ($list_dn[3]) - FAILED\n";
			 $result = 0;
        } else {
            print FH "STEP: Remove CFB from line D ($list_dn[3]) - PASSED\n";
        }
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH from A
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[0] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_014");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_014";
	my $tcid = "ADQ1114_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;
	

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Out line A and B to create group MLH
	$ses_core->execCmd ("servord");
	for (my $i = 0; $i <= 1; $i++){
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[$i] $list_len[$i] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter the command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[$i]");
            print FH "STEP: OUT line $list_dn[$i] before adding into MLH group - FAILED\n";
        } else {
            print FH "STEP: OUT line $list_dn[$i] before adding into MLH group - PASSED\n";
        }
	}
	# Create MLH group: A is pilot, B is member
	$ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 3 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
    unless (grep /MLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: Create MLH for line $list_dn[0] and $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create MLH for line $list_dn[0] and $list_dn[1] - PASSED\n";
    }
	$feature_added = 1;
	# Add LOD to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] lod $list_dn[2] \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LOD for line $list_dn[0]");
		print FH "STEP:  Add LOD for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP:  Add LOD for line A($list_dn[0]) - PASSED\n";
    }
	
    $feature_added = 1;
################## LI provisioning ###########################
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line C and LEA to line D   
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    $lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk SST is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[2] $list_dn[2] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# B off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B to make it busy - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B to make it busy - PASSED\n";
    }
	sleep(1);
# E calls A, C answers
	%input = (
                -lineA => $list_line[4],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[4],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: E can't call A");
        print FH "STEP: E calls A, C answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: E calls A, C answers - PASSED\n";
    }

# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between E and C
    %input = (
                -list_port => [$list_line[4],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between E and C");
        print FH "STEP: Line D (LEA) monitors the speech path between E and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between E and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_014 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove MLH from line A and B
	if ($feature_added) {
        # Remove member B from MLH
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove member $list_dn[1] from MLH group");
            print FH "STEP: Remove member $list_dn[1] from MLH group - FAILED\n";
        } else {
            print FH "STEP: Remove member $list_dn[1] from MLH group - PASSED\n";
        }
		# Out line Pilot from MLH
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: Out line Pilot $list_dn[0] from MLH - FAILED\n";
        } else {
            print FH "STEP: Out line Pilot $list_dn[0] from MLH - PASSED\n";
        }

		# New line A and B for next tc
        
		for (my $i = 0; $i <= 1; $i++){
			if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[$i] $list_line_info[$i] $list_len[$i] dgt \$ y y")) {
				unless($ses_core->execCmd("abort")) {
					$logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
				}
				$logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[$i] ");
				print FH "STEP: NEW line $list_dn[$i] - FAILED\n";
			} else {
				print FH "STEP: NEW line $list_dn[$i] - PASSED\n";
			}
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_015");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_015";
	my $tcid = "ADQ1114_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Out line A and B to create group DLH
	$ses_core->execCmd ("servord");
	for (my $i = 0; $i <= 1; $i++){
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[$i] $list_len[$i] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter the command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[$i]");
            print FH "STEP: OUT line $list_dn[$i] before adding into DLH group - FAILED\n";
        } else {
            print FH "STEP: OUT line $list_dn[$i] before adding into DLH group - PASSED\n";
        }
	}
# Create the DLH group with A be pilot and B be member
    $ses_core->execCmd("est \$ DLH $list_dn[0] $list_line_info[0] $list_len[0] \+");
    if (grep /ERROR/, $ses_core->execCmd("$list_len[1] IBN \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot enter command 'est'");
		$ses_core->execCmd("abort");
		print FH "STEP: Create the DLH group with A be pilot and B be member - FAILED \n";
		$result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: Create the DLH group with A be pilot and B be member - PASSED \n";
	}	
   
    unless (grep /PILOT OF DLH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: Query to verify DLH created successfully - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query to verify DLH created successfully - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################
# Switch to DNBPRVCI mode
	
	unless(grep /DNBPRVCI/, $ses_core_li->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Switch to DNBPRVCI");
        print FH "STEP: Switch to DNBPRVCI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Switch to DNBPRVCI mode - PASSED\n";
    }
# Verify PTI ON or OFF
	unless(grep /PTI on TRUNK is Active/, $ses_core_li->execCmd("pti")) {
        $logger->error(__PACKAGE__ . ".$sub_name: PTI on TRUNK is Deactive ");
		unless (grep /PTI on TRUNK is now Activated/, $ses_core_li->execCmd("y")){
			print FH "STEP: Active PTI on TRUNK - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Active PTI on TRUNK - PASSED\n";
		}
        
    } else {
        print FH "PTI on TRUNK is now Activated\n";
		$ses_core_li->execCmd("n");
    }
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line A and LEA to line D   
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    $lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk PRI is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# C calls A, A answers
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, A answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, A answers - PASSED\n";
    }
	
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_015 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
         # Remove DLH group
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ dlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from DLH group");
            print FH "STEP: Remove member $list_dn[1] from DLH group - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove member $list_dn[1] from DLH group - PASSED\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: Out line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: Out line $list_dn[0] - PASSED\n";
        }

		# New line A and B for running TC
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASSED\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASSED\n";
        }
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_016");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_016";
	my $tcid = "ADQ1114_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################

# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
# Add POH to line A
	unless ($ses_core->callFeature(-featureName => "POH", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add POH for line A-$list_dn[0]");
		print FH "STEP: Add POH for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add POH for line A($list_dn[0]) - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################

# Switch to DNBPRVCI mode
	
	unless(grep /DNBPRVCI/, $ses_core_li->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Switch to DNBPRVCI");
        print FH "STEP: Switch to DNBPRVCI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Switch to DNBPRVCI mode - PASSED\n";
    }
# Verify PTI ON or OFF
	unless(grep /PTI on TRUNK is Active/, $ses_core_li->execCmd("pti")) {
        $logger->error(__PACKAGE__ . ".$sub_name: PTI on TRUNK is Deactive ");
		unless (grep /PTI on TRUNK is now Activated/, $ses_core_li->execCmd("y")){
			print FH "STEP: Active PTI on TRUNK - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Active PTI on TRUNK - PASSED\n";
		}
        
    } else {
        print FH "PTI on TRUNK is now Activated\n";
		$ses_core_li->execCmd("n");
    }
	
# Add SURV and LEA to line B and D
	# Login to DNBDORDER
	$ses_core_li->execCmd("quit");
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line B and LEA to line D   
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    $lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk PRI is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;

############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# C calls A, B rings and answers
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, B rings and answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, B rings and answers - PASSED\n";
    }

# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between B and C");
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_016 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_016 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
        
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH, POH from A
		unless ($ses_core->callFeature(-featureName => 'DNH POH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH, POH from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH, POH from line $list_dn[0] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_017";
	my $tcid = "ADQ1114_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn}, $db_line{$tc_line{$tcid}[4]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line}, $db_line{$tc_line{$tcid}[4]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region}, $db_line{$tc_line{$tcid}[4]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len}, $db_line{$tc_line{$tcid}[4]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info}, $db_line{$tc_line{$tcid}[4]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################

# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
# Add 3WC to line C
	unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[3], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line C-$list_dn[3]");
		print FH "STEP: Add 3WC for line C($list_dn[3]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line C($list_dn[3]) - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################

# Switch to DNBPRVCI mode
	
	unless(grep /DNBPRVCI/, $ses_core_li->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Switch to DNBPRVCI");
        print FH "STEP: Switch to DNBPRVCI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Switch to DNBPRVCI mode - PASSED\n";
    }
# Verify PTI ON or OFF
	unless(grep /PTI on TRUNK is Active/, $ses_core_li->execCmd("pti")) {
        $logger->error(__PACKAGE__ . ".$sub_name: PTI on TRUNK is Deactive ");
		unless (grep /PTI on TRUNK is now Activated/, $ses_core_li->execCmd("y")){
			print FH "STEP: Active PTI on TRUNK - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Active PTI on TRUNK - PASSED\n";
		}
        
    } else {
        print FH "PTI on TRUNK is now Activated\n";
		$ses_core_li->execCmd("n");
    }
	
# Add SURV and LEA to line B and D
	# Login to DNBDORDER
	$ses_core_li->execCmd("quit");
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line B and LEA to line D   
	my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk ISUP is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[1] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;

############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
		%input = (
					-username => [@{$core_account{-username}}[10..14]],
					-password => [@{$core_account{-password}}[10..14]],
					-testbed => $TESTBED{"c20:1:ce0"},
					-gwc_user => $gwc_user,
					-gwc_pwd => $gwc_pwd,
					-list_dn => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3], $list_dn[4]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# C calls E, E answers and C flashs then
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[4],
                -dialed_number => $list_dn[4],
                -regionA => $list_region[2],
                -regionB => $list_region[4],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call E");
        print FH "STEP: C calls E, E answers and C flashs then - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls E, E answers and C flashs then - PASSED\n";
    }
# C calls A, B rings and answers, C flashs again
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, B rings and answers, C flashs again - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, B rings and answers, C flashs again - PASSED\n";
    }
# Check speech path between B, C and E
	%input = (
                -list_port => [$list_line[1],$list_line[2], $list_line[4]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between B, C and E");
        print FH "STEP: Verify speech path between B, C and E - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between B, C and E - PASSED\n";
    }
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between B, C and E
    %input = (
                -list_port => [$list_line[1],$list_line[2], $list_line[4]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between B, C and E");
        print FH "STEP: Line D (LEA) monitors the speech path between B, C and E - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between B, C and E - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_017 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
        
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH, POH from A
		unless ($ses_core->callFeature(-featureName => 'DNH POH', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH, POH from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH, POH from line $list_dn[0] - PASSED\n";
		}
		# Remove 3WC from C
		unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[2]");
            print FH "STEP: Remove 3WC from line $list_dn[2] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[2] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_018");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_018";
	my $tcid = "ADQ1114_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################

# Create DNH group: A is pilot, B is member
	
	unless ($ses_core->addLineGroupDNH(-pilotDN => $list_dn[0], -addMem => 'Yes', -listMemDN => [$list_dn[1]])) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot create group DNH for line $list_dn[0] and $list_dn[1]");
		print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create group DNH with line $list_dn[0] is pilot and $list_dn[1] is member - PASSED\n";
    }

    unless(grep /PILOT OF DNH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot create DNH group for line $list_dn[0] and $list_dn[1]");
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query DNH group with line $list_dn[0] is pilot - PASSED\n";
    }
# Add CWT CWI to line A
	unless ($ses_core->callFeature(-featureName => "CWT CWI", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CWT CWI for line A-$list_dn[0]");
		print FH "STEP: Add CWT CWI for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CWT CWI for line A($list_dn[0]) - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################

# Switch to DNBPRVCI mode
	
	unless(grep /DNBPRVCI/, $ses_core_li->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Switch to DNBPRVCI");
        print FH "STEP: Switch to DNBPRVCI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Switch to DNBPRVCI mode - PASSED\n";
    }
# Verify PTI ON or OFF
	unless(grep /PTI on TRUNK is Active/, $ses_core_li->execCmd("pti")) {
        $logger->error(__PACKAGE__ . ".$sub_name: PTI on TRUNK is Deactive ");
		unless (grep /PTI on TRUNK is now Activated/, $ses_core_li->execCmd("y")){
			print FH "STEP: Active PTI on TRUNK - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Active PTI on TRUNK - PASSED\n";
		}
        
    } else {
        print FH "PTI on TRUNK is now Activated\n";
		$ses_core_li->execCmd("n");
    }
	
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	$ses_core_li->execCmd("quit");
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line A and LEA to line D   
	my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk PRI is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;

############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..9]], 
					-password => [@{$core_account{-password}}[6..9]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}

# C calls A, A answers
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS 123_456'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, A answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, A answers - PASSED\n";
    }
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - PASSED\n";
    }
# B calls A, A doesn't answer
	%input = (
                -lineA => $list_line[1],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[1],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['none'],
                -send_receive => ['none','none'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: B can't call A");
        print FH "STEP: B calls A, A doesn't answer - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: B calls A, A doesn't answer - PASSED\n";
    }
# Check line A hears CWT tone
	
	%input = (
                -line_port => $list_line[0],
                -callwaiting_tone_duration => 300,
                -cas_timeout => 20000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line A can't hear CWT tone");
        print FH "STEP: Check line A hears CWT tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A hears CWT tone - PASSED\n";
    }
# A flashs
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line A $list_line[0]");
		print FH "STEP: A flashs to answer B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flashs to answer B - PASSED\n";
    }
	sleep (1);
# Check speech path between A and B
	%input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and B");
        print FH "STEP: Verify speech path between A and B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and B - PASSED\n";
    }
# Line D (LEA) hears silent between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        print FH "STEP: Line D (LEA) hears silent between A and B - PASSED\n";
        
    } else {
	    $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) doesn't hear silent between A and B");
        print FH "STEP: Line D (LEA) hears silent between A and B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    }
# A flashs again
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line A $list_line[0]");
		print FH "STEP: A flashs again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flashs again - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between A and C again
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C again");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C again - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_018 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_018 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DNH from line A and B
	if ($feature_added) {
        
		# Remove DNH from B
		unless ($ses_core->callFeature(-featureName => 'DNH', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[1]");
            print FH "STEP: Remove DNH from line $list_dn[1] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH from line $list_dn[1] - PASSED\n";
		}
		# Remove DNH CWT CWI from A
		unless ($ses_core->callFeature(-featureName => 'DNH CWT CWI', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DNH from line $list_dn[0]");
            print FH "STEP: Remove DNH CWT CWI from line $list_dn[0] - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove DNH CWT CWI from line $list_dn[0] - PASSED\n";
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_019");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_019";
	my $tcid = "ADQ1114_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Out line A and B to create group DLH
	$ses_core->execCmd ("servord");
	for (my $i = 0; $i <= 1; $i++){
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[$i] $list_len[$i] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter the command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[$i]");
            print FH "STEP: OUT line $list_dn[$i] before adding into DLH group - FAILED\n";
        } else {
            print FH "STEP: OUT line $list_dn[$i] before adding into DLH group - PASSED\n";
        }
	}
# Create the DLH group with A be pilot and B be member
    $ses_core->execCmd("est \$ DLH $list_dn[0] $list_line_info[0] $list_len[0] \+");
    if (grep /ERROR/, $ses_core->execCmd("$list_len[1] IBN \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot enter command 'est'");
		$ses_core->execCmd("abort");
		print FH "STEP: Create the DLH group with A be pilot and B be member - FAILED \n";
		$result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: Create the DLH group with A be pilot and B be member - PASSED \n";
	}	
   
    unless (grep /PILOT OF DLH HUNT GROUP/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: Query to verify DLH created successfully - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Query to verify DLH created successfully - PASSED\n";
    }
# Add CHD to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] chd \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CHD for line $list_dn[0]");
		print FH "STEP:  Add CHD for line A($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP:  Add CHD for line A($list_dn[0]) - PASSED\n";
    }
    $feature_added = 1;
################## LI provisioning ###########################
# Switch to DNBPRVCI mode
	
	unless(grep /DNBPRVCI/, $ses_core_li->execCmd("DNBPRVCI")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Switch to DNBPRVCI");
        print FH "STEP: Switch to DNBPRVCI mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Switch to DNBPRVCI mode - PASSED\n";
    }
# Verify PTI ON or OFF
	unless(grep /PTI on TRUNK is Active/, $ses_core_li->execCmd("pti")) {
        $logger->error(__PACKAGE__ . ".$sub_name: PTI on TRUNK is Deactive ");
		unless (grep /PTI on TRUNK is now Activated/, $ses_core_li->execCmd("y")){
			print FH "STEP: Active PTI on TRUNK - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Active PTI on TRUNK - PASSED\n";
		}
        
    } else {
        print FH "PTI on TRUNK is now Activated\n";
		$ses_core_li->execCmd("n");
    }
# Add SURV and LEA to line A and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line A and LEA to line D   
	my $trunk_access_code = $db_trunk{'tw_isup'}{-acc};
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk PRI is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[0] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# Get CHD Access Code
	my $chd_code = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CHD');
    unless ($chd_code) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CHD access code for line $list_dn[0]");
		print FH "STEP: Get CHD access code for line A ($list_dn[0]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
		print FH "The access code CHD is: $chd_code \n";
        print FH "STEP: Get CHD access code for line A($list_dn[0]) - PASSED\n";
    }
# C calls A, A answers
	%input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['RINGBACK', 'RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE','DIGITS 123_456'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: C can't call A");
        print FH "STEP: C calls A, A answers - FAILED\n";
        $result = 0;
		goto CLEANUP;
    } else {
		print FH "STEP: C calls A, A answers - PASSED\n";
    }
	
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C - PASSED\n";
    }
# A flashs
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line A $list_line[0]");
		print FH "STEP: A flashs - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flashs - PASSED\n";
    }
	sleep (1);

# A dials CHD code
	# Start detect hear confirmation tone
    $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = "\*$chd_code";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A dials $dialed_num to active CHD - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $dialed_num to active CHD - PASSED\n";
    }

    unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
        $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
        print FH "STEP: A hears confirmation tone after activating CHD - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears confirmation tone after activating CHD - PASSED\n";
    }
	
# A hears dial tone again
	%input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timADQ1086ut => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone on line $list_dn[0]");
        print FH "STEP: A hears dial tone again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone again - PASSED\n";
    }
# A dials itself
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial itself to pickup call");
        print FH "STEP: A dials itself - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials itself - PASSED\n";
    }
# Detect B rings
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
        print FH "STEP: Check line B ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASSED\n";
    }
# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B to answer A - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B to answer A - PASSED\n";
    }
# Check speech path between B and A
	%input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and B");
        print FH "STEP: Verify speech path between A and B - FAILED\n";
        $result = 0;
       goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and B - PASSED\n";
    }
# # A calls itself, B answers
	# %input = (
                # -lineA => $list_line[0],
                # -lineB => $list_line[1],
                # -dialed_number => $list_dn[0],
                # -regionA => $list_region[0],
                # -regionB => $list_region[1],
                # -check_dial_tone => 'y',
                # -digit_on => 300,
                # -digit_off => 300,
                # -detect => ['DELAY 12','RINGBACK','RINGING'],
                # -ring_on => [0],
                # -ring_off => [0],
                # -on_off_hook => ['offB'],
                # -send_receive => ['TESTTONE','DIGITS 123_456'],
                # -flash => ''
                # );
    # unless ($ses_glcas->makeCall(%input)) {
        # $logger->error(__PACKAGE__ . " $tcid: A can't call itself");
        # print FH "STEP: A calls itself, B answers - FAILED\n";
        # $result = 0;
		# goto CLEANUP;
    # } else {
		# print FH "STEP: A calls itself, B answers - PASSED\n";
    # }
# # Verify C is still hearing ringback tone during A&B talking
	# %input = (
                # -line_port => $list_line[2],
                # -ring_count => 1,
                # -cas_timeout => 50000,
                # -wait_for_event_time => $wait_for_event_time,
                # );
    # unless ($ses_glcas->detectRingbackToneCAS(%input)){
        # $logger->error(__PACKAGE__ . ".$tcid: Cannot detect ringback tone line $list_dn[2]");
        # print FH "STEP: C is still hearing ringback tone during A&B talking - FAILED\n";
        # $result = 0;
        # #goto CLEANUP;
    # } else {
        # print FH "STEP: C is still hearing ringback tone during A&B talking - PASSED\n";
    # }
# Line D (LEA) hears silent between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        
        print FH "STEP: Line D (LEA) hears silent between A and B - PASSED\n";
        
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) doesn't hear silent between A and B");
		print FH "STEP: Line D (LEA) hears silent between A and B - FAILED\n";
		$result = 0;
        goto CLEANUP;
    }
# A flashs again
	%input = (
                -line_port => $list_line[0], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line A $list_line[0]");
		print FH "STEP: A flashs again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A flashs again - PASSED\n";
    }
	sleep (1);
# A dials CHD acctive code to turn back talking with C
	$dialed_num = "\*$chd_code";
    %input = (
                -line_port => $list_line[0],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: A dials $dialed_num to turn back talking with C - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: A dials $dialed_num to turn back talking with C - PASSED\n";
    }
	sleep (1);
# Check speech path between A and C
	%input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between A and C");
        print FH "STEP: Verify speech path between A and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between A and C - PASSED\n";
    }
# Line D (LEA) monitors the speech path between A and C again
    %input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between A and C");
        print FH "STEP: Line D (LEA) monitors the speech path between A and C again - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between A and C again - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_019 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove DLH from line A and B
	if ($feature_added) {
         # Remove DLH group
		$ses_core->execCmd("quit all");
		$ses_core->execCmd("servord");
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ dlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from DLH group");
            print FH "STEP: Remove member $list_dn[1] from DLH group - FAILED\n";
			$result = 0;
        } else {
            print FH "STEP: Remove member $list_dn[1] from DLH group - PASSED\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: Out line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: Out line $list_dn[0] - PASSED\n";
        }

		# New line A and B for running TC
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[0] $list_line_info[0] $list_len[0] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[0] ");
            print FH "STEP: NEW line $list_dn[0] - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[0] - PASSED\n";
        }
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[1] $list_line_info[1] $list_len[1] dgt \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter command 'abort' after NEW fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[1] ");
            print FH "STEP: NEW line $list_dn[1] - FAILED\n";
        } else {
            print FH "STEP: NEW line $list_dn[1] - PASSED\n";
        }
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

}

sub ADQ1114_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1114_020");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1114_020";
	my $tcid = "ADQ1114_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1114");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
	my $calltrak_start = 0;
    my $flag = 1;
	my $feature_added = 0;
	my $li_added = 0;
    my (@list_file_name, $dialed_num, $ID, %info);
	
    
# Which logs need to get
	 $log_type[0] = 1;
	 $log_type[1] = 1;
	 $log_type[2] = 0;
	 $log_type[3] = 0;

################################# LOGIN #######################################
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 Lab - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 Lab - PASSED\n";
    }
	
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASSED\n";
    }
	
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASSED\n";
    }
	
	unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiTraceSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for tapi trace- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for tapi trace- PASSED\n";
    }
	
	unless ($ses_calltrak = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CallTrakSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for calltrak - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for calltrak - PASSED\n";
    }
	unless ($ses_calltrak->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core to run calltrak function - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core to run calltrak function - PASSED\n";
    }
	
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..20]], -password => [@{$core_account{-password}}[2..20]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASSED\n";
    }
	# Initialize LI session
	unless ($ses_core_li = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLogLI")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for LI session - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 for LI session - PASSED\n";
    }
	
	# Just in case "liadmin" account is in use
    $ses_core->execCmd("forceout $li_user");
	
	unless ($ses_core_li->loginCore(-username => [@{$core_account_li{-username}}[0..6]], -password => [@{$core_account_li{-password}}[0..6]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core for LI");
		print FH "STEP: Login TMA20 LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 LI - PASSED\n";
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
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] Cannot reset");
            print FH "STEP: Reset line $list_dn[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Reset line $list_dn[$i] - PASSED\n";
        }
		sleep (1);
        unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[$i])) {
            $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[$i] is not IDL");
            print FH "STEP: Check line $list_dn[$i] status - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Check line $list_dn[$i] status - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
################## Add feature or datafill table ###########################
# Out line A and B to create group MLH
	$ses_core->execCmd ("servord");
	for (my $i = 0; $i <= 1; $i++){
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[$i] $list_len[$i] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter the command 'abort' after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot OUT line $list_dn[$i]");
            print FH "STEP: OUT line $list_dn[$i] before adding into MLH group - FAILED\n";
        } else {
            print FH "STEP: OUT line $list_dn[$i] before adding into MLH group - PASSED\n";
        }
	}
	# Create MLH group: A is pilot, B is member
	$ses_core->execCmd("est \$ MLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] ibn \$ DGT \$ 3 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
    unless (grep /MLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: Create MLH for line $list_dn[0] and $list_dn[1] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Create MLH for line $list_dn[0] and $list_dn[1] - PASSED\n";
    }
	$feature_added = 1;
	# Add WML to line C
	unless ($ses_core->callFeature(-featureName => "WML Y Y $list_dn[0] 12 N", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add WML for line C-$list_dn[2]");
		print FH "STEP: Add WML for line C($list_dn[2]) - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add WML for line C($list_dn[2]) - PASSED\n";
    }
	
    $feature_added = 1;
################## LI provisioning ###########################
# Add SURV and LEA to line B and D
	# Login to DNBDORDER
	unless(grep /\?/, $ses_core_li->execCmd("dnbdord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot access to dnbdord");
        print FH "STEP: Access to dnbdord mode - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access to dnbdord mode - PASSED\n";
    }
	 
	unless(grep /DNBDORDER/, $ses_core_li->execCmd("$pass_li")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot enter password to LI");
        print FH "STEP: Enter password to LI - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter password to LI - PASSED\n";
    }
	
	# Add SURV to line B and LEA to line D   
	
	my ($lea_num) = ($list_dn[3] =~ /\d{3}(\d+)/);
	my $trunk_access_code = $db_trunk{'sst'}{-acc};
    $lea_num = $trunk_access_code . $lea_num;
	print FH "LEA num via trunk SST is $lea_num\n";
	$ses_core_li->execCmd("add XUYEN YES FTPV4 047 135 041 070 021 hnt len $list_len[1] $list_dn[0] +");
	
	unless(grep /Please confirm/, $ses_core_li->execCmd("10 151515 yes $lea_num yes RESTP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D $list_dn[3]- FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D $list_dn[3] - PASSED\n";
    }
	unless(grep /Done/, @output = $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D ");
        print FH "STEP: Add LEA number to line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASSED\n";
    }

	foreach (@output) {
        if (/Monitor Order ID.*\s+(\d+)/ ) {
			$ID = $1;
        }
	}
	print FH "Monitor Order ID is: $ID\n";
	# Active SURV to line 
	unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Enter cmd 'surv act $ID'");
        print FH "STEP: Enter cmd 'surv act $ID' - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Enter cmd 'surv act $ID' - PASSED\n";
    }
	
	unless(grep /Done/, $ses_core_li->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Actived SURV - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Actived SURV - PASSED\n";
    }
	$li_added = 1;
############################################################################
# Initialize Call
    %input = (
                -cas_server => [@cas_server],
                -list_port => [@list_line],
                -tone_type => 0
             );
    unless($ses_glcas->initializeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot Initialize Call");
		print FH "STEP: Initialize Call - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Initialize Call - PASSED\n";
    }

    for (my $i = 0; $i <= $#list_line; $i++){
        unless ($ses_glcas->setRegionCAS(-line_port => $list_line[$i], -region_code => $list_region[$i], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot set region for line $list_line[$i]");
            print FH "STEP: Set region for line $list_line[$i] - FAILED\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASSED\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil
    if ($log_type[0]){
	   %input = (
					-username => [@{$core_account{-username}}[6..20]], 
					-password => [@{$core_account{-password}}[6..20]], 
					-logutilType => ['SWERR', 'TRAP', 'AMAB'],
				 );
		unless ($ses_logutil->startLogutil(%input)) {
			$logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
			print FH "STEP: Start logutil - FAILED\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: Start logutil - PASSED\n";
		}
		$logutil_start = 1;
	}
# Start tapi trace
    if ($log_type[2]){
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
	}
# Start Calltrak
	if ($log_type[3]){
		%input = (
					-traceType => ['msgtrace'],
					-trunkName => [],
					-dialedNumber => [$list_dn[0], $list_dn[1], $list_dn[2], $list_dn[3]],
				);
		
		unless ($ses_calltrak->SonusQA::SST::startCalltrak(%input)){
			$logger->error(__PACKAGE__ . " $tcid: Cannot start calltrak");
			print FH "STEP: Start calltrak - FAILED\n";
			$result = 0;
			#goto CLEANUP;
		} else {
			print FH "STEP: Start calltrak - PASSED\n";
			$calltrak_start = 1;
		}
	}
###################### Call flow ###########################
#Start PCM trace
    if ($log_type[1]){
		@list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
		unless(@list_file_name) {
			$logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
		}
		$pcm_start = 1;
	}
# A off-hooks to make it busy
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A to make it busy - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A to make it busy - PASSED\n";
    }
	sleep(1);
# Check A is CPB status
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
        print FH "STEP: Check A is CPB status - FAILED\n";
        $result = 0;
        goto CLEANUP;
	} else {
		print FH "STEP: Check A is CPB status - PASSED\n";
	}
# C off-hooks and wait 12s
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C and wait - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line C and wait - PASSED\n";
    }
	sleep (13);

# Detect B rings
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
        print FH "STEP: Check line B ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASSED\n";
    }
# B off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line B - PASSED\n";
    }
	sleep (1);
# Check speech path between B and C
	%input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['TESTTONE'], 
                -tone_duration => 2000,
                -cas_timADQ1086ut => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify speech path between B and C");
        print FH "STEP: Verify speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Verify speech path between B and C - PASSED\n";
    }
# Detect D rings
	%input = (
                -line_port => $list_line[3],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: Line D does not ring");
        print FH "STEP: Check line D ringing - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line D ringing - PASSED\n";
    }
# D off-hooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook line D - PASSED\n";
    }
	sleep (1);
# Line D (LEA) monitors the speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line D (LEA) can't monitor the speech path between B and C");
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Line D (LEA) monitors the speech path between B and C - PASSED\n";
    }
# Onhook all line
    for (my $j = 0; $j <= $#list_line; $j++){
        unless($ses_glcas->onhookCAS(-line_port => $list_line[$j], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[$j]");
			print FH "STEP: Onhook line $list_dn[$j] - FAILED\n";
			$result = 0;
            last;
        } else {
            print FH "STEP: Onhook line $list_dn[$j] - PASSED\n";
        }
	}

################################## Cleanup ADQ1114_020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup ADQ1114_020 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAILED\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASSED\n";
        }
    }
	# Get PCM trace
    if ($pcm_start){
		%input = (
				-remoteip => $cas_server[0],
				-remoteuser => $sftp_user,
				-remotepasswd => $sftp_pass,
				-localDir => '/home/ntthuyhuong/PCM_hnphuc/',
				-remoteFilePath => [@list_file_name]
				);
		if (@list_file_name) {
			unless(&SonusQA::Utils::sftpFromRemote(%input)) {
				$logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
				print FH "STEP: Get PCM trace - FAILED\n";
			} else {
				print FH "STEP: Get PCM trace - PASSED\n";
			}
		}
	}
    # Stop Logutil
    if ($logutil_start) {
        
		unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
        }
		
        @output = $ses_logutil->execCmd("open trap");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core");
            $result = 0;
            print FH "STEP: Check Trap - FAILED\n";
        } else {
            print FH "STEP: Check Trap - PASSED\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAILED\n";
        } else {
            print FH "STEP: Check SWERR - PASSED\n";
        }
    }
	# Stop tapi
    my $exist1 = 0;
    my $exist2 = 0;
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
                if (grep /cg\/dt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist1 = 1;
                }
                if (grep /srvtn\/rdt/, @{$tapiterm_out{$gwc_id}{$tn}}) {
                    $exist2 = 1;
                }
            }
        }
        if ($exist1) {
            print FH "STEP: Check the message cg\/dt on tapi log - PASSED\n";
        } else {
            print FH "STEP: Check the message cg\/dt on tapi log - FAILED\n";
            $result = 0;
        }
		# if ($exist2) {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - PASSED\n";
			
        # } else {
            # print FH "STEP: Check the message srvtn\/rdt on tapi log - FAILED\n";
            # $result = 0;
        # }
    }
	# Stop calltrak
	if ($calltrak_start){
		my @calltrak_out = $ses_calltrak->SonusQA::SST::stopCalltrak();
		unless (grep /Tracing: Stopped/, @calltrak_out) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot stop calltrak");
            print FH "STEP: Stop calltrak - FAILED\n";
            $result = 0;
        } else {
            print FH "STEP: Stop calltrak - PASSED\n";
        }
	}
	###################Remove features added######################	
	# Deactive LEA
	if ($li_added){ 
		unless(grep /Do You want to ACT/, $ses_core_li->execCmd("surv deact $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
			print FH "STEP: Enter cmd 'surv deact $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'surv deact $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
			print FH "STEP: Deactive SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Deactive SURV - PASSED\n";
		}
		# Del LEA
		unless(grep /Delete MON ORDER ID/, $ses_core_li->execCmd("del $ID")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Enter cmd 'del $ID' - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Enter cmd 'del $ID' - PASSED\n";
		}
		
		unless(grep /Done/, $ses_core_li->execCmd("y")) {
			$logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
			print FH "STEP: Delete SURV - FAILED\n";
			$result = 0;
		} else {
			print FH "STEP: Delete SURV - PASSED\n";
			}
	}
	# Remove MLH from line A and B
	if ($feature_added) {
        # Remove WML from C
		unless ($ses_core->callFeature(-featureName => 'WML', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove WML from line C($list_dn[2])");
            print FH "STEP: Remove WML from line C ($list_dn[2]) - FAILED\n";
			 $result = 0;
        } else {
            print FH "STEP: Remove WML from line C ($list_dn[2]) - PASSED\n";
        }
		# Remove member B from MLH
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ mlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove member $list_dn[1] from MLH group");
            print FH "STEP: Remove member $list_dn[1] from MLH group - FAILED\n";
        } else {
            print FH "STEP: Remove member $list_dn[1] from MLH group - PASSED\n";
        }
		# Out line Pilot from MLH
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[0] bldn y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot out line $list_dn[0]");
            print FH "STEP: Out line Pilot $list_dn[0] from MLH - FAILED\n";
        } else {
            print FH "STEP: Out line Pilot $list_dn[0] from MLH - PASSED\n";
        }

		# New line A and B for next tc
        
		for (my $i = 0; $i <= 1; $i++){
			if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("new \$ $list_dn[$i] $list_line_info[$i] $list_len[$i] dgt \$ y y")) {
				unless($ses_core->execCmd("abort")) {
					$logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after NEW fail");
				}
				$logger->error(__PACKAGE__ . ".$sub_name: Cannot NEW line $list_dn[$i] ");
				print FH "STEP: NEW line $list_dn[$i] - FAILED\n";
			} else {
				print FH "STEP: NEW line $list_dn[$i] - PASSED\n";
			}
		}
    }
	
	################################################################
    close(FH);
    &ADQ1114_cleanup();
    &ADQ1114_checkResult($tcid, $result);

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