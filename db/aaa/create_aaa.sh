#
# Template - Wednesday, 22. October 2014
#

sqlplus system/system@aaa @create_aaa.sql
sqlplus system/system@aaa @tablespace.sql

imp system/system@aaa fromuser=afm_secure touser=afm_secure file=afmoscm.dmp log=afm_secure.log
imp system/system@aaa fromuser=afm touser=afm file=afmoscm.dmp log=afm.log

sqlplus system/system@aaa @afm_roles_const.sql
sqlplus system/system@aaa @chg_prof_limit.sql
sqlplus system/system@aaa @grants_extra.sql 
