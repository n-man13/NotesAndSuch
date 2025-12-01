# 🐍 Twitch Subathon Timer (Python Version)

A Python-based Subathon Timer that connects to Twitch Chat, listens for subscriptions and channel point redemptions, and updates a text file for OBS.

## ✨ Features

*   **Twitch Integration:** Connects securely via SSL/TLS.
*   **Auto-Extension:** Adds time for new subs, resubs, and gifted subs.
*   **Randomized Time:** Configurable random range (e.g., add 5-10 minutes per sub).
*   **Channel Points:** Support for adding time via a specific Channel Point Reward.
*   **OBS Ready:** Outputs to `timer.txt` every second.

---

## 🛠️ Prerequisites

*   **Python 3.6+** (Installed by default on most systems)
*   No external dependencies required! (Uses standard libraries only)

---

## 🚀 Setup & Usage

1.  **Configure**
    Open `config.txt` and fill in your details:
    *   **OAUTH_TOKEN**: Get this from [twitchapps.com/tmi/](https://twitchapps.com/tmi/) (starts with `oauth:...`)
    *   **BOT_USERNAME**: Your Twitch username (lowercase).
    *   **CHANNEL**: The channel to monitor (lowercase).
    *   **INITIAL_MINUTES**: Start time in minutes.
    *   **MIN/MAX_SECONDS_ADD**: Random range of seconds to add per sub.
    *   **REWARD_ID**: (Optional) UUID for a channel point reward to track.

2.  **Run**
    ```bash
    python subathon_timer.py
    ```
    (On Windows, you might use `py subathon_timer.py` or `python3 subathon_timer.py` depending on your install).

3.  **OBS Setup**
    *   Add a **Text** source in OBS.
    *   Check **"Read from file"**.
    *   Select the `timer.txt` generated in this folder.

---

## 📝 Finding Reward IDs

To find the UUID for `REWARD_ID`:
1.  Run the bot.
2.  Redeem the reward in your chat.
3.  Check the console output (if debugging) or use a tool like [Twitch's API explorer](https://dev.twitch.tv/console) or a dedicated reward-ID-finder tool online.
*   *Note: This script currently doesn't log all raw tags to console to keep it clean, but you can temporarily print `tags` in the code to see the ID.*

## 📜 License

MIT License.
