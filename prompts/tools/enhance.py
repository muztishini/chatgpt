
from rest_framework.request import Request

from core.gpt import handle_gpt3


def get_enhance_response(request: Request):

    max_role_tokens = 50          # Kоличество токенов роль чата по умолчанию
    # Kоличество токенов пользовательского запроса по умолчанию
    max_prompt_tokens = 1000
    # Kоличество токенов ответа чата (ПО умолчанию) - Задается пользователем
    max_response_tokens = 2950
    set_token_price = 0.000002    # Цена одного токена
    temperature = 0.7             # Температура
    timeout = 5                   # Таймаут при нецензурном слове
    model_chat_gpt = 'gpt-3.5-turbo'  # Версия модели чата GPT

    # Получаем JSON-данные из запроса от frontend
    data = request.data

    # Извлекаем 'Переменные' из запроса от frontend
    textarea1 = str(data.get('textarea1', ''))      	# Статья, абзац
    textarea2 = str(data.get('textarea2', ''))          # Дополнительные данные
    dropdown1 = data.get('dropdown1', '')         		# Уровень творчества
    dropdown2 = float(data.get('dropdown2', ''))    	# Кол-во символов

    # Выбор Модели чата GPT для обработки данных
    dropdown3 = str(data.get('dropdown3', ''))    # Версия модели чата GPT
    if dropdown3.strip():
        model_chat_gpt = dropdown3                  # Версия модели чата GPT

    if dropdown1.strip():  # Hе пустое ли значение Уровень творчества
        # Преобразуем в число и делим на 10 Уровень творчества
        temperature = float(dropdown1) / 10

    # Переводим Символы в Токены Ограничения ответ чата
    max_response_tokens = round(dropdown2 / 1.0)
    # Кол-во. Символов для Промта в чат
    max_length = round(dropdown2 / 1.0)

    # Роль чата GPT
    chat_role = (
        'Представь ты самая огромная база знаний и можешь оперативно и точно '
        'выдавать необходимую информацию.'
    )

    # Пользовательский промт
    prompt = ''

    # Статья, абзац
    prompt += f' Вот есть статья: [{textarea1}]'
    if textarea2.strip():
        prompt += f'. {textarea2}'  # Дополнительные данные

    prompt += (
        ' Я ничего не знаю в этой области. Расскажи мне пожалуйста подробно '
        'о всех нюансах о всех вариантах что могут быть связаны с этой '
        'статьёй. Прокачай эту статью. Расширь ее, расскажи о дополнительных '
        'нюансах, добавь все важное что может быть связано с этим '
        'направлением. Напиши перечень смежных направлений что как-то связано '
        'с этим направлением. Напиши перспективные направления. Размер статьи '
        f'{max_length} символов.'
    )

    # Вызов обработчика GPT3 и возврат результата
    return handle_gpt3(
        chat_role=chat_role,
        prompt=prompt,
        timeout=timeout,
        temperature=temperature,
        set_token_price=set_token_price,
        max_role_tokens=max_role_tokens,
        max_prompt_tokens=max_prompt_tokens,
        max_response_tokens=max_response_tokens,
        model_chat_gpt=model_chat_gpt
    )
