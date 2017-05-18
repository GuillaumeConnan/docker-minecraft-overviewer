# docker-minecraft-overviewer

An ephemeral Docker container for Minecraft Overviewer configured with environment variables.

## Installation

```sh
docker pull silenthunter44/docker-minecraft-overviewer:latest
```

## Run

Run the default configuration with the following:

```sh
docker run --detach --name minecraft-overviewer --volume /local-path-to-minecraft-data:/in --volume /local-path-to-output-map:/out silenthunter44/docker-minecraft-overviewer:latest
```

Alternatively, you can use environment variables for configuration:

```sh
docker run --detach --name minecraft-overviewer  \
  --volume /local-path-to-minecraft-data:/in \
  --volume /local-path-to-output-map:/out \
  --env MCO_PROCESSES=2 \
  silenthunter44/docker-minecraft-overviewer:latest
```

## Volumes

- `/in`: input Minecraft Server folder
- `/out`: output map will be generated here

## Configuration

This Minecraft Overviewer container can be configured with the following environment variables:

- Global:
  - `MCO_WORLDNAME`: Minecraft Server's world name and folder (default to `world`)
  - `MCO_CONFIGFILE`: defines a custom configuration file path (default to `/opt/overviewer/overviewer.conf`)
  - `MCO_PROCESSES`: number of CPU used for the rendering process (default to `$(nproc)`)
  - `MCO_RENDER_DAY`: defines if a day map must be rendered (default to `1`, possible other value `0`)
  - `MCO_DAY_NORTH_DIRECTION`: defines North direction of the rendered day map (default to `upper-left`)
  - `MCO_RENDER_NIGHT`: defines if a night map must be rendered (default to `1`, possible other value `0`)
  - `MCO_NIGHT_NORTH_DIRECTION`: defines North direction of the rendered night map (default to `upper-left`)
  - `MCO_RENDER_NETHER`: defines if a Nether map must be rendered (default to `0`, possible other value `1`)
  - `MCO_NETHER_NORTH_DIRECTION`: defines North direction of the rendered Nether map (default to `upper-left`)

## How it works

![howitworks](https://cloud.githubusercontent.com/assets/5552420/26220880/c1f941ba-3c14-11e7-85b1-b879b1c80d9a.png)
