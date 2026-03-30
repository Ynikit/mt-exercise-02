#!/bin/bash

scripts=$(dirname "$0")
base=$scripts/..

data=$base/data

mkdir -p $data

tools=$base/tools

# link default training data for easier access

mkdir -p $data/wikitext-2

for corpus in train valid test; do
    absolute_path=$(realpath $tools/pytorch-examples/word_language_model/data/wikitext-2/$corpus.txt)
    ln -snf $absolute_path $data/wikitext-2/$corpus.txt
done

# download Wuthering Heights, Jane Eyre, Anne Grey and combine into one file

mkdir -p $data/classics/raw

wget -O $data/classics/raw/wuthering_heights.txt https://www.gutenberg.org/files/768/768-0.txt
wget -O $data/classics/raw/jane_eyre.txt https://www.gutenberg.org/files/1260/1260-0.txt
wget -O $data/classics/raw/anne_grey.txt https://www.gutenberg.org/files/1215/1215-0.txt

cat $data/classics/raw/wuthering_heights.txt \
    $data/classics/raw/jane_eyre.txt \
    $data/classics/raw/anne_grey.txt > $data/classics/raw/combined.txt

# preprocess slightly

cat $data/classics/raw/combined.txt | python $base/scripts/preprocess_raw.py > $data/classics/raw/combined.cleaned.txt

# tokenize, fix vocabulary upper bound

cat $data/classics/raw/combined.cleaned.txt | python $base/scripts/preprocess.py --vocab-size 5000 --tokenize --lang "en" --sent-tokenize > \
    $data/classics/raw/combined.preprocessed.txt

# split into train, valid and test

head -n 500 $data/classics/raw/combined.preprocessed.txt | tail -n 400 > $data/classics/valid.txt
head -n 1000 $data/classics/raw/combined.preprocessed.txt | tail -n 400 > $data/classics/test.txt
tail -n 3000 $data/classics/raw/combined.preprocessed.txt | head -n 2600 > $data/classics/train.txt
