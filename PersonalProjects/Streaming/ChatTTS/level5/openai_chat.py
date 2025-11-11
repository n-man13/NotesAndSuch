from openai import OpenAI
import tiktoken
import os
from rich import print
import base64
import time
import json

class OpenAiManager:
    
    def __init__(self, system_prompt=None, chat_history_backup=None):
        """
        Optionally provide a chat_history_backup txt file and a system_prompt string.
        If the backup file is provided, we load the chat history from it.
        If the backup file already exists, then we don't add the system prompt into the convo history, because we assume that it already has a system prompt in it.
        Alternatively you manually add new system prompts into the chat history at any point. 
        """

        self.client = OpenAI(api_key=os.environ['OPENAI_API_KEY'])
        self.logging = True # Determines whether the module should print out its results
        self.tiktoken_encoder = None # Used to calculate the token count in messages
        self.chat_history = []

        # If a backup file is provided, we will save our chat history to that file after every call
        self.chat_history_backup = chat_history_backup
        
        # If the backup file already exists, we load its contents into the chat_history
        if chat_history_backup and os.path.exists(chat_history_backup):
            with open(chat_history_backup, 'r') as file:
                self.chat_history = json.load(file)
        elif system_prompt:
            # If the chat history file doesn't exist, then our chat history is currently empty.
            # If we were provided a system_prompt, add it into the chat history as the first message.

            # FORMATTED_SYSTEM_PROMPT = {"role": "system", "content": f'''Here is my system prompt text here, hooray!'''}
            # UNFORMATTED_SYSTEM_PROMPT = '''Here is my system prompt text here, hooray!'''

            # Check if the system_prompt is already formatted (a dictionary with 'role' and 'content' keys)
            if isinstance(system_prompt, dict) and 'role' in system_prompt and 'content' in system_prompt:
                # Already formatted, use as-is
                self.chat_history.append(system_prompt)
            else:
                # Unformatted string, format it properly
                formatted_system_prompt = {"role": "system", "content": system_prompt}
                self.chat_history.append(formatted_system_prompt)

    # Write our current chat history to the txt file
    def save_chat_to_backup(self):
        if self.chat_history_backup:
            with open(self.chat_history_backup, 'w') as file:
                json.dump(self.chat_history, file)

    def num_tokens_from_messages(self, messages, model='gpt-4o'):
        """Returns the number of tokens used by a list of messages.
        The code below is an adaptation of this text-only version: https://platform.openai.com/docs/guides/chat/managing-tokens 

        Note that image tokens are calculated differently from text.
        The guide for image token calculation is here: https://platform.openai.com/docs/guides/vision
        Short version is that a 1920x1080 image is going to be 1105 tokens, so just using that for all images for now.
        In the future I could swap to 'detail: low' and cap it at 85 tokens. Might be necessary for certain use cases.

        There are three message formats we have to check:
        Version 1: the 'content' is just a text string
            'content' = 'What are considered some of the most popular characters in videogames?'
        Version 2: the content is an array with a single dictionary, with two key/value pairs
            'content' = [{'type': 'text', 'text': 'What are considered some of the most popular characters in videogames?'}]
        Version 3: the content is an array with two dictionaries, one for the text portion and one for the image portion
            'content' = [{'type': 'text', 'text': 'Okay now please compare the previous image I sent you with this new image!'}, {'type': 'image_url', 'image_url': {'url': 'https://i.gyazo.com/8ec349446dbb538727e515f2b964224c.png', 'detail': 'high'}}]
        """
        try:
            if self.tiktoken_encoder == None:
                self.tiktoken_encoder = tiktoken.encoding_for_model(model) # We store this value so we don't have to check again every time
            num_tokens = 0
            for message in messages:
                num_tokens += 4  # every message follows <im_start>{role/name}\n{content}<im_end>\n
                for key, value in message.items():
                    if key == 'role':
                        num_tokens += len(self.tiktoken_encoder.encode(value))
                    elif key == 'content':
                        # In the case that value is just a string, simply get its token value and move on
                        if isinstance(value, str):
                            num_tokens += len(self.tiktoken_encoder.encode(value))
                            continue

                        # In this case the 'content' variables value is an array of dictionaries
                        for message_data in value:
                            for content_key, content_value in message_data.items():
                                if content_key == 'type':
                                    num_tokens += len(self.tiktoken_encoder.encode(content_value))
                                elif content_key == 'text': 
                                    num_tokens += len(self.tiktoken_encoder.encode(content_value))
                                elif content_key == "image_url":
                                    num_tokens += 1105 # Assumes the image is 1920x1080 and that detail is set to high               
            num_tokens += 2  # every reply is primed with <im_start>assistant
            return num_tokens
        except Exception:
            # Either this model is not implemented in tiktoken, or there was some error processing the messages
            raise NotImplementedError(f"""num_tokens_from_messages() is not presently implemented for model {model}.""")

    # Analyze an image without history
    # Works with jpg, jpeg, or png. Alternatively can provide an image URL by setting local_image to False
    # More info here: https://platform.openai.com/docs/guides/vision
    def analyze_image(self, prompt, image_path, local_image=True, model="gpt-4o"):
        # Use default prompt if one isn't provided
        if prompt is None:
            prompt = "Please give me a detailed description of this image."
        # If this is a local image, encode it into base64. Otherwise just use the provided URL.
        if local_image:
            try:
                with open(image_path, "rb") as image_file:
                    base64_image = base64.b64encode(image_file.read()).decode("utf-8")
                    url = f"data:image/jpeg;base64,{base64_image}"
            except:
                print("[red]ERROR: COULD NOT BASE64 ENCODE THE IMAGE. PANIC!!")
                return None
        else:
            url = image_path # The provided image path is a URL
        if self.logging:
            print("[yellow]\nAsking ChatGPT to analyze image...")
        completion = self.client.chat.completions.create(
            model=model,
            messages=[
                {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": url,
                            "detail": "high"
                        }
                    },
                ],
                },
            ],
            max_tokens=4096, # max of 4096 tokens as of Dec 25th 2023
        )
        openai_answer = completion.choices[0].message.content
        if self.logging:
            print(f"[green]\n{openai_answer}\n")
        return openai_answer

    # Asks a question with no chat history
    # Temperature is a value between 0 and 2, but in practice 1.5 seems to be the highest it can handle without taking insanely long or returning a server error
    def chat(self, prompt, model="gpt-4o", temperature=1.0):
        if not prompt:
            print("Didn't receive input!")
            return

        # Check that the prompt is under the token context limit
        chat_question = [{"role": "user", "content": prompt}]
        if self.num_tokens_from_messages(chat_question) > 128000:
            print("The length of this chat question is too large for the GPT model")
            return

        if self.logging:
            print("[yellow]\nAsking ChatGPT a question...")
        completion = self.client.chat.completions.create(
            model=model,
            messages=[
                {"role": "user", "content": prompt}
            ],
            temperature=temperature
        )

        # Process the answer
        openai_answer = completion.choices[0].message.content
        if self.logging:
            print(f"[green]\n{openai_answer}\n")
        return openai_answer
    
    # Asks a question that includes the full conversation history
    # Can include a mix of text and images
    # Temperature is a value between 0 and 2, but in practice 1.5 seems to be the highest it can handle without taking insanely long or returning a server error
    def chat_with_history(self, prompt="", image_path="", local_image=True, model="gpt-4o", temperature=1.0):
        
        # If we received a prompt, add it into our chat history.
        # Prompts are technically optional because the Ai can just continue the conversation from where it left off.
        if prompt is not None and prompt != "":
            # Create a new chat message with the text prompt
            new_chat_message = {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                ],
            }
            # If an image is provided, add the image url info into our new message.
            if image_path != "":
                # If this is a local image, we encode it into base64. Otherwise just use the provided URL.
                if local_image:
                    try:
                        with open(image_path, "rb") as image_file:
                            base64_image = base64.b64encode(image_file.read()).decode("utf-8")
                            url = f"data:image/jpeg;base64,{base64_image}"
                    except:
                        print("[red]ERROR: COULD NOT BASE64 ENCODE THE IMAGE. PANIC!!")
                        return None
                else:
                    url = image_path # The provided image path is a URL
                new_image_content = {
                    "type": "image_url",
                    "image_url": {
                        "url": url,
                        "detail": "high"
                    }
                }
                new_chat_message["content"].append(new_image_content)

            # Add the new message into our chat history
            self.chat_history.append(new_chat_message)

        # Check total token limit. Remove old messages as needed
        if self.logging:
            print(f"[coral]Chat History has a current token length of {self.num_tokens_from_messages(self.chat_history)}")
        while self.num_tokens_from_messages(self.chat_history) > 128000:
            self.chat_history.pop(1) # We skip the 1st message since it's the system message
            if self.logging:
                print(f"Popped a message! New token length is: {self.num_tokens_from_messages(self.chat_history)}")

        if self.logging:
            print("[yellow]\nAsking ChatGPT a question...")
        completion = self.client.chat.completions.create(
          model=model,
          messages=self.chat_history,
          temperature=temperature
        )

        # Add this answer to our chat history
        self.chat_history.append({"role": completion.choices[0].message.role, "content": completion.choices[0].message.content})

        # If a backup file was provided, write out convo history to the txt file
        self.save_chat_to_backup()

        # Return answer
        openai_answer = completion.choices[0].message.content
        if self.logging:
            print(f"[green]\n{openai_answer}\n")
        return openai_answer
    


if __name__ == '__main__':
    openai_manager = OpenAiManager()
    
    

    ##################################
    # CHAT WITH HISTORY TEST
    # FIRST_SYSTEM_MESSAGE = {"role": "system", "content": "Act like you are Captain Jack Sparrow from the Pirates of Carribean movie series!"}
    # openai_manager.chat_history.append(FIRST_SYSTEM_MESSAGE)
    openai_manager = OpenAiManager(system_prompt="Act like you are Captain Jack Sparrow from the Pirates of Carribean movie series!")
    FIRST_USER_MESSAGE = {"role": "user", "content": "Ahoy there! Who are you, and what are you doing in these parts? Please give me a 2 sentence background on how you got here. And do you have any mayonnaise I can borrow?"}
    openai_manager.chat_history.append(FIRST_USER_MESSAGE)

    while True:
        new_prompt = input("\nNext question? \n\n")
        # openai_manager.chat_with_history(new_prompt, model="gpt-4o-mini")
        # openai_manager.chat_with_history(new_prompt, model="gpt-4.5-preview")
        # openai_manager.chat_with_history(new_prompt, model="o4-mini")
        openai_manager.chat_with_history(new_prompt)
    
    # FIRST_SYSTEM_MESSAGE = {"role": "system", "content": "You are now representing Twitch Chat, the lovable and chaotic sidekick of the Twitch streamer DougDoug. DougDoug is a Twitch streamer known for playing gaming challenges in various chaotic ways. The trademark of his stream is the incredibly silly and dynamic commentary between Doug and Twitch Chat. At it's core, this conversation is about banter and joking between Doug and Twitch Chat, including developing new recurring jokes and banter. You will be given lines of dialogue from Doug that he is saying on stream, and your job as a Twitch Chat Ai is to respond with funny, witty, chaotic, and engaging banter."}
    # openai_manager.chat_history.append(FIRST_SYSTEM_MESSAGE)
    # openai_manager.chat_with_history("What on earth, why isn't Mario wearing pants?? Chat, did you guys install a mod without telling me??", model="ft:gpt-4o-2024-08-06:dougdoug:twitch-chat-10-words-v1:AQmCaEky")

    ##################################
    # ANALYZE IMAGE TEST
    # dnd_pic = 'https://i.gyazo.com/fda1ab3a138d10197f6d8dabf36274d1.jpg'
    # image_analysis = openai_manager.analyze_image("This is a screenshot from a game of Dungeons and Dragons. Could you please give a detailed description of everything going on in this scene?", dnd_pic, False)
    # print('test')
    # peggle_pic = "https://i.gyazo.com/7be4c8df6285b5df375bcaeb3e9a621b.jpg"
    # image_analysis = openai_manager.analyze_image("This image is from the videogame Peggle. Based on the location of the remaining pegs, can you pick a specific spot on the board to shoot the next shot? The dimensions of this image are 798 pixels wide and 600 pixels tall. Please pick a very precise location that could work well for the next shot and include the X and Y pixel coordinates and then describe why it is likely the best shot available here.", peggle_pic, False)
    # youtube_pic = "https://i.gyazo.com/2b46fc5763bf5fb2847cd179bfe39a8f.jpg"
    # image_analysis = openai_manager.analyze_image("You are now the character Sonic from the videogames. This image contains the Youtube home page. Could you please analyze which of these 6 videos would interest you the most as the character sonic? Please answer in character.", youtube_pic, False)
    # image_analysis = openai_manager.analyze_image("This image contains the Youtube homepage. Could you please analyze the 6 videos here and select which video is most similar to a video by Mr Beast, or most likely to lead to content similar to Mr Beast's content?", youtube_pic, False)
    # mario_pic = "https://i.gyazo.com/e943e47213786bede88a298ce3d9fc6b.jpg"
    # image_analysis = openai_manager.analyze_image("I am playing a videogame, and I have an image of the videogame attached here. I would like to understand whether the following message is relevant to the game I'm playing. Could you please describe whether the following message is relevant to my videogame and why? Here is the message: LOL you are bald and bad at 2D platformers", mario_pic, False)
    # print(image_analysis)

    ##################################
    # ANALYZE IMAGE WITH HISTORY TEST
    # FIRST_SYSTEM_MESSAGE = {"role": "system", "content": "Please analyze the following images."}
    # openai_manager.chat_history.append(FIRST_SYSTEM_MESSAGE)
    # patrick_test_image = "https://i.gyazo.com/dc5e707a07376cd2af03722f3031ee24.png" # patrick
    # shrek_test_image = "https://i.gyazo.com/8ec349446dbb538727e515f2b964224c.png" # shrek
    # image_analysis = openai_manager.analyze_image_with_history("Please describe this image in just 3 sentences.", patrick_test_image, False)
    # image_analysis = openai_manager.analyze_image_with_history("Okay now please compare the previous image I sent you with this new image!", shrek_test_image, False)
    # time.sleep(60)

    ##########################################
    # MIX OF TEXT AND IMAGES WITH CHAT HISTORY
    # FIRST_SYSTEM_MESSAGE = {"role": "system", "content": "Lets have a varied conversation!"}
    # openai_manager.chat_history.append(FIRST_SYSTEM_MESSAGE)
    # patrick_test_image = "https://i.gyazo.com/dc5e707a07376cd2af03722f3031ee24.png" # patrick
    # shrek_test_image = "https://i.gyazo.com/8ec349446dbb538727e515f2b964224c.png" # shrek

    # output = openai_manager.chat_with_history("What are considered some of the most popular characters in videogames?")
    # output = openai_manager.chat_with_history("Okay, do you think this characer makes sense on that list?", patrick_test_image, False)
    # output = openai_manager.chat_with_history("What about the character Jeff Bezos? Is he a popular videogame character?")
    # output = openai_manager.chat_with_history("Okay would you consider this a popular videogame character?", shrek_test_image, False)
    # output = openai_manager.chat_with_history("Okay between those two images I showed you, which one would you consider more popular? There's obviously no right answer here, just make the best judgement you can.")
    # time.sleep(60)

    ##################################
    # SAVING AND LOADING FROM CHAT HISTORY BACKUP FILE
    # openai_manager = OpenAiManager('backup_for_testing.txt')
    # FIRST_SYSTEM_MESSAGE = {"role": "system", "content": "We're going to talk about greatest videogames of all time"}
    # openai_manager.chat_history.append(FIRST_SYSTEM_MESSAGE)
    # openai_manager.chat_with_history("What was the highest selling videogame of 2015?")
    # openai_manager.chat_with_history("Okay great, what about 2016?")
    # shrek_test_image = "https://i.gyazo.com/8ec349446dbb538727e515f2b964224c.png" # shrek
    # openai_manager.chat_with_history("What's the highest selling videogame that has this character in it?", shrek_test_image, False)
    # openai_manager.chat_with_history("Okay great, what about the highest selling game of 2017?")
    # print("test")
    # new_openai_manager = OpenAiManager('backup_for_testing.txt')
    # new_openai_manager.chat_with_history("Okay great, what about 2018?")
    # print('test2')

    ##################################
    # READING / WRITING CODE FROM THE API
    # chat_with_history = openai_manager.chat_with_history("Could you please write me a python script that uses pygame to create a very simplified version of asteroids?")
    # chat_with_history2 = openai_manager.chat_with_history("Could you please update this python code so there are elements of Pac Man as well?")
    # print("test")

    ##################################
    # TEMPERATURE TEST
    # chat_without_history = openai_manager.chat("Hey ChatGPT what is a 1 paragraph summary of the original 3 star wars movies? But tell it to me as Yoda")
    # chat_without_history = openai_manager.chat("Hey ChatGPT what is a 1 paragraph of the original 3 star wars movies? But tell it to me as Yoda", temperature=1.4)
    # chat_without_history = openai_manager.chat("Hey ChatGPT what is a 1 paragraph of the original 3 star wars movies? But tell it to me as Yoda", temperature=0.1)



