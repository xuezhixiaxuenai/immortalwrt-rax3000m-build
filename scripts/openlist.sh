#!/bin/bash
# openlist 4.2.9 需要 Go 1.26，环境只有 1.23 → 用 4.1.9（要求 Go 1.23.4）
# 4.1.9 与主路由现有版本一致，数据完全兼容
set -e
cd openwrt
F=feeds/openlist2/openlist2/Makefile
if [ ! -f "$F" ]; then echo "找不到 $F"; exit 1; fi

sed -i 's/PKG_VERSION:=4\.[0-9.]*/PKG_VERSION:=4.1.9/' "$F"
sed -i 's/PKG_WEB_VERSION:=4\.[0-9.]*/PKG_WEB_VERSION:=4.1.9/' "$F"
sed -i 's|^PKG_HASH:=.*|PKG_HASH:=5171cef3b03f6b68af0e4886af7b6f5a6f9c103de41c3b831f46dcb3ddcc6f18|' "$F"
sed -i 's|^  HASH:=.*|  HASH:=460db8632ff7faf00e651f0fd92d3e85eb6770529313f193c8b418156eaa08c6|' "$F"

echo '--- openlist 版本已调整 ---'
grep -nE 'PKG_VERSION|PKG_WEB_VERSION|PKG_HASH|HASH:=' "$F"
