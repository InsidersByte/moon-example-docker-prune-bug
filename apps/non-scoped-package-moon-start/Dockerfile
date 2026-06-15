#### BASE STAGE
#### Installs moon.

FROM node:24.16.0 AS base
WORKDIR /app

# Install moon binary
RUN curl -fsSL https://moonrepo.dev/install/moon.sh | bash
ENV PATH="/root/.moon/bin:/root/.proto/bin:$PATH"

#### SKELETON STAGE
#### Scaffolds repository skeleton structures.

FROM base AS skeleton

# Copy entire repository and scaffold
COPY . .
RUN moon docker scaffold non-scoped-package-moon-start

#### BUILD STAGE
#### Builds the project.

FROM base AS build

# Copy workspace configs
COPY --from=skeleton /app/.moon/docker/configs .

# Install toolchains and dependencies
RUN moon docker setup

# Copy project sources
COPY --from=skeleton /app/.moon/docker/sources .

# Prune extraneous dependencies
RUN moon docker prune
RUN echo "=== post-prune node_modules ===" && if [ -d apps/non-scoped-package-moon-start/node_modules ]; then ls -alR apps/non-scoped-package-moon-start/node_modules; else echo "no node_modules found"; fi

#### START STAGE
#### Runs the project.

FROM base AS start

# Copy built sources
COPY --from=build /root/.proto /root/.proto
COPY --from=build /app /app

# CMD moon run non-scoped-package-moon-start:start
CMD sh -lc 'echo "=== runtime node_modules ===" && if [ -d apps/non-scoped-package-moon-start/node_modules ]; then ls -alR apps/non-scoped-package-moon-start/node_modules; else echo "no node_modules found"; fi && moon run non-scoped-package-moon-start:start'
