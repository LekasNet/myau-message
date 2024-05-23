import os
import requests
import asyncio
from criptor import use_decrypt
from work_with_model import predict
from icecream import ic
from dotenv import load_dotenv

load_dotenv()

ic.disable()


async def get_conversations():
    response = requests.get("https://myau-message.onrender.com/api/conversations/user-conversations",
                            headers={"Authorization": os.getenv("TOKEN")}).json()
    ic(response)
    return response


async def get_message(id):
    response = requests.get(f"https://myau-message.onrender.com/api/admin/conversations/{id}/last_message",
                            headers={"Authorization": os.getenv("TOKEN")})
    if response.status_code == 404:
        return {"response": None}
    ic(response.json(), type(response.json()))
    data = use_decrypt(str(response.json()))
    ic(data)
    answer = await predict(data["theme"], data["content"][:-20])
    ic(answer)
    return {"response": answer, "id": data["id"]}


async def send_data(id, data):
    response = requests.patch(f"https://myau-message.onrender.com/api/admin/messages/{id}/ban",
                              headers={"Authorization": os.getenv("TOKEN")},
                              json=data)
    if response.status_code == 200:
        return {"message": "Data sent successfully"}
    else:
        return {"message": "Failed to send data"}


async def poll_data():
    while True:
        conversations = await get_conversations()
        for conversation in conversations:
            ic(conversation)
            data = await get_message(conversation['id'])
            if data["response"] is None:
                continue
            await send_data(data["id"], {"ban": data["response"]})
        await asyncio.sleep(0.5)


async def main():
    await asyncio.create_task(poll_data())


if __name__ == "__main__":
    asyncio.run(main())
