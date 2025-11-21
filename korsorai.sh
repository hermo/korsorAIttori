#!/usr/bin/env bash
#
# korsorai.sh - AI-powered Finnish Slang Translator (KorsorAIttori)
# Converts text or web pages to 2000s Finnish youth slang using OpenRouter API
#
# Usage: korsorai.sh [OPTIONS] [TEXT]
#
# Dependencies: curl, jq
#
# Environment: OPENROUTER_API_KEY must be set

set -euo pipefail

OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"
OPENROUTER_URL="https://openrouter.ai/api/v1/chat/completions"
DEFAULT_MODEL="anthropic/claude-sonnet-4.5"
TEMPERATURE=0.8

declare -A STYLES=(
    ["classic"]="2000-luvun alun klassinen korso-slang"
    ["modern"]="Moderni Gen Z slang"
    ["mixed"]="Sekoitus klassista ja modernia slangia"
    ["extreme"]="Äärimmäinen korsoilu, maksimaalinen slang-tiheys"
    ["subtle"]="Kevyt korsoilu, säästellään slangia"
)

declare -A STYLE_EXAMPLES=(
    ["classic"]="Käytä paljon kiroilua ja IRC-galleria aikakauden ilmaisuja:
- Kirosanat: vittu, saatana, perkele, helvetti, jumalauta, paska
- Slangisanat: ragee, hengaa, tsekaa, jäbä, muija, tyyppi
- Lyhenteet: typ, jne, tos, sil
- Ilmaisut: 'ei vittu', 'saatanan', 'perkeleesti', 'ihan sikana'
- Lauserakenne: ronski, suora, huoleton
Esim: 'vitun hyvä', 'saatanan kallis', 'ragee ihan sikana'"
    ["modern"]="Moderni Gen Z/englanti, internet ja meemisanasto:
- Slangisana: slay, based, cap/no cap, mid, cringe, vibe, flex
- Ilmaisu: 'fr fr', 'lowkey', 'ngl', 'periodt', 'ate'
Esim: 'tää on fr fr based', 'lowkey hyvä vibe', 'se slays', 'no cap hyvä'"
    ["mixed"]="Sekoita vapautuneesti klassista ja uutta:
- 'vittu se slays', 'no cap saatana', 'ihan based meininki', 'ragee cringe style'"
    ["extreme"]="Maksimaalinen slangitiheys:
- Joka toinen sana slangia, paljon kiroilua
- Esim: 'vittu jäbä et tää on ihan sickimpii juttui mitä oon nähny, ei saatana'"
    ["subtle"]="Kevyesti slangia, pääosin normikieli:
- Vain muutama slangisana/kirosana per lause
- Esim: 'Onks sul aikaa huomenna?', 'Toi tyyppi vaik ihan jees'"
)

usage() {
    cat << EOF
Usage: korsorai.sh [OPTIONS] [TEXT]

Convert text or web pages to Finnish youth slang using KorsorAIttori and AI.

OPTIONS:
    -s, --style STYLE    Slang style (classic/moder/mixed/extreme/subtle), default: classic
    -i, --intensity N    Slang intensity 1-10 (default: 7)
    -m, --model MODEL    OpenRouter model (default: anthropic/claude-sonnet-4.5)
    -l, --list-styles    Show detailed style descriptions
    -h, --help           Show this help

EXAMPLES:
    korsorai.sh "Hei, miten menee?"
    korsorai.sh -s modern "Tämä on tärkeä viesti"
    korsorai.sh -i 10 -s extreme "Huomenna on kokous"
    korsorai.sh -s classic -i 9 < teksti.txt
    korsorai.sh -l

ENVIRONMENT:
    OPENROUTER_API_KEY   Required: Your OpenRouter API key
EOF
}

list_styles() {
    echo "Available Styles:"
    for style in classic modern mixed extreme subtle; do
        echo
        echo "$style:"
        echo "  ${STYLES[$style]}"
        echo "  Esimerkkejä:"
        echo "  ${STYLE_EXAMPLES[$style]}" | sed 's/^/    /'
    done
}

error() {
    echo "Error: $*" >&2
    exit 1
}

check_dependencies() {
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Missing dependency: $cmd"
        fi
    done
}

check_api_key() {
    if [ -z "$OPENROUTER_API_KEY" ]; then
        error "OPENROUTER_API_KEY not set"
    fi
}

build_prompt() {
    local text="$1"
    local style="$2"
    local intensity="$3"
    local desc="${STYLES[$style]}"
    local ex="${STYLE_EXAMPLES[$style]}"
    cat << PROMPT
Käännä seuraava teksti suomalaiseksi nuorisoslangiksi.

TYYLI: $desc

TYÖTYYLIOHJEET JA ESIMERKIT:
$ex

INTENSITEETTI: $intensity/10 (1=hienovarainen, 10=äärimmäinen)

YLEISOHJEET:
- Säilytä sisältö
- Muokkaa slangilla ja kiroilulla tyylin mukaan
- Intensiteetti määrää slangin/kiroilun taso
- Palauta vain käännetty teksti, ei selityksiä
- Slangit ja kiroilut kuuluvat tyyliin jos tyyli vaatii!

KÄÄNNETTÄVÄ TEKSTI:
$text
PROMPT
}

call_openrouter() {
    local prompt="$1"
    local model="$2"
    local payload
    payload=$(jq -n \
        --arg model "$model" \
        --arg prompt "$prompt" \
        --argjson temp "$TEMPERATURE" \
        '{
            model: $model,
            messages: [
                {
                    role: "user",
                    content: $prompt
                }
            ],
            temperature: $temp
        }')
    local response
    response=$(curl -s -X POST "$OPENROUTER_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "HTTP-Referer: https://github.com/korsorai" \
        -H "X-Title: korsorai-cli" \
        -d "$payload")
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.error.message')
        error "API error: $error_msg"
    fi
    echo "$response" | jq -r '.choices[0].message.content'
}

main() {
    local style="classic"
    local intensity=7
    local model="$DEFAULT_MODEL"
    local input_text=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--style)
                style="$2"
                if [[ ! -v STYLES[$style] ]]; then
                    error "Unknown style: $style"
                fi
                shift 2
                ;;
            -i|--intensity)
                intensity="$2"
                if ! [[ "$intensity" =~ ^[1-9]$|^10$ ]]; then
                    error "Intensity must be 1-10"
                fi
                shift 2
                ;;
            -m|--model)
                model="$2"
                shift 2
                ;;
            -l|--list-styles)
                list_styles
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                input_text="$1"
                shift
                ;;
        esac
    done
    check_dependencies
    check_api_key

    if [ -z "$input_text" ] && [ ! -t 0 ]; then
        input_text=$(cat)
    elif [ -z "$input_text" ]; then
        error "No input provided. Use -h for help."
    fi

    if [ -z "$input_text" ]; then
        error "No content to translate"
    fi

    local char_count=${#input_text}
    if [ "$char_count" -gt 10000 ]; then
        input_text="${input_text:0:10000}"
    fi

    local prompt
    prompt=$(build_prompt "$input_text" "$style" "$intensity")

    local result
    result=$(call_openrouter "$prompt" "$model")

    echo "$result"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

