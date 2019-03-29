#!/bin/bash
set -o errexit

MCO_MINECRAFT_VERSION=${MCO_MINECRAFT_VERSION:="1.13.2"}

# Download Minecraft Client
CLIENT_URL=$(python /home/minecraft/download_url.py "$MCO_MINECRAFT_VERSION")
wget -nv -N "$CLIENT_URL" -O "${MCO_MINECRAFT_VERSION}.jar" \
     -P /home/minecraft/.minecraft/versions/$MCO_MINECRAFT_VERSION/

MCO_INPUT_VOLUME=${MCO_INPUT_VOLUME:="/in"}
MCO_TEMP_VOLUME=${MCO_TEMP_VOLUME:="/temp"}
MCO_OUTPUT_VOLUME=${MCO_OUTPUT_VOLUME:="/out"}

MCO_WORLDNAME=${MCO_WORLDNAME:=world}
MCO_CONFIGFILE=${MCO_CONFIGFILE:="/home/minecraft/config.py"}

if [ ! -d "$MCO_OUTPUT_VOLUME" ]
then
    mkdir -p "$MCO_OUTPUT_VOLUME"
fi

# Generate config if needed
if [ ! -f "$MCO_CONFIGFILE" ]; then
    {
        echo "def playerIcons(poi):"
        echo "    if poi[\"id\"] == \"Player\":"
        echo "        poi[\"icon\"] = \"https://overviewer.org/avatar/%s\" % poi[\"EntityId\"]"
        echo "        return \"Last known location for %s\" % poi[\"EntityId\"]"

        echo "def signFilter(poi):"
        echo "    if poi[\"id\"] in [\"Sign\", \"minecraft:sign\"]:"
        echo "        if \"-- RENDER --\" in poi.values():"
        echo "            return \"\\n\".join([poi[\"Text1\"],"
        echo "                                 poi[\"Text2\"],"
        echo "                                 poi[\"Text3\"],"
        echo "                                 poi[\"Text4\"]])"

        echo "worlds[\"$MCO_WORLDNAME\"] = \"$MCO_TEMP_VOLUME\""
        echo "outputdir = \"$MCO_OUTPUT_VOLUME\""
        echo "texturepath = \"/home/minecraft/${MCO_MINECRAFT_VERSION}.jar\""

        echo "markers = ["
        echo "    dict(name=\"Players\", filterFunction=playerIcons),"
        echo "    dict(name=\"Signs\", filterFunction=signFilter)"
        echo "]"
    } > "$MCO_CONFIGFILE"

    if ! [[ "${MCO_RENDER_DAY:="true"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_day\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"Day\","
            echo "    \"rendermode\": smooth_lighting,"
            echo "    \"dimension\": \"overworld\","
            echo "    \"northdirection\": \"${MCO_DAY_NORTH_DIRECTION:="upper-left"}\","
            echo "    \"markers\": markers"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_NIGHT:="true"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_night\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"Night\","
            echo "    \"rendermode\": smooth_night,"
            echo "    \"dimension\": \"overworld\","
            echo "    \"northdirection\": \"${MCO_NIGHT_NORTH_DIRECTION:="upper-left"}\","
            echo "    \"markers\": markers"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_NETHER:="false"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_nether\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"Nether\","
            echo "    \"rendermode\": nether_smooth_lighting,"
            echo "    \"dimension\": \"nether\","
            echo "    \"northdirection\": \"${MCO_NETHER_NORTH_DIRECTION:="upper-left"}\","
            echo "    \"markers\": markers"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_END:="false"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_end\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"End\","
            echo "    \"rendermode\": [Base(), EdgeLines(), SmoothLighting(strength=0.5)],"
            echo "    \"dimension\": \"end\","
            echo "    \"northdirection\": \"${MCO_END_NORTH_DIRECTION:="upper-left"}\","
            echo "    \"markers\": markers"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_OVERLAY_BIOME:="false"}" == "false" ]]; then
        {
        echo "renders[\"${MCO_WORLDNAME}_biome_overlay\"] = {"
        echo "    \"world\": \"$MCO_WORLDNAME\","
        echo "    \"title\": \"Biome Overlay\","
        echo "    \"rendermode\": [ClearBase(), BiomeOverlay()],"
        echo "    \"dimension\": \"overworld\","
        echo "    \"overlay\": [\"${MCO_WORLDNAME}_day\"]"
        echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_OVERLAY_MOB:="false"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_mob_overlay\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"Mob Spawnable Areas Overlay\","
            echo "    \"rendermode\": [ClearBase(), SpawnOverlay()],"
            echo "    \"dimension\": \"overworld\","
            echo "    \"overlay\": [\"${MCO_WORLDNAME}_day\"]"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi

    if ! [[ "${MCO_RENDER_OVERLAY_SILME:="false"}" == "false" ]]; then
        {
            echo "renders[\"${MCO_WORLDNAME}_slime_overlay\"] = {"
            echo "    \"world\": \"$MCO_WORLDNAME\","
            echo "    \"title\": \"Slime Chunk Overlay\","
            echo "    \"rendermode\": [ClearBase(), SlimeOverlay()],"
            echo "    \"dimension\": \"overworld\","
            echo "    \"overlay\": [\"${MCO_WORLDNAME}_day\"]"
            echo "}"
        } >> "$MCO_CONFIGFILE"
    fi
fi

# Copy map to avoid corruption
cp -ru $MCO_INPUT_VOLUME/$MCO_WORLDNAME/* $MCO_TEMP_VOLUME/

# Render maps
if [ "${MCO_RENDER_MAP:="true"}" == "true" ]; then
    overviewer.py --config $MCO_CONFIGFILE \
                  --processes ${MCO_PROCESSES:=$(nproc)} \
                  $MCO_ADDITIONAL_ARGS
fi

# Render POI
if [ "${MCO_RENDER_POI:="true"}" == "true" ]; then
    overviewer.py --config $MCO_CONFIGFILE \
                  --genpoi \
                  $MCO_ADDITIONAL_ARGS
fi
