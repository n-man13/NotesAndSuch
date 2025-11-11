from gtts import gTTS
import os

def text_to_speech(text, filename=None, language='en-uk'):
    """
    Convert text to speech using gTTS and save as MP3 file.
    Uses British English ('en-uk') by default for closest to British accent.
    
    Args:
        text (str): The text to convert to speech
        filename (str, optional): Output filename without extension. If None, uses 'output'
        language (str, optional): Language code (default: 'en-uk' for British English)
    
    Returns:
        str: Path to the created MP3 file
    """
    if filename is None:
        filename = 'output'
    
    # Create gTTS object
    tts = gTTS(text=text, lang=language, slow=False)
    
    # Save as mp3
    mp3_path = f"{filename}.mp3"
    tts.save(mp3_path)
    
    print(f"Audio saved as: {mp3_path}")
    return mp3_path

# Example usage
if __name__ == "__main__":
    # Test the function with British English
    audio_file = text_to_speech("Hello, this is a test using British English pronunciation.")
    print(f"Created audio file: {audio_file}")
    
    # Test with custom filename
    audio_file2 = text_to_speech("Good day! How are you doing today?", "british_greeting")
    print(f"Created audio file: {audio_file2}")
