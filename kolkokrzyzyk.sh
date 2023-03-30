#!/bin/bash

GRACZ1=1
GRACZ2=2
graczBiezacy=$GRACZ1

tablica=(0 0 0 0 0 0 0 0 0)

graKomputer=false
graSkonczona=false

function pokazInstrukcje() {
  for i in {0..8}; do
    echo -e $i "\c"
    if [[ $(expr $(($i + 1)) % 3) == 0 ]]; then
      echo
    else
      echo -e "| \c"
    fi
  done
  echo
}

function skonczGre() {
  if [[ $graKomputer == true ]] && [[ $graczBiezacy == "$GRACZ2" ]]; then
    echo "Wygrał komputer !"
  else
    echo "Wygrał gracz nr: ${graczBiezacy} !"
  fi

  graSkonczona=true
}

function pokazKomorke() {
  if [[ ${tablica[$1]} == $GRACZ1 ]]; then
    echo -e "X \c"
  elif [[ ${tablica[$1]} == $GRACZ2 ]]; then
    echo -e "O \c"
  else
    echo -e "  \c"
  fi
}

function pokazTablice() {
  clear
  for i in {0..8}; do
    pokazKomorke $i
    if [[ $(expr $(($i + 1)) % 3) == 0 ]]; then
      echo
    else
      echo -e " | \c"
    fi
  done
}

function zapiszGre() {
  printf "%s " "${tablica[@]}" >rozgrywka.txt
  echo $graczBiezacy >>rozgrywka.txt

  graSkonczona=true
}

function wczytajGre() {
  array=($(head -n 1 rozgrywka.txt))

  for i in {0..8}; do
    echo -e ${array[$i]}
    case "${array[$i]}" in
    "0") tablica[$i]=0 ;;
    "1") tablica[$i]=1 ;;
    "2") tablica[$i]=2 ;;
    esac
    graczBiezacy=${array[9]}
  done
}

function sprawdzCzyGraSkonczona() {
  for ((i = 0; i <= 6; i = i + 3)); do
    if [ ${tablica[$i]} == $graczBiezacy ] && [ ${tablica[$i + 1]} == $graczBiezacy ] && [ ${tablica[$i + 2]} == $graczBiezacy ]; then
      skonczGre
      return
    fi
  done

  for ((i = 0; i <= 2; i++)); do
    if [ ${tablica[$i]} == $graczBiezacy ] && [ ${tablica[$i + 3]} == $graczBiezacy ] && [ ${tablica[$i + 6]} == $graczBiezacy ]; then
      skonczGre
      return
    fi
  done

  if [ ${tablica[0]} == $graczBiezacy ] && [ ${tablica[4]} == $graczBiezacy ] && [ ${tablica[8]} == $graczBiezacy ]; then
    skonczGre
    return

  fi

  if [ ${tablica[2]} == $graczBiezacy ] && [ ${tablica[4]} == $graczBiezacy ] && [ ${tablica[6]} == $graczBiezacy ]; then
    skonczGre
    return
  fi

  tablicaPelna=true
  
  for i in {0..8}; do
    if [ ${tablica[$i]} == 0 ]; then
      tablicaPelna=false
      break
    fi
  done

  if [ $tablicaPelna == true ]; then
    echo 'Remis !'
    graSkonczona=true
  fi
}

function zmienGracza() {
  if [ $graczBiezacy == $GRACZ1 ]; then
    graczBiezacy=$GRACZ2
  else
    graczBiezacy=$GRACZ1
  fi
}

function wczytajRuch() {
  while true; do

    if [[ $graKomputer == true ]] && [[ $graczBiezacy == "$GRACZ2" ]]; then
      echo "Kolej komputera !"
      pos=$((($RANDOM % 8)))
      while [ ${tablica[$pos]} != 0 ]; do
        pos=$((($RANDOM % 8)))
      done

      tablica[$pos]=$graczBiezacy
      break
    else
      echo "Kolej gracza: ${graczBiezacy} !"
      read pos
    fi

    if [[ $pos == 'z' ]]; then
      zapiszGre
      break
    fi

    if [[ $pos == 'w' ]]; then
      wczytajGre
      clear
      pokazTablice
      echo "Kolej gracza: ${graczBiezacy} !"
      read pos
    fi

    if [[ $pos == ?(-)+([0-9]) ]] && [ $pos -ge 0 ] && [ $pos -le 8 ] && [ ${tablica[$pos]} == 0 ]; then
      tablica[$pos]=$graczBiezacy
      break
    fi
    echo "Wprowadż poprawny numer pola."
  done
}

pokazInfo() {
  clear
  echo -e "Aby wybrać komórke użyj cyfr od 0 do 8 jak poniżej:\n"
  pokazInstrukcje
  echo -e "Zapisz gre klikajac klawisz 'z', a wczytaj ja za pomoca klawisza 'w'  \n\n"
}

wybierzTryb() {
  echo "Wybierz tryb rozgrywki :"
  echo "1) gra w parze"
  echo "2) gra z komputerem"
  read type
  case $type in
  "1") graKomputer=false ;;
  "2") graKomputer=true ;;
  esac
}

pokazInfo
wybierzTryb
while [ $graSkonczona == false ]; do
  wczytajRuch
  pokazTablice
  sprawdzCzyGraSkonczona
  zmienGracza
done
