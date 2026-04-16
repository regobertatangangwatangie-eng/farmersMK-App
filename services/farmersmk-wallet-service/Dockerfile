FROM maven:3.9.9-eclipse-temurin-21 AS build
COPY maven-settings.xml /usr/share/maven/ref/settings.xml
WORKDIR /build
COPY services/farmersmk-wallet-service/pom.xml .
RUN mvn dependency:go-offline -q --settings /usr/share/maven/ref/settings.xml 2>/dev/null || true
COPY services/farmersmk-wallet-service/src ./src
RUN mvn clean package -DskipTests -q --settings /usr/share/maven/ref/settings.xml

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8086
ENTRYPOINT ["java","-jar","app.jar"]