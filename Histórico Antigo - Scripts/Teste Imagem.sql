SELECT n.cpro2s, n.cpros, n.OP, p.nops, SUM(n.pesos) as pesos, SUM(n.qtds) as qtds, n.cunis, SUM(n.qtbaixas) as qtbaixas, n.OBS
					FROM (SELECT m.cpro2s, m.cpros, l.datas, m.pesos, m.qtds, m.cunis, m.qtbaixas, Convert(varchar(max),l.obses) AS 'OBS',
										LEFT(REPLACE(
													REPLACE(
															REPLACE(
																	REPLACE(
																			REPLACE( 
																					REPLACE(Convert(varchar(max),l.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP'
							FROM SigMvCab (NOLOCK) l
								LEFT JOIN SigMvItn (NOLOCK) m ON l.empdopnums = m.empdopnums 
								WHERE (l.dopes = 'SAIDA PRODUCAO      ' OR l.dopes = 'SAIDA PRODUCAO TOTAL')
											AND l.datas >= '2020-01-01') n
											--PODE SER PUXADA PENDÊNCIA PARA OPs QUEBRADAS OU SÓ PARA AS ORIGINAIS!?!? SE SIM, A MÉTRICA PRECISA SER ALTERADA!!!!
 						INNER JOIN SigOpPic (NOLOCK) p ON LEFT(p.nops, 4) = n.OP AND p.nopmaes=0 AND RTRIM(n.cpro2s) = RTRIM(p.cpros)
							--WHERE p.nops = 72690007
						GROUP BY n.cpro2s, n.cpros, n.OP, p.nops, n.cunis, n.OBS