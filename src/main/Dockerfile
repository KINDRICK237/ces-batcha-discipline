FROM tomcat:10.1-jdk21
RUN rm -rf /usr/local/tomcat/webapps/*
RUN mkdir -p /usr/local/tomcat/webapps/ROOT
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes
COPY src/main/java/ /tmp/java/
RUN find /tmp/java -name "*.java" > /tmp/sources.txt && \
    javac -encoding UTF-8 \
    -cp "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    @/tmp/sources.txt
EXPOSE 8080
CMD ["catalina.sh", "run"]