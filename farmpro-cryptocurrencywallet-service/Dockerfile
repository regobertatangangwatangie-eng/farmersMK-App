FROM eclipse-temurin:17-jdk-jammy

# Copy the built jar file
COPY target/*.jar app.jar

EXPOSE 8088

ENTRYPOINT ["java", "-jar", "/app.jar"]