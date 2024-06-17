# DFIR_EntraID
This repo conatins quick powershell scripts that can come in handy in BEC or EntraID DFIR cases

As with the EasiCSIRT we encounter quite some BEC or EntraID hacks where we lost quite some time revoking and resetting users some what manually we decided to create a small and simple script.
This ain't rocket science guys and i'm definitely not a great scripting guy but all small things can help in the end.

The usage of the script can be found here:

1. Run the ps1 script with an administrative powershell session
2. Connect to the impacted Entra tenant (also here you would need admin privileges to push revoke and disable commands)
3. Enter the UPN of the user(s) you want to affect. e.g. 'j.dhoe@COMPANY.net, s.alias@COMPANY.net'. This will pull the UID's of the users to execute the commands to.
4. Next define the actions you want execute, the following 5 options are available
   a) Revoke All Session
   b) Reset Password
   c) Both Revoke All Session & Reset Password
   d) Disable User
   e) None
5. press enter after selecting the executions you want to achieve.

NOTE: It might be possible that existing tokens are still working until their expiring time is exceeded.

I hope this can safe you guys some time during DFIR cases on EntraID.

If you have any questions, errors, pointers,... don't hesitate to let me know.

Cheers.
