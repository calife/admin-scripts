sqlplus system/system@TEMPLATE @create_TEMPLATE.sql

#Import the tables, data, constraints, triggers, ... from schema .dmp file
#Note the migration of data for both user AFM and user AFM_SECURE.

imp system/system@TEMPLATE fromuser=afm_secure touser=afm_secure file=afmoscm.dmp log=afm_secure.log
imp system/system@TEMPLATE fromuser=afm touser=afm file=afmoscm.dmp log=afm.log

#Create foreign key constraint AFM_USERS_ROLE_NAME referencing AFM_ROLES.
#Required for v14.3i+

sqlplus system/system@TEMPLATE @afm_roles_const.sql

sqlplus system/system@TEMPLATE @chg_prof_limit.sql

sqlplus system/system@TEMPLATE @grants_extra.sql 
