sequences=$(awk '!/^>/ {print}' "$1")
num_sequences=$(grep -c '^>' "$1")
total_length=$(awk '/^>/ {next} {sum += length} END {print sum}' "$1")
lengths=$(awk '/^>/ {next} {print length}' "$1")
longest=$(echo "$lengths" | sort -nr | head -n1)
shortest=$(echo "$lengths" | sort -n | head -n1)
average_length=$((total_length / num_sequences))
gc_count=$(echo "$sequences" | grep -o '[GCgc]' | wc -l)
gc_content=$(echo "$gc_count * 100 / $total_length" | bc -l)

echo "FASTA File Statistics:"
echo "----------------------"
echo "Number of sequences: $num_sequences"
echo "Total length of sequences: $total_length"
echo "Length of the longest sequence: $longest"
echo "Length of the shortest sequence: $shortest"
echo "Average sequence length: $average_length"
echo "GC Content (%): $gc_content"