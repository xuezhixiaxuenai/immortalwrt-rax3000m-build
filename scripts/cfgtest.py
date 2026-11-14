#!/usr/bin/env python3
# 生成 4 个候选 .config，用于测试哪种写法能选中 rax3000m-emmc 设备
import io
import sys

src = io.open('/tmp/def.config', encoding='utf-8').read().splitlines()


def variant(name):
    if name == 'A':
        out = []
        for l in src:
            if l.startswith('CONFIG_TARGET_MULTI_PROFILE'):
                continue
            if l.startswith('CONFIG_TARGET_DEVICE_') and 'cmcc_rax3000m-emmc' not in l:
                continue
            if l.startswith('CONFIG_TARGET_mediatek_mt7981'):
                continue
            out.append(l)
        i = out.index('CONFIG_TARGET_mediatek=y')
        out.insert(i + 1, 'CONFIG_TARGET_mediatek_filogic=y')
        return out
    if name == 'B':
        out = []
        for l in src:
            if l.startswith('CONFIG_TARGET_DEVICE_') and 'cmcc_rax3000m-emmc' not in l:
                continue
            if l.startswith('CONFIG_TARGET_mediatek_mt7981'):
                continue
            out.append(l)
        i = out.index('CONFIG_TARGET_mediatek=y')
        out.insert(i + 1, 'CONFIG_TARGET_mediatek_filogic=y')
        return out
    if name == 'C':
        return list(src)
    if name == 'D':
        return [
            'CONFIG_TARGET_mediatek=y',
            'CONFIG_TARGET_mediatek_filogic=y',
            'CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_cmcc_rax3000m-emmc=y',
        ]
    raise SystemExit('unknown variant ' + name)


for n in ['A', 'B', 'C', 'D']:
    io.open('/tmp/cfg_' + n, 'w', encoding='utf-8').write('\n'.join(variant(n)) + '\n')
print('已生成 4 个候选配置')
