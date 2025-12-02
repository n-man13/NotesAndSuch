class Config:
    def __init__(self, filename="config.txt"):
        self.filename = filename
        self.oauth_token = ""
        self.bot_username = ""
        self.channel = ""
        self.initial_minutes = 60
        self.min_seconds_add = 300
        self.max_seconds_add = 600
        self.reward_id = ""
        self.min_seconds_redeem = 60
        self.max_seconds_redeem = 120

    def load(self):
        try:
            with open(self.filename, "r") as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith("#"):
                        continue
                    if "=" in line:
                        key, value = line.split("=", 1)
                        key, value = key.strip(), value.strip()
                        
                        if key == "OAUTH_TOKEN": self.oauth_token = value
                        elif key == "BOT_USERNAME": self.bot_username = value.lower()
                        elif key == "CHANNEL": self.channel = value.lower()
                        elif key == "INITIAL_MINUTES": self.initial_minutes = int(value)
                        elif key == "MIN_SECONDS_ADD": self.min_seconds_add = int(value)
                        elif key == "MAX_SECONDS_ADD": self.max_seconds_add = int(value)
                        elif key == "REWARD_ID": self.reward_id = value
                        elif key == "MIN_SECONDS_REDEEM": self.min_seconds_redeem = int(value)
                        elif key == "MAX_SECONDS_REDEEM": self.max_seconds_redeem = int(value)
            return True
        except FileNotFoundError:
            print(f"Error: {self.filename} not found.")
            return False
        except ValueError as e:
            print(f"Error parsing config: {e}")
            return False
