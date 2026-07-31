# Home Lab Services
I decided to start the Dell Poweredge R710 and use it as a media server and added a few other features I wanted, like Home Assistant

# Services

## Nginx Proxy Manager
I installed Nginx to be able to translate urls into precise ports for each service web portal. It is available at npm.nman13.com

## Portainer
I installed Portainer as a web UI for managing Docker containers, images, and stacks on the Debian host. It is available at docker.nman13.com

## DDNS-GO
I use DDNS-Go to ensure that cloudflare always maintains the correct public ip address for the house. It is available at ddns-home.nman13.com

## Jellyfin
I installed Jellyfin as the main media server for streaming movies, TV, and other video from the library. It is available at jellyfin.nman13.com

## Seerr
I installed Seerr (Jellyseerr) so users can request movies and TV shows, which then get handed off to the Servarr stack. It is available at requests.nman13.com

## Kodbox
I installed Kodbox as a web-based file manager for browsing and organizing files on the server. It is available at files.nman13.com

## Audiobookshelf
I installed Audiobookshelf to host and stream audiobooks and podcasts with progress tracking across devices. It is available at audiobooks.nman13.com

## Komga
I installed Komga as a comics and manga library with a web reader for browsing series and issues. It is available at manga.nman13.com

## Servarr Stack
I installed Sonarr, Radarr, and Prowlarr (with FlareSolverr) to automate TV and movie downloads through indexers. Sonarr handles shows, Radarr handles movies, and Prowlarr manages the indexer connections.

## qBittorrent
I installed qBittorrent as the download client, routed through ProtonVPN so torrent traffic stays on the VPN network stack. The web UI is exposed via the ProtonVPN container at torrents.nman13.com.

## Home Assistant
I installed Home Assistant to control and automate smart home devices from a single dashboard. It is available at homeassistant.nman13.com

## Automatic Ripping Machine
I installed ARM on AlmaLinux to automatically rip physical discs and feed the media into the library pipeline. It is available at arm.nman13.com

## Glances
I installed Glances to monitor system resources like CPU, memory, and disk usage on the host. It runs internally on the Debian server rather than through a public reverse-proxy URL, but it is still available at glances1.nman13.com for the Debian Server, and glances2.nman13.com for the AlmaLinux Server.

### Home Lab Server Services and Port Mappings

| Host Server | Service / Container | Local Port(s) | Category | Notes |
| --- | --- | --- | --- | --- |
| **AlmaLinux** | ARM *(Auto-Ripper)* | 8080 | Media Pipeline | Physical disc ingest |
| **AlmaLinux** | Code Autocomplete AI Agent | 8086 | AI Server | Coding Autocomplete|
| **AlmaLinux** | Code AI Agent | 8085 | AI Server | Coding Agent|
| **AlmaLinux** | Code Deep Thinking AI Agent | 8087 | AI Server | Heavy Thinking Coding Agent|
| **Debian** | Nginx Proxy Manager | 80, 443, 81 | Infrastructure | Web/SSL routing (Admin UI on 81) |
| **Debian** | Homepage | 3000 | Management | Start page / dashboard |
| **Debian** | Portainer | 9443, 8000 | Management | Container UI (HTTPS on 9443) |
| **Debian** | Glances | Internal / Host | Management | System resource monitor |
| **Debian** | Jellyfin | 8096 | Media Server | Video streaming |
| **Debian** | Audiobookshelf | 13378 | Media Server | Audiobooks and podcasts |
| **Debian** | Komga | 25600 | Media Server | Comics and manga reader |
| **Debian** | Kodbox | 3011 | Cloud Storage | Web-based file manager |
| **Debian** | Seerr  | 5055 | Media Requests | User request portal |
| **Debian** | Sonarr | 8989 | Servarr Stack | TV Show automation |
| **Debian** | Radarr | 7878 | Servarr Stack | Movie automation |
| **Debian** | Prowlarr | 9696 | Servarr Stack | Indexer proxy |
| **Debian** | FlareSolverr | 8191, 8192 | Servarr Stack | Cloudflare bypass for Prowlarr |
| **Debian** | ProtonVPN | 8080 | Networking | VPN tunnel (Exposing qBT UI) |
| **Debian** | qBittorrent | Routed via VPN | Downloads | Uses ProtonVPN network stack |
| **Debian** | DDNS-GO | 9876 | Networking | Dynamic DNS updater |
| **Debian** | Home Assistant | 8123 | Automation | Smart home dashboard |
