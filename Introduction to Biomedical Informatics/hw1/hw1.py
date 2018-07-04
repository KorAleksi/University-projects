import sys


class Data:

    def __init__(self):
        self.seqA = 0
        self.seqB = 0
        self.isLocal = 0
        self.gap_open_A = 0
        self.gap_ext_A = 0
        self.gap_open_B = 0
        self.gap_ext_B = 0
        self.letters_in_A = ""
        self.letters_in_B = ""
        self.score_matrix = 0

    # returns to score of aligning two letters.
    def get_score(self, letter_A, letter_B):
        ind_A = self.letters_in_A.find(letter_A)
        ind_B = self.letters_in_B.find(letter_B)
        return self.score_matrix[ind_A][ind_B]


def gap_penalty(gap_open, gap_extend, n):
    return gap_open + gap_extend * (n - 1)


def loc_to_str(location):
    return str(location[0]) + "," + str(location[1])


def str_to_loc(string):
    location = [0, 0]
    str_vec = string.split(",")
    location[0] = int(str_vec[0])
    location[1] = int(str_vec[1])
    return location

def list_to_2d(list, y_dim, x_dim):
    new_matrix = [[0] * (x_dim) for i in range(y_dim)]
    for i in range(0, y_dim):
        new_matrix[i] = list[i * x_dim:(i + 1) * x_dim +1]
    return new_matrix

def create_best_score_matrix(data):
    print("Creating score matrix...")
    # initialize
    seqA = data.seqA
    seqB = data.seqB
    nA = len(seqA)
    nB = len(seqB)
    wA_open = data.gap_open_A
    wA_ext = data.gap_ext_A
    wB_open = data.gap_open_B
    wB_ext = data.gap_ext_B
    best_score = [[0] * (nA + 1) for i in range(nB + 1)]
    #best_score = np.zeros((nB + 1, nA + 1))
    prev_best_mat = []

    # find the best score for every location [i, j].
    for i in range(1, nB + 1):
        for j in range(1, nA + 1):
            match_score = data.get_score(seqA[j - 1], seqB[i - 1])
            # fill the first cols and rows with match scores.
            if i <= 1 or j <= 1:
                best_score[i][j] = match_score
                # in local alignment convert negative values to zeros.
                if data.isLocal == 1 and best_score[i][j] < 0:
                    best_score[i][j] = 0
            else:
                # get the score from loc [i - 1, j - 1].
                prev_best_loc = [i - 1, j - 1]
                prev_best = best_score[prev_best_loc[0]][prev_best_loc[1]]
                prev_best_mat.append(loc_to_str(prev_best_loc))
                # get scores from every vertical location and take gap penalty into account.
                for y in range(2, i):
                    with_gap = best_score[i - y][j - 1] - gap_penalty(wA_open, wA_ext, y)
                    # if is the same as previous best then add the location with the previous location.
                    dif = with_gap - prev_best
                    if -0.001 < dif < 0.001:
                        prev_best_mat[-1] = prev_best_mat[-1] + ";" + loc_to_str([i - y, j - 1])
                    # if the score is better than previously checked then assign it as the new
                    # best and save the location.
                    elif dif > 0:
                        prev_best_loc = [i - y, j - 1]
                        prev_best = with_gap
                        prev_best_mat[-1] = loc_to_str(prev_best_loc)
                # get scores from every horizontal location and take gap penalty into account.
                for x in range(2, j):
                    with_gap = best_score[i - 1][j - x] - gap_penalty(wB_open, wB_ext, x)
                    # if is the same as previous best then add the location with the previous location.
                    dif = with_gap - prev_best
                    if -0.001 < dif < 0.001:
                        prev_best_mat[-1] = prev_best_mat[-1] + ";" + loc_to_str([i - 1, j - x])
                    # if the score is better than previously checked then assign it as the new
                    # best and save the location.
                    elif dif > 0:
                        prev_best_loc = [i - 1, j - x]
                        prev_best = with_gap
                        prev_best_mat[-1] = loc_to_str(prev_best_loc)
                # calculate the best score for location [i, j].
                best_score[i][j] = round(match_score + prev_best, 2)
                # in local alignment change negative scores to zeros.
                if data.isLocal == 1 and prev_best == 0:
                    prev_best_mat[-1] = ""
                if data.isLocal == 1 and best_score[i][j] <= 0:
                    best_score[i][j] = 0
                    prev_best_mat[-1] = ""
        sys.stdout.write('\r' + '{0:.0f}'.format(i / nB * 100,) + '%')
    sys.stdout.write("")
    sys.stdout.flush()
    # convert list to matrix
    prev_best_mat = list_to_2d(prev_best_mat, nB - 1, nA - 1)
    #    prev_best_mat = np.reshape(prev_best_mat, (nB - 1, nA - 1))
    return best_score, prev_best_mat


# Prints the output
def print_output(val, seq_list):
    print("\n")
    print("Maximum Score= " + str(val))
    seq_list = reversed(seq_list)
    for seq in seq_list:
        (seqA, seqB) = seq
        print(seqA)
        print(seqB)
        print("\n")


# Calculates all local alignments with the best score
def local_alignment(data, s_matrix, prev):
    # init variables
    nA = len(data.seqA)
    nB = len(data.seqB)
    highest_loc = []
    highest_val = -9000000000000

    # search the best scores from last column and row
    for i in range(1, nB + 1):
        for j in range(1, nA + 1):
            val = s_matrix[i][j]
            if val > highest_val:
                highest_val = val
                highest_loc = loc_to_str([i, j])
            elif val == highest_val:
                highest_loc = highest_loc + ";" + loc_to_str([i, j])
    # list because there might be multiple best scores
    loc_list = highest_loc.split(";")
    seq_list = []
    # find all possible alignments and add them to list
    for loc in loc_list:
        seq_list.extend(align(loc, data, prev))
    print_output(highest_val, seq_list)
    return


# Calculates all global alignments with the best score
def global_alignment(data, s_matrix, prev):
    # init variables
    nA = len(data.seqA)
    nB = len(data.seqB)
    highest_loc = []
    highest_val = -9000000000000

    # search the best scores from last column and row
    for i in range(1, nB + 1):
        for j in range(1, nA + 1):
            if i < nB and j < nA:
                continue
            val = s_matrix[i][j]
            if val > highest_val:
                highest_val = val
                highest_loc = loc_to_str([i, j])
            elif val == highest_val:
                highest_loc = highest_loc + ";" + loc_to_str([i, j])
    # list because there might be multiple best scores
    loc_list = highest_loc.split(";")
    seq_list = []
    # find all possible alignments and add them to list
    for loc in loc_list:
        seq_list.extend(align(loc, data, prev))
    print_output(highest_val, seq_list)
    return


# finds recursively all possible alignments
def align(loc_str, data, prev):
    # initialize
    seq_list = []
    if loc_str == "":
        return ""
    loc = str_to_loc(loc_str)
    # letters in this location
    cur_letterA = data.seqA[loc[1] - 1]
    cur_letterB = data.seqB[loc[0] - 1]

    # If not the last location then recursively find alignments.
    # Else just add the last letters to list
    if loc[0] > 1 and loc[1] > 1:
        # split location string
        prev_loc_list = prev[loc[0] - 2][loc[1] - 2].split(";")
        for prev_loc_str in prev_loc_list:
            # if there is no more pointers
            if prev_loc_str == "":
                # This will be the first letter in alignment
                seq_list.append((cur_letterA, cur_letterB))
                continue
            # find letters recursively
            last_seq_list = align(prev_loc_str, data, prev)

            prev_loc = str_to_loc(prev_loc_str)
            # there might be multiple paths found
            for last_seq in last_seq_list:
                (last_letterA, last_letterB) = last_seq
                gapsB = loc[0] - prev_loc[0] - 1
                gapsA = loc[1] - prev_loc[1] - 1
                # If there should be gaps then next lines will add them
                if gapsB > 0:
                    last_letterA = last_letterA + "_" * gapsB + cur_letterA
                    last_letterB = last_letterB + data.seqB[prev_loc[0]:prev_loc[0] + gapsB] + cur_letterB
                    seq_list.append((last_letterA, last_letterB))
                elif gapsA > 0:
                    last_letterB = last_letterB + "_" * gapsA + cur_letterB
                    last_letterA = last_letterA + data.seqA[prev_loc[1]:prev_loc[1] + gapsA] + cur_letterA
                    seq_list.append((last_letterA, last_letterB))
                else:
                    seq_list.append((last_letterA + cur_letterA, last_letterB + cur_letterB))
    else:
        seq_list.append((cur_letterA, cur_letterB))
    return seq_list


def read_file(filename):
    print("Reading file...")
    # Save data into Data class
    data = Data()
    try:
        file_object = open(filename, "r")
    except:
        return ""
    # Read sequences
    data.seqA = file_object.readline().strip()
    data.seqB = file_object.readline().strip()
    # local or global alignment
    data.isLocal = int(file_object.readline().strip())
    # read gap penalties
    gap_penalties = file_object.readline().strip().split(" ")
    data.gap_open_A = float(gap_penalties[0])
    data.gap_open_B = float(gap_penalties[2])
    data.gap_ext_A = float(gap_penalties[1])
    data.gap_ext_B = float(gap_penalties[3])
    # Letters in A and B
    nA = int(file_object.readline())
    data.letters_in_A = file_object.readline().strip()
    nB = int(file_object.readline())
    data.letters_in_B = file_object.readline().strip()
    # Read match matrix
    score_matrix = [[0] * nA for i in range(nB)]
    #score_matrix = np.zeros((nA, nB))
    # print(score_matrix)
    for i in range(0, nA * nB):
        line = file_object.readline().strip().split()
        score_matrix[int(line[0]) - 1][int(line[1]) - 1] = float(line[4])
    data.score_matrix = score_matrix
    # data.print_data()
    return data


def main():
    print("\nHW1 - Pairwise Sequence Alignment")
    print("Aleksi Artturi Korkee")
    print("ID: 12180067\n")
    while True:
        filename = input("Read input file. It must be in the same folder as this script."
                         "\nFile name: ")
        input_data = read_file(filename)
        if input_data == "":
            print("Error! There is no such file.\n")
            continue
        if input_data.isLocal:
            (best_score, prev_best) = create_best_score_matrix(input_data)
            local_alignment(input_data, best_score, prev_best)
        else:
            (best_score, prev_best) = create_best_score_matrix(input_data)
            global_alignment(input_data, best_score, prev_best)
        inp = ""
        while True:
            inp = input("Again (y/n): ")
            if inp == "y":
                print("")
                break
            elif inp == "n":
                return


main()