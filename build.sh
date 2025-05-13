#filein=$1
#filename=${filein%.*}
filename=$1
db_run=$2
echo $filename
echo $filename".asm"
nasm -f elf32 -g -F dwarf -o $(echo $filename".o") $(echo $filename".asm")
ld -m elf_i386 -o $filename $(echo $filename".o")

if [ "$db_run" = "run" ]; then
  echo "executing..."
  ./$filename
elif [ "$db_run" = "db" ]; then
  echo "debug..."
  gdb ./$filename
fi
