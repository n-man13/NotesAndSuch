#!/usr/bin/env bash
# adjust-ilo-limits.sh - Buffered fan adjustment script for Ubuntu remote management

ILO_USER="Administrator"
ILO_IP="192.168.1.245"
TARGET_LIMIT="1600"
FAN_MIN_SPEED="64"

PIDS_TO_MODIFY=(
    01 02 03 04 05 06 07 08 09 10 
    11 12 13 14 17 18 19 20 21 22 
    23 24 25 26 27 28 29 30 31 32 
    33 34 35 36 37 38 39 40 41 42 
    43 44 45 46 47 48 49 50 51 52 
    53 54 55 56 57 58 59 60 61 62 63
)

echo "Connecting to iLO 4 at ${ILO_IP} from external management node..."

# Generate the complete list of instructions in an execution array
COMMANDS=()
for pid in "${PIDS_TO_MODIFY[@]}"; do
    COMMANDS+=("fan pid $pid lo $TARGET_LIMIT")
done
for fan_id in {0..5}; do
    COMMANDS+=("fan p $fan_id min $FAN_MIN_SPEED")
done
COMMANDS+=("fan info g")
COMMANDS+=("exit")

# Open a single SSH channel and drip-feed commands to prevent buffer truncation
(
    for cmd in "${COMMANDS[@]}"; do
        echo "$cmd"
        sleep 0.5  # A small 500ms pause gives the spoofed iLO firmware room to breathe
    done
) | ssh -tt -i ~/.ssh/id_rsa_ilo4 \
    -oKexAlgorithms=+diffie-hellman-group14-sha1 \
    -oHostKeyAlgorithms=+ssh-rsa \
    -oPubkeyAcceptedKeyTypes=+ssh-rsa \
    "${ILO_USER}@${ILO_IP}"

echo "Done! Command stream processing complete."