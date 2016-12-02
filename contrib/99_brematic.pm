##############################################
# my definitions for using the brennenstuhl brematic home automation GW 433 
#
# Steffen Sperling
# 

package main;

use strict;
use warnings;
use POSIX;
use CGI qw(:standard);
use IO::Socket;
use MIME::Base64;
use Time::Piece;

$main::NextUpdate = ();

sub
myUtils_Initialize($$)
{
  my ($hash) = @_;
}

# Enter you functions below _this_ line.
sub connair($$$){
my ($Master,$Slave,$action) = @_;
my  $SendData="";
my    $sA=0;
my    $sG=0;
my    $sRepeat=10;
my    $sPause=5600;
my    $sTune=350;
my    $sBaud=25;
my    $sSpeed=16;
my    $uSleep=800000;
my    $txversion=2;
my    $HEAD="TXP:$sA,$sG,$sRepeat,$sPause,$sTune,$sBaud,";
my    $TAIL=",$txversion,1,$sSpeed,;";
my    $AN="1,3,1,3,3";
my    $AUS="3,1,1,3,1";
my    $bitLow=1;
my    $bitHgh=3;
my    $seqLow=$bitHgh.",".$bitHgh.",".$bitLow.",".$bitLow.",";
my    $seqHgh=$bitHgh.",".$bitLow.",".$bitHgh.",".$bitLow.",";
my    $i=0;
my    $bit="";   
my    $msg="";

my $c_ip = "192.168.178.142";
my  $bits=$Master;
    for($i=0; $i<length($bits); $i++) {   
        $bit=substr($bits,$i,1);
        if($bit=="0") {
            $msg=$msg.$seqLow;
        } else {
            $msg=$msg.$seqHgh;
        }
    }
my    $msgM=$msg;
   
    $bits=$Slave;
   
    $msg="";
    for($i=0; $i<length($bits); $i++) {
        $bit=substr($bits,$i,1);
        if($bit=="0") {
            $msg=$msg.$seqLow;
        } else {
            $msg=$msg.$seqHgh;
        }
    }
my    $msgS=$msg;

    if($action eq "on") {
        $SendData = $HEAD.$bitLow.",".$msgM.$msgS.$bitHgh.",".$AN.$TAIL;
    } else {
        $SendData = $HEAD.$bitLow.",".$msgM.$msgS.$bitHgh.",".$AUS.$TAIL;
    }
my ($socket,$data);
#  We call IO::Socket::INET->new() to create the UDP Socket
$socket = new IO::Socket::INET(PeerAddr=>'$c_ip:49880',Proto=>'udp') or die "ERROR in Socket Creation : $!\n";
$socket->send($SendData);

$socket->close();	
	
}
# inspired by https://github.com/Power-Switch/PowerSwitch_Android/blob/8b4e20859303c5cf225e41e5b1149e4a55aa39dd/Smartphone/src/main/java/eu/power_switch/obj/receiver/device/intertechno/CMR1000.java
sub intertech {
my ($c_master,$c_slave,$action) = @_;
 my $c_ip = "192.168.178.142";
 my $c_port = "49880";
 my $c_A = "0";
 my $c_G = "0";
 my $c_repeat = "12";
 my $c_pause = "11125";
 my $c_tune = "89";
 my $c_baud = "25";
 my $c_speed = "4";
 my $c_speedConnAir = "140";
 my $c_tx433version = "1,";

 my $c_bitLow="4";
 my $c_bitHgh="12";
 
 my $c_seqLow="$c_bitLow,$c_bitHgh,$c_bitLow,$c_bitHgh,";
 my $c_seqHgh="$c_bitLow,$c_bitHgh,$c_bitHgh,$c_bitLow,";

 my $c_AN = "$c_seqHgh$c_seqHgh";
 my $c_AUS = "$c_seqHgh$c_seqLow";

 my $c_additional = "$c_seqLow$c_seqHgh";
 my $c_headConnAir = "TXP:0,0,6,11125,89,25,";
 my $c_tailConnAir = "$c_tx433version$c_speedConnAir;";

 my $c_seqMaster="";
 my $c_seqSlave="";
 my $SendData="";
 
 
my $filename = '/tmp/report.txt';
open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
print $fh "Master $c_master\n";
print $fh "Slave  $c_slave\n";
 
#Setting master id
# A=0000
# B=1000
# C=0100 etc.
for($b=0; $b<4; $b++) {
    if (((ord($c_master) - ord("A")) >> $b) & 1) {
       $c_seqMaster="$c_seqMaster$c_seqHgh"; 
    } else {
       $c_seqMaster="$c_seqMaster$c_seqLow"; 
    }
}

 
#Setting slave id
# 1=0000
# 2=1000
# 3=0100 etc.
for($b=0; $b<4; $b++) {
    if (((ord($c_slave) - ord("1")) >> $b) & 1) {
       $c_seqSlave="$c_seqSlave$c_seqHgh"; 
    } else {
       $c_seqSlave="$c_seqSlave$c_seqLow"; 
    }
}
 
 print $fh "Master $c_seqMaster\n";
 print $fh "Slave  $c_seqSlave\n";
 
 if($action eq "on") {
        $SendData = "$c_headConnAir$c_seqMaster$c_seqSlave$c_additional$c_AN$c_tailConnAir";
    } else {
        $SendData = "$c_headConnAir$c_seqMaster$c_seqSlave$c_additional$c_AUS$c_tailConnAir";
    }

 print $fh $SendData;

 my ($socket,$data);

# We call IO::Socket::INET->new() to create the UDP Socket
 $socket = new IO::Socket::INET(PeerAddr=>"$c_ip:$c_port",Proto=>'udp') or die "ERROR in Socket Creation : $!\n";
 $socket->send($SendData);
 $socket->close();	
}
1;
