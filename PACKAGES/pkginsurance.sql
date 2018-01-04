--BRANCH 1 CODES

CREATE OR REPLACE PACKAGE PKGINSURANCE AS

    FUNCTION    VALIDATE_INSURANCE               (DATASTRING  IN   VARCHAR2)     RETURN   VARCHAR2;
    FUNCTION    GET_ACCNAME       (ACNO IN   VARCHAR2)     RETURN   VARCHAR2;

END;
/


CREATE OR REPLACE PACKAGE BODY  PKGINSURANCE  IS

FUNCTION    GET_ACCNAME       (ACNO IN   VARCHAR2)     RETURN   VARCHAR2 IS

    GET_ACCNAME       VARCHAR2(500);

BEGIN

    SELECT 'A'||'|'||ACCT_NAME||'|'||SOL_ID||'|'||ACCT_CLS_DATE||'|'||SCHM_TYPE
      INTO GET_ACCNAME 
      FROM GAM 
     WHERE FORACID = ACNO;
     
    RETURN GET_ACCNAME;
          
EXCEPTION
   WHEN OTHERS THEN 

    RETURN 'ERROR';

END GET_ACCNAME;

FUNCTION    VALIDATE_INSURANCE              (DATASTRING IN VARCHAR2)  RETURN   VARCHAR2 IS
    
    VALIDATE_INSURANCE                     VARCHAR2(1000);
    
    GMODE                                 VARCHAR2(100);
    GINSURANCEID                          VARCHAR2(100);
    GRENEWALID                            VARCHAR2(100);
    GACCNO                                VARCHAR2(100);
    GPOLICYNUM                            VARCHAR2(100);
    GASSETTYPE                            VARCHAR2(100);
    GINSUREDFROM                          VARCHAR2(100);
    GINSUREDTILL                          VARCHAR2(100);
    GINSUREDAMOUNT                        VARCHAR2(100);
    GPREMIUM                              VARCHAR2(100);
    GCOMPANY                              VARCHAR2(100);
    GBRANCH                               VARCHAR2(100);
    GREASON                               VARCHAR2(100);
    GCLSUSER                              VARCHAR2(100);
    GRUSER                                VARCHAR2(100);
    GMUSER                                VARCHAR2(100);
    GCUSER                                VARCHAR2(100);
    GUUSER                                VARCHAR2(100);
    GVUUSER                               VARCHAR2(100);
    
    GASSETDESC                            VARCHAR2(100);
    GCOMPANYDESC                          VARCHAR2(100);
    
    GSTEP                                 VARCHAR2(100);    
    GSOLID                                VARCHAR2(100);
    GUSERID                               VARCHAR2(100);
    GBODDATE                              VARCHAR2(100);
    GRENEWTODATE                          DATE;
    AINSUREDFROM                          DATE;
    
    GACCTNAME                             VARCHAR2(500);
    TEMPDATE1                             DATE;
    TEMPCOUNT1                            NUMBER(10);
    INSUR_SEQ                             NUMBER(20);
    
    GSTATUS                               NUMBER(2);
    GSTATUSNAME                           VARCHAR2(10);
            
BEGIN

    GMODE                           := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',1);
    GINSURANCEID                    := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',2);
    GACCNO                          := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',3);  
    GPOLICYNUM                      := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',4);   
    GASSETTYPE                      := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',5);
    GINSUREDFROM                    := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',6);
    GINSUREDTILL                    := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',7);
    GINSUREDAMOUNT                  := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',8);
    GPREMIUM                        := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',9);
    GCOMPANY                        := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',10);
    GBRANCH                         := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',11);
    GREASON                         := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',12);

    GSOLID                          := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',13);
    GUSERID                         := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',14);
    GBODDATE                        := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',15);    
    GSTEP                           := PKGSMGBCOMMON.DELIMITEDTEXT(DATASTRING,'^',16);
     
    SELECT PKGINSURANCE.GET_ACCNAME(GACCNO)
      INTO GACCTNAME
      FROM DUAL;     
    
    -- RETURNING THE RECORDS BASED ON THE INPUTED INSURANCE ID
    
    IF GSTEP = '1' THEN
        
        IF GMODE <> 'A' THEN  
            
            BEGIN
                        
                SELECT RECORD_STATUS
                  INTO GSTATUS
                  FROM C_INSURANCE  
                 WHERE INSURANCE_ID = GINSURANCEID;
                 
                GSTATUSNAME := CASE WHEN GSTATUS = 1 THEN 'ADDED'
                                    WHEN GSTATUS = 11 THEN 'MODIFIED'
                                    WHEN GSTATUS = 21 THEN 'UPDATED'
                                    WHEN GSTATUS = 51 THEN 'VERIFIED'
                                    WHEN GSTATUS = 99 THEN 'DELETED'
                                    WHEN GSTATUS = 61 THEN 'CLOSED'
                                    WHEN GSTATUS = 71 THEN 'RENEWED'
                                    ELSE 'UNKNOWN' END;
                         
            EXCEPTION
                 WHEN OTHERS THEN
                         
                 VALIDATE_INSURANCE:= RPAD('F01No Record Found. Press F3 to quit.',70);
                 RETURN VALIDATE_INSURANCE;
                         
            END;
            
        END IF;
        
        IF GMODE IN ('M','D','V') THEN
            
            IF GSTATUS >= 51  THEN

                VALIDATE_INSURANCE:= RPAD('F01Record is in '||GSTATUSNAME||' status. Press F3 to quit.',70);
                RETURN VALIDATE_INSURANCE;

            END IF;
            
            IF GMODE IN ('M','D') AND GSTATUS = 21 THEN
                
                VALIDATE_INSURANCE:= RPAD('F01Record is in '||GSTATUSNAME||' status. Press F3 to quit.',70);
                RETURN VALIDATE_INSURANCE;
                
            END IF;
            
        ELSIF GMODE = 'I' THEN    
            
            IF GSTATUS NOT IN (1,11,21,51,71) THEN

                VALIDATE_INSURANCE:= RPAD('F01Record is in '||GSTATUSNAME||' status. Press F3 to quit.',70);
                RETURN VALIDATE_INSURANCE;

            END IF;         
            
        ELSIF GMODE IN ('R', 'C', 'U') THEN            
                
            IF GSTATUS <> 51  THEN

                VALIDATE_INSURANCE:= RPAD('F01Record not in verified status. Press F3 to quit.',70);
                RETURN VALIDATE_INSURANCE;

            END IF;
                
        END IF;
        
        GACCTNAME := PKGSMGBCOMMON.DELIMITEDTEXT(GACCTNAME,'|',2);
     
        SELECT INSURANCE_ID,ACCOUNT_NO,INSURED_ASSET_DETAILS,INSURED_FROM,INSURED_TO,INSURED_AMOUNT,PREMIUM_AMOUNT,POLICY_NO,
               INSURANCE_COMPANY,BRANCH_NAME,CLOSE_REASON,RENEW_INSURANCE_ID,CLSUSER,RUSER,MUSER,CUSER,UUSER,VUUSER
          INTO GINSURANCEID,GACCNO,GASSETTYPE,GINSUREDFROM,GINSUREDTILL,GINSUREDAMOUNT,GPREMIUM,GPOLICYNUM,
               GCOMPANY,GBRANCH,GREASON,GRENEWALID,GCLSUSER,GRUSER,GMUSER,GCUSER,GUUSER,GVUUSER
          FROM C_INSURANCE 
         WHERE INSURANCE_ID = GINSURANCEID;
         
        IF GMODE = 'R' AND GRUSER IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01The record is already renewed.',70);
            RETURN VALIDATE_INSURANCE;
            
        ELSIF GMODE = 'R' AND GCLSUSER IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01The record is already closed.',70);
            RETURN VALIDATE_INSURANCE;           
            
        ELSIF GMODE = 'C' AND GRUSER IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01The record is renewed, cannot close.',70);
            RETURN VALIDATE_INSURANCE;   
            
        ELSIF GMODE = 'C' AND GCLSUSER IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01The record is already closed.',70);
            RETURN VALIDATE_INSURANCE;                          
            
        ELSIF GMODE = 'U' AND GUUSER IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Update not allowed more than once. Close and create new if required.',70);
            RETURN VALIDATE_INSURANCE;               
            
        END IF;                   
          
        BEGIN
            
            SELECT NVL(SECU_DESC,'')          
              INTO GASSETDESC
              FROM ASM
             WHERE SECU_CODE = TRIM(GASSETTYPE)
               AND DEL_FLG = 'N';
            
        EXCEPTION 
             WHEN OTHERS THEN
             
            VALIDATE_INSURANCE:= RPAD('F02Invalid Asset Type is uploaded.',70);
            RETURN VALIDATE_INSURANCE;
             
        END;            
        
        BEGIN
            
            SELECT NVL(CODE_DESCRIPTION,'')            
              INTO GCOMPANYDESC
              FROM C_REFCODE
             WHERE MAIN_CODE = 1120
               AND SUB_CODE <> 0
               AND UPPER(CODE_DESCRIPTION) = UPPER(TRIM(GCOMPANY));
            
        EXCEPTION 
             WHEN OTHERS THEN
             
            VALIDATE_INSURANCE:= RPAD('F02Invalid Insurance Company Name is uploaded.',70);
            RETURN VALIDATE_INSURANCE;
             
        END; 
        
        IF GMODE = 'V' AND GSTATUS = 21 AND GUUSER = GUSERID THEN 
            
            VALIDATE_INSURANCE:= RPAD('F00Same user should not verify the record. Press F3 to quit.',70);
            RETURN VALIDATE_INSURANCE;
            
        END IF;
        
        IF GMODE = 'V' AND GSTATUS <> 21 AND NVL(GMUSER,GCUSER) = GUSERID THEN            
            
            VALIDATE_INSURANCE:= RPAD('F00Same user should not verify the record. Press F3 to quit.',70);
            RETURN VALIDATE_INSURANCE;
            
        END IF;
        
        IF GMODE IN ('V','C') THEN
            
            IF  PKGSMGBCOMMON.AUTHORISATIONPOWER(GUSERID) = 'N' THEN 

                VALIDATE_INSURANCE:= RPAD('F00Cannot Proceed. Insufficient Privilages.',70);
                RETURN VALIDATE_INSURANCE;

            END IF;
            
        END IF;
        
        IF GMODE IN ('R','C') THEN
            
            IF GCLSUSER IS NOT NULL THEN
                
                VALIDATE_INSURANCE:= RPAD('F00The Record is already closed.Cannot proceed.',70);
                RETURN VALIDATE_INSURANCE;
                
            END IF;
            
            IF GRUSER IS NOT NULL THEN
                
                VALIDATE_INSURANCE:= RPAD('F00The Record is already renewed.Cannot proceed.',70);
                RETURN VALIDATE_INSURANCE;
                
            END IF;
            
        END IF;
        
        IF GMODE = 'R' THEN

            VALIDATE_INSURANCE:= 'S'||GINSURANCEID||'^'||GACCNO||'^'||GPOLICYNUM||'^'||GASSETTYPE||'^^^^^'||GCOMPANY||'^'||GBRANCH||'^'||GREASON||'^'||GACCTNAME||'^'||GASSETDESC||'^'||GCOMPANYDESC||'^'||GSTATUS;
            RETURN VALIDATE_INSURANCE;

        ELSE
            
            VALIDATE_INSURANCE:= 'S'||GINSURANCEID||'^'||GACCNO||'^'||GPOLICYNUM||'^'||GASSETTYPE||'^'||GINSUREDFROM||'^'||GINSUREDTILL||'^'||GINSUREDAMOUNT||'^'||GPREMIUM||'^'||GCOMPANY||'^'||GBRANCH||'^'||GREASON||'^'||GACCTNAME||'^'||GASSETDESC||'^'||GCOMPANYDESC||'^'||GSTATUS;
            RETURN VALIDATE_INSURANCE;
            
        END IF;
            
    END IF;
    
    IF GSTEP = '2' THEN
        
        -- VALIDATING INSURANCE ID
        
        IF GMODE <> 'A' AND GINSURANCEID IS NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Insurance ID cannot be empty.',70);
            RETURN VALIDATE_INSURANCE;
            
        END IF;
        
        IF GMODE <> 'A' AND NVL(PKGSMGBCOMMON.VALIDATECUSTOMVALUESONLY(GINSURANCEID,'1234567890'),1) = 1 THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Only numerics are allowed in Insurance ID',70);
            RETURN VALIDATE_INSURANCE;  
            
        END IF;
        
        -- VALIDATING ACCOUNT NUMBER
        
        IF GACCNO IS NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Enter the Account Number',70);
            RETURN VALIDATE_INSURANCE;
            
        END IF;
        
        IF GACCTNAME = 'ERROR' THEN 
            
            VALIDATE_INSURANCE:= RPAD('F01Invalid Account Number',70);
            RETURN VALIDATE_INSURANCE;
                            
        END IF;
        
        IF PKGSMGBCOMMON.DELIMITEDTEXT(GACCTNAME,'|',4) IS NOT NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01The Account is already closed',70);
            RETURN VALIDATE_INSURANCE;       

        END IF; 
            
        IF PKGSMGBCOMMON.DELIMITEDTEXT(GACCTNAME,'|',5) NOT IN ('CCA','ODA','LAA') THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Enter a valid loan account number.',70);
            RETURN VALIDATE_INSURANCE;    

        END IF;
        
        IF PKGSMGBCOMMON.DELIMITEDTEXT(GACCTNAME,'|',3) <> GSOLID THEN
                
            VALIDATE_INSURANCE:= RPAD('F01A/c ID is not related to this SOL. Press F3 to quit.',70);
            RETURN VALIDATE_INSURANCE;
                                
        END IF;  
        
        -- VALIDATING TYPE OF ASSET
        
        IF GASSETTYPE IS NULL THEN
            
            IF GMODE = 'R' THEN
                
                VALIDATE_INSURANCE:= RPAD('F02Asset Type cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSE
                
                VALIDATE_INSURANCE:= RPAD('F03Asset Type cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                
            END IF;
            
        ELSE
               
            SELECT COUNT(1)          
              INTO TEMPCOUNT1
              FROM ASM
             WHERE SECU_CODE = TRIM(GASSETTYPE)
               AND DEL_FLG = 'N';               
               
            IF TEMPCOUNT1 = 0 THEN        
                
                IF GMODE = 'R' THEN
                    
                    VALIDATE_INSURANCE:= RPAD('F02Asset Type is not valid. Press F2 for options.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                ELSE
                    
                    VALIDATE_INSURANCE:= RPAD('F03Asset Type is not valid. Press F2 for options.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                END IF;   
                
            END IF;
            
        END IF;
        
        -- VALIDATING INSURED FROM DATE
        
        IF GINSUREDFROM IS NULL THEN
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F03Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN                
                    
                VALIDATE_INSURANCE:= RPAD('F02Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F04Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;    
            
        ELSIF PKGSMGBCOMMON.ISDATE(GINSUREDFROM) = 'N' THEN
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F03Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN                
                    
                VALIDATE_INSURANCE:= RPAD('F02Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F04Enter a valid Insured From date.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;   
            
        END IF;
        
        -- VALIDATING INSURED TO DATE
        
        IF GINSUREDTILL IS NULL THEN 
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F04Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN 
                
                VALIDATE_INSURANCE:= RPAD('F03Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;                 
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F05Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF; 
            
        ELSIF PKGSMGBCOMMON.ISDATE(GINSUREDTILL) = 'N' THEN 
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F04Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN 
                
                VALIDATE_INSURANCE:= RPAD('F03Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;                 
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F05Enter a valid Insured To date.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF; 
            
        ELSE
            
            IF ((GINSUREDFROM IS NOT NULL) OR (GINSUREDTILL IS NOT NULL)) THEN
                
                IF TO_DATE(GINSUREDFROM,'DD-MM-YYYY') >= TO_DATE(GINSUREDTILL,'DD-MM-YYYY') THEN
                        
                    IF GMODE = 'R' THEN
                            
                        VALIDATE_INSURANCE:= RPAD('F03Insured From date should be less than Insured To Date.',70);
                        RETURN VALIDATE_INSURANCE;
                        
                    ELSIF GMODE = 'U' THEN    
                        
                        VALIDATE_INSURANCE:= RPAD('F02Insured From date should be less than Insured To Date.',70);
                        RETURN VALIDATE_INSURANCE;
                            
                    ELSE
                            
                        VALIDATE_INSURANCE:= RPAD('F04Insured From date should be less than Insured To Date.',70);
                        RETURN VALIDATE_INSURANCE;
                            
                    END IF;
                        
                END IF;
                
            END IF;
            
        END IF;
        
        IF GMODE = 'R' THEN
            
            BEGIN
                
                SELECT TO_DATE(GINSUREDFROM,'DD-MM-YYYY')
                  INTO AINSUREDFROM
                  FROM DUAL;
              
            EXCEPTION WHEN
               OTHERS THEN  
               
               VALIDATE_INSURANCE:= RPAD('F03Incorrect From Date Format. Should be in DD-MM-YYYY format.',70);
               RETURN VALIDATE_INSURANCE;      
              
            END;              
            
            BEGIN
                
                SELECT CASE WHEN INSURED_TO IS NULL THEN SYSDATE ELSE TO_DATE(INSURED_TO,'DD-MM-YYYY') END
                  INTO GRENEWTODATE
                  FROM C_INSURANCE
                 WHERE INSURANCE_ID = GINSURANCEID;
             
            EXCEPTION WHEN
               OTHERS THEN  
               
               VALIDATE_INSURANCE:= RPAD('F01Record not present for this insurance id.',70);
               RETURN VALIDATE_INSURANCE;      
              
            END; 
             
            IF GINSUREDFROM < GRENEWTODATE THEN           
                
                VALIDATE_INSURANCE:= RPAD('F03Renewal start date should not be less than to date of old record.',70);
                RETURN VALIDATE_INSURANCE;                
                
            END IF;
            
        END IF;
        
        -- VALIDATING INSURED AMOUNT
        
        IF GINSUREDAMOUNT IS NULL THEN
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F05Enter the Insured Amount.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN     
                
                VALIDATE_INSURANCE:= RPAD('F04Enter the Insured Amount.',70);
                RETURN VALIDATE_INSURANCE;           
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F06Enter the Insured Amount.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;
            
        ELSE
            
            IF PKGSMGBCOMMON.ISNUMBER(GINSUREDAMOUNT) = 'N' THEN
                
                IF GMODE = 'R' THEN
                        
                    VALIDATE_INSURANCE:= RPAD('F05Enter a valid Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                ELSIF GMODE = 'U' THEN 
                    
                    VALIDATE_INSURANCE:= RPAD('F04Enter a valid Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;                   
                        
                ELSE
                        
                    VALIDATE_INSURANCE:= RPAD('F06Enter a valid Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                        
                END IF;
                
            END IF;        
            
        END IF;
        
        -- VALIDATING PREMIUM AMOUNT
        
        IF GPREMIUM IS NULL THEN
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F06Enter the Premium Amount.',70);
                RETURN VALIDATE_INSURANCE;
                
            ELSIF GMODE = 'U' THEN            
                
                VALIDATE_INSURANCE:= RPAD('F05Enter the Premium Amount.',70);
                RETURN VALIDATE_INSURANCE;    
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F07Enter the Premium Amount.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;
            
        ELSE
            
            IF PKGSMGBCOMMON.ISNUMBER(GPREMIUM) = 'N' THEN
                
                IF GMODE = 'R' THEN
                        
                    VALIDATE_INSURANCE:= RPAD('F06Enter a valid Premium Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                ELSIF GMODE = 'U' THEN
                    
                    VALIDATE_INSURANCE:= RPAD('F05Enter a valid Premium Amount.',70);
                    RETURN VALIDATE_INSURANCE;                    
                        
                ELSE
                        
                    VALIDATE_INSURANCE:= RPAD('F07Enter a valid Premium Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                        
                END IF;
                
            END IF;        
            
            IF TO_NUMBER(GPREMIUM) > TO_NUMBER(GINSUREDAMOUNT) THEN
                
                IF GMODE = 'R' THEN
                        
                    VALIDATE_INSURANCE:= RPAD('F06Premium Amount should not be greater than Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                ELSIF GMODE = 'U' THEN 
                        
                    VALIDATE_INSURANCE:= RPAD('F05Premium Amount should not be greater than Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                    
                ELSE
                        
                    VALIDATE_INSURANCE:= RPAD('F07Premium Amount should not be greater than Insured Amount.',70);
                    RETURN VALIDATE_INSURANCE;
                        
                END IF;
                
            END IF;
            
        END IF;
        
        -- VALIDATING INSURANCE COMPANY NAME
        
        IF GCOMPANY IS NULL THEN    
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F07Insurance Company Name cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F08Insurance Company Name cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;
            
        ELSE
            
            SELECT COUNT(1)
              INTO TEMPCOUNT1
              FROM C_REFCODE
             WHERE MAIN_CODE = 1120
               AND SUB_CODE <> 0
               AND UPPER(CODE_DESCRIPTION) = UPPER(TRIM(GCOMPANY))
               AND DEL_FLAG = 'N';
               
            IF TEMPCOUNT1 = 0 THEN 
                
                IF GMODE = 'R' THEN
                        
                    VALIDATE_INSURANCE:= RPAD('F07Insurance Company Name is not valid.Press F2 for options.',70);
                    RETURN VALIDATE_INSURANCE;
                        
                ELSE
                        
                    VALIDATE_INSURANCE:= RPAD('F08Insurance Company Name is not valid.Press F2 for options.',70);
                    RETURN VALIDATE_INSURANCE;
                        
                END IF;               
                
            END IF;            
            
        END IF;
        
        -- VALIDATING BRANCH NAME
        
        IF GBRANCH IS NULL THEN
            
            IF GMODE = 'R' THEN
                    
                VALIDATE_INSURANCE:= RPAD('F08Insurance Branch Location cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                    
            ELSE
                    
                VALIDATE_INSURANCE:= RPAD('F09Insurance Branch Location cannot be empty.',70);
                RETURN VALIDATE_INSURANCE;
                    
            END IF;
            
        END IF;
        
        -- VALIDATING CLOSURE REASON
        
        IF GMODE = 'C' AND GREASON IS NULL THEN
            
            VALIDATE_INSURANCE:= RPAD('F01Closure Reason cannot be empty.',70);
            RETURN VALIDATE_INSURANCE;
            
        END IF;
        
        GACCTNAME := PKGSMGBCOMMON.DELIMITEDTEXT(GACCTNAME,'|',2);
        
        VALIDATE_INSURANCE:= 'S'||GACCTNAME;
        RETURN VALIDATE_INSURANCE;
        
    END IF;
    
EXCEPTION
 WHEN OTHERS THEN

    RETURN RPAD('F^Unknown Error',100);
   
END VALIDATE_INSURANCE;

END;
/
DROP PUBLIC SYNONYM PKGINSURANCE
/
CREATE PUBLIC SYNONYM PKGINSURANCE FOR PKGINSURANCE
/
GRANT EXECUTE ON PKGINSURANCE TO TBAGEN, TBAUTIL,TBACUST
/
GRANT EXECUTE ON PKGINSURANCE TO PUBLIC
/


