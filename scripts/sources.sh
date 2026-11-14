#!/bin/bash
# 把软件源和默认设置写进固件（用 OpenWrt 的 files/ 自定义覆盖层）
set -e
cd openwrt

mkdir -p files/etc/opkg
mkdir -p files/etc/uci-defaults

# ===== opkg 软件源 =====
cat > files/etc/opkg/distfeeds.conf <<'EOF'
src/gz immortalwrt_core https://mirrors.ustc.edu.cn/immortalwrt/releases/packages-24.10/aarch64_cortex-a53/base
src/gz immortalwrt_luci https://mirrors.ustc.edu.cn/immortalwrt/releases/packages-24.10/aarch64_cortex-a53/luci
src/gz immortalwrt_packages https://mirrors.ustc.edu.cn/immortalwrt/releases/packages-24.10/aarch64_cortex-a53/packages
src/gz immortalwrt_routing https://mirrors.ustc.edu.cn/immortalwrt/releases/packages-24.10/aarch64_cortex-a53/routing
src/gz immortalwrt_telephony https://mirrors.ustc.edu.cn/immortalwrt/releases/packages-24.10/aarch64_cortex-a53/telephony
src/gz istore_compat https://istore.istoreos.com/repo/all/compat
EOF

# ===== 首次启动默认设置 =====
cat > files/etc/uci-defaults/99-custom-defaults <<'EOF'
#!/bin/sh
# 默认主题 vantage
uci -q set luci.main.mediaurlbase='/luci-static/vantage'
# 默认语言中文
uci -q set luci.main.lang='zh_cn'
uci -q commit luci

# 默认 LAN 网段保持 192.168.15.x
uci -q set network.lan.ipaddr='192.168.15.1'
uci -q commit network

exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-defaults

echo '--- 写入的软件源 ---'
cat files/etc/opkg/distfeeds.conf
echo '--- 默认设置 ---'
cat files/etc/uci-defaults/99-custom-defaults
