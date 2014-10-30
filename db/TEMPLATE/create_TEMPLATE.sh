#
# Template - Wednesday, 29. October 2014
#

# Pre import
sqlplus system/system@TEMPLATE @create_TEMPLATE.sql
sqlplus system/system@TEMPLATE @tblspace.sql

# Import
imp system/system@TEMPLATE fromuser=afm_secure touser=afm_secure file=afmoscm.dmp log=afm_secure.log
imp system/system@TEMPLATE fromuser=afm touser=afm file=afmoscm.dmp log=afm.log

# Post import
sqlplus system/system@TEMPLATE @afm_roles_const.sql
sqlplus system/system@TEMPLATE @chg_prof_limit.sql
sqlplus system/system@TEMPLATE @grants_extra.sql
sqlplus system/system@TEMPLATE @pwd.sql
