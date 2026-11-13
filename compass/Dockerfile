# syntax=docker/dockerfile:1
#
# Official MongoDB Compass desktop app, served to a web browser through
# TigerVNC (virtual X display) + noVNC (HTML5 VNC client).
#
# Base image: Ubuntu 24.04 LTS (Noble Numbat).
FROM ubuntu:24.04

ARG COMPASS_VERSION=1.53.2
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8 \
    DISPLAY=:1 \
    VNC_RESOLUTION=1600x900 \
    VNC_PASSWORD= \
    COMPASS_CONNECTION_STRING= \
    NO_AT_BRIDGE=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl \
      tigervnc-standalone-server tigervnc-tools \
      novnc websockify \
      openbox supervisor dbus-x11 \
      fonts-dejavu-core fonts-liberation \
 && curl -fsSL -o /tmp/mongodb-compass.deb \
      "https://downloads.mongodb.com/compass/mongodb-compass_${COMPASS_VERSION}_amd64.deb" \
 && apt-get install -y --no-install-recommends /tmp/mongodb-compass.deb \
 && rm -f /tmp/mongodb-compass.deb /usr/share/novnc/index.html \
 && rm -rf /var/lib/apt/lists/*

# Openbox: show the Compass main window maximized and without a title bar,
# so the browser tab looks like a web app. Dialogs keep their normal size.
RUN sed -i 's|</applications>|<application class="*" type="normal"><decor>no</decor><maximized>yes</maximized></application></applications>|' \
      /etc/xdg/openbox/rc.xml

# Run everything as an unprivileged user (replaces the stock "ubuntu" user, uid 1000).
RUN userdel -r ubuntu \
 && useradd -m -u 1000 -s /bin/bash compass \
 && mkdir -p "/home/compass/.config/MongoDB Compass" /home/compass/.vnc \
 && chown -R compass:compass /home/compass \
 && mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

COPY mongodb-compass.conf /etc/mongodb-compass.conf
COPY supervisord.conf     /etc/supervisor/compass.conf
COPY index.html           /usr/share/novnc/index.html
COPY entrypoint.sh        /usr/local/bin/entrypoint
COPY launch.sh            /usr/local/bin/launch
# Strip CRLF in case the scripts were edited on Windows.
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint /usr/local/bin/launch \
 && chmod 755 /usr/local/bin/entrypoint /usr/local/bin/launch

USER compass
WORKDIR /home/compass
EXPOSE 6080

HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://localhost:6080/vnc.html >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint"]
