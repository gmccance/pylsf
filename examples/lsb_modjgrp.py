#!/usr/bin/python
from pylsf import *
a=lsb_init("")
lsb_modjgrp("/misc/new","/misc/new2/")
lsb_perror()
