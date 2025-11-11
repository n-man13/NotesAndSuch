
#################################################
#                                               #
#               LEVEL 5 INTRO                   #
#                                               #
#################################################

'''
LEVEL 5 CHALLENGE - Twitch Cheer Alerts
    Write a function that does something exciting when you receive Twitch bits.
    I've provided you with various images, sounds, and videos you can use in OBS for this.
    You can also add in your own sounds, images, videos, etc.
    Code the most interesting cheer alert to win!

NEW CONCEPTS 

    OPTIONAL - Making Text-to-Speech Audio
        I've provided a TTS Manager variable - you can use it to turn text into audio.
        Then you can use the Audio Manager variable to play that audio.

    OPTIONAL - Asking ChatGPT a question
        I've provided a ChatGPT Manager variable - you can use it to ask any question.
        For example, you could use to it to ask for a custom sub message, written by Yoda.
        It will return text to you, which you can then use for whatever (like text-to-speech, or writing in OBS)

    OPTIONAL - Opening a Website
        I've provided an Website Manager variable - you can use it to open up any website.
        Could use to open Youtube videos, The Yard merch website, etc.
        Note, you need chrome installed in your C drive for this to work.

    OPTIONAL - Clicking on Screen
        I've provided a Click Manager variable - you can use it to click around on screen
        This is probably a bad idea but it's funny.

'''

# We first create the various managers (You can ignore this)
from obs_websockets import OBSWebsocketsManager
from audio_player import AudioManager
from openai_chat import OpenAiManager
from click_manager import click_at_position
from website_manager import open_website
from google_tts import text_to_speech
obs_manager = OBSWebsocketsManager()
audio_manager = AudioManager()
chatgpt_manager = OpenAiManager()

# EXAMPLES BELOW!

# You can create a text-to-speech audio file
tts_audio = text_to_speech("Here is the text that I want to turn into audio")

# Now you can play that audio file!
audio_manager.play_audio(tts_audio)

# You can ask ChatGPT a question, and get a text answer back
chatgpt_answer = chatgpt_manager.chat("Hey ChatGPT, please write a poem about hot dogs.")

# If you have a Twitch Chat message, you can combine it with another string to make a bigger question
example_chat_message = "Hey Atrioc you are bald glizzy glizzy"
chatgpt_question = "Hey ChatGPT, please roast the guy who wrote this twitch chat message: " + example_chat_message
chatgpt_answer = chatgpt_manager.chat(chatgpt_question)

# You can open any URL or website in Chrome (or whatever browser you want)
open_website("https://www.twitch.tv/dougdoug")

# You can click on the screen anywhere you want, just give an X and Y coordiante
# In this example, it will click the screen at 
click_at_position(500, 500)

# Remember that you can also update anything you want in OBS
# Combine all these to create crazy effects



#############################################
# HERE ARE THE TIPS FROM THE PREVIOUS LEVELS
#############################################

# Play any audio file with audio_manager!
audio_manager.play_audio("Fart.mp3")

# You can turn any OBS sources on or off.
# For example, you can make an image visible, or making your camera invisible.
obs_manager.set_source_visibility("SCENE NAME", "SOURCE NAME 1", True)
obs_manager.set_source_visibility("SCENE NAME", "SOURCE NAME 2", False)

# You can change the text of Text Sources in OBS
obs_manager.set_text("TEXT SOURCE NAME", "Your new text here!")

# You can turn an OBS filter on or off
# Can use this to turn on or off crazy visual or audio filters
obs_manager.set_filter_visibility("SOURCE NAME", "FILTER NAME 1", True)
obs_manager.set_filter_visibility("SOURCE NAME", "FILTER NAME 2", False)

# You can change your OBS scene
obs_manager.set_scene("Your Scene Name Here")

message = "this is an example twitch chat message"

# You can check if two strings are equal (This is what we did the previous level)
if message == "bald":
    ban_time = 100000

# You can check if two strings are NOT equal
if message != "bald":
    ban_time = 35

# This is an "if else" statement, where you can decide what happens if a condition is NOT met.
if message == "i love lemonade stand":
    ban_time = 0
else:
    ban_time = 100

# You can check the length of a string!

# Ban if the message is longer than 50 characters
if len(message) > 10:
    ban_time = 100  

# Or, can ban if the message is too short
if len(message) < 10:
    ban_time = 500  

# You can check if the string starts with specific letter or word!
if message.startswith("fuck"):
    ban_time = 1000
if message.startswith("I hate you because"):
    ban_time = 350

# You can check if a string contains a word or letter inside of it!
if "bald" in message:
    ban_time = 999
if "you are bald" in message:
    ban_time = 50

# You can go crazy and check the number of times a certain word or letter is inside the string
# For example, count how many times "bald" appears in the message:
bald_count = message.count("bald")
if bald_count > 3:
    ban_time = 1000  # Ban if "bald" appears more than three times

# You can also count single letters:
a_count = message.count("e")
if a_count > 0:
    ban_time = 500  # Ban if they used the letter 'e' a single time

# You can get the total number of words in a message
word_list = message.split() # This splits the message into words
word_count = len(word_list) # This counts the number of words
if word_count < 5:
    ban_time = 10000

# You can generate a random number, and use that to make something unpredictable
random_number = random.randint(1, 10)
if random_number == 10:
    ban_time = 1000 # This guy got unlucky