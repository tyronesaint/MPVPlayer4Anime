#!/bin/bash

# 自动部署脚本
# 将项目推送到 GitHub 并触发 Actions 构建

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 VLC for iOS - Auto Deployment${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""

# 检查 Git 状态
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  没有需要提交的更改${NC}"
    exit 0
fi

# 显示更改
echo -e "${YELLOW}📝 待提交的更改:${NC}"
git status --short
echo ""

# 确认提交
read -p "是否提交并推送这些更改? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo -e "${RED}❌ 操作已取消${NC}"
    exit 0
fi

# 获取提交信息
echo ""
read -p "请输入提交信息 (留空使用默认): " COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Update: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# 添加文件
echo -e "${YELLOW}📦 添加文件...${NC}"
git add .

# 提交
echo -e "${YELLOW}💾 提交更改...${NC}"
git commit -m "$COMMIT_MSG"

# 推送
echo -e "${YELLOW}🚀 推送到 GitHub...${NC}"
git push

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ 部署完成！${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "📍 查看 Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
