DROP PROCEDURE IF EXISTS CreaSuggerimento;

DELIMITER $$

CREATE PROCEDURE CreaSuggerimento()
BEGIN

	DECLARE GiornoSettimana INT DEFAULT 0;
    DECLARE finito INT DEFAULT 0;
    
    DECLARE IDDispositivo INT DEFAULT 0;
    DECLARE IDLivello INT DEFAULT 0;
    DECLARE Durata TIME DEFAULT 0;
	DECLARE MediaConsumoKW DOUBLE DEFAULT 0;
    DECLARE ConsumoKW DOUBLE DEFAULT 0;
    
    DECLARE KWProdotti DOUBLE DEFAULT 0;
    DECLARE KWConsumati DOUBLE DEFAULT 0;
    
    
    DECLARE PrimaData TIMESTAMP DEFAULT NULL;
	DECLARE verifica TIME DEFAULT NULL;
    
    DECLARE KWRimanenti DOUBLE DEFAULT 0.0;
    
    DECLARE CurDisp CURSOR FOR
    /*
		Dalla queri sottostante  prenderemo tutti i dispositivo a ciclo non interrompibile con i vari
        livelli
    */
    SELECT PLCE.*, LCE.Durata, L.MediaConsumoKW, D.ConsumoKW
	FROM DISPOSITIVO D
		INNER JOIN
		DISPOSITIVOACICLONONINTERROMPIBILE DACNI ON D.IDDispositivo = DACNI.IDDispositivo
		INNER JOIN
		POSSIEDELCE PLCE ON DACNI.IDDIspositivo = PLCE.IDDispositivo
		INNER JOIN
		LIVELLOCONSUMOENERGETICO LCE ON PLCE.IDLivello = LCE.IDLivello
		INNER JOIN
		LIVELLO L ON LCE.IDLivello = L.IDLivello;
    
    DECLARE CONTINUE HANDLER 
    FOR NOT FOUND SET finito = 1;
    
    -- andiamo a far corrispondere un determinato numero al giorno odierno Domenica = 1 ... Sabato = 7
    SELECT IF(DAYOFWEEK(CURRENT_DATE) = 1, 6, DAYOFWEEK(CURRENT_DATE) - 2) INTO GiornoSettimana;
    
    DROP TABLE IF EXISTS TabellaProduzioneConsumo;

    CREATE TABLE TabellaProduzioneConsumo(
		Inizio TIMESTAMP NOT NULL,
        Fine TIMESTAMP NOT NULL,
        KWProdotti DOUBLE NOT NULL,
        KWConsumati DOUBLE NOT NULL,
        PRIMARY KEY(Inizio, Fine)
    );
    
    INSERT INTO TabellaProduzioneConsumo(Inizio, Fine, KWProdotti, KWConsumati)
    -- andiamo a fare una stima di quanto si consuma/produce in avanti nel tempo quanto durano i vari livelli
    -- a partire anche dai giorni successivi del giorno corrente della settimana
	WITH STORICOPRODUZIONECONSUMOENERGIASETTIMANA AS
	(
		SELECT *
		FROM STORICOPRODUZIONEENERGIA SPE
			INNER JOIN
			CONSUMODISPOSITIVO CD ON(SPE.InizioTimeStamp = CD.InizioAccensione
									AND SPE.FineTimeStamp = CD.FineAccensione)
		WHERE MONTH(SPE.InizioTimeStamp) = MONTH(CURRENT_TIMESTAMP)
			AND DAY(SPE.InizioTimeStamp) BETWEEN (DAY(CURRENT_TIMESTAMP - INTERVAL 7 DAY) - GiornoSettimana) AND (DAY(CURRENT_TIMESTAMP - INTERVAL 7 DAY) + (7 - GiornoSettimana))
			-- AND TIME(SPE.InizioTimeStamp) >= CURRENT_TIME
	),
	STORICOPRODUZIONECONSUMOENERGIARANKING AS
	(
		-- creo un ordine cronologico nel tempo
		SELECT SPES.*, DENSE_RANK() OVER w AS Ranking
		FROM STORICOPRODUZIONECONSUMOENERGIASETTIMANA SPES
		WINDOW w AS
		(
			ORDER BY DAY(SPES.InizioTimeStamp)
		)
	)
	-- prendo il timestamp più vicino al current_timestamp
	SELECT SPER.InizioTimestamp AS Inizio, SPER.FineTimeStamp AS Fine, SPER.KWProdotti, SPER.KWConsumati
	FROM STORICOPRODUZIONECONSUMOENERGIARANKING SPER
	WHERE SPER.Ranking >= ALL (
								SELECT SPER0.Ranking
								FROM STORICOPRODUZIONECONSUMOENERGIARANKING SPER0
								);
                        
	SELECT MIN(Inizio) INTO PrimaData
	FROM TabellaProduzioneConsumo;
    
    SELECT sec_to_time(sum(time_to_sec(TIMEDIFF(Fine, Inizio)))) INTO verifica
    FROM TabellaProduzioneConsumo;
                                
	OPEN CurDisp;
    
    scan : LOOP
    -- per ogni dispositivo con un determinato livello e durata
		FETCH CurDisp INTO IDDispositivo, IDLivello, Durata, MediaConsumoKW, ConsumoKW;
        IF(finito = 1) THEN
			LEAVE scan;
		END IF;
        
        IF(Durata < verifica) THEN
        -- stimo quanti KW mi rimangono da produzione - consumo, media produzione/consumo dalla prima data in avanti nel tempo quanto dura un livello
			SELECT AVG(TPC.KWProdotti), AVG(TPC.KWConsumati) INTO KWProdotti, KWConsumati
			FROM TabellaProduzioneConsumo TPC
			WHERE TPC.Inizio < (((PrimaData + INTERVAL (Durata) HOUR) + INTERVAL (Durata) MINUTE) + INTERVAL (Durata) SECOND);
            
            -- calcolo i KW rimanenti
            SET KWRimanenti = KWProdotti - KWConsumati;
            
            -- solo in caso in cui il consumo sia minore di produzione
            IF(KWRimanenti > 0) THEN
				IF(MediaConsumoKW = 0) THEN
					-- se la media di quanti KW consumano i vari livelli non è neancora stata calcolata
                    -- verrà preso il consumo del dispositivo
					SET MediaConsumoKW = ConsumoKW;
				END IF;
				IF(KWRimanenti >= MediaConsumoKW) THEN
					-- inserisco all'interno di suggerimento
					INSERT INTO SUGGERIMENTO(IDDIspositivo, IDLivello, DurataAccensioneDispositivo)
					VALUES (IDDispositivo, IDLivello, Durata);
				END IF;
			END IF;
        END IF;
	END LOOP scan;
    
    SELECT *
    FROM SUGGERIMENTO S
    WHERE S.TimeStampSuggerimento = CURRENT_TIMESTAMP;
END $$

DELIMITER ;