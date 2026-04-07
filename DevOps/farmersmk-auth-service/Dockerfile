# Use a Java 17 runtime
FROM eclipse-temurin:17-jdk-jammy

# Set working directory
WORKDIR /app

# Copy the built JAR from target/
COPY target/auth-service-1.0.0.jar app.jar

# Expose the port your service runs on
EXPOSE 8081

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]