from django.apps import AppConfig
from factualweb import settings
import os
import tensorflow as tf
try:
    from transformers import BertTokenizer
except ImportError:
    raise ImportError
from pathlib import Path

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'API'
    '''
    https://gcsfs.readthedocs.io/en/latest/
    BASE_DIR_T="".join([i+"/" for i in dir])
    MODEL_FILE_T = [i for i in MODELS.split('/') if i!=""][0]
    TOKENIZER_FILE_T = [i for i in TOKENIZER.split('/') if i!=""][0]
    dir= [i for i in str(BASE_DIR).split('/') if i!=""]
    '''
    tokenizer= BertTokenizer.from_pretrained("bert-base-uncased")
    model=tf.keras.models.load_model("API/models")