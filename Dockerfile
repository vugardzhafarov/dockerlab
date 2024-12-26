FROM openjdk:17-jdk-slim AS builder
WORKDIR /app
COPY pom.xml ./
COPY ./src ./src
RUN apt-get update && apt-get install -y maven && \
    mvn clean install -DskipTests && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.m2/repository/*

FROM openjdk:17-jdk-slim
ARG USER_ID=1001
ARG GROUP_ID=1001
RUN groupadd -g ${GROUP_ID} appuser && useradd -u ${USER_ID} -g appuser -m -s /bin/bash appuser
WORKDIR /app
COPY --from=builder /app/target/compose-1.0.0.jar /app/compose-1.0.0.jar
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 10101
ENTRYPOINT ["java", "-jar", "/app/compose-1.0.0.jar"]