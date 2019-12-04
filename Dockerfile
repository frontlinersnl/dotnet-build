FROM mcr.microsoft.com/dotnet/core/sdk:3.1

# install base software
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    apt-transport-https \
    gnupg \
    wget \
    dpkg \ 
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
