/*
 *  File name:  ProjectSetup.sql
 *  Function:   to drop & create triggers,indexs, and get ready for
 *  the Radiology Information System.
 */



CREATE OR REPLACE TRIGGER checkEmail
BEFORE INSERT ON persons
FOR EACH ROW
DECLARE dummy INTEGER;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	SELECT count(*) INTO dummy
	FROM persons p
	WHERE email = :NEW.email AND
	      p.person_id <> :NEW.person_id;

	IF dummy > 0
	THEN
		raise_application_error(-20000, 'Duplicate Email!');
	END IF;
COMMIT;
END;
/


CREATE OR REPLACE TRIGGER checkUserName
BEFORE INSERT ON users
FOR EACH ROW
DECLARE dummy INTEGER;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	SELECT count(*) INTO dummy
	FROM users
	WHERE user_name = :NEW.user_name;

        IF dummy > 0
	THEN
		raise_application_error(-20001, 'The user name exists!');
	END IF;
COMMIT;
END;
/

DROP TABLE fullname;
DROP INDEX dx;
DROP INDEX des;
CREATE INDEX dx ON radiology_record(diagnosis) INDEXTYPE IS CTXSYS.CONTEXT;
CREATE INDEX des ON radiology_record(description) INDEXTYPE IS CTXSYS.CONTEXT;


set serveroutput on
declare
  job1 number;
  job2 number;
begin
  dbms_job.submit(job1, 'ctx_ddl.sync_index(''dx'');',
                  interval=>'SYSDATE+0/1440');
  dbms_job.submit(job2, 'ctx_ddl.sync_index(''des'');',
                  interval=>'SYSDATE+0/1440');
  commit;
  dbms_output.put_line('job1 '||job1||' has been submitted.');
  dbms_output.put_line('job2 '||job2||' has been submitted.');
end;
/
