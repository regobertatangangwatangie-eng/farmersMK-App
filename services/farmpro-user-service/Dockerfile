# Use lightweight Java 17 image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory in container
WORKDIR /app

# Copy JAR from target folder
# Use wildcard to avoid version mismatch
COPY target/*.jar app.jar

# Expose port your service runs on
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]