# Add zoxide to the command line if it exists
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Make sure to place the cursor at the bottom
printf "\e[H\ec\e[${LINES}B"
