# Protomaps Tileserver Docker

This repository is part of the **GeoJar Protomaps Stack** and provides a Dockerized setup for serving [Protomaps PMTiles](https://protomaps.com/docs/pmtiles/) using the official `go-pmtiles` tile server.

A full setup guide is available in [geojar/protomaps-stack](https://github.com/geojar/protomaps-stack).

This project consists of two main components:
1. A **Docker Compose setup** that runs the Protomaps tile server with the downloaded `pmtiles` data.
2. A **download script** to download or extract `.pmtiles` files from [Protomaps Build](https://build.protomaps.com/), either the entire world map or a region (based on a specified bounding box).

---

## Setup and Usage

### 1. Download Protomaps Data

Use the `download_map.sh` script to fetch map data from [Protomaps](https://protomaps.com/). The script supports downloading either the **entire world map** or a **specific regional extract** by providing a bounding box.

#### 📦 Download the script

```bash
wget https://github.com/geojar/protomaps-tileserver-docker/run_download.sh
chmod +x download_map.sh
```

#### 🛠️ download_map.sh Arguments

- If `BBOX` is defined, the script extracts a specific region.
- If not, the full world map is downloaded.
- The file is saved as `$DATA_DIR/$MAP_FILE`.

| Argument         | Description                                    | Optional |
|------------------|------------------------------------------------|----------|
| `--bbox`      | Bounding box for extracting a specific region      | ✅        |
| `--map-file`   | File name to save the downloaded map as (default: map.pmtiles)             | ✅ (default: `/data`) |
| `--data-dir`      | Directory to extract the data into | ✅        |

You can optionally create a `.env` file to configure and use with both the download_map.sh helper and Docker Compose:

```env
BBOX="4.742883,51.830755,5.552837,52.256198"
MAP_FILE="custom_map.pmtiles"
DATA_DIR="data/"
```

#### 🌍 Download the entire world map

To download the full global map dataset and save it to `./data/world.pmtiles`:

```bash
./run_download.sh --map-file "world.pmtiles" --data-dir "./data"
```

> This will download the global `.pmtiles` file (from the previous day) and place it in your local `./data` folder. It's suitable if you need the complete world tileset.

#### 📍 Download a regional extract (by bounding box)

To download only a specific region (e.g. the Netherlands), supply a bounding box (`minLon,minLat,maxLon,maxLat`) using the `--bbox` argument:

```bash
./run_download.sh --bbox "4.742883,51.830755,5.552837,52.256198" --map-file "custom_map.pmtiles" --data-dir "./data"
```

> This will extract just the area defined by the bounding box and save it to `custom_map.pmtiles`. Use this if you want to reduce file size or serve only a specific geographic region.

### 2. Serving Tiles with Docker

You can serve your `.pmtiles` files using Docker Compose.

#### Example `docker-compose.yml`

```yaml
services:
  tileserver:
    image: geojar/protomaps-tileserver:latest
    container_name: protomaps_tileserver
    ports:
      - "${TILESERVER_IP:-0.0.0.0}:${TILESERVER_PORT:-8080}:8080"
    volumes:
      - ./data:/data:ro
    command: serve /data --cors=* --bucket=file:///data/
```

#### Usage

1. Place your `.pmtiles` file inside the `data/` directory.
2. Start the tile server:

```bash
docker-compose up
```

### 3. Access the Tile Server

Once the tile server is running, you can access it via a browser or API at:
```
http://<TILESERVER_IP>:<TILESERVER_PORT>
```
- If no IP is set, it will listen on `0.0.0.0` (all network interfaces).
- If no port is set, it will default to `8080`.

---

### Environment Variables (`.env`)

You can optionally create a `.env` file to configure:

```env
# PMTiles Docker Image Version
PMTILES_IMAGE_VERSION=v1.28.0

# IP and port for the tileserver container to bind (used in docker-compose)
TILESERVER_IP=your-server-ip
TILESERVER_PORT=8080

# Bounding box for extracting a specific region (optional)
BBOX="4.742883,51.830755,5.552837,52.256198"

# File name to save the downloaded map as (default: map.pmtiles)
MAP_FILE="custom_map.pmtiles"
DATA_DIR="data/"
```
---

### 🤖 AI-Assisted Content

Some parts of this project, especially the README and other documentation, were created or refined with the help of AI tools (such as ChatGPT). These tools were used to improve clarity, structure, and consistency in presenting the information. All generated content was reviewed and edited as needed to ensure accuracy and alignment with the project’s goals.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.