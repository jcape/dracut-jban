dracut-jban
===========

James' Boot-And-Nuke, a module for dracut which uses hdparm and wipe to erase
HDD and SSD devices.

The main caveat is that your SSD must be plugged into something that will accept
or pass-through the SATA secure-erase commands---your typical hardware RAID card
only presents the logical devices, so these commands won't work.

Breaking any arrays and putting the controller into JBOD mode may allow these
commands to work, but I haven't tested it, and that functionality is beyond the
current scope of this module.

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=jcape&url=https://github.com/jcape/dracut-jban&title=dracut-jban&language=&tags=github&category=software) 
