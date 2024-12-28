# Define Catppuccin colors
CATT_MAUVE="%F{141}"    # Mauve
CATT_GREEN="%F{120}"    # Green
CATT_BLUE="%F{110}"     # Blue
CATT_YELLOW="%F{179}"   # Yellow
CATT_PINK="%F{175}"     # Pink
CATT_RED="%F{167}"      # Red
CATT_WHITE="%F{231}"    # White
CATT_BLACK="%F{235}"    # Black (background)
CATT_RESET="%f%k"       # Reset formatting

# Prompt settings
PROMPT='${CATT_MAUVE}%n@%m ${CATT_BLUE}%~ ${CATT_YELLOW}$(git_prompt_info)${CATT_GREEN}❯ ${CATT_RESET}'

# Git prompt settings (optional if using git plugin)
ZSH_THEME_GIT_PROMPT_PREFIX="${CATT_PINK} "  # Branch symbol
ZSH_THEME_GIT_PROMPT_SUFFIX="${CATT_RESET}"   # Reset color
ZSH_THEME_GIT_PROMPT_DIRTY="${CATT_RED} ✗"    # Dirty repo
ZSH_THEME_GIT_PROMPT_CLEAN="${CATT_GREEN} ✓"  # Clean repo

# RPrompt (right side prompt)
RPROMPT='${CATT_RED}Exit: %?${CATT_RESET}'
