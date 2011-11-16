from pylsf import *

a = lsb_init("")
print lsb_addreservation("mark","",["localhost"],"4:20:00-4:22:00")
print lsb_sysmsg()
