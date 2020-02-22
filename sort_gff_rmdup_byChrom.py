#!/usr/bin/env python
import sys
import os

def sort_gff(gff_file):
    fp = open(gff_file,'r')
    sorted_gff, tmp_chr, chr_name = [], [], ''
    for line in fp:
        gff_list = line.replace('\n','')
        li = gff_list.split(' ')
        if chr_name != li[0] and len(tmp_chr) != 0:
            gff_sorted = sorted( [ i for i in tmp_chr], key=lambda x: int(x.split(' ')[3]))
            sorted_gff.append(gff_sorted)
            tmp_chr = []
        chr_name = li[0]
        tmp_chr.append(gff_list)
    gff_sorted = sorted( [ i for i in tmp_chr], key=lambda x: int(x.split(' ')[3]))
    sorted_gff.append(gff_sorted)

    return sorted_gff


def rm_dup(name):
    fp = open(name,'r')
    old, dupList = 0, []
    for line in fp:
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

    f1 = open(name, 'r')
    f2 = open(name+'.rmdup', 'w')
    gff_list, cnt, fflag, ffflag = [], 0, False, False
    if len(dupList) == 0:
        for line in f1:
            f2.write(line)
            gff_list.append(line)
    else:
        for line in f1:
            li = line.replace('\n','').split(' ')
            val = dupList[cnt] if cnt < len(dupList) else dupList[len(dupList)-1]
            if li[3] == val[3]:
                if fflag is False:
                    if li[8] == dupList[cnt][8]:
                        f2.write(line)
                        gff_list.append(line)
                        fflag = True
                else:
                    if ffflag is False:
                        f2.write(line)
                        gff_list.append(line)
                        ffflag = True
            else:
                if fflag and ffflag:
                    cnt+=1
                    fflag = False
                    ffflag = False
                f2.write(line)
                gff_list.append(line)
    f1.close()
    f2.close()
    return gff_list

def write_gff_with_rm_dup(all_data,gff_file):
    fp_sort = open(gff_file+".sorted",'a')
    fp_rmdup = open(gff_file+".sorted.rmdup",'a')
    fp_name = open(gff_file+".scfname",'w')
    for li in all_data:
        scf = li[0].split(' ')[0]
        name = scf+".gff.sorted"
        fp = open(name, 'w')
        for t in li:
            fp.write(t+"\n")
            fp_sort.write(t+"\n")
        fp.close()

        return_gff = rm_dup(name)
        for i in return_gff:
            fp_rmdup.write(i)
        fp_name.write(scf+"\n")

    fp_rmdup.close()
    fp_sort.close()
    fp_name.close()
def main(gff_file):
    sorted_gff = sort_gff(gff_file)
    write_gff_with_rm_dup(sorted_gff, gff_file)

if __name__ == '__main__':
    gff_file = sys.argv[1]
    os.system('mkdir temp')
    os.chdir('temp')
    main(gff_file)
