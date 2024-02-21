import os
import argparse
import ast
from pprint import pprint as pp
from azure.ai.contentsafety import ContentSafetyClient
from azure.core.credentials import AzureKeyCredential
from azure.core.exceptions import HttpResponseError
from azure.ai.contentsafety.models import AnalyzeTextOptions, TextCategory, AnalyzeImageOptions, ImageData
from dotenv import load_dotenv


def analyze_text(client=None, textpath=None):
    print(f"Text statement: {textpath}")
    request = AnalyzeTextOptions(text=textpath, categories=[TextCategory.HATE,
                                                        TextCategory.SELF_HARM,
                                                        TextCategory.VIOLENCE,
                                                        TextCategory.SEXUAL])
    try:
        response = client.analyze_text(request)
    except HttpResponseError as e:
        print("Analyze text failed.")
        if e.error:
            print(f"Error code: {e.error.code}")
            print(f"Error message: {e.error.message}")
            raise
        print(e)
        raise
    if response:
        # print(ast.literal_eval(response))
        print(response)


def form_factor(client=None, filepath=None, textpath=None, imagepath=None):
    """Analyze Azure AI content safety results with a text string, filepath or image"""

    # Input: text, file or image
    if textpath:
        analyze_text(client, textpath)

    if filepath:
        text_path = os.path.abspath(os.path.join(os.path.abspath(__file__), "..", "./samples/text.txt"))
        # Read sample data, and build request
        with open(text_path) as f:
            text_list = f.readlines()
        # Create one string from the list of strings
        text_list = [x.replace('\n', '.') for x in text_list]
        text = " ".join(text_list)
        analyze_text(client, text)

    if imagepath:
        # Build request
        image_path = os.path.abspath(os.path.join(os.path.abspath(__file__), "..", "./samples/image.jpg"))
        with open(image_path, "rb") as file:
            my_file = file.read()

        # Analyze image
        try:
            response = client.analyze_image(AnalyzeImageOptions(image=ImageData(content=my_file)))
        except Exception as e:
            print("Error code: {}".format(e.error.code))
            print("Error message: {}".format(e.error.message))
            return
        if response:
            print(response)
            # print(ast.literal_eval(response))


if __name__ == "__main__":
    # Argument parser
    parser = argparse.ArgumentParser()
    parser.add_argument("--text_string", "--verb", type=str)
    parser.add_argument("--filepath", action='store_true', default=False)
    parser.add_argument("--imagepath", action='store_true', default=False)
    args = parser.parse_args()

    # Load env variables
    load_dotenv('./variables.env')
    key, endpoint = os.environ["CONTENT_SAFETY_KEY"], os.environ["CONTENT_SAFETY_ENDPOINT"]

    # Create an Content Safety client
    client = ContentSafetyClient(endpoint, AzureKeyCredential(key))

    # Analyze content
    form_factor(client=client, filepath=args.filepath, textpath=args.text_string, imagepath=args.imagepath)
