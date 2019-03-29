# docker-minecraft-overviewer

An ephemeral Docker container for Minecraft Overviewer, configured with environment variables.

## Installation

```sh
docker pull silenthunter44/minecraft-overviewer:latest
```

## Run

Run the default configuration with the following:

```sh
docker run -d --name overviewer --volume /local-path-to-minecraft-data:/in --volume /local-path-to-output-map:/out silenthunter44/minecraft-overviewer:latest
```

Alternatively, you can use environment variables for configuration:

```sh
docker run -d --name overviewer \
  --volume /local-path-to-minecraft-data:/in \
  --volume /local-path-to-output-map:/out \
  --env MCO_PROCESSES=2 \
  silenthunter44/minecraft-overviewer:latest
```

## Volumes

- `/in`: Minecraft Server folder
- `/out`: output map will be generated here

## Configuration

This Minecraft Overviewer container can be configured with the following environment variables.

### General configuration

| Variable | Default | Description |
|---|---|---|
| `MCO_MINECRAFT_VERSION` | `1.13.2` | Minecraft Client version to use |
| `MCO_RENDER_MAP` | `true` | Set to `false` to disable map render (useful for POI only-updates) |
| `MCO_RENDER_POI` | `true` | Set to `false` to disable POI render |
| `MCO_WORLDNAME` | `world` | Minecraft Server's world (and folder) name |
| `MCO_RENDER_DAY` | `true` | Defines if a day map must be rendered |
| `MCO_DAY_NORTH_DIRECTION` | `upper-left` | Defines North direction of the rendered day map |
| `MCO_RENDER_NIGHT` | `true` | Defines if a night map must be rendered |
| `MCO_NIGHT_NORTH_DIRECTION` | `upper-left` | Defines North direction of the rendered night map |
| `MCO_RENDER_NETHER` | `false` | Defines if a Nether map must be rendered |
| `MCO_NETHER_NORTH_DIRECTION` | `upper-left` | Defines North direction of the rendered Nether map |
| `MCO_RENDER_END` | `false` | Defines if an End map must be rendered |
| `MCO_END_NORTH_DIRECTION` | `upper-left` | Defines North direction of the rendered Ent map |
| `MCO_RENDER_OVERLAY_BIOME` | `false` | Defines if a biome overlay must be rendered (on top of day map) |
| `MCO_RENDER_OVERLAY_MOB` | `false` | Defines if a mob spawnable areas overlay must be rendered (on top of day map) |
| `MCO_RENDER_OVERLAY_SILME` | `false` | Defines if a slime chunk overlay must be rendered (on top of day map) |

### Extra configuration

| Variable | Default | Description |
|---|---|---|
| `MCO_ADDITIONAL_ARGS` |  | Additionals arguments to pass into `overviewer.py` |
| `MCO_CONFIGFILE` | `/home/minecraft/config.py` | Use a custom configuration file path |
| `MCO_PROCESSES` | `$(nproc)` | Number of threads to use for the map rendering process |
| `MCO_INPUT_VOLUME` | `/in` | Override input dir |
| `MCO_TEMP_VOLUME` | `/temp` | Override temp working dir |
| `MCO_OUTPUT_VOLUME` | `/out` | Override output dir |
