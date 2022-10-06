FROM mcr.microsoft.com/dotnet/sdk:6.0.401-bullseye-slim-amd64

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
  docker-compose \
  && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get install -y --no-install-recommends libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb procps\
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set workdir alias
WORKDIR /api

# Fix .netcore paths if dotnet is installed
RUN mkdir -p ~/scripts
COPY scripts /scripts
RUN echo "source /scripts/dotnetcore.sh" >> ~/.bashrc

# install reportgenerator for code coverage
RUN dotnet tool install -g dotnet-reportgenerator-globaltool
RUN dotnet tool install -g dotnet-sonarscanner

# add entrypoint and run
COPY dotnet-build.sh /dotnet-build.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /dotnet-build.sh
RUN chmod +x /entrypoint.sh
CMD ["/bin/bash","-i", "/entrypoint.sh"]
