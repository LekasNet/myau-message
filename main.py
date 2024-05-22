import os
from fastapi import FastAPI
import requests
import asyncio
from sraca import predict
from icecream import ic
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()


@app.get("/get/conversations")
async def get_conversations():
    response = requests.get("https://myau-message.onrender.com/api/conversations/user-conversations",
                            headers={"Authorization": os.getenv("TOKEN")}).json()
    ic(response)
    answer = [{"id": i["id"]} for i in response]
    return answer


@app.get("/data")
async def get_message(id):
    response = requests.get(f"https://myau-message.onrender.com/api/admin/conversations/{id}/1ast_message",
                            headers={"Authorization": os.getenv("TOKEN")})
    ic(response)
    if response.status_code == 404:
        return {"response": None}
    data = response.json()
    response = await predict(data["theme"], data["massage"])
    return {"response": response, "id": data["id"]}


@app.patch("/send_data")
async def send_data(id):
    response = requests.patch(f"https://myau-message.onrender.com/api/admin/messages/{id}/ban",
                              headers={"Authorization": os.getenv("TOKEN")})
    if response.status_code == 200:
        return {"message": "Data sent successfully"}
    else:
        return {"message": "Failed to send data"}


async def poll_data():
    while True:
        conversations = get_conversations()
        for conversation in conversations:
            data = await get_message(conversation["id"])
            if data["response"] is None:
                continue
            if not data["response"]:
                await send_data(data["id"])
        await asyncio.sleep(0.5)


async def main():
    await asyncio.create_task(poll_data())


if __name__ == "__main__":
    asyncio.run(main())
