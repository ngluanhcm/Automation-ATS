#**************************************************************************************************#
#FEATURE                : <ADQ766> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Hang Doan>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ766::ADQ766; 

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
our (%input, @output, $tcid, $ses_core);
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
our $LCM_GTWY = "15";
our $RLCM_GTWY = "5";

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

sub ADQ766_cleanup {
    my $subname = "ADQ766_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    if (defined $ses_core) {
        $ses_core->DESTROY();
        undef $ses_core;
    }
    return 1;
}
sub ADQ766_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ766_checkResult";
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
##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                    "ADQ766_01", # LCM_GTWYMode - Verify POST GTWY command work correctly
                    "ADQ766_02", # LCM_GTWYMode - Verify LISTSET command work correctly
                    "ADQ766_03", # LCM_GTWYMode - Verify DISPL INSV command work correctly
                    "ADQ766_04", # LCM_GTWYMode - Verify QueryPM command work correctly
                    "ADQ766_05", # LCM_GTWYMode - Verify QueryPM G6EX command work correctly
                    "ADQ766_06", # LCM_GTWYMode - Verify QueryPM CONFIG command work correctly
                    "ADQ766_07", # LCM_GTWYMode - Verify QueryPM CARD command work correctly
                    "ADQ766_08", # LCM_GTWYMode - Verify DISPL ManB command work correctly
                    "ADQ766_09", # LCM_GTWYMode - Verify DISPL OffL command work correctly
                    "ADQ766_10", # LCM_GTWYMode - Verify NEXT command work correctly
                    "ADQ766_11", # LCM_GTWYMode - Verify TEST command for a Pside link
                    "ADQ766_12", # LCM_GTWYMode - Translate Cside and verify links and GWC number
                    "ADQ766_13", # LCM_GTWYMode - Translate Pside and verify G6 EX port state
                    "ADQ766_14", # LCM_GTWYMode - Translate MSG C and verify ouput
                    "ADQ766_15", # LCM_GTWYMode - Translate MSG P and verify ouput
                    "ADQ766_16", # LCM_GTWYMode - Manual offline a GW when GW is InSv
                    "ADQ766_17", # LCM_GTWYMode - Manual busy a GW then return and verify its state
                    "ADQ766_18", # LCM_GTWYMode - Manual busy Pside links then return and verify their state
                    "ADQ766_19", # LCM_GTWYMode - Manual offline a GW then return and verify its state
                    "ADQ766_20", # RLCM_GTWYMode - Verify POST GTWY command work correctly
                    "ADQ766_21", # RLCM_GTWYMode - Verify LISTSET command work correctly
                    "ADQ766_22", # RLCM_GTWYMode - Verify DISPL INSV command work correctly
                    "ADQ766_23", # RLCM_GTWYMode - Verify DISPL ManB command work correctly
                    "ADQ766_24", # RLCM_GTWYMode - Verify DISPL OffL command work correctly
                    "ADQ766_25", # RLCM_GTWYMode - Verify TEST command for a Pside link
                    "ADQ766_26", # RLCM_GTWYMode - Translate Cside and verify links and GWC number
                    "ADQ766_27", # RLCM_GTWYMode - Translate Pside and verify DS1 port state
                    "ADQ766_28", # RLCM_GTWYMode - Translate MSG C and verify ouput
                    "ADQ766_29", # RLCM_GTWYMode - Translate MSG P and verify ouput
                    "ADQ766_30", # RLCM_GTWYMode - Manual offline a GW when GW is InSv
                    "ADQ766_31", # RLCM_GTWYMode - Manual busy a GW then return and verify its state
                    "ADQ766_32", # RLCM_GTWYMode - Manual busy Pside links then return and verify their state
                    "ADQ766_33", # RLCM_GTWYMode - Manual offline a GW then return and verify its state
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
# +------------------------------------------------------------------------------+
# |   ADQ766                                                                     |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Hang Doan ##########################

sub ADQ766_01 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_01");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_01";
    $tcid = "ADQ766_01";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd post");
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }

    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_02 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_02");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_02";
    $tcid = "ADQ766_02";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY DLP $RLCM_GTWY");
    unless (grep /GTWY DLP    $RLCM_GTWY\, DLP   $LCM_GTWY\./, @cmd_result= $ses_core->execCmd("Listset")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'listset' and verify output");
        print FH "STEP: Execution cmd 'listset' and verify output - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'listset' and verify output - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_03 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_03");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_03";
    $tcid = "ADQ766_03";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: ############################$1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("Disp state insv")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state insv'");
        print FH "STEP: Execution cmd 'Disp state insv' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state insv' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: AAAAAA############".Dumper(\@cmd_result));
    my $j =1;
    $i = 0;
    unless(grep /InSv GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output InSv GTWY mapping number GTWY InSv on Banner");
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /InSv GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output InSv GTWY mapping number GTWY InSv on Banner");
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - PASS\n";
        }
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_04 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_04");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_04";
    $tcid = "ADQ766_04";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @cmd_result1, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("QueryPM")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM'");
        print FH "STEP: Execution cmd 'QueryPM'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'QueryPM'- PASS\n";
    }
    foreach(@cmd_result){
        if($_ =~ /IP Address:\s(\d+).(\d+).(\d+).(\d+)/){
            my $ip = $1." ".$2." ".$3."  ".$4;
            push @value, $ip;
        }
        if($_ =~ /H248 port\s(\d+)/){
            push @value, $1;
        }
        if($_ =~ /SCTP port\s(\d+)/){
            push @value, $1;
        }
        if($_ =~ /GTWY Profile:\s+(\w+)/){
            push @value, $1;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: AAAAAA############".Dumper(\@value));
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result1 = $ses_core->execCmd("pos DLP $LCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $LCM_GTWY'");
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- PASS\n";
    }
    if(grep /$value[0]/, @cmd_result1){
        if(grep /$value[1]/, @cmd_result1){
            if(grep /$value[2]/, @cmd_result1){
                if(grep /$value[3]/, @cmd_result1){
                    print FH "STEP: Verify information  on the mapci - PASS\n";
                } else {
                    $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information  on the mapci ");
                    print FH "STEP: Verify information  on the mapci - FAIL\n";
                    return 0;
                }
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information  on the mapci ");
                print FH "STEP: Verify information  on the mapci - FAIL\n";
                return 0;
            }
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information  on the mapci ");
            print FH "STEP: Verify information  on the mapci - FAIL\n";
            return 0;
        }
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information  on the mapci ");
        print FH "STEP: Verify information  on the mapci - FAIL\n";
        return 0;
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_05 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_05");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_05";
    $tcid = "ADQ766_05";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("QueryPM g6ex")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM g6ex'");
        print FH "STEP: Execution cmd 'QueryPM g6ex'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'QueryPM g6ex'- PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: Result:".Dumper(\@cmd_result));
    if (grep /No response from G6/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify output");
        $logger->info(__PACKAGE__ . " $tcid: Result:".Dumper(\@cmd_result));
        print FH "STEP: Verify output- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify output- PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_06 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_06");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_06";
    $tcid = "ADQ766_06";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @cmd_result1, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("QueryPM CONFIG")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM CONFIG'");
        print FH "STEP: Execution cmd 'QueryPM CONFIG'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'QueryPM CONFIG'- PASS\n";
        $logger->error(__PACKAGE__ . " $tcid: Result:".Dumper(\@cmd_result));
    }
    my $result_cmd = join ("",@cmd_result);
    if ($result_cmd =~ /STATUS/ && $result_cmd =~ /ERROR/) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Mismatch information between G6 & CORE");
        print FH "STEP: Mismatch information between G6 & CORE- FAIL\n";
        return 0;
    }
    foreach(@cmd_result){
        if($_ =~ /IP Address\s+(\d+).(\d+).(\d+).(\d+)/){
            my $ip = $1." ".$2." ".$3."  ".$4;
            push @value, $ip;
        }
        if($_ =~ /H248 Port\s+(\d+)/){
            push @value, $1;
        }
        if($_ =~ /SCTP Port\s+(\d+)/){
            push @value, $1;
        }
    }
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result1 = $ses_core->execCmd("pos DLP $LCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $LCM_GTWY'");
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- PASS\n";
    }
    if(grep /$value[0]/, @cmd_result1){
        if(grep /$value[1]/, @cmd_result1){
            if(grep /$value[2]/, @cmd_result1){
                print FH "STEP: Verify information on the mapci - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information on the mapci ");
                print FH "STEP: Verify information on the mapci - FAIL\n";
                $result = 0;
            }
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information on the mapci ");
            print FH "STEP: Verify information on the mapci - FAIL\n";
            $result = 0;
        }
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify information on the mapci ");
        print FH "STEP: Verify information on the mapci - FAIL\n";
        $result = 0;
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_07 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_07");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_07";
    $tcid = "ADQ766_07";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $i = 1;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("QueryPM card")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM card'");
        print FH "STEP: Execution cmd 'QueryPM card'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'QueryPM card'- PASS\n";
        $logger->error(__PACKAGE__ . " $tcid: Result:".Dumper(\@cmd_result));
        foreach(@cmd_result){
            if($_ =~ /\sLOCK/){
                $logger->error(__PACKAGE__ . " $tcid: ##############Verify information: $_");
                print FH "STEP: Verify information: $_- PASS\n";
                $i =0;
            }
        }
        if ($i == 1) {
            $logger->error(__PACKAGE__ . " $tcid: ##############Verify information: all states are unlock");
            print FH "STEP: Verify information: all states are unlock- PASS\n";
        } 
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_08 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_08");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_08";
    $tcid = "ADQ766_08";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: ############################$1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $i = 1;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("Disp state ManB")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state ManB'");
        print FH "STEP: Execution cmd 'Disp state ManB'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state ManB'- PASS\n";
    }
    my $j =1;
    $i = 0;
    unless(grep /ManB GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output ManB GTWY mapping number GTWY ManB on Banner");
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /ManB GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output ManB GTWY mapping number GTWY ManB on Banner");
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_09 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_09");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_09";
    $tcid = "ADQ766_09";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: #################Number OffL: $1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $i = 1;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("Disp state OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state OffL'");
        print FH "STEP: Execution cmd 'Disp state OffL'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state OffL'- PASS\n";
    }
    my $j =1;
    $i = 0;
    unless(grep /OffL GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output OffL GTWY mapping number GTWY OffL on Banner");
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /OffL GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output OffL GTWY mapping number GTWY OffL on Banner");
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_10 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_10");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_10";
    $tcid = "ADQ766_10";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /GTWY DLP  $RLCM_GTWY/ && $_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state of DLP $RLCM_GTWY on the mapci");
        print FH "STEP: Verify GW's state of DLP $RLCM_GTWY on the mapci => Output: $status  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state of DLP $RLCM_GTWY on the mapci => Output: $status  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'next'");
        print FH "STEP: Execution cmd 'next' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'next' - PASS\n";
    }
    $i = 0;
    foreach(@cmd_result){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################$_");
        if($_ =~ /GTWY DLP  $LCM_GTWY/ && $_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state of DLP $LCM_GTWY on the mapci");
        print FH "STEP: Verify GW's state of DLP $LCM_GTWY on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state of DLP $LCM_GTWY on the mapci => Output: $status - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_11 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_11");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_11";
    $tcid = "ADQ766_11";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL p")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL p'");
        print FH "STEP: Execution cmd 'TRNSL p' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL p' - PASS\n";
    }
    foreach(@cmd_result){
        if($_ =~ /Link\s+(\d+).*OK/){
            push @value, $1;
        }
    }
    $i =1;
    $logger->error(__PACKAGE__ . " $tcid: ###########################List link:".Dumper(\@value));
    foreach(@value){
        unless (grep /Tst Passed|Tst Failed/, @cmd_result= $ses_core->execCmd("Tst link $_")) {
            $logger->error(__PACKAGE__ . " $tcid: TC failed when result of command TST link not contains 'Tst Passed' or 'Tst Failed'");
            $i = 0;
            last;
        }
        if (grep /ERROR/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: TC failed when result of command TST link contains 'ERROR'");
            $i = 0;
            last;
        }
    }
    unless($i == 1){
        $logger->error(__PACKAGE__ . " $tcid: Failed to Tst command works fine");
        print FH "STEP: Tst command works fine - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Tst command works fine - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_12 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_12");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_12";
    $tcid = "ADQ766_12";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $gwc, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL c")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL c'");
        print FH "STEP: Execution cmd 'TRNSL c' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL c' - PASS\n";
    }
    my $number = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            $gwc = $2;
            $number = $number + 1;
        }
    }
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("pos DLP $LCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $LCM_GTWY' in table GATWYINV");
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY' in table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY' in table GATWYINV- PASS\n";
    }
    unless (grep /GWC\s+$gwc/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GWC is correct with table GATWYINV");
        print FH "STEP: Verify GWC is correct with table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GWC is correct with table GATWYINV- PASS\n";
    }
    $ses_core->execCmd("TABLE LCMINV");
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'list all' in table LCMINV");
        print FH "STEP: Execution cmd 'list all' in table LCMINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'list all' in table LCMINV- PASS\n";
    }
    $i = 0;
    my $j = 0;
    for (my $x = 0; $x <= $#cmd_result; $x++){
        if($cmd_result[$x] =~ /DLP\s+$LCM_GTWY/){
            do{
                if($cmd_result[$x + 2] =~ /LCM\s+\(\s?\d+\)/){
                    $cmd_result[$x + 2] =~ s/\(\s?\d+\)//;
                    $i = $i+ 1;
                } else {
                    $j = 1;
                }
            } while ($j == 0);
            last;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ##########################Count of C-side link: $number");
    $logger->error(__PACKAGE__ . " $tcid: ##########################Count in table GATWYINV: $i");
    unless ($number == $i) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify number of Cside links is correct with datafill in table LCMINV");
        print FH "STEP: Verify number of Cside links is correct with datafill in table LCMINV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of Cside links is correct with datafill in table LCMINV - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_13 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_13");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_13";
    $tcid = "ADQ766_13";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL c")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL c'");
        print FH "STEP: Execution cmd 'TRNSL c' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL c' - PASS\n";
    }
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+)/){
            push @value, $1;
        }
    }
    $logger->info(__PACKAGE__ . " $tcid: ################List C-side link:".Dumper(\@value));
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL p")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL p'");
        print FH "STEP: Execution cmd 'TRNSL p' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL p' - PASS\n";
    }
    $logger->info(__PACKAGE__ . " $tcid: ################:".Dumper(\@cmd_result));
    $i = 1;
    foreach(@value){
        unless(grep /$_/, @cmd_result){
            $i = 0;
            last;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify number of P-side link is correct with C-side link");
        print FH "STEP: Verify number of P-side link is correct with C-side link - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of P-side link is correct with C-side link - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_14 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_14");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_14";
    $tcid = "ADQ766_14";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $gwc, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG C")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG C'");
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - PASS\n";
    }
    my $j = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            $j = $j + 1;
            $gwc = $2;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ###########GWC: $gwc");
    unless ($j == 2) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify the output: make sure number of msg link is 2");
        print FH "STEP: Verify the output: make sure number of msg link is 2- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify the output: make sure number of msg link is 2- PASS\n";
    }
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("pos DLP $LCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $LCM_GTWY'");
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $LCM_GTWY'- PASS\n";
    }
    unless (grep /GWC\s+$gwc/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GWC is correct with table GATWYINV");
        print FH "STEP: Verify GWC is correct with table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GWC is correct with table GATWYINV- PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_15 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_15");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_15";
    $tcid = "ADQ766_15";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG C")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG C'");
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - PASS\n";
    }
    my $j = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            push @value, $1;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ###########Link: ".Dumper(\@value));
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG P")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG P'");
        print FH "STEP: Execution cmd 'TRNSL  MSG P' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG P' - PASS\n";
    }
    $i = 1;
    foreach(@value){
        unless(grep /$_/, @cmd_result){
            $i = 0;
            last;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify number of MSG P-side link is correct with MSG C-side link");
        print FH "STEP: Verify number of MSG P-side link is correct with MSG C-side link - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of MSG P-side link is correct with MSG C-side link - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_16 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_16");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_16";
    $tcid = "ADQ766_16";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'OffL'");
        print FH "STEP: Execution cmd 'OffL' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'OffL' - PASS\n";
    }
    unless (grep /Request Invalid/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify show error");
        print FH "STEP: Verify show error- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify show error- PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
    $i = 0;
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
    unless (grep /GTWY DLP  $LCM_GTWY    InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is InSv");
        print FH "STEP: Verify GW's state is InSv- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is InSv- PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_17 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_17");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_17";
    $tcid = "ADQ766_17";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY FORCE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
        print FH "STEP: Verify GW is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    unless (grep /already ManB|Bsy Request Invalid/, $ses_core->execCmd("bsy GTWY NOWAIT")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
        print FH "STEP: Verify GW is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    @cmd_result = $ses_core->execCmd("bsy GTWY ALL");
    if(grep /Please confirm/,@cmd_result){
        unless (grep /already ManB|Bsy Request Invalid/, $ses_core->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
            print FH "STEP: Verify GW is busy successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW is busy successfully - PASS\n";
        }
    } else{
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    unless (grep /Rts Passed/, $ses_core->execCmd("rts GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Execution cmd 'rts GTWY'");
        print FH "STEP: Execution cmd 'rts GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'rts GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
    unless (grep /GTWY DLP\s+$LCM_GTWY\s+InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify GW is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is returned successfully to Insv state - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_18 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_18");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_18";
    $tcid = "ADQ766_18";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status, $ses_core1);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    my $value;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Bsy Passed/, @cmd_result = $ses_core->execCmd("bsy link 0")) {
        if(grep /Request Invalid/, @cmd_result){
            foreach(@cmd_result){
                if($_ =~ /(LCM.*\d+)\s+Unit/){
                    $value = $1;
                    last;
                }
            }
            $ses_core->execCmd("quit all");
            $ses_core->{conn}->print("");
            $ses_core->{conn}->print("mapci;mtc;pm;post $value");
            sleep(5);
            if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("")) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post $value'");
                print FH "STEP: Execution cmd 'post $value' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Execution cmd 'post $value' - PASS\n";
            }
            foreach(@cmd_result){
                $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]//g;
            }
            $logger->debug(__PACKAGE__ . ".$tcid: ############################".Dumper(\@cmd_result));
            my $value1 = $value.'ISTb';
            my $value2 = $value.'InSv';
            unless(grep /$value1|$value2/, @cmd_result){
                $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is InSv or ISTb");
                print FH "STEP: Verify GW's state is InSv or ISTb - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Verify GW's state is InSv or ISTb - PASS\n";
            }
        }
    } else {
        unless (grep /Link  0.*Status:MBsy/, $ses_core->execCmd("TRNSL p")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify G6 EX port is busy successfully");
            print FH "STEP: Verify G6 EX port is busy successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify G6 EX port is busy successfully - PASS\n";
        }
        $ses_core->execCmd("quit all");
        @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
        unless (grep /GTWY DLP\s+$LCM_GTWY\s+ISTb/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is ISTb");
            print FH "STEP: Verify GW's state is ISTb - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW's state is ISTb - PASS\n";
        }
        $ses_core->execCmd("quit all");
        $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
        unless (grep /Rts\s+Passed/, $ses_core->execCmd("rts link 0")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'rts link 0'");
            print FH "STEP: Execution cmd 'rts link 0' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Execution cmd 'rts link 0' - PASS\n";
        }
        unless (grep /Link  0.*Status:OK/, $ses_core->execCmd("TRNSL p")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify G6 EX port is returned successfully");
            print FH "STEP: Verify G6 EX port is returned successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify G6 EX port is returned successfully - PASS\n";
        }
        $ses_core->execCmd("quit all");
        @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
        unless (grep /GTWY DLP\s+$LCM_GTWY\s+InSv/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is InSv");
            print FH "STEP: Verify GW's state is InSv - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW's state is InSv - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_19 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_19");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_19";
    $tcid = "ADQ766_19";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$LCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'bsy GTWY'");
        print FH "STEP: Execution cmd 'bsy GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'bsy GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
    unless (grep /GTWY DLP\s+$LCM_GTWY\s+ManB/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is ManB");
        print FH "STEP: Verify GW's state is ManB - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is ManB - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Offl Passed/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'OffL'");
        print FH "STEP: Execution cmd 'OffL' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'OffL' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
    $i = 0;
    foreach(@cmd_result){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        if($_ =~ /GTWY DLP\s+$LCM_GTWY\s+OffL/ && $_ =~ /Links_OOS:0/ && $_ =~ /SCTP:I/ && $_ =~ /H248:I/){
            $i = 1;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is Offl, SCTP and H248 state is I");
        print FH "STEP: Verify GW's state is Offl, SCTP and H248 state is I - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is Offl, SCTP and H248 state is I - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'bsy GTWY'");
        print FH "STEP: Execution cmd 'bsy GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'bsy GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
    unless (grep /GTWY DLP\s+$LCM_GTWY\s+ManB/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is ManB");
        print FH "STEP: Verify GW's state is ManB - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is ManB - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY");
    unless (grep /Rts Passed/, $ses_core->execCmd("rts GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'rts GTWY'");
        print FH "STEP: Execution cmd 'rts GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'rts GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
    unless (grep /GTWY DLP\s+$LCM_GTWY\s+InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify GW is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is returned successfully to Insv state - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

######################RLCM########################################################
sub ADQ766_20 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_20");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_20";
    $tcid = "ADQ766_20";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd post");
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }

    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_21 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_21");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_21";
    $tcid = "ADQ766_21";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $LCM_GTWY DLP $RLCM_GTWY");
    unless (grep /GTWY DLP    $RLCM_GTWY\, DLP   $LCM_GTWY\./, @cmd_result= $ses_core->execCmd("Listset")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'listset' and verify output");
        print FH "STEP: Execution cmd 'listset' and verify output - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'listset' and verify output - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_22 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_22");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_22";
    $tcid = "ADQ766_22";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: ############################$1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
            last;
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("Disp state insv")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state insv'");
        print FH "STEP: Execution cmd 'Disp state insv' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state insv' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: AAAAAA############".Dumper(\@cmd_result));
    my $j =1;
    $i = 0;
    unless(grep /InSv GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output InSv GTWY mapping number GTWY InSv on Banner");
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /InSv GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output InSv GTWY mapping number GTWY InSv on Banner");
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output InSv GTWY mapping number GTWY InSv on Banner - PASS\n";
        }
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_23 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_23");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_23";
    $tcid = "ADQ766_23";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: ############################$1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("Disp state ManB")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state ManB'");
        print FH "STEP: Execution cmd 'Disp state ManB'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state ManB'- PASS\n";
    }
    my $j =1;
    $i = 0;
    unless(grep /ManB GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output ManB GTWY mapping number GTWY ManB on Banner");
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /ManB GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output ManB GTWY mapping number GTWY ManB on Banner");
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output ManB GTWY mapping number GTWY ManB on Banner - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_24 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_24");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_24";
    $tcid = "ADQ766_24";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);
    my $value;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if(/GTWY\s+\d+\s+\d+\s+(\d+)/){
            $logger->debug(__PACKAGE__ . ".$tcid: #################Number OffL: $1");
            $value = $1;
        }
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $i = 1;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("Disp state OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Disp state OffL'");
        print FH "STEP: Execution cmd 'Disp state OffL'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'Disp state OffL'- PASS\n";
    }
    my $j =1;
    $i = 0;
    unless(grep /OffL GTWY/, @cmd_result) {
        if ($value == 0){
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - PASS\n";
        } else{
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output OffL GTWY mapping number GTWY OffL on Banner");
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - FAIL\n";
            $result = 0;
        }
    } else {
        foreach(@cmd_result){
            if($_ =~ /OffL GTWY/){
                for ($i = 0; $i<$value; $i++){
                    unless(grep /DLP/, $_){
                        $j = 0;
                        last;
                    } else { 
                        $_ =~ s/DLP//;
                        $logger->error(__PACKAGE__ . " $tcid: AAAAAA############$_");
                    }
                }
                if ($_ =~ /DLP/){
                    $j = 0;
                }
                last;
            }
        }
        unless ($j == 1) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify the output OffL GTWY mapping number GTWY OffL on Banner");
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify the output OffL GTWY mapping number GTWY OffL on Banner - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_25 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_25");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_25";
    $tcid = "ADQ766_25";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL p")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL p'");
        print FH "STEP: Execution cmd 'TRNSL p' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL p' - PASS\n";
    }
    foreach(@cmd_result){
        if($_ =~ /Link\s+(\d+).*OK/){
            push @value, $1;
        }
    }
    $i =1;
    $logger->error(__PACKAGE__ . " $tcid: ###########################List link:".Dumper(\@value));
    foreach(@value){
        unless (grep /Tst Passed|Tst Failed/, @cmd_result= $ses_core->execCmd("Tst link $_")) {
            $logger->error(__PACKAGE__ . " $tcid: TC failed when result of command TST link not contains 'Tst Passed' or 'Tst Failed'");
            $i = 0;
            last;
        }
        if (grep /ERROR/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: TC failed when result of command TST link contains 'ERROR'");
            $i = 0;
            last;
        }
    }
    unless($i == 1){
        $logger->error(__PACKAGE__ . " $tcid: Failed to Tst command works fine");
        print FH "STEP: Tst command works fine - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Tst command works fine - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_26 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_26");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_26";
    $tcid = "ADQ766_26";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $gwc, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL c")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL c'");
        print FH "STEP: Execution cmd 'TRNSL c' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL c' - PASS\n";
    }
    my $number = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            $gwc = $2;
            $number = $number + 1;
        }
    }
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("pos DLP $RLCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $RLCM_GTWY' in table GATWYINV");
        print FH "STEP: Execution cmd 'pos DLP $RLCM_GTWY' in table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $RLCM_GTWY' in table GATWYINV- PASS\n";
    }
    unless (grep /GWC\s+$gwc/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GWC is correct with table GATWYINV");
        print FH "STEP: Verify GWC is correct with table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GWC is correct with table GATWYINV- PASS\n";
    }
    $ses_core->execCmd("TABLE LCMINV");
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'list all' in table LCMINV");
        print FH "STEP: Execution cmd 'list all' in table LCMINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'list all' in table LCMINV- PASS\n";
    }
    $i = 0;
    my $j = 0;
    for (my $x = 0; $x <= $#cmd_result; $x++){
        if($cmd_result[$x] =~ /DLP\s+$RLCM_GTWY/){
            do{
                if($cmd_result[$x + 2] =~ /LCM\s+\(\s?\d+\)/){
                    $cmd_result[$x + 2] =~ s/\(\s?\d+\)//;
                    $i = $i+ 1;
                } else {
                    $j = 1;
                }
            } while ($j == 0);
            last;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ##########################Count of C-side link: $number");
    $logger->error(__PACKAGE__ . " $tcid: ##########################Count in table GATWYINV: $i");
    unless ($number == $i) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify number of Cside links is correct with datafill in table LCMINV");
        print FH "STEP: Verify number of Cside links is correct with datafill in table LCMINV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of Cside links is correct with datafill in table LCMINV - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_27 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_27");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_27";
    $tcid = "ADQ766_27";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL c")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL c'");
        print FH "STEP: Execution cmd 'TRNSL c' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL c' - PASS\n";
    }
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+)/){
            push @value, $1;
        }
    }
    $logger->info(__PACKAGE__ . " $tcid: ################List C-side link:".Dumper(\@value));
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL p")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL p'");
        print FH "STEP: Execution cmd 'TRNSL p' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL p' - PASS\n";
    }
    $logger->info(__PACKAGE__ . " $tcid: ################:".Dumper(\@cmd_result));
    $i = 1;
    foreach(@value){
        unless(grep /$_/, @cmd_result){
            $i = 0;
            last;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify number of P-side link is correct with C-side link");
        print FH "STEP: Verify number of P-side link is correct with C-side link - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of P-side link is correct with C-side link - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_28 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_28");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_28";
    $tcid = "ADQ766_28";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $gwc, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG C")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG C'");
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - PASS\n";
    }
    my $j = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            $j = $j + 1;
            $gwc = $2;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ###########GWC: $gwc");
    unless ($j == 2) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify the output: make sure number of msg link is 2");
        print FH "STEP: Verify the output: make sure number of msg link is 2- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify the output: make sure number of msg link is 2- PASS\n";
    }
    $ses_core->execCmd("quit all");
    if (grep /INCONSISTENT DATA| ERROR/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: ERROR occurs when accessing TABLE GATWYINV");
        print FH "STEP: Accessing TABLE GATWYINV  - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Accessing TABLE GATWYINV  - PASS\n";
    }
    if (grep /Undefined command|error/, @cmd_result = $ses_core->execCmd("pos DLP $RLCM_GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'pos DLP $RLCM_GTWY'");
        print FH "STEP: Execution cmd 'pos DLP $RLCM_GTWY'- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'pos DLP $RLCM_GTWY'- PASS\n";
    }
    unless (grep /GWC\s+$gwc/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GWC is correct with table GATWYINV");
        print FH "STEP: Verify GWC is correct with table GATWYINV- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GWC is correct with table GATWYINV- PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_29 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_29");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_29";
    $tcid = "ADQ766_29";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, @value, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG C")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG C'");
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG C' - PASS\n";
    }
    my $j = 0;
    foreach(@cmd_result){
        if($_ =~ /(Link\s+\d+).*GWC\s+(\d+)/){
            push @value, $1;
        }
    }
    $logger->error(__PACKAGE__ . " $tcid: ###########Link: ".Dumper(\@value));
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("TRNSL  MSG P")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'TRNSL  MSG P'");
        print FH "STEP: Execution cmd 'TRNSL  MSG P' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'TRNSL  MSG P' - PASS\n";
    }
    $i = 1;
    foreach(@value){
        unless(grep /$_/, @cmd_result){
            $i = 0;
            last;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Verify number of MSG P-side link is correct with MSG C-side link");
        print FH "STEP: Verify number of MSG P-side link is correct with MSG C-side link - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify number of MSG P-side link is correct with MSG C-side link - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_30 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_30");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_30";
    $tcid = "ADQ766_30";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'OffL'");
        print FH "STEP: Execution cmd 'OffL' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'OffL' - PASS\n";
    }
    unless (grep /Request Invalid/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify show error");
        print FH "STEP: Verify show error- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify show error- PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
    $i = 0;
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
    unless (grep /GTWY DLP\s+$RLCM_GTWY\s+InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is InSv");
        print FH "STEP: Verify GW's state is InSv- FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is InSv- PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_31 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_31");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_31";
    $tcid = "ADQ766_31";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY FORCE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
        print FH "STEP: Verify GW is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    unless (grep /already ManB|Bsy Request Invalid/, $ses_core->execCmd("bsy GTWY NOWAIT")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
        print FH "STEP: Verify GW is busy successfully - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    @cmd_result = $ses_core->execCmd("bsy GTWY ALL");
    if(grep /Please confirm/,@cmd_result){
        unless (grep /already ManB|Bsy Request Invalid/, $ses_core->execCmd("y")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is busy successfully");
            print FH "STEP: Verify GW is busy successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW is busy successfully - PASS\n";
        }
    } else{
        print FH "STEP: Verify GW is busy successfully - PASS\n";
    }
    unless (grep /Rts Passed/, $ses_core->execCmd("rts GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Execution cmd 'rts GTWY'");
        print FH "STEP: Execution cmd 'rts GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'rts GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $LCM_GTWY");
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
    unless (grep /GTWY DLP\s+$LCM_GTWY\s+InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify GW is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is returned successfully to Insv state - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_32 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_32");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_32";
    $tcid = "ADQ766_32";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    my $value;
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Bsy Passed/, @cmd_result = $ses_core->execCmd("bsy link 0")) {
        if(grep /Request Invalid/, @cmd_result){
            foreach(@cmd_result){
                if($_ =~ /(LCM.*\d+)\s+Unit/){
                    $value = $1;
                    last;
                }
            }
            $ses_core->execCmd("quit all");
            $ses_core->{conn}->print("");
            $ses_core->{conn}->print("mapci;mtc;pm;post $value");
            sleep(5);
            if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("")) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post $value'");
                print FH "STEP: Execution cmd 'post $value' - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Execution cmd 'post $value' - PASS\n";
            }
            foreach(@cmd_result){
                $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
                $_ =~ s/[^a-zA-Z0-9, _, :]//g;
            }
            $logger->debug(__PACKAGE__ . ".$tcid: ############################".Dumper(\@cmd_result));
            my $value1 = $value.'ISTb';
            my $value2 = $value.'InSv';
            unless(grep /$value1|$value2/, @cmd_result){
                $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is InSv or ISTb");
                print FH "STEP: Verify GW's state is InSv or ISTb - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Verify GW's state is InSv or ISTb - PASS\n";
            }
        }
    } else {
        unless (grep /Link  0.*Status:MBsy/, $ses_core->execCmd("TRNSL p")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify G6 EX port is busy successfully");
            print FH "STEP: Verify G6 EX port is busy successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify G6 EX port is busy successfully - PASS\n";
        }
        $ses_core->execCmd("quit all");
        @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
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
        unless (grep /GTWY DLP\s+$RLCM_GTWY\s+ISTb/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is ISTb");
            print FH "STEP: Verify GW's state is ISTb - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW's state is ISTb - PASS\n";
        }
        $ses_core->execCmd("quit all");
        $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
        unless (grep /Rts\s+Passed/, $ses_core->execCmd("rts link 0")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'rts link 0'");
            print FH "STEP: Execution cmd 'rts link 0' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Execution cmd 'rts link 0' - PASS\n";
        }
        unless (grep /Link  0.*Status:OK/, $ses_core->execCmd("TRNSL p")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to Verify G6 EX port is returned successfully");
            print FH "STEP: Verify G6 EX port is returned successfully - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify G6 EX port is returned successfully - PASS\n";
        }
        $ses_core->execCmd("quit all");
        @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
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
        unless (grep /GTWY DLP\s+$RLCM_GTWY\s+InSv/, @cmd_result) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to GW's state is InSv");
            print FH "STEP: Verify GW's state is InSv - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Verify GW's state is InSv - PASS\n";
        }
    }
    
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
}

sub ADQ766_33 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ766_33");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ766_33";
    $tcid = "ADQ766_33";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my (@cmd_result, $status);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ766");
    
################## LOGIN ##############
    
    unless($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_coreSession")){
		$logger->error(__PACKAGE__ . ": Could not create C20 object for tms_alias => TESTBED{ c20:1:ce0 }");
        print FH "STEP: Login TMA15 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA15 - PASS\n";        
	}
    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA15 Core");
        print FH "STEP: Login TMA15 core - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Login TMA15 core - PASS\n";
    }
############### Test Specific configuration & Test Tool Script Execution #################
    $ses_core->{conn}->prompt('/\>$/');
    if (grep /Undefined command|error/, @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY")) {
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
        if($_ =~ /Links_OOS:0/ && $_ =~ /SCTP:A/ && $_ =~ /H248:A/){
            $i = 1;
        } elsif ($_ =~ /Possible in ESA/){
            $i = 0;
            $logger->error(__PACKAGE__ . " $tcid: Gateway is possible in ESA");
        }
        if($_ =~ /(GTWY\s+DLP\s+$RLCM_GTWY.*H248:\w)/){
            $status = $1;
            $logger->error(__PACKAGE__ . " $tcid: #############################Status: $status");
        }
        
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state on the mapci");
        print FH "STEP: Verify GW's state on the mapci => Output: $status - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state on the mapci => Output: $status - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'bsy GTWY'");
        print FH "STEP: Execution cmd 'bsy GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'bsy GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
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
    unless (grep /GTWY DLP\s+$RLCM_GTWY\s+ManB/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is ManB");
        print FH "STEP: Verify GW's state is ManB - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is ManB - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Offl Passed/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'OffL'");
        print FH "STEP: Execution cmd 'OffL' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'OffL' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
    $i = 0;
    foreach(@cmd_result){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        if($_ =~ /GTWY DLP\s+$RLCM_GTWY\s+OffL/ && $_ =~ /Links_OOS:0/ && $_ =~ /SCTP:I/ && $_ =~ /H248:I/){
            $i = 1;
        }
    }
    unless ($i == 1) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is Offl, SCTP and H248 state is I");
        print FH "STEP: Verify GW's state is Offl, SCTP and H248 state is I - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is Offl, SCTP and H248 state is I - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Bsy Passed/, $ses_core->execCmd("bsy GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'bsy GTWY'");
        print FH "STEP: Execution cmd 'bsy GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'bsy GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
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
    unless (grep /GTWY DLP\s+$RLCM_GTWY\s+ManB/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW's state is ManB");
        print FH "STEP: Verify GW's state is ManB - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW's state is ManB - PASS\n";
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GTWY DLP $RLCM_GTWY");
    unless (grep /Rts Passed/, $ses_core->execCmd("rts GTWY")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'rts GTWY'");
        print FH "STEP: Execution cmd 'rts GTWY' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'rts GTWY' - PASS\n";
    }
    $ses_core->execCmd("quit all");
    @cmd_result= $ses_core->execCmd("mapci;mtc;pm;post GTWY DLP $RLCM_GTWY");
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
    unless (grep /GTWY DLP\s+$RLCM_GTWY\s+InSv/, @cmd_result) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to verify GW is returned successfully to Insv state");
        print FH "STEP: Verify GW is returned successfully to Insv state - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Verify GW is returned successfully to Insv state - PASS\n";
    }
    close(FH);
    &ADQ766_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ766_checkResult($tcid, $result);
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