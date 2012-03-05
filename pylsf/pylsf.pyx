"""

PyLSF : Pyrex module for interfacing to Platform LSF 6.2

"""

import string
from sets import Set
from os import getenv

cdef extern from "string.h":
    void* memset(void*, int, unsigned long int)

cdef extern from "stdlib.h":
    ctypedef long long size_t
    ctypedef signed long long int64_t
    ctypedef unsigned long long uint64_t
    void free(void *__ptr)
    void* malloc(size_t size)
    void* calloc(unsigned int nmemb, unsigned int size)
    char *strcpy(char *dest, char *src)

cdef extern from "stdio.h":
    ctypedef struct FILE
    FILE *fopen(char *filename, char *mode)
    int fclose(FILE *fp)

cdef extern from "Python.h":
    object PyCObject_FromVoidPtr(void* cobj, void (*destr)(void *))
    void* PyCObject_AsVoidPtr(object)
    cdef FILE *PyFile_AsFile(object file)

cdef extern from "time.h":
    ctypedef int time_t

cdef char** pyStringSeqToStringArray(seq):

    cdef char **msgArray

    msgArray = NULL
    i = 0
    length = len(seq)

    if length != 0:
        msgArray = <char**>malloc((length+1)*sizeof(char*))
        for line in seq:
            msgArray[i] = line
            i = i + 1

        msgArray[i] = NULL

    return msgArray

cdef int* pyIntSeqToIntArray(seq):

    cdef int *intArray

    intArray = NULL
    i = 0
    length = len(seq)

    if length != 0:
        intArray = <int*>malloc((length+1)*sizeof(int))
        for line in seq:
            intArray[i] = line
            i = i + 1

        intArray[i] = <int>NULL

    return intArray

cdef long* pyLongSeqToLongArray(seq):

    cdef long *intArray

    intArray = NULL
    i = 0
    length = len(seq)

    if length != 0:
        intArray = <long*>malloc((length+1)*sizeof(long))
        for line in seq:
            intArray[i] = line
            i = i + 1

        intArray[i] = <long>NULL

    return intArray

cdef extern from "lsf/lsf.h":

    enum valueType:
       LS_BOOLEAN
       LS_NUMERIC
       LS_STRING
       LS_EXTERNAL

    enum orderType:
       INCR
       DECR
       NA

    cdef struct pidInfo:
       int pid
       int ppid
       int pgid
       int jobid

    cdef struct config_param:
       char *paramName
       char *paramValue

    cdef struct lsfRusage:
       double  ru_utime
       double  ru_stime
       double  ru_maxrss
       double  ru_ixrss
       double  ru_ismrss
       double  ru_idrss
       double  ru_isrss
       double  ru_minflt
       double  ru_majflt
       double  ru_nswap
       double  ru_inblock
       double  ru_oublock
       double  ru_ioch
       double  ru_msgsnd
       double  ru_msgrcv
       double  ru_nsignals
       double  ru_nvcsw
       double  ru_nivcsw
       double  ru_exutime

    cdef struct lsfAcctRec:
       int pid
       char *username
       int exitStatus
       time_t dispTime
       time_t termTime
       char *fromHost
       char *execHost
       char *cwd
       char *cmdln

    cdef struct jRusage:
       int mem
       int swap
       int utime
       int stime
       int npids
       pidInfo *pidInfo
       int npgids
       int *pgid
       int nthreads

    cdef struct resItem:
       char name[256]
       char des[256]
       int  valueType
       int  orderType
       int  flags
       int  interval

    cdef struct lsInfo:
       int     nRes
       resItem *resTable
       int     nTypes
       char    hostTypes[128][256]
       int     nModels
       char    hostModels[128][256]
       char    hostArchs[128][256]
       int     modelRefs[128]
       float   cpuFactor[128]
       int     numIndx
       int     numUsrIndx

    cdef struct clusterInfo:
       char  clusterName[256]
       int   status
       char  masterName[256]
       char  managerName[256]
       int   managerId
       int   numServers
       int   numClients
       int   nRes
       char  **resources
       int   nTypes
       char  **hostTypes
       int   nModels
       char  **hostModels
       int   nAdmins
       int   *adminIds
       char  **admins
       int   analyzerLicFlag
       int   jsLicFlag
       char  afterHoursWindow[256]
       char  preferAuthName[256]
       char  inUseAuthName[256]

    cdef struct hostInfo:
       char  hostName[256]
       char  *hostType
       char  *hostModel
       float cpuFactor
       int   maxCpus
       int   maxMem
       int   maxSwap
       int   maxTmp
       int   nDisks
       int   nRes
       char  **resources
       int   nDRes
       char  **DResources
       char  *windows
       int   numIndx
       float *busyThreshold
       char  isServer
       char  licensed
       int   rexPriority
       int   licFeaturesNeeded

    cdef struct hostLoad:
       char  hostName[256]
       int   *status
       float *li

    cdef struct placeInfo:
       char  hostName[256]
       int   numtask

    cdef extern void  cls_perror          "ls_perror" (char*)
    cdef extern char* cls_sysmsg          "ls_sysmsg" ()
    cdef extern int   cls_readconfenv     "ls_readconfenv" (config_param *, char*)
    cdef extern int   cls_isclustername   "ls_isclustername" (char*)
    cdef extern char* cls_getclustername  "ls_getclustername" ()
    cdef extern lsInfo *cls_info          "ls_info" ()
    cdef extern char  **cls_indexnames    "ls_indexnames" (lsInfo*)
    cdef extern hostInfo *cls_gethostinfo "ls_gethostinfo"   (char*, int*, char**, int, int)
    cdef extern char* cls_gethostmodel    "ls_gethostmodel"  (char*)
    cdef extern char* cls_gethosttype     "ls_gethosttype"   (char*)
    cdef extern float* cls_gethostfactor   "ls_gethostfactor" (char*)
    cdef extern float* cls_getmodelfactor  "ls_getmodelfactor" (char*)
    cdef extern char* cls_getmastername   "ls_getmastername" ()
    cdef extern char* cls_getmyhostname   "ls_getmyhostname" ()
    cdef extern char* cls_getmnthost      "ls_getmnthost"    (char*)
    cdef extern clusterInfo *cls_clusterinfo  "ls_clusterinfo" (char*, int*, char**, int, int)
    cdef extern hostLoad *cls_load        "ls_load" (char*, int*, int, char*)
    cdef extern hostLoad *cls_loadinfo    "ls_loadinfo" (char*, int*, int, char*, char**, int, char***)
    cdef extern int cls_loadadj           "ls_loadadj" (char*, placeInfo *, int)
    cdef extern int cls_eligible          "ls_eligible" (char*, char*, char)
    cdef extern int cls_lockhost          "ls_lockhost" (time_t)
    cdef extern int cls_unlockhost        "ls_unlockhost" ()
    cdef extern int cls_limcontrol        "ls_limcontrol" (char*, int)
    cdef extern int cls_rescontrol        "ls_rescontrol" (char*, int, int)


cdef extern from "lsf/lsbatch.h":

    cdef struct submig:
      int  jobId
      int  options
      int  numAskedHosts
      char **askedHosts

    cdef struct xFile:
      char subFn[256]
      char execFn[256]
      int  options

    cdef struct jobExternalMsgReply:
      long   jobId
      int    msgIdx
      char   *desc
      int    userId
      long   dataSize
      time_t postTime
      int    dataStatus
      char   *userName

    cdef struct submit:
      int     options
      int     options2
      char    *jobName
      char    *queue
      int     numAskedHosts
      char    **askedHosts
      char    *resReq
      int     rLimits[12]
      char    *hostSpec
      int     numProcessors
      char    *dependCond
      char    *timeEvent
      time_t  beginTime
      time_t  termTime
      int     sigValue
      char    *inFile
      char    *outFile
      char    *errFile
      char    *command
      char    *newCommand
      time_t  chkpntPeriod
      char    *chkpntDir
      int     nxf
      xFile   *xf
      char    *preExecCmd
      char    *mailUser
      int     delOptions
      int     delOptions2
      char    *projectName
      int     maxNumProcessors
      char    *loginShell
      char    *userGroup
      char    *exceptList
      int     userPriority
      char    *rsvId
      char    *jobGroup
      char    *sla
      char    *extsched
      int     warningTimePeriod
      char    *warningAction
      char    *licenseProject

    cdef struct submitReply:
      char    *queue
      long    badJobId
      char    *badJobName
      int     badReqIndx

    cdef struct jobInfoEnt:
      int       jobId
      char      *user
      int       status
      int       *reasonTb
      int       numReasons
      int       reasons
      int       subreasons
      int       jobPid
      time_t    submitTime
      time_t    reserveTime
      time_t    startTime
      time_t    predictedStartTime
      time_t    endTime
      time_t    lastEvent
      time_t    nextEvent
      int       duration
      float     cpuTime
      int       umask
      char      *cwd
      char      *subHomeDir
      char      *fromHost
      char      **exHosts
      int       numExHosts
      float     cpuFactor
      int       nIdx
      float     *loadSched
      float     *loadStop
      submit    submit
      int       exitStatus
      int       execUid
      char      *execHome
      char      *execCwd
      char      *execUsername
      time_t    jRusageUpdateTime
      jRusage   runRusage
      int       jType
      char      *parentGroup
      char      *jName
      int       counter[256]
      #u_short  portlsb_hostinfo_cond
      int       jobPriority
      int       numExternalMsg
      jobExternalMsgReply **externalMsg
      int       clusterId
      char      *detailReason
      float     idleFactor
      int       exceptMask
      char      *additionalInfo
      int       exitInfo
      int       warningTimePeriod
      char      *warningAction
      char      *chargedSAAP
      char      *execRusage
      time_t    rsvInActive
      int       numLicense
      char      **licenseNames

    cdef struct jobAttrSetLog:
      int       jobId
      int       idx
      int       uid
      int       port
      char      *hostname

    cdef struct userInfoEnt:
      char   *user
      float  procJobLimit
      int    maxJobs
      int    numStartJobs
      int    numJobs
      int    numPEND
      int    numRUN
      int    numSSUSP
      int    numUSUSP
      int    numRESERVE
      int    maxPendJobs

    cdef struct userShares:
      char *user
      int  shares

    cdef struct groupInfoEnt:
      char       *group
      char       *memberList
      int        numUserShares
      userShares *userShares
      int        options
      char       *pattern
      char       *neg_pattern

    cdef struct hostInfoEnt:
      char   *host
      int    hStatus
      int    *busySched
      int    *busyStop
      float  cpuFactor
      int    nIdx
      float  *load
      float  *loadSched
      float  *loadStop
      char   *windows
      int    userJobLimit
      int    maxJobs
      int    numJobs
      int    numRUN
      int    numSSUSP
      int    numUSUSP
      int    mig
      int    attr
      float  *realLoad
      int    numRESERVE
      int    chkSig
      float  cnsmrUsage
      float  prvdrUsage
      float  cnsmrAvail
      float  prvdrAvail
      float  maxAvail
      float  maxExitRate
      float  numExitRate
      char   *hCtrlMsg

    cdef struct condHostInfoEnt:
      char  *name
      int   howManyOk
      int   howManyBusy
      int   howManyClosed
      int   howManyFull
      int   howManyUnreach
      int   howManyUnavail
      hostInfoEnt *hostInfo

    cdef struct hostPartUserInfo:
      char     user[256] # MAX_LSB_NAME_LEN
      int      shares
      float    priority
      int      numStartJobs
      float    histCpuTime
      int      numReserveJobs
      int      runTime

    cdef struct hostPartInfoEnt:
      char   hostPart[256] # MAX_LSB_NAME_LEN
      char   *hostList
      int    numUsers
      hostPartUserInfo* users

    cdef struct hostRsvInfoEnt:
      char *host
      int  numCPUs
      int  numSlots
      int  numRsvProcs
      int  numUsedProcs

    cdef struct rsvInfoEnt:
      int     options
      char    *rsvId
      char    *name
      int     numRsvHosts
      hostRsvInfoEnt   *rsvHosts
      char    *timeWindow
      int     numRsvJobs
      long    *jobIds
      int     *jobStatus

    cdef struct jobrequeue:
      int  jobId
      int  status
      int  options

    cdef struct jobInfoHead:
      int  numJobs
      long *jobIds
      int  numHosts
      char **hostNames
      int  numClusters
      char **clusterNames
      int  *numRemoteHosts
      char ***remoteHosts

    cdef struct loadIndexLog:
      int  nIdx
      char **name

    cdef struct mbdCtrlReq:
      int  opCode
      char *name
      char *message

    cdef struct queueCtrlReq:
      char *queue
      int  opCode
      char *message

    cdef struct shareAcctInfoEnt:
      char   *shareAcctPath
      int    shares
      float  priority
      int    numStartJobs
      float  histCpuTime
      int    numReserveJobs
      int    runTime

    cdef struct queueInfoEnt:
      char   *queue
      char   *description
      int    priority
      short  nice
      char   *userList
      char   *hostList
      char   *hostStr
      int    nIdx
      float  *loadSched
      float  *loadStop
      int    userJobLimit
      float  procJobLimit
      char   *windows
      int    rLimits[12] # LSF_RLIM_NLIMITS
      char   *hostSpec
      int    qAttrib
      int    qStatus
      int    maxJobs
      int    numJobs
      int    numPEND
      int    numRUN
      int    numSSUSP
      int    numUSUSP
      int    mig
      int    schedDelay
      int    acceptIntvl
      char   *windowsD
      char   *nqsQueues
      char   *userShares
      char   *defaultHostSpec
      int    procLimit
      char   *admins
      char   *preCmd
      char   *postCmd
      char   *requeueEValues
      int    hostJobLimit
      char   *resReq
      int    numRESERVE
      int    slotHoldTime
      char   *sndJobsTo
      char   *rcvJobsFrom
      char   *resumeCond
      char   *stopCond
      char   *jobStarter
      char   *suspendActCmd
      char   *resumeActCmd
      char   *terminateActCmd
      int    sigMap[30] #LSB_SIG_NUM
      char   *preemption
      int    maxRschedTime
      int    numOfSAccts
      shareAcctInfoEnt *shareAccts
      char   *chkpntDir
      int    chkpntPeriod
      int    imptJobBklg
      int    defLimits[12] # LSF_RLIM_NLIMITS
      int    chunkJobSize
      int    minProcLimit
      int    defProcLimit
      char   *fairshareQueues
      char   *defExtSched
      char   *mandExtSched
      int    slotShare
      char   *slotPool
      int    underRCond
      int    overRCond
      float  idleCond
      int    underRJobs
      int    overRJobs
      int    idleJobs
      int    warningTimePeriod
      char   *warningAction
      char   *qCtrlMsg
      char   *acResReq
      int    symJobLimit
      char   *cpuReq
      int    proAttr
      int    lendLimit
      int    hostReallocInterval
      int    numCPURequired
      int    numCPUAllocated
      int    numCPUBorrowed
      int    numCPULent
      int    schGranularity
      int    symTaskGracePeriod
      int    minOfSsm
      int    maxOfSsm
      int    numOfAllocSlots
      char   *servicePreemption
      int    provisionStatus
      int    minTimeSlice

    cdef struct parameterInfo:
      char   *defaultQueues
      char   *defaultHostSpec
      int    mbatchdInterval
      int    sbatchdInterval
      int    jobAcceptInterval
      int    maxDispRetries
      int    maxSbdRetries
      int    preemptPeriod
      int    cleanPeriod
      int    maxNumJobs
      float  historyHours
      int    pgSuspendIt
      char   *defaultProject
      int    retryIntvl
      int    nqsQueuesFlags
      int    nqsRequestsFlags
      int    maxPreExecRetry
      int    eventWatchTime
      float  runTimeFactor
      float  waitTimeFactor
      float  runJobFactor
      int    eEventCheckIntvl
      int    rusageUpdateRate
      int    rusageUpdatePercent
      int    condCheckTime
      int    maxSbdConnections
      int    rschedInterval
      int    maxSchedStay
      int    freshPeriod
      int    preemptFor
      int    adminSuspend
      int    userReservation
      float  cpuTimeFactor
      int    fyStart
      int    maxJobArraySize
      time_t exceptReplayPeriod
      int    jobTerminateInterval
      int    disableUAcctMap
      int    enforceFSProj
      int    enforceProjCheck
      int    jobRunTimes
      int    dbDefaultIntval
      int    dbHjobCountIntval
      int    dbQjobCountIntval
      int    dbUjobCountIntval
      int    dbJobResUsageIntval
      int    dbLoadIntval
      int    dbJobInfoIntval
      int    jobDepLastSub
      char   *dbSelectLoad
      int    jobSynJgrp
      char   *pjobSpoolDir
      int    maxUserPriority
      int    jobPriorityValue
      int    jobPriorityTime
      int    enableAutoAdjust
      int    autoAdjustAtNumPend
      float  autoAdjustAtPercent
      int    sharedResourceUpdFactor
      int    scheRawLoad
      char   *jobAttaDir
      int    maxJobMsgNum
      int    maxJobAttaSize
      int    mbdRefreshTime
      int    updJobRusageInterval
      char   *sysMapAcct
      int    preExecDelay
      int    updEventUpdateInterval
      int    resourceReservePerSlot
      int    maxJobId
      char   *preemptResourceList
      int    preemptionWaitTime
      int    maxAcctArchiveNum
      int    acctArchiveInDays
      int    acctArchiveInSize
      float  committedRunTimeFactor
      int    enableHistRunTime
      int    nqsUpdateInterval
      int    mcbOlmReclaimTimeDelay
      int    chunkJobDuration
      int    sessionInterval
      int    publishReasonJobNum
      int    publishReasonInterval
      int    publishReason4AllJobInterval
      int    mcUpdPendingReasonInterval
      int    mcUpdPendingReasonPkgSize
      int    noPreemptRunTime
      int    noPreemptFinishTime
      char   *acctArchiveAt
      int    absoluteRunLimit
      int    lsbExitRateDuration
      int    lsbTriggerDuration
      int    maxJobinfoQueryPeriod
      int    jobSubRetryInterval
      int    pendingJobThreshold
      int    maxConcurrentJobQuery
      int    minSwitchPeriod
      int    condensePendingReasons
      int    slotBasedParallelSched
      int    disableUserJobMovement
      int    detectIdleJobAfter
      int    useSymbolPriority
      int    JobPriorityRound
      char   *priorityMapping
      int    maxInfoDirs
      int    minMbdRefreshTime

    cdef struct lsbSharedResourceInstance:
      char   *totalValue
      char   *rsvValue
      int    nHosts
      char   **hostList

    cdef struct lsbSharedResourceInfo:
      char   *resourceName
      int    nInstances
      lsbSharedResourceInstance  *instances

    cdef struct procRange:
      int    minNumProcs
      int    maxNumProcs

    cdef struct addRsvRequest:
      int  options
      char *name
      procRange procRange
      int  numAskedHosts
      char **askedHosts
      char *resReq
      char *timeWindow

    cdef struct jgrp:
      char *name
      char *path
      char *user
      int  counters[8]

    cdef struct jobAttrInfoEnt:
      long long jobId
      int       port
      char      hostname[64]

    cdef struct jgrpAdd:
      char *groupSpec
      char *timeEvent
      char *depCond

    cdef struct jgrpMod:
      char    *destSpec
      jgrpAdd jgrp

    cdef struct jgrpReply:
      char *badJgrpName

    cdef struct jgrpCtrl:
      char *groupSpec
      int  options
      int  ctrlOp

    cdef struct objective:
      char *spec
      int  type
      int  state
      int  goal
      int  actual
      int  optimum
      int  minimum

    cdef enum objectives:
      GOAL_DEADLINE
      GOAL_VELOCITY
      GOAL_THROUGHPUT

    cdef struct serviceClass:
      char      *name
      float     priority
      int       ngoals
      objective *goals
      char      *userGroups
      char      *description
      char      *controlAction
      float     throughput
      int       counters[9]

    cdef struct dataLoggingLog:
      time_t loggingTime

    cdef struct logSwitchLog:
      int lastJobId

    cdef struct jobFinishLog:
      int    jobId
      int    userId
      char   userName[64]
      int    options
      int    numProcessors
      int    jStatus
      time_t submitTime
      time_t beginTime
      time_t termTime
      time_t startTime
      time_t endTime
      char   queue[64]
      char   *resReq
      char   fromHost[64]
      char   cwd[1024]
      char   inFile[256]
      char   outFile[256]
      char   errFile[256]
      char   inFileSpool[256]
      char   commandSpool[256]
      char   jobFile[256]
      int    numAskedHosts
      char   **askedHosts
      float  hostFactor
      int    numExHosts
      char   **execHosts
      float  cpuTime
      char   jobName[512]
      char   command[512]
      lsfRusage lsfRusage
      char   *dependCond
      char   *timeEvent
      char   *preExecCmd
      char   *mailUser
      char   *projectName
      int    exitStatus
      int    maxNumProcessors
      char   *loginShell
      int    idx
      int    maxRMem
      int    maxRSwap
      char   *rsvId
      char   *sla
      int    exceptMask
      char   *additionalInfo
      int    exitInfo
      int    warningTimePeriod
      char   *warningAction
      char   *chargedSAAP
      char   *licenseProject
      # According to /usr/include/lsf/lsbatch.h, we also have:
      char   *app
      char   *postExecCmd
      int    runtimeEstimation
      char   *jgroup

    cdef struct calendarLog:
      int    options
      int    userId
      char   *name
      char   *desc
      char   *calExpr

    cdef struct jobForwardLog:
      int   jobId
      char  *cluster
      int   numReserHosts
      char  **reserHosts
      int   idx
      int   jobRmtAttr

    cdef struct jobAcceptLog:
      int  jobId
      long remoteJid
      char *cluster
      int  idx
      int  jobRmtAttr

    cdef struct statusAckLog:
      int jobId
      int statusNum
      int idx

    cdef struct jobMsgLog:
      int  usrId
      int  jobId
      int  msgId
      int  type
      char *src
      char *dest
      char *msg
      int  idx

    cdef struct jobMsgAckLog:
      int  usrId
      int  jobId
      int  msgId
      int  type
      char *src
      char *dest
      char *msg
      int  idx

    cdef struct jobOccupyReqLog:
      int  userId
      int  jobId
      int  numOccupyRequests
      void *occupyReqList
      int  idx
      char userName[60]

    cdef struct jobVacatedLog:
      int  userId
      int  jobId
      int  idx
      char userName[60]

    cdef struct jobForceRequestLog:
      int     userId
      int     numExecHosts
      char    **execHosts
      int     jobId
      int     idx
      int     options
      char    userName[60]
      char    *queue

    cdef struct jobChunkLog:
      long    membSize
      long    *membJobId
      long    numExHosts
      char    **execHosts

    cdef struct jobExternalMsgLog:
      int     jobId
      int     idx
      int     msgIdx
      char    *desc
      int     userId
      long    dataSize
      time_t  postTime
      int     dataStatus
      char    *fileName
      char    userName[60]

    cdef struct jgrpNewLog:
      int    userId
      time_t submitTime
      char   userName[60]
      char   *depCond
      char   *timeEvent
      char   *groupSpec
      char   *destSpec
      int    delOptions
      int    delOptions2
      int    fromPlatform

    cdef struct jgrpCtrlLog:
      int    userId
      char   userName[60]
      char   *groupSpec
      int    options
      int    ctrlOp

    cdef struct jgrpStatusLog:
      char   *groupSpec
      int    status
      int    oldStatus

    cdef struct jobNewLog:
      int    jobId
      int    userId
      char   userName[60]
      int    options
      int    options2
      int    numProcessors
      time_t submitTime
      time_t beginTime
      time_t termTime
      int    sigValue
      int    chkpntPeriod
      int    restartPid
      int    rLimits[12]
      char   hostSpec[64]
      float  hostFactor
      int    umask
      char   queue[60]
      char   *resReq
      char   fromHost[64]
      char   cwd[256]
      char   chkpntDir[256]
      char   inFile[256]
      char   outFile[256]
      char   errFile[256]
      char   inFileSpool[256]
      char   commandSpool[256]
      char   jobSpoolDir[1024]
      char   subHomeDir[256]
      char   jobFile[256]
      int    numAskedHosts
      char   **askedHosts
      char   *dependCond
      char   *timeEvent
      char   jobName[512]
      char   command[512]
      int    nxf
      xFile  *xs
      char   *preExecCmd
      char   *mailUser
      char   *projectName
      int    niosPort
      int    maxNumProcessors
      char   *schedHostType
      char   *loginShell
      char   *userGroup
      char   *exceptList
      int    idx
      int    userPriority
      char   *rsvId
      char   *jobGroup
      char   *extsched
      int    warningTimePeriod
      char   *warningAction
      char   *sla
      int    SLArunLimit
      char   *licenseProject

    cdef struct jobModLog:
      char    *jobIdStr
      int     options
      int     options2
      int     delOptions
      int     delOptions2
      int     userId
      char    *userName
      int     submitTime
      int     umask
      int     numProcessors
      int     beginTime
      int     termTime
      int     sigValue
      int     restartPid
      char    *jobName
      char    *queue
      int     numAskedHosts
      char    **askedHosts
      char    *resReq
      int     rLimits[12]
      char    *hostSpec
      char    *dependCond
      char    *timeEvent
      char    *subHomeDir
      char    *inFile
      char    *outFile
      char    *errFile
      char    *command
      char    *inFileSpool
      char    *commandSpool
      int     chkpntPeriod
      char    *chkpntDir
      int     nxf
      xFile *xf
      char    *jobFile
      char    *fromHost
      char    *cwd
      char    *preExecCmd
      char    *mailUser
      char    *projectName
      int     niosPorts
      int     maxNumProcessors
      char    *loginShell
      char    *schedHostType
      char    *userGroup
      char    *exceptList
      int     userPriority
      char    *rsvId
      char    *extsched
      int     warningTimePeriod
      char    *warningAction
      char    *jobGroup
      char    *sla
      char    *licenseProject

    cdef struct jobStartLog:
      int    jobId
      int    jStatus
      int    jobPid
      int    jobPGid
      float  hostFactor
      int    numExHosts
      char   **execHosts
      char   *queuePreCmd
      char   *queuePostCmd
      int    jFlags
      char   *userGroup
      int    idx
      char   *additionalInfo
      int    duration4PreemptBackfill

    cdef struct jobStartAcceptLog:
      int    jobId
      int    jobPid
      int    jobPGid
      int    idx

    cdef struct jobExecuteLog:
      int    jobId
      int    execUid
      char   *execHome
      char   *execCwd
      int    jobPGid
      char   *execUsername
      int    jobPid
      int    idx
      char   *additionalInfo
      int    SLAscaledRunLimit
      int    position
      char   *execRusage
      int    duration4PreemptBackfill

    cdef struct jobStatusLog:
      int    jobId
      int    jStatus
      int    reason
      int    subreasons
      float  cpuTime
      time_t endTime
      int    ru
      lsfRusage lsfRusage
      int   jFlags
      int   exitStatus
      int    idx
      int    exitInfo

    cdef struct sbdJobStatusLog:
      int    jobId
      int    jStatus
      int    reasons
      int    subreasons
      int    actPid
      int    actValue
      time_t actPeriod
      int    actFlags
      int    actStatus
      int    actReasons
      int    actSubReasons
      int    idx
      int    sigValue
      int    exitInfo

    cdef struct sbdUnreportedStatusLog:
      int       jobId
      int       actPid
      int       jobPid
      int       jobPGid
      int       newStatus
      int       reason
      int       subreasons
      lsfRusage lsfRusage
      int       execUid
      int       exitStatus
      char      *execCwd
      char      *execHome
      char      *execUsername
      int       msgId
      jRusage   runRusage
      int       sigValue
      int       actStatus
      int       seq
      int       idx
      int       exitInfo

    cdef struct jobSwitchLog:
      int    userId
      int    jobId
      char   queue[60]
      int    idx
      char   userName[60]

    cdef struct jobMoveLog:
      int    userId
      int    jobId
      int    position
      int    base
      int    idx
      char   userName[60]

    cdef struct chkpntLog:
      int    jobId
      time_t period
      int    pid
      int    ok
      int    flags
      int    idx

    cdef struct jobRequeueLog:
      int   jobId
      int   idx

    cdef struct jobCleanLog:
      int   jobId
      int   idx

    cdef struct jobExceptionLog:
      int    jobId
      int    exceptMask
      int    actMask
      time_t timeEvent
      int    exceptInfo
      int    idx

    cdef struct sigactLog:
      int      jobId
      time_t   period
      int      pid
      int      jStatus
      int      reasons
      int      flags
      char     *signalSymbol
      int      actStatus
      int      idx

    cdef struct migLog:
      int    jobId
      int    numAskedHosts
      char   **askedHosts
      int    userId
      int    idx
      char   userName[60]

    cdef struct signalLog:
      int    userId
      int    jobId
      char   *signalSymbol
      int    runCount
      int    idx
      char   userName[60]

    cdef struct queueCtrlLog:
      int    opCode
      char   queue[60]
      int    userId
      char   userName[60]
      char   message[512]

    cdef struct newDebugLog:
      int opCode
      int level
      int logclass
      int turnOff
      char logFileName[40]
      int userId

    cdef struct hostCtrlLog:
      int    opCode
      char   host[64]
      int    userId
      char   userName[60]
      char   message[512]

    cdef struct hgCtrlLog:
      int    opCode
      char   host[64]
      char   grpname[64]
      int    userId
      char   userName[60]
      char   message[512]

    cdef struct mbdStartLog:
      char   master[64]
      char   cluster[40]
      int    numHosts
      int    numQueues

    cdef struct mbdDieLog:
      char   master[64]
      int    numRemoveJobs
      int    exitCode
      char   message[512]

    cdef struct unfulfillLog:
      int    jobId
      int    notSwitched
      int    sig
      int    sig1
      int    sig1Flags
      time_t chkPeriod
      int    notModified
      int    idx
      int    miscOpts4PendSig

    cdef struct rsvRes:
      char   *resName
      int    count
      int    usedAmt

    cdef struct rsvFinishLog:
      time_t rsvReqTime
      int    options
      int    uid
      char   *rsvId
      char   *name
      int    numReses
      rsvRes *alloc
      char   *timeWindow
      time_t duration
      char   *creator

    cdef struct cpuProfileLog:
      char servicePartition[60]
      int  slotsRequired
      int  slotsAllocated
      int  slotsBorrowed
      int  slotsLent

    cdef union eventLog:
      jobNewLog jobNewLog
      jobStartLog jobStartLog
      jobStatusLog jobStatusLog
      sbdJobStatusLog sbdJobStatusLog
      jobSwitchLog jobSwitchLog
      jobMoveLog jobMoveLog
      queueCtrlLog queueCtrlLog
      newDebugLog  newDebugLog
      hostCtrlLog hostCtrlLog
      mbdStartLog mbdStartLog
      mbdDieLog mbdDieLog
      unfulfillLog unfulfillLog
      jobFinishLog jobFinishLog
      loadIndexLog loadIndexLog
      migLog migLog
      calendarLog calendarLog
      jobForwardLog jobForwardLog
      jobAcceptLog jobAcceptLog
      statusAckLog statusAckLog
      signalLog signalLog
      jobExecuteLog jobExecuteLog
      jobMsgLog jobMsgLog
      jobMsgAckLog jobMsgAckLog
      jobRequeueLog jobRequeueLog
      chkpntLog chkpntLog
      sigactLog sigactLog
      jobOccupyReqLog jobOccupyReqLog
      jobVacatedLog jobVacatedLog
      jobStartAcceptLog jobStartAcceptLog
      jobCleanLog jobCleanLog
      jobExceptionLog jobExceptionLog
      jgrpNewLog jgrpNewLog
      jgrpCtrlLog jgrpCtrlLog
      jobForceRequestLog jobForceRequestLog
      logSwitchLog logSwitchLog
      jobModLog jobModLog
      jgrpStatusLog jgrpStatusLog
      jobAttrSetLog jobAttrSetLog
      jobExternalMsgLog jobExternalMsgLog
      jobChunkLog jobChunkLog
      sbdUnreportedStatusLog sbdUnreportedStatusLog
      rsvFinishLog rsvFinishLog
      hgCtrlLog hgCtrlLog
      cpuProfileLog cpuProfileLog
      dataLoggingLog dataLoggingLog

    cdef struct eventRec:
      char     version[12]
      int      type
      time_t   eventTime
      eventLog eventLog

    cdef struct eventLogFile:
      char eventDir[256]
      time_t beginTime, endTime

    cdef struct eventLogHandle:
      FILE *fp
      char openEventFile[256]
      int  curOpenFile
      int  lastOpenFile

    cdef struct signalBulkJobs:
      int      signal
      int      njobs
      long int *jobs
      int      flags

    cdef struct runJobRequest:
      long int jobId
      int      numHosts
      char     **hostname
      int      options
      int      *slots

    cdef struct jobExternalMsgReq:
      int      options
      int      jobId
      char     *jobName
      int      msgIdx
      char     *desc
      int      userId
      long int dataSize
      time_t   postTime
      char     *userName

    cdef extern int c_lsb_init "lsb_init" (char *)

    cdef extern parameterInfo *c_lsb_parameterinfo "lsb_parameterinfo" (char **, int *, int)

    cdef extern void c_lsb_closejobinfo  "lsb_closejobinfo" ()

    cdef extern int c_lsb_openjobinfo    "lsb_openjobinfo" (long long int, char *, char *, char *, char *, int)

    cdef extern jobInfoHead *c_lsb_openjobinfo_a  "lsb_openjobinfo_a" (long long int, char *, char *, char *, char *, int)

    cdef extern userInfoEnt *c_lsb_userinfo     "lsb_userinfo" (char **, int *)

    cdef extern groupInfoEnt *c_lsb_usergrpinfo "lsb_usergrpinfo" (char **, int *, int)

    cdef extern jobInfoEnt *c_lsb_readjobinfo   "lsb_readjobinfo" (int *)

    cdef extern condHostInfoEnt *c_lsb_hostinfo_cond "lsb_hostinfo_cond" (char **, int *, char *, int)

    cdef extern hostInfoEnt *c_lsb_hostinfo "lsb_hostinfo" (char **, int *)

    cdef extern groupInfoEnt *c_lsb_hostgrpinfo "lsb_hostgrpinfo" (char **, int *, int)

    cdef extern hostPartInfoEnt *c_lsb_hostpartinfo "lsb_hostpartinfo" (char **, int *)

    cdef extern long long int c_lsb_modify "lsb_modify" (submit *, submitReply *, long long int)

    cdef extern float* c_getCpuFactor "getCpuFactor" (char *, int)

    cdef extern char* c_lsb_suspreason "lsb_suspreason" (int, int, loadIndexLog *)

    cdef extern char* c_lsb_pendreason "lsb_pendreason" (int, int *, jobInfoHead *, loadIndexLog *, int)

    cdef extern int c_lsb_requeuejob   "lsb_requeuejob" (jobrequeue *)
    cdef extern int c_lsb_movejob      "lsb_movejob" (long, int *, int)
    cdef extern int c_lsb_switchjob    "lsb_switchjob" (long, char *)
    cdef extern char* c_lsb_peekjob    "lsb_peekjob" (long)
    cdef extern int c_lsb_deletejob    "lsb_deletejob" (long, int, int)
    cdef extern int c_lsb_signaljob    "lsb_signaljob" (long, int)
    cdef extern int c_lsb_killbulkjobs "lsb_killbulkjobs" (signalBulkJobs *)
    cdef extern int c_lsb_forcekilljob "lsb_forcekilljob" (long)
    cdef extern int c_lsb_chkpntjob    "lsb_chkpntjob" (long, time_t, int)
    cdef extern int c_lsb_msgjob       "lsb_msgjob"    (long, char *)
    cdef extern int c_lsb_mig          "lsb_mig" (submig *, int *)
    cdef extern int c_lsb_reconfig     "lsb_reconfig" (mbdCtrlReq *)

    cdef extern int c_lsb_queuecontrol "lsb_queuecontrol" (queueCtrlReq *)
    cdef extern queueInfoEnt *c_lsb_queueinfo "lsb_queueinfo" (char **, int *, char *, char *, int)

    cdef extern lsbSharedResourceInfo *c_lsb_sharedresourceinfo "lsb_sharedresourceinfo" (char **, int *, char *, int)

    cdef extern char* c_lsb_sysmsg "lsb_sysmsg" ()
    cdef extern void  c_lsb_perror "lsb_perror" (char *)

    # Routines to covert jobid to string


    # API for advance reservations

    cdef extern int c_lsb_addreservation "lsb_addreservation" (addRsvRequest *, char *)
    cdef extern rsvInfoEnt *c_lsb_reservationinfo "lsb_reservationinfo" (char *, int *, int)
    cdef extern int c_lsb_removereservation "lsb_removereservation" (char *)

    # API for job group

    cdef extern int   c_lsb_addjgrp   "lsb_addjgrp"  (jgrpAdd *, jgrpReply **)
    cdef extern int   c_lsb_modjgrp   "lsb_modjgrp"  (jgrpMod *, jgrpReply **)
    cdef extern int   c_lsb_holdjgrp  "lsb_holdjgrp" (char *, int, jgrpReply **)
    cdef extern int   c_lsb_reljgrp   "lsb_reljgrp"  (char *, int, jgrpReply **)
    cdef extern int   c_lsb_deljgrp   "lsb_deljgrp"  (char *, int, jgrpReply **)
    cdef extern jgrp  *c_lsb_listjgrp "lsb_listjgrp" (int *)
    cdef extern serviceClass  *c_lsb_serviceClassInfo "lsb_serviceClassInfo" (int *)

    # API for event records

    cdef extern eventRec *c_lsb_geteventrec "lsb_geteventrec" (FILE *, int *)
    cdef extern int c_lsb_geteventrecbyline "lsb_geteventrecbyline" (char *, eventRec *)

    # API for submit

    cdef extern long c_lsb_submit "lsb_submit" (submit *, submitReply *)

    # API for runjob

    cdef extern int c_lsb_runjob "lsb_runjob" (runJobRequest *)

    # API for job attribute operations

    cdef extern int c_lsb_setjobattr "lsb_setjobattr" (int, jobAttrInfoEnt *)

    # API for job external message

    cdef extern int c_lsb_postjobmsg "lsb_postjobmsg" (jobExternalMsgReq *, char *)
    cdef extern int c_lsb_readjobmsg "lsb_readjobmsg" (jobExternalMsgReq *, jobExternalMsgReply *)

def version():

    """
    version    : Returns a string containing the
                 Pylsf version number

    Parameters : None

    Returns    : String
    """

    return ("0.0.1")

def ls_sysmsg():

    """
    ls_sysmg   : Obtains LSF error messages. The global variable lserrno,
                 maintained by LSLIB, indicates the error number of the most
                 recent LSLIB call that caused an error.

    Parameters : None

    Returns    : String
    """

    return cls_sysmsg()

def ls_perror(message = ""):

    """
    ls_perror  : Prints LSF error messages to standard out

    Parameters : String - Message

    Returns    : None
    """

    cdef char *Message

    Message = message

    cls_perror(Message)

    return

def ls_readconfenv(param_dict={}, config_dir=""):

    """
    ls_readconfenv : Reads the LSF configuration parameters from the
                     config_dir/lsf.conf file. If config_dir is empty,
                     the LSF configurable parameters are read from the
                     ${LSF_ENVDIR-/etc}/lsf.conf file.

    Parameters     : Dictionary - Conf variable strings
                     String     - Config directory

    Returns        : Tuple  - Numeric -  0 = successful,
                                        -1 = unsucessful

                              Dict    - Configuration params
    """

    cdef config_param *params

    cdef char *Config_dir
    cdef char *param_list_name
    cdef int  i

    # If no config directory passed then get
    # the value from LSF environment variable

    if config_dir == "":
       config_dir = getenv("LSF_ENVDIR")

    Config_dir = config_dir

    # For each parameter dict entry populate param struct

    count  = len(param_dict)
    params = NULL
    params = <config_param *>malloc((count+1)*sizeof(config_param))

    i = 0
    for k, v in param_dict.iteritems():
       param_list_name = k
       params[i].paramName  = param_list_name
       params[i].paramValue = NULL
       i = i + 1

    params[i].paramName  = NULL
    params[i].paramValue = NULL

    retval = cls_readconfenv(params, Config_dir)

    # If successful then read back param struct
    # to populate values into the param dictionary

    param_dict = {}
    if retval == 0:
      for i from 0 <= i < count:
         param_dict[params[i].paramName] = params[i].paramValue

    free(params)

    return retval, param_dict

def ls_isclustername(cluster = ""):

    """
    ls_isclustername  : Tests if the connected cluster is the one given

    Parameters        : String - Clustername

    Returns           : 1 = True, 0 = False
    """

    cdef char *ClusterName

    ClusterName = cluster

    retval = cls_isclustername(ClusterName)

    return retval

def ls_getclustername():

    """
    ls_getclustername : Gets the local cluster name
                        If the function fails, lserrno is set to
                        indicate the error.

    Parameters        : None

    Returns           : String
    """

    return cls_getclustername()

def ls_gethostmodel(host_name=""):

    """
    ls_gethostmodel : Gets the model type for a host.

    Parameters      : String - HostName

    Returns         : String
    """

    cdef char *Host_name

    Host_name = host_name

    model_type = cls_gethostmodel(Host_name)

    return model_type

def ls_gethosttype(host_name=""):

    """
    ls_gethosttype  : Gets the type of the specified host.
                      If the function fails, lserrno is set
                      to indicate the error.

    Parameters      : String - HostName

    Returns         : String
    """

    cdef char *Host_name

    Host_name = host_name

    host_type = cls_gethosttype(Host_name)

    return host_type

def ls_gethostfactor(host_name=""):

    """
    ls_gethostfactor : Gets pointer to a floating point number that
                       contains the CPU factor of the specified host.

    Parameters       : String - HostName

    Returns          : float
    """

    cdef char *Host_name

    Host_name = host_name

    factor = float(<char>cls_gethostfactor(Host_name))

    return factor

def ls_getmodelfactor(model=""):

    """
    ls_getmodelfactor : Gets the CPU normalization factor of the
                        specified host model.
                        If the function fails, lserrno is set to
                        indicate the error.

    Parameters        : String - Model name

    Returns           : float
    """

    cdef char *Model_name

    Model_name = model

    factor = float(<char>cls_getmodelfactor(Model_name))

    return factor

def ls_getmastername():

    """
    ls_getmastername : Gets the name of the host runnning the local
                       load sharing cluster's master LIM.

    Parameters       : None

    Returns          : String
    """

    return cls_getmastername()

def ls_getmyhostname():

    """
    ls_getmyhostname : Gets the name of the host runnning the local
                       load sharing cluster's master LIM.

    Parameters       : None

    Returns          : String
    """

    return cls_getmyhostname()

def ls_getmnthost(file=""):

    """
    ls_getmnthost : Gets the name of the file server that exports
                    the file system containing file, where file is
                    a relative or absolute path name.

    Parameters    : String - filename

    Returns       : String
    """

    cdef char *File_name

    File_name = file

    retval = cls_getmnthost(File_name)

    return retval

def ls_indexnames():

    """
    ls_indexnames : Returns a list of indexnames retrieved
                    from the ls_info call

    Parameters    : None

    Returns       : List
    """

    cdef lsInfo *lsinfo

    cdef char **IndexNames
    cdef int  i

    lsinfo = cls_info()
    IndexNames = NULL
    IndexNames = cls_indexnames(lsinfo)

    IndexList = []
    for i from 0 <= i < lsinfo.numIndx:
      IndexList.append(IndexNames[i])

    return IndexList

def ls_load():

    """
    ls_load    : Returns all load indices.

    Parameters : None

    Returns    : List - [ host, status, load list ]
    """

    cdef hostLoad *hosts

    cdef char *resreq
    cdef char *fromhost
    cdef int  numHosts
    cdef int  options
    cdef int  i
    cdef int  y

    resreq   = NULL
    fromhost = NULL
    options  = 0
    numHosts = 0

    hosts = cls_load(resreq, &numHosts, options, fromhost)

    IndexList = []
    for i from 0 <= i < numHosts:
      floatList = []
      for y from 0 <= y < 11:
        floatList.append( "%0.1f" % hosts[i].li[y] )
      IndexList.append([hosts[i].hostName, hosts[i].status[0], floatList])

    return IndexList

def ls_loadinfo():

    """
    ls_loadinfo : Gets the requested load indices of the hosts that
                  satisfy specified resource requirements.

    Parameters  : None

    Returns     : List
    """

    cdef hostLoad *hosts

    cdef char *resreq
    cdef char *fromhost
    cdef char **nlp
    cdef char *defaultindex
    cdef char *hostnames[256]
    cdef int  hostlistsize
    cdef int  numHosts
    cdef int  options
    cdef int  i
    cdef int  y

    nlp = NULL
    resreq = NULL
    fromhost = NULL
    hostlistsize = 0
    options  = 0
    numHosts = 0

    hosts = cls_loadinfo(resreq, &numHosts, options, fromhost, hostnames, hostlistsize, &nlp)

    loadList = []
    for i from 0 <= i < numHosts:

      liList = []
      for y from 0 <= y < 11: # Num of load Indicies
         liList.append( hosts[i].li[y] )

      loadList.append( [ hosts[i].hostName,
                         hosts[i].status[0],
                         liList
                       ] )

    return loadList

def ls_loadadj(resource=""):

    """
    ls_loadadj   : Sends a load adjustment request to LIM after the
                   execution host or hosts have been selected outside
                   the LIM by the calling application. Use this call
                   only if a placement decision is made by the
                   application without calling ls_placereq()
                   (for example, a decision based on the load information
                   from an earlier ls_load() call). This request keeps
                   LIM informed of task transfers so that the potential
                   load increase on the destination host() provided in
                   placeinfo are immediately taken into consideration
                   in future LIM placement decisions. listsize gives
                   the total number of entries in placeinfo.

                   lserrno is set to indicate the error.

    Returns       : 0 - successful, -1 - unsucessful
    """

    cdef placeInfo myhost

    cdef char *hostname
    cdef char *resreq
    cdef int  numHosts

    resreq = resource

    numHosts = len(hostlist)
    host = hostlist[0]
    hostname = host
    strcpy(myhost.hostName, hostname)
    myhost.numtask = 1

    retval = cls_loadadj(resreq, &myhost, numHosts)

    return retval

def ls_lockhost(duration=0):

    """
    ls_lockhost : Locks the local host for a specified number of seconds.
                  Prevents a host from being selected by the master LIM
                  for task or job placement. If the host is locked for
                  0 seconds, it remains locked until it is explicitly
                  unlocked by ls_unlockhost(). Indefinitely locking a
                  host is useful if a job or task must run exclusively
                  on the local host, or if machine owners want private
                  control over their machines.

                  A program using ls_lockhost() must be setuid to root
                  in order for the LSF administrator or any other user
                  to lock a host.

                  On failure, lserrno is set to indicate the error.
                  If the host is already locked, ls_lockhost() sets
                  lserrno to LSE_LIM_ALOCKED.

    Parameters  : Numeric - seconds

    Returns     : 0 = unsucessful, -1 = successful
    """

    cdef time_t Duration

    Duration = duration

    retval = cls_lockhost(Duration)

    return retval

def ls_unlockhost():

    """
    ls_unlockhost : Unlocks a host locked by ls_lockhost().
                    On success, ls_unlockhost() changes the status
                    of the local host to indicate that it is no 
                    longer locked by the user.

    Parameters    : None

    Returns       : 0 = unsucessful, -1 = successful
    """

    return cls_unlockhost()

def ls_info():

    cdef lsInfo  *lsinfo
    cdef resItem *resTable

    cdef int i

    lsinfo = cls_info()

    ResTable = []
    for i from 0 <= i < lsinfo.nRes:
      ResTable.append( [lsinfo.resTable[i].name, lsinfo.resTable[i].des] )

    HostTypes = []
    for i from 0 <= i < lsinfo.nTypes:
      HostTypes.append( lsinfo.hostTypes[i] )

    HostModels = []
    for i from 0 <= i < lsinfo.nModels:
      HostModels.append( [lsinfo.hostModels[i], lsinfo.cpuFactor[i]] )

    Info_list = [ ResTable, HostTypes, HostModels ]

    return Info_list

def ls_gethostinfo(host_list=[]):

   """
   ls_gethostinfo  : Returns static resource information about hosts.
                     Static resources include configuration information
                     as determined by LSF configuration files as well as
                     others determined automatically by LIM at start up.

   Parameters      : List - hostnames

   Returns         : List of Lists for each host -

                       0 - hostName
                       1 - hostType
                       2 - hostModel
                       3 - cpuFactor
                       4 - maxCpus
                       5 - maxMem
                       6 - maxSwap
                       7 - maxTmp
                       8 - nDisks
                       9 - resources list
                      10 - Dresources list
                      11 - windows
                      12 - BusyThreshold list
                      13 - isServer
                      14 - licensed
                      15 - rexPriority
                      16 - licFeaturesNeeded
   """

   cdef hostInfo *hostinfo

   cdef char  * Resreq
   cdef char  **Host_list
   cdef int   num_hosts
   cdef int   List_size
   cdef int   Options
   cdef int   counter
   cdef int   i
   cdef int   y
   cdef float tfloat

   Resreq = NULL
   Options = 0
   num_hosts = 0
   List_size = len(host_list)
   Host_list = pyStringSeqToStringArray(host_list)

   hostinfo = cls_gethostinfo(Resreq, &num_hosts, Host_list, List_size, Options)

   # convert C struct to list of lists

   host_info = []

   for counter from 0 <= counter < num_hosts:

     hostinfo[counter].busyThreshold = &tfloat

     resources = []
     for i from 0 <= i < hostinfo[counter].nRes:
        currDest = hostinfo[counter].resources[i]
        resources.append(currDest)

     Dresources = []
     for i from 0 <= i < hostinfo[counter].nDRes:
        currDest = hostinfo[counter].DResources[i]
        Dresources.append(currDest)

     BusyThreshold = []
     for i from 0 <= i < hostinfo[counter].numIndx:
        currDest = <float>hostinfo[counter].busyThreshold[i]
        BusyThreshold.append(currDest)

     host_info.append( [hostinfo[counter].hostName,
                        hostinfo[counter].hostType,
                        hostinfo[counter].hostModel,
                        <float>hostinfo[counter].cpuFactor,
                        hostinfo[counter].maxCpus,
                        hostinfo[counter].maxMem,
                        hostinfo[counter].maxSwap,
                        hostinfo[counter].maxTmp,
                        hostinfo[counter].nDisks,
                        resources,
                        Dresources,
                        hostinfo[counter].windows,
                        BusyThreshold,
                        hostinfo[counter].isServer,
                        hostinfo[counter].licensed,
                        hostinfo[counter].rexPriority,
                        hostinfo[counter].licFeaturesNeeded
                       ] )

   free(Host_list)

   return host_info

def ls_clusterinfo(cluster_list=[]):

   """
   ls_clusterinfo : Returns information on clusters

   Parameters     : List - cluster names

   Returns        : List of Lists for clusters -

                      0 - clusterName
                      1 - status
                      2 - masterName
                      3 - managerName
                      4 - managerId
                      5 - numServers
                      6 - numClients
                      7 - nRes
                      8 - resources list
                      9 - nTypes
                     10 - hostTypes list
                     11 - nModels
                     12 - nAdmins
                     13 - analyzerLicFlag
                     14 - jsLicFlag
                     15 - afterHoursWindow
                     16 - preferAuthName
                     17 - inUseAuthName
   """

   cdef clusterInfo *clusterinfo

   cdef char *Resreq
   cdef char **Cluster_list
   cdef int  Cluster_num
   cdef int  List_size
   cdef int  Options
   cdef int  counter
   cdef int  i

   Resreq = NULL
   Options = 0
   List_size = len(cluster_list)
   Cluster_num = 0
   Cluster_list = pyStringSeqToStringArray(cluster_list)

   clusterinfo = cls_clusterinfo(Resreq, &Cluster_num, Cluster_list, List_size, Options)

   # convert C struct to Python list of lists

   counter = 0
   info_list = []
   hostTypes = []

   for counter from 0 <= counter < Cluster_num:

     for i from 0 <= i < clusterinfo[counter].nTypes:
        currDest = clusterinfo[counter].hostTypes[i]
        hostTypes.append(currDest)

     resources = []
     for i from 0 <= i < clusterinfo[counter].nRes:
        currDest = clusterinfo[counter].resources[i]
        resources.append(currDest)

     info_list.append( [clusterinfo[counter].clusterName,
                        clusterinfo[counter].status,
                        clusterinfo[counter].masterName,
                        clusterinfo[counter].managerName,
                        clusterinfo[counter].managerId,
                        clusterinfo[counter].numServers,
                        clusterinfo[counter].numClients,
                        clusterinfo[counter].nRes,
                        resources,
                        clusterinfo[counter].nTypes,
                        hostTypes,
                        clusterinfo[counter].nModels,
                        clusterinfo[counter].nAdmins,
                        clusterinfo[counter].analyzerLicFlag,
                        clusterinfo[counter].jsLicFlag,
                        clusterinfo[counter].afterHoursWindow,
                        clusterinfo[counter].preferAuthName,
                        clusterinfo[counter].inUseAuthName] )

   free(Cluster_list)

   return info_list

def ls_limcontrol(host="", operation=0):

   """
   ls_limcontrol : Shuts down or reboots a host's LIM.

   Parameters    : String  - host,
                   Numeric - operation

   Returns       : 0 = successful, -1 = unsuccessful
   """

   cdef char *hostname
   cdef int  opcode

   hostname = host
   opcode   = int(operation)

   retval = cls_limcontrol(hostname, opcode)

   return retval

def ls_rescontrol(host="", operation=4, data=0):


   """
   ls_rescontrol : Controls and maintains the Remote Execution Server.

   Parameters    : String  - host,
                   Numeric - 1 (reboot)   RES_CMD_REBOOT
                             2 (shutdown) RES_CMD_SHUTDOWN
                             3 (logon)    RES_CMD_LOGON
                             4 (logoff)   RES_CMD_LOGOFF

                   Numeric - data for logon operation

   Returns       : 0 = successful, -1 = unsuccessful
   """

   cdef char *hostname
   cdef int  opcode
   cdef int  opdata

   hostname = host
   opcode   = int(operation)
   opdata   = int(data)

   retval = cls_rescontrol(hostname, opcode, opdata)

   return retval

def lsb_userinfo(user_list=[]):

   """
   lsb_userinfo : Returns the maximum number of job slots that
                  a user can use simultaneously on any host and
                  in the whole local LSF cluster, as well as the
                  current number of job slots used by running and
                  suspended jobs or reserved for pending jobs.

   Parameters   : List - users

   Returns      : List of Lists containing data for each user -

                    0 - user
                    1 - procJobLimit
                    2 - maxJobs
                    3 - numStartJobs
                    4 - numJobs
                    5 - numPEND
                    6 - numRUN
                    7 - numSSUSP
                    8 - numUSUSP
                    9 - numRESERVE
                   10 - maxPendJobs
   """

   cdef userInfoEnt *userinfoent

   cdef char **User_list
   cdef int  List_size
   cdef int  i

   List_size = len(user_list)
   User_list = pyStringSeqToStringArray(user_list)

   userinfoent = c_lsb_userinfo(User_list, &List_size)

   UserInfo = []
   for i from 0 <= i < List_size:
      UserInfo.append( [ userinfoent[i].user,
                         userinfoent[i].procJobLimit,
                         userinfoent[i].maxJobs,
                         userinfoent[i].numStartJobs,
                         userinfoent[i].numJobs,
                         userinfoent[i].numPEND,
                         userinfoent[i].numRUN,
                         userinfoent[i].numSSUSP,
                         userinfoent[i].numUSUSP,
                         userinfoent[i].numRESERVE,
                         userinfoent[i].maxPendJobs ] )

   free(User_list)

   return UserInfo

def lsb_closejobinfo():

   """
   lsb_closejobinfo : Closes the connection to the master batch daemon
                      after opening a job information connection with
                      lsb_openjobinfo() and reading job records with
                      lsb_readjobinfo().
                      On failure lsberrno is set to indicate the error.

   Parameters       : None

   Returns          : None
   """

   c_lsb_closejobinfo()

   return

def lsb_readjobinfo(num_of_records):

   """
   lsb_readjobinfo : Returns the next job information record
                     in the master batch daemon

   Parameters      : Numeric - Number of records to return

   Returns         : List, each job entry contains -

                       0 - jobId
                       1 - user
                       2 - status
                       3 - jobPid
                       4 - submitTime
                       5 - reserveTime
                       6 - startTime
                       7 - predictedStartTime
                       8 - endTime
                       9 - lastEvent
                      10 - nextEvent
                      11 - duration
                      12 - cpuTime
                      13 - umask
                      14 - cwd
                      15 - subHomeDir
                      16 - fromHost
                      17 - [ ExHosts ]
                      18 - cpuFactor
                      19 - [ 0 - jobName
                             1 - queue
                             2 - AskedHosts
                             3 - resReq
                             4 - hostSpec
                             5 - numProcessors
                             6 - dependCond
                             7 - beginTime
                             8 - termTime
                             9 - sigValue
                            10 - inFile
                            11 - outFile
                            12 - errFile
                            13 - command
                            14 - chkpntPeriod
                            15 - preExecCmd
                            16 - mailUser
                            17 - projectName
                            18 - maxNumProcessors
                            19 - loginShell
                            20 - userGroup
                            21 - exceptList
                            22 - userPriority
                            23 - rsvId
                            24 - jobGroup
                            25 - sla
                            26 - extsched
                            27 - warningTimePeriod
                            28 - warningAction
                            29 - licenseProject
                           ]
                      20 - exitStatus
                      21 - execUid
                      22 - execHome
                      23 - execCwd
                      24 - execUsername
                      25 - jRusageUpdateTime
                      26 - jType
                      27 - parentGroup
                      28 - jName
                      29 - jobPriority
                      30 - [ 0 - msgIdx
                             1 - desc
                             2 - userId
                             3 - dataSize
                             4 - postTime
                             5 - dataStatus
                             6 - userName
                           ]
                      31 - clusterId
                      32 - detailReason
                      33 - idleFactor
                      34 - exceptMask
                      35 - additionalInfo
                      36 - exitInfo
                      37 - warningTimePeriod
                      38 - warningAction
                      39 - chargedSAAP
                      40 - execRusage
                      41 - rsvInActive
                      42 - Licenses
                      43 - rusage
                      44 - rlimits
   """

   cdef jobInfoEnt *jobinfoent
   cdef jobExternalMsgReply *externalMsg
   cdef submit *submit
   cdef jRusage *runRusage

   cdef int Num_of_recs
   cdef int i

   Num_of_recs = int(num_of_records)

   jobinfoent = c_lsb_readjobinfo(&Num_of_recs)

   ExHosts = []
   for i from 0 <= i < jobinfoent.numExHosts:
      currDest = jobinfoent.exHosts[i]
      ExHosts.append(currDest)
   ExHosts = __countDuplicatesInList(ExHosts)

   Licenses = []
   for i from 0 <= i < jobinfoent.numLicense:
      currDest = jobinfoent.licenseNames[i]
      Licenses.append(currDest)

   AskedHosts = []
   for i from 0 <= i < jobinfoent.submit.numAskedHosts:
      currDest = jobinfoent.submit.askedHosts[i]
      AskedHosts.append(currDest)

   newCmd = ""
   if jobinfoent.submit.newCommand != NULL:
      newCmd = jobinfoent.submit.newCommand

   warningAction = ""
   if jobinfoent.warningAction != NULL:
      warningAction = jobinfoent.warningAction

   submitwarningAction = ""
   if jobinfoent.submit.warningAction != NULL:
      submitwarningAction = jobinfoent.submit.warningAction

   chargedSAAP = ""
   if jobinfoent.chargedSAAP != NULL:
      chargedSAAP = jobinfoent.chargedSAAP

   execHome = ""
   if jobinfoent.execHome != NULL:
      execHome = jobinfoent.execHome

   rUsage = [ jobinfoent.runRusage.mem,
              jobinfoent.runRusage.swap,
              jobinfoent.runRusage.utime,
              jobinfoent.runRusage.stime,
              jobinfoent.runRusage.npids,
              #pidInfo *pidInfo
              jobinfoent.runRusage.npgids,
              #int *pgid
              jobinfoent.runRusage.nthreads ]

   rlimitsList = []
   for y from 0 <= y < 12:
      rlimitsList.append( jobinfoent.submit.rLimits[y] )

   Msgs = []
   for i from 0 <= i < jobinfoent.numExternalMsg:
      Msgs.append( [jobinfoent.externalMsg[i].msgIdx,
                    jobinfoent.externalMsg[i].desc,
                    jobinfoent.externalMsg[i].userId,
                    jobinfoent.externalMsg[i].dataSize,
                    jobinfoent.externalMsg[i].postTime,
                    jobinfoent.externalMsg[i].dataStatus,
                    jobinfoent.externalMsg[i].userName] )

   SubmitList = [ jobinfoent.submit.jobName,
                  jobinfoent.submit.queue,
                  AskedHosts,
                  jobinfoent.submit.resReq,
                  jobinfoent.submit.hostSpec,
                  jobinfoent.submit.numProcessors,
                  jobinfoent.submit.dependCond,
                  jobinfoent.submit.beginTime,
                  jobinfoent.submit.termTime,
                  jobinfoent.submit.sigValue,
                  jobinfoent.submit.inFile,
                  jobinfoent.submit.outFile,
                  jobinfoent.submit.errFile,
                  jobinfoent.submit.command,
                  newCmd,
                  jobinfoent.submit.chkpntPeriod,
                  jobinfoent.submit.preExecCmd,
                  jobinfoent.submit.mailUser,
                  jobinfoent.submit.projectName,
                  jobinfoent.submit.maxNumProcessors,
                  jobinfoent.submit.loginShell,
                  jobinfoent.submit.userGroup,
                  jobinfoent.submit.exceptList,
                  jobinfoent.submit.userPriority,
                  jobinfoent.submit.rsvId,
                  jobinfoent.submit.jobGroup,
                  jobinfoent.submit.sla,
                  jobinfoent.submit.extsched,
                  jobinfoent.submit.warningTimePeriod,
                  submitwarningAction,
                  jobinfoent.submit.licenseProject]

   retval = [ jobinfoent.jobId,
              jobinfoent.user,
              jobinfoent.status,
              jobinfoent.jobPid,
              jobinfoent.submitTime,
              jobinfoent.reserveTime,
              jobinfoent.startTime,
              jobinfoent.predictedStartTime,
              jobinfoent.endTime,
              jobinfoent.lastEvent,
              jobinfoent.nextEvent,
              jobinfoent.duration,
              jobinfoent.cpuTime,
              jobinfoent.umask,
              jobinfoent.cwd,
              jobinfoent.subHomeDir,
              jobinfoent.fromHost,
              ExHosts,
              jobinfoent.cpuFactor,
              SubmitList,
              jobinfoent.exitStatus,
              jobinfoent.execUid,
              execHome,
              jobinfoent.execCwd,
              jobinfoent.execUsername,
              jobinfoent.jRusageUpdateTime,
              jobinfoent.jType,
              jobinfoent.parentGroup,
              jobinfoent.jName,
              jobinfoent.jobPriority,
              Msgs,
              jobinfoent.clusterId,
              jobinfoent.detailReason,
              jobinfoent.idleFactor,
              jobinfoent.exceptMask,
              jobinfoent.additionalInfo,
              jobinfoent.exitInfo,
              jobinfoent.warningTimePeriod,
              warningAction,
              chargedSAAP,
              jobinfoent.execRusage,
              jobinfoent.rsvInActive,
              Licenses,
              rUsage,
              rlimitsList ]

   return retval

def lsb_openjobinfo(user="all"):

   """
   lsb_openjobinfo : Accesses information about pending, running 
                     and suspended jobs in the master batch daemon.
                     Use lsb_openjobinfo() to create a connection
                     to the master batch daemon.
                     Next, use lsb_readjobinfo() to read job records.
                     Close the connection using lsb_closejobinfo().

   Parameters      : String - User

   Returns         : Value = num of records, -1 = unsuccessful
   """

   cdef char *User

   if user == "": user = "all"

   User = user
   job_num = c_lsb_openjobinfo(0, NULL, User, NULL, NULL, 17)

   return job_num

def lsb_openjobinfo_a(jobid=0, jobname="", user="", queue="", host="", options=0):

   """
   lsb_openjobinfo_a : Accesses information about pending, running and
                       suspended jobs in the master batch daemon.
                       Use lsb_openjobinfo() to create a connection to
                       the master batch daemon.
                       Next, use lsb_readjobinfo() to read job records.
                       Close the connection using lsb_closejobinfo().
                       Provides the name and number of jobs and hosts
                       in the master batch daemon.

   Parameters        : Numeric - jobid,
                       String  - jobname,
                       String  - user,
                       String  - queue,
                       String  - host,
                       Numeric - options

   Returns           : Number of job records
   """

   cdef jobInfoHead *jInfoH

   cdef long jobID
   cdef char *User
   cdef char *jobName
   cdef char *Queue
   cdef char *Host
   cdef int  Options

   jobID   = long(jobid)
   #Options = int(options) # TO BE IMPLEMENTED
   Options = 17

   if jobname == "":
     jobName = NULL
   else:
     jobName = jobname
   if queue == "":
     Queue = NULL
   else:
     Queue = queue
   if host == "":
     Host = NULL
   else:
     Host = host
   if user == "":
     User = NULL
   else:
     User = user

   jInfoH = c_lsb_openjobinfo_a(jobID, jobName, User, Queue, Host, Options)

   return jInfoH.numJobs

def lsb_hostinfo_cond(host_list=[]):

   """
   lsb_hostinfo_cond : Returns condensed information about job server hosts.
                       While lsb_hostinfo() returns specific information 
                       about individual hosts, lsb_hostinfo_cond() returns
                       the number of jobs in each state within the entire
                       host group.
                       If the function fails, lsberrno is set to indicate
                       the error.

   Parameters        : List - hosts

   Returns           : List of Lists of hosts -

                         0 - name
                         1 - howManyBusy
                         2 - howManyClosed
                         3 - howManyFull
                         4 - howManyUnreach
                         5 - howManyUnavail
   """

   cdef condHostInfoEnt *condhostinfo

   cdef char **Host_list
   cdef char *Resreq
   cdef int  Num_of_recs
   cdef int  Options

   Num_of_recs = 0
   Options = 0
   Resreq = NULL

   Host_list = pyStringSeqToStringArray(host_list)

   condhostinfo = c_lsb_hostinfo_cond(Host_list, &Num_of_recs, Resreq, 0)

   hostinfo = [ condhostinfo.name,
                condhostinfo.howManyBusy,
                condhostinfo.howManyClosed,
                condhostinfo.howManyFull,
                condhostinfo.howManyUnreach,
                condhostinfo.howManyUnavail ]

   free(Host_list)

   return hostinfo

def lsb_removereservation(resid=""):

   """
   lsb_removereservation : mbatchd removes the reservation with the
                           specified reservation ID.

   Parameters            : String - Reservation ID

   Returns               : 0 = successful, -1 = unsuccessful
   """

   cdef char *ResId

   ResId = resid

   retval = c_lsb_removereservation(ResId)

   return retval

def lsb_requeuejob(jobid=0, status=1, options=1):

   """
   lsb_requeuejob  : Use lsb_requeuejob()to requeue job arrays,
                     jobs in job arrays, and individual jobs that
                     are running, pending, done, or exited.
                     In a job array, you can requeue all the jobs or
                     requeue individual jobs of the array.

   Parameters      : Numeric - jobid,
                     Numeric - status,
                     Numeric - options

   Returns         : 0 = successful, -1 = unsuccessful
   """

   cdef jobrequeue *requeuejob

   cdef long JobId

   JobId = long(jobid)

   requeuejob = NULL
   requeuejob = <jobrequeue *>malloc(sizeof(jobrequeue))

   requeuejob.jobId   = JobId
   requeuejob.status  = int(status)
   requeuejob.options = int(options)

   retval = c_lsb_requeuejob(requeuejob)

   free(requeuejob)

   return retval

def lsb_movejob(jobid=0, position=1, opcode=1):

   """
   lsb_movejob : Move a job up or down the queue
                 Position the job in a queue by first specifying
                 the job ID. Next, count, beginning at 1, from
                 either the top or the bottom of the queue, to
                 the position you want to place the job.

                 To position a job at the top of a queue, choose 
                 the top of a queue parameter and a postion of 1.

                 To position a job at the bottom of a queue, choose
                 the bottom of the queue parameter and a position of 1.

                 If the function fails, lsberrno is set to indicate the error.

   Parameters  : Numeric - jobid,
                 Numeric - position,
                 Numeric - operation
                           1=TOP (default),
                           2=BOTTOM

   Returns     : 0 = successful, -1 = unsuccessful
   """

   cdef long JobId
   cdef int  Opcode
   cdef int  Position

   JobId    = long(jobid)
   Position = int(position)
   Opcode   = int(opcode)

   retval = c_lsb_movejob(JobId, &Position, Opcode)

   return retval

def lsb_deletejob(jobid=0, subTime=0, options=0):

    """
    lsb_deletejob : Send a signal to kill a running, user-suspended,
                    or system- suspended job. The job can be requeued 
                    or deleted from the batch system. If the job is requeued,
                    it retains its submit time but it is dispatched according
                    to its requeue time. When the job is requeued, it is
                    assigned the PEND status and re-run. If the job is deleted
                    from the batch system, it is no longer available to be requeued.
                    On failure, lsberrno is set to indicate the error.

    Parameters    : Numeric - jobid,
                    Numeric - submit time (Epoch Seconds),
                    Numeric - option

    Returns       : 0 = successful, -1 = successful
    """

    cdef long JobId
    cdef int  submitTime
    cdef int  Options

    JobId      = long(jobid)
    submitTime = int(subTime)
    Options    = int(options)

    retval = c_lsb_deletejob(JobId, submitTime, Options)

    return retval

def lsb_signaljob(jobid=0, signal=0):

    """
    lsb_signaljob : Migrating a job from one host to another.
                    Use lsb_signaljob() to stop or kill a job on a
                    host before using lsb_mig() to migrate the job.
                    Next, use lsb_signaljob() to continue the stopped
                    job at the specified host.

    Parameters    : Numeric - jobid,
                    Numeric - signal

    Returns       : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId
    cdef int  sigValue

    JobId    = long(jobid)
    sigValue = int(signal)

    retval = c_lsb_signaljob(JobId, sigValue)

    return retval

def lsb_killbulkjobs(jobIdList=[]):

    """
    lsb_killbulkjobs : Forces the termination of jobs

    Parameters       : List of numeric jobids

    Returns          : 0 = successful, -1 = unsuccessful
    """

    cdef signalBulkJobs s

    cdef char msg[80]
    cdef long *jobIds

    numJobs = len(jobIdList)
    jobIds  = pyLongSeqToLongArray(jobIdList)

    s.signal = sigValue
    s.njobs  = numJobs
    s.jobs   = jobIds
    s.flags  = 0

    retval = c_lsb_killbulkjobs(&s)

    return retval

def lsb_forcekilljob(jobid=0):

    """
    lsb_forcekilljob : Forces the termination of a job

    Parameters       : Numeric - jobid

    Returns          : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId

    JobId = long(jobid)

    retval = c_lsb_forcekilljob(JobId)

    return retval

def lsb_chkpntjob(jobid=0, ckptPeriod=0, options=0):

    """
    lsb_chkpntjob : Checkpoints a job
                    The checkpoint period in seconds. The value 0 disables
                    periodic checkpointing.
                    The bitwise inclusive OR of some of the following:
                    LSB_CHKPNT_KILL  - Checkpoint and kill the job as an atomic action.
                    LSB_CHKPNT_FORCE - Checkpoint the job even if non-checkpointable
                                       conditions exist.

                    If the function fails, lsberrno is set to indicate the error.

    Parameters    : Numeric - jobid,
                    Numeric - period,
                    Numeric - options

    Returns       : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId
    cdef int  CkptTime
    cdef int  Options

    JobId    = long(jobid)
    CkptTime = ckptPeriod
    Options  = options

    retval = c_lsb_chkpntjob(JobId, CkptTime, Options)

    return retval

def lsb_msgjob(jobid=0, message=""):

    """
    lsb_msgjob : Sends a message to a job

    Parameters : Numeric - jobid
                 String  - Message to send

    Returns    : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId
    cdef char *Msg

    JobId = long(jobid)
    Msg   = message

    retval = c_lsb_msgjob(JobId, Msg)

    return retval

def lsb_mig(jobid=0, hosts=[]):

    """
    lsb_mig    : Migrates a job from one host to another.
                 If the function fails lsberrno is set to
                 indicate the error.

    Parameters : Numeric - jobid,
                 List    - hostlist

    Returns    : 0 = successful, -1 = unsuccessful
    """

    cdef submig *mig

    cdef long JobId
    cdef char **Hosts
    cdef int  *badHostIdx
    cdef int  Operation
    cdef int  NumHosts
    cdef int  i

    JobId     = long(jobid)
    Operation = 0

    NumHosts = len(hosts)
    Hosts = pyStringSeqToStringArray(hosts)

    mig = NULL
    mig = <submig *>malloc(sizeof(submig))

    mig.jobId         = JobId
    mig.options       = Operation
    mig.numAskedHosts = NumHosts
    mig.askedHosts    = Hosts

    # Need to create an int array same size as the hosts

    for i from 0 <= i < NumHosts:
       badHostList.append(0)

    badHostIdx = NULL
    badHostIdx = pyIntSeqToIntArray(badHostList)

    retval = c_lsb_mig(mig, badHostIdx)

    free(Hosts)
    free(badHostIdx)

    return retval

def lsb_switchjob(jobid=0, queue=""):

    """
    lsb_switchjob : Switches an unfinished job to another queue.
                    Effectively, the job is removed from its current
                    queue and re-queued in the new queue. The switch
                    operation can be performed only when the job is
                    acceptable to the new queue. If the switch operation
                    is unsuccessful, the job will stay where it is.
                    If the function fails lsberrno is set to indicate
                    the error.

    Parameters    : Numeric - jobid,
                    String  - queue

    Returns       : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId
    cdef char *Queue

    JobId = long(jobid)
    Queue = queue

    retval = c_lsb_switchjob(JobId, Queue)

    return retval

def lsb_peekjob(jobid=0):

    """
    lsb_peekjob : Retrieves the name of a job's output file.
                  Only the submitter can peek at a job's output.

    Parameters  : Numeric - jobid

    Returns     : 0 = successful, -1 = unsuccessful
    """

    cdef long JobId

    JobId = long(jobid)

    retval = c_lsb_peekjob(JobId)

    return retval

def lsb_queuecontrol(queue="", operation=0, message=""):

    """
    lsb_queuecontrol : Retrieves the name of a job's output file.
                       Only the submitter can peek at a job's output.

    Parameters       : String  - jobqueue,
                       Numeric - operation,
                       String  - message

    Returns          : 0 = successful, -1 = unsuccessful
    """

    cdef queueCtrlReq *queuereq

    cdef char *queueName
    cdef int  Operation

    queueName = queue
    Message   = message
    Operation = int(operation)

    queuereq = NULL
    queuereq = <queueCtrlReq *>malloc(sizeof(queueCtrlReq))

    queuereq.queue   = queueName
    queuereq.opCode  = Operation
    queuereq.message = Message

    retval = c_lsb_queuecontrol(queuereq)

    return retval

def lsb_queueinfo():

    """
    lsb_queueinfo : Returns information about batch queues.
                    If the function fails, lsberrno is set to
                    indicate the error. If lsberrno is LSBE_BAD_QUEUE,
                    (*queues)[*numQueues] is not a queue known to the
                    LSF system. Otherwise, if *numQueues is less than
                    its original value, *numQueues is the actual number
                    of queues found.

    Parameters    : None

    Returns       : List of Lists containg queue info -

                      0 - queue,
                      1 - description,
                      2 - priority,
                      3 - nice,
                      4 - userList,
                      5 - hostList,
                      6 - hostStr,
                      7 - loadSched List,
                      8 - loadStop List,
                      9 - userJobLimit,
                     10 - procJobLimit,
                     11 - windows,
                     12 - rLimits,
                     13 - hostSpec,
                     14 - qAttrib,
                     15 - qStatus,
                     16 - maxJobs,
                     17 - numJobs,
                     18 - numPEND,
                     19 - numRUN,
                     20 - numSSUSP,
                     21 - numUSUSP,
                     22 - mig,
                     23 - schedDelay,
                     24 - acceptIntvl,
                     25 - windowsD,
                     26 - nqsQueues,
                     27 - userShares,
                     28 - defaultHostSpec,
                     29 - procLimit,
                     30 - admins,
                     31 - preCmd,
                     32 - postCmd,
                     33 - requeueEValues,
                     34 - hostJobLimit,
                     35 - resReq,
                     36 - numRESERVE,
                     37 - slotHoldTime,
                     38 - sndJobsTo,
                     39 - rcvJobsFrom,
                     40 - resumeCond,
                     41 - stopCond,
                     42 - jobStarter,
                     43 - suspendActCmd,
                     44 - resumeActCmd,
                     45 - terminateActCmd,
                     46 - sigMap,
                     47 - preemption,
                     48 - maxRschedTime,
                     49 - shareAccts List,
                     50 - chkpntDir,
                     51 - chkpntPeriod,
                     52 - imptJobBklg,
                     53 - defLimits,
                     54 - chunkJobSize,
                     55 - minProcLimit,
                     56 - defProcLimit,
                     57 - fairshareQueues,
                     58 - defExtSched,
                     59 - mandExtSched,
                     60 - slotShare,
                     61 - slotPool,
                     62 - underRCond,
                     63 - overRCond,
                     64 - idleCond,
                     65 - underRJobs,
                     66 - overRJobs,
                     67 - idleJobs,
                     68 - warningTimePeriod,
                     69 - warningAction,
                     70 - qCtrlMsg,
                     71 - acResReq,
                     72 - symJobLimit,
                     73 - cpuReq,
                     74 - proAttr,
                     75 - lendLimit,
                     76 - hostReallocInterval,
                     77 - numCPURequired,
                     78 - numCPUAllocated,
                     79 - numCPUBorrowed,
                     80 - numCPULent,
                     81 - schGranularity,
                     82 - symTaskGracePeriod,
                     83 - minOfSsm,
                     84 - maxOfSsm,
                     85 - numOfAllocSlots,
                     86 - servicePreemption,
                     87 - provisionStatus,
                     88 - minTimeSlice
    """

    cdef queueInfoEnt *qip
    cdef shareAcctInfoEnt *shareAccts

    cdef char **queues
    cdef char *host
    cdef char *user
    cdef int  numQueues
    cdef int  options
    cdef int  i
    cdef int  y

    host   = NULL
    user   = NULL
    queues = NULL
    numQueues = 0
    options   = 0

    qip = c_lsb_queueinfo(queues, &numQueues, host, user, options)

    Queue_info = []
    for i from 0 <= i < numQueues:

      loadSchedList = []
      for y from 0 <= y < qip[i].nIdx:
         loadSchedList.append( float(qip[i].loadSched[y]) )

      loadStopList = []
      for y from 0 <= y < qip[i].nIdx:
         loadStopList.append( float(qip[i].loadStop[y]) )

      shareAcctsList = []
      for y from 0 <= y < qip[i].numOfSAccts:

         shareAcctPath = ""
         if shareAccts[y].shareAcctPath != NULL:
           shareAcctPath = shareAccts[y].shareAcctPath

         shareAcctsList.append( shareAcctPath,
                                shareAccts[y].shares,
                                shareAccts[y].priority,
                                shareAccts[y].numStartJobs,
                                shareAccts[y].histCpuTime,
                                shareAccts[y].numReserveJobs,
                                shareAccts[y].runTime )

      rlimitsList = []
      for y from 0 <= y < 12:
         rlimitsList.append( qip[i].rLimits[y] )

      sigMapList = []
      for y from 0 <= y < 30:
         sigMapList.append( qip[i].sigMap[y] )

      hoststring = ""
      if qip[i].hostStr != NULL:
         hoststring = qip[i].hostStr

      defLimitsList = []
      for y from 0 <= y < 12:
         defLimitsList.append( qip[i].defLimits[y] )

      Queue_info.append( [ qip[i].queue,
                           qip[i].description,
                           qip[i].priority,
                           qip[i].nice,
                           qip[i].userList,
                           qip[i].hostList,
                           hoststring,
                           loadSchedList,
                           loadStopList,
                           qip[i].userJobLimit,
                           float(qip[i].procJobLimit),
                           qip[i].windows,
                           rlimitsList,
                           qip[i].hostSpec,
                           qip[i].qAttrib,
                           qip[i].qStatus,
                           qip[i].maxJobs,
                           qip[i].numJobs,
                           qip[i].numPEND,
                           qip[i].numRUN,
                           qip[i].numSSUSP,
                           qip[i].numUSUSP,
                           qip[i].mig,
                           qip[i].schedDelay,
                           qip[i].acceptIntvl,
                           qip[i].windowsD,
                           qip[i].nqsQueues,
                           qip[i].userShares,
                           qip[i].defaultHostSpec,
                           qip[i].procLimit,
                           qip[i].admins,
                           qip[i].preCmd,
                           qip[i].postCmd,
                           qip[i].requeueEValues,
                           qip[i].hostJobLimit,
                           qip[i].resReq,
                           qip[i].numRESERVE,
                           qip[i].slotHoldTime,
                           qip[i].sndJobsTo,
                           qip[i].rcvJobsFrom,
                           qip[i].resumeCond,
                           qip[i].stopCond,
                           qip[i].jobStarter,
                           qip[i].suspendActCmd,
                           qip[i].resumeActCmd,
                           qip[i].terminateActCmd,
                           sigMapList,
                           qip[i].preemption,
                           qip[i].maxRschedTime,
                           shareAcctsList,
                           qip[i].chkpntDir,
                           qip[i].chkpntPeriod,
                           qip[i].imptJobBklg,
                           defLimitsList,
                           qip[i].chunkJobSize,
                           qip[i].minProcLimit,
                           qip[i].defProcLimit,
                           qip[i].fairshareQueues,
                           qip[i].defExtSched,
                           qip[i].mandExtSched,
                           qip[i].slotShare,
                           qip[i].slotPool,
                           qip[i].underRCond,
                           qip[i].overRCond,
                           float(qip[i].idleCond),
                           qip[i].underRJobs,
                           qip[i].overRJobs,
                           qip[i].idleJobs,
                           qip[i].warningTimePeriod,
                           qip[i].warningAction,
                           qip[i].qCtrlMsg,
                           qip[i].acResReq,
                           qip[i].symJobLimit,
                           qip[i].cpuReq,
                           qip[i].proAttr,
                           qip[i].lendLimit,
                           qip[i].hostReallocInterval,
                           qip[i].numCPURequired,
                           qip[i].numCPUAllocated,
                           qip[i].numCPUBorrowed,
                           qip[i].numCPULent,
                           qip[i].schGranularity,
                           qip[i].symTaskGracePeriod,
                           qip[i].minOfSsm,
                           qip[i].maxOfSsm,
                           qip[i].numOfAllocSlots,
                           qip[i].servicePreemption,
                           qip[i].provisionStatus,
                           qip[i].minTimeSlice ] )

    return Queue_info

def lsb_init(program_name=""):

    """
    lsb_init  : You must use lsb_init() before any other LSBLIB
                library routine in your application.
                If the function fails, lsberrno is set to indicate
                the error.

    Parameter : String - Name of Program making connection

    Returns   : 0 = successful, -1 = successful
    """

    cdef char *Program_name

    Program_name = program_name

    retval = c_lsb_init(Program_name)

    return retval

def lsb_reconfig(operation=0, message=""):

    """
    lsb_reconfig : Dynamically reconfigures an LSF batch system
                   to pick up new configuration parameters and
                   changes to the job queue setup since system
                   startup or the last reconfiguration.
                   If the function fails, lsberrno is set to
                   indicate the error.

    Parameters   : Numeric - operation,
                   String  - message

    Returns      : 0 = successful, -1 = successful
    """

    cdef mbdCtrlReq *ctlreq

    cdef int  Operation
    cdef char *Message
    cdef char *Name

    Name = ""
    Message = message
    Operation = int(operation)

    ctlreq = NULL
    ctlreq = <mbdCtrlReq *>malloc(sizeof(mbdCtrlReq))

    ctlreq.opCode  = Operation
    ctlreq.name    = Name
    ctlreq.message = Message

    retval = c_lsb_reconfig(ctlreq)

    free(ctlreq)

    return retval

def lsb_sysmsg():

    """
    lsb_sysmsg : Returns the batch error message corresponding to lsberrno.
                 The global variable lsberrno maintained by LSBLIB holds
                 the error number from the most recent LSBLIB call that
                 caused an error.

    Parameters : None

    Returns    : String
    """

    return c_lsb_sysmsg()

def lsb_perror(message=""):

    """
    lsb_perror : Prints a batch LSF error message on stderr.
                 The usrMsg is printed out first, followed by a ":"
                 and the batch error message corresponding to lsberrno.

    Parameters : String - Error Message

    Returns    : None

    """

    cdef char *Message

    Message = message

    c_lsb_perror(Message)

    return

def lsb_pendreason(jobid=0):

    """
    lsb_pendreason : Explains why a job is pending, each pending
                     reason is associated with one or more hosts.
                     If no PEND reason is found, the function fails
                     and lsberrno is set to indicate the error.

    Parameters     : None

    Returns        : Dictionary - JobID:Reasons for pending jobs
    """

    cdef jobInfoHead  *jInfoH
    cdef jobInfoEnt   *job
    cdef loadIndexLog *indices

    cdef char *User
    cdef int Cluster_Id
    cdef int i

    Job_Id = int(jobid)
    Cluster_Id = -1
    pendreason = ""
    User       = "all"

    # use enum for suspend flag not 17 value

    jInfoH = c_lsb_openjobinfo_a(Job_Id, NULL, User, NULL, NULL, 17)

    indices = NULL
    indices = <loadIndexLog *>malloc(sizeof(loadIndexLog))
    indices.nIdx = 0
    indices.name = NULL
    indices.name = __getindexlist(indices.nIdx)

    pend_dict = {}
    for i in range(jInfoH.numJobs):
       job = c_lsb_readjobinfo(&i)
       pendreason = c_lsb_pendreason(job.numReasons, job.reasonTb, jInfoH, indices, Cluster_Id)
       pend_dict[job.jobId] = pendreason

    free(indices)

    c_lsb_closejobinfo()

    return pend_dict

cdef char** __getindexlist(int list_size):

    cdef lsInfo *lsInfo

    cdef char *nameList[268]
    cdef int  i

    lsInfo = cls_info()
    if lsInfo == NULL:
        return NULL

    list_size = lsInfo.numIndx
    for i from 0 <= i < lsInfo.numIndx:
        nameList[i] = lsInfo.resTable[i].name

    return nameList

def getCpuFactor(host_name, flag):

    cdef char*  Host_Name
    cdef int    Flag

    Host_Name = host_name
    Flag = flag

    retval = float(<char>c_getCpuFactor(Host_Name, 1))

    return retval

def lsb_suspreason(jobid=0):

    """
    lsb_suspreason : Explains why system-suspended and
                     user-suspended jobs were suspended.

    Parameters     : None

    Returns        : Dictionary - jobid:reason
    """

    cdef jobInfoHead  *jInfoH
    cdef jobInfoEnt   *job
    cdef loadIndexLog *indices

    cdef char *User
    cdef int  Job_Id
    cdef int  Cluster_Id
    cdef int  i

    User = "all"

    # use enum for suspend flag not 17 value

    jInfoH = c_lsb_openjobinfo_a(0, NULL, User, NULL, NULL, 17)

    indices = NULL
    indices = <loadIndexLog *>malloc(sizeof(loadIndexLog))
    indices.nIdx = 0
    indices.name = NULL
    indices.name = __getindexlist(indices.nIdx)

    suspend_dict = {}
    for i from 0 <= i < (jInfoH.numJobs):
       job = c_lsb_readjobinfo(&i)
       pendreason = c_lsb_suspreason(job.reasons, job.subreasons, indices)
       suspend_dict[job.jobId] = pendreason

    free(indices)

    c_lsb_closejobinfo()

    return suspend_dict

def lsb_parameterinfo():

    """
    lsb_parameterinfo : Returns information about the LSF cluster.
                        If the function fails, lsberrno is set to
                        indicate the error.

    Parameters        : None

    Returns           : List of parameter data for cluster -

                          0 - defaultQueues
                          1 - defaultHostSpec
                          2 - mbatchdInterval
                          3 - sbatchdInterval
                          4 - jobAcceptInterval
                          5 - maxDispRetries
                          6 - maxSbdRetries
                          7 - preemptPeriod
                          8 - cleanPeriod
                          9 - maxNumJobs
                         10 - historyHours
                         11 - pgSuspendIt
    """

    cdef parameterInfo *paraminfo

    paraminfo = c_lsb_parameterinfo(NULL, NULL, 0)

    pInfo = [ paraminfo.defaultQueues,
              paraminfo.defaultHostSpec,
              paraminfo.mbatchdInterval,
              paraminfo.sbatchdInterval,
              paraminfo.jobAcceptInterval,
              paraminfo.maxDispRetries,
              paraminfo.maxSbdRetries,
              paraminfo.preemptPeriod,
              paraminfo.cleanPeriod,
              paraminfo.maxNumJobs,
              paraminfo.historyHours,
              paraminfo.pgSuspendIt ]

    return pInfo

def lsb_usergrpinfo(group_list=[]):

    """
    lsb_usergrpinfo : Returns LSF user group membership.

    Parameters      : List - groups

    Returns         : List of Lists containg group info -

                        0 - group
                        1 - memberList
                        2 - numUserShares
    """

    cdef groupInfoEnt *grpInfo

    cdef char **Group_list
    cdef int  Num_of_recs
    cdef int  Options
    cdef int  i

    Num_of_recs = len(group_list)
    Options = 0

    Group_list = pyStringSeqToStringArray(group_list)

    grpInfo = c_lsb_usergrpinfo(Group_list, &Num_of_recs, 0)

    User_Grp = []
    for i from 0 <= i < Num_of_recs:
      User_Grp.append( [ grpInfo[i].group,
                         grpInfo[i].memberList,
                         grpInfo[i].numUserShares ] )

    free(Group_list)

    return User_Grp

def lsb_hostgrpinfo(host_list=[]):

    """
    lsb_hostgrpinfo : Returns LSF host group membership.
                      On failure, returns NULL and sets lsberrno to
                      indicate the error. If there are invalid groups
                      specified, the function returns the groups up to
                      the invalid ones. It then set lsberrno to
                      LSBE_BAD_GROUP, that is the specified
                      (*groups)[*numGroups] is not a group known to the
                      LSF system. If the first group is invalid, the
                      function returns NULL.

    Parameters      : List - hosts

    Returns         : List of Lists containg host info -

                        0 - group
                        1 - memberList
    """

    cdef groupInfoEnt *hostInfo

    cdef char **Host_list
    cdef int  Num_of_recs
    cdef int  Options
    cdef int  i

    Num_of_recs = len(group_list)
    Options = 0

    Host_list = pyStringSeqToStringArray(host_list)

    # Operation default to return all - 0 (GRP_ALL)
    # Operation is a bitwise inclusive OR of some 
    # of the following flags: GRP_RECURSIVE, GRP_ALL

    hostInfo = c_lsb_hostgrpinfo(Host_list, &Num_of_recs, 0)

    Host_Grp = []
    for i from 0 <= i < Num_of_recs:
      Host_Grp.append( [ hostInfo[i].group,
                         hostInfo[i].memberList ] )

    free(Host_list)

    return Host_Grp

def lsb_hostinfo(host_list=[]):

    """
    lsb_hostinfo  : Returns information about job server hosts

    Parameters    : List - hosts

    Returns       : List of Lists containing host info -

                      0 - host
                      1 - hStatus
                      2 - nIdx
                      3 - windows
                      4 - userJobLimit
                      5 - maxJobs
                      6 - numJobs
                      7 - numRUN
                      8 - numSSUSP
                      9 - numUSUSP
                     10 - numRESERVE
                     11 - mig
                     12 - attr
                     13 - realLoad
                     14 - chkSig
    """

    cdef hostInfoEnt *hostInfo

    cdef char **Host_list
    cdef int  Num_of_recs
    cdef int  i

    Num_of_recs = len(host_list)
    Host_list = pyStringSeqToStringArray(host_list)

    hostInfo = c_lsb_hostinfo(Host_list, &Num_of_recs)

    Host_Grp = []
    for i from 0 <= i < Num_of_recs:
      Host_Grp.append( [ hostInfo[i].host,
                         hostInfo[i].hStatus,
                         hostInfo[i].nIdx,
                         hostInfo[i].windows,
                         hostInfo[i].userJobLimit,
                         hostInfo[i].maxJobs,
                         hostInfo[i].numJobs,
                         hostInfo[i].numRUN,
                         hostInfo[i].numSSUSP,
                         hostInfo[i].numUSUSP,
                         hostInfo[i].numRESERVE,
                         hostInfo[i].mig,
                         hostInfo[i].attr,
                         float(<char>hostInfo[i].realLoad),
                         hostInfo[i].chkSig ] )

    free(Host_list)

    return Host_Grp

def lsb_sharedresourceinfo():

    """
    lsb_sharedresourceinfo : Returns the requested shared resource
                             information in dynamic values.

    Parameters             : None

    Returns                : List of Lists

                               0 - resourceName,
                               1 - [ 0 - totalValue,
                                     1 - rsvValue,
                                     2 - HostList
                                   ]
    """

    cdef lsbSharedResourceInfo     *lsbResourceInfo
    cdef lsbSharedResourceInstance *nextInstance

    cdef int numHosts
    cdef int i
    cdef int y

    numHosts = 0

    lsbResourceInfo = c_lsb_sharedresourceinfo(NULL, &numHosts, NULL, 0)

    sharedRes = []
    for i from 0 <= i < numHosts:
       nextInstance = lsbResourceInfo.instances
       Rinstances = []
       for y from 0 <= y < lsbResourceInfo.nInstances:
          Hosts = []
          for x from 0 <= x < nextInstance.nHosts:
             Hosts.append( nextInstance.hostList[x] )

          Rinstances.append( nextInstance.totalValue )
          Rinstances.append( nextInstance.rsvValue )
          Rinstances.append( Hosts )

       sharedRes.append( [ lsbResourceInfo.resourceName, Rinstances ] )

    return sharedRes

def lsb_reservationinfo():

    """
    lsb_reservationinfo : Retrieve reservation information from mbatchd.

    Parameters          : None

    Returns             : List of Lists

                            0 - rsvId,
                            1 - name,
                            2 - timeWindow,
                            3 - [ 0 - host,
                                  1 - numCPUs,
                                  2 - numSlots,
                                  3 - numRsvProcs,
                                  4 - numUsedProcs
                                ]
                            4 - [ 0 - jobIds,
                                  1 - jobStatus
                                ]
    """

    cdef rsvInfoEnt *lsb_reservationinfo
    cdef hostRsvInfoEnt *rsvHosts

    cdef int numEnts
    cdef int options
    cdef int i
    cdef int y

    options = 0

    Reservations = []
    lsb_reservationinfo = c_lsb_reservationinfo(NULL, &numEnts, options)

    for i from 0 <= i < numEnts:

       ResHosts = []
       for y from 0 <=y < lsb_reservationinfo[i].numRsvHosts:
          ResHosts.append( [ lsb_reservationinfo[i].rsvHosts[y].host,
                             lsb_reservationinfo[i].rsvHosts[y].numCPUs,
                             lsb_reservationinfo[i].rsvHosts[y].numSlots,
                             lsb_reservationinfo[i].rsvHosts[y].numRsvProcs,
                             lsb_reservationinfo[i].rsvHosts[y].numUsedProcs ] )

       ResJobs = []
       for y from 0 <= y < lsb_reservationinfo[i].numRsvJobs:
          ResJobs.append( [ lsb_reservationinfo[i].jobIds[y],
                            lsb_reservationinfo[i].jobStatus[y] ] )

       Reservations.append( [ lsb_reservationinfo[i].rsvId,
                              lsb_reservationinfo[i].name,
                              lsb_reservationinfo[i].timeWindow,
                              ResHosts,
                              ResJobs ] )

    return Reservations

def lsb_addreservation(user="", group="", hostlist=[], twindow="", btime="", etime=""):

    """
    lsb_addreservation : Add a reservation

    Parameters         : String - user
                         String - group
                         List   - hosts
                         String - time window
                         String - btime
                         String - etime

    Returns            : Numeric - 0 = successful, -1 = successful
                         String  - Reservation ID
    """

    #RSV_OPTION_USER   0x001
    #RSV_OPTION_GROUP  0x002
    #RSV_OPTION_SYSTEM 0x004
    #RSV_OPTION_RECUR  0x008
    #RSV_OPTION_RESREQ 0x010
    #RSV_OPTION_HOST   0x020
    #RSV_OPTION_OPEN   0x040

    cdef addRsvRequest request

    cdef char rsvId[40]
    cdef char *Name
    cdef char *tWindow
    cdef char **Hosts
    cdef int  numHosts
    cdef int  Options

    memset(&request, 0, sizeof(addRsvRequest))

    Options = 0x000
    Hosts = NULL
    numHosts = 0
    tWindow = twindow

    numHosts = len(hostlist)
    if numHosts > 0:
      Hosts = pyStringSeqToStringArray(hostlist)
      request.options = request.options|0x020
      request.numAskedHosts = numHosts
      request.askedHosts = Hosts

    if group:
      request.options = request.options|0x002
      Name = group
      request.name = Name
    if user:
      Name = user
      request.name = Name
      request.options = request.options|0x001

    request.resReq = ""
    if twindow:
      request.timeWindow = tWindow
      request.options = request.options|0x008

    retval = c_lsb_addreservation(&request, rsvId)
    ResID = rsvId

    if retval < 0:
      ResID = ""

    #for y from 0 <= y < request.numAskedHosts:
    #   free(request.req.askedHosts[y])

    #if (request.askedHosts != NULL):
    #  free(request.askedHosts)
    #  request.askedHosts = NULL
    #if (request.name != NULL):
    #  free(request.name)
    #  request.name = NULL

    #if (request.timeWindow != NULL):
    #  free(request.timeWindow)

    if numHosts > 0:
      free(Hosts)

    return (retval, ResID)

def lsb_listjgrp():

    """
    lsb_listjgrp : Returns job group information

    Parameters  : None

    Returns     : List of job groups

                    0 - name,
                    1 - path,
                    2 - user,
                    3 - [ 0 - njobs,
                          1 - npend,
                          2 - npsusp,
                          3 - nrun,
                          4 - nssusp,
                          5 - nususp,
                          6 - nexit,
                          7 - ndone
                        ]
    """

    cdef jgrp *jgrp

    cdef int numJgrp
    cdef int i
    cdef int y

    jgrp = c_lsb_listjgrp(&numJgrp)
    jgrpList = []
    for i from 0 <= i < numJgrp:

       jgrpCounters = []
       for y from 0 <= y < 7:
          jgrpCounters.append( jgrp[i].counters[y] )

       user = ""
       if jgrp[i].user != NULL:
          user = jgrp[i].user

       jgrpList.append( [ jgrp[i].name,
                          jgrp[i].path,
                          user,
                          jgrpCounters ] )

    return jgrpList

def lsb_addjgrp(group=""):

    """
    lsb_addjgrp : Add a job group

    Parameters  : String - group

    Returns     : Numeric - 0 = successful, -1 = successful
    """

    cdef jgrpAdd   jgrpAdd
    cdef jgrpReply *jgrpReply

    cdef char *newGrp

    newGrp = group

    jgrpAdd.timeEvent = ""
    jgrpAdd.depCond   = ""
    jgrpAdd.groupSpec = newGrp

    retval = c_lsb_addjgrp(&jgrpAdd, &jgrpReply)

    return retval

def lsb_deljgrp(group=""):

    """
    lsb_deljgrp : Delete a job group

    Parameters  : String - group

    Returns     : Numeric - 0 = successful, -1 = successful
    """

    cdef jgrpReply *jgrpReply

    cdef char *groupSpec
    cdef int  options

    options = 0
    groupSpec = group

    retval = c_lsb_deljgrp(groupSpec, options, &jgrpReply)

    return retval

def lsb_holdjgrp(group=""):

    """
    lsb_holdjgrp : Hold a job group

    Parameters   : String - group

    Returns      : Numeric - 0 = successful, -1 = successful
    """

    cdef jgrpReply *jgrpReply

    cdef char *groupSpec
    cdef int  options

    options = 0
    groupSpec = group

    retval = c_lsb_holdjgrp(groupSpec, options, &jgrpReply)

    return retval

def lsb_reljgrp(group=""):

    """
    lsb_reljgrp : Release a job group

    Parameters  : String - group

    Returns     : Numeric - 0 = successful, -1 = successful
    """

    cdef jgrpReply *jgrpReply

    cdef char *groupSpec
    cdef int  options

    options = 0
    groupSpec = group

    retval = c_lsb_reljgrp(groupSpec, options, &jgrpReply)

    return retval

def lsb_modjgrp(group="", newgroup=""):

    """
    lsb_modjgrp : Modify a job group

    Parameters  : String - group

    Returns     : Numeric - 0 = successful, -1 = successful
    """

    cdef jgrpMod   jgrpMod
    cdef jgrpReply *jgrpReply

    cdef char *grpSpec
    cdef char *newGrp

    grpSpec = group
    newGrp  = newgroup

    jgrpMod.destSpec = newGrp
    jgrpMod.jgrp.groupSpec = grpSpec

    retval = c_lsb_modjgrp(&jgrpMod, &jgrpReply)

    return retval

def lsb_serviceClassInfo():

    """
    lsb_serviceClassInfo : Returns SLA information

    Parameters           : None

    Returns              : List of job groups

                             0 - name,
                             1 - priority,
                             2 - goals List,
                                 [ 0 - spec,
                                   1 - type,
                                   2 - state,
                                   3 - goal,
                                   4 - actual,
                                   5 - optimum,
                                   6 - minimum
                                 ]
                             3 - userGroups,
                             4 - description,
                             5 - controlAction,
                             6 - throughput,
                             3 - counters List,
                                 [ 0 - njobs,
                                   1 - npend,
                                   2 - npsusp,
                                   3 - nrun,
                                   4 - nssusp,
                                   5 - nususp,
                                   6 - nexit,
                                   7 - ndone
                                 ]
    """

    cdef serviceClass *sla

    cdef int i
    cdef int y
    cdef int num

    sla = c_lsb_serviceClassInfo(&num)

    slaList = []
    for i from 0 <= i < num:

       ObjList = []
       for y from 0 <= y < sla[i].ngoals:
          ObjList.append( [ sla[i].goals[y].spec,
                            sla[i].goals[y].type,
                            sla[i].goals[y].state,
                            sla[i].goals[y].goal,
                            sla[i].goals[y].actual,
                            sla[i].goals[y].optimum,
                            sla[i].goals[y].minimum ] )

       slaCounters = []
       for y from 0 <= y < 8:
          slaCounters.append( sla[i].counters[y] )

       slaList.append( [ sla[i].name,
                         sla[i].priority,
                         objList,
                         sla[i].userGroups,
                         sla[i].description,
                         sla[i].controlAction,
                         sla[i].throughput,
                         slaCounters ] )

    return slaList

def lsb_hostpartinfo(hostpartlist=[]):

    """
    lsb_hostpartinfo : Returns information on host partitions

    Parameters       : List of host partitions

    Returns          : List of host partition information

                         0 - host partition,
                         1 - List of hosts in partition,
                         2 - List of user data for partition
                             [ 0 - user,
                               1 - shares,
                               2 - priority,
                               3 - number of start jobs,
                               4 - historical cpu time,
                               5 - number of reserved jobs,
                               6 - run time
                             ]
    """

    cdef hostPartInfoEnt *hostPartInfo

    cdef char **hostPartP
    cdef int  numHostsPs
    cdef int  i
    cdef int  y

    numHostsPs = len(hostpartlist)
    hostPartP  = pyStringSeqToStringArray(hostpartlist)

    hostPartInfo = c_lsb_hostpartinfo(hostPartP, &numHostsPs)

    hostPartList = []
    for i from 0 <= i < numHostsPs:

       hostPartUsers = []
       for y from 0 <= y < hostPartInfo[i].numUsers:
          hostPartUsers.append( hostPartInfo[i].users[y].user )
          hostPartUsers.append( hostPartInfo[i].users[y].shares )
          hostPartUsers.append( hostPartInfo[i].users[y].priority )
          hostPartUsers.append( hostPartInfo[i].users[y].numStartJobs )
          hostPartUsers.append( hostPartInfo[i].users[y].histCpuTime )
          hostPartUsers.append( hostPartInfo[i].users[y].numReserveJobs )
          hostPartUsers.append( hostPartInfo[i].users[y].runTime )

       hostPartList.append( [ hostPartInfo[i].hostPart,
                              hostPartInfo[i].hostList,
                              hostPartUsers ] )

    return hostPartList

def lsb_runjob(jobid):

    """
    lsb_runjob : Runs a job immeadiately

    Parameters : Jobid to dispatch

    Returns    : Numeric - 0 = successful, -1 = successful
    """

    #HOST_STAT_BUSY       0x01
    #HOST_STAT_WIND       0x02
    #HOST_STAT_DISABLED   0x04
    #HOST_STAT_LOCKED     0x08
    #HOST_STAT_FULL       0x10
    #HOST_STAT_NO_LIM     0x100
    #HOST_STAT_UNLICENSED 0x80
    #HOST_STAT_UNAVAIL    0x40
    #HOST_STAT_UNREACH    0x20

    cdef hostInfoEnt  *hInfo
    cdef runJobRequest runJobReq

    cdef int JobId
    cdef int numHosts
    cdef int i

    hInfo = c_lsb_hostinfo(NULL, &numHosts)
    if hInfo == NULL:
        c_lsb_perror("lsb_hostinfo")
        return -1

    for i from 0 <= i < numHosts:
       if (hInfo[i].hStatus & (0x01|
                               0x02|
                               0x04|
                               0x08|
                               0x10|
                               0x100|
                               0x80|
                               0x40|
                               0x20)):
            continue

       # found a vacant host

       if ( hInfo[i].numJobs == 0 ):
            break

    if ( i == numHosts ):
        c_lsb_perror("lsb_runjob : cannot find host to run job")
        return -1

    # define the specifications for the job to be run
    # (The job can be stopped due to load conditions)

    runJobReq.jobId = int(jobid)
    runJobReq.options = 0
    runJobReq.numHosts = 1
    runJobReq.hostname = <char**>malloc(sizeof(char*))
    runJobReq.hostname[0] = hInfo[i].host

    # run the job and check for the success

    retval = 0
    if ( c_lsb_runjob(&runJobReq) < 0 ):
        c_lsb_perror("lsb_runjob")
        retval = -1

    free(runJobReq.hostname)

    return retval

def lsb_setjobattr(job_id=0):

    """
    lsb_setjobattr : Sets the attributes for a job

    Parameters     : Jobid

    Returns        : Numeric - 0 = Successful, -1 = Unsuccessful
    """

    return retval

cdef class lsb_geteventrec:

    """
    lsb_geteventrec : Returns event records

    Parameters      : Event file

    Returns         : A list of event records

    """

    cdef char *eventFile
    cdef FILE *fp
    cdef int lineNum

    cdef eventRec *record
    cdef jobNewLog *newJob
    cdef jobStartLog *startJob
    cdef jobStatusLog *statusJob
    cdef sbdJobStatusLog *sbdJobStatus
    cdef jobSwitchLog *switchJob
    cdef jobFinishLog *finishJob
    cdef jobMoveLog *moveJob
    cdef mbdDieLog *mbdDie
    cdef unfulfillLog *mbdUnfulfil
    cdef queueCtrlLog *queueCtrl
    cdef hostCtrlLog *hostCtrl
    cdef mbdStartLog *mbdStart
    cdef signalLog *signalJob
    cdef jobExecuteLog *executeJob
    cdef jobMsgLog *jobMsg
    cdef jobMsgAckLog *jobMsgAck
    cdef jobAcceptLog *acceptJob
    cdef jobForwardLog *forwardJob
    cdef statusAckLog *ackLog
    cdef sigactLog *sigactJob
    cdef jobOccupyReqLog *jobOccupyReq
    cdef jobVacatedLog *vacateJob
    cdef jobStartAcceptLog *jobStartAccept
    cdef migLog *migLog
    cdef calendarLog *calendarLog
    cdef jobRequeueLog *requeueJob
    cdef chkpntLog *chkpntLog
    cdef jobCleanLog *cleanJob
    cdef jobForceRequestLog *jobForceRequest
    cdef logSwitchLog *logSwitch
    cdef jobExceptionLog *exceptionJob
    cdef jgrpCtrlLog *jgrpCtrl
    cdef jgrpNewLog *jgrpNew
    cdef jobExternalMsgLog *jobExtMsg
    cdef jobChunkLog *chunkJob
    cdef rsvFinishLog *rsvFinish
    cdef hgCtrlLog *hgCtrl
    cdef jobModLog *jobMod
    cdef jgrpStatusLog *jgrpLog
    cdef jobAttrSetLog *jobAttrSet
    cdef sbdUnreportedStatusLog *sbdUnreportedStatus
    cdef cpuProfileLog *cpuProfile
    cdef dataLoggingLog *dataLogging

    def __init__(self, event_file):
        self.eventFile = event_file
        self.lineNum = 0
        self.record
        self.newJob
        self.startJob
        self.statusJob
        self.fp
        self.__open()

    def __dealloc__(self):
        # Pyrex expects __dealloc__(), not __del__()

        fclose(self.fp)

        # Whatever c_lsb_geteventrec() returns shouldn't be freed since it's
        # static, not malloc'd.

    def __open(self):
        self.fp = fopen(self.eventFile,'r')
        #self.record = c_lsb_geteventrec(self.fp, &self.lineNum)

    def __iter__(self):
        return self

    def __next__(self):
        a = self.read()
        if not a:
            raise StopIteration
        else:
            return a

    def read(self):

        self.record = c_lsb_geteventrec(self.fp, &self.lineNum)
        if self.record != NULL:
           if self.record.type == 1: # EVENT_JOB_NEW
             self.newJob = &(self.record.eventLog.jobNewLog)
             return [self.record.type,
                     "JOB_NEW",
                     self.record.version,
                     self.record.eventTime,
                     self.newJob.jobId,
                     self.record.eventTime,
                     self.newJob.userName,
                     self.newJob.fromHost,
                     self.newJob.queue,
                     self.newJob.jobFile]
           elif self.record.type == 2: # EVENT_JOB_START
             self.startJob = &(self.record.eventLog.jobStartLog)
             hosts = []
             for i from 0 <= i < self.startJob.numExHosts:
                hosts.append(self.startJob.execHosts[i])
             return [self.record.type,
                     "JOB_START",
                     self.record.version,
                     self.record.eventTime,
                     self.startJob.jobId,
                     self.record.eventTime,
                     self.startJob.jobPid,
                     self.startJob.jobPGid,
                     self.startJob.hostFactor,
                     hosts,
                     self.startJob.queuePreCmd,
                     self.startJob.queuePostCmd,
                     self.startJob.jFlags,
                     self.startJob.userGroup,
                     self.startJob.idx,
                     self.startJob.additionalInfo,
                     self.startJob.duration4PreemptBackfill]
           elif self.record.type == 3: # EVENT_JOB_STATUS
             self.statusJob = &(self.record.eventLog.jobStatusLog)
             return [self.record.type,
                     "JOB_STATUS",
                     self.record.version,
                     self.record.eventTime,
                     self.statusJob.jobId,
                     self.record.eventTime,
                     self.statusJob.jStatus,
                     self.statusJob.reason,
                     self.statusJob.subreasons,
                     self.statusJob.cpuTime,
                     self.statusJob.endTime,
                     self.statusJob.ru,
                     self.statusJob.jFlags,
                     self.statusJob.exitStatus,
                     self.statusJob.idx,
                     self.statusJob.exitInfo]
           elif self.record.type == 4: # EVENT_JOB_SWITCH
             self.switchJob = &(self.record.eventLog.jobSwitchLog)
             return [self.record.type,
                     "JOB_SWITCH",
                     self.record.version,
                     self.record.eventTime,
                     self.switchJob.jobId,
                     self.switchJob.userId,
                     self.switchJob.queue,
                     self.switchJob.idx,
                     self.switchJob.userName]
           elif self.record.type == 5: # EVENT_JOB_MOVE
             self.moveJob = &(self.record.eventLog.jobMoveLog)
             return [self.record.type,
                     "JOB_MOVE",
                     self.record.version,
                     self.record.eventTime,
                     self.moveJob.jobId,
                     self.moveJob.userId,
                     self.moveJob.position,
                     self.moveJob.base,
                     self.moveJob.idx,
                     self.moveJob.userName]
           elif self.record.type == 6:  # EVENT_QUEUE_CTRL
             self.queueCtrl = &(self.record.eventLog.queueCtrlLog)
             return [self.record.type,
                     "QUEUE_CTRL",
                     self.record.version,
                     self.record.eventTime,
                     self.queueCtrl.opCode,
                     self.queueCtrl.queue,
                     self.queueCtrl.userId,
                     self.queueCtrl.userName,
                     self.queueCtrl.message]
           elif self.record.type == 7:  # EVENT_HOST_CTRL
             self.hostCtrl = &(self.record.eventLog.hostCtrlLog)
             return [self.record.type,
                     "HOST_CTRL",
                     self.record.version,
                     self.record.eventTime,
                     self.hostCtrl.opCode,
                     self.hostCtrl.host,
                     self.hostCtrl.userId,
                     self.hostCtrl.userName,
                     self.hostCtrl.message]
           elif self.record.type == 8:  # EVENT_MBD_DIE
             self.mbdDie = &(self.record.eventLog.mbdDieLog)
             return [self.record.type,
                     "MBD_DIE",
                     self.record.version,
                     self.record.eventTime,
                     self.mbdDie.master,
                     self.mbdDie.numRemoveJobs,
                     self.mbdDie.exitCode,
                     self.mbdDie.message]
           elif self.record.type == 9:  # EVENT_MBD_UNFULFILL
             self.mbdUnfulfil = &(self.record.eventLog.unfulfillLog)
             return [self.record.type,
                     "MBD_UNFULFIL",
                     self.record.version,
                     self.record.eventTime,
                     self.mbdUnfulfil.jobId,
                     self.mbdUnfulfil.notSwitched,
                     self.mbdUnfulfil.sig,
                     self.mbdUnfulfil.sig1,
                     self.mbdUnfulfil.sig1Flags,
                     self.mbdUnfulfil.chkPeriod,
                     self.mbdUnfulfil.notModified,
                     self.mbdUnfulfil.idx,
                     self.mbdUnfulfil.miscOpts4PendSig]
           elif self.record.type == 10: # EVENT_JOB_FINISH
             self.finishJob = &(self.record.eventLog.jobFinishLog)
             askedHosts = []
             for i from 0 <= i < self.finishJob.numAskedHosts:
                askedHosts.append(self.finishJob.askedHosts[i])
             execHosts = []
             for i from 0 <= i < self.finishJob.numExHosts:
                execHosts.append(self.finishJob.execHosts[i])

             return {'type':              self.record.type,
                     'eventType':         'JOB_FINISH',
                     'version':           self.record.version,
                     'eventTime':         self.record.eventTime,
                     'jobId':             self.finishJob.jobId,
                     'userId':            self.finishJob.userId,
                     'userName':          self.finishJob.userName,
                     'options':           self.finishJob.options,
                     'numProcessors':     self.finishJob.numProcessors,
                     'jStatus':           self.finishJob.jStatus,
                     'submitTime':        self.finishJob.submitTime,
                     'beginTime':         self.finishJob.beginTime,
                     'termTime':          self.finishJob.termTime,
                     'startTime':         self.finishJob.startTime,
                     'endTime':           self.finishJob.endTime,
                     'queue':             self.finishJob.queue,
                     'resReq':            self.finishJob.resReq,
                     'fromHost':          self.finishJob.fromHost,
                     'cwd':               self.finishJob.cwd,
                     'inFile':            self.finishJob.inFile,
                     'outFile':           self.finishJob.outFile,
                     'errFile':           self.finishJob.errFile,
                     'inFileSpool':       self.finishJob.inFileSpool,
                     'commandSpool':      self.finishJob.commandSpool,
                     'jobFile':           self.finishJob.jobFile,
                     'numAskedHosts':     self.finishJob.numAskedHosts,
                     'askedHosts':        askedHosts,
                     'hostFactor':        self.finishJob.hostFactor,
                     'numExHosts':        self.finishJob.numExHosts,
                     'execHosts':         execHosts,
                     'cpuTime':           self.finishJob.cpuTime,
                     'jobName':           self.finishJob.jobName,
                     'command':           self.finishJob.command,
                     'ru_utime':          self.finishJob.lsfRusage.ru_utime,
                     'ru_stime':          self.finishJob.lsfRusage.ru_stime,
                     'ru_maxrss':         self.finishJob.lsfRusage.ru_maxrss,
                     'ru_ixrss':          self.finishJob.lsfRusage.ru_ixrss,
                     'ru_ismrss':         self.finishJob.lsfRusage.ru_ismrss,
                     'ru_idrss':          self.finishJob.lsfRusage.ru_idrss,
                     'ru_isrss':          self.finishJob.lsfRusage.ru_isrss,
                     'ru_minflt':         self.finishJob.lsfRusage.ru_minflt,
                     'ru_majflt':         self.finishJob.lsfRusage.ru_majflt,
                     'ru_nswap':          self.finishJob.lsfRusage.ru_nswap,
                     'ru_inblock':        self.finishJob.lsfRusage.ru_inblock,
                     'ru_oublock':        self.finishJob.lsfRusage.ru_oublock,
                     'ru_ioch':           self.finishJob.lsfRusage.ru_ioch,
                     'ru_msgsnd':         self.finishJob.lsfRusage.ru_msgsnd,
                     'ru_msgrcv':         self.finishJob.lsfRusage.ru_msgrcv,
                     'ru_nsignals':       self.finishJob.lsfRusage.ru_nsignals,
                     'ru_nvcsw':          self.finishJob.lsfRusage.ru_nvcsw,
                     'ru_nivcsw':         self.finishJob.lsfRusage.ru_nivcsw,
                     'ru_exutime':        self.finishJob.lsfRusage.ru_exutime,
                     'dependCond':        self.finishJob.dependCond,
                     'timeEvent':         self.finishJob.timeEvent,
                     'preExecCmd':        self.finishJob.preExecCmd,
                     'mailUser':          self.finishJob.mailUser,
                     'projectName':       self.finishJob.projectName,
                     'exitStatus':        self.finishJob.exitStatus,
                     'maxNumProcessors':  self.finishJob.maxNumProcessors,
                     'loginShell':        self.finishJob.loginShell,
                     'idx':               self.finishJob.idx,
                     'maxRMem':           self.finishJob.maxRMem,
                     'maxRSwap':          self.finishJob.maxRSwap,
                     'rsvId':             self.finishJob.rsvId,
                     'sla':               self.finishJob.sla,
                     'exceptMask':        self.finishJob.exceptMask,
                     'additionalInfo':    self.finishJob.additionalInfo,
                     'exitInfo':          self.finishJob.exitInfo,
                     'warningTimePeriod': self.finishJob.warningTimePeriod,
                     'warningAction':     self.finishJob.warningAction,
                     'chargedSAAP':       self.finishJob.chargedSAAP,
                     'licenseProject':    self.finishJob.licenseProject,
                     'app':               self.finishJob.app,
                     'postExecCmd':       self.finishJob.postExecCmd,
                     'runtimeEstimation': self.finishJob.runtimeEstimation,
                     'jgroup':            self.finishJob.jgroup}
           elif self.record.type == 11: # EVENT_LOAD_EXEC
             return [self.record.type,
                     "LOAD_EXEC"]
           elif self.record.type == 12: # EVENT_CHKPNT
             self.chkpntLog = &(self.record.eventLog.chkpntLog)
             return [self.record.type,
                     "CHKPNT",
                     self.record.version,
                     self.record.eventTime,
                     self.chkpntLog.jobId,
                     self.chkpntLog.period,
                     self.chkpntLog.pid,
                     self.chkpntLog.ok,
                     self.chkpntLog.flags,
                     self.chkpntLog.idx]
           elif self.record.type == 13: # EVENT_JOB_MIG
             self.migLog = &(self.record.eventLog.migLog)
             hosts = []
             for i from 0 <= i < self.migLog.numAskedHosts:
                hosts.append(self.migLog.askedHosts[i])
             return [self.record.type,
                     "JOB_MIG",
                     self.record.version,
                     self.record.eventTime,
                     self.migLog.jobId,
                     hosts,
                     self.migLog.userId,
                     self.migLog.idx,
                     self.migLog.userName]
           elif self.record.type == 14: # EVENT_PRE_EXEC_START
             return [self.record.type,
                     "PRE_EXEC_START"]
           elif self.record.type == 15: # EVENT_MBD_START
             self.mbdStart = &(self.record.eventLog.mbdStartLog)
             return [self.record.type,
                     "MBD_START",
                     self.record.version,
                     self.record.eventTime,
                     self.mbdStart.master,
                     self.mbdStart.cluster,
                     self.mbdStart.numHosts,
                     self.mbdStart.numQueues]
           elif self.record.type == 16: # EVENT_JOB_ROUTE
             return [self.record.type,
                     "JOB_ROUTE"]
           elif self.record.type == 17: # EVENT_JOB_MODIFY
             return [self.record.type,
                     "JOB_MODIFY"]
           elif self.record.type == 18: # EVENT_JOB_SIGNAL
             self.signalJob = &(self.record.eventLog.signalLog)
             return [self.record.type,
                     "JOB_SIGNAL",
                     self.record.version,
                     self.record.eventTime,
                     self.signalJob.userId,
                     self.signalJob.jobId,
                     self.signalJob.signalSymbol,
                     self.signalJob.runCount,
                     self.signalJob.idx,
                     self.signalJob.userName]
           elif self.record.type == 19: # EVENT_CAL_NEW
             self.calendarLog = &(self.record.eventLog.calendarLog)
             return [self.record.type,
                     "CAL_NEW",
                     self.record.version,
                     self.record.eventTime,
                     self.calendarLog.options,
                     self.calendarLog.userId,
                     self.calendarLog.name,
                     self.calendarLog.desc,
                     self.calendarLog.calExpr]
           elif self.record.type == 20: # EVENT_CAL_MODIFY
             self.calendarLog = &(self.record.eventLog.calendarLog)
             return [self.record.type,
                     "CAL_MODIFY",
                     self.record.version,
                     self.record.eventTime,
                     self.calendarLog.options,
                     self.calendarLog.userId,
                     self.calendarLog.name,
                     self.calendarLog.desc,
                     self.calendarLog.calExpr]
           elif self.record.type == 21: # EVENT_CAL_DELETE
             self.calendarLog = &(self.record.eventLog.calendarLog)
             return [self.record.type,
                     "CAL_DELETE",
                     self.record.version,
                     self.record.eventTime,
                     self.calendarLog.options,
                     self.calendarLog.userId,
                     self.calendarLog.name,
                     self.calendarLog.desc,
                     self.calendarLog.calExpr]
           elif self.record.type == 22: # EVENT_JOB_FORWARD
             self.forwardJob = &(self.record.eventLog.jobForwardLog)
             hosts = []
             for i from 0 <= i < self.forwardJob.numReserHosts:
                hosts.append(self.forwardJob.reserHosts[i])
             return [self.record.type,
                     "JOB_FORWARD",
                     self.record.version,
                     self.record.eventTime,
                     self.forwardJob.jobId,
                     self.forwardJob.cluster,
                     hosts,
                     self.forwardJob.idx,
                     self.forwardJob.jobRmtAttr]
           elif self.record.type == 23: # EVENT_JOB_ACCEPT
             self.acceptJob = &(self.record.eventLog.jobAcceptLog)
             return [self.record.type,
                     "JOB_ACCEPT",
                     self.record.version,
                     self.record.eventTime,
                     self.acceptJob.jobId,
                     self.acceptJob.remoteJid,
                     self.acceptJob.cluster,
                     self.acceptJob.idx,
                     self.acceptJob.jobRmtAttr]
           elif self.record.type == 24: # EVENT_STATUS_ACK
             self.ackLog = &(self.record.eventLog.statusAckLog)
             return [self.record.type,
                     "STATUS_ACK",
                     self.record.version,
                     self.record.eventTime,
                     self.ackLog.jobId,
                     self.ackLog.statusNum,
                     self.ackLog.idx]
           elif self.record.type == 25: # EVENT_JOB_EXECUTE
             self.executeJob = &(self.record.eventLog.jobExecuteLog)
             return [self.record.type,
                     "JOB_EXECUTE",
                     self.record.version,
                     self.record.eventTime,
                     self.executeJob.jobId,
                     self.executeJob.execUid,
                     self.executeJob.execHome,
                     self.executeJob.execCwd,
                     self.executeJob.jobPGid,
                     self.executeJob.execUsername,
                     self.executeJob.jobPid,
                     self.executeJob.idx,
                     self.executeJob.additionalInfo,
                     self.executeJob.SLAscaledRunLimit,
                     self.executeJob.position,
                     self.executeJob.execRusage,
                     self.executeJob.duration4PreemptBackfill]
           elif self.record.type == 26: # EVENT_JOB_MSG
             self.jobMsg = &(self.record.eventLog.jobMsgLog)
             return [self.record.type,
                     "JOB_MSG",
                     self.record.version,
                     self.record.eventTime,
                     self.jobMsg.usrId,
                     self.jobMsg.jobId,
                     self.jobMsg.msgId,
                     self.jobMsg.type,
                     self.jobMsg.src,
                     self.jobMsg.dest,
                     self.jobMsg.msg,
                     self.jobMsg.idx]
           elif self.record.type == 27: # EVENT_JOB_MSG_ACK
             self.jobMsgAck = &(self.record.eventLog.jobMsgAckLog)
             return [self.record.type,
                     "JOB_MSG_ACK",
                     self.record.version,
                     self.record.eventTime,
                     self.jobMsgAck.usrId,
                     self.jobMsgAck.jobId,
                     self.jobMsgAck.msgId,
                     self.jobMsgAck.type,
                     self.jobMsgAck.src,
                     self.jobMsgAck.dest,
                     self.jobMsgAck.msg,
                     self.jobMsgAck.idx]
           elif self.record.type == 28: # EVENT_JOB_REQUEUE
             self.requeueJob = &(self.record.eventLog.jobRequeueLog)
             return [self.record.type,
                     "JOB_REQUEUE",
                     self.record.version,
                     self.record.eventTime,
                     self.requeueJob.jobId,
                     self.requeueJob.idx]
           elif self.record.type == 29: # EVENT_JOB_OCCUPY_REQ
             self.jobOccupyReq = &(self.record.eventLog.jobOccupyReqLog)
             return [self.record.type,
                     "JOB_OCCUPY_REQ",
                     self.record.version,
                     self.record.eventTime,
                     jobOccupyReq.userId,
                     jobOccupyReq.jobId,
                     jobOccupyReq.numOccupyRequests,
                     #void *occupyReqList,
                     jobOccupyReq.idx,
                     jobOccupyReq.userName]
           elif self.record.type == 30: # EVENT_JOB_VACATED
             self.vacateJob = &(self.record.eventLog.jobVacatedLog)
             return [self.record.type,
                     "JOB_VACATED",
                     self.record.version,
                     self.record.eventTime,
                     self.vacateJob.userId,
                     self.vacateJob.jobId,
                     self.vacateJob.idx,
                     self.vacateJob.userName]
           elif self.record.type == 32: # EVENT_JOB_SIGACT
             self.sigactJob = &(self.record.eventLog.sigactLog)
             return [self.record.type,
                     "JOB_SIGACT",
                     self.record.version,
                     self.record.eventTime,
                     self.sigactJob.jobId,
                     self.sigactJob.period,
                     self.sigactJob.pid,
                     self.sigactJob.jStatus,
                     self.sigactJob.reasons,
                     self.sigactJob.flags,
                     self.sigactJob.signalSymbol,
                     self.sigactJob.actStatus,
                     self.sigactJob.idx]
           elif self.record.type == 34: # EVENT_SBD_JOB_STATUS
             self.sbdJobStatus = &(self.record.eventLog.sbdJobStatusLog)
             return [self.record.type,
                     "SBD_JOB_STATUS",
                     self.record.version,
                     self.record.eventTime,
                     self.sbdJobStatus.jobId,
                     self.sbdJobStatus.jStatus,
                     self.sbdJobStatus.reasons,
                     self.sbdJobStatus.subreasons,
                     self.sbdJobStatus.actPid,
                     self.sbdJobStatus.actValue,
                     self.sbdJobStatus.actPeriod,
                     self.sbdJobStatus.actFlags,
                     self.sbdJobStatus.actStatus,
                     self.sbdJobStatus.actReasons,
                     self.sbdJobStatus.actSubReasons,
                     self.sbdJobStatus.idx,
                     self.sbdJobStatus.sigValue,
                     self.sbdJobStatus.exitInfo]
           elif self.record.type == 35: # EVENT_JOB_START_ACCEPT
             self.jobStartAccept = &(self.record.eventLog.jobStartAcceptLog)
             return [self.record.type,
                     "JOB_START_ACCEPT",
                     self.record.version,
                     self.record.eventTime,
                     self.jobStartAccept.jobId,
                     self.jobStartAccept.jobPid,
                     self.jobStartAccept.jobPGid,
                     self.jobStartAccept.idx]
           elif self.record.type == 36: # EVENT_CAL_UNDELETE
             self.calendarLog = &(self.record.eventLog.calendarLog)
             return [self.record.type,
                     "CAL_UNDELETE",
                     self.record.version,
                     self.record.eventTime,
                     self.calendarLog.options,
                     self.calendarLog.userId,
                     self.calendarLog.name,
                     self.calendarLog.desc,
                     self.calendarLog.calExpr]
           elif self.record.type == 37: # EVENT_JOB_CLEAN
             self.cleanJob = &(self.record.eventLog.jobCleanLog)
             return [self.record.type,
                     "JOB_CLEAN",
                     self.record.version,
                     self.record.eventTime,
                     self.cleanJob.jobId,
                     self.cleanJob.idx]
           elif self.record.type == 38: # EVENT_JOB_EXCEPTION
             self.exceptionJob = &(self.record.eventLog.jobExceptionLog)
             return [self.record.type,
                     "JOB_EXCEPTION",
                     self.record.version,
                     self.record.eventTime,
                     self.exceptionJob.jobId,
                     self.exceptionJob.exceptMask,
                     self.exceptionJob.actMask,
                     self.exceptionJob.timeEvent,
                     self.exceptionJob.exceptInfo,
                     self.exceptionJob.idx]
           elif self.record.type == 39: # EVENT_JGRP_ADD
             self.jgrpNew = &(self.record.eventLog.jgrpNewLog)
             return [self.record.type,
                     "JGRP_ADD",
                     self.record.version,
                     self.record.eventTime,
                     self.jgrpNew.userId,
                     self.jgrpNew.submitTime,
                     self.jgrpNew.userName,
                     self.jgrpNew.depCond,
                     self.jgrpNew.timeEvent,
                     self.jgrpNew.groupSpec,
                     self.jgrpNew.destSpec,
                     self.jgrpNew.delOptions,
                     self.jgrpNew.delOptions2,
                     self.jgrpNew.fromPlatform]
           elif self.record.type == 40: # EVENT_JGRP_MOD
             self.jgrpNew = &(self.record.eventLog.jgrpNewLog)
             return [self.record.type,
                     "JGRP_MOD",
                     self.record.version,
                     self.record.eventTime,
                     self.jgrpNew.userId,
                     self.jgrpNew.submitTime,
                     self.jgrpNew.userName,
                     self.jgrpNew.depCond,
                     self.jgrpNew.timeEvent,
                     self.jgrpNew.groupSpec,
                     self.jgrpNew.destSpec,
                     self.jgrpNew.delOptions,
                     self.jgrpNew.delOptions2,
                     self.jgrpNew.fromPlatform]
           elif self.record.type == 41: # EVENT_JGRP_CTRL
             self.jgrpCtrl = &(self.record.eventLog.jgrpCtrlLog)
             return [self.record.type,
                     "JGRP_CTRL",
                     self.record.version,
                     self.record.eventTime,
                     self.jgrpCtrl.userId,
                     self.jgrpCtrl.userName,
                     self.jgrpCtrl.groupSpec,
                     self.jgrpCtrl.options,
                     self.jgrpCtrl.ctrlOp]
           elif self.record.type == 42: # EVENT_JOB_FORCE
             self.jobForceRequest = &(self.record.eventLog.jobForceRequestLog)
             exHosts = []
             for i from 0 <= i < self.jobForceRequest.numExecHosts:
                exHosts.append(self.jobForceRequest.execHosts[i])
             return [self.record.type,
                     "JOB_FORCE",
                     self.record.version,
                     self.record.eventTime,
                     self.jobForceRequest.userId,
                     exHosts,
                     self.jobForceRequest.jobId,
                     self.jobForceRequest.idx,
                     self.jobForceRequest.options,
                     self.jobForceRequest.userName,
                     self.jobForceRequest.queue]
           elif self.record.type == 43: # EVENT_LOG_SWITCH
             self.logSwitch = &(self.record.eventLog.logSwitchLog)
             return [self.record.type,
                     "LOG_SWITCH",
                     self.record.version,
                     self.record.eventTime,
                     logSwitch.lastJobId]
           elif self.record.type == 44: # EVENT_JOB_MODIFY2
             return [self.record.type,
                     "JOB_MODIFY2"]
           elif self.record.type == 45: # EVENT_JGRP_STATUS
             self.jgrpLog = &(self.record.eventLog.jgrpStatusLog)
             return [self.record.type,
                     "JGRP_STATUS",
                     self.record.version,
                     self.record.eventTime,
                     self.jgrpLog.groupSpec,
                     self.jgrpLog.status,
                     self.jgrpLog.oldStatus]
           elif self.record.type == 46: # EVENT_JOB_ATTR_SET
             self.jobAttrSet = &(self.record.eventLog.jobAttrSetLog)
             return [self.record.type,
                     "JOB_ATTR_SET",
                     self.record.version,
                     self.record.eventTime,
                     self.jobAttrSet.jobId,
                     self.jobAttrSet.idx,
                     self.jobAttrSet.uid,
                     self.jobAttrSet.port,
                     self.jobAttrSet.hostname]
           elif self.record.type == 47: # EVENT_JOB_EXT_MSG
             self.jobExtMsg = &(self.record.eventLog.jobExternalMsgLog)
             return [self.record.type,
                     "JOB_EXT_MSG",
                     self.record.version,
                     self.record.eventTime,
                     self.jobExtMsg.jobId,
                     self.jobExtMsg.idx,
                     self.jobExtMsg.msgIdx,
                     self.jobExtMsg.desc,
                     self.jobExtMsg.userId,
                     self.jobExtMsg.dataSize,
                     self.jobExtMsg.postTime,
                     self.jobExtMsg.dataStatus,
                     #self.jobExtMsg.fileName,
                     self.jobExtMsg.userName]
           elif self.record.type == 48: # EVENT_JOB_ATTA_DATA
             return [self.record.type,
                     "JOB_ATTR_DATA"]
           elif self.record.type == 49: # EVENT_JOB_CHUNK
             self.chunkJob = &(self.record.eventLog.jobChunkLog)
             jobs = []
             for i from 0 <= i < self.chunkJob.membSize:
                jobs.append(self.chunkJob.membJobId[i])
             hosts = []
             for i from 0 <= i < self.chunkJob.numExHosts:
                hosts.append(self.chunkJob.execHosts[i])
             return [self.record.type,
                     "JOB_CHUNK",
                     self.record.version,
                     self.record.eventTime,
                     jobs,
                     hosts]
           elif self.record.type == 50: # EVENT_SBD_UNREPORTED_STATUS
             self.sbdUnreportedStatus = &(self.record.eventLog.sbdUnreportedStatusLog)
             return [self.record.type,
                     "SBD_UNREPORTED_STATUS",
                     self.record.version,
                     self.record.eventTime,
                     self.sbdUnreportedStatus.jobId,
                     self.sbdUnreportedStatus.actPid,
                     self.sbdUnreportedStatus.jobPid,
                     self.sbdUnreportedStatus.jobPGid,
                     self.sbdUnreportedStatus.newStatus,
                     self.sbdUnreportedStatus.reason,
                     self.sbdUnreportedStatus.subreasons,
                     #struct lsfRusage lsfRusage,
                     self.sbdUnreportedStatus.execUid,
                     self.sbdUnreportedStatus.exitStatus,
                     self.sbdUnreportedStatus.execCwd,
                     self.sbdUnreportedStatus.execHome,
                     self.sbdUnreportedStatus.execUsername,
                     self.sbdUnreportedStatus.msgId,
                     #struct jRusage runRusage,
                     self.sbdUnreportedStatus.sigValue,
                     self.sbdUnreportedStatus.actStatus,
                     self.sbdUnreportedStatus.seq,
                     self.sbdUnreportedStatus.idx,
                     self.sbdUnreportedStatus.exitInfo]
           elif self.record.type == 51: # EVENT_ADRSV_FINISH
             self.rsvFinish = &(self.record.eventLog.rsvFinishLog)
             return [self.record.type,
                     "ADRSV_FINISH",
                     self.record.version,
                     self.record.eventTime,
                     self.rsvFinish.rsvReqTime,
                     self.rsvFinish.options,
                     self.rsvFinish.uid,
                     self.rsvFinish.rsvId,
                     self.rsvFinish.name,
                     self.rsvFinish.numReses,
                     #struct rsvRes *alloc,
                     self.rsvFinish.timeWindow,
                     self.rsvFinish.duration,
                     self.rsvFinish.creator]
           elif self.record.type == 52: # EVENT_HGHOST_CTRL
             self.hgCtrl = &(self.record.eventLog.hgCtrlLog)
             return [self.record.type,
                     "HGRP_CTRL",
                     self.record.version,
                     self.record.eventTime,
                     self.hgCtrl.opCode,
                     self.hgCtrl.host,
                     self.hgCtrl.grpname,
                     self.hgCtrl.userId,
                     self.hgCtrl.userName,
                     self.hgCtrl.message]
           elif self.record.type == 53: # EVENT_CPUPROFILE_STATUS
             self.cpuProfile = &(self.record.eventLog.cpuProfileLog)
             return [self.record.type,
                     "CPUPRPOFILE_STATUS",
                     self.record.version,
                     self.record.eventTime,
                     self.cpuProfile.servicePartition,
                     self.cpuProfile.slotsRequired,
                     self.cpuProfile.slotsAllocated,
                     self.cpuProfile.slotsBorrowed,
                     self.cpuProfile.slotsLent]
           elif self.record.type == 54: # EVENT_DATA_LOGGING
             self.dataLogging = &(self.record.eventLog.dataLoggingLog)
             return [self.record.type,
                     "DATA_LOGGING",
                     self.record.version,
                     self.record.eventTime,
                     self.dataLogging.loggingTime]
           else:
             return ["UNKNOWN"]
        else:
           return []

def lsb_modify(job_id, modify_dict={}):

   """
   lsb_modify : Modify a jobs's attributes

   Parameters : String - JobId
                Dict   - bmod command flag:value

   Returns    : Numeric- 0 = Successful
   """

   cdef submit req
   cdef submitReply reply

   cdef int  i
   cdef long long int jobId
   cdef long long int rc
   cdef char *job

   memset(&req, 0, sizeof(submit))
   memset(&reply, 0, sizeof(submitReply))

   jobId = int(job_id)
   for i from 0 <= i < 12:
      req.rLimits[i] = -1

   req.options  = 0x800000
   req.options2 = 0x100000
   req.delOptions  = 0
   req.delOptions2 = 0
   req.beginTime = 0
   req.termTime = 0
   req.nxf = 0
   req.numProcessors = 0
   req.maxNumProcessors = 0
   req.hostSpec = NULL
   req.resReq = NULL
   req.loginShell = NULL
   req.exceptList = NULL
   req.userPriority = -1
   req.warningAction = NULL
   req.warningTimePeriod = -1
   req.jobGroup = NULL
   req.sla = NULL
   req.licenseProject = NULL
   req.jobName = NULL

   req.command = job_id

   for key, value in modify_dict.iteritems():

       if key == 'j':
         req.jobName = value
         req.options = (req.options|0x01)

       if key == 'l' or key == 'L':
         req.loginShell = value
         req.options = (req.options|0x200000)

       if key == 'P':
         req.projectName = value
         req.options = (req.options|0x2000000)

       if key == 'g':
         req.jobGroup = value

       if key == 'G':
         req.userGroup = value
         req.options = (req.options|0x200)

       if key == 'x':
         req.options = (req.options|0x40)

       if key == 'B':
         req.options = (req.options|0x100)

       if key == 'E':
         req.options = (req.options|0x80)

       if key == 'u':
         req.mailUser = value
         req.options = (req.options|0x400000)

       if key == 'q':
         req.queue = value
         req.options = (req.options|0x02)

       if key == 'r':
         req.options = (req.options|0x4000)

       if key == 'R':
         req.resReq = value
         req.options = (req.options|0x40000)

       if key == 't':
         req.termTime = value

       if key == 'i':
         req.inFile = value
         req.options = (req.options|0x08)

       if key == 'o':
         req.outFile = value
         req.options = (req.options|0x10)

       if key == 'e':
         req.errFile = value
         req.options = (req.options|0x20)

       if key == 'n':
         req.numProcessors = value

       if key == 's':
         req.sigValue = value

       if key == 'sp':
         req.userPriority = value
         req.options = (req.options|0x200)

       if key == 'U':
         req.rsvId = value
         req.options = (req.options|0x8000)

       if key == 'Un':
         req.rsvId = ""
         req.options = (req.options|0x8000)

   rc = c_lsb_modify(&req, &reply, jobId)

   return rc

def lsb_submit(submit_dict={}, file=""):

   """
   lsb_submit : Submit a job

   Parameters : Dictionary of job attributes

   Returns    : Numeric - jobid for a successfully submitted job
   """

   cdef submit req
   cdef submitReply reply

   cdef int i
   cdef long long jobId
   cdef char *job

   jobId = -1

   # Allocate structure and populate with defaults

   memset(&req, 0, sizeof(submit))

   req.beginTime = 0
   req.beginTime = 0
   req.command = NULL
   req.hostSpec = NULL
   req.resReq = NULL
   req.loginShell = NULL
   req.exceptList = NULL
   req.nxf = 0
   req.numProcessors = 0
   req.maxNumProcessors = 0
   req.delOptions = 0
   req.delOptions2 = 0
   req.userPriority = -1
   req.warningAction = NULL
   req.warningTimePeriod = -1
   req.jobGroup = NULL
   req.sla = NULL
   req.licenseProject = NULL

   # Loop around the dictionary and populate structure

   for i from 0 <= i < 12:
      req.rLimits[i] = -1

   jobId = c_lsb_submit(&req, &reply)

   return jobId

def lsb_postjobmsg(jobid=0, message="", msgid=0):

   """
   lsb_postjobmsg : Posts a message to a job

   Parameters     : Numeric - jobid,
                    String  - message,
                    Numeric - message id

   Returns        : Numeric - 0=successful, -1=unsucessful
   """

   cdef jobExternalMsgReq jobExtMsgReq
   cdef char *fileName

   fileName = NULL

   jobExtMsgReq.options = 0x01 # EXT_MSG_POST
   jobExtMsgReq.jobName = NULL
   jobExtMsgReq.jobId = jobid
   jobExtMsgReq.msgIdx = msgid
   jobExtMsgReq.desc = message
   jobExtMsgReq.userName = NULL

   rc = c_lsb_postjobmsg(&jobExtMsgReq, fileName)

   return rc

def lsb_readjobmsg(jobid=0, msgid=0):

   cdef char *fileName
   cdef jobExternalMsgReq   jobExternalMsgReq
   cdef jobExternalMsgReply jobExternalMsgReply

   cdef int rc
   cdef int jobId
   cdef int msgId

   jobId = jobid
   msgId = msgid
   fileName = NULL

   jobExternalMsgReq.options = 0x04 # EXT_MSG_READ
   jobExternalMsgReq.jobName = NULL
   jobExternalMsgReq.msgIdx = msgId
   jobExternalMsgReq.desc = NULL
   jobExternalMsgReq.jobId = jobId

   rc = c_lsb_readjobmsg(&jobExternalMsgReq, &jobExternalMsgReply)

   msg = []
   if ( rc == 0 ):

     msg.append( [ jobExternalMsgReply.jobId,
                   jobExternalMsgReply.msgIdx,
                   jobExternalMsgReply.desc,
                   jobExternalMsgReply.userId,
                   jobExternalMsgReply.dataSize,
                   jobExternalMsgReply.postTime,
                   jobExternalMsgReply.dataStatus,
                   jobExternalMsgReply.userName ] )

   return (rc, msg)

def __countDuplicatesInList(dupLst):

   """
     http://bigbadcode.com/2007/04/04/count-the-duplicates-in-a-python-list/

     Credit - A modified version of the above code minus the list comprehensions
              so it works in pyrex; cython would work with the original code

     Parameters - List

     Returns    - List of tuples containing the number of duplicates in a list
   """

   newLst = []
   uniqueSet = Set(dupLst)
   for item in uniqueSet:
      newLst.append((item, dupLst.count(item)))
   return newLst

def job_status(status):

   state = "N/A"
   if (status & 0x00) != 0:
     state = "NULL"
   if (status & 0x01) != 0:
     state = "PEND"
   if (status & 0x02) != 0:
     state = "PSUP"
   if (status & 0x04) != 0:
     state = "RUN"
   if (status & 0x08) != 0:
     state = "SSUP"
   if (status & 0x10) != 0:
     state = "USUP"
   if (status & 0x20) != 0:
     state = "EXIT"
   if (status & 0x40) != 0:
     state = "DONE"
   if (status & 0x80) != 0:
     state = "PDONE"
   if (status & 0x100) != 0:
     state = "PERR"
   if (status & 0x200) != 0:
     state = "WAIT"
   if (status & 0x10000) != 0:
     state = "UNKWN"

   return state
