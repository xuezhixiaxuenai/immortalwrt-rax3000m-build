#!/bin/bash
set -e
cd openwrt
curl -fsSL \
  https://raw.githubusercontent.com/padavanonly/immortalwrt-mt798x-6.6/openwrt-24.10-6.6/defconfig/mt7981-ax3000.config \
  -o /tmp/ax3000.config

python3 - <<'PY'
import io

lines = io.open('/tmp/ax3000.config', encoding='utf-8').read().splitlines()
out = []
for line in lines:
    if line.startswith('CONFIG_TARGET_MULTI_PROFILE'):
        continue
    if line.startswith('CONFIG_TARGET_DEVICE_') and 'cmcc_rax3000m-emmc' not in line:
        continue
    if line.startswith('CONFIG_TARGET_mediatek_mt7981'):
        continue
    out.append(line)

idx = out.index('CONFIG_TARGET_mediatek=y')
out.insert(idx + 1, 'CONFIG_TARGET_mediatek_filogic=y')

extra = '''
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-lib-taskd=y
CONFIG_PACKAGE_luci-lib-xterm=y
CONFIG_PACKAGE_luci-app-openlist=y
CONFIG_PACKAGE_openlist=y
CONFIG_PACKAGE_luci-app-lucky=y
CONFIG_PACKAGE_lucky=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-wrtbwmon=y
CONFIG_PACKAGE_luci-app-turboacc-mtk=y
CONFIG_PACKAGE_luci-app-mtwifi-cfg=y
CONFIG_PACKAGE_luci-app-package-manager=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-theme-vantage=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y
CONFIG_PACKAGE_openssl-util=y
CONFIG_PACKAGE_nftables=y
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-package-manager-zh-cn=y
CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y
CONFIG_PACKAGE_luci-i18n-uhttpd-zh-cn=y
CONFIG_PACKAGE_luci-i18n-ddns-zh-cn=y
CONFIG_PACKAGE_luci-i18n-wrtbwmon-zh-cn=y
CONFIG_PACKAGE_luci-i18n-turboacc-mtk-zh-cn=y
CONFIG_PACKAGE_luci-i18n-mtwifi-cfg-zh-cn=y
CONFIG_PACKAGE_luci-i18n-openlist-zh-cn=y
CONFIG_PACKAGE_luci-i18n-lucky-zh-cn=y
CONFIG_PACKAGE_luci-i18n-store-zh-cn=y
'''.strip().splitlines()

out.extend(extra)
io.open('.config', 'w', encoding='utf-8').write('\n'.join(out) + '\n')
print('配置行数:', len(out))
PY

make defconfig
echo '--- 设备 ---'
grep -E '^CONFIG_TARGET_DEVICE.*=y' .config || true
echo '--- 关键包 ---'
grep -E '^CONFIG_PACKAGE_(openlist|lucky|luci-app-openlist|luci-app-lucky|luci-app-store)=' .config || true
echo '--- 主题 ---'
grep -E '^CONFIG_PACKAGE_luci-theme.*=y' .config || true
