--  afm_roles_const.sql (for use with Oracle)
--
--  Creates constraint AFM_USERS_ROLE_NAME on the AFM_USERS table, owned by AFM_SECURE,
--  which references table AFM_ROLES, owned by AFM.  The constraint is created using this
--  file to avoid "Table does not exist" error due to the table AFM_ROLES not having been
--  created at the time this constraint would be typically loaded.
--
--  NOTE: Be sure to modify the SYSTEM/MANAGER userid as required.


SPOOL AFM_ROLES_CONST.LST

ALTER TABLE "AFM_SECURE"."AFM_USERS" ADD CONSTRAINT "AFM_USERS_ROLE_NAME" FOREIGN KEY ("ROLE_NAME") REFERENCES "AFM"."AFM_ROLES" ("ROLE_NAME");

SPOOL OFF
EXIT

