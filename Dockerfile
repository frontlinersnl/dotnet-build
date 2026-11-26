ARG BASE_IMAGE=frontliners/dotnet-build:slim
FROM ${BASE_IMAGE}

# "install" the dotnet 10 runtime so we can also run the NET 10 tests
COPY --from=mcr.microsoft.com/dotnet/aspnet:10.0 /usr/share/dotnet/shared /usr/share/dotnet/shared

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  wget \
  #### Start install for node-gyp (native Node addon builds) ####
  g++ \
  make \
  python3 \
  #### End install for node-gyp (native Node addon builds) ####
  #### Start install for Cypress (headless browser testing GUI libs) ####
  libgtk-3-0t64 \
  libgbm-dev \
  libnotify-dev \
  libnss3 \
  libxss1 \
  libasound2t64 \
  libxtst6 \
  xauth \
  xvfb \
  #### End install for Cypress (headless browser testing GUI libs) ####
  #### Start install for headless browser E2E/unit testing ####
  chromium \
  firefox \
  #### End install for headless browser E2E/unit testing ####
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install docker-compose (for E2E testing in Bitbucket Pipelines)
RUN curl -fsSL "https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose
