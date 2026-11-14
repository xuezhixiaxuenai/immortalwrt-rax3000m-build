#!/bin/bash
set -e
cd openwrt
cat >> feeds.conf.default <<'EOF'
src-git lucky https://github.com/gdy666/luci-app-lucky.git;main
src-git istore https://github.com/istoreos/istore.git;main
src-git vantage https://github.com/anothaDev/luci-theme-vantage.git;main
EOF
./scripts/feeds update -a

# lucky 锁到 v2.19.4（与主路由现有版本一致：lucky 2.19.4 + luci-app-lucky 2.2.2）
if [ -d feeds/lucky/.git ]; then
  cd feeds/lucky
  git fetch -q --unshallow --tags 2>/dev/null || git fetch -q --tags 2>/dev/null || true
  git checkout -q v2.19.4
  echo "lucky 已锁定: $(grep -E '^PKG_VERSION' lucky/Makefile | head -1)"
  cd ../..
fi

./scripts/feeds install -a

mkdir -p package/istore
cp -r feeds/istore/luci/* package/istore/ 2>/dev/null || true
echo "feeds 完成"
