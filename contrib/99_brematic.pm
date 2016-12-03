##############################################
# $Id: myUtilsTemplate.pm 7570 2015-01-14 18:31:44Z rudolfkoenig $
#
# Save this file as 99_myUtils.pm, and create your own functions in the new
# file. They are then available in every Perl expression.

package main;

use strict;
use warnings;
use POSIX;
use CGI qw(:standard);
use IO::Socket;
use MIME::Base64;
use Time::Piece;
use Switch;

sub brennenstuhl($$$) {
	my ( $Master, $Slave, $action ) = @_;
	my $SendData = "";

	my $txversion = 2;

	my $AN     = "1,3,1,3,3";
	my $AUS    = "3,1,1,3,1";
	my $bitLow = 1;
	my $bitHgh = 3;
	my $seqLow = $bitHgh . "," . $bitHgh . "," . $bitLow . "," . $bitLow . ",";
	my $seqHgh = $bitHgh . "," . $bitLow . "," . $bitHgh . "," . $bitLow . ",";
	my $i      = 0;
	my $bit    = "";
	my $msg    = "";

	my $bits = $Master;
	for ( $i = 0 ; $i < length($bits) ; $i++ ) {
		$bit = substr( $bits, $i, 1 );
		if ( $bit == "0" ) {
			$msg = $msg . $seqLow;
		}
		else {
			$msg = $msg . $seqHgh;
		}
	}
	my $msgM = $msg;

	$bits = $Slave;

	$msg = "";
	for ( $i = 0 ; $i < length($bits) ; $i++ ) {
		$bit = substr( $bits, $i, 1 );
		if ( $bit == "0" ) {
			$msg = $msg . $seqLow;
		}
		else {
			$msg = $msg . $seqHgh;
		}
	}
	my $msgS = $msg;

	return ( $action eq "on" )
	  ?	  "$bitLow,$msgM$msgS$bitHgh,$AN$txversion"
	  : "$bitLow,$msgM$msgS$bitHgh,$AUS$txversion";

}

# handles command creation for intertechno power adaptors
sub intertechno ($$$) {
	my ( $c_master, $c_slave, $action ) = @_;
	my $c_bitLow = "4";
	my $c_bitHgh = "12";

	my $c_seqLow = "$c_bitLow,$c_bitHgh,$c_bitLow,$c_bitHgh,";
	my $c_seqHgh = "$c_bitLow,$c_bitHgh,$c_bitHgh,$c_bitLow,";

	my $c_ON  = "$c_seqHgh$c_seqHgh";
	my $c_OFF = "$c_seqHgh$c_seqLow";

	my $c_additional   = "$c_seqLow$c_seqHgh";
	my $c_tx433version = "1,";

	my $c_seqMaster = "";
	my $c_seqSlave  = "";
	my $c_seqCmd    = "";

	#Setting master id
	# A=0000
	# B=1000
	# C=0100 etc.
	for ( $b = 0 ; $b < 4 ; $b++ ) {
		if ( ( ( ord($c_master) - ord("A") ) >> $b ) & 1 ) {
			$c_seqMaster = "$c_seqMaster$c_seqHgh";
		}
		else {
			$c_seqMaster = "$c_seqMaster$c_seqLow";
		}
	}

	#Setting slave id
	# 1=0000
	# 2=1000
	# 3=0100 etc.
	for ( $b = 0 ; $b < 4 ; $b++ ) {
		if ( ( ( ord($c_slave) - ord("1") ) >> $b ) & 1 ) {
			$c_seqSlave = "$c_seqSlave$c_seqHgh";
		}
		else {
			$c_seqSlave = "$c_seqSlave$c_seqLow";
		}
	}

	$c_seqCmd = ( $action eq "on" ) ? "$c_ON" : "$c_OFF";

	return "$c_seqMaster$c_seqSlave$c_additional$c_seqCmd$c_tx433version";
}

# inspired by https://github.com/Power-Switch/PowerSwitch_Android/blob/8b4e20859303c5cf225e41e5b1149e4a55aa39dd/Smartphone/src/main/java/eu/power_switch/obj/receiver/device/intertechno/CMR1000.java
sub brematic ($$$$) {
	my ( $plug_type, $c_master, $c_slave, $action ) = @_;
	my $c_ip           = "192.168.178.142";
	my $c_port         = "49880";
	my $c_A            = "0";
	my $c_G            = "0";
	my $c_repeat       = "12";
	my $c_pause        = "11125";
	my $c_tune         = "89";
	my $c_baud         = "25";
	my $c_speed        = "4";
	my $c_speedConnAir = "140";

	my $c_headConnAir = "TXP:0,0,6,11125,89,25,";
	my $c_tailConnAir = "$c_speedConnAir;";

	my $SendData = "";
	my $command  = "";

	switch ($plug_type) {
		case "INTERTECHNO" {
			$command = intertechno( $c_master, $c_slave, $action );
		}
		case "BRENNENSTUHL" {
			$command = brennenstuhl( $c_master, $c_slave, $action );
		}
	}

	$SendData = "$c_headConnAir$command$c_tailConnAir";

	my ( $socket, $data );

	# We call IO::Socket::INET->new() to create the UDP Socket
	$socket =
	  new IO::Socket::INET( PeerAddr => "$c_ip:$c_port", Proto => 'udp' )
	  or die "ERROR in Socket Creation : $!\n";
	$socket->send($SendData);
	$socket->close();
}
#brematic("INTERTECHNO", "A", "3", "on" );

1;
