#!/bin/bash

# 设置固定助记词环境变量
export ANVIL_MNEMONIC="test test test test test test test test test test test junk"

echo "使用固定助记词启动 Anvil..."
echo "助记词: $ANVIL_MNEMONIC"

# 使用环境变量启动 Anvil
anvil -m "$ANVIL_MNEMONIC"