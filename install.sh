#!/bin/bash
# Sometimes error happens due to updated version of programs and changed directory.
# check error and change program version.
sudo dpkg --add-architecture i386

sudo apt-get update -y
sudo apt-get dist-upgrade -y

sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt-get install -y cpanminus
sudo apt-get install -y unzip
sudo apt-get install -y g++
sudo apt-get install -y make
sudo apt-get install -y wget
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
sudo cpanm -n Bio::SeqIO
sudo cpanm -n Text::Soundex
sudo cpanm -n LWP::Simple
sudo cpanm -n DBD::Pg

sudo apt-get install -y abyss
sudo apt-get install -y bwa
sudo apt-get install -y libsparsehash-dev
sudo apt-get install -y cmake
sudo apt-get install -y bedtools
sudo apt-get install -y libncurses5-dev libncursesw5-dev
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y automake
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y ncbi-blast+
sudo apt-get install -y cd-hit
sudo apt-get install -y exonerate
sudo apt-get install -y snap
sudo apt-get install -y libjsoncpp-dev
sudo apt-get install -y libpq-dev
sudo apt-get install -y libdbd-pg-perl
sudo apt-get install -y postgresql
sudo apt-get install -y dos2unix
sudo apt-get install -y expect

wget http://hgwdev.cse.ucsc.edu/~kent/exe/linux/axtChainNet.zip
wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/rmblast/2.2.28/ncbi-rmblastn-2.2.28-x64-linux.tar.gz
wget http://tandem.bu.edu/trf/downloads/trf409.linux64
wget http://yandell.topaz.genetics.utah.edu/maker_downloads/1726/7524/8A1A/D9715052FF2398BC5D70137483B6/maker-2.31.9.tgz
wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
wget https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
wget https://github.com/samtools/htslib/releases/download/1.3/htslib-1.3.tar.bz2

git clone https://github.com/jts/sga.git
git clone https://github.com/kuleshov/nanoscope.git
git clone https://github.com/hyphaltip/thesis.git
git clone https://github.com/adamlabadorf/ucsc_tools.git
git clone https://github.com/chapmanb/bcbb.git
git clone https://github.com/tanghaibao/quota-alignment.git
git clone https://github.com/pezmaster31/bamtools.git
git clone https://github.com/madler/zlib.git
git clone https://github.com/WardF/libbzip2.git
git clone https://github.com/kobolabs/liblzma.git
git clone https://github.com/Gaius-Augustus/Augustus.git

mv -f quota-alignment/ programs
mv programs/*.py programs/quota-alignment/scripts/

# NOTE
# All installation is executed in AGAPE2 folder and moved to other directory.
# If want to move your directory, you have to change dircetory yourself.

#bcbb installation
cd bcbb/gff
python setup.py build
sudo python setup.py install
cd ../..
mv -f bcbb programs

#bamtools installation
cd bamtools
mkdir build
cd build
cmake ..
make 
sudo make install
cd ../..
mv -f bamtools programs/bamtools

# sga installation
cd sga/src
sudo ./autogen.sh
./configure --with-bamtools=/usr/local
make
sudo make install
cd ../..
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

# trf
chmod a+x trf409.linux64
sudo ln -s trf409.linux64 /usr/local/RepeatMasker
sudo mv -f trf409.linux64 /usr/local/bin

# libbzip2, liblzma, zlib installation (htslib dependency)
cd libbzip2
sudo make install
cd ..
mv -f libbzip2 programs/libbzip2

cd liblzma
./configure
make
sudo make install
cd ..
mv -f liblzma programs/liblzma

cd zlib
./configure
make test
sudo make install
cd ..
mv -f zlib programs/zlib

#htslib-1.3 installation
tar -xjvf htslib-1.3.tar.bz2
cd htslib-1.3
autoheader
autoconf
./configure
make
sudo make install
cd ..
mv -f htslib-1.3 programs/htslib-1.3

#bcftools-1.3 installation
tar -xjvf bcftools-1.3.tar.bz2
cd bcftools-1.3
make
sudo make install
cd ..
mv -f bcftools-1.3 programs/bcftools-1.3

#samtools-1.3 installation
tar -xjvf samtools-1.3.tar.bz2
cd samtools-1.3
autoheader                 
autoconf -Wno-syntax 
./configure           
make
sudo make install
cd ..
mv -f samtools-1.3 programs/samtools-1.3

# augustus (before running, you have to change three Makefiles. you should change it if directory does not matched )
sed -i '10 a BAMTOOLS=/usr/local' Augustus/auxprogs/bam2hints/Makefile
sed -i '12 s/\/usr/$(BAMTOOLS)/g' Augustus/auxprogs/bam2hints/Makefile
sed -i '13 s/-lbamtools -lz/$(BAMTOOLS)\/lib\/libbamtools.a -lz/g' Augustus/auxprogs/bam2hints/Makefile

sed -i '11 s/include\/bamtools/local/g' Augustus/auxprogs/filterBam/src/Makefile
sed -i '12 s/-I$(BAMTOOLS)/-I$(BAMTOOLS)\/include\/bamtools/g' Augustus/auxprogs/filterBam/src/Makefile
sed -i '13 s/-lbamtools -lz/$(BAMTOOLS)\/lib\/libbamtools.a -lz/g' Augustus/auxprogs/filterBam/src/Makefile

sed -i '10 s/$(HOME)\/tools/\/home\/ubuntu\/AGAPE2\/programs/g' Augustus/auxprogs/bam2wig/Makefile
sed -i '18 s/samtools/samtools-1.3/g' Augustus/auxprogs/bam2wig/Makefile
sed -i '19 s/htslib/htslib-1.3/g' Augustus/auxprogs/bam2wig/Makefile

cd Augustus
make
cd src
make
cd ..
sudo make install
cd ..
mv -f Augustus programs/augustus

# RepeatMasker installation
# Check INSTALL file to complete installation
tar xvzf RepeatMasker-open-4-0-7.tar.gz
sudo cp -r RepeatMasker /usr/local/RepeatMasker
cd RepeatMasker
perl ./configure <<END_OF_RESPONSES



/usr/local/bin/trf409.linux64
2
/usr/bin
Y
5
END_OF_RESPONSES
cd ..
mv -f RepeatMasker programs/RepeatMasker

# maker [Error happen, but doesn't matter]
tar xvzf maker-2.31.9.tgz
cd maker/src
perl ./Build.PL
./Build installdeps # enter Yes at local installation
./Build install
cd ../..
mv -f maker programs/maker

mv -f GeneMark_hmm.mod programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod

#AGAPE/src installation
sed -i '31 s/-Werror //g' src/lastz/src/Makefile
cd src
make
cd ..

chmod 775 configs.cf
chmod 775 cfg_files/maker_exe.ctl
chmod 775 programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod
chmod 775 cfg_files/*
chmod 775 src/utils/*

dos2unix agape_annot.sh
dos2unix combined_annot.sh
dos2unix final_annot.sh
dos2unix intervals.sh
dos2unix run_comb_annot.sh

rm -f axtChainNet.zip augustus.current.tar.gz RepeatMasker-open-4-0-7.tar.gz ncbi-rmblastn-2.2.28-x64-linux.tar.gz maker-2.31.9.tgz
rm -rf nanoscope thesis ncbi-rmblastn-2.2.28 ucsc_tools 
rm -f install.shg bcftools-1.3.tar.bz2 htslib-1.3.tar.bz2 samtools-1.3.tar.bz2
rm -rf download
