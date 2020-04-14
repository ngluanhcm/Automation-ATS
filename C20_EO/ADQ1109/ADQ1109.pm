#**************************************************************************************************#
#FEATURE                : <GPP> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <Yen Le>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::C20_EO::ADQ1109;

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
our ($ses_core, $ses_core1, $ses_glcas, $ses_logutil, $ses_tapi, $ses_dnbd, $ses_g604);
our (%input, @output, @cmd_result, $tcid,@list_file_name);
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

# For Tapi
our $audio_gwc = 15;
our $audio_gwc_ip = '10.250.24.40';
our $tapilog_dir = '/home/ylethingoc/Tapitrace/';
#our $detect = 'RINGBACK'; #Change into 'RINGBACK' if ringback is ok to check

# For LI 
# For LI 
our $li_core_user = 'tiennn';
our $li_core_pass = 'tiennn';
our $dnbd_pass = 'cuong1';
our $li_group_id = 'xuyen';

# For GWC
my $alias_hashref = SonusQA::Utils::resolve_alias($TESTBED{ "c20:1:ce0"});
our ($gwc_user) = $alias_hashref->{LOGIN}->{1}->{USERID};
our ($gwc_pwd) = $alias_hashref->{LOGIN}->{1}->{PASSWD};
our ($root_pass) = $alias_hashref->{LOGIN}->{1}->{ROOTPASSWD};

#################### Line info ###########################
our %db_line = (                
                'gpp_4' => {
                            -line => 10,
                            -dn => 4005007603,
                            -region => 'IL',
                            -len => 'GPPV   00 0 00 03',
                            -info => 'IBN AUTO_GRP 0 0',
                            },
                'gpp_3' => {
                            -line => 11,
                            -dn => 4005007604,
                            -region => 'IL',
                            -len => 'GPPV   00 0 00 04',
                            -info => 'IBN AUTO_GRP 0 0',
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
				
################# NOTE: Sort callp, then g6 cli to run well TCs ##################
our %tc_line = (
                'ADQ1109_000' => ['gpp_1','gpp_2','gpp_3'],
                'ADQ1109_001' => ['gpp_1','gpp_2','gpp_3'],
                'ADQ1109_002' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
                'ADQ1109_003' => ['gpp_1','gpp_2','gpp_3'],
                'ADQ1109_004' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
                'ADQ1109_005' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
                'ADQ1109_006' => ['gpp_1','gpp_2'],
                'ADQ1109_007' => ['gpp_1','gpp_2'],
                'ADQ1109_008' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_009' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_010' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_011' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_012' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_013' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_014' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_015' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_016' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_017' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_018' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_019' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_020' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_021' => ['gpp_1','gpp_2'],
				'ADQ1109_022' => ['gpp_1','gpp_2','gpp_3'],
				'ADQ1109_023' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_024' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_025' => ['gpp_1','gpp_2','gpp_3','gpp_4'],
				'ADQ1109_026' => ['gpp_1','gpp_2'],
				'ADQ1109_027' => ['gpp_1','gpp_2'],
				'ADQ1109_028' => ['gpp_1','gpp_2'],
				'ADQ1109_029' => ['gpp_1','gpp_2'],
				'ADQ1109_030' => ['gpp_1','gpp_2'], 
				'ADQ1109_031' => ['gpp_1','gpp_2'],
				'ADQ1109_032' => ['gpp_3','gpp_4'],
                'ADQ1109_036' => ['gpp_1','gpp_2'],
                'ADQ1109_037' => ['gpp_1','gpp_2'],
                'ADQ1109_038' => ['gpp_1','gpp_2'],
                'ADQ1109_039' => ['gpp_1','gpp_2','gpp_3'],
                'ADQ1109_040' => ['gpp_1','gpp_2','gpp_3'],
                'ADQ1109_041' => ['gpp_1','gpp_2'],
                'ADQ1109_042' => ['gpp_1','gpp_2'],
                'ADQ1109_047' => ['gpp_1'],
                'ADQ1109_048' => ['gpp_1'],
                'ADQ1109_049' => ['gpp_1','gpp_2'],
                'ADQ1109_050' => ['gpp_1','gpp_2'],              
            );

#################### Trunk info ###########################
our %db_trunk = (
                'g6_isup' =>{
                                -acc => 105,
                                -region => 'IL',
                                -clli => 'T20G6E1C7ETSI2W',
                            },
                'g6_pri' => {
                                -acc => 104,
                                -region => 'IL',
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

sub ADQ1109_cleanup {
    my $subname = "ADQ1109_cleanup";
    $logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
    my @end_ses = (
                    $ses_core, $ses_core1, $ses_glcas, $ses_logutil, $ses_tapi, $ses_dnbd, $ses_g604, 
                    );
    foreach (@end_ses) {
        if (defined $_) {
            $_->DESTROY();
            undef $_;
        }
    }
    return 1;
}

sub ADQ1109_checkResult {
    my ($tcid, $result) = (@_);
    my $subname = "ADQ1109_checkResult";
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

sub g604 {
    unless ($ses_core = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:2:ce0"}, -sessionLog => $tcid."_G604SessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create G604 object for tms_alias => $TESTBED{'c20:2:ce0'}" );
        print FH "STEP: Login G604 - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login G604 - PASS\n";
    }
    return $ses_core;
}

sub glcas {
    unless($ses_glcas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "glcas:1:ce0"}, -sessionlog => $tcid."_GLCASLog", - output_record_separator => "\n")){
        $logger->error(__PACKAGE__ . " $tcid: Could not create GLCAS object for tms_alias => TESTBED{ ‘glcas:1:ce0’ }");
        print FH "STEP: Login Server 53 for GLCAS - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login Server 53 for GLCAS - PASS\n";
    }
    return $ses_glcas;
}

sub logutil {
    sleep (2);
    unless ($ses_logutil = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_LogutilSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Logutil - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Logutil - PASS\n";
    }
    return $ses_logutil;
}

sub tapi {
    sleep (4);
    unless ($ses_tapi = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_TapiSessionLog")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 for Tapi trace - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 for Tapi trace - PASS\n";
    }
    return $ses_tapi;
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
      
                    # "ADQ1109_000", # Debug TC to detect dial, ringback tone.
                    # "ADQ1109_001", # V5.2_BasicCallP - Verify 3WC via ISUP trunk 
                    # "ADQ1109_002", # V5.2_BasicCallP - Verify MLH feature inter-opts CFU works fine with G6 GPP line                             
                    # "ADQ1109_003", # V5.2_BasicCallP - Verify SCL inter-opts with blind 3WC correctly                          
                    # "ADQ1109_004", # V5.2_BasicCallP - Verify CXR to SIMRING group - Blind transfer
                    # "ADQ1109_005", # V5.2_BasicCallP - Verify CWT Party is on hold and receives incoming call               
                    # "ADQ1109_006", # V5.2_BasicCallP - Verify SCL Speed call long list work correctly via g6_isup trunk 
                    # "ADQ1109_007", # V5.2_BasicCallP - Verify SCS Speed call short list work correctly via g6_pri trunk 
                    # "ADQ1109_008", # V5.2_BasicCallP - Verify MADN work correctly with SCA feature, pilot join 3WC	
                    # "ADQ1109_009", # V5.2_BasicCallP - Verify DLH inter-opts with LOD features via ISUP trunk
					# "ADQ1109_010", # V5.2_BasicCallP - Verify CFB Forwarded the call to G6 GPP(DNH) interopt PRI trunk
					# "ADQ1109_011", # V5.2_BasicCallP - CFD forward to CPU group, query member CPU by command QGRP
					# "ADQ1109_012", # V5.2_BasicCallP - CXR blind transfer to hunt group (MLH)
					# "ADQ1109_013", # V5.2_BasicCallP - Verify DRING feature assigned to G6 GPP line works fine
					# "ADQ1109_014", # V5.2_BasicCallP - MADN_The members of MADN join bridge from forwarded the call
					# "ADQ1109_015", # V5.2_BasicCallP - MADN MCA - Mem1 forward call to Mem2 use CXR
					# "ADQ1109_016", # V5.2_BasicCallP - DLH_LOR_The call is routed to a specified route all G6 GPP hunt group lines are busy
					# "ADQ1109_017", # V5.2_BasicCallP - Verify DNH feature works fine with G6 GPP line 
					# "ADQ1109_018", # V5.2_BasicCallP - G6 GPP line call to GPP line and transfer to CPU has G6 GPP member
					# "ADQ1109_019", # V5.2_BasicCallP - MADN_Verify secondary DN can join the MADN bridge
					# "ADQ1109_020", # V5.2_BasicCallP - DNH_The Secondary DN calls to G6 GPP hunt group 
					# "ADQ1109_021", # V5.2_BasicCallP - SDN_Verifiy SDN_RING 4 on G6 GPP line
					# "ADQ1109_022", # V5.2_BasicCallP - LNR - Verify LNR feature- LI involved 
					# "ADQ1109_023", # V5.2_BasicCallP - DNBD G6 GPP ACB calls to GPP line busy - LI involved 
					# "ADQ1109_024", # V5.2_BasicCallP - DNBD V5.2 line CXR over line call to G6 GPP
					# "ADQ1109_025", # V5.2_BasicCallP - CFDVT_Forward the call after 30s ringing without answer
					# "ADQ1109_026", # V5.2_BasicCallP - Verify the call when turn off DISABLE_DP_RECEPTION_ON_DGT with DGT Line
					# "ADQ1109_027", # V5.2_BasicCallP - Centrex line - Verify only 4 digits (extension dialing number) displayed on intra-group centrex call
					# "ADQ1109_028", # V5.2_BasicCallP - Centrex line - Verify only 5 digits (extension dialing number) displayed on intra-group centrex call
					# "ADQ1109_029", # V5.2_BasicCallP - Centrex line - Verify only 6 digits (extension dialing number) displayed on intra-group centrex call
					# "ADQ1109_030", # G6 - DS512 card rebooted in order and check line recovery
					"ADQ1109_031", # G6 - DS512 card - multiple switchover actions
					"ADQ1109_032", # VCA -  Do VCA REX test during callp
					"ADQ1109_033", # G6 - DP Suppression - Verify alarm raise when using "set" command lock-unlock ES1CAS IDT
					"ADQ1109_034", # Core - ABI mode - QueryABI-Tst  Plane
					"ADQ1109_035", # LTCINV - datafill difference version processor card (SX05 change to  MX77 )
                    "ADQ1109_036", # G6 - DS512 card switchovered during callp
                    "ADQ1109_037", # G6 - DS512 port switchovered during callp
                    "ADQ1109_038", # G6 - Verify GPP line recover when DS512 card lock/unlock IG during callp
                    "ADQ1109_039", # GWC - Warm Swact during during POTS active call
                    # "ADQ1109_040", # GWC - Cold Swact during during POTS active call (not run)
                    # "ADQ1109_041", # Core - Warm Swact during POTS active call (not run)
                    # "ADQ1109_042", # Core - Cold Swact during POTS active call (not run)
                    "ADQ1109_043", # LTCINV - Delete a subtendting ABI GPP in table LTCINV without removing in table GPPTRNSL
                    "ADQ1109_044", # LTCINV - Delete a subtendting ABI GPP while the pside are still existing in table LTCPSINV
                    "ADQ1109_045", # V5 mode - Verify PROTSW - V5 protection switch command
                    "ADQ1109_046", # ABI mode - Busy - return Plane 0 & 1
                    "ADQ1109_047", # LTP mode - busy- frls and return GPP POTS lines
                    "ADQ1109_048", # LTP mode - Verify SHOWERQ status
                    "ADQ1109_049", # Verify manually RExTst then warm swact ABI GWC does not affect Callp and services via that ABI GWC service-units
                    "ADQ1109_050", # GWC - Do GWC REX ABTK during callp
                    # "ADQ1109_051", # GATWYINV - Provisioning ABI GPP with same IP and different H248 ports
                    # "ADQ1109_052", # GATWYINV - Modify IP of an existing ABI GPP while subtending PM state is OFFL
                    # "ADQ1109_053", # GATWYINV - Delete a GPP entry while it is still associated with an entry in table LTCINV
                    # "ADQ1109_054", # LTCINV - Provisioning full data G6 GPP POTS line
                    # "ADQ1109_055", # GPPTRNSL - Delete tuble in table GPPTRNSL when V5 interface is ACT
                    # "ADQ1109_056", # Provisioning - Full data & wrong data (prov ID)
                    # "ADQ1109_057", # Provisioning - GPP V5.2 POTS & BRI lines
                    # "ADQ1109_058", # Provisioning -  BRI ETSI version on C20 ATCA & C20 MA-RMS platform
                    # "ADQ1109_059", # Swap DNs-LTID of ISDN BRI line
                    # "ADQ1109_060", # Provisioning V5.2 from 1 to 16 links
                    # "ADQ1109_061", # BOUNDARY testing for V5.2 LE interface ID, Variant
                    # "ADQ1109_062", # GPP mode - QueryPm GPP
                    # "ADQ1109_063", # GPP mode - Bsy RTS Inactive unit
                    # "ADQ1109_064", # GPP mode - Busy - Return PM
                    # "ADQ1109_065", # GPP mode - Offline - Return PM
                    # "ADQ1109_066", # GPP mode - Busy return 2 pside message links
                    # "ADQ1109_067", # V5 mode - Verify Trnsl- alarm V5 in mode
                    # "ADQ1109_068", # V5 mode - Verify QueryPM in V5 mode
                    # "ADQ1109_069", # V5 mode - Busy and return link 1 & 2
                    # "ADQ1109_070", # V5 mode - Verify ACT and DEACT- Trnsl c and Trnsl p
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
# |   R21 Sourcing - APA-500 - ETSI BRI on C20 with V5.2 for Vodafone NZ         |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+

############################ Yen Le ##########################

sub ADQ1109_000 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_000");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_000";
    $tcid = "ADQ1109_000";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $flag = 1;
    
################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();

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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    

###################### Call flow ###########################
# start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
# Offhook line A
unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASSED\n";
    }

# Detect dialtone on line A
%input = (
                -line_port => $list_line[0], 
                -freq1 => 440,
                -freq2 => 350,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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

    # Get PCM trace
    %input = (
            -remoteip => $cas_server[0],
            -remoteuser => $sftp_user,
            -remotepasswd => $sftp_pass,
            -localDir => '/home/ylethingoc/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
  
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_001 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_001");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_001";
    $tcid = "ADQ1109_001";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    #start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A calls B via isup trunk and check speech path then A flashes
    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
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
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path then A flashes - PASS\n";
    }

# A calls C and check speech path then flash
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }
	
	($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
	$dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C and check speech path then flash");
        print FH "STEP: A calls C and check speech path then flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C and check speech path then flash - PASS\n";
    }

# Check speech path among A, B, C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /WC/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line A 
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
            print FH "STEP: Remove 3WC from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[0] - PASS\n";
        }
    }
  
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_002 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_002");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_002";
    $tcid = "ADQ1109_002";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
	my $mlh_added = 1;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
	my $cfu_act_code = 47;
    my $dialed_num;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] \$ DGT \$ 6 y y")) {
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
	
# Add CFU to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] CFU N \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFU for line $list_dn[0]");
		print FH "STEP: add CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFU for line $list_dn[0] - PASS\n";
    }
    
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A off-hooks to active CFU
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASSED\n";
    }
	# Check A hears dial tone
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASSED\n";
    }
    
	# Start detect Confirmation tone
	# $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);
	
	# A dials CFU + DN(C)
    $dialed_num = '*'. $cfu_acc . $list_dn[2] . '#';
    %input = (
                -line_port => $list_line[0],
               	-dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num ");
		print FH "STEP: A dials cfu_acc to enable CFW to C($list_dn[2]) - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: A dials cfu_acc to enable CFW to C($list_dn[2]) - PASSED\n";
	}
    # Stop detect Confirmation tone
    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
    #     $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
    #     print FH "STEP: A hears confirmation tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hears confirmation tone - PASS\n";
    # }
    # sleep(5);

# A on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASSED\n";
    }

# D calls A and the call forward to line C
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[3],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls A and the call forward to line C");
        print FH "STEP: D calls A and the call forward to line C - FAIL\n";
        print FH "STEP: Check speech path between D and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and the call forward to line C - PASS\n";
        print FH "STEP: Check speech path between D and C - PASS\n";
    }
	
	
################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CFU|MLH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

 # remove CFU from line A

	$ses_core->execCmd ("servord");
    unless ($ses_core->execCmd("deo \$ $list_dn[0] $list_len[0] CFU \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot del CFU for line $list_dn[0]");
		print FH "STEP: del CFU for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: del CFU for line $list_dn[0] - PASS\n";
    }
	
	# remove MLH
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_003 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_003");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_003";
    $tcid = "ADQ1109_003";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $scl_code = 28;
    my $spdc_code = 18;
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $scl_code")) {
        @output = $ses_core->execCmd("add IADFET $scl_code FEAT N N SCPL");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $scl_code FEAT N N SCPL");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SCPL/, $ses_core->execCmd("pos IADFET $scl_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $scl_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $scl_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $scl_code in table IBNXLA - PASS\n";
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        @output = $ses_core->execCmd("add IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SPDC/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $spdc_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Add SCL and 3WC to line A
    foreach ("SCL L30","3WC") {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[0]");
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A dials SCL code + NN + DN (B) and hear confirmation tone then onhook
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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    # $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = "\*$scl_code";
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

    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
    #     $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
    #     print FH "STEP: A hears confirmation tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hears confirmation tone - PASS\n";
    # }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    $list_dn[1] =~ /\d{3}(\d+)/;
    $dialed_num = '22' . $1;
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

# A dials SPDC code + NN and check speech path between line A and B then A flash
    $dialed_num = "\*$spdc_code" . '22';
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A dials SPDC code + NN and check speech path between line A and B");
        print FH "STEP: A dials SPDC code + NN and check speech path between line A and B then A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials SPDC code + NN and check speech path between line A and B then A flash - PASS\n";
    }

# A dials DN (C) then A flash
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[0],
                -regionB => $list_region[2],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 8','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['NONE'],
                -send_receive => ['DIGIT'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A dials DN(C), C rings then A flash");
        print FH "STEP: A dials DN(C), C rings then A flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials DN(C), C rings then A flashes - PASS\n";
    }

# A & B can hear ringback tone during talk with each other.
    # %input = (
    #             -line_port => $list_line[0], 
    #             -freq1 => 450,
    #             -freq2 => 400,
    #             -tone_duration => 100,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
    #     print FH "STEP: A hear ringback tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hear ringback tone - PASS\n";
    # }
    # %input = (
    #             -line_port => $list_line[1], 
    #             -freq1 => 450,
    #             -freq2 => 400,
    #             -tone_duration => 100,
    #             -cas_timeout => 50000, 
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[1]");
    #     print FH "STEP: B hear ringback tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: B hear ringback tone - PASS\n";
    # }

    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A and B can talk to each other during hearing Ringback from C");
        print FH "STEP: A and B can talk to each other during hearing Ringback from C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A and B can talk to each other during hearing Ringback from C - PASS\n";
    }

# C offhook and check speech path among A, B, C
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
    sleep(2);
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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
	
################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /SCL|3WC/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line A
    if ($add_feature_lineA) {
        foreach ("3WC","SCL") {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[0]");
                print FH "STEP: Remove $_ from line $list_dn[0] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[0] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_004 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_004");
 
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_004";
    $tcid = "ADQ1109_004";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $dialed_num;
    my $add_feature_lineA = 0;
    my $add_feature_lineB = 0;
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add CXR to line A, add simring for B and C
    unless ($ses_core->callFeature(-featureName => "CXR CTALL Y 12 STD", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[0]");
		print FH "STEP: Add CXR for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add CXR for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;

    unless ($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'servord'");
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# D calls A and check speech path
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[3],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls A and check speech path");
        print FH "STEP: D calls A and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A and check speech path - PASS\n";
    }

# A transfers call to SIMRING group
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

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
    sleep(8);

# B and C ring then onhook A
    # %input = (
    #             -line_port => $list_line[1],
    #             -ring_count => 1,
    #             -ring_on => 0,
    #             -ring_off => 0,
    #             -cas_timeout => 50000,
    #             -wait_for_event_time => $wait_for_event_time,
    #             );
    # unless ($ses_glcas->detectRingingSignalCAS(%input)) {
    #     $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
    #     print FH "STEP: Check line B ring - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: Check line B ring - PASS\n";
    # }

    %input = (
                -line_port => $list_line[2],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line C does not ring");
        print FH "STEP: Check line C ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(2);

# Offhook B, check status C back IDL and check speech path D and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

	unless (grep /IDL/, $ses_core->coreLineGetStatus($list_dn[2])) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[2] is not IDL");
        print FH "STEP: Check line $list_dn[2] IDL - FAIL\n";
        $flag = 0;
        last;
    } else {
        print FH "STEP: Check line $list_dn[2] IDL - PASS\n";
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
	
    %input = (
                -list_port => [$list_line[3],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between D and B");
        print FH "STEP: Check speech path between D and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between D and B - PASS\n";
    }

	
################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CXR|SIMRING/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line A and B
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[0]");
            print FH "STEP: Remove CXR from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[0] - PASS\n";
        }
    }
    if ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => 'SIMRING', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SIMRING from line $list_dn[1]");
            print FH "STEP: Remove SIMRING from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove SIMRING from line $list_dn[1] - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_005 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_005");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_005";
    $tcid = "ADQ1109_005";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineB = 0;
    my $add_feature_lineC = 0;
    my $dialed_num;
    my (@cat,$logutil_path);
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add CWT, CWI to line B and C
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

    foreach ('CWT','CWI') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[2]");
            print FH "STEP: Add $_ for line $list_dn[2] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Add $_ for line $list_dn[2] - PASS\n";
        }
    }
    unless ($flag) {
        $result = 0;
        goto CLEANUP;
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# C calls B and check speech path
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[2],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls B and check speech path");
        print FH "STEP: C calls B and check speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls B and check speech path - PASS\n";
    }

# A calls C and hear ringback tone, C hear CWT tone
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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    $dialed_num = $list_dn[2];
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

    # Check CWT tone line C
    # %input = (
    #             -line_port => $list_line[2],
    #             -callwaiting_tone_duration => 300,
    #             -cas_timeout => 20000,
    #             -wait_for_event_time => $wait_for_event_time
    #             );
    # unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . " $tcid: Failed at C hears Call waiting tone");
    #     print FH "STEP: C hears Call waiting tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: C hears Call waiting tone - PASS\n";
    # }

    # Check Ringback tone line A
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }

    

# C flash to answer A
    %input = (
                -line_port => $list_line[2], 
                -flash_duration => 600,
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_dn[2]");
        print FH "STEP: C Flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C Flash - PASS\n";
    }
    sleep(2);

# Check speech path A and C
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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

# D calls B and hear ringback tone, B hear CWT tone
    unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook line D - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line D - PASS\n";
    }

    %input = (
                -line_port => $list_line[3],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[3]");
        $result = 0;
        goto CLEANUP;
    }

    $dialed_num = $list_dn[1];
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num successfully");
        print FH "STEP: D dials $dialed_num - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D dials $dialed_num - PASS\n";
    }

    # Check CWT tone line B
    # %input = (
    #             -line_port => $list_line[1],
    #             -callwaiting_tone_duration => 300,
    #             -cas_timeout => 20000,
    #             -wait_for_event_time => $wait_for_event_time
    #             );
    # unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . " $tcid: Failed at B hears Call waiting tone");
    #     print FH "STEP: B hears Call waiting tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: B hears Call waiting tone - PASS\n";
    # }

    # Check Ringback tone line D
    %input = (
                -line_port => $list_line[3], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[3]");
        print FH "STEP: D hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hear ringback tone - PASS\n";
    }

# B flash to answer D
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

# Check speech path B and D
    %input = (
                -list_port => [$list_line[1],$list_line[3]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and D");
        print FH "STEP: Check speech path between B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between B and D - PASS\n";
    }
    sleep(2);

# A, D and B go onhook, check speech path B and C
    foreach ($list_line[0], $list_line[3], $list_line[1]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
        sleep(5);
    }

    # Check line B re-ring
    %input = (
                -line_port => $list_line[1],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not rering");
        print FH "STEP: Check line B rering - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B rering - PASS\n";
    }

    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and B");
        print FH "STEP: Check speech path between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and B - PASS\n";
    }

# B and C go onhook
    foreach ($list_line[1], $list_line[2]){
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }

################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CWT|CWI/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # Remove service from line B and C
    if ($add_feature_lineB) {
        foreach ('CWI','CWT') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }
    if ($add_feature_lineC) {
        foreach ('CWI','CWT') {
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[2]");
                print FH "STEP: Remove $_ from line $list_dn[2] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[2] - PASS\n";
            }
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_006 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_006");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_006";
    $tcid = "ADQ1109_006";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $scl_code = 16;
    my $spdc_code = 17;
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $scl_code")) {
        @output = $ses_core->execCmd("add IADFET $scl_code FEAT N N SCPL");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $scl_code FEAT N N SCPL");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SCPL/, $ses_core->execCmd("pos IADFET $scl_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $scl_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $scl_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $scl_code in table IBNXLA - PASS\n";
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        @output = $ses_core->execCmd("add IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SPDC/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $spdc_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A dials SCS code + NN + acccode DN (B) and hear confirmation tone then onhook
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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    # $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

    $dialed_num = "\*$scl_code";
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

    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
    #     $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
    #     print FH "STEP: A hears confirmation tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hears confirmation tone - PASS\n";
    # }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
	$dialed_num = '11'. $trunk_access_code . $dialed_num;
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

# A dials SPDC code + NN and check speech path between line A and B
    $dialed_num = "\*$spdc_code" . '11';
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
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
	
################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_007 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_007");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_007";
    $tcid = "ADQ1109_007";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
    my $dialed_num;
    my $scs_code = 15;
    my $spdc_code = 17;
    my $flag = 1;
    
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Datafill in table IBNXLA
    unless (grep/IBNXLA/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table IBNXLA'");
    }
    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $scs_code")) {
        @output = $ses_core->execCmd("add IADFET $scs_code FEAT N N SCPS");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $scs_code FEAT N N SCPS");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SCPS/, $ses_core->execCmd("pos IADFET $scs_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $scs_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $scs_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $scs_code in table IBNXLA - PASS\n";
    }

    if (grep /NOT FOUND/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        @output = $ses_core->execCmd("add IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    } else {
        @output = $ses_core->execCmd("rep IADFET $spdc_code FTR 2 SPDC");
        if (grep/DMOS NOT ALLOWED/, @output) {
            $ses_core->execCmd("y");
        }
        $ses_core->execCmd("y");
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
        }
    }
    unless (grep /SPDC/, $ses_core->execCmd("pos IADFET $spdc_code")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill IADFET $spdc_code in table IBNXLA");
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill IADFET $spdc_code in table IBNXLA - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Add SCS to line A
    unless ($ses_core->callFeature(-featureName => "SCS", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SCS for line $list_dn[0]");
		print FH "STEP: Add SCS for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SCS for line $list_dn[0] - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A dials SCS code + N + acccode + DN (B) and hear confirmation tone then onhook
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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    # $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[0], -cas_timeout => 50000);

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

    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[0], -wait_for_event_time => 30)) {
    #     $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[0]");
    #     print FH "STEP: A hears confirmation tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: A hears confirmation tone - PASS\n";
    # }

    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    ($dialed_num) = ($list_dn[1] =~ /\d{3}(\d+)/);
	$dialed_num = '8'. $trunk_access_code . $dialed_num;
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
    $dialed_num = "\*$spdc_code" . '8';
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
                -regionB => $list_region[1],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
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
		
################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_008 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_008");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_008";
    $tcid = "ADQ1109_008";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $mdn_added = 0;
	my $add_feature_lineA = 0;
    my ($dialed_num, @list_file_name, @cmd, @verify);
    my $flag = 1;
    
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[0]");
		print FH "STEP: Add 3WC for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add 3WC for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
	
# Add MDN to line A as primary, Line B as member
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 12 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN to line $list_dn[0] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[0] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: Add MDN to line $list_dn[1] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[1] as member - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[2]");
        print FH "STEP: C hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears dial tone - PASS\n";
    }

    $dialed_num = $list_dn[0];
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
        $logger->error(__PACKAGE__ . ".$sub_name: Line D does not ring");
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
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }

# A answer and check speech path between C and A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
    sleep(2);

    # Check speech path line C and A
    %input = (
                -list_port => [$list_line[2],$list_line[0]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between C and A");
        print FH "STEP: Check speech path between C and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between C and A - PASS\n";
    }

# B offhook and check speech path among C, A, B 
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

    # Check speech path among A, B, D
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path among A, B, D");
        print FH "STEP: Check speech path among A, B, D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path among A, B, D - PASS\n";
    }

# A flash and dials D
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
	
# A calls D and check speech path then flash
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears dial tone - PASS\n";
    }

    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[0],
                -regionB => $list_region[3],
                -check_dial_tone => 'n',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'A'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls D and check speech path then flash");
        print FH "STEP: A calls D and check speech path then flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls D and check speech path then flash - PASS\n";
    }

# Check speech path among A, B, C, D 
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2],$list_line[3]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path among A, B, C, D");
        print FH "STEP: Check speech path among A, B, C, D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path among A, B, C, D - PASS\n";
    }	
	
################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /MDN/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
    # Remove MDN from line A and B 
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[1] from MDN group");
            print FH "STEP: Remove line $list_dn[1] from MDN group - FAIL\n";
        } else {
            print FH "STEP: Remove line $list_dn[1] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[0] - PASS\n";
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

	# Remove service from line A 
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[0]");
            print FH "STEP: Remove 3WC from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[0] - PASS\n";
        }
    }
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
	
}

sub ADQ1109_009 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_009");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_009";
    $tcid = "ADQ1109_009";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $dlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 0;
	my $pcm_start = 0;
	my $tapi_start = 0;
    my $flag = 1;
	my ($dialed_num, @list_file_name, %info);
   
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    
# Add DLH
    $ses_core->execCmd("est \$ DLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
    unless (grep /DLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	$dlh_added = 0;
	
# Add LOD to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] lod $list_dn[2] \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LOD for line $list_dn[0]");
		print FH "STEP: add LOD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add LOD for line $list_dn[0] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
    # A offhooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
	
	# B offhooks
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
	
	# Make call D to A via ISUP 
	($dialed_num) = ($list_dn[0] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $dialed_num,
                -regionA => $list_region[3],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: D cannnot call A ");
        print FH "STEP: D calls A via trunk isup and C answer - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls A via trunk isup and C answer - PASS\n";
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DLH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
# Remove LOD from A
    unless ($ses_core->execCmd("deo \$ $list_dn[0] $list_len[0] lod \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot del LOD for line $list_dn[0]");
		print FH "STEP: del LOD for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: del LOD for line $list_dn[0] - PASS\n";
    }
	
# Remove DLH
    unless ($dlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ dlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from DLH group");
            print FH "STEP: delete member $list_dn[1] from DLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from DLH group - PASS\n";
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_010 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_010");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_010";
    $tcid = "ADQ1109_010";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
	############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_pri'}{-acc};
    my $trunk_region = $db_trunk{'g6_pri'}{-region};
    my $trunk_clli = $db_trunk{'g6_pri'}{-clli};

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
	my $dnh_added = 1;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
    my $dialed_num;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;
	
# Add CFB to line C
	unless ($ses_core->callFeature(-featureName => "CFB N $list_dn[0]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFB for line $list_dn[2]");
		print FH "STEP: add CFB for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFB for line $list_dn[2] - PASS\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# Change line C status into MB in Mapci
	unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[2] is not IDL");
        $result = 0;
        goto CLEANUP;
    }
    unless ($ses_core->execCmd("bsy")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot execute command 'bsy' ");
    }
    unless (grep /\sMB\s/, $ses_core->execCmd("post d $list_dn[2] print")) {
        $logger->error(__PACKAGE__ . " $tcid: line $list_dn[2] is not MB after 'bsy' ");
        print FH "STEP: Make line $list_dn[2] busy - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Make line $list_dn[2] busy - PASS\n";
    }
    unless ($ses_core->execCmd("quit all")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot execute command 'quit all' ");
    }
	
# Make pilot A busy (offhook A)
	%input = (
				-line_port => $list_line[0], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - PASS\n";
	}
	
# D calls C via trunk PRI and the call forward to line B  
   ($dialed_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
    $dialed_num = $trunk_access_code . $dialed_num;
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[3],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls C and the call forward to line B");
        print FH "STEP: D calls C and the call forward to line B - FAIL\n";
        print FH "STEP: Check speech path between D and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls C and the call forward to line B - PASS\n";
        print FH "STEP: Check speech path between D and B - PASS\n";
    }

	
################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CFB|DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

# Return line C status into IDL in Mapci
	unless ($ses_core -> execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[2]; rts;")) {
       $logger->error(__PACKAGE__ . ": Could not rts $list_dn[2] ");
       print FH "STEP: Rts $list_dn[2] - FAIL\n";
       $result = 0; 
    } else {
       print FH "STEP: Rts $list_dn[2] - PASS\n"; 
	}  
	
# Remove CFB from line C
	if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CFB', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFB from line $list_dn[2]");
            print FH "STEP: Remove CFB from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFB from line $list_dn[2] - PASS\n";
        }
    }
	
# Remove DNH
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_011 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_011");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_011";
    $tcid = "ADQ1109_011";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
	my $add_feature_lineAB = 0;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Add CFD to line C
    unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[0]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[2]");
		print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;
	
# Add CPU to line A and B (A and B must have the same custgroup)
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[1] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineAB = 1;

    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CPU');
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
#off-hook line D
	%input = (
				-line_port => $list_line[3], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[3]");
		print FH "STEP: Offhook line D - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[3]");
		print FH "STEP: Offhook line D - PASS\n";
	}
	
#check dial tone line D 
	%input = (
				-line_port => $list_line[3], 
				-dial_tone_duration => '1000', 
				-cas_timeout => '50000',
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->detectDialToneCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect dial tone line $list_line[3]");
		print FH "STEP: D hears dial tone - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully detect dial tone line $list_line[3]");
		print FH "STEP: D hears dial tone - PASS\n";
	}
	
#D makes the call to C  
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
        print FH "STEP: D dials $list_dn[2] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: D dials $list_dn[2] - PASS\n";
    }

#D hears ringback tone
    %input = (
                -line_port => $list_line[3], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[3]");
        print FH "STEP: D hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hear ringback tone - PASS\n";
    }
    

#C hears Ringing signal
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
	
# Wait timeout CFD
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
	
	# B dials CPU access code to pick up the call for A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[1]");
    }
    %input = (
                -line_port => $list_line[1],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
		print FH "STEP: B dials CPU code - FAIL\n";
    } else {
        print FH "STEP: B dials CPU code - PASS\n";
    }
    sleep(3);
	
    # check speech path between B and D
    %input = (
                -list_port => [$list_line[1],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between B and D ");
        print FH "STEP: check speech path between B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between B and D - PASS\n";
    }

	
################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CFD|CPU/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

	# remove CFD from line C 
    if ($add_feature_lineC) {
            unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
            print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
        }      
    }
	
	# remove CPU from line A and B
    if ($add_feature_lineAB) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[1]");
            print FH "STEP: Remove CPU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[1] - PASS\n";
        }
    }
	
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_012 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_012");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_012";
    $tcid = "ADQ1109_012";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
	my $mlh_added = 1;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
    my $dialed_num;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] \$ DGT \$ 6 y y")) {
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
	
# Add CXR to line C
	unless ($ses_core->callFeature(-featureName => "CXR CTALL Y 12 STD", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[2]");
		print FH "STEP: add CXR for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[2] - PASS\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# D calls C check speech path then C flashes
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[3],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['DIGITS'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls C check speech path then C flashes");
        print FH "STEP: D calls C check speech path then C flashes - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls C check speech path then C flashes - PASS\n";
    }
	
# C transfers call to MLH group
    %input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[2]");
        print FH "STEP: C hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears recall dial tone - PASS\n";
    }

    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: C dials $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $list_dn[0] - PASS\n";
    }
    sleep(8);

# A ring then onhook C
    %input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line A does not ring");
        print FH "STEP: Check line A ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ring - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
    sleep(2);

# Offhook A check speech path D and A 
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
	
    %input = (
                -list_port => [$list_line[3],$list_line[0]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between D and A");
        print FH "STEP: Check speech path between D and A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between D and A - PASS\n";
    }	
	
	
################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CXR|MLH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    # remove CXR from line C
	if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[2]");
            print FH "STEP: Remove CXR from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[2] - PASS\n";
        }
    }
	
    # remove MLH
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_013 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_013");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_013";
    $tcid = "ADQ1109_013";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $add_feature_lineC = 0;
    my ($dialed_num, @list_file_name);
    my ($cust_grp) = ($list_line_info[2] =~ /\w+\s(\w+)\s/);
	my $line_A_info = "IBN RESTP 0 0";
    my $flag = 1;
    
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Datafill in table CUSTSTN
    unless (grep/CUSTSTN/, $ses_core->execCmd("table CUSTSTN")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot execute command 'table CUSTSTN'");
    }
    
    if (grep /NOT FOUND/, $ses_core->execCmd("pos $cust_grp DRING DRING")) {
        @output = $ses_core->execCmd("add $cust_grp DRING DRING Y 2 Y 3 ALL 5 N N Y 1 N Y 5 N");
    } else {
        @output = $ses_core->execCmd("rep $cust_grp DRING DRING Y 2 Y 3 ALL 5 N N Y 1 N Y 5 N");
    }
    if (grep/DMOS NOT ALLOWED/, @output) {
        $ses_core->execCmd("y");
    }
    $ses_core->execCmd("y");
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'abort'");
    }
    unless (grep /DRING/, $ses_core->execCmd("pos $cust_grp DRING DRING")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot datafill $cust_grp DRING DRING in table CUSTSTN");
        print FH "STEP: Datafill $cust_grp DRING DRING in table CUSTSTN - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Datafill $cust_grp DRING DRING in table CUSTSTN - PASS\n";
    }

    unless ($ses_core->execCmd("quit")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'quit'");
    }

# Change CUSTGRP of Line A into RESTP 
    %input = (
                    -function => ['OUT','NEW'],
                    -lineDN => $list_dn[0], 
                    -lineType => '', 
                    -len => '', 
                    -lineInfo => $line_A_info
                );
    unless ($ses_core->resetLine(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Line $list_dn[0] cannot change custgrp into restp");
        print FH "STEP: Change CUSTGRP of $list_dn[0] into RESTP  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change CUSTGRP of $list_dn[0] into RESTP - PASS\n";
    }
	
# Add DRING to line C
    unless ($ses_core->callFeature(-featureName => "DRING Y 5 Y 2 ALL 2 N N N Y 4 N Y 5", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add DRING for line $list_dn[2]");
		print FH "STEP: add DRING for line B $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DRING for line B $list_dn[2] - PASS\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

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
                -detect => ['DELAY 12'], # change RINGING to DELAY 12 confirm time on&off
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C and they have speech path");
        print FH "STEP: A calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C and they have speech path - PASS\n";
    }
	
# Hang up line A and C
    foreach (@list_line[0..2]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
    sleep(2); 

# B calls C and they have speech path
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[1],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 12'], #change RINGING to DELAY 12 confirm time on-off 
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => ''
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls C and they have speech path");
        print FH "STEP: B calls C and they have speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls C and they have speech path - PASS\n";
    }
	
################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
            print FH "STEP: Check Trap - PASS\n";
        }
        @output = $ses_logutil->execCmd("open swerr");
        if (grep /DRING/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }  
    }

    # Remove DRING from line C
    if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'DRING', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove DRING from line $list_dn[2]");
            print FH "STEP: Remove DRING from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove DRING from line $list_dn[2] - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_014 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_014");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_014";
    $tcid = "ADQ1109_014";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $mdn_added = 0;
	my $add_feature_lineC = 0;
    my ($dialed_num, @list_file_name);
    my $flag = 1;
    
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add CFD to line C	
	unless ($ses_core->callFeature(-featureName => "CFD N $list_dn[0]", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CFD for line $list_dn[2]");
		print FH "STEP: add CFD for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CFD for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;
	
# Add MDN to line A as primary, Line B as member
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 12 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN to line $list_dn[0] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[0] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: Add MDN to line $list_dn[1] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[1] as member - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
#off-hook line D
	%input = (
				-line_port => $list_line[3], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[3]");
		print FH "STEP: Offhook line D - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[3]");
		print FH "STEP: Offhook line D - PASS\n";
	}
	
#check dial tone line D 
	%input = (
				-line_port => $list_line[3], 
				-dial_tone_duration => '1000', 
				-cas_timeout => '50000',
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->detectDialToneCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect dial tone line $list_line[3]");
		print FH "STEP: D hears dial tone - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully detect dial tone line $list_line[3]");
		print FH "STEP: D hears dial tone - PASS\n";
	}
	
#D makes the call to C  
    %input = (
                -line_port => $list_line[3],
                -dialed_number => $list_dn[2],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] successfully");
        print FH "STEP: D dials $list_dn[2] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: D dials $list_dn[2] - PASS\n";
    }

#D hears ringback tone
    %input = (
                -line_port => $list_line[3], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[3]");
        print FH "STEP: D hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D hear ringback tone - PASS\n";
    }

#C hears Ringing signal
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
	
# Wait timeout CFD
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
	
	# Check line B ringing
	%input = (
                -line_port => $list_line[0],
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
	
	#off-hook line A 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }

	#Check speech path 
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and D");
        print FH "STEP: Check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and D - PASS\n";
    }
	
	#off-hook line B 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
	
	#Check speech path A, B, D
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[3]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A, B and D");
        print FH "STEP: Check speech path between A, B and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A, B and D - PASS\n";
    }

	
################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

    # Cleanup call
    if ($initialize_done) {
        foreach (@list_line){
            unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
                $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            }
        }
        unless($ses_glcas->cleanupCAS(-list_port => [@list_line])) {
            $logger->error(__PACKAGE__ . ": Cannot cleanup GLCAS");
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CFD|MDN/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
    # Remove MDN from line A and B 
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[1] from MDN group");
            print FH "STEP: Remove line $list_dn[1] from MDN group - FAIL\n";
        } else {
            print FH "STEP: Remove line $list_dn[1] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[0] - PASS\n";
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

	# Remove service from line C 
    if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'CFD', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CFD from line $list_dn[2]");
            print FH "STEP: Remove CFD from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CFD from line $list_dn[2] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_015 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_015");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_015";
    $tcid = "ADQ1109_015";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $mdn_added = 0;
	my $add_feature_lineA = 0;
    my ($dialed_num, @list_file_name);
    my $flag = 1;
    
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Add CXR to line A 
	unless ($ses_core->callFeature(-featureName => "CXR CTALL Y 12 STD", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[0]");
		print FH "STEP: add CXR for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[0] - PASS\n";
    }
    $add_feature_lineA = 1;
	
# Add MDN MCA 
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn mca y y $list_dn[0] \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN MCA to line $list_dn[0] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN MCA to line $list_dn[0] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn mca n y $list_dn[0] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: Add MDN MCA to line $list_dn[1] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN MCA to line $list_dn[1] as member - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
#off-hook line C
	%input = (
				-line_port => $list_line[2], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - PASS\n";
	}
	
#check dial tone line C 
	%input = (
				-line_port => $list_line[2], 
				-dial_tone_duration => '1000', 
				-cas_timeout => '50000',
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->detectDialToneCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect dial tone line $list_line[2]");
		print FH "STEP: C hears dial tone - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully detect dial tone line $list_line[2]");
		print FH "STEP: C hears dial tone - PASS\n";
	}
	
#C makes the call to A  
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: C dials $list_dn[0] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: C dials $list_dn[0] - PASS\n";
    }

#C hears ringback tone
    %input = (
                -line_port => $list_line[2], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[2]");
        print FH "STEP: C hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hear ringback tone - PASS\n";
    }

#A hears Ringing signal
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
	
#B hears Ringing signal
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
	
#Off-hook line A 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
	
	#Check speech path 
    %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }
	
	# A flashes 
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
	
	# A calls B, B rings then A onhook 
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
    }

    %input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: A dials $list_dn[0] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: A dials $list_dn[0] - PASS\n";
    }

	#B hears Ringing signal
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
	
	#A onhook
	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
    sleep(2);
	
	#Off-hook line B 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

	#Check speech path 
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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
            print FH "STEP: Cleanup GLCAS - FAIL\n";
        } else {
            print FH "STEP: Cleanup GLCAS - PASS\n";
        }
    }

    # Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CXR|MDN/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
# Remove MDN MCA from line A and B 
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[1] from MDN group");
            print FH "STEP: Remove line $list_dn[1] from MDN group - FAIL\n";
        } else {
            print FH "STEP: Remove line $list_dn[1] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[0] - PASS\n";
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
	
# remove CXR from line A
	if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[0]");
            print FH "STEP: Remove CXR from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[0] - PASS\n";
        }
    }
	
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_016 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_016");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_016";
    $tcid = "ADQ1109_016";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
    my $add_feature_lineA = 1;
	my $dlh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 0;
	my $pcm_start = 0;
    my $flag = 1;
	my @list_file_name;
   
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

#Data fill table IBNRTE
    if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table IBNRTE")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table IBNRTE'");
    }
	
    if (grep /Y TO CONTINUE/, $ses_core->execCmd("rep 201 S N N N N T60 \$ \$")) {
		if (grep /KEY NOT FOUND/, $ses_core->execCmd("Y")) {
			$logger->error(__PACKAGE__ . " $tcid: ERROR when changing tuple 201");
			$ses_core->execCmd("abort");
			if (grep /Y TO CONTINUE/, $ses_core->execCmd("add 201 S N N N N T60 \$ \$")) {
				if (grep /Y TO CONFIRM/, $ses_core->execCmd("Y")){
					if (grep /TUPLE ADDED/, $ses_core->execCmd("Y")){
						$logger->error(__PACKAGE__ . " $tcid: add successfully 201");
						print FH "STEP: add 201 S N N N N T60 - PASS\n";
					}else {
						print FH "STEP: add 201 S N N N N T60 - FAIL\n";
					}
				}
			}
		}else{
			$ses_core->execCmd("abort");
			print FH "STEP: Exist 201 S N N N N T60 - PASS\n";
		}
    }
	$ses_core->execCmd("abort");
	
    if (grep /T60/, $ses_core->execCmd("pos 201")) {
        $logger->error(__PACKAGE__ . " $tcid: can command 'pos 201'");
        print FH "STEP: Datafill tuple 201 in table IBNRTE - PASS\n";
    } else {
        print FH "STEP: Datafill tuple 201 in table IBNRTE - FAIL\n";
		$result = 0;
        goto CLEANUP;
    }
	
#Out A, B
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
    
# Add DLH
    $ses_core->execCmd("est \$ DLH $list_dn[0] $list_line_info[0] \+");
    unless ($ses_core->execCmd("$list_len[0] $list_len[1] \$ DGT \$ 6 y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'est'");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot command 'abort'");
    }
	
    unless (grep /DLH/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DLH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
	$dlh_added = 0;
	
# Add LOR to line A
	unless ($ses_core->execCmd("ado \$ $list_dn[0] $list_len[0] lor IBNRTE 201 \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LOR for line $list_dn[0]");
		    print FH "STEP: add LOR for line $list_dn[0] - FAIL\n";
			$result = 0;
			goto CLEANUP;
		} else {
			print FH "STEP: add LOR for line $list_dn[0] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
#off-hook line A
	%input = (
				-line_port => $list_line[0], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - PASS\n";
	}
	
#off-hook line B
	%input = (
				-line_port => $list_line[1], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - PASS\n";
	}
	
# Make call C to pilot hunt group A, C hears busy tone
	%input = (
				-line_port => $list_line[2], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - PASS\n";
	}
	
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: C dials $list_dn[0] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: C dials $list_dn[0] - PASS\n";
    }

    %input = (
                -line_port => $list_line[2],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
	unless($ses_glcas->detectBusyToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect busy tone line $list_dn[2]");
        print FH "STEP: C hears busy tone - FAIL\n";
		$result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears busy tone - PASS\n";
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DLH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
# Remove LOR from A
	unless ($ses_core->execCmd("deo \$ $list_dn[0] $list_len[0] lor \$ y y")) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot del LOR for line $list_dn[0]");
		print FH "STEP: del LOR for line $list_dn[0] - FAIL\n";
		$result = 0;
		goto CLEANUP;
	}else {
		print FH "STEP: del LOR for line $list_dn[0] - PASS\n";
	}
	
# Remove DLH
    unless ($dlh_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("del \$ dlh $list_len[1] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEL fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot delete member $list_dn[1] from DLH group");
            print FH "STEP: delete member $list_dn[1] from DLH group - FAIL\n";
        } else {
            print FH "STEP: delete member $list_dn[1] from DLH group - PASS\n";
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_017 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_017");

########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_017";
    $tcid = "ADQ1109_017";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $wait_for_event_time = 30;
	my $dnh_added = 1;
    my $initialize_done = 1;
    my $logutil_start = 0;
	my $pcm_start = 0;
    my $flag = 1;
	my @list_file_name;
   
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
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
    $initialize_done = 0;
    
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

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
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and check speech path C with B");
        print FH "STEP: C calls A and C&B 2way speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and C&B 2way speech path - PASS\n";
    }

################################## Cleanup 017 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 017 ##################################");

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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_018 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_018");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_018";
    $tcid = "ADQ1109_018";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
	my $add_feature_lineAB = 0;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Add CXR to line C
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[2]");
		print FH "STEP: add CXR for line B $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line B $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;
	
# Add CPU to line A and B (A and B must have the same custgroup)
    if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("est \$ CPU $list_len[0] $list_len[1] \$ y y")) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot add CPU for line $list_dn[0] and $list_dn[1]");
        $ses_core->execCmd("abort");
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[0]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
    }
    unless (grep /CPU/, $ses_core->execCmd("qdn $list_dn[1]")) {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CPU for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $add_feature_lineAB = 1;
	
#Get CPU acccode
    my $cpu_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'CPU');
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# D calls C and check speech path then C Flash
    %input = (
                -lineA => $list_line[3],
                -lineB => $list_line[2],
                -dialed_number => $list_dn[2],
                -regionA => $list_region[3],
                -regionB => $list_region[2],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at D calls C and check speech path then C flash");
        print FH "STEP: D calls C and check speech path then C flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: D calls C and check speech path then C flash - PASS\n";
    }

# C calls B, B rings then C onhook
    %input = (
                -line_port => $list_line[2],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[2]");
        print FH "STEP: C hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears recall dial tone - PASS\n";
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
        print FH "STEP: C dials $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $list_dn[1] - PASS\n";
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
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
        print FH "STEP: Check line B ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring - PASS\n";
    }

	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
	
# A dials CPU access code to pick up the call for B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
    }
    %input = (
                -line_port => $list_line[0],
                -dialed_number => "\*$cpu_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $cpu_acc successfully");
		print FH "STEP: A dials CPU code - FAIL\n";
    } else {
        print FH "STEP: A dials CPU code - PASS\n";
    }
    sleep(3);
	
# check speech path between A and D
    %input = (
                -list_port => [$list_line[0],$list_line[3]], 
                -checking_type => ['TESTTONE','DIGITS'], 
                -tone_duration => 2000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at checking speech path between A and D ");
        print FH "STEP: check speech path between A and D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: check speech path between A and D - PASS\n";
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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /CFD|CPU/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

	# remove CXR from line C 
    if ($add_feature_lineC) {
            unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[2]");
            print FH "STEP: Remove CXR from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[2] - PASS\n";
        }      
    }
	
	# remove CPU from line A and B
    if ($add_feature_lineAB) {
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[0]");
            print FH "STEP: Remove CPU from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[0] - PASS\n";
        }
        unless ($ses_core->callFeature(-featureName => 'CPU', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CPU from line $list_dn[1]");
            print FH "STEP: Remove CPU from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove CPU from line $list_dn[1] - PASS\n";
        }
    }
	
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}
	
sub ADQ1109_019 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_019");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_019";
    $tcid = "ADQ1109_019";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
	my $mdn_added = 0;
	my @list_file_name;
	my $snd_sub = 4005004321;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Add SDN 4005004321 3P to line C
	unless ($ses_core->callFeature(-featureName => "SDN $snd_sub 3 P \$ \$", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line $list_dn[2]");
		print FH "STEP: Add SDN for line $list_dn[2] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SDN for line $list_dn[2] - PASSED\n";
    }
    $add_feature_lineC = 1;

# Add MDN SCA to line A as primary, Line B as member
    unless($ses_core->execCmd("servord")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'servord'");
    }
    unless ($ses_core->execCmd("ado \$ $list_dn[0] mdn sca y y $list_dn[0] tone y 12 y nonprivate \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /MADN MEMBER LENS INFO/, $ses_core->execCmd("qdn $list_dn[0]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[0]' ");
        print FH "STEP: Add MDN to line $list_dn[0] as primary - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[0] as primary - PASS\n";
    }

    unless ($ses_core->execCmd("ado \$ $list_dn[1] mdn sca n y $list_dn[0] BLDN \$ y y")){
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'ado'");
    }
    unless($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'abort' ");
    }
    unless(grep /UNASSIGNED/, $ses_core->execCmd("qdn $list_dn[1]")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot command 'qdn $list_dn[1]' ");
        print FH "STEP: Add MDN to line $list_dn[1] as member - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add MDN to line $list_dn[1] as member - PASS\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls C by SDN of C and check speech path A&C 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[2],
                -dialed_number => '4005004321',
                -regionA => $list_region[0],
                -regionB => $list_region[2],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls C by SDN of C and check speech path A&C");
        print FH "STEP: A calls C by SDN of C and check speech path A&C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls C by SDN of C and check speech path A&C - PASS\n";
    }

# Off-hook B joins bridge 
	%input = (
				-line_port => $list_line[1], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - PASS\n";
	}
	
#Check speech path among A,B,C 
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A,B and C");
        print FH "STEP: Check speech path between A,B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A,B and C - PASS\n";
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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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
        if (grep /SDN|MDN/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

# Remove MDN from line A and B 
    if ($mdn_added) {
        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("out \$ $list_dn[0] $list_len[1] bldn y y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after OUT fail");
            }
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot remove line $list_dn[1] from MDN group");
            print FH "STEP: Remove line $list_dn[1] from MDN group - FAIL\n";
        } else {
            print FH "STEP: Remove line $list_dn[1] from MDN group - PASS\n";
        }

        if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_len[0] mdn $list_dn[0] \$ y y")) {
            unless($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after DEO fail");
            }
            print FH "STEP: Remove MDN from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove MDN from line $list_dn[0] - PASS\n";
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
	
# remove SDN from line C 
    if ($add_feature_lineC) {
            unless ($ses_core->callFeature(-featureName => 'SDN 4005004321', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove SDN from line $list_dn[2]");
            print FH "STEP: Remove SDN from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove SDN from line $list_dn[2] - PASS\n";
        }      
    }

	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_020 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_020");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_020";
    $tcid = "ADQ1109_020";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
	my $dnh_added = 1;
	my $un_line = 4005004321;
	my $dialed_num1;
	my $dialed_num2;
	my $dialed_num3;
	my @list_file_name;
    my $flag = 1;
    my $pcm_start = 0;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add SDN to line C
	unless ($ses_core->callFeature(-featureName => "SDN $un_line 3 E \$ \$", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add SDN for line $list_dn[2]");
		print FH "STEP: Add SDN for line $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SDN for line $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;

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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;	

# Get SDN acccode
    my $sdn_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'SDNID');
    unless ($sdn_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get SDNID access code");
		print FH "STEP: get SDNID access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get SDNID access code - PASS\n";
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
    #start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
    $pcm_start = 1;    


# Off-hook line A
	%input = (
				-line_port => $list_line[0], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[0]");
		print FH "STEP: Offhook line A - PASS\n";
	}

# C calls A by SDN and check speech path B & C 

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
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[2]");
        $result = 0;
        goto CLEANUP;
    }
	
	#C dials SDN call to pilot A busy 
    # $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[2], -cas_timeout => 50000);
    $dialed_num1 = '*' . $sdn_acc ;
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num1,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num1 successfully");
        print FH "STEP: C dials $dialed_num1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $dialed_num1 - PASS\n";
    }
    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[2], -wait_for_event_time => 30)) {
    #    $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[2]");
    # }

	# $ses_glcas->startDetectConfirmationToneCAS(-line_port => $list_line[2], -cas_timeout => 50000);
	($dialed_num2) = ($un_line =~ /\d{6}(\d+)/);
	$dialed_num2 = $dialed_num2;
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num2,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num2 successfully");
        print FH "STEP: C dials $dialed_num2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $dialed_num2 - PASS\n";
    }
    # unless ($ses_glcas->stopDetectConfirmationToneCAS(-line_port => $list_line[2], -wait_for_event_time => 30)) {
    #    $logger->error(__PACKAGE__ . ": Cannot detect confirmation tone for line $list_dn[2]");
    # }
	
    ($dialed_num3) = ($list_dn[0] =~ /\d{3}(\d+)/);
	$dialed_num3 = $dialed_num3 .'#';
    %input = (
                -line_port => $list_line[2],
                -dialed_number => $dialed_num3,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num3 successfully");
        print FH "STEP: C dials $dialed_num3 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials $dialed_num3 - PASS\n";
    }
    sleep(3);
	
#B rings and check speech path 
	%input = (
                -line_port => $list_line[1],
                -ring_count => 2,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
        print FH "STEP: Check line B ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ringing - PASS\n";
    }
	
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }

	%input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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

	
################################## Cleanup 020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 020 ##################################");

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
            -localDir => '/home/ylethingoc/PCM',
            -remoteFilePath => [@list_file_name]
            );
    if (@list_file_name) {
        unless(&SonusQA::Utils::sftpFromRemote(%input)) {
            $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
        }
    }
	}
	
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
        if (grep /SDN|DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
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

# remove SDN from line C  
    $ses_core->execCmd("servord");
    if ($add_feature_lineC) {
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_dn[2] SDN $un_line \$ y y")) {
			unless($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
			print FH "STEP: Remove SDN from line C $list_dn[2] - FAIL\n";
            }
        } else {
            print FH "STEP: Remove SDN from line C $list_dn[2] - PASS\n";
        }
	}
	
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_021 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_021");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_021";
    $tcid = "ADQ1109_021";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

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
	my $un_line = 4005004321;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add SDN $un_line 4P to line A
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# Off-hook line B 
	%input = (
				-line_port => $list_line[1], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[1]");
		print FH "STEP: Offhook line B - PASS\n";
	}

# Check dial tone line B
	%input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[1]");
		print FH "STEP: Check dial tone line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }else{
		print FH "STEP: Check dial tone line B - PASS\n";
	}
	
# B makes the call to A by SDN 
	 %input = (
                -line_port => $list_line[1],
                -dialed_number => $un_line,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $un_line successfully");
        print FH "STEP: B dials $un_line - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B dials $un_line - PASS\n";
    }
	
#A rings and check sp 
	%input = (
                -line_port => $list_line[0],
                -ring_count => 1,
                -ring_on => 0,
                -ring_off => 0,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectRingingSignalCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Line A does not ring");
        print FH "STEP: Check line A ringing - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line A ringing - PASS\n";
    }
	
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
		goto CLEANUP;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }

	%input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /SDN/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
# remove SDN from line A  
    $ses_core->execCmd("servord");
    if ($add_feature_lineA) {
		if (grep /INCONSISTENT DATA|ERROR/, $ses_core->execCmd("deo \$ $list_dn[0] SDN $un_line \$ y y")) {
			unless($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . ".$sub_name: Cannot command abort after Deo fail");
			print FH "STEP: Remove SDN from line $list_dn[0] - FAIL\n";
            }
        } else {
            print FH "STEP: Remove SDN from line $list_dn[0] - PASS\n";
        }
	}
	
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_022 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_022");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_022";
    $tcid = "ADQ1109_022";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});
	
############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
	my (@list_file_name, $ID);
    my $flag = 1;
  
    ################## LOGIN ##############
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
	
    $ses_core->execCmd("forceout $li_core_user");
	
	unless ($ses_dnbd->loginCore(-username => ['tiennn'], -password => ['tiennn'])) {
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	my ($lea_num) = ($list_dn[2] =~ /\d{3}(\d+)/);
	$lea_num = $trunk_access_code . $lea_num;
	
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
    
	# Add SURV to line A and LEA to line C
	$ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 ibn $list_dn[0] +");
	unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes AUTO_GRP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line A  ");
        print FH "STEP: Add SURV to line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line A - PASS\n";
    }
	unless(grep /Done/, @output = $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line C  ");
        print FH "STEP: Add LEA number to line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line C - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)/) {
			$ID = $1;
			print FH "Monitor Order ID is: $ID\n";
        }
	}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
# Add LNR to line A
	unless ($ses_core->callFeature(-featureName => "LNR", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add LNR for line $list_dn[0]");
		print FH "STEP: Add LNR for line $list_dn[0] - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LNR for line $list_dn[0] - PASSED\n";
    }
	
# Get LNR acccode
    my $lnr_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[0], -lastColumn => 'LNR');
    unless ($lnr_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get LNR access code");
		print FH "STEP: Get LNR access code - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get LNR access code - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
        }
    }
    unless ($flag){
        $result = 0;
        goto CLEANUP;
    }
    $initialize_done = 1;
    
# Start logutil 	
	%input = (
                -username => [@{$core_account{-username}}[10..19]], 
                -password => [@{$core_account{-password}}[10..19]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path between A and B - PASS\n";
    }

# Check LEA C ring
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
	sleep(2);
	
# LEA C off-hook
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook LEA $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook LEA $list_dn[2] - PASS\n";
    }
	
# LEA C can monitor the call between A and B
	%input = (
                -list_port => [$list_line[1],$list_line[0]],
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
	
# Hang up line A,B
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }

# Onhook line LEA 
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[2]");
            print FH "STEP: Onhook line $list_dn[2] - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $list_dn[2] - PASS\n";
        }
	
# A calls B by LNR acccode 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => "\*$lnr_acc\#",
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B by LNR acccode and check speech path");
        print FH "STEP: A calls B by LNR acccode and check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B by LNR acccode and check speech path between A and B - PASS\n";
    }
	
# Check LEA C ring
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
	sleep(2);
	
# LEA C off-hook
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook LEA $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook LEA $list_dn[2] - PASS\n";
    }
	
# LEA C can monitor the call between A and B via LNR acccode
	%input = (
                -list_port => [$list_line[1],$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[2],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B via LNR acccode");
        print FH "STEP: LEA can monitor the call between A and B via LNR accesscode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B via LNR accesscode - PASS\n";
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /LNR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}

# Deact LEA
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_dnbd->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
		
#Remove LNR from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'LNR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove LNR from line $list_dn[0]");
            print FH "STEP: Remove LNR from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove LNR from line $list_dn[0] - PASS\n";
        }
    }
	
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_023 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_023");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_023";
    $tcid = "ADQ1109_023";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineC = 0;
	my (@list_file_name, $ID);
    my $flag = 1;
  
    ################## LOGIN ##############
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
	
    $ses_core->execCmd("forceout $li_core_user");
	
	unless ($ses_dnbd->loginCore(-username => ['tiennn'], -password => ['tiennn'])) {
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    
	# Add SURV to line A and LEA to line D 
	$ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 ibn $list_dn[0] +");
	unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes AUTO_GRP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line A  ");
        print FH "STEP: Add SURV to line A - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line A - PASS\n";
    }
	unless(grep /Done/, @output = $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if (/Monitor Order ID.*\s(\d+)/) {
			$ID = $1;
			print FH "Monitor Order ID is: $ID\n";

        }
	}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
# Add ACB feature to line C
	unless ($ses_core->callFeature(-featureName => "ACB NOAMA", -dialNumber => $list_dn[2], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add ACB for line $list_dn[2]");
		print FH "STEP: add ACB for line C $list_dn[2] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add ACB for line C $list_dn[2] - PASS\n";
    }
    $add_feature_lineC = 1;
	
# Get access code ACB
	my $acb_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[2], -lastColumn => 'ACBA');
    unless ($acb_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get ACB access code for line $list_dn[2]");
		print FH "STEP: Get ACB access code for line $list_dn[2] is $acb_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get ACB access code for line $list_dn[2] is $acb_acc - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A calls B 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path");
        print FH "STEP: A calls B and check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B and check speech path between A and B - PASS\n";
    }
	
# Check LEA D ring
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
	
# LEA D off-hook
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook LEA $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook LEA $list_dn[3] - PASS\n";
    }
	
# LEA D can monitor the call between A and B
	%input = (
                -list_port => [$list_line[1],$list_line[0]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and B");
        print FH "STEP: LEA can monitor the call between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and B - PASS\n";
    }
	
# C goes offhook dial A then onhook
#off-hook line C 
	%input = (
				-line_port => $list_line[2], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_line[2]");
		print FH "STEP: Offhook line C - PASS\n";
	}
	
#check dial tone line C
	%input = (
				-line_port => $list_line[2], 
				-dial_tone_duration => '1000', 
				-cas_timeout => '50000',
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->detectDialToneCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect dial tone line $list_line[2]");
		print FH "STEP: C hears dial tone - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully detect dial tone line $list_line[2]");
		print FH "STEP: C hears dial tone - PASS\n";
	}
	
#C calls A then onhook 
	%input = (
                -line_port => $list_line[2],
                -dialed_number => $list_dn[0],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[0] successfully");
        print FH "STEP: C dials $list_dn[0] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: C dials $list_dn[0] - PASS\n";
    }
	
# C hears busy tone
    sleep(2);
    my %input = (
                -line_port => $list_line[2],
                -busy_tone_duration => 2000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time,
                ); 
    unless($ses_glcas->detectBusyToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot detect busy tone line $list_line[2]");
        print FH "STEP: C hears busy tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C hears busy tone - PASS\n";
    }
	
	unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[2]");
            print FH "STEP: Onhook line $list_dn[2] - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $list_dn[2] - PASS\n";
        }
		
	sleep (2);
# C offhooks and dials ACB accesscode then onhooks
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
		
# C dials *acb_acc
    %input = (
                -line_port => $list_line[2],
                -dialed_number => "\*$acb_acc\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial ACB acccode successfully");
		print FH "STEP: C dials ACB acccode - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C dials ACB acccode - PASS\n";
    }
	
	sleep (2);
# Onhook line C
	 unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }

# Hang up line A,B
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }

# Onhook line LEA 
	unless($ses_glcas->onhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[3]");
            print FH "STEP: Onhook line $list_dn[3] - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $list_dn[3] - PASS\n";
        }

	sleep(2);
# Wait time for C ringing
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
	
# Offhook line C
	unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[2]");
		print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
	
# A ringing
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
		
# Offhook line A
	 unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_line[0]");
        print FH "STEP: offhook line A $list_line[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: offhook line A $list_line[0] - PASS\n";
    }
	
# Verify speech path between A and C
	 %input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
    }

# Check LEA D ring
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
	
# LEA D off-hook
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook LEA $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook LEA $list_dn[3] - PASS\n";
    }
	
# LEA D can monitor the call between A and C
	%input = (
                -list_port => [$list_line[0],$list_line[2]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between A and C");
        print FH "STEP: LEA can monitor the call between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between A and C - PASS\n";
    }
	
################################## Cleanup 023 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 023 ##################################");

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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /ACB/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}

# Deact LEA
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_dnbd->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
# remove ACB from line C
    if ($add_feature_lineC) {
        unless ($ses_core->callFeature(-featureName => 'ACB', -dialNumber => $list_dn[2], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove ACB from line $list_dn[2]");
            print FH "STEP: Remove ACB from line $list_dn[2] - FAIL\n";
        } else {
            print FH "STEP: Remove ACB from line $list_dn[2] - PASS\n";
        }
    }
		
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_024 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_024");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_024";
    $tcid = "ADQ1109_024";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
############################## Trunk DB #####################################
    my $trunk_access_code = $db_trunk{'g6_isup'}{-acc};
    my $trunk_region = $db_trunk{'g6_isup'}{-region};
    my $trunk_clli = $db_trunk{'g6_isup'}{-clli};
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $add_feature_lineA = 0;
	my (@list_file_name, $ID);
    my $flag = 1;
  
    ################## LOGIN ##############
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
	
    $ses_core->execCmd("forceout $li_core_user");
	
	unless ($ses_dnbd->loginCore(-username => ['tiennn'], -password => ['tiennn'])) {
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    
	# Add SURV to line C and LEA to line D 
	$ses_dnbd->execCmd("add $li_group_id YES FTPV4 047 135 041 070 021 ibn $list_dn[2] +");
	unless(grep /Please confirm/, $ses_dnbd->execCmd("10 151515 yes $lea_num yes AUTO_GRP px 515151 NONE no speech no YES yes 1")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add SURV to line C  ");
        print FH "STEP: Add SURV to line C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add SURV to line C - PASS\n";
    }
	unless(grep /Done/, @output = $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add LEA number to line D  ");
        print FH "STEP: Add LEA number to line D - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add LEA number to line D - PASS\n";
    }
	
	foreach (@output) {
        if ( $_ =~ /Monitor Order ID/ ) {
            $_ =~ /\s+(\d+)/;
			$ID = $1;
        print FH "Monitor Order ID is: $ID\n";

        }
		}
	
	#act SURV to line 
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv act $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot act SURV ");
        print FH "STEP: Act SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Act SURV - PASS\n";
    }
	
# Add CXR to line A 
    unless ($ses_core->callFeature(-featureName => "CXR CTALL N STD", -dialNumber => $list_dn[0], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add CXR for line $list_dn[0]");
		print FH "STEP: add CXR for line $list_dn[0] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add CXR for line $list_dn[0] - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# C calls A and check speech path then A Flash
    %input = (
                -lineA => $list_line[2],
                -lineB => $list_line[0],
                -dialed_number => $list_dn[0],
                -regionA => $list_region[2],
                -regionB => $list_region[0],
                -check_dial_tone => 'y',
                -digit_on => 300,
                -digit_off => 300,
                -detect => ['DELAY 2','RINGING'],
                -ring_on => [0],
                -ring_off => [0],
                -on_off_hook => ['offB'],
                -send_receive => ['TESTTONE 1000'],
                -flash => 'B'
                );
    unless ($ses_glcas->makeCall(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at C calls A and check speech path then A flash");
        print FH "STEP: C calls A and check speech path then A flash - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: C calls A and check speech path then A flash - PASS\n";
    }

# A calls B, B rings then A onhook
    %input = (
                -line_port => $list_line[0],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$sub_name: cannot detect dial tone line $list_dn[0]");
        print FH "STEP: A hears recall dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hears recall dial tone - PASS\n";
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
        print FH "STEP: A dials $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A dials $list_dn[1] - PASS\n";
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
        $logger->error(__PACKAGE__ . ".$sub_name: Line B does not ring");
        print FH "STEP: Check line B ring - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line B ring - PASS\n";
    }

	unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_dn[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }
	
# Off-hook line B 
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
	
# Check speech path bwt C&B 
    %input = (
                -list_port => [$list_line[2],$list_line[1]], 
                -checking_type => ['DIGIT'], 
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
	
# Check LEA D ring
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
	
# LEA D off-hook
	unless($ses_glcas->offhookCAS(-line_port => $list_line[3], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[3]");
        print FH "STEP: Offhook LEA $list_dn[3] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Offhook LEA $list_dn[3] - PASS\n";
    }
	
# LEA D can monitor the call between C and B
	%input = (
                -list_port => [$list_line[2],$list_line[1]],
                -cas_timeout => 20000,
                -lea_port => $list_line[3],
                ); 
    unless ($ses_glcas->detectSpeechPathOneWayLI(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed at LEA monitor the call between C and B");
        print FH "STEP: LEA can monitor the call between C and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: LEA can monitor the call between C and B - PASS\n";
    }
	
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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /CXR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}

# Deact LEA
	unless(grep /Do You want to ACT/, $ses_dnbd->execCmd("surv deact $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Deact SURV ");
        print FH "STEP: Deact SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Deact SURV - PASS\n";
    }
	
# Del LEA
	unless(grep /Delete MON ORDER ID/, $ses_dnbd->execCmd("del $ID")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
	unless(grep /Done/, $ses_dnbd->execCmd("y")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot Delete SURV ");
        print FH "STEP: Delete SURV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Delete SURV - PASS\n";
    }
	
# remove CXR from line A
    if ($add_feature_lineA) {
        unless ($ses_core->callFeature(-featureName => 'CXR', -dialNumber => $list_dn[0], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove CXR from line $list_dn[0]");
            print FH "STEP: Remove CXR from line $list_dn[0] - FAIL\n";
        } else {
            print FH "STEP: Remove CXR from line $list_dn[0] - PASS\n";
        }
    }
		
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_025 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_025");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_025";
    $tcid = "ADQ1109_025";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn}, $db_line{$tc_line{$tcid}[3]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line}, $db_line{$tc_line{$tcid}[3]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region}, $db_line{$tc_line{$tcid}[3]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len}, $db_line{$tc_line{$tcid}[3]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info}, $db_line{$tc_line{$tcid}[3]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
    my $feature_added = 0;
    my $pcm_start = 0;
	my $dialed_num;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Add CWT, CWI, CFD, CFDVT to line B
    foreach ('CFD P','CWT','CWI','CFDVT 30 FIXRING') {
        unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
            $logger->error(__PACKAGE__ . " $tcid: Cannot add $_ for line $list_dn[1]");
            print FH "STEP: Add $_ for line $list_dn[1] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Add $_ for line $list_dn[1] - PASS\n";
        }
    }
	$feature_added = 1;

# Get access code CFD 
	my $cfd_acc = $ses_core->getAccessCode(-table => 'IBNXLA', -dialNumber => $list_dn[1], -lastColumn => 'CFDP');
    unless ($cfd_acc) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot get CFD access code for line $list_dn[1]");
		print FH "STEP: Get CFD access code for line $list_dn[1] is $cfd_acc - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Get CFD access code for line $list_dn[1] is $cfd_acc - PASS\n";
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    unless(@list_file_name) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    }
    $pcm_start = 1;
	
# B off-hooks to active CFD
	unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[1]");
        print FH "STEP: Offhook line B - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASSED\n";
    }
	# Check B hears dial tone
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: Cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAILED\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASSED\n";
    }

	# Start detect Confirmation tone
	# %input = (
	# 			-line_port => $list_line[1],
	# 			-cas_timeout => 50000,
	# 			);
    # unless ($ses_glcas->startDetectConfirmationToneCAS(%input)){
    #     $logger->error(__PACKAGE__ . ".$tcid: Can't start detect ConfirmationTone $list_dn[1]");
    #     print FH "STEP: B starts detect confirmation tone - FAILED\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: B starts detect confirmation tone - PASSED\n";
    # } 

	# B dials CFD acccode 
    $dialed_num = '*'. $cfd_acc;
    %input = (
                -line_port => $list_line[1],
               	-dialed_number => $dialed_num,
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $dialed_num ");
		print FH "STEP: B dials cfd_acc to enable CFD  - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B dials cfd_acc to enable CFD  - PASSED\n";
	}

	# Stop detect Confirmation tone
	# %input = (
	# 			-line_port => $list_line[1],
	# 			-wait_for_event_time => $wait_for_event_time,
	# 			);
    # unless ($ses_glcas->stopDetectConfirmationToneCAS(%input)){
    #     $logger->error(__PACKAGE__ . ".$tcid: Can't stop detect Confirmation Tone $list_dn[1]");
    #     print FH "STEP: B detects Confirmation Tone - FAILED\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: B detects Confirmation Tone - PASSED\n";
    # }
    # sleep(3);

    %input = (
                -line_port => $list_line[1],
               	-dialed_number => "$list_dn[2]\#",
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
	
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[2] ");
		print FH "STEP: B dials $list_dn[2]# - FAILED\n";
		$result = 0;
        goto CLEANUP;
    } else {
		print FH "STEP: B dials $list_dn[2]#  - PASSED\n";
	}
	
# B on-hooks
	unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAILED\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASSED\n";
    }
	
# B calls D and check speech path B & D 
    %input = (
                -lineA => $list_line[1],
                -lineB => $list_line[3],
                -dialed_number => $list_dn[3],
                -regionA => $list_region[1],
                -regionB => $list_region[3],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at B calls D and check speech path B with D");
        print FH "STEP: B calls D 2way speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B calls D 2way speech path - PASS\n";
    }
	
# A calls B and B hears callwaiting_tone
	#off-hook line A
	%input = (
				-line_port => $list_line[0], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_dn[0]");
		print FH "STEP: Offhook line A - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_dn[0]");
		print FH "STEP: Offhook line A - PASS\n";
	}
	
    #check dial tone line A
	%input = (
				-line_port => $list_line[0], 
				-dial_tone_duration => '1000', 
				-cas_timeout => '50000',
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->detectDialToneCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not detect dial tone line $list_line[0]");
		print FH "STEP: A hears dial tone - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully detect dial tone line $list_line[1]");
		print FH "STEP: A hears dial tone - PASS\n";
	}
	
	#A dials B 
	%input = (
                -line_port => $list_line[0],
                -dialed_number => $list_dn[1],
                -digit_on => 300,
                -digit_off => 300,
                -wait_for_event_time => $wait_for_event_time
                ); 
    unless($ses_glcas->sendDigitsWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot dial $list_dn[1] successfully");
        print FH "STEP: A dials $list_dn[1] - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: A dials $list_dn[1] - PASS\n";
    }
	
	#B hears callwaiting_tone
	# %input = (
    #             -line_port => $list_line[1],
    #             -callwaiting_tone_duration => 300,
    #             -cas_timeout => 20000,
    #             -wait_for_event_time => $wait_for_event_time
    #             );
    # unless ($ses_glcas->detectCallWaitingToneCAS(%input)) {
    #     $logger->error(__PACKAGE__ . " $tcid: Failed at B hears Call waiting tone");
    #     print FH "STEP: B hears Call waiting tone - FAIL\n";
    #     $result = 0;
    #     goto CLEANUP;
    # } else {
    #     print FH "STEP: B hears Call waiting tone - PASS\n";
    # }

    # Check Ringback tone line A
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }
	
#After 30 seconds, the call is forwarded to C and Line C rings
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
	
	%input = (
				-line_port => $list_line[2], 
				-wait_for_event_time => $wait_for_event_time
			); 
    unless ($ses_glcas->offhookCAS(%input)) {
		$logger->error(__PACKAGE__ . ".$sub_name: Could not off-hook line $list_dn[2]");
		print FH "STEP: Offhook line C - FAIL\n";
		$result = 0;
		goto CLEANUP;
	} else {
		$logger->debug(__PACKAGE__ . ".$sub_name: Successfully off-hook line $list_dn[2]");
		print FH "STEP: Offhook line C - PASS\n";
	}
	
	%input = (
                -list_port => [$list_line[0],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and C");
        print FH "STEP: Check speech path between A and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and C - PASS\n";
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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /CFD|CWT|CWI|CFDVT/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}

# Remove CWT, CWI, CFD, CFDVT from line B
    if ($feature_added) {
        foreach ('CWI','CWT','CFDVT','CFD'){
            unless ($ses_core->callFeature(-featureName => $_, -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
                $logger->error(__PACKAGE__ . " $tcid: Remove $_ from line $list_dn[1]");
                print FH "STEP: Remove $_ from line $list_dn[1] - FAIL\n";
            } else {
                print FH "STEP: Remove $_ from line $list_dn[1] - PASS\n";
            }
        }
    }
	
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_026 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_026");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_026";
    $tcid = "ADQ1109_026";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
    my $calltrak_start = 0;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
	
# Data table OFCENG N 
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table OFCENG")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table OFCENG'");
    }
	
    if (grep /N/, $ses_core->execCmd("pos DISABLE_DP_RECEPTION_ON_DGT")) {
        $logger->error(__PACKAGE__ . " $tcid: can command 'pos DISABLE_DP_RECEPTION_ON_DGT'");
        print FH "STEP: Datafill tuple DISABLE_DP in table OFCENG - PASS\n";
    } else {
        print FH "STEP: Datafill tuple DISABLE_DP in table OFCENG - FAIL\n";
		if (grep /Y TO CONTINUE/, $ses_core->execCmd("change")){
			if (grep /PARMVAL/, $ses_core->execCmd("y")){
				if (grep /TUPLE TO BE CHANGED/, $ses_core->execCmd("N")){
					if (grep /TUPLE CHANGED/, $ses_core->execCmd("y")){
					$logger->error(__PACKAGE__ . " $tcid: can command change tuple");
					print FH "STEP: Change tuple DISABLE_DP_RECEPTION_ON_DGT - PASS\n";
					}else{
					print FH "STEP: Change tuple DISABLE_DP_RECEPTION_ON_DGT - FAIL\n";
					$result = 0;
					goto CLEANUP;
					}
				}
			}
		}
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
            print FH "STEP: Set region for line $list_line[$i] - FAIL\n";
            $flag = 0;
            last;
        } else {
            print FH "STEP: Set region for line $list_line[$i] - PASS\n";
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
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Call flow ###########################
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }

# A calls B and check speech path A&B  
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check speech path A with B");
        print FH "STEP: A calls B 2way speech path - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way speech path - PASS\n";
    }
	
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
	
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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        unless (grep /Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
	
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_027 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_027");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_027";
    $tcid = "ADQ1109_027";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
	my $dnh_added = 1;
	my $dialed_num;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;	
	
# Data fill table IBNXLA (dials 7+3 digits = 4 digits)
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table IBNXLA'");
    }

	if (grep /Undefined command/, $ses_core->execCmd("ove;ver off")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'ove;ver off'");
    }
    
    if (grep /TUPLE NOT FOUND/, @output = $ses_core->execCmd("rep AUTOXLA 7 EXTN N N 400 500 4 \$ \$")) {
		if (grep /TUPLE ADDED/, $ses_core->execCmd("add AUTOXLA 7 EXTN N N 400 500 4 \$ \$")) {
			$logger->error(__PACKAGE__ . " $tcid: add successfully AUTOXLA 7 EXTN N N 400 500 4");
			print FH "STEP: add AUTOXLA 7 EXTN N N 400 500 4 - PASS\n";
		}else {
			print FH "STEP: add AUTOXLA 7 EXTN N N 400 500 4 - FAIL\n";
		}
    } elsif (grep /TUPLE REPLACED/, @output){
			print FH "STEP: Rep AUTOXLA 7 EXTN N N 400 500 4 - PASS\n";
	} else {
			print FH "STEP: Rep AUTOXLA 7 EXTN N N 400 500 4 - FAIL\n";
			$result = 0;
			goto CLEANUP;
    }

	$ses_core->execCmd("abort");
	
    if (grep /N 400 500 4 \$ \$/, $ses_core->execCmd("pos AUTOXLA 7")) {
        $logger->error(__PACKAGE__ . " $tcid: can command pos AUTOXLA 7");
        print FH "STEP: Datafill tuple AUTOXLA 7 in table IBNXLA - PASS\n";
    } else {
        print FH "STEP: Datafill tuple AUTOXLA 7 in table IBNXLA - FAIL\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B by 4 digits 
	($dialed_num) = ($list_dn[1] =~ /\d{6}(\d+)/);
	$dialed_num = $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }
	
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_028 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_028");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_028";
    $tcid = "ADQ1109_028";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
	my $dnh_added = 1;
	my $dialed_num;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;	

# Data fill table IBNXLA (dials 0+4 digits = 5 digits)
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table IBNXLA'");
    }

    if (grep /Undefined command/, $ses_core->execCmd("ove;ver off")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'ove;ver off'");
    }
    
    if (grep /TUPLE NOT FOUND/, @output = $ses_core->execCmd("rep AUTOXLA 0 EXTN N N 400 500 5 \$ \$")) {
		if (grep /TUPLE ADDED/, $ses_core->execCmd("add AUTOXLA 0 EXTN N N 400 500 5 \$ \$")) {
			$logger->error(__PACKAGE__ . " $tcid: add successfully AUTOXLA 7 EXTN N N 400 500 4");
			print FH "STEP: add AUTOXLA 0 EXTN N N 400 500 5 - PASS\n";
		}else {
			print FH "STEP: add AUTOXLA 0 EXTN N N 400 500 5 - FAIL\n";
		}
    } elsif (grep /TUPLE REPLACED/, @output){
			print FH "STEP: Rep AUTOXLA 0 EXTN N N 400 500 5 - PASS\n";
	} else {
			print FH "STEP: Rep AUTOXLA 0 EXTN N N 400 500 5 - FAIL\n";
			$result = 0;
			goto CLEANUP;
    }
    
	$ses_core->execCmd("abort");
	
    if (grep /N 400 500 5 \$ \$/, $ses_core->execCmd("pos AUTOXLA 0")) {
        $logger->error(__PACKAGE__ . " $tcid: can command pos AUTOXLA 0");
        print FH "STEP: Datafill tuple AUTOXLA 0 in table IBNXLA - PASS\n";
    } else {
        print FH "STEP: Datafill tuple AUTOXLA 0 in table IBNXLA - FAIL\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B by 4 digits 
	($dialed_num) = ($list_dn[1] =~ /\d{5}(\d+)/);
	$dialed_num = $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }
	
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
	
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}
	
sub ADQ1109_029 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_029");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_029";
    $tcid = "ADQ1109_029";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
	my $dnh_added = 1;
	my $dialed_num;
	my @list_file_name;
    my $flag = 1;
  
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
        $logger->error(__PACKAGE__ . ".$sub_name: Cannot add DNH for line $list_dn[0] and $list_dn[1] ");
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add DNH for line $list_dn[0] and $list_dn[1] - PASS\n";
    }
    $dnh_added = 0;	

# Data fill table IBNXLA (dials 0+5 digits = 6 digits)
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table IBNXLA")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table IBNXLA'");
    }
	
    if (grep /Undefined command/, $ses_core->execCmd("ove;ver off")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'ove;ver off'");
    }
    
    if (grep /TUPLE NOT FOUND/, @output = $ses_core->execCmd("rep AUTOXLA 0 EXTN N N 400 500 6 \$ \$")) {
		if (grep /TUPLE ADDED/, $ses_core->execCmd("add AUTOXLA 0 EXTN N N 400 500 6 \$ \$")) {
			$logger->error(__PACKAGE__ . " $tcid: add successfully AUTOXLA 7 EXTN N N 400 500 4");
			print FH "STEP: add AUTOXLA 0 EXTN N N 400 500 6 - PASS\n";
		}else {
			print FH "STEP: add AUTOXLA 0 EXTN N N 400 500 6 - FAIL\n";
		}
    } elsif (grep /TUPLE REPLACED/, @output){
			print FH "STEP: Rep AUTOXLA 0 EXTN N N 400 500 6 - PASS\n";
	} else {
			print FH "STEP: Rep AUTOXLA 0 EXTN N N 400 500 6 - FAIL\n";
			$result = 0;
			goto CLEANUP;
    }
    
	$ses_core->execCmd("abort");
	
    if (grep /N 400 500 6 \$ \$/, $ses_core->execCmd("pos AUTOXLA 0")) {
        $logger->error(__PACKAGE__ . " $tcid: can command pos AUTOXLA 0");
        print FH "STEP: Datafill tuple AUTOXLA 0 in table IBNXLA - PASS\n";
    } else {
        print FH "STEP: Datafill tuple AUTOXLA 0 in table IBNXLA - FAIL\n";
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B by 4 digits 
	($dialed_num) = ($list_dn[1] =~ /\d{4}(\d+)/);
	$dialed_num = $dialed_num;
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $dialed_num,
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }
	
	foreach (@list_line[0..1]) {
        unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
            $logger->error(__PACKAGE__ . ": Cannot onhook line $_");
            print FH "STEP: Onhook line $_ - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Onhook line $_ - PASS\n";
        }
    }
	
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
	
# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        if (grep /DNH/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
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
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_030 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_030");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_030";
    $tcid = "ADQ1109_030";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
	my (@list_file_name, @output, $slot_active, $slot_standby); 
    my $flag = 1;
  
    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();
	
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B and check speech path 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }

#Reboot DS512 card active 
	$ses_g604->{conn}->prompt('/Completed/');
	@output = $ses_g604->execCmd("show card 13,14");
    foreach(@output){
        if(/(\d{2}).*enabled.*ACTIVE\s+\|/){
            $slot_active = $1;
        }
    }
	
	$ses_g604->{conn}->prompt('/Are/'); 
    if (grep /WARNING/, $ses_g604->execCmd("reboot slot $slot_active")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active - PASS\n";
	}else {
		print FH "STEP: Reboot slot $slot_active - FAIL\n";
	}
	
	if (grep /least one port INS/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_active - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/\>/');
	if (grep /Command Completed/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active successfully - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_active successfully - FAIL\n";
	}
	sleep (5);
	
#Reboot card standby (when reboot active card > standby card Card Protection Switch to active card)
	$ses_g604->execCmd("q");
	
	$ses_g604->{conn}->prompt('/Completed/');
	@output = $ses_g604->execCmd("show card 13,14");
    foreach(@output){
		if($_ =~ /(\d{2}).*enabled.*ACTIVE\s+\|/){
            $slot_standby = $1;
        }
    }
	
	$ses_g604->{conn}->prompt('/Are/'); 
    if (grep /WARNING/, $ses_g604->execCmd("reboot slot $slot_standby")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_standby");
		print FH "STEP: Reboot slot $slot_standby - PASS\n";
	}else {
		print FH "STEP: Reboot slot $slot_standby - FAIL\n";
	}
	
	if (grep /least one port INS/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_standby");
		print FH "STEP: Reboot slot $slot_standby - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_standby - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/\>/');
	if (grep /Command Completed/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_standby");
		print FH "STEP: Reboot slot $slot_standby successfully - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_standby successfully - FAIL\n";
	}
	
#Check A & B is LMB
	unless (grep /\sLMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")){
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not SB status");
			print FH "STEP: Check A is SB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
		print FH "STEP: Check A is SB status - PASSED\n";
	}	
	
	unless (grep /\sLMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")){
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[1] is not SB status");
			print FH "STEP: Check B is SB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
		print FH "STEP: Check B is SB status - PASSED\n";
	}
	
# Hang up A & B
	foreach (@list_line[0..1]) {
			unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
				$logger->error(__PACKAGE__ . ": Cannot onhook line $_");
				print FH "STEP: Onhook line $_ - FAIL\n";
				$result = 0;
			} else {
				print FH "STEP: Onhook line $_ - PASS\n";
			}
		}
	sleep (5);
	
#Check line recovery
    foreach(1..10){
        unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")){
		    $logger->error(__PACKAGE__ . ".$tcid: Waiting for line $list_dn[0] back to IDL");
	    } else {
		    print FH "STEP: Check A is back to IDL status - PASSED\n";
	    }	
	
	    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")){
		    $logger->error(__PACKAGE__ . ".$tcid: Waiting for line $list_dn[1] back to IDL");
	    } else {
		    print FH "STEP: Check B is back to IDL status - PASSED\n";
            goto CHECK;
	    }
        sleep(40);
    }

# Make new the call: A calls B and check speech path 
CHECK:
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed new the call at A calls B and check sp");
        print FH "STEP: New the call A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New the call A calls B 2way sp - PASS\n";
    }
	
#Hang up A&B
	foreach (@list_line[0..1]) {
			unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
				$logger->error(__PACKAGE__ . ": Cannot onhook line $_");
				print FH "STEP: Onhook line $_ - FAIL\n";
				$result = 0;
			} else {
				print FH "STEP: Onhook line $_ - PASS\n";
			}
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

# Get PCM trace
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_031 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_031");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_031";
    $tcid = "ADQ1109_031";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
    my $wait_for_event_time = 30;
    my $initialize_done = 0;
    my $logutil_start = 0;
	my $line_A = 0;
	my $line_B = 0;
	my (@list_file_name, @output, $slot_active, $slot_standby); 
    my $flag = 1;
  
    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();
	
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
    # start PCM trace
    # my @list_file_name = $ses_glcas->recordSessionCAS(-list_port => [@list_line], -home_directory => "C:\\");
    # unless(@list_file_name) {
    #     $logger->error(__PACKAGE__ . ".$tcid: cannot start record PCM");
    # }
	
# A calls B and check speech path 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }

#Lock card standby 
	$ses_g604->{conn}->prompt('/Completed/');
	@output = $ses_g604->execCmd("show card 13,14");
    foreach(@output){
        if($_ =~ /(\d{2}).*enabled.*STANDBY\s+\|/){
            $slot_standby = $1;
        }
    }
	
	$ses_g604->{conn}->prompt('/Are/');
	if (grep /least one port INS/, $ses_g604->execCmd("lock card $slot_standby")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd lock card $slot_standby");
		print FH "STEP: Lock card $slot_standby - PASS\n";
	}else {
		print FH "STEP: Lock card $slot_standby - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/\>/');
	if (grep /Command Completed/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd lock card $slot_standby");
		print FH "STEP: Lock card $slot_standby successfully - PASS\n";
	}else{
		print FH "STEP: Lock card $slot_standby successfully - FAIL\n";
	}
	
#Reboot DS512 card active 
	$ses_g604->{conn}->prompt('/Completed/');
	@output = $ses_g604->execCmd("show card 13,14");
    foreach(@output){
        if($_ =~ /(\d{2}).*enabled.*ACTIVE\s+\|/){
            $slot_active = $1;
        }
    }
	
	$ses_g604->execCmd("q");
	$ses_g604->{conn}->prompt('/Are/'); 
    if (grep /WARNING/, $ses_g604->execCmd("reboot slot $slot_active")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active - PASS\n";
	}else {
		print FH "STEP: Reboot slot $slot_active - FAIL\n";
	}
	
	if (grep /least one port INS/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_active - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/\>/');
	if (grep /Command Completed/, $ses_g604->execCmd("y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd reboot slot $slot_active");
		print FH "STEP: Reboot slot $slot_active successfully - PASS\n";
	}else{
		print FH "STEP: Reboot slot $slot_active successfully - FAIL\n";
	}
	sleep (5);
	
#Check A & B is LMB
	unless (grep /\sLMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not SB status");
			print FH "STEP: Check A is SB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
		print FH "STEP: Check A is SB status - PASSED\n";
	}	
	
	unless (grep /\sLMB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[1] is not SB status");
			print FH "STEP: Check B is SB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
		print FH "STEP: Check B is SB status - PASSED\n";
	}
	
# Hang up A & B
	foreach (@list_line[0..1]) {
			unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
				$logger->error(__PACKAGE__ . ": Cannot onhook line $_");
				print FH "STEP: Onhook line $_ - FAIL\n";
				$result = 0;
			} else {
				print FH "STEP: Onhook line $_ - PASS\n";
			}
		}
	sleep (15);
	
# Unlock card standby
	$ses_g604->execCmd("q");
	$ses_g604->{conn}->prompt('/Completed/');
	@output = $ses_g604->execCmd("show card 13,14");
    foreach(@output){
        if($_ =~ /(\d{2}).*disabled/){
            $slot_standby = $1;
        }
    }
	
	$ses_g604->{conn}->prompt('/Completed/');
	if (grep /Successfully unlocked ABI card/, $ses_g604->execCmd("unlock card $slot_standby")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd unlock card $slot_standby");
		print FH "STEP: Unlock card $slot_standby successfully - PASS\n";
	}else{
		print FH "STEP: Unlock card $slot_standby successfully - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/CLI.*\>/');
	
#Check line recovery
    foreach(1..10){
        unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print")){
		    $logger->error(__PACKAGE__ . ".$tcid: Waiting for line $list_dn[0] back to IDL");
	    } else {
		    print FH "STEP: Check A is back to IDL status - PASSED\n";
			$line_A = 1;
	    }	
	
	    unless (grep /\sIDL\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print")){
		    $logger->error(__PACKAGE__ . ".$tcid: Waiting for line $list_dn[1] back to IDL");
	    } else {
		    print FH "STEP: Check B is back to IDL status - PASSED\n";
			$line_B = 1;
            goto CHECK;
	    }
        sleep(40);
    }
	
	unless ($line_A*$line_B) {
		$logger->error(__PACKAGE__ . ".$tcid: Line could not back to IDL");
		print FH "STEP: Line could not back to IDL - FAIL\n";
	}
	
	

# Make new the call: A calls B and check speech path 
CHECK:
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed new the call at A calls B and check sp");
        print FH "STEP: New the call A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New the call A calls B 2way sp - PASS\n";
    }
	
#Hang up A & B
	foreach (@list_line[0..1]) {
			unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
				$logger->error(__PACKAGE__ . ": Cannot onhook line $_");
				print FH "STEP: Onhook line $_ - FAIL\n";
				$result = 0;
			} else {
				print FH "STEP: Onhook line $_ - PASS\n";
			}
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
    # if ($pcm_start){
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
	# }
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

=head
sub ADQ1109_032 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_032");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_032";
    $tcid = "ADQ1109_032";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

	my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});
	
	my $wait_for_event_time = 30;
	my $initialize_done = 0;
    my $logutil_start = 0;
	my $ses_core1;
	my @log;
	my $flag = 1;
	
    ################## LOGIN ##################
    my $thr1 = threads->create(\&core);
	my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	
    $ses_core = $thr1->join();
	$ses_glcas = $thr2 -> join();
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
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
 
#Initialize Call
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
        
#Start logutil 	
	%input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
##################### Core flow ###########################
#A calls B and check speech path 
    %input = (
                -lineA => $list_line[0],
                -lineB => $list_line[1],
                -dialed_number => $list_dn[1],
                -regionA => $list_region[0],
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
        $logger->error(__PACKAGE__ . " $tcid: Failed at A calls B and check sp");
        print FH "STEP: A calls B 2way sp - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A calls B 2way sp - PASS\n";
    }

#Do VCA REX 
	unless ($ses_core1 = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{"c20:1:ce0"}, -sessionLog => $tcid."_CoreSessionLog1")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not create C20 object for tms_alias => $TESTBED{'c20:1:ce0'}" );
        print FH "STEP: Login TMA20 CLI - FAIL\n";
        return 0;
    } else {
        print FH "STEP: Login TMA20 CLI - PASS\n";
    }
    
	$ses_core1->{conn}->prompt('/\>/');
	$ses_core1->execCmd("cli");
	
	if (grep /%Warning/, $ses_core1->execCmd("sosAgent vca rex VCA")) {
		$logger->error(__PACKAGE__ . " $tcid: Can execCmd sosAgent vca rex VCA");
	}
	@log = $ses_core1->execCmd("y", 1050);
	$logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@log));
	
    if(grep /Passed/, @log){
        print FH "STEP: sosAgent vca rex VCA - PASS\n"; 
    } else {
        print FH "STEP: sosAgent vca rex VCA - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
	
#Check A&B is CPB
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[0] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[0] is not CPB status");
			print FH "STEP: Check A is CPB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
			print FH "STEP: Check A is CPB status - PASSED\n";
	}	
	
	unless (grep /\sCPB\s/, $ses_core->execCmd("mapci nodisp; mtc; lns; ltp; post d $list_dn[1] print"))
	{
		$logger->error(__PACKAGE__ . ".$tcid: Line $list_dn[1] is not CPB status");
			print FH "STEP: Check B is CPB status - FAILED\n";
			$result = 0;
			goto CLEANUP;
	} else {
			print FH "STEP: Check B is CPB status - PASSED\n";
	}
	
#Hang up A&B
	foreach (@list_line[0..1]) {
			unless($ses_glcas->onhookCAS(-line_port => $_, -wait_for_event_time => $wait_for_event_time)) {
				$logger->error(__PACKAGE__ . ": Cannot onhook line $_");
				print FH "STEP: Onhook line $_ - FAIL\n";
				$result = 0;
			} else {
				print FH "STEP: Onhook line $_ - PASS\n";
			}
		}
	sleep (2);
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result); 
}	
=cut

sub ADQ1109_033 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_033");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_033";
    $tcid = "ADQ1109_033";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $logutil_start = 0;
	my @output;
	
    ################## LOGIN ##################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();
		
############### Test Specific configuration & Test Tool Script Execution #################
    
# Start logutil 	
	%input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### G6 flow ###########################
  
#Lock port 7 5 
	$ses_g604->{conn}->prompt('/Interface/');
	if (grep /Successfully locked DS1 port|Already locked DS1 port/, @output = $ses_g604->execCmd("lock port 7 5")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd lock port 7 5");
		print FH "STEP: lock port 7 5 - PASS\n";
	}else {
		print FH "STEP: lock port 7 5 - FAIL\n";
		$result = 0;
        goto CLEANUP;
	}
	sleep (2);
	
#Verify alarm raise after lock	
	if (grep /Manual Lock/, @output){
		$logger->error(__PACKAGE__ . ".$tcid: Can verify alarm lock");
		print FH "STEP: Verify alarm lock - PASS\n";
	}else {
		print FH "STEP: Verify alarm lock - FAIL\n";
	}
	
#Set ig e1cas idt portmap 7 5 dialpulsesupp y
	$ses_g604->{conn}->prompt('/Command Completed/');
	if (grep /Successfully modified IG portmap/, $ses_g604->execCmd("set ig e1cas idt portmap 7 5 dialpulsesupp y")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd set ig e1cas idt portmap 7 5 dialpulsesupp y");
		print FH "STEP: set ig e1cas idt portmap 7 5 dialpulsesupp y - PASS\n";
	}else{
		print FH "STEP: set ig e1cas idt portmap 7 5 dialpulsesupp y - FAIL\n";
	}
	
#Unlock port 7 5
	$ses_g604->{conn}->prompt('/Interface/');
	if (grep /Successfully unlocked DS1 port/, @output = $ses_g604->execCmd("unlock port 7 5")){
		$logger->error(__PACKAGE__ . ".$tcid: Can execCmd unlock port 7 5");
		print FH "STEP: unlock port 7 5 - PASS\n";
	}else {
		print FH "STEP: unlock port 7 5 - FAIL\n";
	}
	sleep (2);
	
#Verify alarm raise after unlock
	if (grep /Manual Unlock/, @output){
		$logger->error(__PACKAGE__ . ".$tcid: Can verify alarm unlock");
		print FH "STEP: Verify alarm unlock - PASS\n";
	}else {
		print FH "STEP: Verify alarm unlock - FAIL\n";
	}
	
	$ses_g604->{conn}->prompt('/\>/');
	
################################## Cleanup 033 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 033 ##################################");
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_034 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_034");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_034";
    $tcid = "ADQ1109_034";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $logutil_start = 0;
	my @output;
	
    ################## LOGIN ##################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();
	
	unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
	
############### Test Specific configuration & Test Tool Script Execution #################
    
# Start logutil 	
	%input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	
###################### Core flow ###########################
  
#Post ABI mode GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post gpp 1;abi")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Tst plane port 0 & port 1
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post gpp 1;abi print");
	unless (grep /Passed/, $ses_core->execCmd("tst 0 port 0")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'tst'");
        print FH "STEP: Execute command 'tst' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'tst' - PASS\n";
    }
	
	unless (grep /Passed/, $ses_core->execCmd("tst 1 port 0")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'tst'");
        print FH "STEP: Execute command 'tst' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'tst' - PASS\n";
    }

################################## Cleanup 034 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 034 ##################################");
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_035 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_035");
    
########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_035";
    $tcid = "ADQ1109_035";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");
	
    my $logutil_start = 0;
	my @output;
	
    ################## LOGIN ##################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);

    $ses_core = $thr1->join();
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
        
# Start logutil 	
	%input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Cannot start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
	 
#Change data of table (SX05 -> MX77)
	if (grep /UNKNOWN TABLE/, $ses_core->execCmd("table LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: cannot command 'table LTCINV'");
    }
	
	if (grep /GPP\s+1/, $ses_core->execCmd("pos GPP 1")){
		$logger->error(__PACKAGE__ . " $tcid: pos GPP 1 successfully");
		print FH "STEP: pos GPP 1 - PASS\n";
	}else{
		print FH "STEP: pos GPP 1 - FAIL\n";
		$result = 0;
        goto CLEANUP;
	}

    $ses_core->execCmd("ove;ver off");
	$ses_core->execCmd("rep GPP 1 1842 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("4 26 4 27 4 28 4 29 \$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ +");
    @output = $ses_core->execCmd("NZLGC MX77AA \$ MX77AA \$ 0 SXFWAL01 EXTDS512 HOST ABI 2 \$ 6X40FB N");
    if (grep/ERROR/, @output) {
        print FH "STEP: Verify warning error - PASS\n";
	} else {
		print FH "STEP: Verify warning error - FAIL\n";
		$result = 0;
        goto CLEANUP;
	}
	
################################## Cleanup 035 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 035 ##################################");
	
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
        unless ((grep /Log empty/, @output) or grep /MTCMAINP|SYSAUDP|USRSYSMG|CALLP|TDLDPR|CXNADDRV|TPCIPPR|NBDAUDIT|MTCAUXP|TPCIPPR/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
	}
		
	close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);    
}

sub ADQ1109_036 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_036");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_036";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, $card_active, @output);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
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
# A calls B and hears ringback then B ring
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
    
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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
# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# Find active card by using command show card
    $ses_g604->{conn}->prompt('/Command Completed/');
    unless (@output = $ses_g604->execCmd("show card 13,14")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'show card 13,14'");
        $logger->error(__PACKAGE__ . " $tcid: AAAAAAAAAAAAAAAAAAAAA".Dumper(\@output));
        print FH "STEP: Execute command 'show card 13,14' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'show card 13,14' - PASS\n";
    }
    foreach(@output){
        if($_ =~ /(\d+)\s+\|\s+DS512.*ACTIVE/){
            $card_active = $1;
        }
    }

# Switchover card by cmd: set tpm ds512card pg <active card> switchover
    $ses_g604->{conn}->print("set tpm ds512card pg $card_active switchover\n");
    unless ($ses_g604->{conn}->waitfor(-match => '/Are you sure?/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command switchover");
        print FH "STEP: Execute command switchover - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command switchover - PASS\n";
    }

    $ses_g604->{conn}->print("y\n");
    unless ($ses_g604->{conn}->waitfor(-match => '/Command Completed/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'y'");
        print FH "STEP: Execute command 'y' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'y' - PASS\n";
    }

# Check speech path between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_037 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_037");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_037";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @output_1, $master_port, $card);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
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
    
# A calls B and hears ringback then B ring
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
    
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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
# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# Switchover port by cmd: set tpm ds512port 14 <master port> switchover
    $ses_g604->{conn}->prompt('/.*Command Completed.*/');
    @output_1 = $ses_g604->execCmd("sho port 13 all");
    $logger->error(__PACKAGE__ . ".$tcid: ".Dumper(\@output_1));
    foreach(@output_1){
        if($_ =~ /\b(\d{1})\b.*master.*13/){
            $master_port = $1;
            $card = 13;
        }
    }
    @output_1 = $ses_g604->execCmd("sho port 14 all");
    foreach(@output_1){
        if($_ =~ /\b(\d{1})\b.*master.*13/){
            $master_port = $1;
            $card = 14;
        }
    }
    $ses_g604->{conn}->prompt('/Are you sure/');
    unless (grep /Command Initiated/, $ses_g604->execCmd("set tpm ds512port $card $master_port switchover")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot set card $card port $master_port switchover");
        print FH "STEP: execCmd set tpm $card $master_port switchover - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd set tpm $card $master_port switchover- PASS\n";
    }
    $ses_g604->execCmd("y");

# Check speech path between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }

################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_038 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_038");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_038";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, @output);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
	my $thr4 = threads->create(\&g604);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();
	$ses_g604 = $thr4->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
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
    
# A calls B and hears ringback then B ring
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
    
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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
# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }

# lock IG 2
    $ses_g604->{conn}->prompt('/Are you sure/');
    unless (grep /Command Initiated/, $ses_g604->execCmd("lock ig abi 2")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot execCmd 'lock ig abi 2'");
        print FH "STEP: execCmd 'lock ig abi 2' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: execCmd 'lock ig abi 2' - PASS\n";
    }
    $ses_g604->{conn}->print("y");
    $ses_g604->{conn}->waitfor(-match => '//', -timeout => 100);
    $ses_g604->{conn}->prompt('/.*[%\}\|\>\]].*$/');
    sleep(20);

# Verify status of A and B are LMB
    unless (grep /LMB/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[0]");
        print FH "STEP: Check line status LMB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line status LMB - PASS\n";
    }
    unless (grep /LMB/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[1] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[1]");
        print FH "STEP: Check line status LMB - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line status LMB - PASS\n";
    }

# Unlock IG 2
    $logger->debug(__PACKAGE__ . ".$tcid: unlock ig abi 2");
    $ses_g604->{conn}->prompt('/Command Completed/');
    @output = $ses_g604->execCmd("unlock ig abi 2");
    sleep (100);
    unless (grep /Successfully/, @output){
        $logger->error(__PACKAGE__ . ".$tcid: cannot unlock ig abi 2");
        print FH "STEP: unlock ig abi 2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: unlock ig abi 2 - PASS\n";
    }
    $ses_g604->{conn}->prompt('/.*[%\}\|\>\]].*$/');
    sleep(120);

# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
# Verify status of A and B are IDL
    unless (grep /IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[0]");
        print FH "STEP: Check line status IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line status IDL - PASS\n";
    }
    unless (grep /IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[1] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[1]");
        print FH "STEP: Check line status IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line status IDL - PASS\n";
    }
################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_039 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_039");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_039";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my $add_feature_lineB = 0;
    my (@list_file_name, $dialed_num,$active);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# Add 3WC for line B
        unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: add 3WC for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[1] - PASS\n";
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

# Offhook line A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }

# A hears dial tone
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

# A dials DN line B
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

# A hears ringback tone
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }

# B hears Ringing signal
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
# B answers
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
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# B flashes
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: Flash hook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Flash hook line B - PASS\n";
    }
# B hears Dial tone
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
    }
# B dials DN line C
    $dialed_num = $list_dn[2];
    %input = (
                -line_port => $list_line[1],
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
# B hears Ringback tone
    %input = (
                -line_port => $list_line[1], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[1]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }
# C hear Ringing signal
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
# C answers
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
# Check speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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
# B flashes again
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: Flash hook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Flash hook line B - PASS\n";
    }
# Check speech path between A B and C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A B and C");
        print FH "STEP: Check speech path between A B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A B and C - PASS\n";
    }
# Warm Swact GWC 4
    $ses_core->{conn}->prompt('/\>/');
    @output = $ses_core->{conn}->print("logout");
    $ses_core->{conn}->waitfor(-match => '/CI/', -timeout => 10);
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/');
    unless ($ses_core->warmSwactGWC(-gwc_id => 4, -timeout => 120)){
    	$logger->error(__PACKAGE__ . "$tcid: cannot execCmd 'aim service-unit swact gwc4 '");
        print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
    	print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - PASS\n";
    }
 
# Check speech path between A B and C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A B and C");
        print FH "STEP: Check speech path between A B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A B and C - PASS\n";
    }
# Onhook A B and C
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }

################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

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
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }
    # Remove 3WC from line B
    unless ($add_feature_lineB) {
        unless ($ses_core->callFeature(-featureName => '3WC', -dialNumber => $list_dn[1], -deleteFeature => 'Yes')) {
            $logger->error(__PACKAGE__ . " $tcid: Remove 3WC from line $list_dn[1]");
            print FH "STEP: Remove 3WC from line $list_dn[1] - FAIL\n";
        } else {
            print FH "STEP: Remove 3WC from line $list_dn[1] - PASS\n";
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
        unless (grep /VSNWC13DC/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}


sub ADQ1109_040 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_040");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_040";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn}, $db_line{$tc_line{$tcid}[2]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line}, $db_line{$tc_line{$tcid}[2]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region}, $db_line{$tc_line{$tcid}[2]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len}, $db_line{$tc_line{$tcid}[2]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info}, $db_line{$tc_line{$tcid}[2]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my $add_feature_lineB = 0;
    my (@list_file_name, $dialed_num);
    my $active_unit;
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# Add 3WC for line B
        unless ($ses_core->callFeature(-featureName => "3WC", -dialNumber => $list_dn[1], -deleteFeature => 'No')) {
		$logger->error(__PACKAGE__ . " $tcid: Cannot add 3WC for line $list_dn[1]");
		print FH "STEP: add 3WC for line $list_dn[1] - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: add 3WC for line $list_dn[1] - PASS\n";
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
# Offhook line A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
# A hears dial tone
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
# A dials DN line B
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

# A hears ringback tone
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }

# B hears Ringing signal
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
# B answers
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
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# B flashes
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: Flash hook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Flash hook line B - PASS\n";
    }
# B hears Dial tone
    %input = (
                -line_port => $list_line[1],
                -dial_tone_duration => 1000,
                -cas_timeout => 50000,
                -wait_for_event_time => $wait_for_event_time
                );
    unless ($ses_glcas->detectDialToneCAS(%input)){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect dial tone line $list_dn[1]");
        print FH "STEP: B hears dial tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: B hears dial tone - PASS\n";
    }
# B dials DN line C
    $dialed_num = $list_dn[2];
    %input = (
                -line_port => $list_line[1],
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
# B hears Ringback tone
    %input = (
                -line_port => $list_line[1], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[1]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }
# C hear Ringing signal
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
# C answers
    unless($ses_glcas->offhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[2]");
        print FH "STEP: Offhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line C - PASS\n";
    }
# Check speech path between B and C
    %input = (
                -list_port => [$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
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
# B flashes again
    %input = (
                -line_port => $list_line[1], 
                -flash_duration => 600, 
                -wait_for_event_time => $wait_for_event_time
             ); 
    unless($ses_glcas->flashWithDurationCAS(%input)) {
        $logger->error(__PACKAGE__ . ": Cannot flash hook line $list_line[1]");
        print FH "STEP: Flash hook line B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Flash hook line B - PASS\n";
    }
# Check speech path between A B and C
    %input = (
                -list_port => [$list_line[0],$list_line[1],$list_line[2]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A B and C");
        print FH "STEP: Check speech path between A B and C - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A B and C - PASS\n";
    }

# Cold Swact GWC 4
    $ses_core->{conn}->prompt('/\>/');
    @output = $ses_core->{conn}->print("logout");
    $ses_core->{conn}->waitfor(-match => '/CI/', -timeout => 10);
    @output = $ses_core->{conn}->print("cli");
    $ses_core->{conn}->waitfor(-match => '/cli/', -timeout => 10);
    @output = $ses_core->execCmd("aim si-assignment show gwc4");
    unless(@output) {
        $logger->error(__PACKAGE__ . ".$tcid: Cannot command 'aim si-assignment show gwc4'");
        $logger->debug(__PACKAGE__ . ".$tcid: <-- Leaving Sub [0]");
        return 0;
    }
    $ses_core->execCmd("gwc gwc-sg-mtce cold-swact gwc4");
    $ses_core->execCmd("y");
    $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/cli/', -timeout => 200)){
        $logger->error(__PACKAGE__ . "$tcid: cannot execCmd 'gwc gwc-sg-mtce cold-swact gwc4 '");
        print FH "\nSTEP: Execute command 'gwc gwc-sg-mtce cold-swact gwc4 ' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
     	print FH "\nSTEP: Execute command 'gwc gwc-sg-mtce cold-swact gwc4' - PASS\n";
    }
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/');
    $ses_core->execCmd("sh");
    sleep (200);
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }
# Onhook A B and C
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
    unless($ses_glcas->onhookCAS(-line_port => $list_line[2], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[2]");
        print FH "STEP: Onhook line C - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line C - PASS\n";
    }
# Check line status A B and C
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
    unless (grep /IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[2] print")){
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect status of line $list_dn[2]");
        print FH "STEP: Check line C status IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check line C status IDL - PASS\n";
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
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_041 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_041");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_041";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num, $card_active, @output);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
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
# A calls B and hears ringback then B ring
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
    
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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
# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Warm Swact Core by cmd: restart warm active
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
    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }  
# Check speech path between A and B
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
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

    # #Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

    # Stop Logutil
    # if ($logutil_start) {
    #     unless ($ses_logutil->stopLogutil()) {
    #         $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
    #     }
    #     @output = $ses_logutil->execCmd("open trap");
    #     unless (grep /Log empty/, @output) {
    #         $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
    #         $result = 0;
    #         print FH "STEP: Check Trap - FAIL\n";
    #     } else {
    #         print FH "STEP: Check trap - PASS\n";
    #     }
    #     @output = $ses_logutil->execCmd("open swerr");
    #     unless (grep /Log empty/, @output) {
    #         $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
    #         $result = 0;
    #         print FH "STEP: Check SWERR - FAIL\n";
    #     } else {
    #         print FH "STEP: Check SWERR - PASS\n";
    #     }
    # }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}
sub ADQ1109_042 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_042");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_042";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my (@list_file_name, $dialed_num);
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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
# A offhook
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
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
# A calls B and hears ringback then B ring
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }
    
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
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
# B answers and check speech path between A and B
    unless($ses_glcas->offhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot offhook line $list_dn[1]");
        print FH "STEP: Offhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line B - PASS\n";
    }
    %input = (
                -list_port => [$list_line[0],$list_line[1]], 
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
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
# Onhook A and B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
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

    # #Get PCM trace
    # %input = (
    #         -remoteip => $cas_server[0],
    #         -remoteuser => $sftp_user,
    #         -remotepasswd => $sftp_pass,
    #         -localDir => '/home/ylethingoc/PCM',
    #         -remoteFilePath => [@list_file_name]
    #         );
    # if (@list_file_name) {
    #     unless(&SonusQA::Utils::sftpFromRemote(%input)) {
    #         $logger->error(__PACKAGE__ . ": ERROR COPYING FILES to the local machine");
    #     }
    # }

    # Stop Logutil
    # if ($logutil_start) {
    #     unless ($ses_logutil->stopLogutil()) {
    #         $logger->error(__PACKAGE__ . " $tcid: Cannot stop logutil ");
    #     }
    #     @output = $ses_logutil->execCmd("open trap");
    #     unless (grep /Log empty/, @output) {
    #         $logger->error(__PACKAGE__ . " $tcid: Trap is generated on core ");
    #         $result = 0;
    #         print FH "STEP: Check Trap - FAIL\n";
    #     } else {
    #         print FH "STEP: Check trap - PASS\n";
    #     }
    #     @output = $ses_logutil->execCmd("open swerr");
    #     unless (grep /Log empty/, @output) {
    #         $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
    #         $result = 0;
    #         print FH "STEP: Check SWERR - FAIL\n";
    #     } else {
    #         print FH "STEP: Check SWERR - PASS\n";
    #     }
    # }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}


sub ADQ1109_043 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_043");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_043";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
#Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }
#Delete GPP ABI in table LTCINV without removing in table GPPTRNSL
    if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP 1")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE DELETED/, @output) {
         @output = $ses_core->execCmd("y");
    }
    unless (grep/Tuple corresponding to GPP  1 is found in table GPPTRNSL/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to check Error 'Table LTCINV still references table GPPTRNSL'");
        print FH "STEP: Check Error 'Table LTCINV still references table GPPTRNSL' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Check Error 'Table LTCINV still references table GPPTRNSL' - PASS\n";
    }
################################## Cleanup 043 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 043 ##################################");
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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}  

sub ADQ1109_044 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_044");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_044";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my $gatwyinv = 0;
    my $ltcinv = 0;
    my $ltcpsinv = 0;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
#Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI 11 G6ABI \$ 10 250 160 70 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 1 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }
#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }
#New GPP ABI in table LTCINV
    $ses_core->execCmd("add GPP 11 1843 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI 11 \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }
#Access TABLE LTCPSINV
    unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        print FH "STEP: Access TABLE LTCPSINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCPSINV - PASS\n";
    }
#New GPP ABI in table LTCPSINV    
    $ses_core->execCmd("rep GPP 11 Y 0 D30 V52 N 1 D30 V52 N 2 D30 V52 N +");
    $ses_core->execCmd("3 D30 V52 N 4 D30 V52 N 5 D30 V52 N 6 D30 V52 N +");
    @output = $ses_core->execCmd("11 D30 V52 N 12 D30 V52 N 13 D30 V52 N 14 D30 V52 N + 15 D30 V52 N \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE REPLACED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE REPLACED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to change pside link in TABLE LTCPSINV");
        print FH "STEP: Change pside link in TABLE LTCPSINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Change pside link in TABLE LTCPSINV - PASS\n";
        $ltcpsinv = 1;
    }

#Delete GPP ABI in table LTCINV without removing in table LTCPSINV
    if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP 11")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE DELETED/, @output) {
         @output = $ses_core->execCmd("y");
    }
    unless(grep/Delete Pslinks prior to deleting node/, @output) { 
        print FH "STEP: Check Error 'Delete Pslinks prior to deleting node' - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Fail to check Error 'Delete Pslinks prior to deleting node");
        print FH "STEP: Check Error 'Delete Pslinks prior to deleting node' - FAIL\n";
        $result = 0;
    }


################################## Cleanup 009 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");
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
    #Change tuple in table LTCPSINV
    if ($ltcpsinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP 11 Y  0 NILTYPE 1 NILTYPE 2 NILTYPE +");
        $ses_core->execCmd("3 NILTYPE 4 NILTYPE 5 NILTYPE 6 NILTYPE 7 NILTYPE +");
        $ses_core->execCmd("8 NILTYPE 9 NILTYPE 10 NILTYPE 11 NILTYPE 12 NILTYPE +");
        @output = $ses_core->execCmd("13 NILTYPE 14 NILTYPE 15 NILTYPE \$");
        if (grep/DMOS NOT ALLOWED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to change tuple in TABLE LTCPSINV");
            print FH "STEP: Delete GPP in TABLE LTCPSINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCPSINV - PASS\n";
        }
    }
    #Delete GPP in TABLE LTCINV
    if ($ltcinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP 11")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }
    #Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI 11")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_045 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_045");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_045";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
#Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }
#Execute command next;next
    $ses_core->{conn}->print("quit all");
    if($ses_core->{conn}->waitfor(-match => '/CI/', -timeout => 10)){
            print FH "STEP: Go to CLI - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Go to CI - FAIL" );
        print FH "STEP: Go to CI - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }
#Entering command ProtSw
    unless(grep /No action taken/,$ses_core->execCmd("ProtSw 1 2")){
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'ProtSw 1 2'");
        print FH "STEP: Execute command 'ProtSw 1 2' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'ProtSw 1 2' - PASS\n";
    }
################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");
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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_046 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_046");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_046";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $i;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
#Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
#Post GPP into MAPCI PM level
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post GPP 1")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Check GPP is InSv or not
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post GPP 1");
    unless (grep/PM is InSv||PM is ISTb/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: GPP 1 is not in properly state");
        print FH "STEP: Check GPP 1 is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check GPP 1 is InSv - PASS\n";
    }  

#Execute command abi
    unless (grep/ABI/, $ses_core->execCmd("abi")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'abi'");
        print FH "STEP: Execute command 'abi' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'abi' - PASS\n";
    }
#Busy - return Plane 0 & 1
    for($i = 0; $i < 2; $i++){
        if (grep/M/, @output = $ses_core->execCmd("mapci nodisp;mtc;pm;post GPP 1;abi;bsy $i port 0")) {
            print FH "STEP: Execute command 'bsy $i port 0' - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'bsy $i port 0'");
            print FH "STEP: Execute command 'bsy $i port 0' - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
        $ses_core->{conn}->print("mapci nodisp;mtc;pm;post GPP 1;abi;rts $i port 0");
        if($ses_core->{conn}->waitfor(-match => '/./', -timeout => 10)){
            print FH "STEP: Execute command 'rts $i port 0' - PASS\n"; 
        } else {
        $logger->error(__PACKAGE__ . " $tcid: rts $i port 0 - FAIL" );
        print FH "STEP: Execute command 'rts $i port 0' - FAIL\n";
        $result = 0;
        goto CLEANUP;
        }
    }


################################## Cleanup 046 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 046 ##################################");
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

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_047 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_047");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_047";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
#Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
#Check status "IDL" of line
    unless (grep/IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: $list_dn[0] is not in properly state");
        print FH "STEP: Check $list_dn[0] is IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $list_dn[0] is IDL - PASS\n";
    }  

#Execute command Bsy
    $ses_core->execCmd("bsy");
    unless (grep/MB/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy'");
        print FH "STEP: Execute command 'Bsy' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Bsy' - PASS\n";
    }
#Execute command RTS pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing return line");
    unless ($ses_core->execCmd("rts")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'rts'");
        print FH "STEP: Execute command 'rts' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'rts' - PASS\n";
    }
    
    sleep(10);
    unless (grep/IDL/, $ses_core->execCmd("post d $list_dn[0] print")) { 
        $logger->error(__PACKAGE__ . " $tcid: Failed to return $list_dn[0]");
        print FH "STEP: Performed return $list_dn[0] - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else{      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return $list_dn[1]");  
        print FH "STEP: Performed return $list_dn[0] - PASS\n";
    } 
################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");
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
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_048 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_048");
########################### Variables Declaration #############################
    $tcid = "ADQ1109_048";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my @output;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");
    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;

################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;
# Check status "IDL" of line
    unless (grep/IDL/, $ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $list_dn[0] print")) {
        $logger->error(__PACKAGE__ . " $tcid: $list_dn[0] is not in properly state");
        print FH "STEP: Check $list_dn[0] is IDL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $list_dn[0] is IDL - PASS\n";
    }  

# Execute command AlmStat
    $ses_core->{conn}->print("AlmStat");
    unless ($ses_core->{conn}->waitfor(-match => '/\d+\.\d+\%\s+\>/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'AlmStat'");
        print FH "STEP: Execute command 'AlmStat' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'AlmStat' - PASS\n";
    }
################################## Cleanup 048 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 048 ##################################");
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
    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_049 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_049");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_049";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my $add_feature_lineB = 0;
    my (@list_file_name, $dialed_num,$active);
    my $ses_corecli;
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# # Check line status
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Offhook line A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
# A hears dial tone
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

# A dials DN line B
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

# A hears ringback tone
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }

# B hears Ringing signal
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
# B answers
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
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Perform sequence commands on the CM MAP window to manually RExTst on  inactive ABI GWC service-unit
    $ses_core->{conn}->prompt('/\>/');
    unless (@output = $ses_core->execCmd("mapci;mtc;pm;post gwc 4")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post gwc 4");
    $logger->debug(__PACKAGE__ . " $tcid: execute commnad 'rex now'");
    $ses_core->execCmd("rex now");
    @output = $ses_core->{conn}->print("y");
    $ses_core->{conn}->waitfor(-match => '/Inact InSv/', -timeout => 150);
    @output = $ses_core->{conn}->print("logout");
    $ses_core->{conn}->waitfor(-match => '/CI/', -timeout => 10);
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/');
# Warm Swact GWC 4
    unless ($ses_core->warmSwactGWC(-gwc_id => 4, -timeout => 120)){
    	$logger->error(__PACKAGE__ . "$tcid: cannot execCmd 'aim service-unit swact gwc4 '");
        print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
    	print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - PASS\n";
    }
 
# Check speech path between A B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A B");
        print FH "STEP: Check speech path between A B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A B - PASS\n";
    }
# Onhook A B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
# ################################## Cleanup 015 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 014 ##################################");

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
        unless (grep /VSNWC13DC/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_050 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_050");

########################### Variables Declaration #############################
    $tcid = "ADQ1109_050";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    my @list_dn = ($db_line{$tc_line{$tcid}[0]}{-dn}, $db_line{$tc_line{$tcid}[1]}{-dn});
    my @list_line = ($db_line{$tc_line{$tcid}[0]}{-line}, $db_line{$tc_line{$tcid}[1]}{-line});
    my @list_region = ($db_line{$tc_line{$tcid}[0]}{-region}, $db_line{$tc_line{$tcid}[1]}{-region});
    my @list_len = ($db_line{$tc_line{$tcid}[0]}{-len}, $db_line{$tc_line{$tcid}[1]}{-len});
    my @list_line_info = ($db_line{$tc_line{$tcid}[0]}{-info}, $db_line{$tc_line{$tcid}[1]}{-info});

    my $initialize_done = 0;
    my $logutil_start = 0;
    my $flag = 1;
    my $add_feature_lineB = 0;
    my (@list_file_name, $dialed_num,$active);
    my $ses_corecli;
    
################################# LOGIN #######################################
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&glcas);
    my $thr3 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_glcas = $thr2->join();
    $ses_logutil = $thr3->join();

    unless ($ses_core->loginCore(-username => [@{$core_account{-username}}[2..5]], -password => [@{$core_account{-password}}[2..5]])) {
		$logger->error(__PACKAGE__ . " $tcid: Unable to access TMA20 Core");
		print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

############### Test Specific configuration & Test Tool Script Execution #################
# # Check line status
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
		
        unless (grep /IDL||PLO/, $ses_core->coreLineGetStatus($list_dn[$i])) {
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

# Offhook line A
    unless($ses_glcas->offhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . "$tcid: Cannot offhook line $list_line[0]");
        print FH "STEP: Offhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Offhook line A - PASS\n";
    }
# A hears dial tone
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
    
# A dials DN line B
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
    } else {
        print FH "STEP: A dials $dialed_num - PASS\n";
    }

# A hears ringback tone
    %input = (
                -line_port => $list_line[0], 
                -freq1 => 450,
                -freq2 => 400,
                -tone_duration => 100,
                -cas_timeout => 50000, 
                -wait_for_event_time => $wait_for_event_time,
                );
    unless ($ses_glcas->detectSpecifiedToneCAS(%input)) {
        $logger->error(__PACKAGE__ . ".$tcid: cannot detect ringback tone line $list_dn[0]");
        print FH "STEP: A hear ringback tone - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: A hear ringback tone - PASS\n";
    }

# B hears Ringing signal
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
# B answers
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
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A and B");
        print FH "STEP: Check speech path between A and B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A and B - PASS\n";
    }
# Perform sequence commands: rex now and rex abtk
    $ses_core->{conn}->prompt('/\>/');
    unless (@output = $ses_core->execCmd("mapci;mtc;pm;post gwc 4")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post gwc 4");
    $logger->debug(__PACKAGE__ . " $tcid: execute commnad 'rex now'");
    $ses_core->execCmd("rex now");
    unless (grep /Request Submitted/, $ses_core->execCmd("y")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'rex now'");
        print FH "STEP: Execution cmd 'rex now' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'rex now' - PASS\n";
    }
    $logger->debug(__PACKAGE__ . " $tcid: execute commnad 'rex abtk'");
    @output = $ses_core->{conn}->print("rex abtk");
    $ses_core->{conn}->waitfor(-match => '/Inact InSv/', -timeout => 120);
    @output = $ses_core->{conn}->print("logout");
    $ses_core->{conn}->waitfor(-match => '/CI/', -timeout => 10);
    $ses_core->{conn}->prompt('/.*[%\}\|\>\]].*$/');
# Warm Swact GWC 4
    unless ($ses_core->warmSwactGWC(-gwc_id => 4, -timeout => 120)){
    	$logger->error(__PACKAGE__ . "$tcid: cannot execCmd 'aim service-unit swact gwc4 '");
        print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
    	print FH "\nSTEP: Execute command 'aim service-unit swact gwc4 ' - PASS\n";
    }
# Check speech path between A B
    %input = (
                -list_port => [$list_line[0],$list_line[1]],
                -checking_type => ['DIGIT'], 
                -tone_duration => 1000, 
                -cas_timeout => 50000
             );
    unless ($ses_glcas->checkSpeechPathCAS(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to Check speech path between A B");
        print FH "STEP: Check speech path between A B - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check speech path between A B - PASS\n";
    }
# Onhook A B
    unless($ses_glcas->onhookCAS(-line_port => $list_line[0], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[0]");
        print FH "STEP: Onhook line A - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line A - PASS\n";
    }

    unless($ses_glcas->onhookCAS(-line_port => $list_line[1], -wait_for_event_time => $wait_for_event_time)) {
        $logger->error(__PACKAGE__ . ": Cannot onhook line $list_line[1]");
        print FH "STEP: Onhook line B - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Onhook line B - PASS\n";
    }
# ################################## Cleanup 015 ##################################
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
        unless (grep /GWCPSNET||Log empty/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_051 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_051");
    $logger->debug(__PACKAGE__ . " GATWYINV - Provisioning ABI GPP with same IP and different H248 ports");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_051";
    $tcid = "ADQ1109_051";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $existing_ip;
    my $logutil_start = 0;
    my $gatwy_no = 1023;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Find existing IP by using command "DIS"
    if (grep /NOT POSITIONED/, @output = $ses_core->execCmd("DIS")) {
        $logger->error(__PACKAGE__ . " $tcid: Table does not have any tuple");
        print FH "STEP: Execution cmd 'DIS' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'DIS' - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /G6ABI.*\(\s+(.*)\)\$/) {
            $existing_ip = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Existing IP is $existing_ip;");
        }
    }

#Check existing G6 ABI to avoid duplicate
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[2..9]], 
                -password => [@{$core_account{-password}}[2..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

#New ABI gateway with existing IP in above
    @output = $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ $existing_ip \$ HOST GWC 4 PORT 1 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless (grep/The IP address is a duplicate/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The ouput does not contain duplicate ERROR");
        print FH "STEP: Check ERROR 'The IP address is a duplicate' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Check ERROR 'The IP address is a duplicate' - PASS\n";
    }

    ################################## Cleanup 001 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 001 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_052 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_052");
    $logger->debug(__PACKAGE__ . " GATWYINV - Modify IP of an existing ABI GPP while subtending PM state is OFFL");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_052";
    $tcid = "ADQ1109_052";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $new_ip = "11 11 11 11";
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1001 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Change IP of ABI GPP gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        $ses_core->execCmd("rep ABI $gatwy_no G6ABI 'AUTO-DISC' $new_ip \$ HOST GWC 5 +");
        @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
        if (grep/DMOS NOT ALLOWED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to change IP of ABI GPP gateway");
            print FH "STEP: Change IP of ABI GPP gateway - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Change IP of ABI GPP gateway - PASS\n";
        }
    }

    ################################## Cleanup 002 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 002 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_053 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_053");
    $logger->debug(__PACKAGE__ . " GATWYINV - Delete a GPP entry while it is still associated with an entry in table LTCINV");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_053";
    $tcid = "ADQ1109_053";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Delete GPP ABI gateway while LTCINV still references this gateway
    if ($ltcinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/Error: Table LTCINV still references this Gateway/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Fail to check Error 'Table LTCINV still references this Gateway'");
            print FH "STEP: Check Error 'Table LTCINV still references this Gateway' - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Check Error 'Table LTCINV still references this Gateway' - PASS\n";
        }
    }

    ################################## Cleanup 003 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 003 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv){
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_054 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_054");
    $logger->debug(__PACKAGE__ . " LTCINV - Provisioning full data G6 GPP POTS line");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_054";
    $tcid = "ADQ1109_054";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    @output = $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    @output = $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N");
    if (grep/DMOS NOT ALLOWED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Pos new provisioned GPP
    unless (grep/\<line length\>/, $ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not execute command 'format pack'");
    }
    unless (grep/$gatwy_no/, $ses_core->execCmd("pos GPP $gpp_no")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not execute command 'pos' GPP $gpp_no");
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully pos new provisioned GPP");
    }

    ################################## Cleanup 004 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 004 ##################################");

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_055 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_055");
    $logger->debug(__PACKAGE__ . " GPPTRNSL - Delete tuble in table GPPTRNSL when V5 interface is ACT");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_055";
    $tcid = "ADQ1109_055";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gppv5_name;
    my $logutil_start = 0;
    my $flag = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Show all tuples to find GPP V5 interface
    unless (grep /AMCNO/, @output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Find GPP V5 interface
    foreach (@output) {
        if ($_ =~ /(GPPV\s+\d+\s+\d+)\s+GPP\s+\d+/) {
            $logger->debug(__PACKAGE__ . " $tcid: GPP V5 interface was found");
            $gppv5_name = $1;
            $flag = 1;
        }
    }
    unless ($flag) {
        $logger->error(__PACKAGE__ . " $tcid: No GPP V5 interface was found");
        print FH "STEP: Find GPP V5 interface  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Find GPP V5 interface  - PASS\n";
    }

#Delete GPP V5 interface
    if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $gppv5_name")) {
        @output = $ses_core->execCmd("y");
    }
    unless (grep/must be in the DEACT||still lines declared/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Tuple was deleted without any ERROR");
        print FH "STEP: Delete tuple and check ERROR generate - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Delete tuple and check ERROR generate - PASS\n";
    }


    ################################## Cleanup 005 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 005 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_056 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_056");
    $logger->debug(__PACKAGE__ . " V5PROV - Provisioning full data & wrong data (prov ID)");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_056";
    $tcid = "ADQ1109_056";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $v5prid = 700;
    my $new_v5prid = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE V5PROV
    unless (grep /TABLE: V5PROV/, @output = $ses_core->execCmd("TABLE V5PROV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE V5PROV");
        print FH "STEP: Access TABLE V5PROV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE V5PROV - PASS\n";
    }

#New tuple in TABLE V5PROV with invalid V5PRID
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $v5prid 10 50 1 16 CTRL \$ 51 2 16 PSTN \$ \$ 3 \$ 3 15 \$ 50")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/ERROR/, @output) {
        print FH "STEP: Error generated when new tuple with V5PRID $v5prid - PASS\n";
        @output = $ses_core->execCmd("700");
    }
    foreach (@output) {
        if ($_ =~ /V5_KEY\s+\{(\d+)\s+TO\s+(\d+)\}/) {
            $logger->debug(__PACKAGE__ . " $tcid: Find valid range for V5PRID");
            print FH "STEP: Find valid range for V5PRID, $1 to $2 - PASS\n";
            $v5prid = $2 - 1;
        }
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    
#New tuple in TABLE V5PROV with valid V5PRID
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $v5prid 10 50 1 16 CTRL \$ 51 2 16 PSTN \$ \$ 3 \$ 3 15 \$ 50")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple in TABLE V5PROV");
        print FH "STEP: Add new tuple in TABLE V5PROV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Add new tuple in TABLE V5PROV - PASS\n";
        $new_v5prid = 1;
    }

    
    ################################## Cleanup 006 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 006 ##################################");

#Delete tuple in TABLE V5PROV
    if ($new_v5prid) {
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $v5prid")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in TABLE V5PROV");
            print FH "STEP: Delete tuple in TABLE V5PROV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete tuple in TABLE V5PROV - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_057 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_057");
    $logger->debug(__PACKAGE__ . " Provisioning - GPP V5.2 POTS & BRI lines");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_057";
    $tcid = "ADQ1109_057";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $len_group;
    my $flag = 0;
    my @lengrp ;
    my ($i, $j, $draw, $num);

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Show all tuples to find GPP line group
    unless (grep /AMCNO/, @output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Find GPP len group
    foreach (@output) {
        if ($_ =~ /(GPPV\s+\d+\s+\d+)\s+GPP\s+\d+/) {
            $logger->debug(__PACKAGE__ . " $tcid: GPP len group was found");
            $len_group = $1;
            $flag = 1;
        }
    }

    unless ($flag) {
        $logger->error(__PACKAGE__ . " $tcid: No GPP len group was found");
        print FH "STEP: Find GPP len group  - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Find GPP len group  - PASS\n";
    }

#Access TABLE LNINV
    unless (grep /TABLE: LNINV/, @output = $ses_core->execCmd("TABLE LNINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LNINV");
        print FH "STEP: Access TABLE LNINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LNINV - PASS\n";
    }

#Find all provisioned lines with len group in above
    unless (grep /BOTTOM/, @output = $ses_core->execCmd("list all \(1 eq \'$len_group \* \*\'\)")) { 
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all provisioned lines");
        print FH "STEP: List all provisioned lines - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all provisioned lines - PASS\n";
    }

    $i = scalar@output;
    unless ($i>2) { #that means no line provisioned under this len group
        $logger->error(__PACKAGE__ . " $tcid: No line provisioned under this len group");
    } else {
        if ($output[$i-2] =~ /.*\s(\d+)\s(\d+)/) {
            $logger->debug(__PACKAGE__ . " $tcid: Found draw and line number");
            $draw = $1;
            $num = $2;
        }
    }

#Add new line for this len group
    if ($i>2) {
        for ($j = $num+1; $j <=99; $j++) {
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $len_group $draw $j V5BRI NPDGP WORKING N NL Y NIL")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE ADDED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE ADDED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple in TABLE LNINV");
                print FH "STEP: Add new tuple in TABLE LNINV - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Add new tuple in TABLE LNINV - PASS\n";
                $flag = 2;
            }

        }
    } else {
        for ($j = 0; $j <=99; $j++) {
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("add $len_group $draw $j V5BRI NPDGP WORKING N NL Y NIL")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE ADDED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE ADDED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to add new tuple $len_group $draw $j in TABLE LNINV");
                print FH "STEP: Add new tuple $len_group $draw $j in TABLE LNINV - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Add new tuple $len_group $draw $j in TABLE LNINV - PASS\n";
                $flag = 3;
            }
        }

    }
    
    ################################## Cleanup 007 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 007 ##################################");

#Delete tuple in TABLE V5PROV
    if ($flag == 2) {
        for ($j = $num+1; $j <=99; $j++) { 
            if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $len_group $draw $j")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple $len_group $draw $j in TABLE LNINV");
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE LNINV - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE LNINV - PASS\n";
            }
        }
    } 
    if ($flag == 3) {
        for ($j = 0; $j <=99; $j++) { 
            if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del $len_group $draw $j")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in TABLE LNINV");
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE V5PROV - FAIL\n";
                $result = 0;
            } else {
                print FH "STEP: Delete tuple $len_group $draw $j in TABLE V5PROV - PASS\n";
            }
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_058 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_068");
    $logger->debug(__PACKAGE__ . " Provisioning -  BRI ETSI version on C20 ATCA & C20 MA-RMS platform");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_068";
    $tcid = "ADQ1109_068";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $dn_1 = 4005007650;
    my $dn_2 = 4005007651;
    my $isdn_1 = "isdn 220";
    my $isdn_2 = "isdn 221";
    my $len_1 = "GPPV 00 1 02 20";
    my $len_2 = "GPPV 00 1 02 21";
    my $flag_1 = 0;
    my $flag_2 = 0;
    my $line_state;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post 1st lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_1 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is IDL try to out then reprovisioning");
        $flag_1 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#Post 2nd lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_2 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is IDL try to out then reprovisioning");
        $flag_2 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#out, detach and remove isdn_1
    if ($flag_1) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_1 $isdn_1 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_1");
            print FH "STEP: Try to out line $dn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_1 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_1 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_1");
            print FH "STEP: Try to detach $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_1 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_1");
            print FH "STEP: Try to remove $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_1 - PASS\n";
        }
    }

#reprovisioning isdn_1
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_1");
        print FH "STEP: Try to add $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_1 att $len_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_1");
        print FH "STEP: Try to attach $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_1 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_1 ISDNKSET RESTP 0 0 1 y $isdn_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_1");
        print FH "STEP: Try to new line for $dn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_1 - PASS\n";
    }

#out, detach and remove isdn_2
    if ($flag_2) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_2 $isdn_2 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_2");
            print FH "STEP: Try to out line $dn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_2 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_2 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_2");
            print FH "STEP: Try to detach $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_2 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_2");
            print FH "STEP: Try to remove $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_2 - PASS\n";
        }
    }

#reprovisioning isdn_2
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_2");
        print FH "STEP: Try to add $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_2 att $len_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_2");
        print FH "STEP: Try to attach $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_2 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_2 ISDNKSET RESTP 0 0 1 y $isdn_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_2");
        print FH "STEP: Try to new line for $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_2 - PASS\n";
    }
    sleep (5);
#post 2 lines into MAPCI to make sure they IDL after reprovisioning
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after reprovisioning");
            print FH "STEP: Line $_ is IDL after reprovisioning - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after reprovisioning - PASS\n";
        }
    }

    ################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 008 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_059 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_059");
    $logger->debug(__PACKAGE__ . " Swap DNs - LTID of ISDN BRI line");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_059";
    $tcid = "ADQ1109_059";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $logutil_start = 0;
    my $dn_1 = 4005007650;
    my $dn_2 = 4005007651;
    my $isdn_1 = "isdn 220";
    my $isdn_2 = "isdn 221";
    my $len_1 = "GPPV 00 1 02 20";
    my $len_2 = "GPPV 00 1 02 21";
    my $flag_1 = 0;
    my $flag_2 = 0;
    my $line_state;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post 1st lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_1 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is IDL try to out then reprovisioning");
        $flag_1 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_1 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#Post 2nd lines into MAPCI to get their status
    if (grep/Invalid Directory Number/,@output=$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $dn_2 print")) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is blank DN and ready to provisioning");
    } elsif (grep/IDL/,@output) {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is IDL try to out then reprovisioning");
        $flag_2 = 1;
    } else {
        $logger->debug(__PACKAGE__ . " $tcid: $dn_2 is not in properly status");
        $result = 0;
        goto CLEANUP;
    }

#out, detach and remove isdn_1
    if ($flag_1) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_1 $isdn_1 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_1");
            print FH "STEP: Try to out line $dn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_1 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_1 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_1");
            print FH "STEP: Try to detach $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_1 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_1");
            print FH "STEP: Try to remove $isdn_1 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_1 - PASS\n";
        }
    }

#reprovisioning isdn_1
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_1 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_1");
        print FH "STEP: Try to add $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_1 att $len_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_1");
        print FH "STEP: Try to attach $isdn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_1 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_1 ISDNKSET RESTP 0 0 1 y $isdn_1 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_1");
        print FH "STEP: Try to new line for $dn_1 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_1 - PASS\n";
    }

#out, detach and remove isdn_2
    if ($flag_2) {
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("out \$ $dn_2 $isdn_2 bldn y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not command out for $dn_2");
            print FH "STEP: Try to out line $dn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to out line $dn_2 - PASS\n";
        }
        unless (grep/Logical terminal ISDN/,$ses_core->execCmd("slt \$ $isdn_2 det y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not detach out for $isdn_2");
            print FH "STEP: Try to detach $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to detach $isdn_2 - PASS\n";
        }
        unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 rem y y")) {
            $logger->debug(__PACKAGE__ . " $tcid: Could not remove $isdn_2");
            print FH "STEP: Try to remove $isdn_2 - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Try to remove $isdn_2 - PASS\n";
        }
    }

#reprovisioning isdn_2
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("slt \$ $isdn_2 add brafs y n 64 y voice vbd CMD PVC ETSI 0 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt add for $dn_2");
        print FH "STEP: Try to add $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to add $isdn_1 - PASS\n";
    }
    unless (grep/TEI is static/,$ses_core->execCmd("slt \$ $isdn_2 att $len_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not command slt att $isdn_2");
        print FH "STEP: Try to attach $isdn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to attach $isdn_2 - PASS\n";
    }
    unless (grep/SERVICE ORDERS NOT ALLOWED/,$ses_core->execCmd("new \$ $dn_2 ISDNKSET RESTP 0 0 1 y $isdn_2 \$ y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not new line for $dn_2");
        print FH "STEP: Try to new line for $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to new line for $dn_2 - PASS\n";
    }
    sleep (5);
#post 2 lines into MAPCI to make sure they IDL after reprovisioning
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after reprovisioning");
            print FH "STEP: Line $_ is IDL after reprovisioning - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after reprovisioning- PASS\n";
        }
    }

#swap dn isdn_1 and isdn_2
    unless (grep/Logical terminal ISDN/,$ses_core->execCmd("swlt \$ dns 4005007650 4005007651 y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not swact DN for $dn_1 and $dn_2");
        print FH "STEP: Try to swap DN for $dn_1 and $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to swap DN for $dn_1 and $dn_2 - PASS\n";
    }
    sleep(5);

#post 2 lines into MAPCI to make sure they IDL after swap
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after swap");
            print FH "STEP: Line $_ is IDL after swap - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after swap - PASS\n";
        }
    }

    ################################## Cleanup 008 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 009 ##################################");

#swap dn isdn_1 and isdn_2 again
    unless (grep/Logical terminal ISDN/,$ses_core->execCmd("swlt \$ dns 4005007650 4005007651 y y")) {
        $logger->debug(__PACKAGE__ . " $tcid: Could not rollback DN for $dn_1 and $dn_2");
        print FH "STEP: Try to rollback DN for $dn_1 and $dn_2 - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Try to rollback DN for $dn_1 and $dn_2 - PASS\n";
    }
    sleep(5);
    
#post 2 lines into MAPCI to make sure they IDL after swap
    foreach ($dn_1,$dn_2) {
        unless (grep/IDL/,$ses_core->execCmd("mapci nodisp;mtc;lns;ltp;post d $_ print")) {
            $logger->error(__PACKAGE__ . " $tcid: $_ is not IDL after rollback");
            print FH "STEP: Line $_ is IDL after rollback - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Line $_ is IDL after rollback - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_060 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_060");
    $logger->debug(__PACKAGE__ . " Provisioning V5.2 from 1 to 16 links");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_060";
    $tcid = "ADQ1109_060";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;
    my $ltcpsinv = 0;
    my $gpptrnsl = 0;
    my $flag = 0;
    my $v5id = 103;
    my $site_name;
    my $term;
    my @v5id = ();

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Replace tuple to modify 16 ports to D30 V52 N in TABLE LTCPSINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 D30 V52 N 1 D30 V52 N 2 D30 V52 N +");
        $ses_core->execCmd("3 D30 V52 N 4 D30 V52 N 5 D30 V52 N 6 D30 V52 N +");
        $ses_core->execCmd("7 D30 V52 N 8 D30 V52 N 9 D30 V52 N 10 D30 V52 N +");
        $ses_core->execCmd("11 D30 V52 N 12 D30 V52 N 13 D30 V52 N 14 D30 V52 N +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 D30 V52 N 16 D30 V52 N \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rep tuple in TABLE LTCPSINV");
            print FH "STEP: Rep tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rep tuple in TABLE LTCPSINV - PASS\n";
            $ltcpsinv = 1;
        }
    }

#Access TABLE SITE and format pack
    unless (grep /TABLE: SITE/, $ses_core->execCmd("TABLE SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE SITE");
        print FH "STEP: Access TABLE SITE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE SITE - PASS\n";
    }

    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack - PASS\n";
    }

#Find available site name
    CHECKSITE:
    unless (@output = $ses_core->execCmd("dis")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command dis");
    } else {
        $logger->error(__PACKAGE__ . " $tcid:" .Dumper(\@output));
    }
    foreach(@output) {
        unless ($_ =~ /(.*)\s+0\s+0/) {
            $logger->error(__PACKAGE__ . " $tcid: SITE name in used try to find an other");
            $ses_core->execCmd("next");
            goto CHECKSITE;
        } else {
            $site_name = $1;
            $logger->debug(__PACKAGE__ . " $tcid: SITE name $site_name is available");
            print FH "STEP: Site name was found $site_name - PASS\n"; 
        }
    }

#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Check existing V5ID to avoid duplicate
    unless (@output=$ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack list all");
        print FH "STEP: Command format pack list all- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack list all- PASS\n";
    }

    foreach(@output) {
        if ($_ =~ /\(\d+\)\s+\$\s(\d+)/) {
            $logger->debug(__PACKAGE__ . " $tcid: Try to get existing V5ID $1");
            $term = $1;
        }
        if ($v5id == $term) {
            $logger->error(__PACKAGE__ . " $tcid: This V5ID $v5id in used try to use an other");
            $v5id = $v5id - 1;
        } else {
            $flag = 1;
        }
    }
    if ($flag) {
        print FH "STEP: Available V5ID is $v5id- PASS\n";
    }


#New tuple in TABLE GPPTRNSL
    $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $v5id 127 480 V5UMUX RING2 REG")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE GPPTRNSL");
        print FH "STEP: New GPP in TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE GPPTRNSL - PASS\n";
        $gpptrnsl = 1;
    }


    ################################## Cleanup 010 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 010 ##################################");

    #Delete tuple in TABLE GPPTRNSL
    if ($gpptrnsl) {
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("del $site_name 00 0")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Rollback tuple in TABLE LTCPSINV
    if ($ltcpsinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 NILTYPE 1 NILTYPE 2 NILTYPE +");
        $ses_core->execCmd("3 NILTYPE 4 NILTYPE 5 NILTYPE 6 NILTYPE +");
        $ses_core->execCmd("7 NILTYPE 8 NILTYPE 9 NILTYPE 10 NILTYPE +");
        $ses_core->execCmd("11 NILTYPE 12 NILTYPE 13 NILTYPE 14 NILTYPE +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 NILTYPE 16 NILTYPE \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_061 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_061");
    $logger->debug(__PACKAGE__ . " BOUNDARY testing for V5.2 LE interface ID, Variant");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_061";
    $tcid = "ADQ1109_061";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gatwy_no = 1023;
    my $gpp_no = 511;
    my $logutil_start = 0;
    my $gatwyinv = 0;
    my $ltcinv = 0;
    my $ltcpsinv = 0;
    my $gpptrnsl = 0;
    my $flag = 0;
    my $v5id = 103;
    my $site_name;
    my @valid_v5id = (0, 99565, 16777215);
    my $invalid_v5id = 16777777;


    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################

#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Check existing G6 ABI to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKABI:
    if (grep/ABI\s+$gatwy_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gateway number is exist try to find an other");
        print FH "STEP: The gateway number $gatwy_no is in used - FAIL\n";
        $gatwy_no = $gatwy_no - 1;
        goto CHECKABI;
    } else {
        print FH "STEP: The gateway number $gatwy_no is not used - PASS\n";
    }

#New GPP ABI gateway
    $ses_core->execCmd("add ABI $gatwy_no G6ABI \$ 10 11 12 13 \$ HOST GWC 5 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("GTWYLOC TM20 G6F 11 1 F 2 1 15 PORT 2 \$")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP ABI gateway");
        print FH "STEP: New GPP ABI gateway - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP ABI gateway - PASS\n";
        $gatwyinv = 1;
    }

#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Check existing GPP to avoid duplicate
    unless (@output = $ses_core->execCmd("list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command list all");
    }
    CHECKGPP:
    if (grep/GPP\s+$gpp_no/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: The gpp number is exist try to find an other");
        print FH "STEP: The gpp number $gpp_no is in used - FAIL\n";
        $gpp_no = $gpp_no - 1;
        goto CHECKGPP;
    } else {
        print FH "STEP: The gpp number $gpp_no is not used - PASS\n";
    }

#New GPP in TABLE LTCINV
    $ses_core->execCmd("add GPP $gpp_no 1841 CGPP 0 5 1 A 6 MX85AA QPO22AO POTS POTSEX KEYSET KSETEX \$ +");
    $ses_core->execCmd("\$ UTR6 MSGMX76 HOST CMR5 CMRU23A ISP 16 \$ NZLGC SX05AA \$ +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("SX05AA \$ 0 SXFWAL01 EXTDS512 HOST ABI $gatwy_no \$ 6X40FA N")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        @output = $ses_core->execCmd("y");
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }
    unless (grep/TUPLE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to new GPP in TABLE LTCINV");
        print FH "STEP: New GPP in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: New GPP in TABLE LTCINV - PASS\n";
        $ltcinv = 1;
    }

#Replace tuple to modify 16 ports to D30 V52 N in TABLE LTCPSINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 D30 V52 N 1 D30 V52 N 2 D30 V52 N +");
        $ses_core->execCmd("3 D30 V52 N 4 D30 V52 N 5 D30 V52 N 6 D30 V52 N +");
        $ses_core->execCmd("7 D30 V52 N 8 D30 V52 N 9 D30 V52 N 10 D30 V52 N +");
        $ses_core->execCmd("11 D30 V52 N 12 D30 V52 N 13 D30 V52 N 14 D30 V52 N +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 D30 V52 N 16 D30 V52 N \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rep tuple in TABLE LTCPSINV");
            print FH "STEP: Rep tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rep tuple in TABLE LTCPSINV - PASS\n";
            $ltcpsinv = 1;
        }
    }

#Access TABLE SITE and format pack
    unless (grep /TABLE: SITE/, $ses_core->execCmd("TABLE SITE")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE SITE");
        print FH "STEP: Access TABLE SITE - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE SITE - PASS\n";
    }

    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack - PASS\n";
    }

#Find available site name
    CHECKSITE:
    unless (@output = $ses_core->execCmd("dis")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command dis");
    } else {
        $logger->error(__PACKAGE__ . " $tcid:" .Dumper(\@output));
    }
    foreach(@output) {
        unless ($_ =~ /(.*)\s+0\s+0/) {
            $logger->error(__PACKAGE__ . " $tcid: SITE name in used try to find an other");
            $ses_core->execCmd("next");
            goto CHECKSITE;
        } else {
            $site_name = $1;
            $logger->debug(__PACKAGE__ . " $tcid: SITE name $site_name is available");
            print FH "STEP: Site name was found $site_name - PASS\n"; 
        }
    }

#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack list all
    unless (@output=$ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack list all");
        print FH "STEP: Command format pack list all- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack list all- PASS\n";
    }

#New then delete tuple in TABLE GPPTRNSL with valid V5ID
    foreach (@valid_v5id) {
        $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $_ 127 480 V5UMUX RING2 REG")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE ADDED/, @output) {
            @output = $ses_core->execCmd("y");
        } elsif (grep/The V5ID already/, @output) {
            print FH "STEP: The V5ID $_ is exist dont need to provisioning - PASS\n";
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE ADDED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to new tuple in table GPPTRNSL with V5ID $_");
            print FH "STEP: New tuple in table GPPTRNSL with V5ID $_ - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: New tuple in table GPPTRNSL with V5ID $_ - PASS\n";
            if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("del $site_name 00 0")) {
                @output = $ses_core->execCmd("y");
            }
            if (grep/TUPLE TO BE DELETED/, @output) {
                @output = $ses_core->execCmd("y");
            }
            unless ($ses_core->execCmd("abort")) {
                $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
            }
            unless (grep/TUPLE DELETED/, @output) {
                $logger->error(__PACKAGE__ . " $tcid: Failed to delete tuple in table GPPTRNSL with V5ID $_");
                print FH "STEP: Delete tuple in table GPPTRNSL with V5ID $_ - FAIL\n";
                $result = 0;
                goto CLEANUP;
            } else {
                print FH "STEP: Delete tuple in table GPPTRNSL with V5ID $_ - PASS\n";
            }
        }
    }

#New tuple in TABLE GPPTRNSL with invalid V5ID
    $ses_core->execCmd("add $site_name 00 0 GPP $gpp_no V5_2 0 1 2 3 4 5 6 7 8 9 10 +");
    if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("11 12 13 14 15 $invalid_v5id 127 480 V5UMUX RING2 REG")) {
        @output = $ses_core->execCmd("y");
    }
    if (grep/TUPLE TO BE ADDED/, @output) {
        $logger->error(__PACKAGE__ . " $tcid: Successfully to new tuple with invalid V5ID $invalid_v5id");
        print FH "STEP: Detected invalid V5ID $invalid_v5id - FAIL\n";
    } else {
        print FH "STEP: Detected invalid V5ID $invalid_v5id - PASS\n";
    }
    unless ($ses_core->execCmd("abort")) {
        $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
    }


    ################################## Cleanup 011 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 011 ##################################");

#Rollback tuple in TABLE LTCPSINV
    if ($ltcpsinv) {
        unless (grep /TABLE: LTCPSINV/, @output = $ses_core->execCmd("TABLE LTCPSINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCPSINV");
        }
        $ses_core->execCmd("rep GPP $gpp_no Y 0 NILTYPE 1 NILTYPE 2 NILTYPE +");
        $ses_core->execCmd("3 NILTYPE 4 NILTYPE 5 NILTYPE 6 NILTYPE +");
        $ses_core->execCmd("7 NILTYPE 8 NILTYPE 9 NILTYPE 10 NILTYPE +");
        $ses_core->execCmd("11 NILTYPE 12 NILTYPE 13 NILTYPE 14 NILTYPE +");
        if (grep/DMOS NOT ALLOWED/, $ses_core->execCmd("15 NILTYPE 16 NILTYPE \$")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE REPLACED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless ($ses_core->execCmd("abort")) {
            $logger->error(__PACKAGE__ . " $tcid: Could not command 'abort'");
        }
        unless (grep/TUPLE REPLACED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to rollback tuple in TABLE LTCPSINV");
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Rollback tuple in TABLE LTCPSINV - PASS\n";
        }
    }

#Delete GPP in TABLE LTCINV
    if ($ltcinv) {
        unless (grep /TABLE: LTCINV/, @output = $ses_core->execCmd("TABLE LTCINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del GPP $gpp_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP in TABLE LTCINV");
            print FH "STEP: Delete GPP in TABLE LTCINV - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP in TABLE LTCINV - PASS\n";
        }
    }

#Delete GPP ABI gateway
    if ($gatwyinv) {
        unless (grep /TABLE: GATWYINV/, @output = $ses_core->execCmd("TABLE GATWYINV")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        }
        if (grep/DMOS NOT ALLOWED/, @output = $ses_core->execCmd("del ABI $gatwy_no")) {
            @output = $ses_core->execCmd("y");
        }
        if (grep/TUPLE TO BE DELETED/, @output) {
            @output = $ses_core->execCmd("y");
        }
        unless (grep/TUPLE DELETED/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to delete GPP ABI gateway");
            print FH "STEP: Delete GPP ABI gateway - FAIL\n";
            $result = 0;
        } else {
            print FH "STEP: Delete GPP ABI gateway - PASS\n";
        }
    }

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_062 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_062");
    $logger->debug(__PACKAGE__ . " GPP mode - QueryPm GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_062";
    $tcid = "ADQ1109_062";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $abi_gateway;
    my $gateway_ip;
    my $query_ip = 1111;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE LTCINV
    unless (grep /TABLE: LTCINV/, $ses_core->execCmd("TABLE LTCINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE LTCINV");
        print FH "STEP: Access TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE LTCINV - PASS\n";
    }

#Command format pack in TABLE LTCINV
    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack TABLE LTCINV - PASS\n";
    }

#Pos GPP 1 and find ABI gateway it belongs to
    unless (@output=$ses_core->execCmd("pos $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to pos $gpp in TABLE LTCINV");
        print FH "STEP: Pos $gpp in TABLE LTCINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Pos $gpp in TABLE LTCINV - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /HOST\s+(.*)\)\s+\$/) {
            $abi_gateway = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Gateway that $gpp belongs to is $abi_gateway");
            print FH "STEP: Gateway of $gpp is $abi_gateway - PASS\n";
        }
    }

#Access TABLE GATWYINV
    unless (grep /TABLE: GATWYINV/, $ses_core->execCmd("TABLE GATWYINV")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GATWYINV");
        print FH "STEP: Access TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GATWYINV - PASS\n";
    }

#Command format pack in TABLE GATWYINV
    unless ($ses_core->execCmd("format pack")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to command format pack");
        print FH "STEP: Command format pack TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Command format pack TABLE GATWYINV - PASS\n";
    }

#Pos ABI gateway in TABLE GATWYINV and find it IP
    unless (@output=$ses_core->execCmd("pos $abi_gateway")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to pos $abi_gateway in TABLE GATWYINV");
        print FH "STEP: Pos $abi_gateway in TABLE GATWYINV - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Pos $abi_gateway in TABLE GATWYINV - PASS\n";
    }

    foreach (@output) {
        if ($_ =~ /AUTO-DISC\s+\((\d+)\s+(\d+)\s+(\d+)\s+(\d+)\)/) { 
            $gateway_ip = $1.".".$2.".".$3.".".$4;
            $logger->debug(__PACKAGE__ . " $tcid: IP of gateway $abi_gateway was found: $gateway_ip");
            print FH "STEP: Detect IP of gateway $abi_gateway $gateway_ip - PASS\n";           
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;
        $logger->debug(__PACKAGE__ . ".$tcid: ############################ $_");       
    }

#Execute command QueryPM
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (@output = $ses_core->execCmd("QueryPM")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM'");
        print FH "STEP: Execution cmd 'QueryPM'- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'QueryPM'- PASS\n";    
    }

    #$logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
#Detect gateway IP in QueryPM output then compare with IP in TABLE GATWYINV
    foreach(@output) {
        if ($_ =~ /0002.*002\s+(.*)/){
            $query_ip = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Detected IP in QueryPM output $query_ip");
        }
    }
    
    if ($query_ip == $gateway_ip) {
        print FH "STEP: IP $gateway_ip matched - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: IP $gateway_ip does not match");
        print FH "STEP: IP $gateway_ip matched - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }

    ################################## Cleanup 012 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 012 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_063 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_063");
    $logger->debug(__PACKAGE__ . " GPP mode - Bsy RTS Inactive unit");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_063";
    $tcid = "ADQ1109_063";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $inact_unit;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }
    
#Execute command QueryPM
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (@output = $ses_core->execCmd("QueryPM")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'QueryPM'");
        print FH "STEP: Execution cmd 'QueryPM'- FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execution cmd 'QueryPM'- PASS\n";    
    }

    #$logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
#Detect Inactive unit
    foreach(@output) {
        if ($_ =~ /(.*)\s+Inact/){
            $inact_unit = $1;
            $logger->debug(__PACKAGE__ . " $tcid: Inactive unit is $inact_unit");
            print FH "STEP: Detected $inact_unit inactive unit -  PASS\n";
        }
    }

#Execute command Bsy inactive unit
    $logger->debug(__PACKAGE__ . " $tcid: Execute command Bsy $inact_unit");
    @output = $ses_core->{conn}->print("Bsy $inact_unit\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 100)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'Bsy $inact_unit'");
        print FH "STEP: Bsy $inact_unit - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully Bsy $inact_unit");       
        print FH "STEP: Bsy $inact_unit - PASS\n";
    }
        

#Execute command RTS inactive unit
    $logger->debug(__PACKAGE__ . " $tcid: Execute command RTS $inact_unit");
    @output = $ses_core->{conn}->print("Rts $inact_unit\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 400)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed 'Rts $inact_unit'");
        print FH "STEP: Execution cmd 'Rts $inact_unit' - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully RTS $inact_unit");  
        print FH "STEP: Execution cmd 'Rts $inact_unit' - PASS\n";
    }  

    ################################## Cleanup 013 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 013 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_064 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_064");
    $logger->debug(__PACKAGE__ . " GPP mode - Busy - Return GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_064";
    $tcid = "ADQ1109_064";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $state;
    

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Check GPP is InSv or not
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (grep/PM is InSv||PM is ISTb/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not in properly state");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
    }  

#Execute command Bsy pm
    unless (grep/Please confirm/, $ses_core->execCmd("Bsy pm")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy pm'");
        print FH "STEP: Execute command 'Bsy pm' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Bsy pm' - PASS\n";
    }
    $logger->debug(__PACKAGE__ . " $tcid: Performing busy pm");
    $ses_core->{conn}->print("y");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 200)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform busy pm");
        print FH "STEP: Performed busy pm - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully busy pm");       
        print FH "STEP: Performed busy pm - PASS\n";
    }
    
#Execute command RTS pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing return pm");
    @output = $ses_core->{conn}->print("Rts pm\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 500)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return $gpp");
        print FH "STEP: Performed return $gpp - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return $gpp");  
        print FH "STEP: Performed return $gpp - PASS\n";
    } 

    unless (grep/PM is ISTb||PM is InSv/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not InSv after busy return");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
        $flag = 1;
    }

    ################################## Cleanup 014 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 064 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_065 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_065");
    $logger->debug(__PACKAGE__ . " GPP mode - Offline - Return GPP");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_065";
    $tcid = "ADQ1109_065";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    
    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post GPP into MAPCI PM level
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Check GPP is InSv or not
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    unless (grep/PM is InSv||PM is ISTb/, $ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not in properly state");
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
    }  

#Perform busy pm
    unless (grep/Please confirm/, $ses_core->execCmd("Bsy pm")) {
        $logger->error(__PACKAGE__ . " $tcid: Fail to execute commnad 'Bsy pm'");
        print FH "STEP: Execute command 'Bsy pm' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Bsy pm' - PASS\n";
    }

    $logger->debug(__PACKAGE__ . " $tcid: Performing busy pm");
    $ses_core->{conn}->print("y\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 200)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform busy pm");
        print FH "STEP: Performed busy pm - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully busy pm");       
        print FH "STEP: Performed busy pm - PASS\n";
    }

#Perform offline pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing Offline pm");
    $ses_core->{conn}->print("OffL\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform offline pm");
        print FH "STEP: Performed offline pm - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully offline pm");       
        print FH "STEP: Performed offline pm - PASS\n";
    }
        
#Perform busy pm again
    $logger->debug(__PACKAGE__ . " $tcid: Performing busy pm from offline state");
    $ses_core->{conn}->print("Bsy pm\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform busy pm from offline state");
        print FH "STEP: Performed busy pm from offline state - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else { 
        $logger->debug(__PACKAGE__ . " $tcid: Successfully busy pm");       
        print FH "STEP: Performed busy pm from offline state - PASS\n";
    }

#Execute command RTS pm
    $logger->debug(__PACKAGE__ . " $tcid: Performing return pm");
    @output = $ses_core->{conn}->print("Rts pm\n");
    unless ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 500)) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return $gpp");
        print FH "STEP: Performed return $gpp - FAIL\n";
        $result = 0; 
        goto CLEANUP;            
    } else {      
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return $gpp");  
        print FH "STEP: Performed return $gpp - PASS\n";
    } 

#Check PM InSv| ISTb or not
    unless (grep/PM is ISTb||PM is InSv/, @output=$ses_core->execCmd("OffL")) {
        $logger->error(__PACKAGE__ . " $tcid: $gpp is not InSv after busy return");
        $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
        print FH "STEP: Check $gpp is InSv - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Check $gpp is InSv - PASS\n";
        $flag = 1;
    }

    ################################## Cleanup 065 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 065 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_066 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_066");
    $logger->debug(__PACKAGE__ . " GPP mode - Busy return 2 pside message links");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_066";
    $tcid = "ADQ1109_066";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $pslink_1;
    my $pslink_2;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect link 1 and link 2 of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp\s+.*\s+\((\d+)\)\s+\((\d+)\)/) {
            $pslink_1 = $1;
            $pslink_2 = $2;
            print FH "STEP: Link 1 of $gpp is $pslink_1 - PASS\n";
            print FH "STEP: Link 2 of $gpp is $pslink_2 - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect 2 messages link of $gpp");
        print FH "STEP: Detected 2 messages link of $gpp - FAIL\n";
        
    }

    ######################### MTC on link 1 ###############################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy link 1
    if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy 1")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy 1'");
        print FH "STEP: Execute command 'bsy 1' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } elsif (grep/ManB state/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The V5 link 1 is already in ManB no action required");
        print FH "STEP: Detected link 1 is already in ManB  - PASS\n";
    } else {
        print FH "STEP: Execute command 'bsy 1' - PASS\n";
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy 1' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy 1'");
            print FH "STEP: Perform 'bsy 1' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in GPP mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in GPP mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Busy pside message link
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    if (grep/Please confirm/, @output=$ses_core->execCmd("bsy link $pslink_1")) {
        unless(grep/Passed/, $ses_core->execCmd("y")){
            $logger->error(__PACKAGE__ . " $tcid: Could not busy link $pslink_1");
            print FH "STEP: Busy link $pslink_1 in GPP mode - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Busy link $pslink_1 in GPP mode - PASS\n";
        }
    } elsif (grep/Link $pslink_1 is ManB/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: Link $pslink_1 is already in ManB try to it");
        print FH "STEP: Detected link $pslink_1 is already in ManB - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Link $pslink_1 is not in properly state");
        $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
        print FH "STEP: Detected link $pslink_1 is not in properly state - FAIL\n";
    }
#Return pside message link
    $logger->debug(__PACKAGE__ . " $tcid: Trying to return pside link $pslink_1"); 
    $ses_core->{conn}->print("rts link $pslink_1");
    if ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 150)) {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return link $pslink_1");       
        print FH "STEP: Performed return link $pslink_1 - PASS\n";           
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return link $pslink_1");
        print FH "STEP: Performed return link $pslink_1 - FAIL\n"; 
        $result = 0; 
        goto CLEANUP;            
    }

#Access V5 mode again to return link
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode again - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode again - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next again
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next' again");
        print FH "STEP: Execute command 'next;next' again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' again - PASS\n";
    }

#Perform return link 1
    if (grep/Done/, $ses_core->execCmd("rts 1")) {
        print FH "STEP: Perform 'rts 1' successfully - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts 1'");
        print FH "STEP: Perform 'rts 1' successfully - FAIL\n";
        $result = 0;
    }

     ######################### MTC on link 2 ###############################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy link 1
    if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy 2")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy 2'");
        print FH "STEP: Execute command 'bsy 2' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } elsif (grep/ManB state/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: The V5 link 2 is already in ManB no action required");
        print FH "STEP: Detected link 2 is already in ManB  - PASS\n";
    }else {
        print FH "STEP: Execute command 'bsy 2' - PASS\n";
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy 2' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy 2'");
            print FH "STEP: Perform 'bsy 2' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    }

#Post GPP into MAPCI PM level
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>/');
    unless (@output=$ses_core->execCmd("mapci;mtc;pm;post $gpp")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in GPP mode - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in GPP mode - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Busy pside message link
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;pm;post $gpp");
    if (grep/Please confirm/, @output=$ses_core->execCmd("bsy link $pslink_2")) {
        unless(grep/Passed/, $ses_core->execCmd("y")){
            $logger->error(__PACKAGE__ . " $tcid: Could not busy link $pslink_2");
            print FH "STEP: Busy link $pslink_2 in GPP mode - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } else {
            print FH "STEP: Busy link $pslink_2 in GPP mode - PASS\n";
        }
    } elsif (grep/Link $pslink_2 is ManB/, @output) {
        $logger->debug(__PACKAGE__ . " $tcid: Link $pslink_2 is already in ManB try to it");
        print FH "STEP: Detected link $pslink_2 is already in ManB - PASS\n";
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Link $pslink_2 is not in properly state");
        $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));
        print FH "STEP: Detected link $pslink_2 is not in properly state - FAIL\n";
    }
#Return pside message link
    $logger->debug(__PACKAGE__ . " $tcid: Trying to return pside link $pslink_2"); 
    $ses_core->{conn}->print("rts link $pslink_2");
    if ($ses_core->{conn}->waitfor(-match => '/Passed/', -timeout => 150)) {
        $logger->debug(__PACKAGE__ . " $tcid: Successfully return link $pslink_2");       
        print FH "STEP: Performed return link $pslink_2 - PASS\n";           
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to return link $pslink_2");
        print FH "STEP: Performed return link $pslink_2 - FAIL\n"; 
        $result = 0; 
        goto CLEANUP;            
    }

#Access V5 mode again to return link
    $ses_core->execCmd("quit all");
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' in V5 mode again - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' in V5 mode again - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next again
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next' again");
        print FH "STEP: Execute command 'next;next' again - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' again - PASS\n";
    }

#Perform return link 1
    if (grep/Done/, $ses_core->execCmd("rts 2")) {
        print FH "STEP: Perform 'rts 2' successfully - PASS\n"; 
    } else {
        $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts 2'");
        print FH "STEP: Perform 'rts 2' successfully - FAIL\n";
        $result = 0;
    }

    ################################## Cleanup 066 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 066 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_067 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_067");
    $logger->debug(__PACKAGE__ . " V5 mode - Verify Trnsl- alarm V5 in mode");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_067";
    $tcid = "ADQ1109_067";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $pslink_1;
    my $pslink_2;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect link 1 and link 2 of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp\s+.*\s+\((\d+)\)\s+\((\d+)\)/) {
            $pslink_1 = $1;
            $pslink_2 = $2;
            print FH "STEP: Link 1 of $gpp is $pslink_1 - PASS\n";
            print FH "STEP: Link 2 of $gpp is $pslink_2 - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect 2 messages link of $gpp");
        print FH "STEP: Detected 2 messages link of $gpp - FAIL\n";
        
    }

#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform Trnsl into MAPCI V5 level
    unless (@output=$ses_core->execCmd("Trnsl")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'Trnsl'");
        print FH "STEP: Execute command 'Trnsl' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'Trnsl' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));

#Verify output of Trnsl command
    foreach(@output){
        if ($_ =~/link  1.*pslink\s+(\d+)/) {
            if ($1 == $pslink_1){
                print FH "STEP: Verified link 1 in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Link 1 does not match");
                print FH "STEP: Verified link 1 in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
        if ($_ =~/link  2.*pslink\s+(\d+)/) {
            if ($1 == $pslink_2){
                print FH "STEP: Verified link 2 in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: Link 2 does not match");
                print FH "STEP: Verified link 2 in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
    }
 
    ################################## Cleanup 067 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 067 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_068 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_068");
    $logger->debug(__PACKAGE__ . " V5 mode - Verify QueryPM in V5 mode");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_068";
    $tcid = "ADQ1109_068";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;
    my $v5id;
    my $v5prid;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Access TABLE GPPTRNSL
    unless (grep /TABLE: GPPTRNSL/, @output = $ses_core->execCmd("TABLE GPPTRNSL")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to access TABLE GPPTRNSL");
        print FH "STEP: Access TABLE GPPTRNSL - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Access TABLE GPPTRNSL - PASS\n";
    }

#Command format pack;list all
    unless (@output = $ses_core->execCmd("format pack;list all")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to list all tuples");
        print FH "STEP: List all tuples - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: List all tuples - PASS\n";
    }

#Detect V5ID and V5PRID of GPP 1
    foreach(@output) {
        if ($_ =~ /$gpp.*\$\s+(\d+)\s+(\d+)/) {
            $v5id = $1;
            $v5prid = $2;
            print FH "STEP: V5ID of $gpp is $v5id - PASS\n";
            print FH "STEP: V5PRID of $gpp is $v5prid - PASS\n";
            $flag = 1;
        }
    }
    unless($flag){
        $logger->error(__PACKAGE__ . " $tcid: Failed to detect V5ID and V5PRID of $gpp");
        print FH "STEP: Detected V5ID and V5PRID of $gpp - FAIL\n";
        
    }

#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform Trnsl into MAPCI V5 level
    unless (@output=$ses_core->execCmd("QueryV5")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'QueryV5'");
        print FH "STEP: Execute command 'QueryV5' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'QueryV5' - PASS\n";
    }
    $logger->error(__PACKAGE__ . " $tcid: ".Dumper(\@output));

#Verify output of QueryV5 command
    foreach(@output){
        if ($_ =~/V5ID\:\s+(\d+)\s+V5PRID\:\s+(\d+)/) {
            if ($1 == $v5id && $2 == $v5prid){
                print FH "STEP: Verified V5ID and V5PRID in output of Trnsl command - PASS\n";
            } else {
                $logger->error(__PACKAGE__ . " $tcid: V5ID and V5PRID does not match");
                print FH "STEP: Verified V5ID and V5PRID in output of Trnsl command - FAIL\n";
                $result = 0;
                goto CLEANUP;
            }
        }
    }
 
    ################################## Cleanup 068 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 068 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_069 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_069");
    $logger->debug(__PACKAGE__ . " V5 mode - Busy and return link 1 & 2");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_069";
    $tcid = "ADQ1109_069";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Perform busy-return link 1 & 2
    foreach(1,2) {
        if (grep/EITHER incorrect/, @output=$ses_core->execCmd("bsy $_")) {
            $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'bsy $_'");
            print FH "STEP: Execute command 'bsy $_' - FAIL\n";
            $result = 0;
            goto CLEANUP;
        } elsif (grep/ManB state/, @output) {
            $logger->debug(__PACKAGE__ . " $tcid: The V5 link $_ is in the ManB state try to return it");
            goto RTS;
        }else {
            print FH "STEP: Execute command 'bsy $_' - PASS\n";   
        }
        if (grep/Done/, $ses_core->execCmd("y")) {
            print FH "STEP: Perform 'bsy $_' successfully - PASS\n";
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'bsy $_'");
            print FH "STEP: Perform 'bsy $_' successfully - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    RTS:    
        if (grep/Done/, $ses_core->execCmd("rts $_")) {
            print FH "STEP: Perform 'rts $_' successfully - PASS\n"; 
        } else {
            $logger->error(__PACKAGE__ . " $tcid: Failed to perform 'rts $_'");
            print FH "STEP: Perform 'rts $_' successfully - FAIL\n";
            $result = 0;
        }
        sleep(5);
        
    }
 
    ################################## Cleanup 019 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 019 ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
}

sub ADQ1109_070 {
    $logger->debug(__PACKAGE__ . " Inside test case ADQ1109_070");
    $logger->debug(__PACKAGE__ . " V5 mode - Busy and return link 1 & 2");

    ########################### Variables Declaration #############################
    my $sub_name = "ADQ1109_070";
    $tcid = "ADQ1109_070";
    my $execution_logs = $tcid.'_ExecutionLogs_'.$datestamp.'.txt';
    my $result = 1;
    my $gpp = "GPP 1";
    my $flag = 0;
    my $logutil_start = 0;

    open(FH,'>',$execution_logs) or die $!;
    move($dir."/".$execution_logs,"/home/".$user_name."/ats_user/logs/ADQ1109");

    ################## LOGIN ##############
    my $thr1 = threads->create(\&core);
    my $thr2 = threads->create(\&logutil);
    $ses_core = $thr1->join();
    $ses_logutil = $thr2->join();

    unless ($ses_core->loginCore(%core_account)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not access TMA20 Core");
        print FH "STEP: Login TMA20 core - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login TMA20 core - PASS\n";
    }

    #Start logutil
    %input = (
                -username => [@{$core_account{-username}}[5..9]], 
                -password => [@{$core_account{-password}}[5..9]], 
                -logutilType => ['SWERR', 'TRAP', 'AMAB'],
             );
    unless ($ses_logutil->startLogutil(%input)) {
        $logger->error(__PACKAGE__ . " $tcid: Could not start logutil");
        print FH "STEP: Start logutil - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Start logutil - PASS\n";
    }
    $logutil_start = 1;

    ############### Test Specific configuration & Test Tool Script Execution #################
#Post V5 interface of GPP 1 into MAPCI
    $ses_core->{conn}->prompt('/\>$/');
    unless (@output=$ses_core->execCmd("mapci;mtc;ccs;v5;post s act")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execution cmd 'post'");
        print FH "STEP: Execution cmd 'post' - FAIL\n";
        $result = 0;
    } else {
        print FH "STEP: Execution cmd 'post' - PASS\n";
    }
    
    foreach(@output){
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+H[^a-zA-Z0-9,]//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]K//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]8//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]7//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]\d+;\d+m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]0m//g;
        $_ =~ s/[^a-zA-Z0-9, _, :]//g;      
    }

#Execute command next;next
    $ses_core->execCmd("quit all");
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    unless ($ses_core->execCmd("next;next")) {
        $logger->error(__PACKAGE__ . " $tcid: Failed to execute command 'next;next'");
        print FH "STEP: Execute command 'next;next' - FAIL\n";
        $result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Execute command 'next;next' - PASS\n";
    }

#Deact V5 interface
    $ses_core->execCmd("mapci nodisp;mtc;ccs;v5;post s act");
    if (grep/Please confirm/, @output=$ses_core->execCmd("deact")) {
        if (grep/Done||progress/, $ses_core->execCmd("y")) {
            print FH "STEP: Deacted V5 interface - PASS\n";
        } else {
            print FH "STEP: Deacted V5 interface - FAIL\n";
            $result = 0;
            goto CLEANUP;
        }
    } else {
        $logger->error(__PACKAGE__ . " $tcid: An error occured please check related logs");
        print FH "STEP: An error occurd - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }
    sleep(5);

#Return V5 interface
    foreach(1,2,3,4) {
        unless (grep/timeout(.*)required/,@output=$ses_core->execCmd("act")) {
            print FH "STEP: Check 2 mins timeout - PASS\n";
        }
        if (grep/Please confirm/, @output) {
            if (grep/Done||interface||progress/, $ses_core->execCmd("y")) {
                print FH "STEP: Acted V5 interface - PASS\n";
                $flag = 1;
            }
        }      
        sleep(40);
    }

    unless ($flag) {
        print FH "STEP: Acted V5 interface - FAIL\n";
        $result = 0;
        goto CLEANUP;
    }

    ################################## Cleanup 020 ##################################
    CLEANUP:
    $logger->debug(__PACKAGE__ . " $tcid: ################################ Cleanup 020  ##################################");

    #Stop Logutil
    if ($logutil_start) {
        unless ($ses_logutil->stopLogutil()) {
            $logger->error(__PACKAGE__ . " $tcid: Could not stop logutil ");
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
        unless ((grep /Log empty/, @output) or grep /TDLDPR|CXNADDRV|MTCAUXP|PDNP|CALLP|SYSAUDP|TFP03MOD/, @output) {
            $logger->error(__PACKAGE__ . " $tcid: Swerr is generated on core ");
            $result = 0;
            print FH "STEP: Check SWERR - FAIL\n";
        } else {
            print FH "STEP: Check SWERR - PASS\n";
        }
    }

    close(FH);
    &ADQ1109_cleanup();
    # check the result var to know the TC is passed or failed
    &ADQ1109_checkResult($tcid, $result);
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