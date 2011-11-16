from pylsf import *
import string
import time

class Sorter:

   def _helper(self, data, aux, inplace):
     aux.sort()
     result = [data[i] for junk, i in aux]
     if inplace: data[:] = result

     return result

   def byItem(self, data, itemindex=None,inplace=1):

     if itemindex is None:

       if inplace:
         data.sort()
         result = data
       else:
         result = data[:]
         result.sort()

       return result

     else:
       aux = [(data[i][itemindex], i) for i in range(len(data))]
       return self._helper(data, aux, inplace)

   sort = byItem
   __call__ = byItem

   def byAttribute(self, data, attributename, inplace=1):
     aux = [(getattr(data[i], attributename), i) for i in range(len(data))]
     return self._helper(data, aux, inplace)

def queues():

  queue_dict = {}
  for queue in lsb_queueinfo():
    queue_dict[queue[0]] = queue[53][9]

  return queue_dict

def jobqueue(queue_dict):

  job_list = []

  b = lsb_openjobinfo()
  if b:

   for c in range(b):

     data = lsb_readjobinfo(c)

     state = job_status(data[2])
     if state == "RUN":

      jobname = data[19][0]
      queue   = data[19][1]
      procs   = data[19][5]

      wallclock = data[44][9]
      if wallclock == -1:
        if queue_dict.has_key(queue):
          wallclock = queue_dict[queue]

      job_list.append( [data[0], data[1], state, queue, procs, jobname[0:15], wallclock, data[6], time_remain(data[6], wallclock) ] )

  lsb_closejobinfo()

  return job_list

def time_end(start_time, wcl):

  edate = time.gmtime( int(start_time) + int(wcl) )
  end_date = time.strftime("%b %d %H:%M:%S", edate)

  return end_date

def time_remain(start_time, wcl):

  etime = start_time + wcl
  tremain = etime - time.time()

  return int(tremain)

def sec2string(secs):

  days = hours = minutes = 0
  remaining = abs(secs)

  flag = sign = ' '
  if secs < 0:
    flag = '*'
    sign = '-'

  seconds = remaining % 60
  remaining = (remaining - seconds)/60
  minutes = remaining % 60
  remaining = (remaining - minutes)/60
  hours = remaining % 24
  remaining = (remaining-hours)/24
  days = remaining

  time_string = "%1s%.3dd:%.2dh:%.2dm:%.2ds%s" % (sign, days, hours, minutes, seconds, flag)

  return time_string


sort = Sorter()

if __name__ == "__main__":

  a = lsb_init("bremain.py")

  jobs = jobqueue(queues())

  if jobs:

    sort(jobs, 8)

    print ""
    print "  JobId      User      State      Queue    Procs      JobName       WCL(s)     End Date         Time Remain"
    print "---------  --------  ---------  ---------  -----  ---------------   ------  ---------------  -----------------"

    for job in jobs:

      if job[6] == "-1":
        print "%-9s  %-8s  %-9s  %-9s  %5s  %15s  %7s  %-10s  %-10s" % (job[0], job[1], job[2], job[3], str(job[4]).rjust(4, ' '), job[5].lstrip(), "  N/A", "      N/A", "      N/A")
      else:
        print "%-9s  %-8s  %-9s  %-9s  %5s  %15s  %7s  %-10s  %-10s" % (job[0], job[1], job[2], job[3], str(job[4]).rjust(4, ' '), job[5].lstrip(), str(job[6]).rjust(6,' '), time_end(job[7], job[6]), sec2string(job[8]) )

  else:
    print "No running jobs found\n"
   
