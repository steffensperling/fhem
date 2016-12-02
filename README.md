# FHEM Home automation server files for Brennenstuhl Brematic Home Automation Gateway GWY 433
For the time being only supporting some intertechno and some brennenstuhl adaptors

Use this at your own risk

for FHEM and FHEM install check http://fhem.de/fhem.html

To install this add the 99_brematic.pm to your contrib directory via FHEM web-gui

To use this add something like this to your fhem.cfg:
'''
define Lampe_Tisch dummy
attr Lampe_Tisch alias Lampe Wohnzimmertisch
attr Lampe_Tisch eventMap BI:on B0:off
attr Lampe_Tisch room Wohnzimmer
attr Lampe_Tisch setList state:on,off
define Lampe_Tisch_ntfy notify Lampe_Tisch:.* {\
    my $master = "A";;\
    my $slave = "2";;\
    my $v=Value("Lampe_Tisch");;\
    if ($v eq "on") {intertech("$master","$slave","on")};;\
    if ($v eq "off") {intertech("$master","$slave","off")};;\
    }
'''

$master and $slave need to be set to the configuration of your intertechno wireless wall plug adaptors.
