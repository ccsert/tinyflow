# 🔧 故障排除指南

本文档提供了TinyFlow npm发布过程中常见问题的解决方案。

## 🚨 GitHub Actions 构建失败

### 问题1: 锁定文件同步错误

**错误信息**:
```
ERR_PNPM_OUTDATED_LOCKFILE Cannot install with "frozen-lockfile" because pnpm-lock.yaml is not up to date with packages/ui/package.json
```

**原因**: `pnpm-lock.yaml` 文件与 `package.json` 文件不同步

**解决方案**:

1. **本地修复**:
   ```bash
   # 更新锁定文件
   pnpm install
   
   # 提交更新的锁定文件
   git add pnpm-lock.yaml
   git commit -m "fix: update pnpm-lock.yaml to sync with package.json"
   git push
   ```

2. **GitHub Actions 自动处理**:
   更新工作流文件中的依赖安装步骤：
   ```yaml
   - name: Install Dependencies
     run: |
       # 尝试使用frozen-lockfile，如果失败则更新锁定文件
       if ! pnpm install --frozen-lockfile; then
         echo "⚠️ Lockfile is outdated, updating dependencies..."
         pnpm install
         echo "📝 Lockfile has been updated"
       fi
   ```

### 问题2: Node.js 版本不兼容

**错误信息**:
```
The engine "node" is incompatible with this module
```

**解决方案**:
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: 20  # 确保使用Node.js 20+
```

### 问题3: pnpm 版本问题

**解决方案**:
```yaml
- name: Install pnpm
  uses: pnpm/action-setup@v2
  with:
    version: 8  # 使用pnpm 8.x
```

## 🔑 NPM 认证问题

### 问题1: NPM_TOKEN 未设置

**错误信息**:
```
npm ERR! code E401
npm ERR! 401 Unauthorized
```

**解决方案**:

1. **生成 NPM Token**:
   ```bash
   npm login
   npm token create --read-and-publish
   ```

2. **在 GitHub 设置 Secret**:
   - 进入仓库设置: `Settings` → `Secrets and variables` → `Actions`
   - 点击 `New repository secret`
   - Name: `NPM_TOKEN`
   - Value: 粘贴生成的token

### 问题2: NPM Token 过期

**解决方案**:
```bash
# 检查token状态
npm token list

# 删除过期token
npm token revoke <token-id>

# 创建新token
npm token create --read-and-publish
```

### 问题3: 包发布权限不足

**错误信息**:
```
npm ERR! code E403
npm ERR! 403 Forbidden
```

**解决方案**:

1. **检查包所有者**:
   ```bash
   npm owner ls @tinyflow-ai/ui
   ```

2. **添加发布权限**:
   ```bash
   npm owner add <username> @tinyflow-ai/ui
   ```

3. **检查组织权限**:
   - 确保在 `@tinyflow-ai` 组织中有发布权限

## 📦 包版本问题

### 问题1: 版本已存在

**错误信息**:
```
npm ERR! code E409
npm ERR! 409 Conflict - PUT https://registry.npmjs.org/@tinyflow-ai/ui - cannot modify pre-existing version
```

**解决方案**:

1. **更新版本号**:
   ```bash
   # 使用changeset更新版本
   npx changeset
   npx changeset version
   
   # 或手动更新package.json中的版本号
   npm version patch  # 或 minor, major
   ```

2. **检查当前版本**:
   ```bash
   npm show @tinyflow-ai/ui version
   ```

### 问题2: 版本不一致

**解决方案**:
```bash
# 检查所有包的版本
npm show @tinyflow-ai/ui version
npm show @tinyflow-ai/react version
npm show @tinyflow-ai/vue version
npm show @tinyflow-ai/svelte version

# 使用changeset同步版本
npx changeset version
```

## 🏗️ 构建问题

### 问题1: TypeScript 编译错误

**解决方案**:
```bash
# 检查TypeScript配置
npx tsc --noEmit

# 修复类型错误
# 更新tsconfig.json配置
```

### 问题2: Svelte 编译错误

**解决方案**:
```bash
# 检查Svelte配置
npx svelte-check

# 更新Svelte版本
pnpm update svelte
```

### 问题3: 依赖冲突

**解决方案**:
```bash
# 清理依赖
rm -rf node_modules
rm pnpm-lock.yaml

# 重新安装
pnpm install

# 解决peer dependency警告
pnpm install --fix-peer-deps
```

## 🔄 Changesets 问题

### 问题1: 没有changeset文件

**错误信息**:
```
No changesets found
```

**解决方案**:
```bash
# 创建changeset
npx changeset

# 检查changeset状态
npx changeset status
```

### 问题2: Changeset 配置错误

**解决方案**:
检查 `.changeset/config.json`:
```json
{
  "changelog": [
    "@changesets/changelog-github",
    {
      "repo": "ccsert/tinyflow"
    }
  ],
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": []
}
```

## 🛠️ 本地开发问题

### 问题1: 脚本权限错误

**错误信息**:
```
Permission denied: ./scripts/publish.sh
```

**解决方案**:
```bash
chmod +x scripts/*.sh
```

### 问题2: npm 登录状态

**检查登录状态**:
```bash
npm whoami
```

**重新登录**:
```bash
npm logout
npm login
```

### 问题3: Registry 配置错误

**检查registry**:
```bash
npm config get registry
```

**设置正确的registry**:
```bash
npm config set registry https://registry.npmjs.org/
```

## 🔍 调试命令

### 检查包状态
```bash
# 检查包版本
npm show @tinyflow-ai/ui version
npm show @tinyflow-ai/react version
npm show @tinyflow-ai/vue version
npm show @tinyflow-ai/svelte version

# 检查包信息
npm show @tinyflow-ai/ui

# 检查包文件
npm pack --dry-run
```

### 检查构建状态
```bash
# 构建所有包
pnpm run build

# 检查构建输出
ls -la packages/*/dist/

# 验证类型定义
npx tsc --noEmit
```

### 检查发布状态
```bash
# 检查changeset状态
npx changeset status

# 预览发布
npx changeset publish --dry-run

# 检查npm配置
npm config list
```

## 📞 获取帮助

如果以上解决方案都无法解决您的问题，请：

1. **检查日志**: 查看完整的错误日志
2. **搜索文档**: 查看相关工具的官方文档
3. **社区支持**: 在相关项目的GitHub Issues中搜索类似问题

### 有用的链接

- [pnpm 文档](https://pnpm.io/)
- [Changesets 文档](https://github.com/changesets/changesets)
- [npm 文档](https://docs.npmjs.com/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

---

**💡 提示**: 大多数问题都可以通过仔细阅读错误信息和检查配置文件来解决。保持耐心，逐步排查问题！
