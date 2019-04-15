FROM mcr.microsoft.com/dotnet/core/runtime:2.2-alpine3.9

LABEL maintainer="JJTC <docker@jjtc.eu>"

ENV ddler_full_ver=2.3.0-hotfix1 \
    ddler_ver=2.3.0 \
    WINEPREFIX=/home/steam/wine/ \
    WINEARCH=win64

COPY wine-4.0-r0.apk wine-libs-4.0-r0.apk ./

# Get and setup DepotDownloader
RUN mkdir /usr/share/ddler \
    && cd /usr/share/ddler \
    && wget https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_${ddler_ver}/depotdownloader-${ddler_full_ver}.zip \
    && unzip depotdownloader-${ddler_full_ver}.zip \
    && rm depotdownloader-${ddler_full_ver}.zip \
    && echo "#!/usr/bin/env sh" > /usr/bin/ddler \
    && echo "dotnet /usr/share/ddler/DepotDownloader.dll \"\$@\"" >> /usr/bin/ddler \
    && chmod +x /usr/bin/ddler \
    # Get Wine 4.0 and dependencies
    && apk update \
    && apk add --no-cache gnutls ncurses-libs xvfb \
    # Not available until this PR has been merged https://github.com/alpinelinux/aports/pull/6271/files
    # && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community wine \
    && cd / \
    && apk add --allow-untrusted wine-4.0-r0.apk wine-libs-4.0-r0.apk \
    && rm wine-4.0-r0.apk wine-libs-4.0-r0.apk \
    # Create steam group and user
    && addgroup -S steam \
    && adduser -D steam -G steam \
    # Create wineprefix folder and set owner
    && mkdir /home/steam/wine \
    && chown steam /home/steam/wine

# Switch to steam user
USER steam

WORKDIR /home/steam

ENTRYPOINT [ "echo", "Use https://steamdb.info/search/?a=app&q=server or https://developer.valvesoftware.com/wiki/Dedicated_Servers_List to find the appid.\n\n\
# Examples of installing an app:\n\
\n\
- Conan Exiles Dedicated Server for Windows\n\
    ddler -app 443030 -os windows -dir conanexiles/ -validate" ]

CMD [ "ddler", "$@" ]
