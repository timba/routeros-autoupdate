:global emailBody;
:global updateVersion;

# Specify notifications emails receiver
:local to "notification.email@example.com"

:local emailSubject "RouterOS Update $updateVersion";

/tool e-mail send to=$to subject=$emailSubject body=$emailBody
