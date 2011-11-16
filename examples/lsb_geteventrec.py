import pylsf

a = pylsf.lsb_init("pylsf-lsb.acct")
b = pylsf.lsb_geteventrec("/usr/share/lsf/work/makalu/logdir/lsb.events")
while 1:
  c = b.read()
  if not c:
    break
  else:
    print c
