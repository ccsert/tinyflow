#!/bin/bash

# 发布环境设置脚本
# 用于配置npm发布所需的环境和权限

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  TinyFlow NPM 发布环境设置"
    echo "=================================================="
    echo -e "${NC}"
}

print_header

# 1. 检查Node.js和npm版本
print_info "检查Node.js和npm版本..."
node_version=$(node --version)
npm_version=$(npm --version)
echo "  Node.js: $node_version"
echo "  npm: $npm_version"

if ! command -v pnpm &> /dev/null; then
    print_warning "pnpm未安装，正在安装..."
    npm install -g pnpm
fi

pnpm_version=$(pnpm --version)
echo "  pnpm: $pnpm_version"
print_success "环境版本检查完成"

# 2. 检查npm登录状态
print_info "检查npm登录状态..."
if npm whoami > /dev/null 2>&1; then
    current_user=$(npm whoami)
    print_success "已登录npm，用户: $current_user"
else
    print_warning "未登录npm"
    read -p "是否现在登录npm? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm login
        if npm whoami > /dev/null 2>&1; then
            current_user=$(npm whoami)
            print_success "npm登录成功，用户: $current_user"
        else
            print_error "npm登录失败"
            exit 1
        fi
    else
        print_warning "跳过npm登录，稍后可使用 'npm login' 命令登录"
    fi
fi

# 3. 检查npm registry
print_info "检查npm registry配置..."
current_registry=$(npm config get registry)
echo "  当前registry: $current_registry"

if [ "$current_registry" != "https://registry.npmjs.org/" ]; then
    print_warning "registry不是官方npm registry"
    read -p "是否设置为官方registry? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm config set registry https://registry.npmjs.org/
        print_success "registry已设置为官方npm registry"
    fi
fi

# 4. 检查包权限
print_info "检查包发布权限..."
packages=("@tinyflow-ai/ui" "@tinyflow-ai/react" "@tinyflow-ai/vue" "@tinyflow-ai/svelte")

for package in "${packages[@]}"; do
    if npm show "$package" > /dev/null 2>&1; then
        echo "  $package: 已存在"
        # 检查是否有发布权限
        if npm access list packages 2>/dev/null | grep -q "$package"; then
            echo "    ✅ 有发布权限"
        else
            echo "    ⚠️  可能没有发布权限"
        fi
    else
        echo "  $package: 未发布（首次发布）"
    fi
done

# 5. 检查GitHub Token（如果需要）
print_info "检查GitHub环境..."
if [ -n "$GITHUB_TOKEN" ]; then
    print_success "GITHUB_TOKEN环境变量已设置"
else
    print_warning "GITHUB_TOKEN环境变量未设置（自动发布需要）"
fi

# 6. 验证项目结构
print_info "验证项目结构..."
required_files=(
    "package.json"
    "packages/ui/package.json"
    "packages/react/package.json"
    "packages/vue/package.json"
    "packages/svelte/package.json"
    ".changeset/config.json"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (缺失)"
    fi
done

# 7. 检查包配置
print_info "检查包发布配置..."
for pkg_dir in packages/*/; do
    if [ -f "$pkg_dir/package.json" ]; then
        pkg_name=$(basename "$pkg_dir")
        
        # 检查name字段
        if node -p "require('./$pkg_dir/package.json').name" | grep -q "@tinyflow-ai"; then
            echo "  ✅ $pkg_name: name字段正确"
        else
            echo "  ⚠️  $pkg_name: name字段可能不正确"
        fi
        
        # 检查publishConfig
        if node -p "require('./$pkg_dir/package.json').publishConfig" > /dev/null 2>&1; then
            echo "  ✅ $pkg_name: 有publishConfig配置"
        else
            echo "  ⚠️  $pkg_name: 缺少publishConfig配置"
        fi
        
        # 检查files字段
        if node -p "require('./$pkg_dir/package.json').files" > /dev/null 2>&1; then
            echo "  ✅ $pkg_name: 有files字段"
        else
            echo "  ⚠️  $pkg_name: 缺少files字段"
        fi
    fi
done

# 8. 生成npm token（如果需要）
print_info "NPM Token配置..."
if npm whoami > /dev/null 2>&1; then
    read -p "是否需要生成新的npm token用于CI/CD? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "生成npm token..."
        echo "请运行以下命令生成token:"
        echo "  npm token create --read-and-publish"
        echo ""
        echo "然后在GitHub仓库设置中添加NPM_TOKEN secret:"
        echo "  1. 进入 GitHub 仓库"
        echo "  2. Settings → Secrets and variables → Actions"
        echo "  3. 点击 'New repository secret'"
        echo "  4. Name: NPM_TOKEN"
        echo "  5. Value: 粘贴生成的token"
    fi
fi

# 9. 测试构建
print_info "测试项目构建..."
if pnpm install --frozen-lockfile; then
    print_success "依赖安装成功"
else
    print_error "依赖安装失败"
    exit 1
fi

if pnpm run build; then
    print_success "项目构建成功"
else
    print_error "项目构建失败"
    exit 1
fi

# 10. 总结
echo ""
print_success "发布环境设置完成！"
echo ""
print_info "下一步操作："
echo "  1. 确保所有包配置正确"
echo "  2. 创建changeset: npx changeset"
echo "  3. 提交代码并推送到main分支"
echo "  4. GitHub Action将自动处理发布"
echo ""
print_info "手动发布命令："
echo "  ./scripts/publish.sh          # 发布所有包"
echo "  ./scripts/publish.sh ui       # 发布UI包"
echo ""
print_info "有用的命令："
echo "  npm whoami                    # 检查登录状态"
echo "  npx changeset status          # 检查changeset状态"
echo "  pnpm run build               # 构建项目"
echo "  npm show @tinyflow-ai/ui      # 查看包信息"
echo ""
print_info "文档："
echo "  docs/PUBLISHING.md            # 详细发布指南"
