#!/usr/bin/env bash
src="pagerank-openmp-dynamic"
out="$HOME/Logs/$src$1.log"
ulimit -s unlimited
printf "" > "$out"

# Download program
if [[ "$DOWNLOAD" != "0" ]]; then
  rm -rf $src
  git clone https://github.com/puzzlef/$src
  cd $src
  git checkout measure-temporal
fi

# Fixed config
: "${TYPE:=double}"
: "${MAX_THREADS:=64}"
: "${REPEAT_BATCH:=1}"
: "${REPEAT_METHOD:=1}"
# Parameter sweep for batch (randomly generated)
: "${BATCH_UNIT:=%}"
: "${BATCH_LENGTH:=100}"
# Define macros (dont forget to add here)
DEFINES=(""
"-DTYPE=$TYPE"
"-DMAX_THREADS=$MAX_THREADS"
"-DREPEAT_BATCH=$REPEAT_BATCH"
"-DREPEAT_METHOD=$REPEAT_METHOD"
"-DBATCH_UNIT=\"$BATCH_UNIT\""
"-DBATCH_LENGTH=$BATCH_LENGTH"
)

# Run
g++ ${DEFINES[*]} -std=c++17 -O3 -fopenmp main.cxx
stdbuf --output=L ./a.out ~/Data/sx-mathoverflow.txt    248180   506550   239978   2>&1 | tee -a "$out"
stdbuf --output=L ./a.out ~/Data/sx-askubuntu.txt       1593160  964437   596933   2>&1 | tee -a "$out"
stdbuf --output=L ./a.out ~/Data/sx-superuser.txt       1940850  1443339  924886   2>&1 | tee -a "$out"
stdbuf --output=L ./a.out ~/Data/wiki-talk-temporal.txt 11401490 7833140  3309592  2>&1 | tee -a "$out"
stdbuf --output=L ./a.out ~/Data/sx-stackoverflow.txt   26019770 63497050 36233450 2>&1 | tee -a "$out"

# Signal completion
curl -X POST "https://maker.ifttt.com/trigger/puzzlef/with/key/${IFTTT_KEY}?value1=$src$1"
