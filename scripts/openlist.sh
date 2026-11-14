#!/bin/bash
# openlist 4.2.9 需要 Go 1.26，环境只有 1.23 → 降到 4.1.0（要求 Go 1.23.4）
set -e
cd openwrt
F=feeds/openlist2/openlist2/Makefile
if [ ! -f "$F" ]; then echo "找不到 $F"; exit 1; fi

sed -i 's/PKG_VERSION:=4\.2\.9/PKG_VERSION:=4.1.0/' "$F"
sed -i 's/PKG_WEB_VERSION:=4\.2\.9/PKG_WEB_VERSION:=4.1.0/' "$F"
sed -i 's|^PKG_HASH:=.*|PKG_HASH:=cdaf91413fe07b3d8155f644237a839dac09f084e812b25c76effca7dfc1d3f2|' "$F"
sed -i 's|^  HASH:=af0b7214fb3a5c34f27366acf528378d9501e27f6e36d5d9c6533c6fee67e4df|  HASH:=508c5d13bdf9defae749bf10b29353016aa45394fb99af78788fd59805a4ead0|' "$F"

echo '--- openlist 版本已调整 ---'
grep -nE 'PKG_VERSION|PKG_WEB_VERSION|PKG_HASH|HASH:=' "$F"
