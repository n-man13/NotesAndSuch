import webbrowser

# Browser path - can be any browser executable
# BROWSER_PATH = "C:/Program Files/Google/Chrome/Application/chrome.exe"
BROWSER_PATH = 'C:/Program Files/Mozilla Firefox/firefox.exe'

def open_website(url):
    """
    Opens the given URL in the specified browser.
    
    Args:
        url (str): The website URL to open
    """
    # Get the browser instance
    browser = webbrowser.get(BROWSER_PATH + ' %s')
    
    # Open the URL in the browser
    browser.open(url)
    
    print(f'Opening: {url}')

# Example usage:
if __name__ == "__main__":
    # You can call the function like this:
    open_website("https://www.google.com")
    pass
