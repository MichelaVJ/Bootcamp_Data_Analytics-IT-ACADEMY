 -- Creamos la base de datos
   
# Comprobaciones
DESCRIBE company;
DESCRIBE transaction;

### NIVEL 1

-- Listado de países que han generado ventas
SELECT DISTINCT c.country as sales_country 
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id;

-- Desde cuantos países se generan ventas
SELECT COUNT(DISTINCT c.country) as num_sales_country
FROM company c 
INNER JOIN transaction t 
ON c.id = t.company_id;

-- Identifica la compañía con la media más alta en ventas.
SELECT c.id,
       c.company_name,
       ROUND(AVG(t.amount),2) AS avg_sales
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
GROUP BY c.id
ORDER BY avg_sales DESC
LIMIT 1;

-- Muestra todas las transacciones realizadaas por empresas de Alemania.
SELECT * FROM transaction t 
WHERE EXISTS
	(SELECT 1 # no queremos que selccione nada, busca si se cumple la condición (TRUE or FALSE)
	FROM company c
	WHERE c.id = t.company_id # crear filtro que une las dos tablas, como ON del JOIN
    AND c.country = 'Germany'); # filtro para empresas Alemanas
    
-- Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT DISTINCT c.company_name AS company_above_sales_avg
FROM company c 
WHERE EXISTS
	(SELECT 1
	FROM transaction t
    WHERE c.id = t.company_id
	AND t.amount > (SELECT avg(amount) FROM transaction));
    
-- Eliminaran del sistema las empresas que no tienen transacciones registradas, entrega el litado de estas empresas.
SELECT c.company_name 
FROM company c 
WHERE NOT EXISTS
	(SELECT 1 
     FROM transaction t 
     WHERE c.id = t.company_id);
     
### NIVEL 2

-- Identifica los cinco días en los que se generó la mayor cantidad de ingresos en la empresa por ventas.
-- Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT t.DATE(timestamp) AS transaction_date, COUNT(*) AS num_transactions, SUM(amount) AS tot_sales
FROM transaction
GROUP BY transaction_date
ORDER BY tot_sales DESC
LIMIT 5;

# aquí COUNT(*) suma el número de registros de cada agrupación

-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor promedio.

SELECT c.country, ROUND(AVG(amount),2) AS avg_sales
FROM company c
INNER JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.country
ORDER BY avg_sales DESC;


-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
-- Mostra el llistat aplicant solament subconsultes.

## Obtener el nombre del país dinámicamente

SELECT c.company_name, c.country, t.id, timestamp 
FROM transaction t
INNER JOIN company c 
ON c.id = t.company_id
WHERE c.company_name != 'Non Institute' # queremos ver las empresas de la competencia, descartamos Non Institute
AND EXISTS
	(SELECT 1 
     FROM company c2 # ponemos otro alias xq es la tabla de la subquery
	 WHERE c2.company_name LIKE '%Non Institute%' # Creamos la condición: que el country coincida el de Non Institute
     AND c2.country = c.country); # une con la tabla exterior

     
SELECT *
FROM transaction t
WHERE EXISTS (
    SELECT 1
    FROM company c
    WHERE c.id = t.company_id # correlacionamos tabla exterior con la interior
	AND c.country = # añadimos condición country debe ser igual que al resultado de la query
		 (SELECT country
          FROM company
          WHERE company_name = 'Non Institute') # Devuelve un único valor 'United Kingdom'
	AND c.company_name != 'Non Institute'); # añadimos una última condición, que no incluya Non Institute 
     

### NIVEL 3

-- Presenta el nombre, teléfono, país, fecha y amount de aquellas empresas que realizaron 
-- transacciones con un valor comprendido entre 350 y 400 euros 
-- en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024.

-- Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
AND t.DATE(timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen 
-- més de 400 transaccions o menys.

SELECT 
	c.company_name, 
	CASE 
		WHEN COUNT(t.id) > 400 THEN '> 400'
        ELSE '<= 400'
	END AS total_transactions
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
GROUP BY c.id;
