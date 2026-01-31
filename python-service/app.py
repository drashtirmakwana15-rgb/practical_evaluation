from flask import Flask, request, jsonify
from flask_cors import CORS
import time
from sentiment import SentimentAnalyzer
from database import DatabaseLogger
from config import Config

app = Flask(__name__)
CORS(app)  # Allow Java app to call this
analyzer = SentimentAnalyzer()
logger = DatabaseLogger()

@app.route('/analyze', methods=['POST'])
def analyze_text():
    # Start timer for response time
    start_time = time.time()
    
    # Get JSON data
    data = request.get_json()
    
    # Validate input
    if not data or 'text' not in data:
        return jsonify({'error': 'Missing text field'}), 400
    
    text = data['text'].strip()
    
    # Business Rule: Save costs on short texts
    if len(text) < 5:
        return jsonify({'error': 'Text must be at least 5 characters'}), 400
    
    # Analyze sentiment
    try:
        sentiment, confidence = analyzer.analyze(text)
        
        # Business Rule: Lead detection
        is_lead = analyzer.detect_lead(text)
        
        # Calculate response time
        response_time = round((time.time() - start_time) * 1000, 2)  # ms
        
        # Log to database
        logger.log_request(text, sentiment, confidence, is_lead, response_time)
        
        # Return result
        return jsonify({
            'sentiment': sentiment,
            'confidence': confidence,
            'priority_lead': is_lead,
            'response_time_ms': response_time,
            'text_length': len(text)
        })
        
    except Exception as e:
        return jsonify({'error': f'Analysis failed: {str(e)}'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'service': 'Opinion-Analyzer'})

if __name__ == '__main__':
    print(f"Starting Opinion-Analyzer API...")
    print(f"Using GPT: {Config.USE_GPT}")
    print(f"Lead keywords: {Config.LEAD_KEYWORDS}")
    app.run(host='0.0.0.0', port=5000, debug=True)