1.


SET LINESIZE 130;
SET PAGESIZE 130;
SET SERVEROUTPUT ON
SET VERIFY OFF 

CREATE OR REPLACE PROCEDURE mine(
p_visa_exp varchar2,
p_case_char char
) IS
v_count NUMBER;
e_invalid_input EXCEPTION;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Last day of the month ' || p_visa_exp || ' is ' || TO_CHAR(last_day(to_date(p_visa_exp,'MM/YY')),'day'));
	
	IF (UPPER(p_case_char) NOT LIKE 'P' AND UPPER(p_case_char) NOT LIKE 'F' and UPPER(p_case_char) NOT LIKE 'B') 
	THEN 
	RAISE e_invalid_input;
	
	ELSIF (UPPER(p_case_char) = 'P') THEN
	SELECT COUNT(*) INTO v_count FROM user_objects
	WHERE object_type = 'PROCEDURE';
	DBMS_OUTPUT.PUT_LINE('Number of stored objects of type ' || p_case_char || ' is ' || v_count);
	
	ELSIF (UPPER(p_case_char) = 'F') THEN
	SELECT COUNT(*) INTO v_count FROM user_objects
	WHERE object_type = 'FUNCTION';
	DBMS_OAUTPUT.PUT_LINE('Number of stored objects of type ' || p_case_char || ' is ' || v_count);
	
	ELSIF (UPPER(p_case_char) = 'B') THEN
	SELECT COUNT(*) INTO v_count FROM user_objects
	WHERE object_type = 'PACKAGE';
	
	DBMS_OUTPUT.PUT_LINE('Number of stored objects of type ' || p_case_char || ' is ' || v_count);
	END IF;
	
	EXCEPTION
	WHEN e_invalid_input THEN
	DBMS_OUTPUT.PUT_LINE('You have entered an Invalid letter for the stored object. Try P, F or B.');
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY');
	
END mine;
/

 EXECUTE MINE('11/09','P');
 EXECUTE MINE('12/09','f');
 EXECUTE MINE('01/10','T');
 EXECUTE MINE('13/09','P');	
	
Procedure created.

Last day of the month 11/09 is monday                                                                                             
Number of stored objects of type P is 3                                                                                           

PL/SQL procedure successfully completed.

Last day of the month 12/09 is thursday                                                                                           
Number of stored objects of type f is 2                                                                                           

PL/SQL procedure successfully completed.

Last day of the month 01/10 is sunday                                                                                             
You have entered an Invalid letter for the stored object. Try P, F or B.                                                          

PL/SQL procedure successfully completed.

You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY                                                              

PL/SQL procedure successfully completed.






























2.
SQL> @dbs501_lab4_2;

SET LINESIZE 130;
SET PAGESIZE 130;
SET SERVEROUTPUT ON
SET VERIFY OFF 
SET AUTOPRINT ON

CREATE OR REPLACE PROCEDURE add_zip(
  p_zip zipcode.zip%TYPE,
  p_city zipcode.city%TYPE,
  p_state zipcode.state%TYPE,
  p_rows OUT NUMBER,
  p_success OUT VARCHAR2)
IS
  v_zip zipcode.zip%TYPE;
BEGIN
  SELECT zip INTO v_zip FROM zipcode
  WHERE zip = p_zip;
  p_success := 'FAILURE';
  DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || p_zip ||' is already in the Database. Try again.');
  SELECT COUNT(*) INTO p_rows FROM zipcode 
  WHERE state = p_state;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_success := 'SUCCESS';
    INSERT INTO zipcode
    VALUES (p_zip, p_city, p_state, USER, SYSDATE, USER, SYSDATE);
    SELECT COUNT(*) INTO p_rows FROM zipcode
    WHERE state = p_state;
END add_zip;
/

VARIABLE flag VARCHAR2(10)
VARIABLE zipnum NUMBER

EXECUTE add_zip('18104', 'Chicago', 'MI', :zipnum, :flag)
SELECT  * FROM zipcode WHERE  state = 'MI';
ROLLBACK;

EXECUTE add_zip('48104', 'Ann Arbor', 'MI', :zipnum, :flag)
SELECT  * FROM zipcode WHERE  state = 'MI';
ROLLBACK;

Procedure created.


PL/SQL procedure successfully completed.




FLAG                                                                                                                              
--------------------------------                                                                                                  
SUCCESS                                                                                                                           


    ZIPNUM                                                                                                                        
----------                                                                                                                        
         2                                                                                                                        


ZIP   CITY                      ST CREATED_BY                     CREATED_D MODIFIED_BY                    MODIFIED_              
----- ------------------------- -- ------------------------------ --------- ------------------------------ ---------              
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99 ARISCHER                       24-NOV-99              
18104 Chicago                   MI DBS501_183A19                  14-NOV-18 DBS501_183A19                  14-NOV-18              


Rollback complete.

This ZIPCODE 48104 is already in the Database. Try again.                                                                         

PL/SQL procedure successfully completed.


FLAG                                                                                                                              
--------------------------------                                                                                                  
FAILURE                                                                                                                           


    ZIPNUM                                                                                                                        
----------                                                                                                                        
         1                                                                                                                        


ZIP   CITY                      ST CREATED_BY                     CREATED_D MODIFIED_BY                    MODIFIED_              
----- ------------------------- -- ------------------------------ --------- ------------------------------ ---------              
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99 ARISCHER                       24-NOV-99              


Rollback complete.







3.
SQL> @dbs501_lab4_3;

SET LINESIZE 130;
SET PAGESIZE 130;
SET SERVEROUTPUT ON
SET AUTOPRINT ON
SET VERIFY OFF 


CREATE OR REPLACE function exist_zip(
v_zip zipcode.zip%TYPE
) 
RETURN BOOLEAN
IS

V_INPUT NUMBER;
BEGIN
	SELECT count(*) INTO V_INPUT from ZIPCODE
	where ZIP = v_zip;
	
	IF V_INPUT > 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
	RETURN FALSE;

END exist_zip;
/

CREATE OR REPLACE PROCEDURE add_zip2(
  p_zip zipcode.zip%TYPE,
  p_city zipcode.city%TYPE,
  p_state zipcode.state%TYPE,
  p_rows OUT NUMBER,
  p_success OUT VARCHAR2)
IS
  v_zip zipcode.zip%TYPE;
  FALSE_DATA EXCEPTION;
BEGIN
 
   
   IF exist_zip(p_zip) THEN
    p_success := 'FAILURE';
   ELSE
    RAISE FALSE_DATA;
   
   END IF;   
	

  DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || p_zip ||' is already in the Database. Try again.');
  SELECT COUNT(*) INTO p_rows FROM zipcode 
  WHERE state = p_state;
EXCEPTION
  WHEN FALSE_DATA THEN
    p_success := 'SUCCESS';
    INSERT INTO zipcode
    VALUES (p_zip, p_city, p_state, USER, SYSDATE, USER, SYSDATE);
    SELECT COUNT(*) INTO p_rows FROM zipcode
    WHERE state = p_state;
END add_zip2;
/

VARIABLE flag VARCHAR2(10)
VARIABLE zipnum NUMBER

EXECUTE add_zip2('18104', 'Chicago', 'MI', :zipnum, :flag)
SELECT  * FROM zipcode WHERE  state = 'MI';
ROLLBACK;

EXECUTE add_zip2('48104', 'Ann Arbor', 'MI', :zipnum, :flag)
SELECT  * FROM zipcode WHERE  state = 'MI';
ROLLBACK;


Function created.


Procedure created.


PL/SQL procedure successfully completed.


FLAG                                                                                                                              
--------------------------------                                                                                                  
SUCCESS                                                                                                                           


    ZIPNUM                                                                                                                        
----------                                                                                                                        
         2                                                                                                                        


ZIP   CITY                      ST CREATED_BY                     CREATED_D MODIFIED_BY                    MODIFIED_              
----- ------------------------- -- ------------------------------ --------- ------------------------------ ---------              
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99 ARISCHER                       24-NOV-99              
18104 Chicago                   MI DBS501_183A19                  14-NOV-18 DBS501_183A19                  14-NOV-18              


Rollback complete.

This ZIPCODE 48104 is already in the Database. Try again.                                                                         

PL/SQL procedure successfully completed.


FLAG                                                                                                                              
--------------------------------                                                                                                  
FAILURE                                                                                                                           


    ZIPNUM                                                                                                                        
----------                                                                                                                        
         1                                                                                                                        


ZIP   CITY                      ST CREATED_BY                     CREATED_D MODIFIED_BY                    MODIFIED_              
----- ------------------------- -- ------------------------------ --------- ------------------------------ ---------              
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99 ARISCHER                       24-NOV-99              


Rollback complete.


























4.
SQL> @dbs501_lab4_4;

SET LINESIZE 130;
SET PAGESIZE 130;
SET SERVEROUTPUT ON
SET AUTOPRINT ON
SET VERIFY OFF 


CREATE OR REPLACE function instruct_status(
v_first instructor.first_name%TYPE,
v_last instructor.last_name%TYPE
) 
RETURN VARCHAR2
IS

v_instructor_id instructor.instructor_id%TYPE;
v_sections NUMBER;
V_message varchar2(100);


BEGIN
	SELECT instructor_id into v_instructor_id from instructor
	where first_name = v_first
	and last_name = v_last;
	
	SELECT COUNT(*) into v_sections from section
	where instructor_id = v_instructor_id;
	
	IF (v_sections > 9) THEN
	v_message := 'This Instructor will teach 10 course and needs a vacation';
	ELSIF (v_sections > 0 AND v_sections <= 9) THEN
	v_message := 'This Instructor will teach ' || v_sections || ' courses';
	ELSE
	v_message := 'This Instructor is NOT scheduled to teach ';
	
	END IF;
	
	RETURN v_message;
	

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	v_message := 'There is NO such instructor'; 
	RETURN v_message;
	WHEN OTHERS THEN
	v_message := 'Error';
	RETURN v_message;

END instruct_status;
/

VARIABLE message VARCHAR2(100);

SELECT last_name, INSTRUCT_STATUS(FIRST_NAME, LAST_NAME) "Instructor_Status"
FROM INSTRUCTOR
ORDER by LAST_NAME;

EXECUTE :message := instruct_status('Peter', 'Pan');
EXECUTE :message := instruct_status('Irene', 'Willig');
 

Function created.


LAST_NAME                                                                                                                         
-------------------------                                                                                                         
Instructor_Status                                                                                                                 
----------------------------------------------------------------------------------------------------------------------------------
Chow                                                                                                                              
This Instructor is NOT scheduled to teach                                                                                         
                                                                                                                                  
Frantzen                                                                                                                          
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  
Hanks                                                                                                                             
This Instructor will teach 9 courses                                                                                              
                                                                                                                                  
Lowry                                                                                                                             
This Instructor will teach 9 courses                                                                                              
                                                                                                                                  
Morris                                                                                                                            
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  
Pertez                                                                                                                            
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  
Schorin                                                                                                                           
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  
Smythe                                                                                                                            
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  
Willig                                                                                                                            
This Instructor is NOT scheduled to teach                                                                                         
                                                                                                                                  
Wojick                                                                                                                            
This Instructor will teach 10 course and needs a vacation                                                                         
                                                                                                                                  

10 rows selected.


PL/SQL procedure successfully completed.


MESSAGE                                                                                                                           
--------------------------------------------------------------------------------------------------------------------------------  
There is NO such instructor                                                                                                       


PL/SQL procedure successfully completed.


MESSAGE                                                                                                                           
--------------------------------------------------------------------------------------------------------------------------------  
This Instructor is NOT scheduled to teach                                                                                         

SQL> spool off;


Lab 3 DBS 501 By Le, Sean Teacher: Nebojsa

