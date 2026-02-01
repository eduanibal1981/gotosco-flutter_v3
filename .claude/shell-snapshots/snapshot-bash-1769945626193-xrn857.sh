# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
shopt -s expand_aliases
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg=''\''C:\Users\abdal\.local\bin\claude.exe'\'' --ripgrep'
fi
# Check for mcp-cli availability
if ! command -v mcp-cli >/dev/null 2>&1; then
  alias mcp-cli='/c/Users/abdal/.local/bin/claude.exe --mcp-cli'
fi
export PATH=$PATH
