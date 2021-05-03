import numpy as np
import random

random.seed(0)

# Number of strings
N = [1,2,3,4,5,6,7,8,9,10]

# Max string length
n_k = [10]

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
