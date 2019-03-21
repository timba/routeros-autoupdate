:global updateVersion;
:global upgradeVersion;
:global updateProcess;
:global upgradeProcess;
:global emailBody;

# Specify WAN connection name to wait when it is up
:local connection "connection-name";

:local connected false;

:log info "System Autoupdate: Waiting for internet connection...";

:delay 5s;

:do {
    
    # In this example PPPoE WAN connection is used, specify your connection type if needed
    /interface pppoe-client monitor $connection once do={
        :if ($status != "connected") do={
            :delay 5s;
        } else={
            :set $connected true;
        }
    }

} while ($connected = false);

:log info "System Autoupdate: Internet connection established. Continue update.";

/system script;

:if ($updateProcess = true) do={ 

    :local installedVersion [/system package update get installed-version]

    :if ($updateVersion != $installedVersion) do={

        :set $emailBody "RouterOS has not been updated.\nInstalled version: $installedVersion\nUpdate version: $updateVersion";
        run system-email;
        :log error "System Autoupdate: Version not updated and remains on version: $installedVersion";
        :error;

    }

    :local currentFw [/system routerboard get current-firmware]
    :local upgradeFw [/system routerboard get upgrade-firmware]

    :if ($currentFw = $upgradeFw) do={
        :set $emailBody "Routerboard firmware doesn't need upgrade and remains on version: $currentFw.";
        run system-email;
        :log error "System Autoupdate: RouterOS updated but Routerboard firmware doesn't need upgrade and remains on version: $currentFw"
        :error;
    }
    
    :set $emailBody "RouterOS has been updated. Executing Routerboard upgrade to version $upgradeFw.";
    run system-email;
    :log info "System Autoupdate: Routerboard firmware being updated to version: $upgradeFw";

    :set $upgradeVersion $upgradeFw;

    /system schedule add name="upgrade-on-boot" on-event="/system scheduler remove upgrade-on-boot; :global updateProcess false; :global upgradeProcess true; :global updateVersion \"$updateVersion\"; :global upgradeVersion \"$upgradeVersion\"; /system script run system-upgrade;" start-time=startup interval=0;

    /system routerboard upgrade;
    :delay 5s;
    /system reboot;

} else={ :if ($upgradeProcess = true) do={

    :local currentFw [/system routerboard get current-firmware]
    :if ($currentFw != $upgradeVersion) do={
        :set $emailBody "Routerboard firmware has not been upgraded.\nCurrent firmware: $currentFw\nUpgrade firmware: $upgradeVersion";
        run system-email;
        :error "System Autoupdate: Routerboard firmware has not been upgraded to version $upgradeFw and remains on version $currentFw";
    } else={
        :set $emailBody "Routerboard firmware has been upgraded. System update completed.";
        run system-email;
        :log info "System Autoupdate: Routerboard firmware has been upgraded to version: $currentFw.";
    }
}}
