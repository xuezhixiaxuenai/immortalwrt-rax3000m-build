#!/bin/bash
set -e
cd openwrt
cat >> feeds.conf.default <<'EOF'
src-git lucky https://github.com/gdy666/luci-app-lucky.git;main
src-git openlist2 https://github.com/sbwml/luci-app-openlist2.git;main
src-git istore https://github.com/istoreos/istore.git;main
src-git vantage https://github.com/anothaDev/luci-theme-vantage.git;main
EOF
./scripts/feeds update -a
./scripts/feeds install -a
mkdir -p package/istore
cp -r feeds/istore/luci/* package/istore/ 2>/dev/null || true
echo "feeds 完成"
