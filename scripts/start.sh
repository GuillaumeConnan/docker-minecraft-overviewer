#!/bin/bash

MCO_IN_VOLUME=${MCO_IN_VOLUME:="/in"}
MCO_TEMP_VOLUME=${MCO_TEMP_VOLUME:="/temp"}
MCO_OUT_VOLUME=${MCO_OUT_VOLUME:="/out"}

MCO_WORLDNAME=${MCO_WORLDNAME:=world}
MCO_CONFIGFILE=${MCO_CONFIGFILE:="/opt/overviewer/overviewer.conf"}

if [ ! -d "$MCO_OUT_VOLUME" ]
then
    mkdir -p $MCO_OUT_VOLUME
fi

# Generate config if needed
if [ ! -f "$MCO_CONFIGFILE" ]
then
    echo "worlds[\"$MCO_WORLDNAME\"] = \"$MCO_TEMP_VOLUME\""                             >  $MCO_CONFIGFILE

    if ! [[ "${MCO_RENDER_DAY:=1}" == "0" ]]
    then
        echo "renders[\""$MCO_WORLDNAME"day\"] = {"                                      >> $MCO_CONFIGFILE
        echo "    \"world\": \"$MCO_WORLDNAME\","                                        >> $MCO_CONFIGFILE
        echo "    \"title\": \"Day\","                                                   >> $MCO_CONFIGFILE
        echo "    \"rendermode\": smooth_lighting,"                                      >> $MCO_CONFIGFILE
        echo "    \"dimension\": \"overworld\","                                         >> $MCO_CONFIGFILE
        echo "    \"northdirection\": \"${MCO_DAY_NORTH_DIRECTION:=upper-left}\","       >> $MCO_CONFIGFILE
        echo "}"                                                                         >> $MCO_CONFIGFILE
    fi

    if ! [[ "${MCO_RENDER_NIGHT:=1}" == "0" ]]
    then
        echo "renders[\""$MCO_WORLDNAME"night\"] = {"                                    >> $MCO_CONFIGFILE
        echo "    \"world\": \"$MCO_WORLDNAME\","                                        >> $MCO_CONFIGFILE
        echo "    \"title\": \"Night\","                                                 >> $MCO_CONFIGFILE
        echo "    \"rendermode\": smooth_night,"                                         >> $MCO_CONFIGFILE
        echo "    \"dimension\": \"overworld\","                                         >> $MCO_CONFIGFILE
        echo "    \"northdirection\": \"${MCO_NIGHT_NORTH_DIRECTION:=upper-left}\","     >> $MCO_CONFIGFILE
        echo "}"                                                                         >> $MCO_CONFIGFILE
    fi

    if ! [[ "${MCO_RENDER_NETHER:=0}" == "0" ]]
    then
        echo "renders[\""$MCO_WORLDNAME"nether\"] = {"                                   >> $MCO_CONFIGFILE
        echo "    \"world\": \"$MCO_WORLDNAME\","                                        >> $MCO_CONFIGFILE
        echo "    \"title\": \"Nether\","                                                >> $MCO_CONFIGFILE
        echo "    \"rendermode\": nether_smooth_lighting,"                               >> $MCO_CONFIGFILE
        echo "    \"dimension\": \"nether\","                                            >> $MCO_CONFIGFILE
        echo "    \"northdirection\": \"${MCO_NETHER_NORTH_DIRECTION:=upper-left}\","    >> $MCO_CONFIGFILE
        echo "}"                                                                         >> $MCO_CONFIGFILE
    fi

    echo "outputdir = \"$MCO_OUT_VOLUME\""                                               >> $MCO_CONFIGFILE
fi

cp -ru $MCO_IN_VOLUME/$MCO_WORLDNAME/* $MCO_TEMP_VOLUME/

chown -R overviewer:overviewer $MCO_TEMP_VOLUME $MCO_OUT_VOLUME

# Init
sudo -u overviewer /usr/bin/python /opt/overviewer/overviewer.py --config $MCO_CONFIGFILE                  \
                                                                 --processes ${MCO_PROCESSES:=$(nproc)}
