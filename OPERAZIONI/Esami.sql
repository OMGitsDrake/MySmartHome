/*
	Scrivere una query che restituisca il codice fiscale dei pazienti che hanno assunto Zitromax nel 2015 solo
	per curare patologie precedentemente già curate con successo da almeno un altro paziente della stessa città.
*/

WITH pazienti_target AS(
	SELECT P.CodFiscale, P.Citta, T.DataInizioTerapia
    FROM Paziente P
		INNER JOIN
        Terapia T ON P.CodFiscale = T.Paziente
	WHERE YEAR(T.DataInizioTerapia) = 2013
		AND T.Farmaco IN ('Exocin', 'Gentalyn Beta')
)
SELECT PT.CodFiscale
FROM pazienti_target PT
	INNER JOIN 
    Esordio E ON E.Paziente = PT.CodFiscale
WHERE E.DataGuarigione IS NOT NULL
	AND YEAR(E.DataGuarigione) <= PT.DataInizioTerapia
GROUP BY PT.Citta, PT.CodFiscale
;

/*
	Scrivere una query che restituisca la città dalla quale proviene il maggior numero di pazienti che
	non hanno sofferto d’insonnia per un numero di giorni maggiore a quello degli altri pazienti della
	loro città. In caso di pari merito restituire tutti gli ex aequo
*/

WITH pazienti_non_insonnia AS (
	SELECT P.Citta,
			DATEDIFF(T.DataFineTerapia, T.DataInizioTerapia) AS Durata
    FROM Terapia T
		INNER JOIN
        Paziente P ON P.CodFiscale = T.Paziente
	WHERE T.Patologia <> 'Insonnia'
		AND T.DataFineTerapia IS NOT NULL
),
citta_target AS(
	SELECT DISTINCT PNI.Citta,
		MAX(PNI.Durata) OVER(
			PARTITION BY PNI.Citta
		) AS N
	FROM pazienti_non_insonnia PNI
)
SELECT CT.Citta
FROM citta_target CT
GROUP BY CT.Citta
HAVING MAX(CT.N) = (
	SELECT MAX(CT1.N)
    FROM citta_target CT1
);

/*
	Implementare una business rule che consenta aumenti di prezzo dei farmaci a base di paracetamolo
	non superiori al 5% del prezzo medio attuale dei farmaci basati sullo stesso principio attivo. 
*/

DROP PROCEDURE IF EXISTS aumento_prezzi_check;
DELIMITER $$
CREATE PROCEDURE aumento_prezzi_check(IN _costo INTEGER, _principio CHAR(100))
BEGIN
	DECLARE avg_prezzo DOUBLE DEFAULT 0;
	DECLARE aumento INTEGER DEFAULT 0;
    
    SELECT AVG(F.Costo) INTO avg_prezzo
    FROM Farmaco F
    WHERE F.PrincipioAttivo = _principio;
    
    SELECT (F.Costo - _costo) INTO aumento
    FROM Farmaco F
    WHERE F.PrincipioAttivo = _principio;

	IF (aumento < 0) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore nell\'inserimento del nuovo prezzo!';
    END IF;

	IF aumento > 0.05*avg_prezzo THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aumento di prezzo troppo alto, aggiornamento non effettuato';
    ELSE
		UPDATE Farmaco
        SET Costo = _costo
        WHERE PrincipioAttivo = _principio;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER aumento_prezzi
BEFORE INSERT ON Farmaco
FOR EACH ROW
BEGIN
	CALL aumento_prezzi_check(NEW.Costo, NEW.PrincipioAttivo);
END $$
DELIMITER ;

/*
Implementare una analytic function efficiente (tramite select statement con variabili user-defined)
per ottenere il cognome dei medici aventi rank = 1 e rank = 2 in una classifica in cui un medico ottiene un rank
tanto più alto quante più visite ha effettuato rispetto agli altri medici della sua specializzazione.
Scrivere, in un commento, di quale analytic function si tratta, fra quelle viste a lezione.
*/

WITH n_visite AS (
	SELECT M.Cognome, M.Specializzazione, COUNT(*) AS Visite
    FROM Medico M
		INNER JOIN 
		Visita V ON V.Medico = M.Matricola
	GROUP BY M.Matricola, M.Specializzazione
),
primi_medici AS (
	SELECT NV.Cognome,
		DENSE_RANK() OVER(
			PARTITION BY NV.Specializzazione
			ORDER BY NV.Visite
		) AS N
	FROM n_visite NV
)
SELECT PM.Cognome
FROM primi_medici PM
WHERE PM.N IN (1, 2)
;

/*
	Scrivere una query che, considerati gli ultimi dieci anni, restituisca anno e mese (come numeri interi)
	in cui non `e stata effettuata alcuna visita in una (e una sola) specializzazione fra quelle aventi almeno
	due medici provenienti dalla stessa citt`a. Il nome di tale specializzazione deve completare il record.
*/

WITH spec_target AS (
	SELECT D.Specializzazione
	FROM Medico M
		NATURAL JOIN
		(
			SELECT M.Specializzazione
			FROM Medico M
			GROUP BY M.Specializzazione
			HAVING COUNT(*) > 1
		) AS D
	GROUP BY M.Specializzazione, M.Citta
	HAVING COUNT(*) > 1
),
anno_mese_target AS (
	SELECT DISTINCT YEAR(V.Data) AS Anno, MONTH(V.Data) as Mese
    FROM Visita V
    WHERE YEAR(V.Data) BETWEEN (YEAR(CURRENT_DATE()) - 10) AND YEAR(CURRENT_DATE())
)
SELECT AMT.Anno, AMT.Mese
FROM spec_target ST
	INNER JOIN
    Medico M ON ST.Specializzazione = M.Specializzazione
    INNER JOIN
    Visita V ON M.Matricola = V.Medico
    RIGHT OUTER JOIN
    anno_mese_target AMT ON AMT.Anno = YEAR(V.Data)
						AND AMT.Mese = MONTH(V.Data)
WHERE M.Matricola IS NULL;

/*
	Considerati i soli pazienti di Pisa e Firenze che hanno contratto al massimo una
	patologia per settore medico (una o più volte), scrivere una query che, per ogni
	paziente, restituisca il nome, il cognome, la città, il farmaco usato nel maggior
	numero di terapie, considerando nel complesso le varie patologie, e la posologia
	media. In caso di pari merito fra i farmaci usati da un paziente, completare il record
	con valori NULL.
*/

WITH pazienti_target AS (
	SELECT P.*
    FROM Paziente P
		LEFT OUTER JOIN
		(
			SELECT DISTINCT P.CodFiscale
			FROM Paziente P
			INNER JOIN
			Esordio E ON P.CodFiscale = E.Paziente
			INNER JOIN
			Patologia PA ON PA.Nome = E.Patologia
			GROUP BY E.Patologia, PA.SettoreMedico
			HAVING COUNT(DISTINCT P.CodFiscale) > 1
    ) AS D ON P.CodFiscale = D.CodFiscale
    WHERE P.Citta IN ('Firenze', 'Pisa')
),
farmaci_usati AS (
	SELECT T.Paziente, PT.Nome, PT.Cognome, PT.Citta, T.Farmaco, COUNT(*) AS Usi, AVG(T.Posologia) AS PosMedia
    FROM pazienti_target PT
		INNER JOIN
        Terapia T ON T.Paziente = PT.CodFiscale
	GROUP BY PT.CodFiscale, T.Farmaco
),
farmaci_target AS (
	SELECT *
    FROM farmaci_usati FU
    WHERE FU.Usi >= ALL (
		SELECT FU1.Usi
        FROM farmaci_usati FU1
        WHERE FU.Paziente = FU1.Paziente
			AND FU.Farmaco <> FU1.Farmaco
    )
)
SELECT FT.Paziente, FT.Nome, FT.Cognome, FT.Citta, FT.Farmaco, FT.Usi, FT.PosMedia
FROM farmaci_target FT
	LEFT OUTER JOIN
	(
		SELECT *
		FROM farmaci_target FT1
		GROUP BY FT1.Paziente
		HAVING COUNT(*) = 1
	) AS D ON FT.Paziente = D.Paziente;

/*
	Scrivere una query che consideri gli esordi di gastrite nei bimestri Febbraio-Marzo degli ultimi dieci
	anni, e restituisca in quali di questi anni pi`u del 40% degli esordi del bimestre Febbraio-marzo
	hanno riguardato, nel complesso, pazienti di Pisa e Roma, rispetto al totale degli esordi di gastrite
	dello stesso bimestre.
*/



/*
	Per ogni visita ortopedica si vuole trovare il tempo trascorso, per ogni paziente, della visita
	precedente con lo stesso medico e con un altro medico della stessa specializzazione
*/

WITH visite_ortopediche AS (
	SELECT *
    FROM Medico M
		INNER JOIN 
        Visita V ON M.Matricola = V.Medico
	WHERE M.Specializzazione = 'Ortopedia'
)
SELECT DATEDIFF(D.Data, VO.Data) AS Intervallo
SELECT DATEDIFF(D.Data, VO.Data) AS Intervallo
FROM Paziente P
	INNER JOIN
    visite_ortopediche VO ON P.CodFiscale = VO.Paziente
    INNER JOIN
    (
		SELECT VO1.Data, VO1.Paziente, VO1.Medico
        FROM visite_ortopediche VO1
    ) AS D ON D.Paziente = P.CodFiscale
		AND D.Medico <> VO.Medico
WHERE VO.Data <= D.Data
GROUP BY P.CodFiscale, VO.Medico;
















