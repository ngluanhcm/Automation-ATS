Array:

	my @list_dn = ($db_list_dn[0], $db_list_dn[1], $db_list_dn[2]);
	can also write:
	my @list_dn = (@db_list_dn[0..2]);

Improve sub Cleanup

	sub DEMO_cleanup {
		my $subname = "DEMO_cleanup";
		$logger->debug(__PACKAGE__ ." . $subname . DESTROYING OBJECTS");
		my @end_ses = (
						$ses_core, $ses_glcas, $ses_logutil, 
						$ses_tapi, $ses_swact, $ses_dnbd,
						); #Put all sessions of suite here
		foreach (@end_ses) {
			if (defined $_) {
				$_->DESTROY();
				undef $_;
			}
		}
		return 1;
	}
	
Make line status into MB in mapci:

	Ex: Change line DN B status into MB in Mapci: 
		command: 'mapci nodisp; mtc; lns; ltp; post d <DN B> print'
		then command: 'bsy'

Parallel in session creation: refer ADQ_730.pm

