# ============================================================================
# Containerfile — Reproducible opencode development environment
# Podman-compatible (no Docker-specific syntax)
#
# Layer cache order: least-changing → most-changing
#   1. Base image + system packages (rarely changes)
#   2. Runtimes: Node, pnpm, Rust, Nushell, Julia, just (rarely changes)
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
        glibc-langpack-en nushell julia \
        fd-find bat eza git-delta hyperfine tokei pre-commit \
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
# Generic user — works for ANY host user via --userns keep-id in Podman
ARG USERNAME=dev
ARG USER_UID=1000

# Create non-root user, directories, fix ownership, set git identity
RUN useradd -m -u ${USER_UID} -s /usr/bin/bash ${USERNAME} \
    && mkdir -p \
        /home/${USERNAME}/.config/opencode \
        /home/${USERNAME}/.local/bin \
        /home/${USERNAME}/.opencode/bin \
        /home/${USERNAME}/.agentmemory \
        /workspace \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspace \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.cargo /home/${USERNAME}/.rustup 2>/dev/null || true

# Persistent env
ENV PATH="/home/${USERNAME}/.local/share/pnpm/bin:/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/.local/bin:/home/${USERNAME}/.opencode/bin:/usr/local/bin:/usr/bin" \
    HOME="/home/${USERNAME}" \
    PNPM_HOME="/home/${USERNAME}/.local/share/pnpm"

USER ${USERNAME}

# Git identity (inside user layer — rarely changes)
RUN git config --global user.email "opencode@container" \
    && git config --global user.name "OpenCode User"

# ---- pnpm globals (changes on version bumps) ------------------------------
# --allow-build lets postinstall scripts run (pnpm v10+ blocks them by default)
RUN export PATH="$PNPM_HOME:$PATH" \
    && pnpm add -g \
        opencode-ai \
        @colbymchenry/codegraph@1.5.0 \
        @agentmemory/agentmemory@0.9.28 \
        @agentmemory/mcp@0.9.28 \
        @fission-ai/openspec@1.7.0 \
        @ast-grep/cli \
        --allow-build=opencode-ai

# ---- Config files (changes on config edits) -------------------------------
# Baked into image — host config is NOT mounted.
# To update container config, rebuild the image.
COPY --chown=${USERNAME}:${USERNAME} agents /home/${USERNAME}/.config/opencode/agents
COPY --chown=${USERNAME}:${USERNAME} skills /home/${USERNAME}/.config/opencode/skills
COPY --chown=${USERNAME}:${USERNAME} AGENTS.md /home/${USERNAME}/.config/opencode/AGENTS.md
COPY --chown=${USERNAME}:${USERNAME} opencode.jsonc /home/${USERNAME}/.config/opencode/opencode.jsonc
COPY --chown=${USERNAME}:${USERNAME} opencode.json /home/${USERNAME}/.config/opencode/opencode.json
COPY --chown=${USERNAME}:${USERNAME} package.json /home/${USERNAME}/.config/opencode/package.json
COPY --chown=${USERNAME}:${USERNAME} package-lock.json /home/${USERNAME}/.config/opencode/package-lock.json

# ---- Scripts (changes most often) -----------------------------------------
USER root
COPY --chown=${USERNAME}:${USERNAME} scripts/ /tmp/scripts/
RUN mkdir -p /usr/local/bin \
    && mv /tmp/scripts/first-run.sh /usr/local/bin/first-run \
    && mv /tmp/scripts/create-project /usr/local/bin/create-project \
    && mv /tmp/scripts/setup-project /usr/local/bin/setup-project \
    && chmod +x /usr/local/bin/first-run /usr/local/bin/create-project /usr/local/bin/setup-project \
    && rm -rf /tmp/scripts
USER ${USERNAME}

# ---- Working directory -----------------------------------------------------
WORKDIR /workspace

# ---- Health check ----------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s \
    CMD opencode --version || exit 1

# ---- Default command -------------------------------------------------------
CMD ["/usr/local/bin/first-run"]
