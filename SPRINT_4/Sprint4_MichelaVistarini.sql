-- Creamos la base de datos
CREATE DATABASE IF NOT EXISTS sprint4_transactions
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE sprint4_transactions;

-- Comprobamos si el servidor está rechazando LOCAL INFILE
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Activamos LOCAL INFILE y comprobamos
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET PERSIST local_infile = 1;

-- Debemos activar también los permisos desde My Connections OPT_LOCAL_INFILE=1 

-- Creamos la tabla de hechos transactions
CREATE TABLE IF NOT EXISTS transactions (
  id           VARCHAR(50),      -- PK
  card_id      VARCHAR(15),
  business_id  VARCHAR(20),
  timestamp    TIMESTAMP,         -- 'YYYY-MM-DD HH:MM:SS'
  amount       DECIMAL (10,2),    -- es decimal
  declined     TINYINT,           -- '0'/'1' boolean
  product_ids  VARCHAR(255),      -- lista de productos "92, 85, 36"
  user_id      CHAR(10),      
  lat          FLOAT,
  longitude    FLOAT,

  PRIMARY KEY (id)
);

DESCRIBE transactions;

-- Importamos datos
LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/transactions.csv' 
INTO TABLE transactions 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SELECT * FROM transactions;

-- AjustE nombre de campos
ALTER TABLE transactions
RENAME COLUMN business_id TO company_id,
RENAME COLUMN lat TO latitude;

DESCRIBE transactions;

-- Dimensión usuarios

CREATE TABLE IF NOT EXISTS users (
    id            CHAR (10), -- PK
    name          VARCHAR(255),
    surname       VARCHAR(255),
    phone         VARCHAR(50),
    email         VARCHAR(100),
    birth_date    DATE,
    country       VARCHAR(50),
    city          VARCHAR(50),
    postal_code   VARCHAR(20),
    address       VARCHAR(255),
    region        VARCHAR(50), -- nueva columna 
    
    PRIMARY KEY (id)
);

DESCRIBE users;

-- Cargamos datos en user, unimos american_users y european_users
LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/american_users.csv'
INTO TABLE users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date_raw, country, city, postal_code, address)
SET
  birth_date = STR_TO_DATE(@birth_date_raw, '%b %e, %Y'),
  region = 'America';
  
SELECT * FROM users;

LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/european_users.csv'
INTO TABLE users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date_raw, country, city, postal_code, address)
SET
  birth_date = STR_TO_DATE(@birth_date_raw, '%b %e, %Y'),
  region = 'Europe';

SELECT * FROM users;

-- Dimensión compañías
CREATE TABLE IF NOT EXISTS companies (
    id             VARCHAR(20), -- PK
    company_name   VARCHAR(100),
    phone          VARCHAR(20),
    email          VARCHAR(50),
    country        VARCHAR(50),
    website        VARCHAR(50),
    
    PRIMARY KEY (id)
);

DESCRIBE companies;

-- Cargamos datos
LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/companies.csv'
INTO TABLE companies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM companies;

-- Creamos tabla dimensión credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
    id              VARCHAR(15), -- PK
    user_id         CHAR (10),
    iban            VARCHAR(50),
    pan             VARCHAR(25),
    pin             CHAR(4),
    cvv             CHAR(3),
    track1          VARCHAR(100),
    track2          VARCHAR(100),
    expiring_date   DATE,
    
    PRIMARY KEY (id)
);

DESCRIBE credit_cards;

-- Cargamos datos
LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/credit_cards.csv'
INTO TABLE credit_cards
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date_raw)
SET 
  expiring_date = STR_TO_DATE(@expiring_date_raw, '%m/%d/%y');
  
SELECT * FROM credit_cards;

-- Eliminamos info redundante y ajustes de tipo datos
ALTER TABLE credit_cards
DROP COLUMN user_id;

DESCRIBE credit_cards;

-- Creamos conexiones entre tabla de hechos y dimensiones
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id)
REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (company_id)
REFERENCES companies(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

-- Creamos tabla products y tabla intermedia
CREATE TABLE IF NOT EXISTS products (
  id            VARCHAR(10),  -- PK
  product_name  VARCHAR(100),
  price         DECIMAL (10,2),
  colour        VARCHAR(20),     
  weight        DECIMAL (10,2),     
  warehouse_id  VARCHAR(20),      
  
  PRIMARY KEY (id)
);

DESCRIBE products;

-- Cargamos y transformamos datos
LOAD DATA LOCAL INFILE '/Users/michelavistarinijacas/Desktop/BOOTCAMP/SPRINT_4/DATA/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price_raw, colour, @weight_raw, warehouse_id)
SET
  price = CAST(REPLACE(@price_raw, '$', '') AS DECIMAL(10,2)),
  weight = CAST(TRIM(@weight_raw) AS DECIMAL(10,2));

SELECT * FROM products;

-- Creamos tabla puente
CREATE TABLE transactions_products (
    transaction_id VARCHAR(255),
    product_id     VARCHAR(10),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

DESCRIBE transactions_products;

-- Poblamos la tabla puente
INSERT INTO transactions_products (transaction_id, product_id)
SELECT
    t.id AS transaction_id,
    jt.product_id
FROM transactions t
JOIN JSON_TABLE(
    CONCAT('[', t.product_ids, ']'),
    '$[*]' COLUMNS (
        product_id VARCHAR(10) PATH '$'
    )
) AS jt;

SELECT * FROM transactions_products;


-- EJERCICIOS --

USE sprint4_transactions;

## NIVEL 1 ##

-- Realiza una subconsulta que muestre todos los usuarios con más de 80 transacciones.
SELECT name, surname
FROM users u
WHERE u.id 
IN
	(SELECT user_id
	 FROM transactions
     GROUP BY user_id
     HAVING COUNT(*) > 80);
 
 -- Muestra la media de amount por IBAN de las tarjetas de crédito de la compañía Donec Ltd; utiliza al menos 2 tablas.
 
 SELECT cc.iban, ROUND(AVG(amount), 2) AS avg_amount
 FROM transactions t
 JOIN credit_cards cc
	ON t.card_id = cc.id
 JOIN companies c
	 ON t.company_id = c.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

## NIVEL 2 ##

-- Crea una tabla nueva con el estado de las tarjetas: 
-- si las 3 últimas transacciones fueron rechazadas, queda inactiva; si al menos una no fue rechazada, queda activa.

CREATE TABLE IF NOT EXISTS status_credit_cards AS
WITH last_transactions AS (
    SELECT
        card_id,
        timestamp,
        declined,
        ROW_NUMBER() OVER (
            PARTITION BY card_id
            ORDER BY timestamp DESC
        ) AS row_num
    FROM transactions
)
SELECT card_id,
	CASE 
		WHEN SUM(declined) = 3 THEN 'Inactive'
		ELSE 'Active'
	END AS status
FROM last_transactions
WHERE row_num <= 3
GROUP BY card_id;

SELECT * FROM status_credit_cards;

-- Tarjetas activas
SELECT COUNT(*) AS num_actives
FROM status_credit_cards
WHERE status = 'Active';

## NIVEL 3 ##

-- Número de veces que se ha vendido un producto.
SELECT tp.product_id, p.product_name, COUNT(*) AS tot_sales  
FROM transactions_products tp
JOIN products p
ON tp.product_id = p.id
GROUP BY tp.product_id, p.product_name
ORDER BY tot_sales DESC;

