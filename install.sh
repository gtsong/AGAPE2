#!/bin/bash
# Sometimes error happens due to updated version of programs.
# check error and change program version.

sudo dpkg --add-architecture i386

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt-get install -y cpanminus
sudo apt-get install -y unzip
sudo apt-get install -y g++
sudo apt-get install -y make
sudo apt-get install -y python-pip
sudo apt-get install -y python-biopython
sudo apt-get install -y python-setuptools
pip install --upgrade pip

sudo cpanm -n local::lib
sudo cpanm -n DBI
sudo cpanm -n DBD::SQLite
sudo cpanm -n forks
sudo cpanm -n forks::shared
sudo cpanm -n File::Which
sudo cpanm -n Perl::Unsafe::Signals
sudo cpanm -n Bit::Vector
sudo cpanm -n Inline::C
sudo cpanm -n IO::All
sudo cpanm -n IO::Prompt
sudo cpanm -n DBD::Pg
sudo cpanm -n Bio::SeqIO
sudo cpanm -n Text::Soundex
sudo cpanm -n LWP::Simple

sudo apt-get install -y abyss
sudo apt-get install -y bwa
sudo apt-get install -y libsparsehash-dev
sudo apt-get install -y cmake
sudo apt-get install -y bamtools
sudo apt-get install -y bedtools
sudo apt-get install -y samtools
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y automake
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y ncbi-blast+
sudo apt-get install -y cd-hit
sudo apt-get install -y exonerate
sudo apt-get install -y snap

sudo apt-get install -y libpq-dev
sudo apt-get install -y libdbd-pg-perl
sudo apt-get install -y postgresql
sudo apt-get install -y dos2unix

wget http://hgwdev.cse.ucsc.edu/~kent/exe/linux/axtChainNet.zip
wget http://bioinf.uni-greifswald.de/augustus/binaries/augustus.current.tar.gz
wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/rmblast/2.2.28/ncbi-rmblastn-2.2.28-x64-linux.tar.gz
wget http://tandem.bu.edu/trf/downloads/trf409.linux64
wget http://yandell.topaz.genetics.utah.edu/maker_downloads/1726/7524/8A1A/D9715052FF2398BC5D70137483B6/maker-2.31.9.tgz

git clone https://github.com/jts/sga.git
git clone https://github.com/kuleshov/nanoscope.git
git clone https://github.com/hyphaltip/thesis.git
git clone https://github.com/adamlabadorf/ucsc_tools.git
git clone https://github.com/chapmanb/bcbb.git
git clone https://github.com/tanghaibao/quota-alignment.git

mv -f quota-alignment/ programs
mv programs/*.py programs/quota-alignment/scripts/

cd bcbb/gff
python setup.py build
sudo python setup.py install
cd ../..
mv -f bcbb programs

# sga
mv -f sga programs/sga

# axtChainNet
unzip axtChainNet.zip -d axtChainNet
mv -f axtChainNet programs/axtChainNet

# faSize
mv -f ucsc_tools/executables/faSize programs/axtChainNet

# genemark
tar xvzf download/gm_et_linux_64.tar.gz
cp gm_et_linux_64/gmes_petap/gm_key ~/.gm_key
mv gm_et_linux_64 programs/gm_et_linux_64

# gmhmmp & gmsn.pl
mv -f nanoscope/sw/src/quast-2.3/libs/genemark/linux_64/gmhmmp programs/gm_et_linux_64/gmes_petap
mv -f nanoscope/sw/src/quast-2.3/libs/genemark/linux_64/gmsn.pl programs/gm_et_linux_64/gmes_petap

# gff2zff.pl
chmod 775 thesis/src/gene_prediction/gff2zff.pl
sudo cp thesis/src/gene_prediction/gff2zff.pl /usr/bin

# rmblast
tar zxvf ncbi-rmblastn-2.2.28-x64-linux.tar.gz
chmod 775 ncbi-rmblastn-2.2.28/bin/rmblastn
sudo cp ncbi-rmblastn-2.2.28/bin/rmblastn /usr/bin

# RepeatMasker
tar xvzf RepeatMasker-open-4-0-7.tar.gz
sudo cp -r RepeatMasker /usr/local/RepeatMasker
mv -f RepeatMasker programs/RepeatMasker

# trf
chmod a+x trf409.linux64
sudo ln -s trf409.linux64 /usr/local/RepeatMasker
sudo mv -f trf409.linux64 /usr/local/bin

# augustus
tar xvzf augustus.current.tar.gz
cd augustus-3.3.1
make
cd src
make
cd ../..
mv -f augustus-3.3.1 programs/augustus

# maker
tar xvzf maker-2.31.9.tgz
cd maker/src
perl ./Build.PL
./Build installdeps # enter Yes at local installation
./Build install
cd ../..
mv -f maker programs/maker

mv -f GeneMark_hmm.mod programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod

chmod 775 configs.cf
chmod 775 cfg_files/maker_exe.ctl
chmod 775 programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod
chmod 775 cfg_files/*
chmod 775 src/utils/*

dos2unix agape_annot.sh
dos2unix combined_annot.sh
dos2unix final_annot.sh
dos2unix intervals.sh
dos2unix non_ref.sh
dos2unix run_comb_annot.sh

rm -f axtChainNet.zip augustus.current.tar.gz RepeatMasker-open-4-0-7.tar.gz ncbi-rmblastn-2.2.28-x64-linux.tar.gz maker-2.31.9.tgz
rm -rf nanoscope thesis ncbi-rmblastn-2.2.28 ucsc_tools
rm -f install.shg
rm -rf download
