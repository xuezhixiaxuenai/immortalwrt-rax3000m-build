#!/bin/bash
set -e
cd openwrt
F=$(find feeds/luci -name channel_analysis.js | head -1)
if [ -z "$F" ]; then echo "找不到 channel_analysis.js"; exit 1; fi
echo "目标文件: $F"
python3 - "$F" <<'PY'
import io, sys
path = sys.argv[1]
s = io.open(path, encoding='utf-8').read()
applied = []

def rep(old, new, tag):
    global s
    if old in s:
        s = s.replace(old, new, 1)
        applied.append(tag)

# 1) freqlist 缺 band：按信道号推断
rep('if(bands[freq.band])',
    'var b=freq.band||(freq.channel<=14?2:(freq.channel>=200?6:5));if(bands[b])', 'freqlist-band')
rep('bands[freq.band].channels.push(freq.channel)',
    'bands[b].channels.push(freq.channel)', 'freqlist-push')

# 2) scan 结果缺 band
rep('if(band!=res.band)',
    'if(band!=(res.band||(res.channel<=14?2:(res.channel>=200?6:5))))', 'scan-band')

# 3) 取消自动轮询
rep('this.pollFn=L.bind(this.handleScanRefresh,this);poll.add(this.pollFn);',
    'this.pollFn=L.bind(this.handleScanRefresh,this);', 'no-autopoll')

# 4) 点击标签页才扫描
rep('if(!this.radios[this.active_tab].loadedOnce)\npoll.start();',
    'if(this.pollFn) this.pollFn();', 'tab-click-scan')

# 5) 去掉 poll.stop()
rep('if(!radio.loadedOnce){radio.loadedOnce=true;poll.stop();}',
    'if(!radio.loadedOnce){radio.loadedOnce=true;}', 'no-pollstop')

# 6) HE 带宽白名单
rep('if(res.he_operation?.channel_width>20){',
    'if(res.he_operation?.channel_width>20&&[40,80,160,320].indexOf(res.he_operation.channel_width)>=0){',
    'he-whitelist')

# 7) VHT 带宽白名单
rep('if(res.vht_operation?.channel_width>40){',
    'if(res.vht_operation?.channel_width>40&&[80,160,8080].indexOf(res.vht_operation.channel_width)>=0){',
    'vht-whitelist')

# 8) 脏数据不再搞崩整表
rep('this.add_wifi_to_graph(chan_analysis,res,scanCache,center_channels,chan_width);rows.push(',
    'try{this.add_wifi_to_graph(chan_analysis,res,scanCache,center_channels,chan_width)}catch(e){}rows.push(',
    'graph-trycatch')
rep('this.add_wifi_to_graph(chan_analysis,local_wifi,scanCache,center_channels,chan_width);rows.push(',
    'try{this.add_wifi_to_graph(chan_analysis,local_wifi,scanCache,center_channels,chan_width)}catch(e){}rows.push(',
    'graph-trycatch-local')

io.open(path, 'w', encoding='utf-8').write(s)
print('已应用:', ', '.join(applied))
print('数量:', len(applied), '/ 10')
if len(applied) < 6:
    sys.exit('补丁过少，源码可能已变更')
PY
echo "补丁完成"
