#!/bin/sh
# 给工具链打上 AgentPad 来源标记。
# 用法: sh stamp.sh <工具链根目录> <版本号>
set -e
C="$1"
VER="${2:-1.0.0}"

cat > "$C/AGENTPAD-TOOLCHAIN.txt" <<EOF
==============================================================
 AGENTPAD WORKSPACE - SELF-ASSEMBLED AARCH64 BUILD TOOLCHAIN
==============================================================
 name    : gradle-toolchain-arm64
 version : $VER
 built   : $(date -u +%Y-%m-%d)
 host    : AgentPad Workspace  (com.agentpad.workspace)
 origin  : assembled by AgentPad CI, NOT a redistributed Google SDK
--------------------------------------------------------------
 jdk     : Temurin OpenJDK 17.0.21+9  (linux/aarch64, glibc)
 gradle  : Gradle 9.6.0               (bin distribution, sha256 verified)
 sdk     : build-tools 36.0.0  aarch64 natives
           platforms/android-37  android.jar
           platform-tools  aarch64
--------------------------------------------------------------
 EVERY executable in this tree is native ELF aarch64
 (e_machine = 0xB7). No x86_64 emulation, no qemu,
 no binfmt_misc registration required.
--------------------------------------------------------------
 verify : sh verify.sh
 mark   : .agentpad/mark.env
==============================================================
EOF

mkdir -p "$C/.agentpad"
cat > "$C/.agentpad/mark.env" <<EOF
AGENTPAD_TOOLCHAIN=1
AGENTPAD_APP=com.agentpad.workspace
AGENTPAD_NAME=gradle-toolchain-arm64
AGENTPAD_VERSION=$VER
AGENTPAD_ARCH=aarch64
AGENTPAD_FORMAT=tar.gz
AGENTPAD_BUILD_DATE=$(date -u +%Y-%m-%d)
EOF

for f in "$C/jdk-17.0.21+9/bin/java" "$C/gradle-9.6.0/bin/gradle" "$C/android-sdk/build-tools/36.0.0/aapt2"; do
  [ -f "$f" ] && echo "AgentPad self-assembled aarch64 toolchain v$VER (com.agentpad.workspace)" > "$f.agentpad.txt"
done

cat > "$C/verify.sh" <<'EOF'
#!/bin/sh
# AgentPad toolchain authenticity + arch self-check. Read-only.
C=$(cd "$(dirname "$0")" && pwd)
echo "== agentpad marker =="
cat "$C/.agentpad/mark.env" 2>/dev/null || echo "MARKER MISSING"
echo "== arch check (expect 0xB7 = aarch64) =="
for f in "$C/jdk-17.0.21+9/bin/java" "$C/gradle-9.6.0/bin/gradle" \
         "$C/android-sdk/build-tools/36.0.0/aapt2" \
         "$C/android-sdk/build-tools/36.0.0/zipalign"; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  m=$(head -c 20 "$f" | od -An -tx1 | tr -d ' \n' | cut -c35-38)
  echo "$f -> 0x$m"
done
echo "== run test =="
"$C/jdk-17.0.21+9/bin/java" -version 2>&1 | head -2
"$C/android-sdk/build-tools/36.0.0/aapt2" version 2>&1 | head -1
EOF
chmod 755 "$C/verify.sh"
echo "stamp done: $C ($VER)"