# DNYFappbuilder — Java Spring Boot Production Dockerfile
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app
COPY . .

RUN chmod +x gradlew 2>/dev/null || chmod +x mvnw 2>/dev/null || true

RUN if [ -f gradlew ]; then \
        ./gradlew bootJar --no-daemon -q; \
    elif [ -f mvnw ]; then \
        ./mvnw clean package -DskipTests -q; \
    fi

# ── Production stage ──────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS production

RUN addgroup -S spring && adduser -S spring -G spring
USER spring

WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar 2>/dev/null || \
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "app.jar"]
