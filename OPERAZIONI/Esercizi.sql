/*
*Indicare l’incasso totale degli ultimi due anni, realizzato grazie alle visite dei medici cardiologi della clinica.

*Indicare il reddito medio dei pazienti che sono stati visitati solo da medici con parcella superiore a 100 euro,
 negli ultimi sei mesi.

*Indicare nome e cognome dei pazienti con reddito compreso fra 1000 e 2000 euro che sono stati visitati nel 2010
 da almeno un medico da cui non erano mai stati visitati prima.
*/

SELECT P.Nome, P.Cognome
FROM Paziente P
	INNER JOIN Visita V ON P.CodFiscale = V.Paziente
    INNER JOIN Medico M ON M.Matricola = V.Medico
WHERE P.Reddito BETWEEN 1000 AND 2000
	AND YEAR(V.Data) = 2010
    AND V.Medico NOT IN (SELECT V1.Medico
							FROM Visita V1
							WHERE V.Medico = V1.Medico
							AND V.Data < V1.Data
							)
;

WITH pazienti_f AS(
	SELECT AVG(P.Reddito) AS Reddito_Medio_F
    FROM Paziente P
		INNER JOIN Visita V
		ON P.CodFiscale = V.Paziente
		INNER JOIN Medico M
		ON V.Medico = M.Matricola
    WHERE P.Sesso = 'F'
    AND V.Data BETWEEN date_sub('2012-01-01', INTERVAL 2 YEAR) AND '2012-01-01'
    AND M.Parcella = (SELECT MAX(M1.Parcella)
						FROM Medico M1
						)
), pazienti_m AS(
	SELECT AVG(P.Reddito) AS Reddito_Medio_M
    FROM Paziente P
		INNER JOIN Visita V
		ON P.CodFiscale = V.Paziente
		INNER JOIN Medico M
		ON V.Medico = M.Matricola
    WHERE P.Sesso = 'M'
    AND V.Data BETWEEN date_sub('2012-01-01', INTERVAL 2 YEAR) AND '2012-01-01'
    AND M.Parcella = (SELECT MAX(M1.Parcella)
						FROM Medico M1
						)
)
SELECT Reddito_Medio_F, Reddito_Medio_M
FROM pazienti_f, pazienti_m
;

SELECT SUM(M.Parcella) AS incasso_totale
FROM Visita V INNER JOIN Medico M
	ON V.Medico = M.Matricola
WHERE M.Specializzazione = 'Cardiologia' AND YEAR(V.Data) BETWEEN YEAR(current_date()) - 2 AND YEAR(current_date()) - 1
;

-- Per ogni specializzazione medica, indicarne il nome, la parcella minima
-- e il cognome del medico a cui appartiene

SELECT M.Specializzazione, min(M.Parcella) AS ParcellaMinima, M.Cognome
FROM Medico M
GROUP BY M.Specializzazione, M.Matricola
;

-- Indicare le specializzazioni della clinica con più di due medici

SELECT M.Specializzazione
FROM Medico M
GROUP BY M.Specializzazione
HAVING COUNT(*) > 2
;

-- Indicare le specializzazioni con la più alta parcella media

SELECT M.Specializzazione
FROM Medico M
GROUP BY M.Specializzazione
HAVING AVG(Parcella) = (
	SELECT MAX(MediaParcelle)
    FROM (
		SELECT AVG(M1.Parcella) AS MediaParcelle
        FROM Medico M1
        GROUP BY M1.Specializzazione
    ) AS D
)
;

-- Indicare le specializzazioni con più di due medici di Pisa.

SELECT M.Specializzazione
FROM Medico M
WHERE M.Citta = 'Pisa'
GROUP BY M.Specializzazione
HAVING COUNT(*) > 2
;

/*
Considerati i soli pazienti di Pisa, indicarne nome e cognome,
e la spesa sostenuta per le visite di ciascuna specializzazione,
nel triennio 2008-2010.
*/

SELECT M.Specializzazione, P.Nome, P.Cognome, SUM(M.Parcella)
FROM Visita V
	INNER JOIN 
    Paziente P ON V.Paziente = P.CodFiscale
    INNER JOIN
    Medico M ON M.Matricola = V.Medico
WHERE P.Citta = 'Pisa' AND YEAR(V.Data) BETWEEN 2008 AND 2010
GROUP BY M.Specializzazione, P.CodFiscale
ORDER BY M.Specializzazione, P.Nome
;

/*
1. Considerata ogni specializzazione, indicarne il nome e l’incasso degli ultimi due anni.
2. Indicare le specializzazioni aventi medici della stessa città.
3. Indicare codice fiscale, nome, cognome ed età del paziente più anziano della clinica, e il numero di volte da cui è stato visitato da ogni medico.
4. Indicare la matricola dei medici che hanno effettuato più del 20% delle visite annue della loro specializzazione
	in almeno due anni fra il 2010 e il 2020.
	[Suggerimento: nel select, è possibile inserire espressioni (quindi si possono usare +,-,*,/).
    Per esempio, se voglio restituire il reddito annuale di tutti i pazienti della clinica, posso scrivere:  SELECT P.Reddito*12 FROM Paziente P;]
5. Fra tutte le città da cui provengono più di tre pazienti con reddito superiore a 1000 Euro,
	indicare quelle da cui provengono almeno due pazienti che sono stati visitati più di una volta al mese,
	nel corso degli ultimi 10 anni.
*/

-- 5
WITH citta_target AS (
	SELECT P.Citta
    FROM Paziente P
    WHERE P.Reddito > 1000
    GROUP BY Citta
    HAVING COUNT(*) > 3
),
visite_target AS (
	SELECT  P.CodFiscale AS Paziente,
			MONTH(V.Data) AS MeseVisita,
            YEAR(V.Data) AS AnnoVisita,
            CT.Citta
    FROM Paziente P
		INNER JOIN
        Visita V ON P.CodFiscale = V.Paziente
        NATURAL JOIN
        citta_target CT
	WHERE YEAR(V.Data) > YEAR(CURRENT_DATE()) - INTERVAL 10 YEAR
),
visite_mese AS (
	SELECT VT.Paziente,
			VT.MeseVisita,
            VT.AnnoVisita,
            VT.Citta,
            COUNT(*) AS NVisite
    FROM visite_target VT
	GROUP BY VT.Paziente,
			VT.MeseVisita,
            VT.AnnoVisita,
            VT.Citta
)
SELECT VM.Citta
FROM visite_mese VM
WHERE VM.Nvisite > 1
GROUP BY VM.Citta
HAVING COUNT(DISTINCT VM.Paziente) >= 2
;
-- 4
WITH visite_2010_2020 AS (
	SELECT  V.Medico,
			YEAR(V.Data) AS Anno
    FROM Visita V
    WHERE YEAR(V.Data) BETWEEN 2010 AND 2020
),
visite_annue_med AS(
	SELECT  V1.Medico,
            M.Specializzazione,
            COUNT(*) AS VisiteMed
    FROM visite_2010_2020 V1
		INNER JOIN 
        Medico M ON M.Matricola = V1.Medico
    GROUP BY V1.Medico, V1.Anno
),
visite_annue_spec AS (
	SELECT  VAM.Specializzazione,
			SUM(VAM.VisiteMed) AS VisiteSpec
    FROM visite_annue_med VAM
		INNER JOIN
        Medico M ON M.Matricola = VAM.Medico
	GROUP BY M.Specializzazione
)
SELECT VAM.Medico
FROM visite_annue_spec VAS
	NATURAL JOIN
    visite_annue_med VAM
WHERE VAM.VisiteMed > 0.2*VAS.VisiteSpec
;

-- 1
SELECT M.Specializzazione, SUM(M.Parcella)
FROM Medico M INNER JOIN Visita V ON V.Medico = M.Matricola
WHERE YEAR(V.Data) BETWEEN (YEAR(current_date()) - 2) AND YEAR(current_date())
GROUP BY M.Specializzazione
;

-- 2
SELECT M.Specializzazione
FROM Medico M
GROUP BY M.Specializzazione
HAVING COUNT(*) > 1
;

SELECT M.Specializzazione
FROM Medico M
GROUP BY M.Specializzazione
HAVING COUNT(DISTINCT M.Citta) = 1
;

-- 3
WITH paziente_anziano AS(
	SELECT P.CodFiscale, P.Nome, P.Cognome, (YEAR(current_date()) - YEAR(P.DataNascita)) AS Eta
    FROM Paziente P
    WHERE P.DataNascita = (
		SELECT MIN(P1.DataNascita)
        FROM Paziente P1
    )
)
SELECT PA.CodFiscale, PA.Nome, PA.Cognome, PA.Eta, COUNT(*) AS NumeroVisite, V.Medico
FROM paziente_anziano PA
	INNER JOIN
    Visita V ON PA.CodFiscale = V.Paziente
GROUP BY V.Paziente, V.Medico
;

/*
1. Scrivere un trigger che impedisca l’inserimento di due terapie consecutive per lo stesso paziente,
	caratterizzate dallo stesso farmaco, la più recente delle quali con una posologia superiore al doppio rispetto alla precedente.
2. Creare una business rule per impedire che un medico possa visitare mensilmente più di due volte lo stesso paziente,
	qualora all’atto delle due visite già effettuate in un dato mese dal medico sul paziente, quest’ultimo non fosse affetto da alcuna patologia.
3. Creare una business rule che permetta di inserire un nuovo farmaco F e le relative indicazioni,
	se nel database non vi sono già più di due farmaci,
	di cui almeno uno basato sullo stesso principio attivo di F,
	aventi ciascuno un’indicazione per una stessa patologia per la quale F è indicato.
	Supporre che prima sia inserito il farmaco, e dopo le sue indicazioni.
4. Scrivere un event che sconti mensilmente del 2% i farmaci
	che sono stati assunti in meno del 10% delle terapie iniziate nel mese precedente.
	Nel caso in cui un farmaco venga scontato, mantenere nella tabella Farmaco anche il prezzo originario.
*/

-- 4
ALTER TABLE Farmaco
ADD COLUMN PrezzoScontato DOUBLE DEFAULT 0 NOT NULL AFTER Costo;

DROP EVENT IF EXISTS sconta_farmaci;
DELIMITER $$
CREATE EVENT sconta_farmaci
ON SCHEDULE EVERY 1 MONTH DO
BEGIN
	DECLARE terapie_mese_prec INTEGER DEFAULT 0;
    
    SELECT COUNT(*) INTO terapie_mese_prec		
	FROM Terapia T
	WHERE YEAR(T.DataInizioTerapia) = YEAR(current_date())
		AND MONTH(T.DataInizioTerapia) = MONTH(current_date()) - 1;
    
	UPDATE Farmaco F
	SET F.PrezzoScontato = (F.Prezzo - 0.02*F.Prezzo)
    WHERE terapie_mese_prec > 0.1*(
		SELECT COUNT(*)
		FROM Terapia T
		WHERE YEAR(T.DataInizioTerapia) = YEAR(current_date())
		AND MONTH(T.DataInizioTerapia) = MONTH(current_date()) - 1
    );
END $$
DELIMITER ;

-- 3
DROP TRIGGER IF EXISTS check_farmaci;
DELIMITER $$
CREATE TRIGGER check_farmaci
BEFORE INSERT ON Indicazione
FOR EACH ROW
BEGIN
	DECLARE principio_new CHAR (100) DEFAULT '';
	DECLARE principio_cur CHAR (100) DEFAULT '';
    DECLARE farmaci_stesso_principio INTEGER DEFAULT 0;
    
    DECLARE finito INTEGER DEFAULT 0;
    
    DECLARE farmaci_stessa_pat CURSOR FOR
    SELECT I.Farmaco
    FROM Indicazione I
		INNER JOIN
        Farmaco F ON F.NomeCommerciale = I.Farmaco
    WHERE I.Farmaco = NEW.Farmaco;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;
    
    SET principio_new = (
		SELECT F.PrincipioAttivo
        FROM Farmaco F
        WHERE F.NomeCommerciale = NEW.Farmaco
    );
    
    OPEN farmaci_stessa_pat;
    
    REPEAT
		FETCH Farmaci_stessa_pat INTO principio_cur;
		IF principio_cur = principio_new THEN
			SET farmaci_stesso_principio = farmaci_stesso_principio + 1;
		END IF;
    UNTIL farmaci_stesso_principio = 1 OR finito = 1
    END REPEAT;
    
    CLOSE farmaci_stessa_pat;
    
    IF farmaci_stesso_principio > 1 THEN
		DELETE FROM Farmaco
        WHERE NomeCommerciale = NEW.Farmaco;
		
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inserimento indicazione non valido, e farmaco eliminato!';
    END IF;
END $$
DELIMITER;

-- 2
DROP TRIGGER IF EXISTS blocca_visite_consecutive;
DELIMITER $$
CREATE TRIGGER blocca_visite_consecutive
BEFORE INSERT ON Visita
FOR EACH ROW
BEGIN
	DECLARE visite_mese_paziente INTEGER DEFAULT 0;
    DECLARE no_patologia INTEGER DEFAULT 0;
    
    SET visite_mese_paziente = (
		SELECT COUNT(*)
        FROM Visita V
        WHERE V.Paziente = NEW.Paziente
			AND V.Medico = NEW.Medico
            AND NEW.Data BETWEEN V.Data AND V.Data + INTERVAL 1 MONTH
    );
    
    SET no_patologia = (
		SELECT COUNT(*)
        FROM Esordio E
		WHERE E.Paziente = NEW.Paziente
			AND E.DataGuarigione BETWEEN NEW.Data - INTERVAL 1 MONTH AND NEW.Data
    );
    
    IF (visite_mese_paziente > 2 AND no_patologia > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inserimento non valido!';
	END IF;
    
END $$
DELIMITER ;

-- 1
DROP TRIGGER IF EXISTS blocca_terapie_consecutive;
DELIMITER $$
CREATE TRIGGER blocca_etrapie_consecutive
BEFORE INSERT ON Terapia
FOR EACH ROW
BEGIN
	DECLARE terapia_consecutiva INTEGER DEFAULT 0;
    
    SET terapia_consecutiva = (
		SELECT 1
        FROM Terapia T
        WHERE T.Paziente = NEW.Paziente
			AND T.Farmaco = NEW.Farmaco
            AND T.DataInizioTerapia =(
				SELECT MAX(T1.DataInizioTerapia)
                FROM Terapia T1
                WHERE T1.Paziente = NEW.Paziente
						AND T1.Farmaco = NEW.Farmaco
            )
            AND NEW.Posologia > 2*T.Posologia
    );
    
    IF(terapia_consecutiva = 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Terapia inserita non valida!';
	END IF;
		
END $$
DELIMITER ;

/*
	Creare una materialized view MV_RESOCONTO avente funzione di reporting, contenente, per ogni specializzazione medica della clinica,
	il numero di visite effettuate,
    il numero di nuovi pazienti visitati,
	l’incasso totale relativo al mese in corso,
    e la matricola del medico che ha visitato più pazienti.
	Implementare:
	i) il complete incremental refresh;
	ii) il partial incremental refresh;
	iii) il rebuild.
	Per semplicità, implementare solamente il push relativo all’inserimento.
*/

CREATE TABLE MV_RESOCONTO (
	Specializzazione CHAR (100) PRIMARY KEY NOT NULL,
    VisiteEffettuate INTEGER NOT NULL DEFAULT 0,
    NuoviPazientiVisitati INTEGER NOT NULL DEFAULT 0,
    IncassoTotale DOUBLE NOT NULL DEFAULT 0,
    MedicoGOAT CHAR(100) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET=latin1;

SET @var1 = (
	SELECT D.Anno
	FROM (
		SELECT YEAR(V.Data) AS Anno, COUNT(*) AS VisiteAnnue
		FROM Visita V
		GROUP BY YEAR(V.Data)
		ORDER BY VisiteAnnue DESC
	) AS D
	GROUP BY D.Anno
	HAVING MIN(VisiteAnnue) < ALL (
		SELECT COUNT(*) AS VisiteAnnue
		FROM Visita V
		WHERE D.Anno <> YEAR(V.Data)
		GROUP BY YEAR(V.Data)
	)
);

SET @var2 = (
	SELECT D.Anno
	FROM (
		SELECT YEAR(V.Data) AS Anno, COUNT(*) AS VisiteAnnue
		FROM Visita V
		GROUP BY YEAR(V.Data)
		ORDER BY VisiteAnnue DESC
	) AS D
	GROUP BY D.Anno
	HAVING MAX(VisiteAnnue) > ALL (
		SELECT COUNT(*) AS VisiteAnnue
		FROM Visita V
		WHERE D.Anno <> YEAR(V.Data)
		GROUP BY YEAR(V.Data)
	)
);

SELECT * FROM MV_RESOCONTO ORDER BY VisiteEffettuate DESC;

TRUNCATE TABLE MV_RESOCONTO;

INSERT INTO MV_RESOCONTO
WITH incasso_mese AS
(
	SELECT M.Specializzazione, SUM(Parcella) AS Incasso
    FROM Visita V
		INNER JOIN 
        Medico M ON M.Matricola = V.Medico
    WHERE MONTH(V.Data) = 9
		AND YEAR(V.Data) = @var1
    GROUP BY M.Specializzazione
),
medico_ganzo AS (
	SELECT M.Matricola
	FROM Medico M
		INNER JOIN
		Visita V ON V.Medico = M.Matricola
	GROUP BY M.Matricola
	HAVING COUNT(*) >= ALL (
		SELECT COUNT(*)
		FROM Medico M1
			INNER JOIN
			Visita V1 ON V1.Medico = M1.Matricola
		WHERE M1.Matricola <> M.Matricola
		GROUP BY M1.Matricola
	)
)
SELECT M.Specializzazione,
		COUNT(*) AS Visite,
        COUNT(DISTINCT V.Paziente) AS NuoviPazienti,
        IM.Incasso AS IncassoTotale,
		MG.Matricola
FROM Visita V
	INNER JOIN
    Medico M ON M.Matricola = V.Medico
    NATURAL JOIN
    incasso_mese IM,
    medico_ganzo MG
GROUP BY M.Specializzazione, IM.Incasso;

SELECT M.Matricola, 
		M.Cognome, 
		M.Specializzazione,
		M.Parcella,
        M.VisiteSpec,
		DENSE_RANK() OVER(PARTITION BY M.Specializzazione ORDER BY M.VisiteSpec DESC) AS Posizione
FROM (
	SELECT COUNT(*) AS VisiteSpec, M1.Cognome, M1.Specializzazione, M1.Matricola, M1.Parcella
	FROM Visita V
		INNER JOIN
		Medico M1 ON V.Medico = M1.Matricola
        INNER JOIN
        Paziente P ON V.Paziente = P.CodFiscale
	WHERE M1.Citta = 'Pisa' OR M1.Citta = 'Livorno'
		AND P.Sesso = 'F'
        AND P.Reddito*12 >= 20000
	GROUP BY M1.Matricola, M1.Specializzazione
) AS M;

WITH visite_medici AS(
	SELECT  M.Matricola,
			M.Cognome,
            M.Specializzazione,
            M.Parcella,
            COUNT(*) AS Visite
    FROM Visita V
		INNER JOIN
        Medico M ON M.Matricola = V.Medico
	GROUP BY M.Matricola
)
SELECT *,
		RANK() OVER(ORDER BY VM.Visite) AS ClassificaVisite,
        DENSE_RANK() OVER(PARTITION BY VM.Specializzazione ORDER BY VM.Visite) AS ClassificaSpec
FROM visite_medici VM
ORDER BY ClassificaVisite, Specializzazione;

SELECT V.Medico,
		V.Paziente,
		V.Data,
        LEAD(V.Data, 1) OVER(
			PARTITION BY V.Paziente
            ORDER BY V.Data
        ) AS VisitaPrecedente
FROM Visita V
	INNER JOIN
	Medico M ON M.Matricola = V.Medico
WHERE M.Specializzazione = 'Otorinolaringoiatria'
	AND YEAR(V.Data) BETWEEN 2010 AND 2019;


SELECT V.Medico,
		V.Paziente,
        V.Data,
		FIRST_VALUE(V.Data) OVER (
			PARTITION BY V.Paziente, V.Medico ORDER BY V.Data
        ) AS PrimaVisita,
		LAST_VALUE(V.Data) OVER (
			PARTITION BY V.Paziente, V.Medico ORDER BY V.Data
			ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
        ) AS UltimaVisita
FROM Visita V
WHERE YEAR(V.Data) BETWEEN 2012 AND 2014
    AND (V.Paziente = 'aaa1'
    OR V.Paziente = 'bbb4'
    OR V.Paziente = 'ccc2');


WITH terapie_target AS(
	SELECT T.Farmaco,
			T.DataInizioTerapia,
			(DATEDIFF(T.DataFineTerapia, T.DataInizioTerapia)) AS Durata
    FROM Terapia T
    WHERE T.Paziente = 'ttw2'
		AND T.DataFineTerapia IS NOT NULL
)
SELECT TT.Farmaco,
		TT.Durata,
        TT.DataInizioTerapia,
        AVG(TT.Durata) OVER(
			ORDER BY TT.DataInizioTerapia 
			ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ) AS M_Avg
FROM terapie_target TT;

SELECT V.Paziente,
		M.Matricola,
        M.Parcella,
        COUNT(*) OVER w AS visite_target,
        SUM(M.Parcella) OVER w AS Spesa
FROM Visita V
	INNER JOIN
    Medico M ON V.Medico = M.Matricola
WHERE M.Specializzazione = 'Ortopedia'
WINDOW w AS (
	PARTITION BY V.Paziente
	ORDER BY V.Data
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
);

SELECT V.Paziente,
		M.Matricola,
        M.Parcella,
        COUNT(*) OVER z AS visite_target,
        SUM(M.Parcella) OVER w AS Spesa
FROM Visita V
	INNER JOIN
    Medico M ON V.Medico = M.Matricola
WHERE M.Specializzazione = 'Ortopedia'
WINDOW w AS (
	PARTITION BY V.Paziente
	ORDER BY V.Data
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
),
z AS (
	PARTITION BY V.Paziente
	ORDER BY V.Data
	RANGE BETWEEN INTERVAL 6 MONTH PRECEDING AND INTERVAL 1 MONTH PRECEDING
);

SELECT DISTINCT M.Nome, M.Cognome, M.Specializzazione
FROM Medico M
	INNER JOIN
    Visita V ON M.Matricola = V.Medico
    LEFT OUTER JOIN(
		SELECT *
        FROM Visita V
        WHERE V.Data = '2013-03-01'
    ) AS D ON D.Medico = M.Matricola
WHERE D.Medico IS NULL;

SELECT P.CodFiscale
FROM Paziente P
WHERE P.Citta = 'Siena'
	AND P.CodFiscale NOT IN (
		SELECT V.Paziente
        FROM Visita V
        WHERE V.Medico IN (
			SELECT M.Matricola
            FROM Medico M
            WHERE M.Specializzazione = 'Ortopedia'
        )
    );

SELECT DISTINCT V.Paziente
FROM Visita V
	INNER JOIN
    Medico M ON V.Medico = M.Matricola
WHERE M.Cognome = 'Verdi'
	AND V.Paziente NOT IN (
		SELECT Paziente
		FROM Visita V1
			INNER JOIN
			Medico M1 ON V1.Medico = M1.Matricola
		WHERE M1.Cognome = 'Rossi'
    );





















