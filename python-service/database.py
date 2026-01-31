import mysql.connector
from mysql.connector import Error
from datetime import datetime
from config import Config

class DatabaseLogger:
    def __init__(self):
        self.connection = None
        self.connect()
    
    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host=Config.DB_HOST,
                user=Config.DB_USER,
                password=Config.DB_PASSWORD,
                database=Config.DB_NAME
            )
        except Error as e:
            print(f"Database connection failed: {e}")
            self.connection = None
    
    def log_request(self, text, sentiment, confidence, is_lead, response_time):
        if not self.connection:
            return False
        
        try:
            cursor = self.connection.cursor()
            query = """
                INSERT INTO sentiment_logs 
                (text, sentiment, confidence, is_lead, response_time, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            values = (text, sentiment, confidence, is_lead, response_time, datetime.now())
            cursor.execute(query, values)
            self.connection.commit()
            cursor.close()
            return True
        except Error as e:
            print(f"Logging failed: {e}")
            return False