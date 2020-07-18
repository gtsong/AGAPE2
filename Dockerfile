############################################################
# Dockerfile for AGAPE2 pipeline
# Based on Ubuntu 16.04
############################################################

# Set the base image to Ubuntu 16.04
#FROM ubuntu:16.04
FROM ubuntu@sha256:e4a134999bea4abb4a27bc437e6118fdddfb172e1b9d683129b74d254af51675

# File Author / Maintainer
MAINTAINER Ho Yong Lee

# Update the repository sources list
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get dist-upgrade -y && apt-get upgrade
RUN apt-get install -y libc6:i386 libc6:i386 libncurses5:i386 libstdc++6:i386
RUN apt-get install -y libncurses5-dev \
    build-essential \
    cpanminus \
    unzip \
    g++ \
    make \
    python-pip \
    libpq-dev \
    libdbd-pg-perl \
    libghc-bzlib-dev \
    pkg-config \
    postgresql \
    perl \
    expect \
    git \
    vim

RUN pip install --upgrade pip
RUN pip install biopython bcbio-gff

RUN cpanm -n local::lib \
    DBI \
    DBD::SQLite \
    Test::Simple \
    DBD::Pg \
    forks \
    forks::shared \
    File::Which \
    Perl::Unsafe::Signals \
    Bit::Vector \
    Inline::C \
    IO::All \
    IO::Prompt \
    Bio::SeqIO \
    Text::Soundex \
    LWP::Simple

RUN apt-get install -y abyss \
    bwa \
    libsparsehash-dev \
    cmake \
    bamtools libbamtools-dev \
    bedtools \
    samtools \
    zlib1g-dev \
    automake \
    libboost-all-dev \
    ncbi-blast+ \
    cd-hit \
    exonerate \
    snap \
    dos2unix \
    wget \
    libcurl4-openssl-dev

RUN cd /home && git clone https://github.com/gtsong/AGAPE2.git

#quota-alignment
RUN cd /home/AGAPE2 && git clone https://github.com/tanghaibao/quota-alignment.git && mv -f /home/AGAPE2/quota-alignment/ /home/AGAPE2/programs && mv /home/AGAPE2/programs/*.py /home/AGAPE2/programs/quota-alignment/scripts/

#bcbb
RUN cd /home/AGAPE2 && git clone https://github.com/chapmanb/bcbb.git && cd /home/AGAPE2/bcbb/gff && python setup.py build && python setup.py install && mv -f /home/AGAPE2/bcbb /home/AGAPE2/programs

#bamtools
RUN cd /home/AGAPE2 && git clone https://github.com/pezmaster31/bamtools.git && cd /home/AGAPE2/bamtools && mkdir build && cd build && cmake .. && make && make install && mv -f /home/AGAPE2/bamtools /home/AGAPE2/programs/bamtools

#sga
RUN cd /home/AGAPE2 && git clone https://github.com/jts/sga.git && cd /home/AGAPE2/sga/src && bash autogen.sh && ./configure --with-bamtools=/usr/local && make && make install && mv -f /home/AGAPE2/sga /home/AGAPE2/programs/sga

#axtChainNet
RUN cd /home/AGAPE2 && wget http://hgwdev.cse.ucsc.edu/~kent/exe/linux/axtChainNet.zip && unzip /home/AGAPE2/axtChainNet.zip -d axtChainNet && mv -f /home/AGAPE2/axtChainNet /home/AGAPE2/programs/axtChainNet

#faSize
RUN cd /home/AGAPE2 && git clone https://github.com/adamlabadorf/ucsc_tools.git && mv -f /home/AGAPE2/ucsc_tools/executables/faSize /home/AGAPE2/programs/axtChainNet

#genemark
RUN cd /home/AGAPE2/download && tar xvzf /home/AGAPE2/download/gm_et_linux_64.tar.gz && cp /home/AGAPE2/download/gm_et_linux_64/gmes_petap/gm_key /home/AGAPE2/.gm_key && mv /home/AGAPE2/download/gm_et_linux_64 /home/AGAPE2/programs/gm_et_linux_64

#gmhmmp & gmsn.pl
RUN cd /home/AGAPE2 && git clone https://github.com/kuleshov/nanoscope.git
RUN mv -f /home/AGAPE2/nanoscope/sw/src/quast-2.3/libs/genemark/linux_64/gmhmmp /home/AGAPE2/programs/gm_et_linux_64/gmes_petap && mv -f /home/AGAPE2/nanoscope/sw/src/quast-2.3/libs/genemark/linux_64/gmsn.pl /home/AGAPE2/programs/gm_et_linux_64/gmes_petap

#gff2zff.pl
RUN cd /home/AGAPE2 && git clone https://github.com/hyphaltip/thesis.git && chmod 755 /home/AGAPE2/thesis/src/gene_prediction/gff2zff.pl && cp /home/AGAPE2/thesis/src/gene_prediction/gff2zff.pl /usr/bin

#rmblast
RUN cd /home/AGAPE2 && wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/rmblast/2.2.28/ncbi-rmblastn-2.2.28-x64-linux.tar.gz && tar zxvf /home/AGAPE2/ncbi-rmblastn-2.2.28-x64-linux.tar.gz && chmod 755 /home/AGAPE2/ncbi-rmblastn-2.2.28/bin/rmblastn && cp /home/AGAPE2/ncbi-rmblastn-2.2.28/bin/rmblastn /usr/bin

#trf
RUN cd /home/AGAPE2 && wget http://tandem.bu.edu/trf/downloads/trf409.linux64 && chmod a+x /home/AGAPE2/trf409.linux64 && mv -f /home/AGAPE2/trf409.linux64 /usr/local/bin

# libbzip2, liblzma, zlib installation (htslib dependency)
RUN cd /home/AGAPE2 && git clone https://github.com/WardF/libbzip2.git && cd /home/AGAPE2/libbzip2 && make install && mv -f /home/AGAPE2/libbzip2 /home/AGAPE2/programs/libbzip2
RUN cd /home/AGAPE2 && git clone https://github.com/kobolabs/liblzma.git && cd /home/AGAPE2/liblzma && ./configure && make && make install && mv -f /home/AGAPE2/liblzma /home/AGAPE2/programs/liblzma
RUN cd /home/AGAPE2 && git clone https://github.com/madler/zlib.git && cd /home/AGAPE2/zlib && ./configure && make test && make install && mv -f /home/AGAPE2/zlib /home/AGAPE2/programs/zlib

#htslib-1.3
RUN cd /home/AGAPE2 && wget https://github.com/samtools/htslib/releases/download/1.3/htslib-1.3.tar.bz2 && tar -xjvf /home/AGAPE2/htslib-1.3.tar.bz2 && cd /home/AGAPE2/htslib-1.3 && autoheader && autoconf -Wno-syntax && bash configure && make && make install && mv -f /home/AGAPE2/htslib-1.3 /home/AGAPE2/programs/htslib-1.3
#bcftools-1.3
RUN cd /home/AGAPE2 && wget https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2 && tar -xjvf /home/AGAPE2/bcftools-1.3.tar.bz2 && cd /home/AGAPE2/bcftools-1.3 && make && make install && mv -f /home/AGAPE2/bcftools-1.3 /home/AGAPE2/programs/bcftools-1.3
#samtools-1.3
RUN cd /home/AGAPE2 && wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2 && tar -xjvf /home/AGAPE2/samtools-1.3.tar.bz2 && cd /home/AGAPE2/samtools-1.3 && autoheader && autoconf -Wno-syntax && bash configure && make && make install && mv -f /home/AGAPE2/samtools-1.3 /home/AGAPE2/programs/samtools-1.3

#Augustus
RUN apt-get install -y libmysql++-dev libsqlite3-dev libgsl-dev libsuitesparse-dev liblpsolve55-dev
RUN cd /home/AGAPE2 && git clone https://github.com/Gaius-Augustus/Augustus.git && \
    sed -i '10 a BAMTOOLS=/usr/local' /home/AGAPE2/Augustus/auxprogs/bam2hints/Makefile && \
    sed -i '12 s/\/usr/$(BAMTOOLS)/g' /home/AGAPE2/Augustus/auxprogs/bam2hints/Makefile && \
    sed -i '13 s/-lbamtools -lz/$(BAMTOOLS)\/lib\/libbamtools.a -lz/g' /home/AGAPE2/Augustus/auxprogs/bam2hints/Makefile && \
    sed -i '11 s/include\/bamtools/local/g' /home/AGAPE2/Augustus/auxprogs/filterBam/src/Makefile && \
    sed -i '12 s/-I$(BAMTOOLS)/-I$(BAMTOOLS)\/include\/bamtools/g' /home/AGAPE2/Augustus/auxprogs/filterBam/src/Makefile && \
    sed -i '13 s/-lbamtools -lz/$(BAMTOOLS)\/lib\/libbamtools.a -lz/g' /home/AGAPE2/Augustus/auxprogs/filterBam/src/Makefile && \
    sed -i '10 s/$(HOME)\/tools/\/home\/AGAPE2\/programs/g' /home/AGAPE2/Augustus/auxprogs/bam2wig/Makefile && \
    sed -i '18 s/samtools/samtools-1.3/g' /home/AGAPE2/Augustus/auxprogs/bam2wig/Makefile && \
    sed -i '19 s/htslib/htslib-1.3/g' /home/AGAPE2/Augustus/auxprogs/bam2wig/Makefile

RUN cd /home/AGAPE2/Augustus && make && cd src && make && cd .. && make install && mv -f /home/AGAPE2/Augustus /home/AGAPE2/programs/augustus

#RepeatMasker
RUN export TERM=xterm
RUN cd /home/AGAPE2 && wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz && tar xvzf /home/AGAPE2/RepeatMasker-open-4-0-7.tar.gz && cp -r /home/AGAPE2/RepeatMasker /usr/local/RepeatMasker && cd /home/AGAPE2/RepeatMasker && mv /home/AGAPE2/AutomakeRepeat.sh . && bash AutomakeRepeat.sh &&  mv -f /home/AGAPE2/RepeatMasker /home/AGAPE2/programs/RepeatMasker

# maker
RUN cd /home/AGAPE2 && wget http://yandell.topaz.genetics.utah.edu/maker_downloads/1726/7524/8A1A/D9715052FF2398BC5D70137483B6/maker-2.31.9.tgz && tar xvzf /home/AGAPE2/maker-2.31.9.tgz && cd /home/AGAPE2/maker/src && perl ./Build.PL && ./Build installdeps && ./Build install && mv -f /home/AGAPE2/maker /home/AGAPE2/programs/maker

RUN mv -f /home/AGAPE2/GeneMark_hmm.mod /home/AGAPE2/programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod

#AGAPE/src installation
RUN sed -i '31 s/-Werror //g' /home/AGAPE2/src/lastz/src/Makefile && cd /home/AGAPE2/src && make

RUN chmod 775 /home/AGAPE2/configs.cf
RUN chmod 775 /home/AGAPE2/cfg_files/maker_exe.ctl && chmod 775 /home/AGAPE2/programs/gm_et_linux_64/gmes_petap/GeneMark_hmm.mod && chmod 775 /home/AGAPE2/cfg_files/* && chmod 775 /home/AGAPE2/src/utils/*
RUN dos2unix /home/AGAPE2/agape_annot.sh && dos2unix /home/AGAPE2/combined_annot.sh && dos2unix /home/AGAPE2/final_annot.sh && dos2unix /home/AGAPE2/intervals.sh && dos2unix /home/AGAPE2/run_comb_annot.sh
RUN cd /home/AGAPE2 && rm -f axtChainNet.zip augustus.current.tar.gz RepeatMasker-open-4-0-7.tar.gz ncbi-rmblastn-2.2.28-x64-linux.tar.gz maker-2.31.9.tgz && rm -rf nanoscope thesis ncbi-rmblastn-2.2.28 ucsc_tools && \
    rm -f install.shg bcftools-1.3.tar.bz2 htslib-1.3.tar.bz2 samtools-1.3.tar.bz2 && cd /home/AGAPE2 && rm -rf download

RUN sed -i 's/home\/ubuntu/home/g' /home/AGAPE2/configs.cf /home/AGAPE2/cfg_files/maker_exe.ctl
