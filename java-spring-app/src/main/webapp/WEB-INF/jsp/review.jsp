<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>OpinionAds - Sentiment Analyzer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 800px;
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        
        .header p {
            opacity: 0.9;
        }
        
        .content {
            padding: 40px;
        }
        
        textarea {
            width: 100%;
            padding: 18px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 1rem;
            resize: vertical;
            min-height: 150px;
            margin: 20px 0;
        }
        
        textarea:focus {
            outline: none;
            border-color: #4f46e5;
        }
        
        .char-count {
            text-align: right;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .btn {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            color: white;
            border: none;
            padding: 16px 40px;
            font-size: 1.1rem;
            font-weight: 600;
            border-radius: 12px;
            cursor: pointer;
            display: block;
            margin: 0 auto;
            transition: transform 0.3s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        
        .loading {
            text-align: center;
            padding: 20px;
            display: none;
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #4f46e5;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .result {
            background: #f9fafb;
            border-radius: 12px;
            padding: 25px;
            margin-top: 30px;
            display: none;
            animation: fadeIn 0.5s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .sentiment-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: 600;
            margin-right: 15px;
            margin-bottom: 15px;
        }
        
        .positive {
            background: #d1fae5;
            color: #065f46;
        }
        
        .negative {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .neutral {
            background: #e5e7eb;
            color: #374151;
        }
        
        .lead-flag {
            display: inline-block;
            padding: 8px 20px;
            background: #fef3c7;
            color: #92400e;
            border-radius: 20px;
            font-weight: 600;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 25px;
        }
        
        .stat-item {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #4f46e5;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .error {
            background: #fee2e2;
            border: 2px solid #ef4444;
            color: #991b1b;
            padding: 20px;
            border-radius: 12px;
            margin-top: 20px;
            display: none;
        }
        
        .example {
            cursor: pointer;
            padding: 10px;
            border-radius: 8px;
            margin: 5px 0;
            background: #f8fafc;
            border-left: 3px solid transparent;
        }
        
        .example:hover {
            background: #f1f5f9;
            border-left-color: #4f46e5;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Opinion Analyzer</h1>
            <p>AI-powered sentiment analysis with lead detection</p>
            <p style="font-size: 0.9rem; margin-top: 10px;">Python Flask API + Spring Boot Integration</p>
        </div>
        
        <div class="content">
            <!-- Example Texts -->
            <div style="margin-bottom: 20px;">
                <p style="font-weight: 600; margin-bottom: 10px;">Try these examples:</p>
                <div class="example" onclick="fillText('I love this product! Please call me for details.')">
                    "I love this product! Please call me for details."
                </div>
                <div class="example" onclick="fillText('Terrible service. I want a refund immediately.')">
                    "Terrible service. I want a refund immediately."
                </div>
                <div class="example" onclick="fillText('Please email me the pricing information.')">
                    "Please email me the pricing information."
                </div>
            </div>
            
            <form id="analyzeForm">
                <textarea 
                    id="textInput" 
                    placeholder="Enter your text here... (minimum 5 characters)"
                    oninput="updateCharCount()"></textarea>
                <div class="char-count">
                    <span id="charCount">0</span> characters
                </div>
                
                <button type="submit" class="btn" id="analyzeBtn" disabled>
                    Analyze Sentiment
                </button>
            </form>
            
            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p>Analyzing with AI engine...</p>
            </div>
            
            <div class="error" id="errorBox">
                <strong>Error:</strong> <span id="errorMessage"></span>
            </div>
            
            <div class="result" id="resultBox">
                <h3 style="margin-bottom: 20px;">Analysis Results:</h3>
                
                <div>
                    <span class="sentiment-badge" id="sentimentBadge">Positive</span>
                    <span class="lead-flag" id="leadFlag" style="display: none;">🔥 Priority Lead</span>
                </div>
                
                <div class="stats">
                    <div class="stat-item">
                        <div class="stat-value" id="confidenceValue">0.95</div>
                        <div class="stat-label">Confidence</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value" id="responseTime">26ms</div>
                        <div class="stat-label">Response Time</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value" id="textLength">38</div>
                        <div class="stat-label">Characters</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // DOM Elements
        const textInput = document.getElementById('textInput');
        const charCount = document.getElementById('charCount');
        const analyzeBtn = document.getElementById('analyzeBtn');
        const loading = document.getElementById('loading');
        const errorBox = document.getElementById('errorBox');
        const errorMessage = document.getElementById('errorMessage');
        const resultBox = document.getElementById('resultBox');
        const sentimentBadge = document.getElementById('sentimentBadge');
        const leadFlag = document.getElementById('leadFlag');
        
        // Fill example text
        function fillText(text) {
            textInput.value = text;
            updateCharCount();
        }
        
        // Update character count
        function updateCharCount() {
            const length = textInput.value.length;
            charCount.textContent = length;
            
            // Enable/disable button based on length
            if (length < 5) {
                analyzeBtn.disabled = true;
                textInput.style.borderColor = '#ef4444';
                charCount.style.color = '#ef4444';
            } else {
                analyzeBtn.disabled = false;
                textInput.style.borderColor = '#10b981';
                charCount.style.color = '#10b981';
            }
        }
        
        // Form submission
        document.getElementById('analyzeForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            // Reset UI
            errorBox.style.display = 'none';
            resultBox.style.display = 'none';
            loading.style.display = 'block';
            
            const text = textInput.value.trim();
            
            try {
                // Call Java controller endpoint
                const response = await fetch('/analyzer/analyze', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({
                        'text': text
                    })
                });
                
                const data = await response.json();
                
                if (!response.ok) {
                    throw new Error(data.error || 'Unknown error');
                }
                
                // Display results
                displayResults(data);
                
            } catch (error) {
                errorMessage.textContent = error.message;
                errorBox.style.display = 'block';
                
                // Show fallback for connection issues
                if (error.message.includes('unavailable')) {
                    showFallbackResults();
                }
            } finally {
                loading.style.display = 'none';
            }
        });
        
        // Display analysis results
        function displayResults(data) {
            // Set sentiment badge
            sentimentBadge.textContent = data.sentiment;
            sentimentBadge.className = 'sentiment-badge ' + data.sentiment.toLowerCase();
            
            // Set lead flag
            if (data.priority_lead) {
                leadFlag.style.display = 'inline-block';
            } else {
                leadFlag.style.display = 'none';
            }
            
            // Set statistics
            document.getElementById('confidenceValue').textContent = data.confidence.toFixed(2);
            document.getElementById('responseTime').textContent = data.response_time_ms + 'ms';
            document.getElementById('textLength').textContent = data.text_length;
            
            // Show results
            resultBox.style.display = 'block';
        }
        
        // Fallback results when Python API is down
        function showFallbackResults() {
            sentimentBadge.textContent = 'Neutral';
            sentimentBadge.className = 'sentiment-badge neutral';
            leadFlag.style.display = 'none';
            
            document.getElementById('confidenceValue').textContent = '0.50';
            document.getElementById('responseTime').textContent = 'N/A';
            document.getElementById('textLength').textContent = textInput.value.length;
            
            resultBox.style.display = 'block';
        }
        
        // Initialize
        updateCharCount();
        fillText("I love this product! Please call me for more details.");
    </script>
</body>
</html>