alter system set sec_case_sensitive_logon=false scope=both;
alter profile default limit PASSWORD_LIFE_TIME unlimited;
alter profile default limit  FAILED_LOGIN_ATTEMPTS unlimited;
quit;

