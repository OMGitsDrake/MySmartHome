WITH pazienti_visitati_ortopedici AS (
	SELECT DISTINCT P.CodFiscale AS Paziente
    FROM Paziente P
		INNER JOIN
        Visita V ON P.CodFiscale = V.Paziente
        INNER JOIN
        Medico M ON M.Matricola = V.Medico
	WHERE M.Specializzazione = 'Ortopedia'
)
SELECT COUNT(*)
FROM pazienti_visitati_ortopedici PVO
	INNER JOIN
    Paziente P
    ON PVO.Paziente = P.CodFiscale
WHERE P.Citta <> 'Pisa'
	AND P.Sesso = 'F';