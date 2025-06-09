# GitHub Actions 发布工作流设置指南

由于权限限制，无法直接推送 GitHub Actions 工作流文件。请按照以下步骤手动设置：

## 🔧 必需的 GitHub Actions 文件

### 1. 更新 `.github/workflows/release.yml`

将以下内容替换到现有的 `release.yml` 文件中：

```yaml
name: Release and Publish to NPM

on:
  push:
    branches:
      - main
    paths:
      - ".changeset/*.md"
      - "packages/*/package.json"
      - "packages/*/src/**"
  pull_request:
    types: [closed]
    branches:
      - main
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release type'
        required: true
        default: 'patch'
        type: choice
        options:
        - patch
        - minor
        - major

permissions:
  id-token: write
  contents: write
  pull-requests: write
  packages: write

jobs:
  # 构建和测试作业
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: https://registry.npmjs.org/

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install Dependencies
        run: pnpm install --frozen-lockfile

      - name: Build packages
        run: pnpm run build

      - name: Run tests
        run: pnpm run test --if-present

  # 发布作业
  release:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.pull_request.merged == true) || github.event_name == 'workflow_dispatch'
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: https://registry.npmjs.org/

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install Dependencies
        run: pnpm install --frozen-lockfile

      - name: Build packages
        run: pnpm run build

      # 检查是否有changeset文件
      - name: Check for changesets
        id: check-changesets
        run: |
          if [ -n "$(ls .changeset/*.md 2>/dev/null | grep -v README.md)" ]; then
            echo "has_changesets=true" >> $GITHUB_OUTPUT
          else
            echo "has_changesets=false" >> $GITHUB_OUTPUT
          fi

      # 使用 Changesets Action 自动化发布
      - name: Create Release PR or publish to npm
        id: changesets
        if: steps.check-changesets.outputs.has_changesets == 'true'
        uses: changesets/action@v1
        with:
          createGithubReleases: true
          publish: pnpm changeset publish
          version: pnpm changeset version
          title: "chore: release packages"
          commit: "chore: release packages"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
          NPM_CONFIG_PROVENANCE: true

      # 手动触发发布（当workflow_dispatch时）
      - name: Manual release
        if: github.event_name == 'workflow_dispatch' && steps.check-changesets.outputs.has_changesets == 'false'
        run: |
          echo "Creating manual changeset for ${{ github.event.inputs.release_type }} release"
          pnpm changeset add --empty
          pnpm changeset version
          pnpm changeset publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
          NPM_CONFIG_PROVENANCE: true

      # 打印发布信息
      - name: Print release information
        if: steps.changesets.outputs.published == 'true' || github.event_name == 'workflow_dispatch'
        run: |
          echo "🎉 Packages published successfully!"
          echo "Published packages:"
          if [ -f ".changeset/published-packages.json" ]; then
            cat .changeset/published-packages.json
          fi
          
          echo ""
          echo "📦 Package versions on NPM:"
          echo "UI: $(npm show @tinyflow-ai/ui version 2>/dev/null || echo 'Not found')"
          echo "React: $(npm show @tinyflow-ai/react version 2>/dev/null || echo 'Not found')"
          echo "Vue: $(npm show @tinyflow-ai/vue version 2>/dev/null || echo 'Not found')"
          echo "Svelte: $(npm show @tinyflow-ai/svelte version 2>/dev/null || echo 'Not found')"

      # 发布失败时的处理
      - name: Handle publish failure
        if: failure()
        run: |
          echo "❌ Publishing failed. Please check the logs above."
          echo "Common issues:"
          echo "1. NPM_TOKEN secret not set or expired"
          echo "2. Package version already exists"
          echo "3. Build or test failures"
          echo "4. Network connectivity issues"
```

## 🔑 设置 NPM Token

1. **生成 NPM Token**：
   ```bash
   npm login
   npm token create --read-and-publish
   ```

2. **在 GitHub 中设置 Secret**：
   - 进入仓库设置：`Settings` → `Secrets and variables` → `Actions`
   - 点击 `New repository secret`
   - Name: `NPM_TOKEN`
   - Value: 粘贴生成的 token

## 🚀 发布流程

### 自动发布（推荐）

1. **创建 changeset**：
   ```bash
   npx changeset
   ```

2. **提交并推送**：
   ```bash
   git add .changeset/
   git commit -m "chore: add changeset for new features"
   git push
   ```

3. **自动发布**：GitHub Action 将自动处理发布

### 手动发布

使用提供的脚本：
```bash
# 设置发布环境
./scripts/setup-publish.sh

# 发布所有包
./scripts/publish.sh

# 发布特定包
./scripts/publish.sh ui
```

## 📋 验证设置

1. **检查 changeset 配置**：
   ```bash
   npx changeset status
   ```

2. **验证构建**：
   ```bash
   pnpm install
   pnpm run build
   ```

3. **测试发布脚本**：
   ```bash
   ./scripts/setup-publish.sh
   ```

## 🔍 故障排除

### 常见问题

1. **NPM_TOKEN 未设置**：
   - 确保在 GitHub 仓库设置中添加了 `NPM_TOKEN` secret
   - Token 需要有 `read-and-publish` 权限

2. **版本冲突**：
   - 检查本地版本是否已更新
   - 确保 changeset 文件存在

3. **权限问题**：
   - 确保有 npm 包的发布权限
   - 检查 npm 登录状态：`npm whoami`

### 调试命令

```bash
# 检查包版本
npm show @tinyflow-ai/ui version
npm show @tinyflow-ai/react version
npm show @tinyflow-ai/vue version
npm show @tinyflow-ai/svelte version

# 检查 changeset 状态
npx changeset status

# 手动发布测试
npx changeset publish --dry-run
```

## 📚 相关文档

- [发布指南](docs/PUBLISHING.md)
- [Changesets 文档](https://github.com/changesets/changesets)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
