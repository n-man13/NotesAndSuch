import pyautogui
import time

def click_at_position(x, y):
    try:
        # Move to position and click
        pyautogui.click(x, y)
        print(f"Clicked at position ({x}, {y})")
        
    except Exception as e:
        print(f"Error clicking at position ({x}, {y}): {e}")

if __name__ == "__main__":
    # Example usage
    print("Screen Click Manager")
    print(f"Clicking at screen center ({100}, {100}) in 3 seconds...")
    time.sleep(3)
    click_at_position(100, 100)
