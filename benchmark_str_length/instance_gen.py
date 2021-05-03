import numpy as np
import random

random.seed(0)

# Number of strings
N = [10]

# Max string length
n_k = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]

# Alphabet length
A = 4
alphabet_string = "ACGT"

# instances per category
inst_per_category = 5

# generate instances p1
for i in N:
    for j in n_k:

        for z in range(inst_per_category):
            strings = []
            for k in range(i):
                s = []

                alpha_vector = np.random.normal(loc=0, scale=1, size=j)
                for alpha in alpha_vector:
                    char = min(1+int(abs(alpha)), A)
                    s.append(alphabet_string[int(char)-1])

                strings.append(s)

            f = open("p1_"+str(i)+"_"+str(j)+"-"+str(z)+".txt", "w")

            f.write("{\n")
            f.write("\t\"num_strings\": "+str(i)+",\n")
            f.write("\t\"alphabet\": \""+str(alphabet_string)+"\",\n")

            f.write("\t\"strings\": [\n")
            for s in strings[:-1]:
                f.write("\t\t\"" + "".join(map(str,s)) + "\",\n")
            f.write("\t\t\"" + "".join(map(str,strings[-1])) + "\"\n")
            f.write("\t],\n")

            str_lengths = [j] * i
            f.write("\t\"str_length\":[" + ",".join(map(str,str_lengths)) + "]\n")
            f.write("}")

            f.close()

random_edits = 100

def perform_random_edit(s, max_length):
    r = 0
    if (len(s) < max_length and len(s) > 0):
        r = random.randint(1,3)
    elif (len(s) == 0):
        r = random.randint(3,3)
    else:
        r = random.randint(1,2)


    if r == 2:
        # substitution
        pos = random.randint(0,len(s)-1)
        c = random.randint(1,A)

        s[pos] = c

    elif r == 3:
        # insertion
        pos = random.randint(0,len(s))
        c = random.randint(1,A)

        s.insert(pos, c)
    elif r == 1:
        # deletion
        pos = random.randint(0,len(s)-1)

        del s[pos]

# generate instances p2
for i in N:
    for j in n_k:

        for z in range(inst_per_category):
            strings = []
            str_lengths = []
            for k in range(i):
                s = [1] * i

                for y in range(random_edits):
                    perform_random_edit(s, j)

                s_length = len(s)
                str_lengths.append(s_length)

                dna_s = [alphabet_string[int(c)-1] for c in s]

                strings.append(dna_s)

            f = open("p2_"+str(i)+"_"+str(j)+"-"+str(z)+".txt", "w")

            f.write("{\n")
            f.write("\t\"num_strings\": "+str(i)+",\n")
            f.write("\t\"alphabet\": \""+str(alphabet_string)+"\",\n")

            f.write("\t\"strings\": [\n")
            for s in strings[:-1]:
                f.write("\t\t\"" + "".join(map(str,s)) + "\",\n")
            f.write("\t\t\"" + "".join(map(str,strings[-1])) + "\"\n")
            f.write("\t],\n")

            f.write("\t\"str_length\":[" + ",".join(map(str,str_lengths)) + "]\n")
            f.write("}")

            f.close()
