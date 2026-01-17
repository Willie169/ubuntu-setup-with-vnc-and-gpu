#!/bin/bash

export TMPDIR="/tmp"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include"
export NVM_DIR="$HOME/.nvm"
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export CLASSPATH="$CLASSPATH:/usr/lib/antlr-4.13.2-complete.jar"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_NDK_HOME="$HOME/Android/Sdk/ndk/29.0.14206865"
export GOPROXY='direct'
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go:$GOPATH"
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:$HOME/.local/sbin:/usr/glibc/bin:$GOPATH/bin:$GOROOT/bin:$HOME/.cargo/bin:/opt/TurboVNC/bin:/usr/local/texlive/2025/bin/x86_64-linux:/opt/android-studio/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_NDK_HOME:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$HOME/intelFPGA/20.1/modelsim_ase/bin"
export WAYDROID="$HOME/.local/share/waydroid/data/media/0"
export PLANTUML_JAR="$HOME/plantuml.jar"
export BOTTLES="$HOME/.var/app/com.usebottles.bottles/data/bottles"
export KIT="/usr/share/LaTeX-ToolKit"
export PATCH="$HOME/texmf/tex/latex/physics-patch"
export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os -r elease; then
  inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
  . /etc/os -r elease
  echo "$VERSION_ID"
fi
)
