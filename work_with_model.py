import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer
from dotenv import load_dotenv
from icecream import ic

load_dotenv()

ic.enable()

model = AutoModelForSequenceClassification.from_pretrained('my_model')
tokenizer = AutoTokenizer.from_pretrained('my_model')


themes = ["Программирование", "Кино", "Книги", "Музыка", "Игры", "Юмор", "Экономика", "История"]


async def predict(theme, message, threshold=0.5):
    inputs = tokenizer.encode_plus(
        f"{message}",
        add_special_tokens=True,
        max_length=1024,
        truncation=False,
        return_attention_mask=True,
        return_tensors='pt'
    )
    with torch.no_grad():
        outputs = model(inputs['input_ids'], attention_mask=inputs['attention_mask'])
    probs = torch.sigmoid(outputs.logits)
    ic(probs)
    probabilities = probs > threshold
    ic(probabilities)
    pretion = probabilities.detach().numpy().flatten()
    ic(pretion)
    response = theme in [th for th in themes if pretion[themes.index(th)]==True]
    ic(response)
    return response
