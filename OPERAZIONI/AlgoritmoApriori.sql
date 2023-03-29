DROP PROCEDURE IF EXISTS Apriori;

DELIMITER $$

CREATE PROCEDURE Apriori()
BEGIN
	CALL creazioneItemTarget;
END $$

DELIMITER ;

SET GLOBAL group_concat_max_len = 50000;
SET SESSION group_concat_max_len = 20000;

-- -----------------------------------
-- Creazione procedure target
-- -----------------------------------


-- -----------------------------------
-- Procedura Principale
-- -----------------------------------
DROP PROCEDURE IF EXISTS creazioneItemTarget;

DELIMITER $$

CREATE PROCEDURE creazioneItemTarget()
BEGIN
	
    DECLARE Contatore INT DEFAULT 0;
    
    CALL creazioneTabelle();
    
    SELECT (1/100)*COUNT(*) INTO @valoreSoglia						-- si inserisce il valore di soglia per il pruning
    FROM TransazioniTarget;
    
    SELECT @valoreSoglia;
    
	TRUNCATE C;
    TRUNCATE L;
    
    INSERT INTO C
	SELECT MB.MascheraBit, MB.Dispositivo, 0, 0
	FROM MascheraBit MB;
    
    CALL PotaturaC();												-- si chiama la procedura che ha il compito di sfoltire le tuple non considerate ricorrenti
    
    TRUNCATE C;
		
	INSERT INTO C
	SELECT L1.mascheraBitDispositivoPrima AS mascheraBitDispositivoPrima, L1.DispositivoPrima AS DispositivoPrima, L2.mascheraBitDispositivoPrima AS mascheraBitDispositivoDopo, L2.DispositivoPrima AS DispositivoDopo
	FROM L L1
		INNER JOIN
		L L2 ON (L2.DispositivoPrima > L1.DispositivoPrima);
        
	CALL PotaturaC();
    
    SELECT COUNT(*) INTO Contatore
	FROM L;
    
																	-- processo di JOIN e Pruning
    WHILE Contatore > 1 DO
			
		TRUNCATE C;
		
		INSERT INTO C
		SELECT L1.mascheraBitDispositivoPrima | L1.mascheraBitDispositivoDopo, CONCAT(L1.DispositivoPrima, ',', L1.DispositivoDopo) AS DispositivoPrima, L2.mascheraBitDispositivoDopo AS mascheraBitDispositivoDopo, L2.DispositivoDopo AS DispositivoDopo
		FROM L L1
			INNER JOIN
			L L2 ON (L1.DispositivoPrima = L2.DispositivoPrima
					AND L2.DispositivoDopo > L1.DispositivoDopo);
		
		CALL PotaturaC();
		
		SELECT COUNT(*) INTO Contatore
		FROM L;
			
	END WHILE;
	    
    SELECT ROW_NUMBER() OVER() AS Conteggio, BIT_COUNT(C1.mascheraBitDispositivoPrima | C1.mascheraBitDispositivoDopo) AS SupportoTotale, CONCAT(C1.DispositivoPrima, ',', C1.DispositivoDopo) AS Ris
	FROM C C1;
    
    CALL RegoleAssociazione;
END $$

DELIMITER ;

-- ----------------------------------------------------
-- Creazione delle tabelle fondamentali per l'algoritmo
-- ----------------------------------------------------

DROP PROCEDURE IF EXISTS creazioneTabelle;

DELIMITER $$

CREATE PROCEDURE creazioneTabelle()
BEGIN
	DROP TABLE IF EXISTS C;
    
    CREATE TABLE C(
		mascheraBitDispositivoPrima BIGINT NOT NULL,
        DispositivoPrima VARCHAR(255) NOT NULL,
        mascheraBitDispositivoDopo BIGINT NOT NULL,
        DispositivoDopo VARCHAR(255) NOT NULL
    );
    
    DROP TABLE IF EXISTS RegoleAssociazioni;
    
    CREATE TABLE RegoleAssociazioni(
		Dispositivo VARCHAR(255) PRIMARY KEY,
        Conteggio INT NOT NULL,
        ORBITBIT INT NOT NULL
    );
    
    DROP TABLE IF EXISTS combinazioni;
    
    CREATE TABLE combinazioni(
		Conteggio INT NOT NULL,
        Dispositivo VARCHAR(255) NOT NULL,
        mascheraBit INT DEFAULT 0,
        PRIMARY KEY(Conteggio, mascheraBit)
    );
    
    DROP TABLE IF EXISTS combinazioniMascheraBit;
    
    CREATE TABLE combinazioniMascheraBit(
		ConteggioDispositivi INT NOT NULL,
        DispositivoPrima VARCHAR(255) NOT NULL,
        mascheraBitDispositivoPrima INT NOT NULL,
        DispositivoDopo VARCHAR(255) NOT NULL,
        mascheraBitDispositivoDopo INT NOT NULL,
        PRIMARY KEY(ConteggioDispositivi, DispositivoPrima, DispositivoDopo)
    );
    
    DROP TABLE IF EXISTS combinazioniAppoggioMascheraBit;
    
    CREATE TABLE combinazioniAppoggioMascheraBit LIKE combinazioniMascheraBit;
    
    DROP TABLE IF EXISTS L;
    
    CREATE TABLE L LIKE C;
    
    CALL creazioneTransazioni();

    CALL creazioneMaschereBit();
    
END $$

DELIMITER ;

-- ----------------------------
-- Creazione tabella Pivot
-- ----------------------------

DROP PROCEDURE IF EXISTS creazioneTransazioni;

DELIMITER $$

CREATE PROCEDURE creazioneTransazioni()
BEGIN
	WITH DispositiviTarget AS
    (
		SELECT DISTINCT(LD.IDDispositivo)
		FROM LOGDISPOSITIVO LD
			NATURAL JOIN
            DISPOSITIVO D
        WHERE D.NTipoDispositivo = 1 OR D.NTipoDispositivo = 2 OR D.NTipoDispositivo = 3
    )
    
    SELECT GROUP_CONCAT(
				CONCAT(
					' COUNT(IF(IDDispositivo = ''', DT.IDDispositivo, 
                    ''', 1, NULL)) AS ''', DT.IDDispositivo, ''''
                )
            )
    FROM DispositiviTarget DT
    INTO @pivot_query;
    
    DROP TEMPORARY TABLE IF EXISTS LOGTarget;
    
    CREATE TEMPORARY TABLE LOGTarget
	SELECT  DISTINCT MONTH(LD.TimestampInizio) AS Mese, DAY(LD.TimestampInizio) AS Giorno, HOUR(LD.TimestampInizio) AS Ora, LD.IDDispositivo 
	FROM LOGDISPOSITIVO LD
		NATURAL JOIN
		DISPOSITIVO D
	WHERE D.NTipoDispositivo = 1 OR D.NTipoDispositivo = 2 OR D.NTipoDispositivo = 3;
    
    DROP TABLE IF EXISTS TransazioniTarget;
    
    SET @pivot_query = CONCAT(
							' CREATE TABLE TransazioniTarget SELECT Mese, Giorno, Ora, ',
                            @pivot_query,
                            ' FROM LOGTarget GROUP BY Mese, Giorno, Ora;'
                        );
                            
    SELECT @pivot_query;
    
	PREPARE sql_statement FROM @pivot_query;
    EXECUTE sql_statement;
    
    -- con questa query andiamo a concatenare tutte le colonne di tutte le tuple della tabella PIVOT
    -- la particolarità è che non dobbiamo andare a specificare colonna per colonna(cosa impossibile visto che non sappiamo a priori quali dispositivi saranno coinvolti)
    SELECT	CONCAT(
				' SELECT CONCAT(mese, ''-'', giorno, ''-'', ora), CONV(CONCAT_WS('''', ',
														GROUP_CONCAT(
															CONCAT('`', column_name, '`')
														),
							'), 2, 10) AS IDIdentificativo FROM TransazioniTarget;'
			)
	FROM   `information_schema`.`columns` 
	WHERE  `table_schema`=DATABASE() 
		    AND `table_name`='TransazioniTarget'
		    AND `column_name` <> 'mese'
			AND `column_name` <> 'giorno'
			AND`column_name` <> 'ora'
	INTO @sql;

	-- SELECT @sql;

	DROP TABLE IF EXISTS temporaryTable;

	SET @sql = CONCAT(
					'CREATE TABLE temporaryTable '
					, @sql
				);
				
	SELECT @sql;
	PREPARE stm FROM @sql;
    
    EXECUTE stm;

END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS creazioneMaschereBit;

DELIMITER $$
-- ----------------------------------------------------
-- Creazioni mascherebit(multipli di due) per ogni item
-- ----------------------------------------------------
CREATE PROCEDURE creazioneMaschereBit()
BEGIN
	DECLARE multipliDue BIGINT DEFAULT 1;
    DECLARE finito INT DEFAULT 0;
    DECLARE dispositivoVar VARCHAR(255) DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    SELECT PTRN.Dispositivo
	FROM(
		SELECT ROW_NUMBER() OVER() AS NumeroRiga, PT.Dispositivo
		FROM(
			SELECT DISTINCT(IDDispositivo) AS Dispositivo
			FROM LOGDISPOSITIVO LD
				NATURAL JOIN
				DISPOSITIVO D
			WHERE D.NTipoDispositivo = 1 OR D.NTipoDispositivo = 2 OR D.NTipoDispositivo = 3
		) AS PT
    ) AS PTRN
    ORDER BY PTRN.NumeroRiga DESC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;
    
    DROP TABLE IF EXISTS MascheraBit;
    
    CREATE TABLE MascheraBit(
		Dispositivo VARCHAR(255) NOT NULL,
        MascheraBit BIGINT PRIMARY KEY NOT NULL
    );
    
    OPEN cursore;
    -- processo di LOOP per inserire la maschera di bit(multipli di 2)
    scan : LOOP
		FETCH cursore INTO dispositivoVar;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        
        INSERT INTO MascheraBit VALUES(dispositivoVar, multipliDue);
        
        SET multipliDue = multipliDue*2;
    END LOOP scan;
    
    CLOSE cursore;
END $$

DELIMITER ;

-- -------------------------------------------------------------------------------------
-- creazione della procedura di Pruning, svoltisce gli items non considerati ricorrenti
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS PotaturaC;

DELIMITER $$

CREATE PROCEDURE PotaturaC()
BEGIN
	TRUNCATE L;
	
    DROP TEMPORARY TABLE IF EXISTS TabellaPotaturaC;
    
    -- controlliamo se il conteggio delle volte in cui uno o più dispositivi capitano contemporaneamente nelle varie transazioni
    CREATE TEMPORARY TABLE TabellaPotaturaC
	SELECT *
	FROM(
		SELECT D.mascheraBitDispositivoPrima, D.DispositivoPrima, D.mascheraBitDispositivoDopo, D.DispositivoDopo, COUNT(*) AS Conteggio, ORBITBIT
		FROM(
			SELECT *, ((mascheraBitDispositivoPrima | mascheraBitDispositivoDopo) & IDIdentificativo) AS ANDBITBIT, (mascheraBitDispositivoPrima | mascheraBitDispositivoDopo) AS ORBITBIT
			FROM C
				CROSS JOIN
				temporaryTable
		) AS D
		WHERE D.ANDBITBIT <> 0
			AND D.ANDBITBIT = D.ORBITBIT
		GROUP BY D.mascheraBitDispositivoPrima, D.DispositivoPrima, D.mascheraBitDispositivoDopo, D.DispositivoDopo
	) AS RIS
	WHERE RIS.Conteggio >= @valoreSoglia;
    
    -- SELECT * FROM TabellaPotaturaC;
    
	INSERT INTO RegoleAssociazioni
    SELECT IF(RIS.DispositivoDopo = '0', RIS.DispositivoPrima, CONCAT(RIS.DispositivoPrima, ',', RIS.DispositivoDopo)) AS Dispositivo, Conteggio, ORBITBIT
	FROM TabellaPotaturaC RIS;
    
    INSERT INTO L
	SELECT RIS.mascheraBitDispositivoPrima, RIS.DispositivoPrima, RIS.mascheraBitDispositivoDopo, RIS.DispositivoDopo
	FROM TabellaPotaturaC RIS;
    
END $$

DELIMITER ;

-- ---------------------------------------
-- Creazione delle regole di Associazione 
-- ---------------------------------------

DROP PROCEDURE IF EXISTS RegoleAssociazione;

DELIMITER $$

CREATE PROCEDURE RegoleAssociazione()
BEGIN
/*
DROP TABLE IF EXISTS supportoTotale;
    
    CREATE TABLE supportoTotale
    */
    DECLARE contatore INT DEFAULT 0;
    
    DECLARE mediaConfidenza DOUBLE DEFAULT 0;
    
	CALL string_split;
    
    CALL settaggioSupportoTotale;
    
    CALL settaggio_variabile_controllo;
    
	
    TRUNCATE combinazioni;
    
    INSERT INTO combinazioni
    SELECT ConteggioDispositivi, DispositivoPrima, mascheraBitDispositivoPrima 
    FROM combinazioniMascheraBit;
    
    SELECT COUNT(*) INTO contatore
    FROM combinazioni;
    
    -- processo per inserire e generare l'implicante "IDProdotto =>"
    IF @varControllo <> contatore THEN
		TRUNCATE combinazioniAppoggioMascheraBit;
		
		INSERT INTO combinazioniAppoggioMascheraBit
		SELECT CMB1.ConteggioDispositivi, CMB1.DispositivoPrima, CMB1.mascheraBitDispositivoPrima, CMB2.DispositivoPrima, CMB2.mascheraBitDispositivoPrima
		FROM combinazioniMascheraBit CMB1
			INNER JOIN
			combinazioniMascheraBit CMB2 ON (CMB2.DispositivoPrima > CMB1.DispositivoPrima
											AND CMB2.ConteggioDispositivi = CMB1.ConteggioDispositivi);
											
		INSERT INTO combinazioni
		SELECT ConteggioDispositivi, CONCAT(DispositivoPrima, ',', DispositivoDopo), mascheraBitDispositivoPrima | mascheraBitDispositivoDopo
		FROM combinazioniAppoggioMascheraBit;
		
		SELECT COUNT(*) INTO contatore
		FROM combinazioni;
		
		TRUNCATE combinazioniMascheraBit;
		
		INSERT INTO combinazioniMascheraBit
		SELECT *
		FROM combinazioniAppoggioMascheraBit;
		
		WHILE contatore <> @varControllo DO
			
			TRUNCATE combinazioniAppoggioMascheraBit;
			INSERT INTO combinazioniAppoggioMascheraBit
			SELECT CMB1.ConteggioDispositivi, CONCAT(CMB1.DispositivoPrima, ',', CMB1.DispositivoDopo), (CMB1.mascheraBitDispositivoPrima | CMB1.mascheraBitDispositivoDopo), CMB2.DispositivoDopo, CMB2.mascheraBitDispositivoDopo
			FROM combinazioniMascheraBit CMB1
				INNER JOIN
				combinazioniMascheraBit CMB2 ON (CMB2.DispositivoPrima = CMB1.DispositivoPrima
												AND CMB2.ConteggioDispositivi = CMB1.ConteggioDispositivi
												AND CMB2.DispositivoDopo > CMB1.DispositivoDopo);
												
			INSERT INTO combinazioni
			SELECT ConteggioDispositivi, CONCAT(DispositivoPrima, ',', DispositivoDopo), mascheraBitDispositivoPrima | mascheraBitDispositivoDopo
			FROM combinazioniAppoggioMascheraBit;
			
			TRUNCATE combinazioniMascheraBit;
			INSERT INTO combinazioniMascheraBit
			SELECT * 
			FROM combinazioniAppoggioMascheraBit;
			
			SELECT COUNT(*) INTO contatore
			FROM combinazioni;
			
		END WHILE;
    END IF;
    
    DROP TABLE IF EXISTS RegoleFinali;

	CREATE TABLE RegoleFinali
    WITH MascheraBitTotaleItem AS
    (
		SELECT C.Conteggio, BIT_OR(C.MascheraBit) AS mascheraBitTotale
		FROM combinazioni C
        GROUP BY C.Conteggio
    )
    -- processo per generare l'implicato =>IDProdotto
	SELECT C.Conteggio, C.Dispositivo, C.mascheraBit, MBTI.mascheraBitTotale ^ mascheraBit AS XORBITBIT, RA.Conteggio AS totaleOccorrenze
	FROM RegoleAssociazioni RA
		INNER JOIN 
		combinazioni C ON RA.Dispositivo = C.Dispositivo
        INNER JOIN
        MascheraBitTotaleItem MBTI ON C.Conteggio = MBTI.Conteggio;

	DROP TABLE IF EXISTS RisultatoAPriori;
    
    CREATE TABLE RisultatoAPriori
    WITH regole AS
    (
		SELECT D.*, (D.SupportoMassimo/D.totaleOccorrenze)*100 AS Confidenza
		FROM(
			SELECT RF1.Conteggio, CONCAT(RF1.Dispositivo, '  =>  ', RF2.Dispositivo) As RegoleAssociazione, RF1.totaleOccorrenze, ST.SupportoMassimo
			FROM RegoleFinali RF1
				INNER JOIN
				RegoleFinali RF2 ON (RF1.XORBITBIT = RF2.mascheraBit
									AND RF1.Conteggio = RF2.Conteggio)
				INNER JOIN
				SupportoMassimo ST ON RF1.Conteggio = ST.ConteggioDispositivi
			) AS D
    )
    
    SELECT Conteggio, RegoleAssociazione, Confidenza
    FROM regole
    WHERE Confidenza >= (SELECT CEILING(AVG(Confidenza))
						FROM regole);
    
    
	SELECT *
    FROM RisultatoAPriori;
                            
	-- CALL dropTAbles;
END $$

DELIMITER ;

-- ---------------------------------------------------------
-- setta il supporto totale degli items frequenti trovati
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS settaggioSupportoTotale;

DELIMITER $$

CREATE PROCEDURE settaggioSupportoTotale()
BEGIN
	DROP TABLE IF EXISTS SupportoMassimo;
    
    CREATE TABLE SupportoMassimo
	WITH ORMASCHERE AS
    (
		SELECT CMB.ConteggioDispositivi, BIT_OR(CMB.mascheraBitDispositivoPrima) AS ORMASCHERE
		FROM combinazioniMascheraBit CMB
		GROUP BY CMB.ConteggioDispositivi
	),
    ORMaschereANDMaschere AS
    (
		SELECT ORM.ConteggioDispositivi, ORM.ORMASCHERE, ORM.ORMASCHERE & TT.IDIdentificativo AS ANDMASCHERE
		FROM ORMASCHERE ORM
			CROSS JOIN
			temporaryTable TT
    )
    
    SELECT OAM.ConteggioDispositivi, COUNT(*) AS SupportoMassimo
    FROM ORMaschereANDMaschere OAM
    WHERE OAM.ANDMASCHERE <> 0
		AND OAM.ANDMASCHERE = OAM.ORMASCHERE
	-- ORDER BY ConteggioDispositivi
    GROUP BY OAM.ConteggioDispositivi
    ORDER BY ConteggioDispositivi;
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS settaggio_variabile_controllo;

DELIMITER $$

CREATE PROCEDURE settaggio_variabile_controllo()
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE esponente INT DEFAULT 0;
    DECLARE numeroTuple INT DEFAULT 0;
    
	DECLARE Cursore CURSOR FOR
	SELECT COUNT(*)
    FROM combinazioniMascheraBit
    GROUP BY ConteggioDispositivi;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;
    
    SET @varControllo = 0;
    OPEN Cursore;
    
    scan : LOOP
    FETCH Cursore INTO numeroTuple;
    IF finito = 1 THEN
		LEAVE scan;
	END IF;
    
    SET @varControllo = @varControllo + (POW(2, numeroTuple) -2);
    END LOOP scan;
    
    CLOSE Cursore;
    
    SELECT @varControllo;
END $$

DELIMITER ;
-- ------------------------------------------------------------------------
-- procedura per splittare la stringa in più sottostringhe: separatore ","
-- ------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS string_split;

DELIMITER $$

CREATE PROCEDURE string_split()
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE numero INT DEFAULT 0;
    DECLARE stringa VARCHAR(255) DEFAULT NULL;
    DECLARE valore VARCHAR(255) DEFAULT '';
    DECLARE carattere CHAR DEFAULT '';
    DECLARE contatore INT DEFAULT 0;
    DECLARE lunghezzaStringa INT DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
	SELECT ROW_NUMBER() OVER() AS numero, CONCAT(DispositivoPrima, ',', DispositivoDopo) AS stringa
	FROM C;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;
    
    TRUNCATE combinazioniMascheraBit;
    
    OPEN cursore;
    
    scan : LOOP
		FETCH cursore INTO numero, stringa;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        
        SET lunghezzaStringa = CHAR_LENGTH(stringa);
        
        SET contatore = 0;
        
        WHILE lunghezzaStringa <> contatore DO
			SET contatore = contatore + 1;
			
			SELECT SUBSTR(stringa, contatore, 1) INTO carattere;
			-- SELECT carattere;
			IF carattere <> ',' THEN
				SET valore = CONCAT(valore, carattere);
			ELSE
				INSERT INTO combinazioniMascheraBit VALUES(numero, valore, 0, 0, 0);
                SET valore = '';
			END IF;
		END WHILE;
        INSERT INTO combinazioniMascheraBit VALUES(numero, valore, 0, 0, 0);
		SET valore = '';
    END LOOP;
    
    CLOSE cursore;
    
    REPLACE combinazioniMascheraBit
    SELECT c.ConteggioDispositivi, c.DispositivoPrima, MB.MascheraBit, 0, 0
    FROM combinazioniMascheraBit c
		INNER JOIN
        MascheraBit MB ON c.DispositivoPrima = MB.Dispositivo
        INNER JOIN
        RegoleAssociazioni RA ON c.DispositivoPrima = RA.Dispositivo;
	
    
    
	-- CALL settaggioVariabiliXOR;
END $$

DELIMITER ;

-- -----------------------------------------------------------
-- elimina tutte le tabelle che sono servite per l'algoritmo
-- -----------------------------------------------------------

DROP PROCEDURE IF EXISTS dropTAbles;

DELIMITER $$

CREATE PROCEDURE dropTAbles()
BEGIN
	DROP TABLE IF EXISTS combinazioni;
    
    DROP TABLE IF EXISTS combinazioniAppoggioMascheraBit;
    
    DROP TABLE IF EXISTS combinazioniMascheraBit;
    
    DROP TABLE IF EXISTS C;
    
    DROP TABLE IF EXISTS L;
    
    DROP TABLE IF EXISTS MascheraBit;
    
    DROP TABLE IF EXISTS pivottransazionedispositivi;
    
    DROP TABLE IF EXISTS TransazioniTarget;
    
    DROP TABLE IF EXISTS temporaryTable;
END $$

DELIMITER ;
