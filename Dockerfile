FROM debian:sid

MAINTAINER Ilya Epifanov <elijah.epifanov@gmail.com>

RUN apt-get update \
 && apt-get install -y curl ca-certificates --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

RUN apt-get update \
 && apt-get install -y openjdk-8-jre-headless --no-install-recommends \
 && dpkg-reconfigure ca-certificates-java \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r youtrack \
 && useradd -r -d /var/lib/youtrack -m -g youtrack youtrack

ENV YOUTRACK_VERSION=6.0.12634

RUN curl -o /var/lib/youtrack/youtrack.jar -SL "http://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.jar" \
 && mkdir -p /var/lib/youtrack/teamsysdata /var/lib/youtrack/teamsysdata-backup \
 && chown -R youtrack /var/lib/youtrack

VOLUME /var/lib/youtrack/teamsysdata /var/lib/youtrack/teamsysdata-backup

WORKDIR /var/lib/youtrack

EXPOSE 9000
ENV YOUTRACK_MEM_OPTS "-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication"
CMD exec gosu youtrack java $YOUTRACK_MEM_OPTS -Djava.awt.headless=true -Djetbrains.youtrack.disableBrowser=true -jar /var/lib/youtrack/youtrack.jar 9000
