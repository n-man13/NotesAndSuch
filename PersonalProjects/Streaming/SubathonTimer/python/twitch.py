import socket
import ssl
import random

HOST = "irc.chat.twitch.tv"
PORT = 6697

def parse_tags(line):
    """Helper to parse IRC tags into a dictionary"""
    tags = {}
    if line.startswith("@"):
        tag_part = line.split(" ")[0][1:] # Remove @ and take first part
        pairs = tag_part.split(";")
        for pair in pairs:
            if "=" in pair:
                k, v = pair.split("=", 1)
                tags[k] = v
    return tags

def run_bot(config, timer):
    context = ssl.create_default_context()
    
    print(f"Connecting to {HOST}...")
    try:
        with socket.create_connection((HOST, PORT)) as sock:
            with context.wrap_socket(sock, server_hostname=HOST) as ssock:
                print("Connected! Authenticating...")
                
                # Send Auth
                ssock.sendall(f"PASS {config.oauth_token}\r\n".encode('utf-8'))
                ssock.sendall(f"NICK {config.bot_username}\r\n".encode('utf-8'))
                # Request tags to see subs/redeems
                ssock.sendall(b"CAP REQ :twitch.tv/tags twitch.tv/commands\r\n")
                ssock.sendall(f"JOIN #{config.channel}\r\n".encode('utf-8'))
                
                print(f"Joined #{config.channel}. Listening for events...")

                buffer = ""
                while True:
                    try:
                        data = ssock.recv(2048).decode('utf-8', errors='ignore')
                        if not data:
                            break
                        
                        buffer += data
                        while "\r\n" in buffer:
                            line, buffer = buffer.split("\r\n", 1)
                            
                            # Keep alive
                            if line.startswith("PING"):
                                ssock.sendall(b"PONG :tmi.twitch.tv\r\n")
                                continue
                            
                            # Logic: Check for Subs or Redeems
                            # Look for USERNOTICE
                            if "USERNOTICE" in line:
                                tags = parse_tags(line)
                                msg_id = tags.get("msg-id", "")
                                
                                # 1. Subscriptions
                                if msg_id in ["sub", "resub", "subgift"]:
                                    add_amt = random.randint(config.min_seconds_add, config.max_seconds_add)
                                    print(f"Subscription detected! Adding {add_amt}s")
                                    timer.add_time(add_amt)

                            # 2. Channel Point Redemptions (PRIVMSG with custom-reward-id tag)
                            elif "PRIVMSG" in line and config.reward_id:
                                tags = parse_tags(line)
                                reward_id = tags.get("custom-reward-id", "")
                                
                                if reward_id == config.reward_id:
                                    add_amt = random.randint(config.min_seconds_redeem, config.max_seconds_redeem)
                                    print(f"Redemption detected! Adding {add_amt}s")
                                    timer.add_time(add_amt)
                                    
                    except socket.error:
                        print("Socket error, reconnecting...")
                        break
    except Exception as e:
        print(f"Connection error: {e}")
