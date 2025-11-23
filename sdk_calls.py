import os
import argparse
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv('./variables.env')

def main():
    parser = argparse.ArgumentParser(description='Test Azure OpenAI API with optional custom content filter')
    parser.add_argument('--message', '-m', type=str, required=True, help='The user message to send')
    parser.add_argument('--use-custom-policy', action='store_true', help='Use custom content filter policy (empty-custom)')
    
    args = parser.parse_args()
    user_msg = args.message
    use_custom_policy = args.use_custom_policy
    
    # Prepare extra headers
    extra_headers = {}
    if use_custom_policy:
        extra_headers["x-policy-id"] = "empty-custom"
        print(f"Using custom policy: empty-custom\n")

    client = OpenAI(  
      base_url = f"{os.getenv('OPENAI_ENDPOINT')}openai/v1/",  
      api_key = os.getenv('OPENAI_KEY'),
      default_headers=extra_headers
    )

    try:
        response = client.responses.create(
            model=f"{os.getenv('OPENAI_DEPLOYMENT_NAME')}",
            input= user_msg
        )

        print("Responses API call:\n")
        print(response.model_dump_json(indent=2))
    except Exception as e:
        print(f"Responses API hit an error: {e}")


    try:
        completion = client.chat.completions.create(
            model=f"{os.getenv('OPENAI_DEPLOYMENT_NAME')}",
            messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": user_msg}
          ]
        )

        print("Chat Completions API call:\n")
        print(completion.model_dump_json(indent=2))
    except Exception as e:
        print(f"Chat Completions API hit an error: {e}")

if __name__ == "__main__":
    main()
