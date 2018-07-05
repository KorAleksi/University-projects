"""
Variables:
0-9 = rows (FIXED)
10 = current position (FIXED)
11 = next position
12 = bit_manipulation (decoding, used with AND)
13 = current_pos, number_of_moves
14 = current_stage (how far in tree)
15-17 = division_positions
18-22 = moves (18 also next move)
23-28 = local variables for functions
"""


def init_memory():
    global containers
    containers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    global fork_nodes
    fork_nodes = []


def is_black():
    if "1" == input("is block black"):
        return True
    else:
        return False


# 23 y-iterator
# 24 x-iterator
# 25 bit manipulation
def scan_board(auto=False):
    print("\nscanning the board...\nStart position: " + str(containers[10]))
    if auto:
        containers[0] = 767
        containers[1] = 593
        containers[2] = 805
        containers[3] = 681
        containers[4] = 555
        containers[5] = 681
        containers[6] = 613
        containers[7] = 821
        containers[8] = 901
        containers[9] = 1021
        containers[10] = 99
        print("Finished Scanning at position: " + str(containers[10]))
        return

    containers[10] = 0
    containers[23] = 0
    while containers[23] < 10:
        containers[25] = 1
        containers[24] = 0
        while containers[24] < 10:
            if is_black():
                if containers[24] == 0:
                    containers[containers[23]] = 1
                else:
                    containers[containers[23]] += containers[25]
            containers[24] += 1
            containers[25] *= 2
        containers[23] += 1
    print("Finished Scanning at position: " + str(containers[10]))


# 23 bit manipulation
# 24 position
# 25 y
# 28 is_edge (1 or 0)
def is_position_edge():

    containers[28] = 0
    containers[25] = int(containers[10]/10)
    containers[24] = containers[25]*10
    containers[24] = containers[10] - containers[24]
    if containers[10] < 10:
        containers[28] = 1
        return
    if containers[10] > 90:
        containers[28] = 1
        return
    if containers[24] == 0:
        containers[28] = 1
        return
    if containers[24] == 9:
        containers[28] = 1
        return


# 23 bit manipulation
# 24 new position
# loop_container
def find_start_pos():
    print("\nFinding starting position...\nCurrent position: " + str(containers[10]))
    containers[23] = 256
    for loop_container in range(8, 0, -1):
        if containers[23] & containers[0] == 0:
            containers[24] = loop_container
            containers[23] = 0  # first move up
            break
        if containers[23] & containers[9] == 0:
            containers[24] = 90 + loop_container
            containers[23] = 1  # first move down
            break
        if containers[loop_container] & 1 == 0:
            containers[24] = loop_container*10
            containers[23] = 3  # first move left
            break
        if containers[loop_container] & 512 == 0:
            containers[24] = loop_container*10 + 9
            containers[23] = 2  # first move right
            break
        containers[23] = int(containers[23]/2)
    containers[10] = containers[24]
    containers[11] = containers[23]
    print("Starting position found at: " + str(containers[10]))


# Run Before moving
# 23 get current pos->x-coordinate->
# 24 y-coordinate(used to get a row 0-9)
# 25 bit manipulation
def mark_as_visited():
    containers[23] = containers[10]
    containers[24] = int(containers[23]/10)
    containers[23] -= 10*containers[24]
    containers[25] = 1
    for _ in range(0,containers[23]):
        containers[25] *= 2
    containers[containers[24]] = containers[25] | containers[containers[24]]


# 23 block number
# 24 y-coordinate
# 25 bit manipulation
def is_block_white():
    containers[24] = int(containers[23] / 10)
    containers[23] = containers[23] - 10 * containers[24]
    containers[25] = 1
    for i in range(0, containers[23]):
        containers[25] *= 2
    # 23 is free
    containers[23] = containers[25] & containers[containers[24]]


# 10 position
# 11 move(0,1,2,3)
# 13 number of moves in list
# 23 pointer to moves container (18-22)
# 24 move iterator
# 25 bit manipulation
def new_position():
    containers[13] += 1
    if containers[11] == 0:
        containers[10] += 10
    elif containers[11] == 1:
        containers[10] -= 10
    elif containers[11] == 2:
        containers[10] -= 1
    else:
        containers[10] += 1

    containers[23] = 18
    containers[24] = 0
    containers[25] = 1
    while containers[24] < containers[13]:
        if containers[24] == 7:
            containers[23] += 1
            containers[25] = 1
        elif containers[24] == 14:
            containers[23] += 1
            containers[25] = 1
        elif containers[24] == 21:
            containers[23] += 1
            containers[25] = 1
        elif containers[24] == 28:
            containers[23] += 1
            containers[25] = 1

        if containers[24] != containers[13] - 1:
            containers[25] *= 4
            containers[24] += 1
        else:
            containers[26] = (3*containers[25]) & containers[containers[23]]
            containers[containers[23]] -= containers[26]
            containers[containers[23]] += containers[11]*containers[25]

            containers[24] += 1

# 24 pointer to row (18-22)
# 25 x-position
# 26 is there white around the block
def back_to_last_fork():


    containers[24] = 0
    containers[25] = 0
    containers[26] = 0

    while containers[26] == 0:
        containers[23] = containers[13] - 1
        containers[27] = 1
        containers[24] = int((containers[23])/7)
        containers[25] = containers[23] - containers[24]*7
        loop_counter = 0
        while loop_counter < containers[25]:
            containers[27] *= 4
            loop_counter += 1
        containers[11] = containers[containers[24] + 18] & (containers[27]*3)
        containers[11] = int(containers[11]/containers[27])
        if containers[11] == 0:
            containers[10] -= 10
            #print("back: DOWN")
        if containers[11] == 1:
            containers[10] += 10
            #print("back: UP")
        if containers[11] == 2:
            containers[10] += 1
            #print("back: LEFT")
        if containers[11] == 3:
            containers[10] -= 1
            #print("back: RIGHT")
        #print("Current pos: " + str(containers[10]))
        is_white_neighbours()
        containers[13] -= 1


def is_white_neighbours():
    containers[23] = containers[10] - 1
    containers[26] = 0
    is_block_white()
    if containers[23] == 0:
        containers[26] += 1
        return
    containers[23] = containers[10] + 1
    is_block_white()
    if containers[23] == 0:
        containers[26] += 1
        return
    containers[23] = containers[10] - 10
    is_block_white()
    if containers[23] == 0:
        containers[26] += 1
        return
    containers[23] = containers[10] + 10
    is_block_white()
    if containers[23] == 0:
        containers[26] += 1
        return


# 23a block number and neighbour block number
# 23b is that block white
# 26 counter for number of moves found
def find_available():

    containers[23] = containers[10] - 1
    containers[26] = 0
    is_block_white()
    if containers[23] == 0:
        containers[11] = 2
        containers[26] += 1
    containers[23] = containers[10] + 1
    is_block_white()
    if containers[23] == 0:
        containers[11] = 3
        containers[26] += 1
    containers[23] = containers[10] - 10
    is_block_white()
    if containers[23] == 0:
        containers[11] = 1
        containers[26] += 1
    containers[23] = containers[10] + 10
    is_block_white()
    if containers[23] == 0:
        containers[11] = 0
        containers[26] += 1

    if containers[14] == 0:
        if containers[26] > 1:
            containers[14] += 1
            fork_nodes.append(containers[10])
            mark_as_visited()
            new_position()
            #print(str(containers[11]) + "dir\nCurrent pos: " + str(containers[10]))
        elif containers[26] == 1:
            containers[23] == containers[10]
            mark_as_visited()
            move()
    else:
        if containers[26] > 1:
            containers[14] += 1
            fork_nodes.append(containers[10])
            mark_as_visited()
            new_position()
        elif containers[26] == 1:
            containers[23] == containers[10]
            mark_as_visited()
            new_position()
        else:
            containers[14] -= 1
            mark_as_visited()
            back_to_last_fork()

        #print(str(containers[11])+"dir\nCurrent pos: " + str(containers[10]))








def find_path(auto=False):
    print("\nFinding a path...\nCurrent position: " + str(containers[10]))
    if auto:
        containers[18] = 8736
        containers[19] = 10368
        containers[20] = 2
        containers[21] = 5865
        containers[22] = 16019
        containers[13] = 16
        containers[10] = 8

        return
    mark_as_visited()
    move()
    while containers[28] != 1:
        find_available()

        is_position_edge()
    containers[10] = fork_nodes[0]







# 10 new position
# 11 move (0,1,2,3)
def move():
    if containers[11] == 0:
        print("UP")
        containers[10] += 10
    elif containers[11] == 1:
        print("DOWN")
        containers[10] -= 10
    elif containers[11] == 2:
        print("RIGHT")
        containers[10] -= 1
    else:
        print("LEFT")
        containers[10] += 1
    print("Current pos: " + str(containers[10]))


# 23 pointer to moves
# 24 move iterator
# 13 number of moves (CONSTANT)
#
def move_to_goal():
    containers[23] = 18
    containers[24] = 0
    while containers[24] < containers[13]:
        if containers[24] == 7:
            containers[23] += 1
        elif containers[24] == 14:
            containers[23] += 1
        elif containers[24] == 21:
            containers[23] += 1
        elif containers[24] == 28:
            containers[23] += 1
        containers[11] = containers[containers[23]] & 3
        containers[containers[23]] = int(containers[containers[23]]/4)
        move()

        containers[24] += 1


def main():

    init_memory()

    scan_board(True)
    find_start_pos()

    find_path()

    move_to_goal()

    return


main()
