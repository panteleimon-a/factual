from django.apps import AppConfig
import os

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'API'
    tokenizer = None
    model = None
    
    def ready(self):
        """
        Initialize model and tokenizer when Django starts.
        Only load if models directory exists.
        """
        # Import dependencies here to avoid import errors when they're not installed
        try:
            from transformers import BertTokenizer
            import tensorflow as tf
        except ImportError as e:
            print(f"⚠ Warning: Could not import ML dependencies: {e}")
            print("  Model and tokenizer will not be available.")
            return
            
        if ApiConfig.tokenizer is None:
            try:
                ApiConfig.tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
                print("✓ Tokenizer loaded successfully")
            except Exception as e:
                print(f"⚠ Warning: Could not load tokenizer: {e}")
                
        if ApiConfig.model is None:
            model_path = os.path.join(os.path.dirname(__file__), "models")
            if os.path.exists(model_path):
                try:
                    ApiConfig.model = tf.keras.models.load_model(model_path)
                    print("✓ Model loaded successfully")
                except Exception as e:
                    print(f"⚠ Warning: Could not load model: {e}")
            else:
                print(f"⚠ Warning: Model directory not found at {model_path}")