from textblob import TextBlob
import openai
import re
from config import Config

class SentimentAnalyzer:
    def __init__(self):
        if Config.USE_GPT and Config.OPENAI_API_KEY:
            openai.api_key = Config.OPENAI_API_KEY
            self.use_gpt = True
        else:
            self.use_gpt = False
    
    def analyze_with_gpt(self, text):
        """Use OpenAI GPT for accurate sentiment (production-ready)"""
        try:
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "Analyze sentiment. Return ONLY JSON: {\"sentiment\": \"Positive/Negative/Neutral\", \"confidence\": 0.0-1.0}"},
                    {"role": "user", "content": text}
                ],
                temperature=0.1,
                max_tokens=50
            )
            
            # Extract JSON from response
            import json
            result = json.loads(response.choices[0].message.content)
            return result['sentiment'], float(result['confidence'])
            
        except Exception as e:
            print(f"GPT API failed: {e}")
            raise
    
    def analyze_with_textblob(self, text):
        """Fallback: Use TextBlob (free, offline)"""
        analysis = TextBlob(text)
        polarity = analysis.sentiment.polarity  # -1 to 1
        
        # Determine sentiment
        if polarity > 0.1:
            sentiment = "Positive"
        elif polarity < -0.1:
            sentiment = "Negative"
        else:
            sentiment = "Neutral"
        
        # Convert polarity to confidence (0-1)
        confidence = min(abs(polarity) * 2.5, 1.0)
        
        return sentiment, round(confidence, 2)
    
    def analyze(self, text):
        """Main analysis method with fallback"""
        if self.use_gpt:
            try:
                return self.analyze_with_gpt(text)
            except:
                print("Falling back to TextBlob")
                return self.analyze_with_textblob(text)
        else:
            return self.analyze_with_textblob(text)
    
    def detect_lead(self, text):
        """Check for sales lead keywords"""
        text_lower = text.lower()
        for keyword in Config.LEAD_KEYWORDS:
            if re.search(r'\b' + keyword + r'\b', text_lower):
                return True
        return False