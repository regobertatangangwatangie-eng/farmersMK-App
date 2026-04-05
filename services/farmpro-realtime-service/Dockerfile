FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/realtime-service-1.0.0.jar app.jar

EXPOSE 8087

ENTRYPOINT ["java","-jar","app.jar"]