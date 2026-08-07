# ============================================================================
# Containerfile — Reproducible opencode development environment
# Podman-compatible (no Docker-specific syntax)
#
# Layer cache order: least-changing → most-changing
#   1. Base image + system packages (rarely changes)
#   2. Runtimes: Node, pnpm, Rust, Nushell, just (rarely changes)
#   3. User setup (rarely changes)
#   4. pnpm globals (changes on version bumps)
#   5. Config files (changes on config edits)
#   6. Scripts (changes most often)
#
# Build:  podman build -t opencode-dev -f Containerfile .
# Run:    ./scripts/launcher.sh
# ============================================================================

# ---- Base image (NEVER changes) -------------------------------------------
# Fedora 44 required: opencode binary needs glibc 2.40+
FROM registry.fedoraproject.org/fedora:44

LABEL maintainer="SomeSuperCoder" \
      description="Reproducible opencode development environment" \
      version="1.0.0"

# ---- Pinned versions (changes only on version bumps) ----------------------
ENV NODE_VERSION=22 \
    PNPM_VERSION=10.33.0 \
    RUST_VERSION=1.97.1 \
    JUST_VERSION=1.55.1

# ---- System packages (changes rarely) -------------------------------------
RUN dnf install -y --setopt=tsflags=nodocs \
        git curl wget jq ripgrep tree tmux bash python3 \
        gh podman util-linux file which xclip \
        gcc gcc-c++ make \
        openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel \
        sqlite-devel xz-devel tk-devel \
        glibc-langpack-en nushell \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---- Runtimes (changes rarely) --------------------------------------------
# Node.js 22
RUN curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - \
    && dnf install -y nodejs \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# pnpm via corepack
RUN corepack enable \
    && corepack prepare pnpm@${PNPM_VERSION} --activate

# Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain ${RUST_VERSION} \
    && /root/.cargo/bin/rustup component add clippy rustfmt

# just
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
    | bash -s -- --to /usr/local/bin --tag ${JUST_VERSION}

# ---- User setup (changes rarely) ------------------------------------------
# Create non-root user, directories, fix ownership, set git identity
RUN useradd -m -u 1000 -s /usr/bin/bash allen \
    && mkdir -p \
        /home/allen/.config/opencode \
        /home/allen/.local/bin \
        /home/allen/.opencode/bin \
        /workspace \
    && chown -R allen:allen /home/allen /workspace \
    && chown -R allen:allen /home/allen/.cargo /home/allen/.rustup 2>/dev/null || true

# Persistent env
ENV PATH="/home/allen/.local/share/pnpm/bin:/home/allen/.cargo/bin:/home/allen/.local/bin:/home/allen/.opencode/bin:/usr/local/bin:/usr/bin" \
    HOME="/home/allen" \
    PNPM_HOME="/home/allen/.local/share/pnpm"

USER allen

# Git identity (inside user layer — rarely changes)
RUN git config --global user.email "opencode@container" \
    && git config --global user.name "OpenCode User"

# ---- pnpm globals (changes on version bumps) ------------------------------
# Configure pnpm to run build scripts (postinstall) automatically
RUN export PATH="$PNPM_HOME:$PATH" \
    && pnpm config set onlyBuiltDependenciesFile "" \
    && pnpm add -g \
        opencode-ai \
        @colbymchenry/codegraph@1.5.0 \
        @agentmemory/agentmemory@0.9.28 \
        @fission-ai/openspec@1.7.0

# ---- Config files (changes on config edits) -------------------------------
# Baked into image — host config is NOT mounted.
# To update container config, rebuild the image.
COPY --chown=allen:allen agents /home/allen/.config/opencode/agents
COPY --chown=allen:allen skills /home/allen/.config/opencode/skills
COPY --chown=allen:allen AGENTS.md /home/allen/.config/opencode/AGENTS.md
COPY --chown=allen:allen opencode.jsonc /home/allen/.config/opencode/opencode.jsonc
COPY --chown=allen:allen opencode.json /home/allen/.config/opencode/opencode.json
COPY --chown=allen:allen package.json /home/allen/.config/opencode/package.json
COPY --chown=allen:allen package-lock.json /home/allen/.config/opencode/package-lock.json

# ---- Scripts (changes most often) -----------------------------------------
USER root
COPY --chown=allen:allen scripts/ /tmp/scripts/
RUN mkdir -p /usr/local/bin \
    && mv /tmp/scripts/first-run.sh /usr/local/bin/first-run \
    && mv /tmp/scripts/create-project /usr/local/bin/create-project \
    && chmod +x /usr/local/bin/first-run /usr/local/bin/create-project \
    && rm -rf /tmp/scripts
USER allen

# ---- Working directory -----------------------------------------------------
WORKDIR /workspace

# ---- Health check ----------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s \
    CMD opencode --version || exit 1

# ---- Default command -------------------------------------------------------
CMD ["/usr/local/bin/first-run"]
