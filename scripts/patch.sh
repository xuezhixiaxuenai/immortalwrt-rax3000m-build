#!/bin/bash
set -e
cd openwrt
F=$(find feeds/luci -name channel_analysis.js | head -1)
if [ -z "$F" ]; then echo "找不到 channel_analysis.js"; exit 1; fi
echo "目标文件: $F"
python3 - "$F" <<'PY'
import io, re, sys

path = sys.argv[1]
s = io.open(path, encoding='utf-8').read()
applied = []

def sub(pattern, repl, tag, count=1):
    global s
    new, n = re.subn(pattern, repl, s, count=count, flags=re.M)
    if n:
        s = new
        applied.append(tag)
        return True
    return False

# 1) freqlist 缺 band：按信道号推断
sub(r'if\s*\(\s*bands\s*\[\s*freq\.band\s*\]\s*\)',
    'var b=freq.band||(freq.channel<=14?2:(freq.channel>=200?6:5));if(bands[b])',
    'freqlist-band')
sub(r'bands\s*\[\s*freq\.band\s*\]\.channels\.push',
    'bands[b].channels.push', 'freqlist-push')

# 2) scan 结果缺 band：按信道号推断
sub(r'if\s*\(\s*band\s*!=\s*res\.band\s*\)',
    'if(band!=(res.band||(res.channel<=14?2:(res.channel>=200?6:5))))', 'scan-band')

# 3) 取消自动轮询（避免周期扫描导致 WiFi 掉线）
sub(r'^[ \t]*poll\.add\s*\(\s*this\.pollFn\s*\)\s*;', '', 'no-autopoll')

# 4) 标签页切换时才扫描
sub(r'^[ \t]*poll\.start\s*\(\s*\)\s*;', 'this.pollFn&&this.pollFn();', 'tab-click-scan')

# 5) 去掉 poll.stop()
sub(r'^[ \t]*poll\.stop\s*\(\s*\)\s*;', '', 'no-pollstop')

# 6) HE 带宽白名单（驱动会返回 720/13 等垃圾值）
sub(r'if\s*\(\s*res\.he_operation\?\.channel_width\s*>\s*20\s*\)\s*\{',
    'if(res.he_operation?.channel_width>20&&[40,80,160,320].indexOf(res.he_operation.channel_width)>=0){',
    'he-whitelist')

# 7) VHT 带宽白名单
sub(r'if\s*\(\s*res\.vht_operation\?\.channel_width\s*>\s*40\s*\)\s*\{',
    'if(res.vht_operation?.channel_width>40&&[80,160,8080].indexOf(res.vht_operation.channel_width)>=0){',
    'vht-whitelist')

# 8) 单个 AP 脏数据不再搞崩整张表
sub(r'this\.add_wifi_to_graph\s*\(\s*chan_analysis\s*,\s*res\s*,\s*scanCache\s*,\s*center_channels\s*,\s*chan_width\s*\)\s*;',
    'try{this.add_wifi_to_graph(chan_analysis,res,scanCache,center_channels,chan_width)}catch(e){}',
    'graph-trycatch')
sub(r'this\.add_wifi_to_graph\s*\(\s*chan_analysis\s*,\s*local_wifi\s*,\s*scanCache\s*,\s*center_channels\s*,\s*chan_width\s*\)\s*;',
    'try{this.add_wifi_to_graph(chan_analysis,local_wifi,scanCache,center_channels,chan_width)}catch(e){}',
    'graph-trycatch-local')

io.open(path, 'w', encoding='utf-8').write(s)
print('已应用:', ', '.join(applied))
print('数量:', len(applied), '/ 9')
if len(applied) < 6:
    sys.exit('补丁过少（%d），源码可能已变更' % len(applied))
PY
echo "补丁完成"
