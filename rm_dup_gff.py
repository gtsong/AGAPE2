#!/usr/bin/env python
import sys

def main(gff_file):
    f1 = open(gff_file,'r')
    old = 0
    dupList = []
    for line in f1:
        li = line.replace('\n','').split(' ')
        if old == 0:
            old = li
            continue
        if li[2] != 'gene':
            continue
        if old[3] == li[3]:
            val =  dupList[-1] if len(dupList) != 0 else ['0','0','0','0','0','0','0','0','0']
            val1,val2,val3 = val[3],val[4],val[8]
            if li[8] != 'UNDEF':
                if li[3] != val[3] and li[4] != val[4] and li[8] != val3:
                   dupList.append(li)
            else:
                if old[3] != val[3] and old[4] != val[4] and old[8] != val3:
                    dupList.append(old)
        if li[2] == 'gene':
            old = li

    f2 = open(gff_file, 'r')
    f3 = open(gff_file+'.rmdup', 'w')
    cnt = 0
    fflag = False
    ffflag = False
    for line in f2:
        li = line.replace('\n','').split(' ')
        val = dupList[cnt] if cnt < len(dupList) else dupList[len(dupList)-1]
        if li[3] == val[3]:
            if fflag is False:
                if li[8] == dupList[cnt][8]:
                    f3.write(line)
                    fflag = True
            else:
                if ffflag is False:
                    f3.write(line)
                    ffflag = True
        else:
            if fflag and ffflag:
                cnt+=1
                fflag = False
                ffflag = False
            f3.write(line)

    f1.close()
    f2.close()
    f3.close()

if __name__ == '__main__':
    gff_file = sys.argv[1]
    main(gff_file)
