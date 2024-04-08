#!/usr/bin/env bash

echo "All 256 ANSI color codes"
echo " "

for code in {0..255}
  do echo -e "${code}:   \e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
done

