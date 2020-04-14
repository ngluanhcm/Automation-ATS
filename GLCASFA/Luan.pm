#**************************************************************************************************#
#FEATURE                : <TRAINING> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Tai Nguyen Huu>
#cd /home/ylethingoc/ats_repos/lib/perl/QATEST/C20_EO/Luan/GLCASFA/
#/usr/bin/runtest.sh `pwd` 
#perl -cw Luan.pm
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::Luan::GLCASFA::Luan; 

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
our $wait_for_event_time = 30;

my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};
our ($root_pass) = $alias_hashref->{LOGIN}->{1}->{ROOTPASSWD};

# Line Info
our %db_line = (
                'gr303_1' => {
                            -line => 48,
                            -dn => 2124414010,
                            -region => 'US',
                            -len => 'AZTK   04 4 00 01',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'gr303_2' => {
                            -line => 47,
                            -dn => 2124414011,
                            -region => 'US',
                            -len => 'AZTK   04 4 00 02',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'gr303_3' => {
                            -line => 46,
                            -dn => 2124414012,
                            -region => 'US',
                            -len => 'AZTK   04 4 00 03',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                'gr303_4' => {
                            -line => 45,
                            -dn => 2124414013,
                            -region => 'US',
                            -len => 'AZTK   04 4 00 04',
                            -info => 'IBN AUTO_GRP 0 0 NILLATA 0',
                            },
                );

our %tc_line = (
                'TC1' => ['gr303_1','gr303_2','gr303_3'],
                'TC2' => ['gr303_1','gr303_2','gr303_3'],
);

#################### Trunk info ###########################
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
                                -acc => 750,
                                -region => 'US',
                                -clli => 'T15G6OC3C7IBNT2W',
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

sub Luan_cleanup {
    my $subname = "Luan_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_glcas, $ses_logutil, $ses_tapi
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
                    "TC1", #  
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

sub TC1 {
    $logger->debug(__PACKAGE__ . " Inside test case TC1");

    ########################### Variables Declaration #############################
    $tcid = "TC1";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/Luan");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineA = 0;
    my $add_feature_lineB = 0;
    my $ncos_config = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @NCOS, $FEATXLA, @IBNXLA, $cfu_acc );
    
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

    # Get FEATXLA
    unless (grep /TABLE:.*NCOS/, $ses_core->execCmd("table NCOS")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table NCOS' ");
    }
    unless (grep /AUTO_GRP/, @NCOS = $ses_core->execCmd("pos AUTO_GRP 0")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'pos AUTO_GRP 0' ");
    }
    for (@NCOS){
		if ($_ =~ /AUTO_GRP.*AUTOXLA\s(\w+).*/) {
            print FH "STEP: FEATXLA is $1 - Pass\n";
            $FEATXLA = $1;
        }
    }
    # table IBNXLA
    $ses_core->{conn}->prompt('/BOTTOM/');
    unless (grep /BOTTOM/, @IBNXLA = $ses_core->execCmd("table IBNXLA; format pack;list all;")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table IBNXLA' ");
    }
    $ses_core->{conn}->prompt($ses_core->{DEFAULTPROMPT});
    foreach (@IBNXLA){
		if ($_ =~ /($FEATXLA\s+47 N N CFWP)/) {
            print FH "STEP: CFWP is 47 - Pass\n";
            last;
        }else{
            unless (grep /ENTER/, $ses_core->execCmd("rep $FEATXLA 47 FEAT N N CFWP")) {
                 $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'rep $FEATXLA 47 FEAT N N CFWP' ");
            }
            unless (grep /REPLACED/, $ses_core->execCmd("y")) {
                 $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'y' ");
            }
            print FH "STEP: rep CFWP is 47 - Pass\n";
            $cfu_acc = '47';
            last;
        }
	
    }		
    # Add CFU to line B
=head
    unless ($ses_core->callFeature(-featureName => 'CFU N', -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[1]");
		print FH "STEP: add CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[1] - PASS\n";
    }
=cut

    $ses_core->execCmd("servord");
    @output = $ses_core->execCmd("ado \$ $list_dn[1] cfu n \$ y y");
    if (grep /NOT AN EXISTING OPTION|ALREADY EXISTS|INCONSISTENT DATA/, @output) {
        unless($ses_core->execCmd("N")) {
            $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'N' to reject ");
        }
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'abort' ");
    }

    $add_feature_lineB = 1;

    # Get CFWP code in table IBNXLA
=head
    my $cfu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'CFWP');
    unless ($cfu_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFU access code for line $list_dn[1]");
		print FH "STEP: get CFU access code for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get CFU access code for line $list_dn[1] - PASS\n";
    }

    ######
    $ses_core->{conn}->prompt('/BOTTOM/');
    unless (grep /BOTTOM/, @IBNXLA = $ses_core->execCmd("table IBNXLA; format pack;list all;")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'table IBNXLA' ");
    }
    $ses_core->{conn}->prompt($ses_core->{DEFAULTPROMPT});
    foreach (@IBNXLA){
		if ($_ =~ /IBNFXLA\s+(\d+)\sFEAT\sN\sN\sCFWP/) {
            print FH "STEP: get CFWP is $1 - Pass\n";
            $cfu_acc = $1;
            last;
        }else{
            print FH "STEP: get CFWP is $1 - faile\n";
            $result = 0;
            goto CLEANUP;
        }
	
    }		
=cut
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
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

    # Activate CFU to line C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    $dialed_num = '*' . $cfu_acc . $list_dn[2] . '#';
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
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
    }
    unless (grep /CFU.*A/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot activate CFU for line $list_dn[1]");
        print FH "STEP: activate CFU for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: activate CFU for line $list_dn[1] - PASS\n";
    }

    # Make call A to B, C ring and check speech path
        #my ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
        #$dialed_num = $trunk_access_code . $dialed_num;
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and call is forwarded to C ");
        print FH "STEP: A calls B and call is forwarded to C  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and call is forwarded to C  - PASS\n";
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
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }
    # remove CFU from line B
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'CFU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFU from line $list_dn[1]");
            print FH "STEP: Remove CFU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CFU from line $list_dn[1] - PASS\n";
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