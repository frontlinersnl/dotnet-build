FROM mcr.microsoft.com/dotnet/sdk:7.0.102-bullseye-slim-amd64

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
  ca-certificates \
  default-jre \
  && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get install -y --no-install-recommends libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb procps\
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# install Chromium for (unit)-testing during build-phase
RUN apt-get update && \
  apt-get install -y --no-install-recommends libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb && \
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

# install reportgenerator for code coverage
RUN dotnet tool install -g dotnet-reportgenerator-globaltool
RUN dotnet tool install -g dotnet-sonarscanner
RUN dotnet tool install -g dotnet-format
RUN dotnet tool install -g dotnet-coverage

# add entrypoint and run
COPY dotnet-build.sh /dotnet-build.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /dotnet-build.sh
RUN chmod +x /entrypoint.sh
CMD ["/bin/bash","-i", "/entrypoint.sh"]
