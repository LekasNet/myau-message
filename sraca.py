import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer

model = AutoModelForSequenceClassification.from_pretrained('my_model')
tokenizer = AutoTokenizer.from_pretrained('my_model')


themes = {1: "Программирование",
          2: "Кино",
          3: "Книги",
          4: "Музыка",
          5: "Игры",
          6: "Юмор",
          7: "Экономика",
          8: "История"}


def predict(theme, message, threshold=0.5):
    inputs = tokenizer.encode_plus(
        f"{theme} [SEP] {message}",
        add_special_tokens=True,
        max_length=512,
        return_attention_mask=True,
        return_tensors='pt'
    )
    with torch.no_grad():
        outputs = model(inputs['input_ids'], attention_mask=inputs['attention_mask'])
    probs = torch.sigmoid(outputs.logits)
    probabilities = probs > threshold
    pretion = probabilities.detach().numpy().flatten()
    response = theme in [themes[i] for i in range(len(pretion)) if pretion[i] is True]
    return response
