#
# Template - Wednesday, 22. October 2014
#

sqlplus system/system@TEMPLATE @create.sql
sqlplus system/system@TEMPLATE @tablespace.sql

imp system/system@TEMPLATE fromuser=afm_secure touser=afm_secure file=afmoscm.dmp log=afm_secure.log
imp system/system@TEMPLATE fromuser=afm touser=afm file=afmoscm.dmp log=afm.log

sqlplus system/system@TEMPLATE @afm_roles_const.sql
sqlplus system/system@TEMPLATE @chg_prof_limit.sql
sqlplus system/system@TEMPLATE @grants_extra.sql 
