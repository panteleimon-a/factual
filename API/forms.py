from django import forms
from API.models import API

class Platform(forms.ModelForm):
    Sentence = forms.CharField(max_length=120, widget=forms.TextInput(
        attrs={
            'class':'form-control',
        }
    ))
    class Meta:
        model = API
        fields = [
            'Sentence'
        ]