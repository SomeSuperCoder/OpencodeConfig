# ============================================================================
# Containerfile — Reproducible opencode development environment
# Podman-compatible (no Docker-specific syntax)
# ============================================================================
# Build:  podman build -t opencode-dev -f Containerfile .
# Run:    podman run --rm -it -v ./workspace:/workspace opencode-dev
# ============================================================================

# ---- Base image -----------------------------------------------------------
# Fedora 44 required: opencode binary needs glibc 2.40+
FROM registry.fedoraproject.org/fedora:44

LABEL maintainer="SomeSuperCoder"
LABEL description="Reproducible opencode development environment"
LABEL version="1.0.0"

# ---- Pinned versions ------------------------------------------------------
# All versions pinned for reproducibility. Update this block when bumping.
ENV NODE_VERSION=22 \
    PNPM_VERSION=10.33.0 \
    RUST_VERSION=1.97.1 \
    NUSHELL_VERSION=0.99.1 \
    JUST_VERSION=1.55.1

# ---- System packages (single layer, cache cleaned) ------------------------
# git, curl, wget, jq, ripgrep, tree, tmux, bash, python3, gh, podman,
# util-linux (nsenter), file, which — plus build deps for Rust/Node
RUN dnf install -y --setopt=tsflags=nodocs \
        git curl wget jq ripgrep tree tmux bash python3 \
        gh podman util-linux file which \
        gcc gcc-c++ make \
        openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel \
        sqlite-devel xz-devel tk-devel \
        glibc-langpack-en \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---- Node.js 22 (via NodeSource) -----------------------------------------
RUN curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - \
    && dnf install -y nodejs \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---- pnpm via corepack (pinned version) -----------------------------------
RUN corepack enable \
    && corepack prepare pnpm@${PNPM_VERSION} --activate

# ---- Rust via rustup (pinned toolchain) -----------------------------------
# Installs to /root during build; ownership transferred to allen later.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain ${RUST_VERSION} \
    && /root/.cargo/bin/rustup component add clippy rustfmt

# ---- Nushell (via Fedora repos) -------------------------------------------
# NOTE: Version is not pinned — Fedora ships whatever version is in repos.
#       The NUSHELL_VERSION env var is retained for reference but not enforced.
#       If exact version pinning is needed, add a COPR repo or revert to cargo install.
RUN dnf install -y nushell && dnf clean all && rm -rf /var/cache/dnf

# ---- just (pinned, binary install) ----------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
    | bash -s -- --to /usr/local/bin --tag ${JUST_VERSION}

# ---- User setup -----------------------------------------------------------
# Create non-root user 'allen' with uid=1000
RUN useradd -m -u 1000 -s /usr/bin/bash allen \
    && mkdir -p \
        /home/allen/.config/opencode \
        /home/allen/.local/bin \
        /home/allen/.opencode/bin \
        /workspace \
    && chown -R allen:allen /home/allen /workspace \
    && git config --global user.email "opencode@container" \
    && git config --global user.name "OpenCode User"

# Fix Rust/cargo ownership (installed as root above)
RUN chown -R allen:allen /home/allen/.cargo /home/allen/.rustup 2>/dev/null || true

# ---- PATH (persistent env) ------------------------------------------------
ENV PATH="/home/allen/.local/share/pnpm/bin:/home/allen/.cargo/bin:/home/allen/.local/bin:/home/allen/.opencode/bin:/usr/local/bin:/usr/bin"
ENV HOME="/home/allen"

# ---- pnpm global packages (as allen) --------------------------------------
USER allen
ENV PNPM_HOME="/home/allen/.local/share/pnpm"
RUN export PATH="$PNPM_HOME:$PATH" \
    && pnpm add -g \
        opencode-ai \
        @colbymchenry/codegraph@1.5.0 \
        @agentmemory/agentmemory@0.9.28 \
        @fission-ai/openspec@1.7.0

# ---- Copy opencode config into image (baked at build time) ------------------
# Config is OWNED by the container — not mounted from host.
# This ensures clear separation: host config and container config are independent.
# To update container config, rebuild the image.
COPY --chown=allen:allen agents/ /home/allen/.config/opencode/agents/
COPY --chown=allen:allen skills/ /home/allen/.config/opencode/skills/
COPY --chown=allen:allen AGENTS.md /home/allen/.config/opencode/AGENTS.md
COPY --chown=allen:allen opencode.jsonc /home/allen/.config/opencode/opencode.jsonc
COPY --chown=allen:allen package.json /home/allen/.config/opencode/package.json

# ---- First-run setup script ------------------------------------------------
# Runs opencode postinstall + pnpm install on first container start
COPY --chown=allen:allen scripts/first-run.sh /usr/local/bin/first-run
RUN chmod +x /usr/local/bin/first-run

# ---- Global commands -------------------------------------------------------
COPY --chown=allen:allen scripts/create-project /usr/local/bin/create-project
RUN chmod +x /usr/local/bin/create-project

# ---- Working directory -----------------------------------------------------
WORKDIR /workspace

# ---- Health check ----------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s \
    CMD opencode --version || exit 1

# ---- Default command -------------------------------------------------------
CMD ["/usr/local/bin/first-run"]
