package com.opinionads;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class OpinionAnalyzerApplication extends SpringBootServletInitializer {
    
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(OpinionAnalyzerApplication.class);
    }
    
    public static void main(String[] args) {
        SpringApplication.run(OpinionAnalyzerApplication.class, args);
        System.out.println("\n" + "=".repeat(60));
        System.out.println("✅ OPINION ANALYZER APPLICATION STARTED");
        System.out.println("=".repeat(60));
        System.out.println("🌐 Access URL: http://localhost:8080/analyzer/form");
        System.out.println("📊 Python API: http://localhost:5000/analyze");
        System.out.println("🔄 Health Check: http://localhost:8080/analyzer/health");
        System.out.println("=".repeat(60) + "\n");
    }
}