DELIMITER $$
DROP PROCEDURE IF EXISTS cleanInstance$$
DROP TABLE IF EXISTS TEMP_CLEAN_INS$$
DROP TABLE IF EXISTS TEMP_CLEAN_SCOPE$$
DROP TABLE IF EXISTS TEMP_CLEAN_MEX$$
CREATE PROCEDURE cleanInstance(tid BIGINT, inst_state SMALLINT)
BEGIN
        SELECT(' Start deleting instance data with instance ids ');
	START TRANSACTION;
	CREATE TABLE TEMP_CLEAN_INS AS SELECT ID FROM ODE_PROCESS_INSTANCE WHERE INSTANCE_STATE = inst_state AND ID=tid;
	CREATE TABLE TEMP_CLEAN_SCOPE AS SELECT os.SCOPE_ID FROM ODE_SCOPE os INNER JOIN TEMP_CLEAN_INS tc ON os.PROCESS_INSTANCE_ID = tc.ID;
	CREATE TABLE TEMP_CLEAN_MEX AS SELECT mex.MESSAGE_EXCHANGE_ID FROM ODE_MESSAGE_EXCHANGE mex INNER JOIN TEMP_CLEAN_INS tc ON mex.PROCESS_INSTANCE_ID = tc.ID;
	DELETE o FROM ODE_EVENT o INNER JOIN TEMP_CLEAN_INS tc ON o.INSTANCE_ID = tc.ID;
	DELETE FROM ODE_CORSET_PROP WHERE CORRSET_ID IN ( SELECT cs.CORRELATION_SET_ID FROM ODE_CORRELATION_SET cs INNER JOIN TEMP_CLEAN_SCOPE ts ON cs.SCOPE_ID = ts.SCOPE_ID);
	DELETE cs FROM ODE_CORRELATION_SET cs INNER JOIN TEMP_CLEAN_SCOPE ts ON cs.SCOPE_ID = ts.SCOPE_ID;
	DELETE cs FROM ODE_PARTNER_LINK cs INNER JOIN TEMP_CLEAN_SCOPE ts ON cs.SCOPE_ID = ts.SCOPE_ID;
	DELETE FROM ODE_XML_DATA_PROP WHERE XML_DATA_ID IN ( SELECT xd.XML_DATA_ID FROM ODE_XML_DATA xd INNER JOIN TEMP_CLEAN_SCOPE ts ON xd.SCOPE_ID = ts.SCOPE_ID);
	DELETE cs FROM ODE_XML_DATA cs INNER JOIN TEMP_CLEAN_SCOPE ts ON cs.SCOPE_ID = ts.SCOPE_ID;
	DELETE o FROM ODE_SCOPE o INNER JOIN TEMP_CLEAN_INS tc ON o.PROCESS_INSTANCE_ID = tc.ID;
	DELETE om FROM ODE_MEX_PROP om INNER JOIN TEMP_CLEAN_MEX tc ON om.MEX_ID= tc.MESSAGE_EXCHANGE_ID;
	DELETE om FROM ODE_MESSAGE om INNER JOIN TEMP_CLEAN_MEX tc ON om.MESSAGE_EXCHANGE_ID = tc.MESSAGE_EXCHANGE_ID;
	DELETE mex FROM ODE_MESSAGE_EXCHANGE mex INNER JOIN TEMP_CLEAN_INS tc ON mex.PROCESS_INSTANCE_ID = tc.ID;
	DELETE mr FROM ODE_MESSAGE_ROUTE mr INNER JOIN TEMP_CLEAN_INS tc ON mr.PROCESS_INSTANCE_ID = tc.ID;
	DELETE o FROM ODE_PROCESS_INSTANCE o INNER JOIN TEMP_CLEAN_INS tc ON o.ID = tc.ID;
	DROP TABLE TEMP_CLEAN_INS;
	DROP TABLE TEMP_CLEAN_SCOPE;
	DROP TABLE TEMP_CLEAN_MEX;
	COMMIT;
        SELECT(' End deleting instance data with instance ids ');
END$$
DELIMITER ;

SET @INST_STATE =30;

-- 	Set ID to be removed
-- 	Ex:
--	SET @ID=11;

SET @ID=0;

SELECT(' Starting cleanInstance procedure ');
CALL cleanInstance(@ID, @INST_STATE);
SELECT (' Ending cleanInstance procedure ');
