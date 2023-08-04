FROM adoptopenjdk/openjdk11
CMD ["./mvnw", "clean", "package"]
ARG JAR_FILE_PATH=target/*.jar
COPY ${JAR_FILE_PATH} spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
ENV WORKSPACE /var/jenkins_home/workspace/Project02-Pipeline-PetClinic
