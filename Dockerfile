FROM mcr.microsoft.com/dotnet/sdk:9.0

# "install" the dotnet 8 runtime so we can also run the NET 8 tests
COPY --from=mcr.microsoft.com/dotnet/sdk:8.0 /usr/share/dotnet/shared /usr/share/dotnet/shared

# install base software
RUN mkdir -p /usr/share/man/man1 \
  && mkdir -p /usr/share/man/man7 \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
  curl \
  apt-transport-https \
  gnupg \
  wget \
  dpkg \ 
  zip \
  make \
  ca-certificates \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get install -y --no-install-recommends nuget libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb procps\
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# install modern version of java
RUN apt-get update \
  && apt-get install --no-install-recommends -y openjdk-17-jdk openjdk-17-jre \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.35.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# install Chromium for (unit)-testing during build-phase
RUN apt-get update && \
  apt-get install -y --no-install-recommends chromium && \
  rm -rf /var/lib/apt/lists/*

# install Firefox for (unit)-testing during build-phase
RUN apt-get update && \
  apt-get install -y --no-install-recommends firefox-esr && \
  rm -rf /var/lib/apt/lists/*

# Set workdir alias
WORKDIR /api

# Fix .netcore paths if dotnet is installed
RUN mkdir -p ~/scripts
COPY scripts /scripts
RUN echo "source /scripts/dotnetcore.sh" >> ~/.bashrc

# add entrypoint and run
COPY dotnet-build.sh /dotnet-build.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /dotnet-build.sh
RUN chmod +x /entrypoint.sh
CMD ["/bin/bash","-i", "/entrypoint.sh"]
