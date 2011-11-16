from pylsf import *
import string
import time

a = lsb_init("bjobs.py")
b = lsb_openjobinfo()

if b < 1:
  print "No unfinished job found"
else:
  print "  JOBID      USER     STATUS     QUEUE      FROM_HOST      EXEC_HOST      JOB_NAME      SUBMIT_TIME"
  print "--------- ---------  -------- ----------- -------------  -------------  ------------  ---------------"

  for c in range(b):

    data = lsb_readjobinfo(c)

    status = job_status(data[2])
    from_host = string.split(data[16],'.')
    
    exec_host = "-"
    if data[17]:
      (exec_host, exec_num) = data[17][0]
      exec_host = string.split(exec_host,'.')

    sdate = time.gmtime(data[4])
    submit_date = time.strftime("%b %d %H:%M:%S", sdate)

    jobname = data[19][0][:12]
    if "#" in jobname:   jobname = ""

    print " %8s %9s  %-7s  %-10s  %13s  %13s  %12s  %10s" % (data[0], data[1], status,
                                                                 data[19][1], from_host[0], 
                                                                 exec_host[0], jobname,
                                                                 submit_date)

lsb_closejobinfo()
