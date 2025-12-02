import threading
import time
import sys
from config import Config
from timer import SubathonTimer
from twitch import run_bot

def main():
    # 1. Load Configuration
    cfg = Config("config.txt")
    if not cfg.load():
        sys.exit(1)
        
    # 2. Setup Timer
    sub_timer = SubathonTimer(cfg.initial_minutes, "timer.txt")
    
    # 3. Start Timer in Background Thread
    t_thread = threading.Thread(target=sub_timer.run, daemon=True)
    t_thread.start()
    
    try:
        # 4. Run Twitch Bot in Main Thread
        while True:
            run_bot(cfg, sub_timer)
            print("Reconnecting in 5 seconds...")
            time.sleep(5)
            
    except KeyboardInterrupt:
        print("\nStopping...")
        sub_timer.stop()
        t_thread.join()

if __name__ == "__main__":
    main()
