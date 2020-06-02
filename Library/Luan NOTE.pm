#-------------------------------------------------------------------------------------#
#									MANDATORY PART 									  #
#-------------------------------------------------------------------------------------#


#**************************************************************************************************#
#FEATURE                : <FEATURE NAME> 
#FEATURE ENGINEER       : <FEATURE ENGINEER NAME>
#AUTOMATION ENGINEER    : <AUTOMATION ENGINEER NAME>
#**************************************************************************************************#

our %TESTBED;
our $TESTSUITE;

package QATEST::AS::TEMPLATE::Demo::DEMO; # Replace this by your <Feature.pm>

use strict;
use Tie::File;
use File::Copy;
use Cwd qw(cwd);
use threads;
#********************************* LIST OF LIBRARIES***********************************************#

use ATS;
use SonusQA::Utils qw (:all);

#**************************************************************************************************#

use Log::Log4perl qw(get_logger :levels);
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

##################################################################################
#  SOAP_UI::TEMPLATE                                                             #
##################################################################################
#  This package  tests for the SOAP_UI.                                          #
##################################################################################

##################################################################################
# SETUP                                                                          #
##################################################################################

our $dir = cwd;
our ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst) = localtime(time);
our $datestamp = sprintf "%4d%02d%02d-%02d%02d%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;


# Required Testbed elements for this package

my %REQUIRED = ( 
        "AS"  => [1],
		"SIPP" => [1],
		"C3" => [1],
               );

################################################################################
# SIPP VARIABLES USED IN THE SUITE Defined HERE#
################################################################################

##################################################################################
sub configured {
##################################################################################

    # Check configured resources match REQUIRED
    if ( SonusQA::ATSHELPER::checkRequiredConfiguration ( \%REQUIRED, \%TESTBED ) ) {
        $logger->info(__PACKAGE__ . ": Found required devices in TESTBED hash"); 
    }else{
        $logger->error(__PACKAGE__ . ": Could not find required devices in TESTBED hash"); 
        return 0;
	}
}

##################################################################################
# TESTS                                                                          #
##################################################################################

our @TESTCASES = (
                     "TC1",
					 "TC2",
                );

############# User Input #########################################################

my $ats = SonusQA::Utils::resolve_alias($TESTBED{ "as:1:ce0"});
my $ip_ats = $ats->{MGMTNIF}->{1}->{IP};
$logger->debug(__PACKAGE__ . "IP ATS is $ip_ats");	
my $c3 = SonusQA::Utils::resolve_alias($TESTBED{ "c3:1:ce0"});
my $ip = $c3->{MGMTNIF}->{1}->{IP};
my $user = $c3->{LOGIN}->{1}->{USERID};
my $passwd = $c3->{LOGIN}->{1}->{PASSWD};
$logger->debug(__PACKAGE__ . "IP C3 Tampa is $ip");
$logger->debug(__PACKAGE__ . "Username C3 Tampa is $user");
$logger->debug(__PACKAGE__ . "Password C3 Tampa is $passwd");

					

##################################################################################
sub runTests {
##################################################################################

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
# |   SOAP_UI_trialtc                                                            |
# +------------------------------------------------------------------------------+
# |   TMSID = "351207"                                                           |
# +------------------------------------------------------------------------------+
# +------------------------------------------------------------------------------+
		
sub TC1 {   
    $logger->debug(__PACKAGE__ . " Inside test case TC1 #############################################");
    my $sub_name = "TC1";
    my $tcid = "TC1";
    my $Result = 1;
    my $filename = "$tcid"."_ExecutionLogs_".$datestamp.'.txt';
    open(FH,'>',$filename) or die $!;
    move($dir."/".$filename,"/home/$ENV{ USER }/ats_user/logs/DEMO");

    $logger->info(__PACKAGE__ ."########################## CREATE SESSIONS #################################" );
	
#-------------------------------------------------------------------------------------#
#										CONTENT OF TC								  #
#-------------------------------------------------------------------------------------#
	
    ######### CLEANUP RESOURCE #################################" );
    close FH;
    $tma15->DESTROY;
    $logger->info(__PACKAGE__ . " ======: -------------------------------------------------");
	# check the Result var to know the TC is passed or failed
    if ($Result) { 
		$logger->debug(__PACKAGE__ . "$tcid  Test case passed ");
                SonusQA::ATSHELPER::printPassTest($tcid);
                return 1;
	}else {
		$logger->debug(__PACKAGE__ . "$tcid  Test case failed ");
                SonusQA::ATSHELPER::printFailTest($tcid);
                return 0;
	}
}

#-------------------------------------------------------------------------------------#
#								SET PROMPT & TIMEOUT								  #
#-------------------------------------------------------------------------------------#

$session_ats->{conn}->prompt('/\:/');	
$session_ats->{conn}->prompt($session_ats->{DEFAULTPROMPT});
$session_ats->{DEFAULTTIMEOUT} = 1100;
$self->{PROMPT} = '/.*[\$%#\}\)\|\>\]].*$/';


#-------------------------------------------------------------------------------------#
#								CREATE NEW SESSIONS									  #
#-------------------------------------------------------------------------------------#

	#ssh to ATS_AS
    my $session_ats; 
    unless ($session_ats = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_ATSLog")){
		$logger->error(__PACKAGE__ . ": Could not create new session for ATS_auto");
		print FH "STEP: Login ATS server FAIL - FAIL\n";
		return 0;              
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully create new session fo ATS_auto");
		print FH "STEP: Login ATS server PASS - PASS\n";
    }
	
#-------------------------------------------------------------------------------------#
#					IN THIS SESSION SSH TO ANOTHER SERVER							  #
#-------------------------------------------------------------------------------------#	

#------------------------------ use execCmd ------------------------------------------#
	#ssh to C3_tampa
	$session_ats->{conn}->prompt("/\:/");
	unless (grep /password/, $session_ats->execCmd("ssh $userid\@$ip_c3")){
		$logger->error(__PACKAGE__ . ": Could not ssh to C3_tampa");
		print FH "STEP: SSH to C3_tampa server fail - FAILED\n";
		return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully ssh to C3_tampa, waitting for user enter password");
		print FH "STEP: SSH to C3_tampa server pass - PASS\n";
		
	}	
    
	#enter password
	$session_ats->{conn}->prompt($session_ats->{DEFAULTPROMPT});
	unless (grep /Last login/, $session_ats->execCmd($passwd)){
		$logger->error(__PACKAGE__ . ": The input password is incorect, fail to login into C3_tampa");
		print FH "STEP: Login into C3_tampa fail - FAIL\n";
		return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully login into to C3_tampa");
		print FH "STEP: Login into C3_tampa pass - PASS\n";
	}

#------------------------------ use print + waitfor -----------------------------------#

	#ssh to C3_tampa   
	$session_ats->{conn}->print("ssh $userid\@$ip_c3");	
	unless($session_ats->{conn}->waitfor(-match => '/password:/')) {
		$logger->error(__PACKAGE__ . ": Could not ssh to C3_tampa");
		print FH "STEP: SSH to C3_tampa server fail - FAILED\n";
		return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully ssh to C3_tampa, waitting for user enter password");
		print FH "STEP: SSH to C3_tampa server pass - PASS\n";
	}
	
	#enter password
	$session_ats->{conn}->print("$passwd");
	unless ($session_ats->{conn}->waitfor(-match => '/Last login:/')){
		$logger->error(__PACKAGE__ . ": The input password is incorect, fail to login into C3_tampa");
		print FH "STEP: Login into C3_tampa fail - FAIL\n";
		return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully login into to C3_tampa");
		print FH "STEP: Login into C3_tampa pass - PASS\n";
	}
	
	
#-------------------------------------------------------------------------------------#
#										BASIC SIPP							  		  #
#-------------------------------------------------------------------------------------#	

	#create new session for UAS
    my $session_uas; 
    unless ($session_uas = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0"},-sessionLog => "$tcid"."_UASLog")){
		$logger->error(__PACKAGE__ . ": Could not create new session for UAS");
		print FH "STEP: Create new session for UAS fail - FAIL\n";
		return 0;              
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully create new session for UAS");
		print FH "STEP: Create new session for UAS PASS - PASSED\n";
    }
    
	#create new session for UAC
    my $session_uac; 
    unless ($session_uac = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "sipp:1:ce0"},-sessionLog => "$tcid"."_UACLog")){
		$logger->error(__PACKAGE__ . ": Could not create new session for UAC");
		print FH "STEP: Create new session for UAC fail - FAIL\n";
		return 0;              
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully create new session for UAS");
		print FH "STEP: Create new session for UAC PASS - PASS\n";
    }
    
    #make call for UAS
    my $uasCmd = ' /usr/local/sipp-3.3/sipp -sf "/usr/local/sipp-3.3/ADQ737/uas.xml" -i 172.20.248.141 -p 20443';
    unless ($session_uas->startCustomServer($uasCmd)) {
		$logger->error(__PACKAGE__ . ": Could not start custom server");
		print FH "STEP: Start custom server fail- FAIL\n";
		return 0;              	    
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully start custom server");
		print FH "STEP: Start custom server pass - PASS\n";
    }
	
	#make call for UAC
    my $uacCmd = '/usr/local/sipp-3.3/sipp -sf "/usr/local/sipp-3.3/ADQ737/uac.xml" -i 172.20.248.141 -p 20442 172.20.47.194 -m 1';
    unless ($session_uac->startCustomClient($uacCmd)) {
		$logger->error(__PACKAGE__ . ": Could not start custom client");
		print FH "STEP: Start custom client fail- FAIL\n";
		return 0;    
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully start custom client");
		print FH "STEP: Start custom client pass - PASS\n";
    }
    
	#waiting for the call complete
    unless ($session_uac->waitcompletionClient(60)){
		$logger->error(__PACKAGE__ . ": Call fail");
		print FH "STEP: Call fail- FAIL\n";
		return 0;
    } else {
		$logger->debug(__PACKAGE__ . ": Call pass");
		print FH "STEP: Call pass - PASS\n";
    }
	
#-------------------------------------------------------------------------------------#
#									EXECUTE COMMAND							  		  #
# 			NOTE :Alsway checking the ouput to set the corect prompt				  #
#-------------------------------------------------------------------------------------#	

	#execution command & dont care the output
    unless (grep /\//, $session_c3->execCmd("cd /root/Auto/ADQ787")) {
		$logger->error(__PACKAGE__ . " : Execute command 'cd /root/Auto/ADQ787' fail");
		print FH "STEP: Execute command 'cd /root/Auto/ADQ787' fail - FAIL\n";
        return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Execute command 'cd /root/Auto/ADQ787' pass");
		print FH "STEP:  Execute command 'cd /root/Auto/ADQ787' pass - PASS\n";
		print FH "The current directory is: @arrResult\n";
	}
	
	#execution command then take care the output
	my @arrResult = $session_c3->execCmd("cd /root/Auto/ADQ787");
    unless (grep /\//, @arrResult) {
		$logger->error(__PACKAGE__ . " : Execute command 'cd /root/Auto/ADQ787' fail");
		print FH "STEP: Execute command 'cd /root/Auto/ADQ787' fail - FAIL\n";
        return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Execute command 'cd /root/Auto/ADQ787' pass");
		print FH "STEP:  Execute command 'cd /root/Auto/ADQ787' pass - PASS\n";
		print FH "The current directory is: @arrResult\n";
	}
	
#-------------------------------------------------------------------------------------#
#							enterRootSessionViaSU() in Base.pm				  		  #
#			This function will enter the linux root session via Su command			  #
#	 		This function also enters root session via sudo command			  	      #
#-------------------------------------------------------------------------------------#	

	unless ($session_c3->enterRootSessionViaSU( )) {
        $logger->debug(__PACKAGE__ . " : Could not enter root session");
		print FH "STEP: Enter su root mode fail - FAIL\n";
        return 0;
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully enter root session");
		print FH "STEP: Enter su root mode pass - PASS\n";
	}

    #or

    unless ($session_c3->enterRootSessionViaSU('sudo')) {
        $logger->debug(__PACKAGE__ . " : Could not enter root session");
		print FH "STEP: Enter su root mode fail - FAIL\n";
        return 0;
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully enter root session");
		print FH "STEP: Enter su root mode pass - PASS\n";
	}
	
#-------------------------------------------------------------------------------------#
#								parseLogFiles() in Base.pm					  	      #
#		This function used to check the Pattern in the given log file				  #
#		NOTE: @parse contains the finding content, the name of file is put in ''      #
#-------------------------------------------------------------------------------------#		
	
	#verify 'huong_auto_test' file contains 'initialAdminPassword'
	my @parse = ("initialAdminPassword");
    unless ($session_c3->parseLogFiles('huong_auto_test', @parse)) {
		$logger->error(__PACKAGE__ . " : huong_auto_test does not contain initialAdminPassword");
		print FH "STEP: Verify initialAdminPassword in huong_auto_test fail - FAIL\n";
        return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": huong_auto_test contains initialAdminPassword");
		print FH "STEP:  Verify initialAdminPassword in huong_auto_test pass - PASS\n";
	}
	
#-------------------------------------------------------------------------------------#
#							sftpFromRemote() in Utils.pm							  #
#    This function copies the file(s) from the specified remote directory on the      #
#   	remote server to the specified directory on the local server                  #
#-------------------------------------------------------------------------------------#		
	
	#open new session for ATS_AS
	my $session_ats; 
    unless ($session_ats = SonusQA::ATSHELPER::newFromAlias(-tms_alias => $TESTBED{ "as:1:ce0"},-sessionLog => "$tcid"."_ATSLog")){
		$logger->error(__PACKAGE__ . ": Could not create new session for ATS");
		print FH "STEP: Create new session for ATS fail - FAIL\n";
		return 0;              
    } else {
		$logger->debug(__PACKAGE__ . ": Successfully create new session for ATS");
		print FH "STEP: Create new session for ATS pass - PASS\n";
    }
	
	#transfer 'huong_auto_test' file from C3 server to ATS log folder --> that means we stand at ATS server 
	#and get file from C3 server.
	my %args;
	$args{-remoteip}       	= <IP>;
	$args{-remoteuser}     	= <username>;
	$args{-remotepasswd} 	= <password>;
	$args{-remoteFilePath} 	= "/root/huong_auto_test";
	$args{-localDir}       	= "/home/ylethingoc/ats_user/logs/DEMO";
	
	unless ($session_ats = &SonusQA::Utils::sftpFromRemote(%args)) {
		$logger->error(__PACKAGE__ . " : Could not copy file from C3 to ATS");
		print FH "STEP: Transfer file fail - FAIL\n";
        return 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Successfully copy file from C3 to ATS");
		print FH "STEP:  Transfer file pass - PASS\n";
	}
  
#-------------------------------------------------------------------------------------#
# 									Login into Core TMA15		 					  #
#-------------------------------------------------------------------------------------#	  
my $core_tma15;
    $core_tma15->{conn}->print("telnet cm");
    unless ($core_tma15->{conn}->waitfor(-match => '/Enter username and password/', -timeout => 10)) {
        $logger->error(__PACKAGE__ . ".$sub_name: Didn't get 'Enter username and password' prompt after entering 'telnet cm'");
        print FH "STEP: get 'Enter username and password' prompt after entering 'telnet cm' - FAILED\n";
        $Result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: get 'Enter username and password' prompt after entering 'telnet cm' - PASSED \n";
    }
    $core_tma15->{conn}->waitfor(-match => '/>/', -timeout => 5);

    unless (grep /LUAN5 Logged in/, $core_tma15 -> execCmd ("luan5 luan5")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Can't login to core ");
        print FH "STEP: Login core - FAILED\n";
        $Result = 0;
        goto CLEANUP;
    } else {
        print FH "STEP: Login core - PASSED \n";
    }
#-------------------------------------------------------------------------------------#
# 		            	Regular expression                            				  #
#-------------------------------------------------------------------------------------#	
\s : space
\d : digit
\l : lower
\u : upper
\w : word

. : anything
* : 0 or more
+ : 1 or more
| : or
(): group
[Aa]b: Ab or ab
i: insensitive

\D : ^digit

Date is  THU.  07/NOV/2019  11:44:43
my ($m, $d, $h, $y) = $show_date[0] =~ /\w+\s+(\w+)\s+(\d+)\s+(\d{2}):\d{2}:\d{2}\s+\w+\s+(\d+)/g;
		print FH "Hour =", $h, "\n";
		print FH "Day =", $d, "\n";
		print FH "Month =", $m, "\n";
		print FH "Year =", $y, "\n";


rex 1 digig =~/\b\d\b/g;

#delete values in arr
my $input_Color = 'Green';
my @array = qw(Red Blue Green Yellow Black);
@array = grep {!/$input_Color/} @array; // delete Green 
print "@array" =>>Red Blue Yellow Black

my @arr = qw/0 1 22 333 4444 55555 666666 7777777/;
@arr = grep {!/\b\d\b/} @arr; => 22 333 4444 55555 666666 7777777
@arr = grep {/\b\d\b/} @arr; => 0 1
print "@arr"; 

#-------------------------------------------------------------------------------------#
#					        SET prompt			          							  #
#-------------------------------------------------------------------------------------#
$ses_c20->{conn}->prompt('/\]\#/');
#-------------------------------------------------------------------------------------#
#					Arrays (push, pop, shift, unshift)								  #
#-------------------------------------------------------------------------------------#
@x = ('Java', 'C', 'C++');
push(@x, 'Python', 'Perl');  	Inserts values of the list at the end of an array // them phan tu vao cuoi array
pop(@x); 	Removes the last value of an array //xoa phan tu o cuoi array
shift(@x); 	Shifts all the values of an array on its left // lay phan tu o dau array ra
unshift(@x, 'PHP', 'JSP'); 	Adds the list element to the front of an array // chen phan tu vao dau array

#-------------------------------------------------------------------------------------#
# 			ExecCmd Input table, list all and take value in output 					  #
#-------------------------------------------------------------------------------------#	
    unless (grep /TABLE: OFRT/, $core_tma15 -> execCmd ("table ofrt")) {
        $logger->error(__PACKAGE__ . ".$sub_name: Can't Execute command 'table ofrt' ");
        print FH "STEP: Execute command 'table ofrt' - FAILED\n";
        $Result = 0;
    } else {
        print FH "STEP: Execute command 'table ofrt' - PASSED \n";
    }
    $core_tma15->{conn}->prompt('/BOTTOM/');	#doi cho den khi thay 'BOTTOM' thi dung`
    my @arrResult, ;
    unless (grep /T15SSTIBNT2LP/, @arrResult = $core_tma15 -> execCmd ("format pack ; list all")) { # tim T15SSTIBNT2LP trong output
        $logger->error(__PACKAGE__ . ".$sub_name: Can't Execute command 'format pack ; list all' ");
        print FH "STEP: Execute command 'format pack ; list all' - FAILED\n";
        $Result = 0;
    } else {
        print FH "STEP: Execute command 'format pack ; list all' - PASSED \n";
    }

    #Take some value in output and put in $_

    for (@arrResult) { #778 (N D T15SSTIBNT2LP
        if ($_ =~ /(\d+).*T15SSTIBNT2LP/) {
            $logger->info(__PACKAGE__ . ".$sub_name: Access code of trunk T15SSTIBNT2LP is :  $1 ");
            print FH "STEP: Access code of trunk T15SSTIBNT2LP is :  $1 \n";
            last;
        }
    }

#-------------------------------------------------------------------------------------#
# 			Execute command traver l 2124411019 4411020 b 		         			  #
#-------------------------------------------------------------------------------------#
 $ses_c20->{conn}->prompt('/TREATMENT ROUTES/');
    my @arrResult, ;
    unless (grep /SUCCESSFUL/, @arrResult = $ses_c20 -> execCmd ("traver l 2124411019 4411020 b")) { # tim T15SSTIBNT2LP trong output
        $logger->error(__PACKAGE__ . ".$sub_name: Can't Execute command 'traver l 2124411019 4411020 b' ");
        print FH "STEP: Execute command 'traver l 2124411019 4411020 b' - FAILED\n";
        $Result = 0;
    } else {
        print FH "STEP: Execute command 'traver l 2124411019 4411020 b' - PASSED \n";
    }
#-------------------------------------------------------------------------------------#
# 			verify the destination of this route (Result : 2124411020) 		          #
#-------------------------------------------------------------------------------------#
for (@arrResult) { #1 LINE                  2124411020                   ST
        if ($_ =~ /LINE\s*(\d+)\s*/) {
            $logger->info(__PACKAGE__ . ".$sub_name: destination of this route is :  $1 ");
            print FH "STEP: destination of this route is :  $1 \n";
        last;
        } 
    }

#-------------------------------------------------------------------------------------#
# 							remoteToRemoteCopy() in Utils.pm		 				  #
#		This function copies the files from remote source to remote destination       #
#							This function auto create new session					  #
#-------------------------------------------------------------------------------------#	  
	
	#put file SESM1_0_2015-12-02-00-16-04-126_All_MCPV4.closed from 172.28.219.217 to 172.28.218.19
    $rtrCopyArgs{-remoteip}      = "172.28.219.217";
    $rtrCopyArgs{-remoteuser}    = "root";
    $rtrCopyArgs{-remotepasswd}  = "li69nux";
	$rtrCopyArgs{-sourceFilePath} = "/export/home/medadmin/sampleData/A2-IPDR/SESM1_0_2015-12-02-00-16-04-126_All_MCPV4.closed";
    $rtrCopyArgs{-recvrip}       = "172.28.218.19";
    $rtrCopyArgs{-recvruser}     = "root";
    $rtrCopyArgs{-recvrport}     = "22";
    $rtrCopyArgs{-recvrpassword} = "li69nux";
	$rtrCopyArgs{-destinationFilePath} = "/export/meddata";

#-------------------------------------------------------------------------------------------#
# 		Configure remote server, replace ott14 with your name password is li69nux           #
# “swbkpconf add remote-host ott14 172.29.31.20 root /root/backup image rhel creation-only” #
#-------------------------------------------------------------------------------------------#	

#configure remote server
	CREATE:
	$session_nsp2->{conn}->prompt('/password:|exists/');
	my @arr_config = $session_nsp2->execCmd("swbkpconf add remote-host ott14 172.29.31.20 root /root/backup image rhel creation-only");
	if (grep /Enter/, @arr_config) {	
		$logger->debug(__PACKAGE__ . ": successfully execute command waiting for user input");
		print FH "STEP: Execution command configure remote server pass - PASS\n";
	} elsif (grep /Remote host id/, @arr_config) { #if the remote server already exists, try to remove -> re-add
		$logger->error(__PACKAGE__ . ": Remote host id: ott14 already exists, try to remove -> re-add");
		$session_nsp2->{conn}->prompt('/\?/');
		if (grep /Yes/,$session_nsp2->execCmd("swbkpconf delete remote-host ott14")) {
			$session_nsp2->{conn}->prompt($session_nsp2->{DEFAULTPROMPT});
			if (grep /Scheduled job deleted/, $session_nsp2->execCmd("Yes")) {
				goto CREATE;
			}
		}
	} elsif (grep /swadm appears to be busy with another operation/,  @arr_config ) { #if swadm appears to be busy with another operation
		$logger->error(__PACKAGE__ . ": swadm appears to be busy with another operation, please try again later.");
		$Result = 0;
		print FH "STEP: Server busy cannot create image backup - FAIL"
	} else {
		$logger->error(__PACKAGE__ . ": cannot execute command 'swbkpconf add remote-host'");
		print FH "STEP: Execute command 'swbkpconf add remote-host' fail - FAIL\n";
		return = 0;
	}
	
	#create password
	unless (grep /Confirm/, $session_nsp2->execCmd("li69nux")) {
		$logger->error(__PACKAGE__ . ": enter password fail");
		print FH "STEP: Enter password fail - FAIL\n";
		$Result = 0;
	} else {
		$logger->debug(__PACKAGE__ . ": enter password successfully");
		print FH "STEP: Enter password pass - PASS\n";
	}
	
	#confirm password
	$session_nsp2->{conn}->prompt($session_nsp2->{DEFAULTPROMPT}); 
	unless ($session_nsp2->execCmd("li69nux")) {
		$logger->error(__PACKAGE__ . ": Configure remote server failure");
		print FH "STEP: Configure remote server fail - FAIL\n";
		$Result = 0;
	} else {
		$logger->debug(__PACKAGE__ . ": Configure remote server successfully");
		print FH "STEP: Configure remote server pass - PASS\n";
	}