IN_FILE=$1
OUT_FILE="${IN_FILE%%.*}".kso
LD_FLAGS="-nostdlib -ffreestanding"

if [ ! -f $IN_FILE ]; then
    echo "File not found!"
    exit -1
fi

ld $LD_FLAGS -shared -o $OUT_FILE $IN_FILE
python genLinker.py $OUT_FILE
ld $LD_FLAGS -shared -o $OUT_FILE $IN_FILE -T linkerscript.ld

# Generate objdump and readelf
readelf -a $OUT_FILE > readelf.txt
objdump -lSd $OUT_FILE  > objdump.txt

# Verify correctness
python genLinker.py -v $OUT_FILE || (echo "ERROR" && exit -1)