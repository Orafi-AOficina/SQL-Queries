SELECT A.cgrus AS 'GRP_INS', A.cpros AS 'COD_INS', A.dpros AS 'DESC_INS', A.cunis AS 'UN', A.moevs AS 'MOEDA' FROM SigCdPro AS A
WHERE A.mercs = 'INS' AND A.cgrus NOT IN ('SER', 'BRF', 'BOR', 'IMF') 
--A.cgrus IN ('IMF')
ORDER BY A.cgrus, A.cpros