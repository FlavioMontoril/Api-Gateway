# Etapa 1: Build da aplicação (utilizando Maven)
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copia o arquivo de dependências para aproveitar o cache do Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia o código-fonte e compila gerando o .jar
COPY src ./src
RUN mvn package -DskipTests

# Etapa 2: Imagem final de execução leve e sem privilégios de root
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Cria um grupo e um usuário do sistema sem privilégios de root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copia o JAR compilado alterando a propriedade do arquivo para o novo usuário
COPY --from=build --chown=appuser:appgroup /app/target/*.jar app.jar

# Define o usuário criado para executar o container
USER appuser

# Expõe a porta do Gateway
EXPOSE 8083

# Comando para rodar a aplicação Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]