---
"@tinyflow-ai/ui": patch
"@tinyflow-ai/react": patch
"@tinyflow-ai/vue": patch
"@tinyflow-ai/svelte": patch
---

🚀 添加完整的npm发布工作流

## 📦 新增发布系统

### GitHub Actions 工作流
- 🤖 **自动发布系统**: 集成GitHub Actions和Changesets
- 🔄 **版本管理**: 语义化版本控制和自动更新
- 📋 **构建测试**: 自动构建、测试和发布流程
- 🏷️ **GitHub Release**: 自动创建Release和变更日志

### 手动发布工具
- 🛠️ **发布脚本**: `scripts/publish.sh` - 智能版本检测和发布
- ⚙️ **环境设置**: `scripts/setup-publish.sh` - 一键配置发布环境
- 📊 **版本检查**: 自动比较本地和npm版本差异
- 🔐 **权限验证**: npm token和发布权限检查

### 发布文档
- 📚 **发布指南**: 详细的发布说明和最佳实践
- 🔧 **GitHub Actions设置**: 自动发布配置指南
- 🆘 **故障排除**: 常见问题解决方案
- 📋 **发布总结**: 完整的发布流程说明

## 🔧 技术改进

- **Monorepo支持**: 完整的多包发布管理
- **错误处理**: 完善的错误检测和恢复机制
- **日志记录**: 详细的发布过程日志
- **安全性**: NPM provenance和权限验证

## 🎯 使用方式

### 自动发布（推荐）
```bash
npx changeset                 # 创建changeset
git add . && git commit && git push  # 推送触发发布
```

### 手动发布
```bash
./scripts/setup-publish.sh   # 设置环境
./scripts/publish.sh         # 发布所有包
```

## 📈 发布流程优化

- **版本同步**: 确保所有包版本一致性
- **依赖管理**: 自动处理包间依赖关系
- **发布验证**: 发布前后的完整性检查
- **回滚支持**: 发布失败时的回滚机制
