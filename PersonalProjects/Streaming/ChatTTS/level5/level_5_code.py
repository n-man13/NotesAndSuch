'''
LEVEL 5 CHALLENGE - Twitch Cheer Alerts
    Write a function that does something exciting when you receive Twitch bits.
    I've provided you with various images, sounds, and videos you can use in OBS for this.
    You can also add in your own sounds, images, videos, etc.
    Code the most interesting cheer alert to win!
'''

############################################################
# Update this to your channel name
CHANNEL_NAME = "13nman"

# Setup the various helper functions (you can ignore this)
import time
import random
from rich import print
from obs_websockets import OBSWebsocketsManager
from audio_player import AudioManager
from openai_chat import OpenAiManager
from click_manager import click_at_position
from website_manager import open_website
from google_tts import text_to_speech
audio_manager = AudioManager()
# chatgpt_manager = OpenAiManager()
obs_manager = OBSWebsocketsManager()
############################################################


def bits_donated(message, username, bits_amount, is_subscribed):
    
    print(f"[cyan]🎉 {username} just donated {bits_amount} bits!")
    
    # TODO: YOUR CODE GOES HERE, DO SOME COOL SHIT WITH THE DONATION!
    
    if bits_amount >= 100:
        print(f"⚡ THIS GUY IS A FUCKING OIL BARON, POGGIES!")

def message_response(message, username, sub):
    if username != CHANNEL_NAME and username != "streamelements":
        tts_audio = text_to_speech(message)
        audio_manager.play_audio(tts_audio, sleep_during_playback=True)
        time.sleep(300)