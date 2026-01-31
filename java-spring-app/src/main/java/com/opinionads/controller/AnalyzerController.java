package com.opinionads.controller;

import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.ResourceAccessException;
import java.util.*;

@Controller
@RequestMapping("/analyzer")
public class AnalyzerController {
    
    private final String PYTHON_API_URL = "http://localhost:5000/analyze";
    private final RestTemplate restTemplate = new RestTemplate();
    
    @GetMapping("/form")
    public String showForm(Model model) {
        model.addAttribute("pageTitle", "OpinionAds - Sentiment Analyzer");
        return "review";
    }
    
    @PostMapping("/analyze")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> analyzeText(
            @RequestParam("text") String text) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Business Rule: Validation (<5 chars = 400 Bad Request)
            if (text == null || text.trim().length() < 5) {
                response.put("error", "Text must be at least 5 characters");
                response.put("received_length", text != null ? text.length() : 0);
                return ResponseEntity.badRequest().body(response);
            }
            
            // Prepare request for Python API
            Map<String, String> requestBody = new HashMap<>();
            requestBody.put("text", text.trim());
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, String>> entity = new HttpEntity<>(requestBody, headers);
            
            // Call Python API
            ResponseEntity<Map> pythonResponse = restTemplate.exchange(
                PYTHON_API_URL,
                HttpMethod.POST,
                entity,
                Map.class
            );
            
            // Return Python API response
            if (pythonResponse.getStatusCode() == HttpStatus.OK) {
                return ResponseEntity.ok(pythonResponse.getBody());
            }
            
        } catch (HttpClientErrorException e) {
            // Handle 400/500 from Python API
            response.put("error", "Python API error: " + e.getStatusCode());
            if (e.getStatusCode() == HttpStatus.BAD_REQUEST) {
                response.put("message", "Text too short or invalid");
            }
            return ResponseEntity.status(e.getStatusCode()).body(response);
            
        } catch (ResourceAccessException e) {
            // Handle timeout or connection issues
            response.put("error", "Python service unavailable");
            response.put("message", "Make sure Python Flask API is running on port 5000");
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
            
        } catch (Exception e) {
            response.put("error", "Unexpected error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("error", "Unknown error occurred");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
    
    @GetMapping("/health")
    @ResponseBody
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "OpinionAds Java Controller");
        response.put("python_api_url", PYTHON_API_URL);
        return ResponseEntity.ok(response);
    }
}