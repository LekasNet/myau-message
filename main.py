import re
import string
import nltk
from nltk import WordNetLemmatizer
from nltk.corpus import stopwords
from pydantic import BaseModel
from fastapi import FastAPI
import requests
import asyncio

from sraca import predict

nltk.download('stopwords')
stop_words = set(stopwords.words('russian'))

lemmatizer = WordNetLemmatizer()


class Message(BaseModel):
    theme: str
    message: str


app = FastAPI()


def preprocess_text(text):
    ban_word_twitch = string.punctuation + '—' + '«' + '»' + '...' + '“' + '”' + '„' + '‘' + '’'
    pattern = f'[{re.escape(ban_word_twitch)}]|[0-9]|[a-zA-Z]'
    text = re.sub(pattern, ' ', text)
    text = text.lower()
    words = nltk.word_tokenize(text)
    words = [word for word in words if word not in stop_words]
    words = [lemmatizer.lemmatize(word) for word in words]
    text = ' '.join(words)
    return text


@app.get("/data")
async def get_data():
    response = requests.get("<ссылка на Лешен сервак>")
    data = response.json()
    response = await predict(data["theme"], data["massage"])
    return {"response": response, "id": data["id"]}


@app.post("/send_data")
async def send_data(data: dict):
    response = requests.post("<ссылка на Лешен сервак>", json=data)
    if response.status_code == 200:
        return {"message": "Data sent successfully"}
    else:
        return {"message": "Failed to send data"}


async def poll_data():
    while True:
        data = await get_data()
        await send_data(data)
        await asyncio.sleep(0.5)


async def main():
    await asyncio.create_task(poll_data())


if __name__ == "__main__":
    asyncio.run(main())
