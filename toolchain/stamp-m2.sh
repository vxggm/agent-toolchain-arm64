#!/bin/sh
# 给「包 2 · Gradle 离线仓库」打 AgentPad 来源标记。
#
# 用法: sh stamp-m2.sh <包根目录> <版本号>
#
# 为什么单独成文件而不写在 workflow 的 run: | 里：
#   YAML 块标量的每一行都必须缩进。heredoc 正文一旦写成零缩进（banner 那种
#   ====== 横线最容易这么写），块标量当场终止，整个 workflow 解析失败 ——
#   表现为 GitHub 把 run 名显示成文件路径、jobs 数为 0。
#   独立脚本由 create_file 写盘，字节原样，不经过 YAML 缩进规则。
set -e
C="$1"
VER="${2:-1.0.0}"

cat > "$C/AGENTPAD-M2-OFFLINE.txt" <<EOF
==============================================================
 AGENTPAD WORKSPACE - GRADLE OFFLINE MAVEN REPOSITORY
==============================================================
 name    : gradle-m2-offline
 version : $VER
 built   : $(date -u +%Y-%m-%d)
 host    : AgentPad Workspace  (com.agentpad.workspace)
 origin  : produced by a REAL assembleDebug run on CI,
           NOT a hand-assembled jar list
--------------------------------------------------------------
 contents:
   AGP 9.4.0 + aapt2 (arm64 override)
   org.jetbrains.kotlin.plugin.compose 2.4.21
   compose-bom 2026.09.00 / material3 1.5.0-beta02
   androidx core / activity / lifecycle
--------------------------------------------------------------
 usage:
   1) 解压本包，使其中的 caches/ 落到 GRADLE_USER_HOME 下
   2) 用 -Pandroid.aapt2FromMavenOverride 指向包 1 的 arm64 aapt2
   3) gradle --offline assembleDebug
 verify: sh verify.sh
==============================================================
EOF

mkdir -p "$C/.agentpad"
cat > "$C/.agentpad/mark.env" <<EOF
AGENTPAD_M2=1
AGENTPAD_APP=com.agentpad.workspace
AGENTPAD_NAME=gradle-m2-offline
AGENTPAD_VERSION=$VER
AGENTPAD_BUILD_DATE=$(date -u +%Y-%m-%d)
EOF

cat > "$C/verify.sh" <<'EOF'
#!/bin/sh
# 包 2 自检：确认关键 artifact 真的在，且没有 x86_64 aapt2 混进来。只读。
C=$(cd "$(dirname "$0")" && pwd)
echo "== agentpad marker =="
cat "$C/.agentpad/mark.env" 2>/dev/null || echo "MARKER MISSING"
echo "== key artifacts =="
FAIL=0
for p in \
  'com.android.tools.build/gradle/9.4.0' \
  'org.jetbrains.kotlin/kotlin-gradle-plugin' \
  'org.jetbrains.kotlin/kotlin-compiler-embeddable' \
  'androidx.compose.material3' \
  'androidx.compose.runtime' \
  'androidx.compose.ui'; do
  if find "$C/caches" -path "*$p*" -type f 2>/dev/null | head -1 | grep -q .; then
    echo "  OK   $p"
  else
    echo "  MISS $p"
    FAIL=1
  fi
done

echo "== 架构纯净性（包 2 不应含任何 aapt2 二进制）=="
# aapt2 是按架构分发的，x86_64 版在手机上跑不了；
# 手机端由包 1 提供 arm64 版，所以这里必须为空。
A2=$(find "$C/caches" -path '*com.android.tools.build/aapt2*' -type f 2>/dev/null | wc -l)
if [ "$A2" = "0" ]; then
  echo "  OK   aapt2 已剔除（由包 1 提供 arm64 版）"
else
  echo "  WARN 仍有 $A2 个 aapt2 文件（可能是别的 classifier，检查是否 x86_64）"
  find "$C/caches" -path '*com.android.tools.build/aapt2*' -type f 2>/dev/null | head -5
fi
# 其他 .so 也不该有
SO=$(find "$C/caches" -name '*.so' 2>/dev/null | wc -l)
echo "  .so 文件数: $SO（预期 0）"
echo "== size =="
du -sb "$C/caches" 2>/dev/null || du -sb "$C"
[ "$FAIL" = "0" ] && echo "VERIFY PASSED" || echo "VERIFY FAILED"
EOF
chmod 755 "$C/verify.sh"

echo "stamp-m2 done: $C ($VER)"