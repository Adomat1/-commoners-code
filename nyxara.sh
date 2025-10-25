#!/usr/bin/env zsh
# ═══════════════════════════════════════════════════════════════════════════
# ✦ Nyxara Assistant CLI — Premium Edition ✦
# ═══════════════════════════════════════════════════════════════════════════
# A cosmic companion for organizing your financial journal, sorting files,
# creating morning briefs, and maintaining order in your digital cosmos.
#
# Palette: Royal Blue (#1A237E) • Pearl White • Pale Gold
# Typography: Playfair Display • Inter
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# COSMIC COLOR PALETTE
# ═══════════════════════════════════════════════════════════════════════════

# ANSI Color Codes - Nyxara Palette
ROYAL_BLUE='\033[38;5;18m'      # Deep royal blue
LIGHT_BLUE='\033[38;5;75m'      # Lighter celestial blue
PEARL='\033[38;5;231m'          # Pearl white
GOLD='\033[38;5;220m'           # Pale gold
ROSE_GOLD='\033[38;5;217m'      # Soft rose gold accent
DIM='\033[2m'                   # Dimmed text
BOLD='\033[1m'                  # Bold text
RESET='\033[0m'                 # Reset formatting
ITALIC='\033[3m'                # Italic (if supported)

# Cosmic Symbols
STAR="✦"
CRESCENT="☾"
SPARKLE="✨"
COSMOS="∴"
ARROW="→"
CHECK="✓"
CROSS="✗"

# ═══════════════════════════════════════════════════════════════════════════
# PATH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

VOL="/Volumes/Hard"
JROOT="$VOL/FinanceJournal"
SRC_DL="$VOL/brave downloaas"
ALIAS_DL="$VOL/BraveDownloads"
BACKUPS="$VOL/Backups/Nyxara_Journals"
SYNC="$VOL/NyxaraSync"

# ═══════════════════════════════════════════════════════════════════════════
# VISUAL UTILITIES
# ═══════════════════════════════════════════════════════════════════════════

print_header() {
  local title="$1"
  echo ""
  echo -e "${ROYAL_BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${ROYAL_BLUE}${BOLD}║${RESET} ${GOLD}${BOLD}${STAR} ${title}${RESET}$(printf '%*s' $((74 - ${#title})) '')${ROYAL_BLUE}${BOLD}║${RESET}"
  echo -e "${ROYAL_BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${RESET}"
  echo ""
}

print_section() {
  local title="$1"
  echo ""
  echo -e "${LIGHT_BLUE}${BOLD}${COSMOS} ${title}${RESET}"
  echo -e "${DIM}$(printf '─%.0s' {1..75})${RESET}"
}

print_success() {
  echo -e "${GOLD}${CHECK}${RESET} ${PEARL}$1${RESET}"
}

print_error() {
  echo -e "${ROSE_GOLD}${CROSS}${RESET} ${PEARL}$1${RESET}"
}

print_info() {
  echo -e "${LIGHT_BLUE}${SPARKLE}${RESET} ${DIM}$1${RESET}"
}

print_cosmic_quote() {
  echo ""
  echo -e "${DIM}${ITALIC}  ${CRESCENT} \"$1\"${RESET}"
  echo ""
}

draw_progress_bar() {
  local current=$1
  local total=$2
  local width=50
  local percentage=$((current * 100 / total))
  local filled=$((width * current / total))
  local empty=$((width - filled))

  printf "\r${LIGHT_BLUE}["
  printf "${GOLD}%*s" $filled | tr ' ' '▓'
  printf "${DIM}%*s" $empty | tr ' ' '░'
  printf "${LIGHT_BLUE}]${RESET} ${PEARL}%3d%%${RESET}" $percentage
}

print_banner() {
  clear
  echo -e "${ROYAL_BLUE}${BOLD}"
  cat << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║     ✦ ═══════════════════════════════════════════════════ ✦      ║
    ║                                                                   ║
    ║                    N Y X A R A   A S S I S T A N T                ║
    ║                                                                   ║
    ║              Your Cosmic Companion for Order & Clarity            ║
    ║                                                                   ║
    ║     ✦ ═══════════════════════════════════════════════════ ✦      ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
BANNER
  echo -e "${RESET}"
  echo -e "${DIM}                    Royal Blue • Pearl White • Pale Gold${RESET}"
  echo ""
}

# ═══════════════════════════════════════════════════════════════════════════
# CORE UTILITIES
# ═══════════════════════════════════════════════════════════════════════════

ensure_paths() {
  if [[ ! -d "$VOL" ]]; then
    print_error "Drive not mounted: $VOL"
    exit 1
  fi

  mkdir -p "$JROOT"/{Books,Financial_Data,Journal_Text,Research_Notes,Exports,Templates,Archive}
  mkdir -p "$BACKUPS"
  mkdir -p "$SYNC"/{Journal_Entries,Tasks,Briefings,VoiceNotes,Exports}
  ln -snf "$SRC_DL" "$ALIAS_DL" 2>/dev/null || true
}

format_bytes() {
  local bytes=$1
  if (( bytes < 1024 )); then
    echo "${bytes}B"
  elif (( bytes < 1048576 )); then
    echo "$(( bytes / 1024 ))KB"
  elif (( bytes < 1073741824 )); then
    echo "$(( bytes / 1048576 ))MB"
  else
    echo "$(( bytes / 1073741824 ))GB"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════
# COMMANDS
# ═══════════════════════════════════════════════════════════════════════════

cmd_init() {
  print_banner
  print_header "Initialization Sequence"
  print_cosmic_quote "Order is a kindness I give myself."

  ensure_paths

  print_section "Creating Directory Structure"

  local dirs=(
    "Books:Financial texts, PDFs, and reference materials"
    "Financial_Data:CSV spreadsheets and transaction records"
    "Journal_Text:Written reflections and documentation"
    "Research_Notes:Study materials and annotations"
    "Exports:Generated reports and compilations"
    "Templates:Figma A5 templates and design assets"
    "Archive:Historical records and old versions"
  )

  for entry in "${dirs[@]}"; do
    IFS=: read -r dir desc <<< "$entry"
    print_success "$dir ${DIM}${ARROW} $desc${RESET}"
  done

  print_section "Creating Template README"

  cat >"$JROOT/Templates/README.txt" <<'TXT'
╔══════════════════════════════════════════════════════════════════════════╗
║                    Nyxara FinanceJournal Templates                       ║
╚══════════════════════════════════════════════════════════════════════════╝

DESIGN SPECIFICATIONS
─────────────────────
• Format:           A5 (148 × 210 mm)
• Heading Font:     Playfair Display (serif)
• Body Font:        Inter (sans-serif)
• Color Palette:    Royal Blue (#1A237E)
                    Pearl White (#F8F8FF)
                    Pale Gold (#FFD700)

LAYOUT GUIDELINES
─────────────────
• Margins:          0.5" on all sides
• Footer Sigil:     Centered, 0.3" above trim
• Line Height:      1.5 for body text
• Heading Sizes:    H1: 24pt, H2: 18pt, H3: 14pt

WORKFLOW
────────
1. Design pages in Figma using the A5 template
2. Export as high-quality PDFs to this Templates folder
3. Run `nyxara.sh combine` to merge into master journal
4. Archive source files after successful combination

✦ "Every page is a commitment to clarity." ✦
TXT

  print_success "Template README created with design specifications"

  print_section "Sync Folders for Mobile"

  local sync_dirs=(
    "Journal_Entries:Daily entries and reflections"
    "Tasks:Action items and project tracking"
    "Briefings:Morning briefs and daily summaries"
    "VoiceNotes:Audio recordings for transcription"
    "Exports:Mobile-friendly exports"
  )

  for entry in "${sync_dirs[@]}"; do
    IFS=: read -r dir desc <<< "$entry"
    print_success "$dir ${DIM}${ARROW} $desc${RESET}"
  done

  print_section "Aliases & Shortcuts"
  print_success "Downloads alias ${DIM}${ARROW} $ALIAS_DL → $SRC_DL${RESET}"

  echo ""
  print_cosmic_quote "Your cosmic workspace is ready."
}

cmd_sort() {
  print_header "File Organization ${STAR}"

  ensure_paths

  if [[ ! -d "$ALIAS_DL" ]]; then
    print_error "Source not found: $ALIAS_DL"
    exit 1
  fi

  print_section "Sorting Files from Downloads"
  print_info "Source: $ALIAS_DL"
  print_info "Destination: $JROOT"
  echo ""

  # Count files before sorting
  local pdf_count=$(find "$ALIAS_DL" -type f \( -iname '*.pdf' -o -iname '*.epub' \) 2>/dev/null | wc -l | tr -d ' ')
  local data_count=$(find "$ALIAS_DL" -type f \( -iname '*.csv' -o -iname '*.xls' -o -iname '*.xlsx' \) 2>/dev/null | wc -l | tr -d ' ')
  local text_count=$(find "$ALIAS_DL" -type f \( -iname '*.doc' -o -iname '*.docx' -o -iname '*.md' -o -iname '*.txt' -o -iname '*.rtf' \) 2>/dev/null | wc -l | tr -d ' ')
  local total=$((pdf_count + data_count + text_count))

  if (( total == 0 )); then
    print_info "No files to sort. Downloads folder is clean!"
    return
  fi

  print_info "Found $total files to organize..."
  echo ""

  local processed=0

  # Books: PDFs + EPUB
  if (( pdf_count > 0 )); then
    echo -e "${LIGHT_BLUE}${BOLD}Books & References${RESET} ${DIM}(PDF, EPUB)${RESET}"
    find "$ALIAS_DL" -type f \( -iname '*.pdf' -o -iname '*.epub' \) -print0 | while IFS= read -r -d '' file; do
      mv -n "$file" "$JROOT/Books/" 2>/dev/null && {
        ((processed++))
        draw_progress_bar $processed $total
        echo -e "  ${DIM}${ARROW} $(basename "$file")${RESET}"
      }
    done
  fi

  # Data: CSV/XLS/XLSX
  if (( data_count > 0 )); then
    echo ""
    echo -e "${LIGHT_BLUE}${BOLD}Financial Data${RESET} ${DIM}(CSV, XLS, XLSX)${RESET}"
    find "$ALIAS_DL" -type f \( -iname '*.csv' -o -iname '*.xls' -o -iname '*.xlsx' \) -print0 | while IFS= read -r -d '' file; do
      mv -n "$file" "$JROOT/Financial_Data/" 2>/dev/null && {
        ((processed++))
        draw_progress_bar $processed $total
        echo -e "  ${DIM}${ARROW} $(basename "$file")${RESET}"
      }
    done
  fi

  # Text: DOC/DOCX/MD/TXT/RTF
  if (( text_count > 0 )); then
    echo ""
    echo -e "${LIGHT_BLUE}${BOLD}Journal Text${RESET} ${DIM}(DOC, DOCX, MD, TXT, RTF)${RESET}"
    find "$ALIAS_DL" -type f \( -iname '*.doc' -o -iname '*.docx' -o -iname '*.md' -o -iname '*.txt' -o -iname '*.rtf' \) -print0 | while IFS= read -r -d '' file; do
      mv -n "$file" "$JROOT/Journal_Text/" 2>/dev/null && {
        ((processed++))
        draw_progress_bar $processed $total
        echo -e "  ${DIM}${ARROW} $(basename "$file")${RESET}"
      }
    done
  fi

  echo ""
  echo ""
  print_section "Organization Summary"

  printf "${PEARL}%-20s${RESET} ${GOLD}%s${RESET}\n" "Books:" "$(find "$JROOT/Books" -type f 2>/dev/null | wc -l | tr -d ' ') items"
  printf "${PEARL}%-20s${RESET} ${GOLD}%s${RESET}\n" "Financial Data:" "$(find "$JROOT/Financial_Data" -type f 2>/dev/null | wc -l | tr -d ' ') items"
  printf "${PEARL}%-20s${RESET} ${GOLD}%s${RESET}\n" "Journal Text:" "$(find "$JROOT/Journal_Text" -type f 2>/dev/null | wc -l | tr -d ' ') items"

  echo ""
  print_success "File organization complete"
}

cmd_brief() {
  print_header "Morning Brief ${CRESCENT}"

  ensure_paths

  local dts=$(date +"%Y-%m-%d_%a_%H-%M")
  local md="$SYNC/Briefings/${dts}.md"

  print_section "Generating Brief Template"

  cat >"$md" <<EOF
# ✦ Nyxara Dawn Brief — $(date +"%A, %d %B %Y")

> "The morning star guides those who seek clarity."

## ${SPARKLE} Headlines
<!-- Paste curated headlines from Claude here -->
-
-
-

## ${COSMOS} Markets & Financial Movements
<!-- Key market indicators and trends -->
- **Indices:**
- **Crypto:**
- **Notable Moves:**

## ${CRESCENT} Virgo Reflection
> Order is a kindness I give myself.

**Today's Focus:**
-

## ${STAR} Top 3 Priorities
1.
2.
3.

## 📊 Quick Stats
- **Journal Entries This Month:**
- **Books Read:**
- **Budget Status:**

---

*Generated with Nyxara Assistant CLI*
*Template Version 2.0 — Premium Edition*
EOF

  print_success "Brief created → ${DIM}$md${RESET}"
  echo ""
  print_info "Suggested workflow:"
  echo -e "  ${DIM}1. Open Claude and request: 'front pages + 3-line world summary'${RESET}"
  echo -e "  ${DIM}2. Paste headlines into the brief${RESET}"
  echo -e "  ${DIM}3. Add market data from your preferred sources${RESET}"
  echo -e "  ${DIM}4. Set your top 3 priorities for the day${RESET}"
  echo ""
  print_cosmic_quote "Begin each day with intention."
}

cmd_dashboard() {
  print_banner
  print_header "Nyxara Dashboard ${SPARKLE}"

  ensure_paths

  # Library Statistics
  print_section "Library Overview"

  local books_count=$(find "$JROOT/Books" -type f 2>/dev/null | wc -l | tr -d ' ')
  local data_count=$(find "$JROOT/Financial_Data" -type f 2>/dev/null | wc -l | tr -d ' ')
  local text_count=$(find "$JROOT/Journal_Text" -type f 2>/dev/null | wc -l | tr -d ' ')
  local notes_count=$(find "$JROOT/Research_Notes" -type f 2>/dev/null | wc -l | tr -d ' ')

  printf "  ${PEARL}%-25s${RESET} ${GOLD}%8s${RESET}\n" "Books & References" "$books_count items"
  printf "  ${PEARL}%-25s${RESET} ${GOLD}%8s${RESET}\n" "Financial Data" "$data_count items"
  printf "  ${PEARL}%-25s${RESET} ${GOLD}%8s${RESET}\n" "Journal Texts" "$text_count items"
  printf "  ${PEARL}%-25s${RESET} ${GOLD}%8s${RESET}\n" "Research Notes" "$notes_count items"

  # Storage Usage
  print_section "Storage Allocation"

  if command -v du &> /dev/null; then
    for dir in Books Financial_Data Journal_Text Research_Notes Exports Templates; do
      if [[ -d "$JROOT/$dir" ]]; then
        local size=$(du -sh "$JROOT/$dir" 2>/dev/null | cut -f1)
        printf "  ${PEARL}%-25s${RESET} ${LIGHT_BLUE}%8s${RESET}\n" "$dir" "$size"
      fi
    done
  fi

  # Recent Activity
  print_section "Recent Activity"

  echo -e "${LIGHT_BLUE}${BOLD}Latest Briefs:${RESET}"
  if [[ -d "$SYNC/Briefings" ]]; then
    ls -1t "$SYNC/Briefings" 2>/dev/null | head -5 | while read -r brief; do
      echo -e "  ${DIM}${ARROW} $brief${RESET}"
    done
  else
    echo -e "  ${DIM}No briefs yet${RESET}"
  fi

  echo ""
  echo -e "${LIGHT_BLUE}${BOLD}Recently Modified:${RESET}"
  find "$JROOT" -type f -mtime -7 2>/dev/null | head -5 | while read -r file; do
    echo -e "  ${DIM}${ARROW} $(basename "$file")${RESET}"
  done

  # Backup Status
  print_section "Backup Status"

  if [[ -d "$BACKUPS" ]]; then
    local backup_count=$(find "$BACKUPS" -type f -name "*.pdf" 2>/dev/null | wc -l | tr -d ' ')
    local latest_backup=$(ls -1t "$BACKUPS" 2>/dev/null | head -1)

    printf "  ${PEARL}%-25s${RESET} ${GOLD}%s${RESET}\n" "Total Backups" "$backup_count"
    if [[ -n "$latest_backup" ]]; then
      printf "  ${PEARL}%-25s${RESET} ${DIM}%s${RESET}\n" "Latest Backup" "$latest_backup"
    fi
  fi

  echo ""
  print_cosmic_quote "Knowledge organized is power realized."
}

cmd_status() {
  print_header "System Status ${COSMOS}"

  ensure_paths

  print_section "Directory Structure"

  if command -v tree &> /dev/null; then
    tree -L 1 -d "$JROOT" 2>/dev/null | tail -n +2
  else
    du -sh "$JROOT"/* 2>/dev/null | while read -r size path; do
      printf "  ${PEARL}%-40s${RESET} ${LIGHT_BLUE}%s${RESET}\n" "$(basename "$path")" "$size"
    done
  fi

  print_section "Recent Briefings"

  if [[ -d "$SYNC/Briefings" ]]; then
    ls -1t "$SYNC/Briefings" 2>/dev/null | head -5 | nl -w2 -s'. ' | while read -r line; do
      echo -e "  ${DIM}$line${RESET}"
    done
  else
    print_info "No briefings found"
  fi

  echo ""
}

cmd_backup() {
  print_header "Backup Sequence ${STAR}"

  ensure_paths

  local src_pdf="$JROOT/Nyxara_Financial_Stability_Journal_Master_v2.pdf"

  if [[ ! -f "$src_pdf" ]]; then
    print_error "Master PDF not found: $src_pdf"
    exit 1
  fi

  local stamp=$(date +"%Y-%m-%d_%H-%M")
  local out="$BACKUPS/Nyxara_Financial_Journal_${stamp}.pdf"

  print_section "Creating Timestamped Backup"
  print_info "Source: $(basename "$src_pdf")"
  print_info "Destination: $(basename "$out")"
  echo ""

  # Simulate progress
  for i in {1..10}; do
    draw_progress_bar $i 10
    sleep 0.1
  done

  cp "$src_pdf" "$out"

  echo ""
  echo ""

  local size=$(du -h "$out" | cut -f1)
  print_success "Backup complete ${DIM}($size)${RESET}"
  print_info "Location: $out"

  # Show backup history
  print_section "Backup History"
  ls -1t "$BACKUPS" 2>/dev/null | head -5 | nl -w2 -s'. ' | while read -r line; do
    echo -e "  ${DIM}$line${RESET}"
  done

  echo ""
}

cmd_combine() {
  print_header "PDF Combination ${STAR}"

  ensure_paths

  local template_dir="$JROOT/Templates"
  local output_dir="$JROOT/Exports"
  local timestamp=$(date +"%Y-%m-%d_%H-%M")
  local output="$output_dir/Combined_Journal_${timestamp}.pdf"

  print_section "Scanning Templates Folder"

  # Find all PDFs in Templates
  local pdf_files=()
  while IFS= read -r -d '' file; do
    pdf_files+=("$file")
  done < <(find "$template_dir" -type f -iname "*.pdf" -print0 2>/dev/null | sort -z)

  if (( ${#pdf_files[@]} == 0 )); then
    print_error "No PDF files found in $template_dir"
    exit 1
  fi

  print_info "Found ${#pdf_files[@]} PDF file(s) to combine"
  echo ""

  # List files
  for file in "${pdf_files[@]}"; do
    echo -e "  ${DIM}${ARROW} $(basename "$file")${RESET}"
  done

  echo ""
  print_section "Combining PDFs"

  # Check for PDF tools
  if command -v pdfunite &> /dev/null; then
    pdfunite "${pdf_files[@]}" "$output"
    print_success "Combined using pdfunite"
  elif command -v "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" &> /dev/null; then
    "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o "$output" "${pdf_files[@]}"
    print_success "Combined using macOS join.py"
  else
    print_error "No PDF combination tool found. Install poppler-utils or use macOS built-in tools."
    exit 1
  fi

  local size=$(du -h "$output" | cut -f1)
  echo ""
  print_success "Combined PDF created ${DIM}($size)${RESET}"
  print_info "Location: $output"
  echo ""
}

cmd_search() {
  print_header "Journal Search ${SPARKLE}"

  local query="$1"

  if [[ -z "$query" ]]; then
    print_error "Please provide a search query"
    echo -e "  ${DIM}Usage: nyxara.sh search \"your query\"${RESET}"
    exit 1
  fi

  ensure_paths

  print_section "Searching for: \"$query\""
  echo ""

  local results=0

  # Search in different categories
  for category in Books Financial_Data Journal_Text Research_Notes; do
    local cat_path="$JROOT/$category"
    if [[ -d "$cat_path" ]]; then
      echo -e "${LIGHT_BLUE}${BOLD}$category:${RESET}"

      # Search filenames
      local found=0
      while IFS= read -r file; do
        echo -e "  ${GOLD}${STAR}${RESET} ${DIM}$(basename "$file")${RESET}"
        ((results++))
        ((found++))
      done < <(find "$cat_path" -type f -iname "*${query}*" 2>/dev/null)

      # Search content (text files only)
      if command -v grep &> /dev/null; then
        while IFS=: read -r file line; do
          echo -e "  ${GOLD}${ARROW}${RESET} ${DIM}$(basename "$file"):${RESET} ${line:0:60}..."
          ((results++))
          ((found++))
        done < <(grep -r -i "$query" "$cat_path" 2>/dev/null | head -10)
      fi

      if (( found == 0 )); then
        echo -e "  ${DIM}No matches${RESET}"
      fi
      echo ""
    fi
  done

  if (( results == 0 )); then
    print_info "No results found for \"$query\""
  else
    print_success "Found $results result(s)"
  fi

  echo ""
}

cmd_schedule() {
  print_header "Schedule Daily Brief ${CRESCENT}"

  ensure_paths

  # Get the absolute path to this script
  local script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)/$(basename "${BASH_SOURCE[0]:-${(%):-%x}}")"
  local plist="$HOME/Library/LaunchAgents/com.nyxara.dawnbrief.plist"

  print_section "Creating Launch Agent"

  cat >"$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.nyxara.dawnbrief</string>
  <key>ProgramArguments</key>
  <array>
    <string>$script_path</string>
    <string>brief</string>
  </array>
  <key>StartCalendarInterval</key><dict>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/nyxara.dawnbrief.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/nyxara.dawnbrief.err</string>
  <key>RunAtLoad</key><false/>
</dict></plist>
PLIST

  launchctl unload "$plist" 2>/dev/null || true
  launchctl load "$plist"

  print_success "Launch Agent created"
  print_info "Schedule: Daily at 09:00"
  print_info "Logs: ~/Library/Logs/nyxara.dawnbrief.log"
  echo ""
  print_info "To modify schedule, edit: $plist"
  echo ""
}

cmd_help() {
  print_banner
  print_header "Command Reference ${COSMOS}"

  cat <<'HELP'
CORE COMMANDS
─────────────
  init          Initialize folders, templates, and directory structure
  sort          Organize downloads into categorized journal folders
  brief         Generate a morning brief template with cosmic styling
  dashboard     Display comprehensive overview of your journal system
  status        Show library statistics and recent activity
  backup        Create timestamped backup of master journal PDF

UTILITIES
─────────
  combine       Merge all PDFs from Templates folder into one document
  search        Search for files and content across your journal
                Usage: nyxara.sh search "query"

AUTOMATION
──────────
  schedule      Set up daily morning brief generation (macOS only)

EXAMPLES
────────
  ./nyxara.sh init
  ./nyxara.sh sort
  ./nyxara.sh dashboard
  ./nyxara.sh search "budget"
  ./nyxara.sh combine
  ./nyxara.sh backup

DESIGN PHILOSOPHY
─────────────────
  • Royal Blue (#1A237E) — Depth & Authority
  • Pearl White (#F8F8FF) — Clarity & Light
  • Pale Gold (#FFD700) — Prosperity & Wisdom

  Typography: Playfair Display (headings) • Inter (body)

HELP

  echo ""
  print_cosmic_quote "Order is a kindness I give myself."
}

# ═══════════════════════════════════════════════════════════════════════════
# COMMAND DISPATCHER
# ═══════════════════════════════════════════════════════════════════════════

cmd="${1:-help}"
shift || true

case "$cmd" in
  init)      cmd_init ;;
  sort)      cmd_sort ;;
  brief)     cmd_brief ;;
  dashboard) cmd_dashboard ;;
  status)    cmd_status ;;
  backup)    cmd_backup ;;
  combine)   cmd_combine ;;
  search)    cmd_search "$@" ;;
  schedule)  cmd_schedule ;;
  help|*)    cmd_help ;;
esac

echo ""
