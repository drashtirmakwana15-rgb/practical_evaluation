1. Create Python API Security Group (port 5000 from Java only)
2. Create Java App Security Group (port 8080 from ALB only)  
3. Create MySQL Security Group (port 3306 from Python only)
4. Configure Java → Python communication (port 5000)
5. Configure Python → MySQL communication (port 3306)
6. Configure ALB Security Group (ports 80/443 to Java)
7. Restrict SSH access to office IP only
8. Test security rules
