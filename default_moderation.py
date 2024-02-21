import os
import argparse
from azure.ai.contentsafety import ContentSafetyClient
from azure.core.credentials import AzureKeyCredential
from azure.core.exceptions import HttpResponseError
from azure.ai.contentsafety.models import AnalyzeTextOptions, TextCategory, AnalyzeImageOptions, ImageData
from dotenv import load_dotenv


def response_statement(response):
    if response.hate_result:
        print(f"Hate severity: {response.hate_result.severity}")
    if response.self_harm_result:
        print(f"Self-harm severity: {response.self_harm_result.severity}")
    if response.sexual_result:
        print(f"Sexual severity: {response.sexual_result.severity}")
    if response.violence_result:
        print(f"Violence severity: {response.violence_result.severity}")


def analyze(filepath=None, textpath=None, imagepath=None):
    # Create an Content Safety client
    client = ContentSafetyClient(endpoint, AzureKeyCredential(key))

    # Input: text, or file
    if filepath:
        text_path = os.path.abspath(os.path.join(os.path.abspath(__file__), "..", "./samples/text.txt"))
        # Read sample data, and build request
        with open(text_path) as f:
            text_list = f.readlines()
        # Create one string from the list of strings
        text_list = [x.replace('\n', '.') for x in text_list]
        text = " ".join(text_list)

    if textpath:
        print(f"Text statement: {text}")
        request = AnalyzeTextOptions(text=text, categories=[TextCategory.HATE,
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
            response_statement(response)

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
            response_statement(response)


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

    # Analyze content
    analyze(filepath=args.filepath, textpath=args.text_string, imagepath=args.imagepath)
