# SCS Scheduler lambda functions

import of runCMD's `EC2` and `RDS` scheduler scripts.

### Tag format to schedule EC2 and RDS instances (USES AEST TimeZone):
  - Key: "cmd:powerup"
    Value: "6:01234"
  - Key: "cmd:powerdown"
    Value: "22:0123456"

### Tag format to schedule RDS instances (uses UTC TimeZone):
  ## For RDS instances with Multi-AZ for non-Prod environments, additional `1 hour and 30min` is required to powerup and powerdown so configured to start 2 hours prior to actual start time
  - Key: "powerup"
    Value: "20:30:0123456" (HOUR:MIUNTE:DAY - Mon,Tue,Wed,Thur,Fri,Sun,Sat)
  - Key: "powerdown"
    Value: "20:30:0123456" (HOUR:MIUNTE:DAY - Mon,Tue,Wed,Thur,Fri,Sun,Sat)
