from django.db import models

# Create your models here.
class API(models.Model):
    # inputs
    Sentence = models.CharField(max_length=120)