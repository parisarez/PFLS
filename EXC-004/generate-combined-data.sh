rm -rf COMBINED-DATA

mkdir -p COMBINED-DATA

if [[ "$OSTYPE" == "darwin"* ]]
then
    SED_COMMAND="sed -i ''"
else
    SED_COMMAND="sed -i"
fi


for dir in $(ls -d RAW-DATA/DNA*)
do
    preculturename=$(basename $dir)

    
    culturename=$(grep $preculturename RAW-DATA/sample-translation.txt | awk '{print $2}')

    
    MAGcount=1
    BINcount=1

    
    cp $dir/checkm.txt COMBINED-DATA/$culturename-CHECKM.txt
    cp $dir/gtdb.gtdbtk.tax COMBINED-DATA/$culturename-GTDB-TAX.txt

    
    for fastafiles in $dir/bins/*.fasta
    do
        
        binname=$(basename $fastafiles .fasta)

        
        completion=$(grep "$binname " $dir/checkm.txt | awk '{print $13}')
        contamination=$(grep "$binname " $dir/checkm.txt | awk '{print $14}')

        
        if [[ $binname == bin-unbinned ]]
        then
            finalname="${culturename}_UNBINNED.fa"
            echo "($culturename unbinned contigs) ($finalname)"
        elif (( $(echo "$completion >= 50" | bc -l) && $(echo "$contamination < 5" | bc -l) ))
        then
            
            
            finalname=$(printf "${culturename}_MAG_%03d.fa" $MAGcount)
            echo "($culturename MAG $bin_name) ($finalname) (C/R: $completion/$contamination)"
            MAGcount=$(("$MAGcount + 1"))
        else
            finalname=$(printf "${culturename}_BIN_%03d.fa" $BINcount)
            echo " ($culturename BIN $binname) ($finalname) (C/R: $completion/$contamination)"
            BINcount=$(($BINcount + 1))
        fi

        
        $SED_COMMAND "s/ms.*${binname}/$(basename $finalname .fa)/g" COMBINED-DATA/$culturename-CHECKM.txt
        $SED_COMMAND "s/ms.*${binname}/$(basename $finalname .fa)/g" COMBINED-DATA/$culturename-GTDB-TAX.txt

        
        cp "$fastafiles" "COMBINED-DATA/$finalname" 
        awk -v prefix="$culturename" '/^>/ {print ">" prefix "_" ++count; next} {print}' "$fastafiles" > "COMBINED-DATA/$finalname"
    done
done