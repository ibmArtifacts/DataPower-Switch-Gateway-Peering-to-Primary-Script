#!/bin/bash

########### Set all the inputs in this section ###########
DPHOST=DATAPOWER_URL_HERE
USERNAME=PRIVILEDGED_USERNAME_HERE
PASS=PASSWORD_HERE
DOMAIN=DOMAIN_OF_APIC
##########################################################

## File is created then used each time the SSH connection is made
INFILE=cli_input.txt

## Prefix of the output filename. It will have a date and timestamp added.
OUTFILE=cli_output_$DPHOST


GWY_PEERING_LIST=$(cat << EOF > $INFILE
$USERNAME
$PASS
sw $DOMAIN
co
show gateway-peering
EOF

ssh -T $DPHOST < $INFILE)

# Extract gateway peering names and append "gateway-peering-switch-primary"
while IFS= read -r line; do
  if [[ $line =~ "gateway-peering:" && $line =~ "[up]" ]]; then
    name=$(echo "$line" | cut -d':' -f2- | cut -d'[' -f1)
    echo "gateway-peering-switch-primary$name"
  fi
done <<< "$GWY_PEERING_LIST" >> $INFILE


ssh -T $DPHOST < $INFILE >> $OUTFILE-$(date +%Y%m%d-%H%M%S).txt

rm $INFILE
echo "Created output file: " $OUTFILE-$(date +%Y%m%d-%H%M%S).txt
echo "Complete"
