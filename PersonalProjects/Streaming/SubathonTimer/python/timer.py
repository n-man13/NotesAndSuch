import threading
import time

class SubathonTimer:
    def __init__(self, start_minutes, output_file="timer.txt"):
        self.remaining_seconds = start_minutes * 60
        self.output_file = output_file
        self.lock = threading.Lock()
        self.running = True

    def add_time(self, seconds):
        with self.lock:
            self.remaining_seconds += seconds

    def tick(self):
        with self.lock:
            if self.remaining_seconds > 0:
                self.remaining_seconds -= 1

    def get_time_string(self):
        with self.lock:
            if self.remaining_seconds <= 0:
                return "00:00:00"
            hours = self.remaining_seconds // 3600
            minutes = (self.remaining_seconds % 3600) // 60
            seconds = self.remaining_seconds % 60
            return f"{hours:02d}:{minutes:02d}:{seconds:02d}"

    def run(self):
        """Thread loop to update timer and file every second"""
        print(f"Timer started. Outputting to {self.output_file}")
        while self.running:
            start_loop = time.time()
            
            self.tick()
            
            # Write to file
            try:
                with open(self.output_file, "w") as f:
                    f.write(self.get_time_string())
            except IOError as e:
                print(f"Error writing to file: {e}")

            # Sleep for remainder of the second to maintain accuracy
            elapsed = time.time() - start_loop
            time.sleep(max(0.0, 1.0 - elapsed))

    def stop(self):
        self.running = False
