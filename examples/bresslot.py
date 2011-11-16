from pylsf import *
from string import split, join
import time
import datetime

def bresslot():

  a = lsb_init("bresslot.py")
  pend_jobs = lsb_pendreason(0)

  total = 0
  b = lsb_openjobinfo()
  for c in range(b):

    data = lsb_readjobinfo(c)
    jobid = data[0]
    user  = data[1]
    state = job_status(data[2])

    shost  = data[16]
    jname  = data[19][0]
    squeue = data[19][1]

    resReason = ""
    if len(data[17]) > 0 and data[5] > 0:
      slotTotal, hostList = listduplicates2str(data[17])
      resReason = "Reserved %4s slots on hosts %s" % (slotTotal, hostList)

    pend_reason = ""
    if pend_jobs.has_key(jobid):

      sdate = ""
      stime = data[7]
      if stime:
        sdate = datetime.datetime.fromtimestamp(int(stime))
        sdate = sdate.strftime("%b %d %H:%M:%S")

      pend_reason = pend_jobs[jobid]
      if pend_reason and resReason:
        if total == 0:
          print "  JobID     User   State    Queue     Est Start Date      Reserved Slot Reason"
          print "--------- -------- -----   -------  ------------------   ----------------------"

          total += 1
          print '%-.11s %-.5s %-.5s %-.10s %-.16s %-.25s' % (jobid, user, state, queue, sdate, resReason)

  lsb_closejobinfo()

  if total == 0:
    print "No reserved job slots found."
  else:
    print "\n%d reserved job slot(s) found." % total

def listduplicates2str(dupLst):

   newLst = []
   total = 0
   for item in dupLst:
      host, number = item
      total += number
      newLst.append("<%s*%s>" % (item))

   return total, join(newLst, ",")

if __name__ == "__main__":

   bresslot()     
