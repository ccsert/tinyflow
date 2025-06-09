#!/bin/bash

# 发布脚本 - 用于手动发布包到npm
# 使用方法: ./scripts/publish.sh [package-name] [version-type]
# 示例: ./scripts/publish.sh ui patch

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 检查是否在项目根目录
if [ ! -f "package.json" ] || [ ! -d "packages" ]; then
    print_error "请在项目根目录运行此脚本"
    exit 1
fi

# 检查npm登录状态
print_info "检查npm登录状态..."
if ! npm whoami > /dev/null 2>&1; then
    print_error "请先登录npm: npm login"
    exit 1
fi

print_success "npm登录状态正常: $(npm whoami)"

# 安装依赖
print_info "安装依赖..."
pnpm install --frozen-lockfile

# 构建项目
print_info "构建项目..."
pnpm run build

# 运行测试
print_info "运行测试..."
if ! pnpm run test --if-present; then
    print_warning "测试失败，但继续发布流程"
fi

# 获取参数
PACKAGE_NAME=${1:-"all"}
VERSION_TYPE=${2:-"patch"}

print_info "发布配置:"
echo "  包名: $PACKAGE_NAME"
echo "  版本类型: $VERSION_TYPE"

# 定义包列表
declare -A PACKAGES
PACKAGES["ui"]="packages/ui"
PACKAGES["react"]="packages/react"
PACKAGES["vue"]="packages/vue"
PACKAGES["svelte"]="packages/svelte"

# 检查包版本函数
check_package_version() {
    local pkg_name=$1
    local pkg_path=$2
    
    if [ ! -f "$pkg_path/package.json" ]; then
        print_error "包路径不存在: $pkg_path"
        return 1
    fi
    
    local local_version=$(node -p "require('./$pkg_path/package.json').version")
    local npm_version=$(npm show "@tinyflow-ai/$pkg_name" version 2>/dev/null || echo "0.0.0")
    
    echo "  $pkg_name: $local_version (本地) vs $npm_version (npm)"
    
    if [ "$local_version" = "$npm_version" ]; then
        return 1  # 版本相同，不需要发布
    fi
    
    return 0  # 版本不同，需要发布
}

# 发布单个包函数
publish_package() {
    local pkg_name=$1
    local pkg_path=$2
    
    print_info "发布 @tinyflow-ai/$pkg_name..."
    
    cd "$pkg_path"
    
    # 检查package.json中的发布配置
    if ! node -p "require('./package.json').publishConfig" > /dev/null 2>&1; then
        print_warning "包 $pkg_name 没有publishConfig配置"
    fi
    
    # 发布包
    if npm publish --access public --provenance; then
        print_success "成功发布 @tinyflow-ai/$pkg_name"
        cd - > /dev/null
        return 0
    else
        print_error "发布 @tinyflow-ai/$pkg_name 失败"
        cd - > /dev/null
        return 1
    fi
}

# 主发布逻辑
if [ "$PACKAGE_NAME" = "all" ]; then
    print_info "检查所有包的版本..."
    
    # 检查哪些包需要发布
    declare -a PACKAGES_TO_PUBLISH
    
    for pkg_name in "${!PACKAGES[@]}"; do
        pkg_path="${PACKAGES[$pkg_name]}"
        if check_package_version "$pkg_name" "$pkg_path"; then
            PACKAGES_TO_PUBLISH+=("$pkg_name")
        fi
    done
    
    if [ ${#PACKAGES_TO_PUBLISH[@]} -eq 0 ]; then
        print_warning "所有包的版本都是最新的，无需发布"
        exit 0
    fi
    
    print_info "需要发布的包: ${PACKAGES_TO_PUBLISH[*]}"
    
    # 确认发布
    read -p "确认发布这些包? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "取消发布"
        exit 0
    fi
    
    # 发布所有需要更新的包
    FAILED_PACKAGES=()
    for pkg_name in "${PACKAGES_TO_PUBLISH[@]}"; do
        pkg_path="${PACKAGES[$pkg_name]}"
        if ! publish_package "$pkg_name" "$pkg_path"; then
            FAILED_PACKAGES+=("$pkg_name")
        fi
    done
    
    # 发布结果总结
    if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
        print_success "所有包发布成功!"
        print_info "发布的包: ${PACKAGES_TO_PUBLISH[*]}"
    else
        print_error "部分包发布失败: ${FAILED_PACKAGES[*]}"
        exit 1
    fi
    
else
    # 发布单个包
    if [ -z "${PACKAGES[$PACKAGE_NAME]}" ]; then
        print_error "未知的包名: $PACKAGE_NAME"
        print_info "可用的包: ${!PACKAGES[*]}"
        exit 1
    fi
    
    pkg_path="${PACKAGES[$PACKAGE_NAME]}"
    
    print_info "检查包版本..."
    if ! check_package_version "$PACKAGE_NAME" "$pkg_path"; then
        print_warning "包 $PACKAGE_NAME 的版本已是最新，无需发布"
        exit 0
    fi
    
    # 确认发布
    read -p "确认发布 @tinyflow-ai/$PACKAGE_NAME? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "取消发布"
        exit 0
    fi
    
    if publish_package "$PACKAGE_NAME" "$pkg_path"; then
        print_success "包 @tinyflow-ai/$PACKAGE_NAME 发布成功!"
    else
        print_error "包 @tinyflow-ai/$PACKAGE_NAME 发布失败!"
        exit 1
    fi
fi

print_success "发布流程完成!"
print_info "查看发布的包: https://www.npmjs.com/org/tinyflow-ai"
