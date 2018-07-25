import sys
import os
import numpy as np


rotations = np.arange(0, 360, 1)


for rotation in rotations:
    f = open("rotation.txt", "w")
    f.write(str(rotation))
    f.close()
    command = "./Povray37UnofficialMacCmd gjw-100.pov -w640 -h480 +L/home/portera/projects/PovrayCommandLineMacV2/include +ooutput/rot{}.png".format(str(rotation).zfill(3))
    os.system(command)

command = "convert output/*.png output/output.gif"
os.system(command)