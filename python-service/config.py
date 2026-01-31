import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # ---------------- Database ----------------
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = int(os.getenv('DB_PORT', 3306))   # ✅ add this
    DB_USER = os.getenv('DB_USER', 'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')
    DB_NAME = os.getenv('DB_NAME', 'sentiment_db')
    DB_CHARSET = 'utf8mb4'  # ✅ add this (best for text)

    # ---------------- OpenAI (optional) ----------------
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
    USE_GPT = os.getenv('USE_GPT', 'False').lower() == 'true'

    # ---------------- App ----------------
    DEBUG = os.getenv('DEBUG', 'True').lower() == 'true'  # ✅ add this

    # ---------------- Lead detection ----------------
    LEAD_KEYWORDS = ['contact', 'call', 'email', 'reach', 'callback', 'phone']
