#!/bin/bash
set -e

# Additional tools
sudo apt-get update && sudo apt-get install -y jq tree

# Chromium dependencies for claude login OAuth flow
npx --yes playwright install-deps chromium

# Claude Code CLI — install manually after container starts:
#   curl -fsSL https://claude.ai/install.sh | bash

# Project dependencies (skip if not yet created)
cd /workspaces/struts-to-springboot-migration
[ -f legacy-app/pom.xml ] && (cd legacy-app && mvn -q dependency:resolve) || true
[ -f migration-app/pom.xml ] && (cd migration-app && mvn -q dependency:resolve) || true
[ -f frontend-app/package.json ] && (cd frontend-app && npm install) || true
