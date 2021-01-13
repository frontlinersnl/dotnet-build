FROM mcr.microsoft.com/dotnet/sdk:5.0

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
    default-jre \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set workdir alias
WORKDIR /api

# Fix .netcore paths if dotnet is installed
RUN mkdir -p ~/scripts
COPY scripts /scripts
RUN echo "source /scripts/dotnetcore.sh" >> ~/.bashrc

# install reportgenerator for code coverage
RUN dotnet tool install -g dotnet-reportgenerator-globaltool

# add entrypoint and run
COPY dotnet-build.sh /dotnet-build.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /dotnet-build.sh
RUN chmod +x /entrypoint.sh
CMD ["/bin/bash","-i", "/entrypoint.sh"]
