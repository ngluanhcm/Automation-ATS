#!/ats/bin/perl 

use strict; 
use warnings;

      
use Log::Log4perl qw(get_logger :levels);

use QATEST::C20_EO::Luan::Automation_ATS::DEAP::DEAP; 

#####################################
# TESTS
#####################################

our $TESTSUITE;

$TESTSUITE->{TESTED_RELEASE} = "GBV.R20_BRC";
$TESTSUITE->{BUILD_VERSION} = "C20-CORE_vsnw17ch";
$TESTSUITE->{TESTED_VARIANT} = "ADQ_1183";

$TESTSUITE->{PATH} = '/home/ylethingoc/ats_user/logs/DEAP'.$TESTSUITE->{TESTED_RELEASE};   # CGE Log Path to Store Server logs and Core Files. 

# NOTE: Email ID of test suite executer is added by default.
$TESTSUITE->{EMAIL_LIST}	= [
    'ntluan2@tma.com.vn'
];   # Email Group


our $release = $TESTSUITE->{TESTED_RELEASE};
our $build = $TESTSUITE->{BUILD_VERSION};
our @emailList	= @{$TESTSUITE->{EMAIL_LIST}};

print "************  RELEASE	==> $release \tBUILD ==> $build \n";
print "************  EMAIL_LIST ==> @emailList\n";

#####################################
# EXECUTION OF TESTS
#####################################

&QATEST::C20_EO::Luan::Automation_ATS::DEAP::DEAP::runTests;  ################  For running all tests #########################

#&QATEST::C20_EO::Luan::Automation_ATS::DEAP::DEAP::runTests("TC5");  ################  For running selective tests #########################

1;
