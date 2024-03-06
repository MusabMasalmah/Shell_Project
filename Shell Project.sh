

save_flag=0
readSwitch=0
declare -A data
num_columns=0
num_rows=0
while true
do
    echo "******************************************************"
    echo "Main Menu:"                                               #printing the menu in while loop
    echo "r - Read dataset from file"
    echo "p - Print names of all features"
    echo "l - Apply label encoding to a categorical feature"
    echo "o - Apply one-hot encoding to a categorical feature"
    echo "m - Apply MinMax scaling to a feature"
    echo "s - Save processed dataset to file"
    echo "e - Exit program"
    echo
    echo "Enter your choice:"
    read choice                                                     #read the choice of the user
    echo "******************************************************"
    
    if [ $choice = "e" ]                                            #if the user is enter "e" then exit after check the saving
    then
        if [ $save_flag -eq 1 ]
        then
            echo "Are you sure you want to exist"
            read save_cho
            if [[ $save_cho == "yes" ]]
            then
                echo "the data saved sucssfully"
                exit
            else
                continue
            fi
        else
            echo "The processed dataset is not saved. Are you sure you want to exist"
            read save_cho
            if [[ $save_cho == "yes" ]]
            then
                exit
            else
                continue
            fi
        fi    
    elif [ "$readSwitch" -eq 0 -a  "$choice" != "r" ]               #if the user enter in choice before "r" print a massege
    then
        echo "You must first read a dataset from a file"
        continue
    fi
    case $choice in
    r)  echo "Please input the name of the dataset file: "          
        read filename
        
        num_columns=$(($(head -n 1 $filename | tr ';' '\n' | wc -l)-1))
        num_rows=$(($(cat $filename | wc -l)-1))
        
        if [ ! -f $filename ]                                       #check if file is exist
        then
            echo "File does not exist"
        else
            FLcounter=0     #first line counter to avoid first line
            read_flag=0     #read flag to check if we can read ot the data set is wrong
            while read -r line                                  
            do
                if [ $FLcounter -eq 0 ]
                then
                    FLcounter=$(($FLcounter+1))
                    continue
                fi    
                test_columns=$(($(echo $line | tr ';' '\n' | wc -l)-1)) #check if the the data set is correct
                if [ $test_columns -ne $num_columns ]                   
                then
                    read_flag=1
                    echo "Theformat of the data in the dataset file is wrong"
                    break 
                fi
            done < $filename
            
            if [ $read_flag -ne 1 ]
            then
            readSwitch=1
            j=0
            while read -r line
            do
            
            for ((i=1;i<=$num_columns;i++)) do
                data[$j,$i]=$(echo $line | cut -d ';' -f$i)             #read the lines and put it in 2d array
                printf ${data[$j,$i]}" "
            done
            j=$(($j+1))
            echo
            
                
            done < $filename
            fi
            
        fi;;
    p)  for ((i=1;i<=$num_columns;i++)) do                     
            printf  ${data[0,$i]}' '               #print the values of features
        done
        echo ;;
    
    l)  echo "Please input the name of the categorical feature for label encoding"
        
        flag=0 #flag to check if the features is correct or not          
        
        read categorical_feature
        for ((i=1;i<=$num_columns;i++)) do
        featuresC=${data[0,$i]}
        if [ $featuresC = $categorical_feature ]                        #check if the features is correct
        then
            flag=$i
        fi    
        done
        if [ $flag -eq 0 ]
        then
            echo "The name of categorical feature is wrong"
            continue
        else
            declare -A arr1                                             #array of values before encoding
            declare -A arr2                                             #array of values after encoding
            i=0
            while [ $i -ne $(($num_rows+1)) ]
            do
                arr1[$i]=${data[$i,$flag]}
                i=$(($i+1))
            done
            arr2[0]=arr1[0]
            j=2
            index=2
            arr2[1]=1
            while [ $j -ne $(($num_rows+1)) ]
            do
                flagB=0
                for ((i=1;i<j;i++))
                do
                    
                    if [ ${arr1[$j]} = ${arr1[$i]} ]        #if there 2 word similer put the same number to the secouned one as the first
                    then
                        arr2[$j]=${arr2[$i]}
                        flagB=1
                    fi
                done
                if [ $flagB -ne 1 ]                         #if not same put a new number to the new word
                then
                    arr2[$j]=$index
                    index=$(($index+1))
                fi
                j=$(($j+1))
            done
            #features=$(head -n 1 dataset.txt)               #print the first kine of the file
            #echo $features 
            for ((i=1;i<=$num_rows;i++))
            do
                data[$i,$flag]=${arr2[$i]}                  #edit the values of the data array
            done
            for ((j=0;j<=$num_rows;j++)) do
                 for ((i=1;i<=$num_columns;i++)) do                     
                    printf  ${data[$j,$i]}';'               #print the values after encoding
                 done
                 echo
            done
        fi;;
    
    o) echo "Please input the name of the categorical feature for ont-hot encoding"
        
        flag=0 #flag to check if the features is correct or not          
        
        read categorical_feature
        for ((i=1;i<=$num_columns;i++)) do
        featuresC=${data[0,$i]}
        if [ $featuresC == $categorical_feature ]                        #check if the features is correct
        then
            flag=$i
        fi    
        done
        if [ $flag -eq 0 ]
        then
            echo "The name of categorical feature is wrong"
            continue
        else
            
            counter=0
            j=0
            while [ $j -ne $(($num_rows+1)) ]
            do
                
                if [ $j -eq 0 ]
                then
                    counter=$(($num_columns+1))
                    data[0,$counter]=${data[1,$flag]}                    #add new values to the feauters on header line
                    j=2
                    continue
                fi 
                flagB=0
                for ((i=1;i<j;i++))
                do
                    if [ ${data[$j,$flag]} = ${data[$i,$flag]} ]        #if there 2 word similer p
                    then
                        flagB=1                                         #get just one  word from the word in the column
                    fi
                done
                if [ $flagB -ne 1 ]
                then
                    counter=$(($counter+1))
                    data[0,$counter]=${data[$j,$flag]}                  #add the words to the headr line
                fi        
                j=$(($j+1))
            done
            Gcounter=$(($num_columns+1))
            j=1
            while [ $j -ne $(($num_rows+1)) ]
            do
                for ((i=$Gcounter;i<=$counter;i++))
                do
                    if [ ${data[$j,$flag]} = ${data[0,$i]} ]             #check the data and put the vlues 
                    then
                        data[$j,$i]=1
                    else
                        data[$j,$i]=0
                    fi    
                done
                j=$(($j+1))
            done
            if [ ${data[1,$flag]} = "no" -o ${data[1,$flag]} = "yes" ]  #if the column with yes or no values add features with yes or no
            then
                counter=$(($num_columns+1))
                data[0,$counter]+="-"${data[0,$flag]}
                counter=$(($counter+1))
                data[0,$counter]+="-"${data[0,$flag]}
            fi
            j=0
            while [ $j -ne $(($num_rows+1)) ]
            do
                for ((i=$flag;i<=$counter;i++))
                do
                    plus=$(($i+1))
                    temp=${data[$j,$plus]}                              #remove the column after encoding
                    data[$j,$plus]=${data[$j,$i]} 
                    data[$j,$i]=$temp
                done
                j=$(($j+1))
            done
            counter=$(($counter-1))
            for ((j=0;j<=$num_rows;j++)) do
                 for ((i=1;i<=$counter;i++)) do                     
                    printf  ${data[$j,$i]}';'               #print the values after encoding
                 done
                 echo
            done
        fi
        num_columns=$counter
        ;;
    
    m)  echo "Please input the name of the feature to be scaled”:"
        
        flag=0 #flag to check if the features is correct or not          
        
        read categorical_feature
        for ((i=1;i<=$num_columns;i++)) do
        featuresC=${data[0,$i]}
        if [ $featuresC == $categorical_feature ]                        #check if the features is correct
        then
            flag=$i
        fi    
        done
        if [ $flag -eq 0 ]
        then
            echo "The name of feature not found"
        else
            if ! [[ "${data[1,$flag]}" =~ ^[0-9]+$ ]]   #check if the value numric
            then
               echo "this feature is categorical feature and must be encoded first"
            else
                minnumber=${data[1,$flag]}
                for (( i=2;i<=$num_rows;i++ ))
                do
                num=${data[$i,$flag]}
                if [[ $num < $minnumber ]]
                then
                    minnumber=$num                  #find the minimum value
                fi
                done
                
                maxnumber=${data[1,$flag]}
                for (( i=2;i<=$num_rows;i++ ))
                do
                num=${data[$i,$flag]}
                if [[ $num > $maxnumber ]]
                then
                    maxnumber=$num                  #find the maximum value
                fi
                done
                echo "minimum number is: "$minnumber
                echo "maximum number is: "$maxnumber
                echo
                printf 'scaling : [ '
                for (( i=1;i<=$num_rows;i++ ))
                do
                num=${data[$i,$flag]}
                up=$(($num-$minnumber))
                down=$(($maxnumber-$minnumber))         
                scail=$(($up/$down))                    # $(echo "$(($up/$down))" | bc) this for float and did not work on online                   
                if [ $i -ne $num_rows ]                 #find the vlues of the scaling
                then
                    printf '%.2f,' $scail       #print the values
                else
                    printf '%.2f ]' $scail
                    echo
                fi    
                done
            fi
            
        fi;;
    
    s)  echo "Enter a file name to save data in it:"
        read save_file
        for ((j=0;j<=$num_rows;j++)) do
            for ((i=1;i<=$num_columns;i++)) do
                printf  ${data[$j,$i]}';' >> $save_file      #save by print the values in the file
            done
            printf '\n' >> $save_file
        done
        save_flag=1;;
        
    esac
done  

