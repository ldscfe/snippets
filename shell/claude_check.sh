#!/bin/bash
# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Connectivity Test Script ---
# Tests the reachability of specific models via the local Claude-code server.
MODELS=(
    "claude-3-opus-20240229"
    "claude-3-5-sonnet-20240620"
    "claude-3-haiku-20240307"
)

echo -e "${YELLOW}Starting model connectivity quick check (Anthropic API)...${NC}"
echo -e "${DARK_GRAY}------------------------------------------------------------${NC}"

for MODEL in "${MODELS[@]}"; do
    printf "${BLUE}Testing${NC} %-40s " "[$MODEL]"
    
    # Execute curl request using Anthropic's native /v1/messages endpoint
    RESPONSE=$(curl -s -X POST http://127.0.0.1:18082/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: ldscfe" \
        -H "anthropic-version: 2023-06-01" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": \"hi\"}],
            \"max_tokens\": 10
        }")

    # Validate response
    # Success: contains "content" | Failure: usually contains "error"
    if echo "$RESPONSE" | grep -q "\"content\""; then
        echo -e "${GREEN}[ OK ]${NC}"
    else
        echo -e "${RED}[ FAIL ]${NC}"
        # Extract and display a preview of the error response
        ERR_MSG=$(echo "$RESPONSE" | tr -d '\n' | cut -c 1-80)
        echo -e "    ${DARK_GRAY}-> Response: $ERR_MSG...${NC}"
    fi
done

echo -e "${DARK_GRAY}------------------------------------------------------------${NC}"
echo -e "${GREEN}Check complete.${NC}"
