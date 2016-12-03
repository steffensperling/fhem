# FHEM Home automation server files for Brennenstuhl Brematic Home Automation Gateway GWY 433
For the time being only supporting some intertechno and some brennenstuhl adaptors

Use this at your own risk

##Install:
for FHEM and FHEM install check http://fhem.de/fhem.html

To install this add the 99_brematic.pm to your contrib directory via FHEM web-gui

##Parameters:

```brematic(MANUFACTURER, MASTER, SLAVE, ONOFF);```

* MANUFACTURER: "BRENNENSTUHL" oder "INTERTECHNO"
* MASTER: Set to master configuration of your wall plug adaptor: "A","B", "C" ... for Intertechno, dip switch setting of first bank of switches for brennenstuhl eg. "10111"
* SLAVE: Set to slave configuration of your wall plug adaptor "1".."16" for Intertechno, dip switch setting of secont bank of switches for brennenstuhl, eg. "00110" 

##Usage:
To use this add something like this to your fhem.cfg:
```
define Lampe_Tisch dummy
attr Lampe_Tisch alias Lampe Wohnzimmertisch
attr Lampe_Tisch eventMap BI:on B0:off
attr Lampe_Tisch room Wohnzimmer
attr Lampe_Tisch setList state:on,off
define Lampe_Tisch_ntfy notify Lampe_Tisch:.* {\
    my $v=Value("Lampe_Tisch");;\
    brematic("INTERTECHNO","A","2","$v");;\
    }
```

