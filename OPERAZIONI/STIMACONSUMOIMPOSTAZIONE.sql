DROP FUNCTION IF EXISTS StimaConsumoImpostazione;

DELIMITER $$

CREATE FUNCTION StimaConsumoImpostazione(_IDImpostazione INT, _Giorno INT, _mese INT)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	
    DECLARE TemperaturaInterna DOUBLE DEFAULT 0.0;
    DECLARE TemperaturaEsterna DOUBLE DEFAULT 0.0;
    
    DECLARE _IDStanza INT DEFAULT 0;
    DECLARE ConsumoTotaleDispositivoLivello DOUBLE DEFAULT 0.0;
    
    DECLARE ConsumoKW DOUBLE DEFAULT 0.0;
    
    DECLARE MediaErroreTemperaturaInterna DOUBLE DEFAULT NULL;
    DECLARE MediaErroreTemperaturaEsterna DOUBLE DEFAULT NULL;
    
    DECLARE Risultato VARCHAR(255) DEFAULT NULL;
    
    -- si prende i dispositivi(condizionatori) coinvolti nella impostazione target, e si sommano i consumi di tutti i condizionatori coinvolti
    -- e i consumi dei vari livelli coinvolti
    SELECT DISTINCT(IC.IDStanza), IF(L.MediaConsumoKW = 0, SUM(D.ConsumoKW), SUM(L.MediaConsumoKW)) INTO _IDStanza, ConsumoTotaleDispositivoLivello
	FROM LIVELLO L
		INNER JOIN
		IMPOSTAZIONECONDIZIONATORE IC ON L.IDLivello = IC.IDLivello
		INNER JOIN
		IMPOSTACOND ICD ON IC.IDImpostazione = ICD.IDImpostazione
		INNER JOIN
		DISPOSITIVO D ON ICD.IDDispositivo = D.IDDispositivo
	WHERE IC.IDImpostazione = _IDImpostazione
    GROUP BY IC.IDImpostazione;
    
    IF((_Giorno > DAY(CURRENT_DATE) AND _mese = MONTH(CURRENT_DATE)) OR _mese > MONTH(CURRENT_DATE)) THEN
    -- in caso in cui si voglia fare una stima nel futuro
		WITH TemperatureTarget AS
		(
			-- dovremo controllare le temperature, poichè il consumo energetico si basa su quanta energia ci vuole per riscaldare una stanza
            -- secondo parametri ben precisi legati strettamente alla temperatura
            -- faremo quindi una media della temperatura indietro negli anni dello stesso mese e giorno
			SELECT DATE(T.TimeStampRilevazione) AS DataCalcolo, AVG(T.TemperaturaInizialeInterna) AS MediaGiornalieraTemperaturaInterna, AVG(T.TemperaturaInizialeEsterna) AS MediaGiornalieraTemperaturaEsterna, AVG(CT.ConsumoKW) AS MediaConsumoKW
			FROM TEMPERATURA T
				NATURAL JOIN
				CONSUMOTEMPERATURA CT
			WHERE MONTH(T.TimeStampRilevazione) = _mese
				AND DAY(T.TimeStampRilevazione) = _Giorno
				AND T.IDStanza = _IDStanza
			GROUP BY DATE(T.TimeStampRilevazione)
		),
		TemperaturaInternaEsterna AS
		-- affianchiamo alla media di temperatura interna/esterna la temperatura minima e massima sia interna che esterna 
		(
			SELECT AVG(TT.MediaGiornalieraTemperaturaInterna) AS MediaInterna,(
																				SELECT MIN(TT0.MediaGiornalieraTemperaturaInterna)
																				FROM TemperatureTarget TT0
																				) AS MediaMinimaInterna,
																				(
																				SELECT MAX(TT0.MediaGiornalieraTemperaturaInterna)
																				FROM TemperatureTarget TT0
																				) AS MediaMassimaInterna,
				   AVG(TT.MediaGiornalieraTemperaturaEsterna) AS MediaEsterna,(
																				SELECT MIN(TT0.MediaGiornalieraTemperaturaEsterna)
																				FROM TemperatureTarget TT0
																				) AS MediaMinimaEsterna, 
																				(
																				SELECT MAX(TT0.MediaGiornalieraTemperaturaEsterna)
																				FROM TemperatureTarget TT0
																				) AS MediaMassimaEsterna,
					AVG(TT.MediaConsumoKW) AS MediaConsumo
			FROM TemperatureTarget TT
		),
		PercentualeTemperatura AS
		(
        -- prendiamo la percentuale di cambiamento delle varie temperature, sia della minima che massima e interna ed esterna
			SELECT TIE.MediaInterna, TIE.MediaMinimaInterna, TIE.MediaMassimaInterna, 
					ABS((100-((MediaMinimaInterna*100)/MediaInterna))) AS PercentualeCambiamentoTemperaturaMinimaInterna,
					ABS((100-((MediaMassimaInterna*100)/MediaInterna))) AS PercentualeCambiamentoTemperaturaMassimaInterna,
					
					TIE.MediaEsterna, TIE.MediaMinimaEsterna, TIE.MediaMassimaEsterna, 
					ABS((100-((MediaMinimaEsterna*100)/MediaEsterna))) AS PercentualeCambiamentoTemperaturaMinimaEsterna,
					ABS((100-((MediaMassimaEsterna*100)/MediaEsterna))) AS PercentualeCambiamentoTemperaturaMassimaEsterna,
					
					TIE.MediaConsumo
			FROM TemperaturaInternaEsterna TIE
		)
		-- arrotondiamo e stampiamo
		SELECT FLOOR(PT.MediaInterna), FLOOR(((PT.PercentualeCambiamentoTemperaturaMinimaInterna + PT.PercentualeCambiamentoTemperaturaMassimaInterna)/2)) AS PercentualeErroreTemperaturaInterna, FLOOR(PT.MediaEsterna), FLOOR(((PT.PercentualeCambiamentoTemperaturaMinimaEsterna + PT.PercentualeCambiamentoTemperaturaMassimaEsterna)/2)) AS PercentualeErroreTemperaturaEsterna, PT.MediaConsumo INTO TemperaturaInterna, MediaErroreTemperaturaInterna, TemperaturaEsterna, MediaErroreTemperaturaEsterna, ConsumoKW
		FROM PercentualeTemperatura PT;
	ELSEIF((_Giorno < DAY(CURRENT_DATE) AND _mese = MONTH(CURRENT_DATE)) OR _mese < MONTH(CURRENT_DATE)) THEN
    -- in caso sia un giorno del passato dovremo solo attenersi ai dati memorizzati
		SELECT AVG(T.TemperaturaInizialeInterna), AVG(T.TemperaturaInizialeEsterna), AVG(CT.ConsumoKW) INTO TemperaturaInterna, TemperaturaEsterna, ConsumoKW
		FROM TEMPERATURA T
			NATURAL JOIN
            CONSUMOTEMPERATURA CT
        WHERE YEAR(T.TimeStampRilevazione) = YEAR(CURRENT_DATE)
			AND MONTH(T.TimeStampRilevazione) = _mese
            AND DAY(T.TimeStampRilevazione) = _Giorno
            AND T.IDStanza = _IDStanza;
    END IF;
    SELECT CONCAT('Si presume una temperatura interna di ', TemperaturaInterna, ', una temperatura esterna di ', TemperaturaEsterna, ' +/-', MediaErroreTemperaturaEsterna, ' e un consumo di ', ConsumoKW + ConsumoTotaleDispositivoLivello) INTO Risultato;
    IF Risultato IS NULL THEN
		RETURN "ERRORE";
    ELSE
		RETURN Risultato;
	END IF;
END $$

DELIMITER ;