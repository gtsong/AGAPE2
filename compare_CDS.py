#!/usr/bin/env python
import sys
from functools import reduce

PLUS_START_CODON, MINUS_START_CODON = "ATG", "CAT"

scf_list=[]

def checkIndex(chrom):
    global scf_list
    count = 0
    for i in scf_list:
        if chrom == i:
            return count
        count += 1

def getRefGff(ref_file):
    f1 = open(ref_file, 'r')
    ref_list, temp, count = [], [], 0
    for line in f1:
        li = line.replace("\n",'').split('\t')
        if li[2] == 'gene':
            if temp:
                temp.append(count)
                ref_list.append(temp)
                temp, count = [], 0
            li[8] = li[8].split(';')[0].split('=')[1]
            temp.append(li)
        else:
            count+=1
    temp.append(count)
    ref_list.append(temp)

    return ref_list

def getFasta(ref_fasta):
    f1 = open(ref_fasta, 'r')
    fasta_list, tmp_list, tmp_str = [], [], ''
    for line in f1:
        if line.find('>') == -1:
            li = line.replace('\n','')
            tmp_str += li
        else:
            if tmp_str != '':
                tmp_list.append(tmp_str)
                fasta_list.append(tmp_list)
                tmp_list, tmp_str = [], ''
            name = line.replace('>','').split(' ')[0]
            tmp_list.append(name)
    tmp_list.append(tmp_str)
    fasta_list.append(tmp_list)

    return fasta_list

def curation(li_info, gene_info, cds_info, fasta_info, ref_info, check_cnt, cds_left, cds_right):
    cur_ref_len, cur_cds_len = int(gene_info[4]) - int(gene_info[3]) + 1, int(cds_right) - int(cds_left) + 1
    count_flag = False
    if cur_ref_len - cur_cds_len == 0:
         count_flag = True
    else:
        for ref_i in ref_info:
            if gene_info[0] == ref_i[0][8]:
                if ref_i[1] == check_cnt or ref_i[1] == 1 :
                    match_result, li_info = correction(li_info, gene_info, cds_info, fasta_info,ref_i[1])
                    count_flag = True if match_result is True else False
                break

    return count_flag, li_info

def correction(li_info, gene_info, cds_info, fasta_info, reference_cds_count):
    chr_n, cds_l, cds_r, direction = cds_info[0], int(cds_info[1]), int(cds_info[2]), cds_info[3]
    index = checkIndex(chr_n)
    ref_length, cds_length, tmp_length = int(gene_info[4])-int(gene_info[3])+1, cds_r - cds_l + 1, 6
    match_flag, fasta_list = False, fasta_info[index][1]
    diff_norm, new_position, limit =  abs(ref_length-cds_length), 0, ref_length + (ref_length/5) # 20%

    if direction == '+':
        tmp_index = cds_r - 3
        while (tmp_length < limit):
            if fasta_list[tmp_index - 3:tmp_index] == PLUS_START_CODON:
                if tmp_length == ref_length:
                    new_position, match_flag = tmp_index - 3, True
                    break
                else:
                   new_norm = abs(tmp_length-ref_length)
                   if new_norm < diff_norm:
                       diff_norm, new_position = new_norm, tmp_index - 3
            tmp_index, tmp_length = tmp_index - 3, tmp_length + 3
        cds_l = new_position+1
    else:
        tmp_index = cds_l + 3
        while (tmp_length < limit):
            if fasta_list[tmp_index - 1:tmp_index+2] == MINUS_START_CODON:
                if tmp_length == ref_length:
                    new_position, match_flag = tmp_index + 2, True
                    break
                else:
                    new_norm = abs(tmp_length-ref_length)
                    if new_norm < diff_norm:
                        diff_norm, new_position = new_norm, tmp_index + 2
            tmp_index, tmp_length = tmp_index + 3, tmp_length + 3
        cds_r = new_position

    if match_flag:
        gene = li_info[0]
        if reference_cds_count == 1:
            cds = li_info[-1] if direction =='+' else li_info[1]
            gene_li, cds_li = gene.split(' '), cds.split(' ')
            new_li = []
            if direction == '+':
                gene_li[3], cds_li[3] = str(cds_l), str(cds_l)
            else:
                gene_li[4], cds_li[4] = str(cds_r), str(cds_r)
            new_li.append(' '.join(gene_li))
            new_li.append(' '.join(cds_li))
            li_info = new_li
        else:
            cds = li_info[1] if direction =='+' else li_info[-1]
            gene_li, cds_li = gene.split(' '), cds.split(' ')
            if direction == '+':
                gene_li[3], cds_li[3] = str(cds_l), str(cds_l)
                li_info[0], li_info[1] = ' '.join(gene_li), ' '.join(cds_li)
            else:
                gene_li[4], cds_li[4] = str(cds_r), str(cds_r)
                li_info[0], li_info[-1] = ' '.join(gene_li), ' '.join(cds_li)

    return match_flag, li_info

def print_list(li_info):
    for it in li_info:
         print(it)

def main(gff_file, ref_file, input_fasta, scf_name):

    fasta_list = getFasta(input_fasta)
    ref_list = getRefGff(ref_file)
    gene_list, li_list, cds_list = [], [], []
    check, flag, chrName, direction, cds_l, cds_r, cnt, chkCnt = False, False, '', '', 0, 0, 0, 0
    fp = open(scf_name, 'r')
    for line in fp:
        scf_list.append(line.replace('\n',''))
    fp.close()

    f1 = open(gff_file, 'r')
    for line in f1:
        new_line = line.replace('\n','')
        li = new_line.split(' ')
        if li[2] == 'gene':
            if flag is True :
                if (int(gene_list[4])-int(gene_list[3])) == (int(cds_r)-int(cds_l)):
                    cnt = cnt + 1
                else:
                    cntFlag,li_list = curation(li_list, gene_list, cds_list, fasta_list, ref_list, chkCnt, cds_l, cds_r)
                    cnt = cnt + 1 if cntFlag else cnt
                print_list(li_list)
                flag = False
            if check is True:
                print_list(li_list)
                check = False
            chkCnt, li_list, cds_list, gene_list = 0, [], [], li[8].split(',')
        else:
            chrName, left, right, direction = li[0], int(li[3]), int(li[4]), li[6]
            chkCnt+=1
            if flag is False:
                cds_l, flag = left, True
            if li[8] == 'UNDEF' or li[8].find(';') != -1:
                check, flag = True, False
            cds_r = right
            cds_list = [chrName, cds_l, cds_r, direction]
        li_list.append(new_line)

    if flag is True:
        cntFlag = curation(li_list, gene_list, cds_list, fasta_list, ref_list, chkCnt, cds_l, cds_r)
        cnt = cnt +1 if cntFlag is True else cnt
        print_list(li_list)
        flag = False

    print(cnt)
    f1.close()

if __name__ == '__main__':
    gff_file = sys.argv[1]
    ref_file = sys.argv[2]
    input_fasta = sys.argv[3]
    scf_name = sys.argv[4]
    main(gff_file, ref_file, input_fasta, scf_name)
