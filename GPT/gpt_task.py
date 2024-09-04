import base64
import requests
from tqdm import tqdm
import os
import time
import numpy as np
import sys

# model params
model = "gpt-4o"
top_p = 0.5


# Function to encode the image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')


def get_response(prompt, image_path):
    # Getting the base64 string
    base64_image = encode_image(image_path)

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }

    payload = {
        "model": model,
        "top_p": top_p,
        "messages": [
            {
             "role": "user",
             "content": [
                {
                 "type": "text",
                 "text": prompt
                },
                {
                 "type": "image_url",
                 "image_url": {
                    "url": f"data:image/jpeg;base64,{base64_image}"
                 }
                }
             ]
            }
        ],
        "max_tokens": 300
    }

    response = requests.post("https://api.openai.com/v1/chat/completions",
                             headers=headers, json=payload)

    response_json = response.json()
    print(response_json)

    answer = response_json['choices'][0]['message']['content']

    print(answer)
    return answer


if __name__ == "__main__":
    # Define arguments: Number of runs, task, and API key
    if len(sys.argv) < 5:
        print(
            "Usage: python gpt_task.py <num_runs> <task> <api_key>"
            " <output_file>")
        sys.exit(1)
    else:
        num_runs = int(sys.argv[1])
        task = sys.argv[2]  # infront_behind, left_right, 9_6, M_W, cot
        api_key = sys.argv[3]
        filename = sys.argv[4]

        # Define image directory
        image_folder = (f'images/jpeg/{task}')

        # Define prompts based on task
        if task == "infront_behind":
            question = ("For the following images respond with "
                        "'INFRONT' or 'BEHIND' to indicate if the "
                        "cube is INFRONT or BEHIND the PERSON")
        elif task == "left_right":
            question = ("For the following images respond with 'LEFT' or "
                        "'RIGHT' to indicate if the cube is to the LEFT or "
                        "RIGHT from the PERSPECTIVE OF THE PERSON")
        elif task == '9_6':
            question = ("For the following images respond with '6' or '9' "
                        "to indicate if the number on the cube is a 6 or "
                        " 9 from the PERSPECTIVE OF THE PERSON")
        elif task == 'M_W':
            question = ("For the following images respond with 'M' or 'W' "
                        "to indicate if the letter on the cube is a M or "
                        " W from the PERSPECTIVE OF THE PERSON")
        elif task == 'cot':
            question = ("Analyze this image step by step to determine if the "
                        "cube is to the person's left or right, from the "
                        "person's perspective. "
                        "First, identify the direction the person is looking "
                        "relative to the camera. "
                        "Second, determine if the cube is to the left or "
                        "right, relative to the camera. "
                        "Third, if the person is facing the camera,"
                        "then from their perspective, the cube is to the "
                        "inverse of the camera's left or right. If the person "
                        "is facing away from the camera, "
                        "then the cube is to the same side as the camera. "
                        "Respond with whether the cube is to the person's "
                        "left or right. "
                        )
            image_folder = ('images/jpeg/left_right')

        if task != 'cot':  # For all levels except cot we save as .txt file
            responses = {}
        else:
            responses = []

        images = os.listdir(image_folder)
        # Only use files not directories
        images = [image for image in images if os.path.isfile(
            os.path.join(image_folder, image))]

        for image in tqdm(images):
            print(image)
            image_name = image.split('.')[0]
            image_response = []
            for i in range(num_runs):
                jpeg_path = os.path.join(image_folder, image)

                response = get_response(question, jpeg_path)

                if task != 'cot':
                    if image_name not in responses:
                        responses[image_name] = [response]
                    else:
                        responses[image_name].append(response)
                else:
                    image_response.append(response)
                time.sleep(5)  # To avoid rate limit
            if task == 'cot':
                responses.append(image_response)

        if task != 'cot':
            with open(f"{filename}.txt", "w") as file:
                for image, response in responses.items():
                    file.write(f"{image}: {response}\n")
        else:
            responses = np.array(responses)
            np.save(f"{filename}.npy", responses)
