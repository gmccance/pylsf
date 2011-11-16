from pylsf import *

a = lsb_init("")

b,c = lsb_readjobmsg(208,5)
print b,c
