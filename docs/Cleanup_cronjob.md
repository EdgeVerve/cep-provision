## Cronjob for cleanup


Cleanup cronjob is an operational tools which help remove unused docker volumes, images, containers, networks and garbage collect unwanted image layers in private registry in all host machines periodically.

Below are the parameters supported to setup cleanup cronjob, you can modify as per the requirement in the file <b>*group_vars/all*</b> before ansible play.


*cleanup_cron_enable:* Default is 'yes'; specify 'no' to skip cleanup cronjob setup<br>
*cleanup_cron_timing:* Default is "0 4 * * *"; modify as per schedule requirement<br>
*cleanup_cron_user:* Default is "root"; modify to run conjob as a specific user<br>
*crontab_file:* default is "/etc/crontab"