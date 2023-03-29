SET GLOBAL log_bin_trust_function_creators = 1;


-- OP1: Inserimento Interazione nel LOG 

/*
	I modi per eseguire questa operazione in SQL sono molteplici, l'idea più plausibile e migliore è quella di chiamare diverse procedure
	in diverse situazioni. Non ha senso fare tutto in SQL, è molto più sensato eseguire un flusso di codice in PHP(per esempio):
		-	Query per capire di che tipo di dispositivo si tratta
		-	Varie procedure per gestire i vari casi
*/
DROP PROCEDURE IF EXISTS TipoDispositivo;
DELIMITER $$

CREATE PROCEDURE TipoDispositivo(IN _IDDispositivo INT)
BEGIN
	SELECT TD.NTipoDispositivo
	FROM DISPOSITIVO D
		NATURAL JOIN
		TIPODISPOSITIVO TD
	WHERE D.IDDispositivo = _IDDispositivo;
END $$

DELIMITER ;

-- In caso in cui si tratta di un dispositivo a consumo fisso

DROP PROCEDURE IF EXISTS LOGDispositivoConsumoFisso;
DELIMITER $$

CREATE PROCEDURE LOGDispositivoConsumoFisso(IN _IDDispositivo INT, IN _IDAccount INT)
BEGIN
	INSERT INTO LOGDISPOSITIVO (TimestampInizio, IDDispositivo, IDAccount, Timestampfine) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDAccount, NULL);
END $$

DELIMITER ;

-- In caso in cui si trattasse di un dispositivo varibile con livelli

DROP PROCEDURE IF EXISTS LOGDispositivoConsumoVariabile;
DELIMITER $$

CREATE PROCEDURE LOGDispositivoConsumoVariabile(IN _IDDispositivo INT, IN _IDAccount INT, IN _IDLivello INT)
BEGIN
	INSERT INTO LOGDISPOSITIVO (TimestampInizio, IDDispositivo, IDAccount, Timestampfine) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDAccount, NULL);
		
	INSERT INTO LOGLivello(TimestampInizio, IDDispositivo, IDLivello) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDLivello);
END $$

DELIMITER ;

-- In caso in cui si trattasse di un condizionatore

DROP PROCEDURE IF EXISTS LOGDispositivoCondizionatore;
DELIMITER $$

CREATE PROCEDURE LOGDispositivoCondizionatore(IN _IDDispositivo INT, IN _IDAccount INT, IN _IDLivello INT, IN _Temperatura INT)
BEGIN
	INSERT INTO LOGDISPOSITIVO (TimestampInizio, IDDispositivo, IDAccount, Timestampfine) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDAccount, NULL);
		
	INSERT INTO LOGLivello(TimestampInizio, IDDispositivo, IDLivello) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDLivello);
		
	INSERT INTO LOGTempCondizionatore(TimestampInizio, IDDispositivo, Temperatura) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _Temperatura);
END $$

DELIMITER ;

-- In caso in cui si trattasse di una Smart Light

DROP PROCEDURE IF EXISTS LOGDispositivoSmartLight;
DELIMITER $$

CREATE PROCEDURE LOGDispositivoSmartLight(IN _IDDispositivo INT, IN _IDAccount INT, IN KTemp INT, IN PercInt INT)
BEGIN
	INSERT INTO LOGDISPOSITIVO (TimestampInizio, IDDispositivo, IDAccount, Timestampfine) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, _IDAccount, NULL);
		
	INSERT INTO LOGTEMPMPINTARTLIGHT(TimestampInizio, IDDispositivo, KTemp, PercInt) VALUES
		(CURRENT_TIMESTAMP, _IDDispositivo, KTemp, PercInt);
END $$

DELIMITER ;

-- OP2: Kw Presenti in batteria senza ridondanza

SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS KWInBatteria;

DELIMITER $$

CREATE FUNCTION KWInBatteria()											-- Creazione di una function
RETURNS DOUBLE NOT DETERMINISTIC
BEGIN

	DECLARE TotaleKWImmessi DOUBLE DEFAULT 0;							-- dichiarazione di variabili
	DECLARE TotaleKWConsumati DOUBLE DEFAULT 0;
	
	SELECT SUM(IB.KWImmessi) INTO TotaleKWImmessi						-- somma di tutte le varie immissioni nel tempo
	FROM IMMISSIONEBATTERIA IB;

	SELECT SUM(CB.KWConsumati) INTO TotaleKWConsumati					-- somma di tutti i vari consumi nel tempo
	FROM CONSUMOBATTERIA CB;
																		
	RETURN TotaleKWImmessi - TotaleKWConsumati;							-- immissioni meno consumi da il risultato
    /*
		ATTENZIONE: il risultato può essere negativo ? NO poichè il consumo si basa sui KW presenti nella batteria e quindi sulle varie immissioni
					Prima di un consumo ci sarà obbligatoriamente un'immissionee al massimo il consumo sarà <= ai kw presenti in batteria.
    */
END $$

DELIMITER ;

-- OP2: Kw Presenti in batteria con ridondanza

DROP FUNCTION IF EXISTS KWInBatteriaSR;

DELIMITER $$

CREATE FUNCTION KWInBatteriaSR()
RETURNS DOUBLE NOT DETERMINISTIC
BEGIN

	DECLARE TotaleKWBatteria DOUBLE DEFAULT 0;
    
	SELECT B.KWAttuali INTO TotaleKWBatteria
	FROM BATTERIA B;
    
    RETURN TotaleKWBatteria;
END $$

DELIMITER ;

-- Ovviamente dovremo aggiornare la ridondanza

-- In caso in cui si attivi l'operazione "Flusso energetico", il trigger è superfluo
DROP TRIGGER IF EXISTS AggiornaKWBatteria;

DELIMITER $$

CREATE TRIGGER AggiornaKWBatteria
AFTER INSERT ON IMMISSIONEBATTERIA
FOR EACH ROW
BEGIN
	UPDATE BATTERIA
    SET KWAttuali = KWAttuali + NEW.KWImmessi
    WHERE CodiceBatteria = NEW.CodiceBatteria;
END $$

DELIMITER ;

/*
	Ovviamente il calcolo di quanti KW immettere in batteria verrà fatto precedentemente, Operazione "flusso energetico", 
	è un'operazione però, ai fini del nostro obiettivo, non è interessate
*/

-- OP3: Monitoraggio SmartLight senza ridondanza

DROP PROCEDURE IF EXISTS  MonitoraggioLuce;

DELIMITER $$

CREATE PROCEDURE MonitoraggioLuce()
BEGIN
																	 
	WITH AccensioneSpegnimento AS									-- CTE, permette di affiancare ad ogni accensione lo spegnimento successivo
	(
		SELECT A.IDDispositivo, A.DataAccensione, A.OraAccensione, A.OraSpegnimento, IF(LEAD(A.OraAccensione, 1) OVER W IS NULL, '24:00:00', LEAD(A.OraAccensione, 1) OVER W) AS AccensioneSuccessiva
		FROM ACCENSIONE A
		WINDOW W AS
		(
			PARTITION BY A.IDDispositivo, A.DataAccensione
		)
	),
	PrimaAccensione AS												-- CTE, viene riportata la prima accensione per ogni giorno e per ogni dispositivo Smart Light affiancandoci la mezzanotte
																	-- Sostanzialmente serve per calcolare il lasso ti tempo dalle 00:00 alla prima accensione per ogni giorno e dispositivo
	(
		SELECT A.IDDispositivo, A.DataAccensione, NULL, '00:00:00', MIN(A.OraAccensione) AS PrimaAccensione
		FROM ACCENSIONE A
		GROUP BY A.IDDispositivo, A.DataAccensione
	),
	UnioneAccensionePrimaAccensione AS								-- Vengono unite le CTE precedenti, si prende la prima accensione e le varie accensioni. In modo tale da affiancare il lasso di tempo
																	-- dalle 00:00 alle altre accensioni e spegnimenti
	(
		SELECT *
		FROM AccensioneSpegnimento 
			UNION 
		SELECT *
		FROM PrimaAccensione
	),
	TempoSpegnimentoAccensione AS									-- Si calcola quanti minuti sono stati accese le varie luci e quindi anche spente
	(
		SELECT UAPA.IDDispositivo, UAPA.DataAccensione, IF(UAPA.OraAccensione IS NULL, NULL, TIMEDIFF(UAPA.OraSpegnimento, UAPA.OraAccensione)) AS TempoAccensione, TIMEDIFF(UAPA.AccensioneSuccessiva, UAPA.OraSpegnimento) AS TempoSpegnimento
		FROM UnioneAccensionePrimaAccensione UAPA
	),
    RIS AS															-- i minuti che le luci rimangono accese vengono formattati in ore-minuti-secondi
    (
		SELECT TSA.IDDispositivo, TSA.DataAccensione, sec_to_time(sum(time_to_sec(TempoAccensione))) AS TotaleTempoAccensione, sec_to_time(sum(time_to_sec(TempoSpegnimento))) AS TotaleTempoSpegnimento
		FROM TempoSpegnimentoAccensione TSA
		GROUP BY TSA.IDDispositivo, TSA.DataAccensione
    )
    
    SELECT *
    FROM RIS R;

END $$

DELIMITER ;
/*
	Un'altra opzione sarebbe quella di sommare tutte le ore/minuti che il sispositivo è stato acceso in una giornata,
    per capire quanto è stato spento sottrarre a 24:00 le ore che è stato acceso
*/

-- OP3: Monitoraggio SmartLight con ridondanza

DROP PROCEDURE IF EXISTS  MonitoraggioLuceRidondanza;

DELIMITER $$

CREATE PROCEDURE MonitoraggioLuceRidondanza()						-- semplicemene andiamo a fare un select statement con "AccesaPer"
BEGIN
	
    SELECT AP.IDDispositivo, AP.DataAccensione, AP.TempoAccensione, AP.TempoSpegnimento
    FROM AccesaPer AP;

END $$

DELIMITER ;

-- Per l'aggiornamento della ridondanza

DROP TRIGGER IF EXISTS AggiornaAccesa;

DELIMITER $$

CREATE TRIGGER AggiornaAccesa
AFTER UPDATE ON ACCENSIONE
FOR EACH ROW
BEGIN
	DECLARE TempoAccensioneApp DOUBLE DEFAULT 0;					-- dichiarazione di variabili
    
    DECLARE verifica INT DEFAULT 0;
    DECLARE DispositivoVar INT DEFAULT 0;
    DECLARE DataAccensioneVar DATE DEFAULT NULL;
    DECLARE TempoAccensioneVar TIME DEFAULT NULL;
    DECLARE TempospegnimentoVar TIME DEFAULT NULL;
    
	SELECT TIMEDIFF(NEW.OraSpegnimento, NEW.OraAccensione) INTO TempoAccensioneApp;
    
    SELECT COUNT(*) INTO verifica 									-- controlliamo se il nuovo dispositivo è già stato acceso in precedenza
    FROM ACCESAPER A
	WHERE A.IDDispositivo = NEW.IDDispositivo
		AND A.DataAccensione = NEW.DataAccensione;
        
	IF(verifica <> 0) THEN											-- se è stato acceso
																	-- andiamo a sommare per quel dispositivo in quel giorno(giorno in cui viene attivato il trigger)
                                                                    -- al tempo che è stato in passato acceso e spento, il tempo che è stato acceso e spento al momento dello scatto del trigger
		SELECT sec_to_time(time_to_sec(TempoAccensioneApp) + time_to_sec(A.TempoAccensione)), sec_to_time(time_to_sec(A.TempoSpegnimento) - time_to_sec(TempoAccensioneAPP)) INTO TempoAccensioneVar, TempospegnimentoVar
		FROM ACCESAPER A
		WHERE A.IDDispositivo = NEW.IDDispositivo
			AND A.DataAccensione = NEW.DataAccensione;
	ELSEIF(verifica = 0) THEN										-- in caso in cui il dispositivo venga acceso per la prima volta
		SET TempoAccensioneVar = sec_to_time(time_to_sec(TempoAccensioneApp));
        SET TempospegnimentoVar = sec_to_time(time_to_sec('24:00:00') - time_to_sec(TempoAccensioneAPP));
	END IF;
    
    -- inseriamo all'inerno della ridondanza
	REPLACE INTO ACCESAPER(IDDispositivo, DataAccensione, TempoAccensione, TempoSpegnimento) VALUES
		(NEW.IDDispositivo, NEW.DataAccensione, TempoAccensioneVar, TempospegnimentoVar);
 
END $$

DELIMITER ;

/*
	Ovviamente anche se non è di nostro interesse, ongi giorno a mezzanotte scatterà un event che permette
    l'update di tutte le "OreSpegnimento" settando a "24:00:00" in caso sia NULL nella tabella "Accesa".
    Di conseguenza scatterà il trigger appena creato.
    
    Il trigger scatta anche in caso in cui un utente spegne la smart light oppure cambia impostazione, verrà un update
    alla tabbela e quindi lo scatto del trigger.
*/

-- OP.4: Lettura Consumo Medio Livello con ridondanza
	
DROP PROCEDURE IF EXISTS ConsumoKWLivello;

DELIMITER $$

CREATE PROCEDURE ConsumoKWLivello()
BEGIN

	DECLARE MediaKWConsumati DOUBLE DEFAULT 0;
	WITH TAB AS
	(
		SELECT CL.IDLivello, SUM(CD.KWConsumati) AS TotaleKWConsumati, COUNT(*) AS NumeroVolteUsatoLivello 
		FROM CONSUMODISPOSITIVO CD
			INNER JOIN
			ConsumoLivello CL ON (CD.IDDispositivo, CD.InizioAccensione) = (CL.IDDispositivo, CL.InizioAccensione)
			INNER JOIN
			LIVELLO L ON CL.IDLivello = L.IDLivello
		GROUP BY CL.IDLivello
		-- WHERE L.IDLivello = _IDLivello
	)
	
	SELECT  T.IDLivello, (T.TotaleKWConsumati/T.NumeroVolteUsatoLivello) As MediaKWConsumati
	FROM TAB T
    GROUP BY T.IDLivello;
    
            
END $$

DELIMITER ;
-- OP.4: Consumo medio livelli in caso di ridondanza, aggiorna ridondanza

SET SQL_SAFE_UPDATES = 0;

DROP PROCEDURE IF EXISTS MediaKWConsumatiPerLivello;

DELIMITER $$

CREATE PROCEDURE MediaKWConsumatiPerLivello()
BEGIN

	DECLARE MediaKWConsumati DOUBLE DEFAULT 0;
    DECLARE IDLivelloVar INT DEFAULT 0;
    
    DECLARE finito INT DEFAULT 0;
    
    DECLARE CursorUpdate CURSOR FOR
	WITH TAB AS
	(
		SELECT CL.IDLivello, SUM(CD.KWConsumati) AS TotaleKWConsumati, COUNT(*) AS NumeroVolteUsatoLivello 
		FROM CONSUMODISPOSITIVO CD
			INNER JOIN
			ConsumoLivello CL ON (CD.IDDispositivo, CD.InizioAccensione) = (CL.IDDispositivo, CL.InizioAccensione)
			INNER JOIN
			LIVELLO L ON CL.IDLivello = L.IDLivello
		GROUP BY CL.IDLivello
	),
    MEDIAKWCONSUMATI AS
    (	
		SELECT T.IDLivello, (T.TotaleKWConsumati/T.NumeroVolteUsatoLivello) As MediaKWConsumati
		FROM TAB T
    )
    
    SELECT L.IDLivello, MKC.MediaKWConsumati
    FROM MEDIAKWCONSUMATI MKC
		NATURAL JOIN
        LIVELLO L;
        
	DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET finito = 1;
    
    OPEN CursorUpdate;
    
    scan : LOOP
		FETCH CursorUpdate INTO IDLivelloVar, MediaKWConsumati;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
	UPDATE LIVELLO
    SET MediaConsumoKW = MediaKWConsumati
    WHERE IDLivello = IDLivelloVar;
END LOOP scan;
    
CLOSE CursorUpdate;

	SELECT IDLivello, MediaConsumoKW
    FROM LIVELLO;
END $$

DELIMITER ;
-- OP.5: Monitoraggio Dispositivi Accesi/Spenti

DROP PROCEDURE IF EXISTS MonitoraggioDispositivi;

DELIMITER $$
																	
CREATE PROCEDURE MonitoraggioDispositivi(IN _IDDispositivo INT)		-- In input avremo l'identificativo di un dispositivo		
BEGIN
	DECLARE verifica INT DEFAULT 0;
    DECLARE inizioImpostazione TIME DEFAULT NULL;
    DECLARE fineImpostazione TIME DEFAULT NULL;
	DECLARE TempoRimanente TIME DEFAULT NULL;
    DECLARE FineAccensione TIME DEFAULT NULL;
    
    SELECT LD.TimeStampFine INTO FineAccensione						-- prendo l'ultima accensione del dispositivo target restituendo l'ipotetico ultimo spegnimento
	FROM LOGDISPOSITIVO LD
	WHERE LD.IDDispositivo = _IDDispositivo
		AND LD.TimestampInizio = ( 
									SELECT MAX(LD0.TimestampInizio)
									FROM LOGDISPOSITIVO LD0
									WHERE LD0.IDDispositivo = _IDDispositivo
								);
                                                        
	IF(FineAccensione IS NULL) THEN									-- se l'ultimo spegnimento è nullo significa che il dispositivo è ancora acceso
		SELECT 'Dispositivo Acceso';
	ELSEIF(FineAccensione IS NOT NULL) THEN							-- se non fosse nullo 
		WITH CalcoloImpostazione AS									-- controllo dalle impostazioni, per controllare quando e se è stata programmata un'accesione in un futuro
		(
			SELECT ID.TimestampInizio, ID.TimestampFine, sec_to_time(time_to_sec(TimestampInizio) - time_to_sec(CURRENT_TIME)) AS Temporimanente
			FROM IMPOSTAZIONEDISPOSITIVI ID
			WHERE ID.IDDispositivo = _IDDispositivo
				AND ID.TimestampInizio = (
												SELECT MIN(ID0.TimestampInizio)		-- viene presa la data nel futuro più vicina ala data odierna
												FROM IMPOSTAZIONEDISPOSITIVI ID0
												WHERE ID0.IDDispositivo = _IDDispositivo
											)
		),
		CalcoloImpostazioneCondizionatore AS										-- si considerano le impostazioni dei condizionatori, sostanzialmente andiamo a controllare in quali giorni e in quali mesi dovranno essere accesi				
		(
        SELECT RIS.TimeStampInizio, RIS.TimestampFine, sec_to_time(time_to_sec(TimeStampInizio) - time_to_sec(CURRENT_TIME)) AS Temporimanente
        FROM(
			SELECT *, ROW_NUMBER() OVER w AS Numero
			FROM(																	-- poichè la ricorrenza è formata da giorno - mese - e ora di accensione e spegnimento, si va noi con la concat a creare il timestamp
																					-- prendo il timestamp più vicino al CURRENT_TIMESTAMP
				SELECT CONCAT(YEAR(CURRENT_TIMESTAMP), "-", P.IDMese, "-", P.IDGiorno, " ", IC.InizioImpostazione) AS TimeStampInizio, CONCAT( YEAR(CURRENT_TIMESTAMP), "-", P.IDMese, "-", P.IDGiorno, " ", IC.FineImpostazione) AS TimeStampFine
				FROM IMPOSTAZIONECONDIZIONATORE IC
					INNER JOIN
					IMPOSTACOND IMC ON IC.IDImpostazione = IMC.IDImpostazione
					INNER JOIN
					Periodo P ON IC.IDImpostazione = P.IDImpostazione
				WHERE IMC.IDDispositivo = _IDDispositivo
				-- GROUP BY P.IDGiorno, P.IDMese
			) AS D
			WINDOW w AS (
					-- PARTITION BY D.TimeStampInizio
					ORDER BY TimeStampInizio
				)
			) AS RIS
		WHERE RIS.Numero = 1
        /*
			SELECT P.Giorno, P.Mese, IMC.IDDispositivo, IC.InizioImpostazione AS TimestampInizio, IC.FineImpostazione AS TimestampFine, sec_to_time(time_to_sec(InizioImpostazione) - time_to_sec(CURRENT_TIME)) AS Temporimanente
			FROM IMPOSTAZIONECONDIZIONATORE IC
				INNER JOIN
				IMPOSTACOND IMC ON IC.IDImpostazione = IMC.IDImpostazione
                INNER JOIN
                Periodo P ON IC.IDImpostazione = P.IDImpostazione
			WHERE IMC.IDDispositivo = 3
            GROUP BY P.Giorno, P.Mese, IMC.IDDispositivo
			-- AND IC.InizioImpostazione > CURRENT_TIME
		*/
		),
		Impostazioni AS																		
		(
			SELECT *																-- si concatenano tutte le varie ricerche così capiamo nel complesso quando viene acceso un determinato dispositivo
			FROM CalcoloImpostazione
				UNION
			SELECT *
			FROM CalcoloImpostazioneCondizionatore
		)

		SELECT I.TimeStampInizio, I.TimeStampFine, I.Temporimanente INTO inizioImpostazione, fineImpostazione, TempoRimanente			-- si prende la data più vicina 
		FROM Impostazioni I
		WHERE I.TimeStampInizio < ALL (
										SELECT IT.TimeStampInizio
										FROM Impostazioni IT
										WHERE IT.TimeStampInizio <> I.TimeStampInizio
										);
        
		IF(inizioImpostazione IS NOT NULL) THEN
			SELECT CONCAT('Il dispositivo si accenderà automaticamente dalle ', inizioImpostazione, ' alle ', IF(fineImpostazione IS NULL, 'tempo da definire', fineImpostazione), ' mancano ', TempoRimanente) AS output;
		ELSE SELECT ('Dispositivo spento fino alle 24:00') AS output;
		END IF;
	END IF;
END $$

DELIMITER ;

-- OP.4: Flusso di energia

SET SQL_SAFE_UPDATES = 0;

DROP PROCEDURE IF EXISTS FlussoEnergetico;

DELIMITER $$

CREATE PROCEDURE FlussoEnergetico()
BEGIN
	DECLARE Produzione DOUBLE DEFAULT 0;
    DECLARE Consumo DOUBLE DEFAULT 0.0;
    DECLARE KWInBatteria DOUBLE DEFAULT 0.0;
    DECLARE CapacitaMassima DOUBLE DEFAULT 0.0;
    DECLARE KWRimanenti DOUBLE DEFAULT 0.0;
    DECLARE Fascia INT DEFAULT 0;
    DECLARE Momento TIME DEFAULT NULL;
    
	SELECT SUM(CD.KWConsumati) INTO Consumo
	FROM CONSUMODISPOSITIVO CD
	WHERE CD.InizioAccensione >= CURRENT_TIMESTAMP - INTERVAL 15 MINUTE
		AND CD.InizioAccensione <= CURRENT_TIMESTAMP;
		
	SELECT SPE.KWProdotti INTO Produzione
	FROM STORICOPRODUZIONEENERGIA SPE
	WHERE SPE.InizioTimeStamp = CURRENT_TIMESTAMP - INTERVAL 15 MINUTE
		AND SPE.FineTimeStamp = CURRENT_TIMESTAMP;
        
	SELECT B.KWAttuali, B.capacitaMassima INTO KWInBatteria, CapacitaMassima
    FROM BATTERIA B;
    
    SET Momento = TIME(CURRENT_TIMESTAMP);
                
	IF(Momento BETWEEN '08:00' AND '13:00') THEN
		SET Fascia = 1;
	ELSEIF(Momento BETWEEN '13:00' AND '18:00') THEN
		SET Fascia = 2;
	ELSEIF(Momento BETWEEN '18:00' AND '00:00') THEN
		SET Fascia = 3;
	ELSEIF(Momento BETWEEN '00:00' AND '08:00') THEN
		SET Fascia = 4;
	END IF;
                
	IF (Produzione > Consumo) THEN
			SET KWRimanenti = Produzione - Consumo;
                
				INSERT INTO CONSUMOGRUPPOSORGENTI(TimeStampConsumo, KWConsumati, IDFascia, IDGruppoSorgenti) 
					VALUES (CURRENT_TIMESTAMP, Consumo, Fascia, 1);
                    
            IF(KWRimanenti <> 0) THEN
				IF((KWRimanenti + KWInBatteria) < CapacitaMassima) THEN
					UPDATE BATTERIA
					SET KWAttuali = KWAttuali + KWRimanenti;
					
					INSERT INTO IMMISSIONE(TimeStampImmissione, KWImmissione) VALUES(CURRENT_TIMESTAMP, KWRimanenti);
				ELSEIF((KWRimanenti + KWInBatteria) > CapacitaMassima) THEN
					INSERT INTO IMMISSIONE(TimeStampImmissione, KWImmissione) VALUES(CURRENT_TIMESTAMP, KWRimanenti - (CapacitaMassima - KWInBatteria));
					
					UPDATE BATTERIA
					SET KWAttuali = CapacitaMassima;
				ELSEIF((KWRimanenti + KWInBatteria) = CapacitaMassima) THEN
					INSERT INTO IMMISSIONE(TimeStampImmissione, KWImmissione) VALUES(CURRENT_TIMESTAMP, KWRimanenti);
					
					UPDATE BATTERIA
					SET KWAttuali = CapacitaMassima;
				END IF;
            END IF;
            
		ELSEIF (Produzione < Consumo) THEN
			INSERT INTO CONSUMOGRUPPOSORGENTI(TimeStampConsumo, KWConsumati, IDFascia, IDGruppoSorgenti) 
					VALUES (CURRENT_TIMESTAMP, Produzione, Fascia, 1);
			
            SET KWRimanenti = Consumo - Produzione;
            
            IF(KWInBatteria > KWRimanenti) THEN
				INSERT INTO CONSUMOBATTERIA (TimeStampConsumo, KWConsumati, IDFascia, CodiceBatteria) VALUES
					(CURRENT_TIMESTAMP, KWRimanenti, Fascia, 5462);
                    
				UPDATE BATTERIA
                SET KWAttuali = KWAttuali - KWRimanenti;
			ELSEIF(KWInBatteria < KWRimanenti) THEN
				INSERT INTO CONSUMOBATTERIA (TimeStampConsumo, KWConsumati, IDFascia, CodiceBatteria) VALUES
					(CURRENT_TIMESTAMP, KWInBatteria, Fascia, 5462);
				
                UPDATE BATTERIA
                SET KWAttuali = 0;
                
                SET KWRimanenti = KWRimanenti - KWInBatteria;

                INSERT INTO PRELIEVO(TimeStampPrelievo, IDFascia, KWPrelievo, CodiceRete) VALUES
					(CURRENT_TIMESTAMP, Fascia, KWRimanenti, 1234);
			END IF;
	END IF;
        
END $$

DELIMITER ;

DROP EVENT IF EXISTS EventoFlussoEnergetica;

DELIMITER $$

CREATE EVENT EventoFlussoEnergetica
ON SCHEDULE EVERY 15 MINUTE
STARTS CURRENT_TIMESTAMP
DO
	CALL FlussoEnergetico();
    
DELIMITER ;

-- OP.7 Storico energia prodotta, immessa e prelevata, costo e guadagno

drop procedure if exists creaStorico;
delimiter $$
create procedure creaStorico(in inizioPeriodo timestamp, in finePeriodo timestamp)
begin
	DECLARE KWProdottiVar INT DEFAULT 0;
	DECLARE KWImmessiVar INT DEFAULT 0;
	DECLARE KWPrelevatiVar INT DEFAULT 0;
	DECLARE guadagno DOUBLE DEFAULT 0;
    DECLARE spesa DOUBLE DEFAULT 0;
    DECLARE KWConsumatiSorgenteVar DOUBLE DEFAULT 0;
    DECLARE KWConsumatiBatteriaVar DOUBLE DEFAULT 0;
    DECLARE KWConsumatiTotaleVar DOUBLE DEFAULT 0;
    
	SELECT IFNULL(sum(KWProdotti), 0) INTO KWProdottiVar
	FROM storicoproduzioneenergia
    WHERE InizioTimeStamp >= inizioPeriodo and FineTimeStamp <= finePeriodo;
    
    SELECT IFNULL(sum(KWImmissione), 0) INTO KWImmessiVar
    FROM immissione 
	WHERE TimeStampImmissione >= inizioPeriodo and TimeStampImmissione <= finePeriodo;
    
    SELECT IFNULL(sum(KWPrelievo), 0) INTO KWPrelevatiVar
	FROM prelievo 
	WHERE TimeStampPrelievo >= inizioPeriodo and TimeStampPrelievo <= finePeriodo;

    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiTotaleVar
	FROM CONSUMODISPOSITIVO 
	WHERE InizioAccensione >= inizioPeriodo and FineAccensione <= finePeriodo;
    
    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiSorgenteVar
	FROM ConsumoGruppoSorgenti  CGS
	WHERE CGS.TimeStampConsumo >= inizioPeriodo and CGS.TimeStampConsumo <= finePeriodo;
    
    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiBatteriaVar
	FROM ConsumoBatteria  CB
	WHERE CB.TimeStampConsumo >= inizioPeriodo and CB.TimeStampConsumo <= finePeriodo;
    
    SELECT IFNULL(SUM(I.KWImmissione*FA.CostoKW), 0) INTO guadagno
	FROM IMMISSIONE I
		INNER JOIN
		FASCIAORARIA FA ON I.IDFascia = FA.IDFascia
	WHERE TimeStampImmissione >= inizioPeriodo and TimeStampImmissione <= finePeriodo;

	SELECT IFNULL(SUM(P.KWPrelievo*FA.CostoKW), 0) INTO spesa
	FROM PRELIEVO P
		INNER JOIN
		FASCIAORARIA FA ON P.IDFascia = FA.IDFascia
	WHERE TimeStampPrelievo >= inizioPeriodo and TimeStampPrelievo <= finePeriodo;
    
    SELECT KWProdottiVar, KWConsumatiTotaleVar, KWConsumatiSorgenteVar, KWConsumatiBatteriaVar, KWPrelevatiVar, spesa, KWImmessiVar, guadagno;
    
end $$

delimiter ;

-- EVENT

DROP EVENT IF EXISTS statisticaMese;

DROP PROCEDURE IF EXISTS statisticaMese;
DELIMITER $$

CREATE PROCEDURE statisticaMese()
BEGIN
	DECLARE KWProdottiMese DOUBLE DEFAULT 0.0;
    DECLARE KWConsumatiMese DOUBLE DEFAULT 0.0;
    DECLARE SpesaMese DOUBLE DEFAULT 0.0;
	DECLARE GuadagnoMese DOUBLE DEFAULT 0.0;
    
    DECLARE PercentualeKWProdotti DOUBLE DEFAULT 0.0;
    DECLARE PercentualeKWConsumo DOUBLE DEFAULT 0.0;
    DECLARE PercentualeKWSpesa DOUBLE DEFAULT 0.0;
	DECLARE PercentualeKWGuadagno DOUBLE DEFAULT 0.0;
    
    DECLARE Risultato VARCHAR(255) DEFAULT '';
    
	SELECT SUM(SPE.KWProdotti) INTO KWProdottiMese
	FROM STORICOPRODUZIONEENERGIA SPE
	WHERE YEAR(SPE.InizioTimeStamp) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(SPE.InizioTimeStamp) = MONTH(CURRENT_TIMESTAMP) - 1
		OR 
		YEAR(SPE.InizioTimeStamp) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(SPE.InizioTimeStamp) = 12;

	SELECT SUM(CD.KWConsumati) INTO KWConsumatiMese
	FROM CONSUMODISPOSITIVO CD
	WHERE (YEAR(CD.InizioAccensione) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(CD.InizioAccensione) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(CD.InizioAccensione) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(CD.InizioAccensione) = 12);

	SELECT SUM(P.KWPrelievo*FA.CostoKW) INTO SpesaMese
	FROM PRELIEVO P
		INNER JOIN
		FASCIAORARIA FA ON P.IDFascia = FA.IDFascia
	WHERE (YEAR(P.TimeStampPrelievo) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(P.TimeStampPrelievo) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(P.TimeStampPrelievo) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(P.TimeStampPrelievo) = 12);

	SELECT SUM(I.KWImmissione*FA.CostoKW) INTO GuadagnoMese
	FROM IMMISSIONE I
		INNER JOIN
		FASCIAORARIA FA ON I.IDFascia = FA.IDFascia
	WHERE (YEAR(I.TimeStampImmissione) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(I.TimeStampImmissione) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(I.TimeStampImmissione) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(I.TimeStampImmissione) = 12);
        
	INSERT INTO MV_Storico(DataStorico, KWProdotti, KWConsumati, Guadagno, Consumo) VALUES(CURRENT_DATE, KWProdottiMese, KWConsumatiMese, SpesaMese, GuadagnoMese);
    
    WITH TableTarget AS
	(
		SELECT MVS.*, LEAD(MVS.KWPRodotti) OVER w AS KWProdottiSucc, LEAD(MVS.KWConsumati) OVER w AS KWConsumatiSucc, LEAD(MVS.Guadagno) OVER w AS GuadagnoSucc, LEAD(MVS.Consumo) OVER w AS ConsumoSucc
		FROM MV_Storico MVS
		WHERE (MONTH(MVS.DataStorico) >= MONTH(CURRENT_TIMESTAMP) - 1
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP))
			OR
			(MONTH(MVS.DataStorico) = 12
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP) - 1)
			AND MONTH(MVS.DataStorico) = 1
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP)
		WINDOW w AS
		(
			ORDER BY MVS.DataStorico
		)
	)

	SELECT 100 - ((TT.KWProdottiSucc*100)/TT.KWProdotti), 100 - ((TT.KWConsumatiSucc*100)/TT.KWConsumati), 100 - ((TT.GuadagnoSucc*100)/TT.Guadagno), 100 - ((TT.ConsumoSucc*100)/TT.Consumo) INTO PercentualeKWProdotti, PercentualeKWConsumo, PercentualeKWSpesa, PercentualeKWGuadagno
	FROM TableTarget TT
	WHERE KWProdottiSucc IS NOT NULL;
    
    SET Risultato = CONCAT('Produzione KW: ', FLOOR(ABS(PercentualeKWProdotti)), IF(PercentualeKWProdotti > 0, ' in meno.', ' in più.'),
						'   Consumo KW: ', FLOOR(ABS(PercentualeKWConsumo)), IF(PercentualeKWConsumo > 0, ' in meno.', ' in più.'),
						'   Spesa KW: ', FLOOR(ABS(PercentualeKWSpesa)), IF(PercentualeKWSpesa > 0, ' in meno.', ' in più.'),
						'   Guadagno KW: ', FLOOR(ABS(PercentualeKWGuadagno)), IF(PercentualeKWGuadagno < 0, ' in meno.', ' in più.'));
    
    SELECT Risultato;
END $$

DELIMITER ;

-- OP.8: Ranking dei dispositivi scelti in base ai suggerimenti

drop procedure if exists get_top_class;

delimiter $$

create procedure get_top_class()
	begin
		select D.NTipoDispositivo
		from Dispositivo D natural join
		(
			select IDDispositivo, max(accettati_per_dispositivo) as accettati
            from (
				select count(*) as accettati_per_dispositivo, IDDispositivo
				from Suggerimento
                where Scelto = 1
				group by IDDispositivo
            ) as c
            group by IDDispositivo
        ) as M
        where D.eliminato != 1
        group by D.NTipoDispositivo;
    end $$
delimiter ;