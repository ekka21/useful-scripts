#!/usr/bin/env bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default debug flag
DEBUG=false

# Function to print debug messages
debug() {
    if [ "$DEBUG" = true ]; then
        echo -e "${YELLOW}DEBUG: $1${NC}" >&2
    fi
}

# Function to show usage
usage() {
    echo -e "${YELLOW}Usage: $0 [-d] <region> <instance-type>${NC}"
    echo -e "${BLUE}Options:${NC}"
    echo -e "  -d    Enable debug output"
    echo -e "${BLUE}Example: $0 -d us-east-1 t3.micro${NC}"
    exit 1
}

# Get ISO 8601 timestamp that works on both Linux and macOS
get_iso_time() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        date -u -v-1H "+%Y-%m-%dT%H:%M:%S"
    else
        # Linux version
        date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S'
    fi
}

# Check required commands
for cmd in aws jq; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}❌ Error: $cmd is not installed${NC}"
        exit 1
    fi
done

# Parse command line options
while getopts ":d" opt; do
    case ${opt} in
        d )
            DEBUG=true
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Input Validation
if [ "$#" -ne 2 ]; then
    usage
fi

# Input Parameters
REGION="$1"
INSTANCE_TYPE="$2"

debug "Debug mode enabled"
debug "Region: $REGION"
debug "Instance Type: $INSTANCE_TYPE"

echo -e "\n${BLUE}Fetching Spot Prices for Instance Type: ${BOLD}$INSTANCE_TYPE${NC} ${BLUE}in Region: ${BOLD}$REGION${NC}"

# Fetch Spot Prices
echo -ne "${YELLOW}Fetching spot price data...${NC}"
START_TIME=$(get_iso_time)
debug "Start Time: $START_TIME"

SPOT_PRICES=$(aws ec2 describe-spot-price-history \
    --region "$REGION" \
    --instance-types "$INSTANCE_TYPE" \
    --product-descriptions "Linux/UNIX" \
    --start-time "$START_TIME" \
    --output json)

# Clear the loading message
echo -ne "\r\033[K"

# Debug output
debug "Raw AWS Response:"
debug "$(echo "$SPOT_PRICES" | jq '.')"

# Validate JSON response
if [ $? -ne 0 ] || [ -z "$SPOT_PRICES" ]; then
    echo -e "${RED}❌ Failed to fetch spot prices or received empty response${NC}"
    exit 1
fi

echo -e "\n${GREEN}✨ AWS Spot Instance Price Details${NC}"
echo "----------------------------------------"
echo -e "${BOLD}Instance Type:${NC} $INSTANCE_TYPE"
echo -e "${BOLD}Region:${NC} $REGION"
echo -e "\n${BOLD}Prices by Availability Zone:${NC}"

# Process prices by AZ
while read -r line; do
    if [ ! -z "$line" ]; then
        AZ=$(echo "$line" | jq -r '.AvailabilityZone')
        PRICE=$(echo "$line" | jq -r '.SpotPrice')
        if [ ! -z "$AZ" ] && [ ! -z "$PRICE" ] && [ "$AZ" != "null" ] && [ "$PRICE" != "null" ]; then
            printf "  ${BLUE}%-15s${NC} \$%s/hour\n" "$AZ" "$PRICE"
        fi
    fi
done < <(echo "$SPOT_PRICES" | jq -c '.SpotPriceHistory[]')

# Calculate statistics
echo -e "\n${BOLD}Statistics:${NC}"
MIN_PRICE=$(echo "$SPOT_PRICES" | jq -r '.SpotPriceHistory | map(.SpotPrice | tonumber) | min // empty')
MAX_PRICE=$(echo "$SPOT_PRICES" | jq -r '.SpotPriceHistory | map(.SpotPrice | tonumber) | max // empty')
AVG_PRICE=$(echo "$SPOT_PRICES" | jq -r '.SpotPriceHistory | map(.SpotPrice | tonumber) | add/length // empty')

debug "Min Price: $MIN_PRICE"
debug "Max Price: $MAX_PRICE"
debug "Avg Price: $AVG_PRICE"

if [ ! -z "$MIN_PRICE" ]; then
    echo -e "Lowest Price:  \$$(printf "%.4f" $MIN_PRICE)/hour"
fi
if [ ! -z "$MAX_PRICE" ]; then
    echo -e "Highest Price: \$$(printf "%.4f" $MAX_PRICE)/hour"
fi
if [ ! -z "$AVG_PRICE" ]; then
    echo -e "Average Price: \$$(printf "%.4f" $AVG_PRICE)/hour"
fi

echo "----------------------------------------"
echo
