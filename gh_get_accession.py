import sys

file1 = sys.argv[1]
tmp1 = open("TMP_ID.tab", "x")

with open(file1, encoding='utf8') as f:
        for line in f:
            last = line.split('_')[-1]
            l = last.replace('.faa', '')
            tmp1.write(l)



