FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# This line fixes EVERYTHING (no more name issues)
COPY target/*.jar app.jar

EXPOSE 8090

ENTRYPOINT ["java", "-jar", "app.jar"]