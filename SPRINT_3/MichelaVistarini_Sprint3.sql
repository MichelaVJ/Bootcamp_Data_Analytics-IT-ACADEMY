    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id)
    );
    
-- Creamos la tabla user   
   CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- Comprobamos de qué tipo son los datos
SHOW COLUMNS FROM `transaction` LIKE 'user_id';
SHOW COLUMNS FROM `user`        LIKE 'id';

-- Modificamos el tipo de dato de tabla user
ALTER TABLE user
MODIFY id INT NOT NULL;

-- Cargamos datos en user, comprobamos que se ha cargado bien.
SELECT * FROM user;

-- Creamos la conexión entre user y transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_user_transaction
FOREIGN KEY (user_id) REFERENCES user(id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
id VARCHAR(20) PRIMARY KEY,
iban VARCHAR(50) NOT NULL,
pan VARCHAR(50) NOT NULL,
pin VARCHAR(4) NOT NULL,
cvv INT NOT NULL,
expiring_date VARCHAR(20)
);

-- Importamos datos a tabla credit_card
SELECT * FROM credit_card;

-- Creamos la conexión con la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_transaction
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

### NIVEL 1 ###

-- Modificar número de cuenta
-- Número antiguo
SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Nuevo número
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT * FROM credit_card
WHERE id = 'CcU-2938';

SELECT * FROM transaction;

-- Añadir un nuevo registro en transaction, añadimos fecha actual, el campo de lat no tiene sentido
-- INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
-- VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,NULL,-117.999,CURRENT_TIMESTAMP,111.11,0);

-- Inserta id en las tablas correspondientes.
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO user (id) VALUES (9999);
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', 'TR000000000000000000000000', '0000000000000000', '0000', 0, NULL);

-- comprobamos los inserts
SELECT id FROM company
WHERE id = 'b-9999';
SELECT id FROM data_user 
WHERE id = 9999;
SELECT * FROM credit_card
WHERE id = 'CcU-9999';

-- insertamos en transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,NULL,-117.999,CURRENT_TIMESTAMP,111.11,0);

-- comprobamos insert
SELECT * FROM transaction
WHERE user_id = 9999;

-- Eliminar campo pan de la tabla credit_card
ALTER TABLE credit_card
DROP COLUMN pan;


### NIVEL 2 ###

-- Eliminar registro
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Crear vista para marketing Nom de la companyia.
CREATE VIEW VistaMarketing AS
SELECT 
	c.company_name, 
    c.phone, 
    c.country, 
    ROUND(AVG(t.amount), 2) AS average_sales
FROM company c
INNER JOIN transaction t
	ON c.id = t.company_id
GROUP BY c.id;

-- Ordenamos de mayor a menor
SELECT * FROM VistaMarketing
ORDER BY average_sales DESC;

-- Vista compañías alemanas
SELECT * FROM VistaMarketing
WHERE country = 'Germany';


### NIVEL 3 ###

-- modificaciones BBDD

-- 1. añadir campo de fecha actual en credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE NOT NULL DEFAULT (CURRENT_DATE);

DESCRIBE credit_card;

-- 2. Convertir a NULL los campos que no aceptan valores nulos en credit_card
ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50) NULL,
MODIFY COLUMN pin  VARCHAR(4)  NULL,
MODIFY COLUMN cvv  INT         NULL;

SHOW COLUMNS FROM credit_card;

-- 3. Eliminar campo website de tabla company
ALTER TABLE company
DROP COLUMN website;

DESCRIBE company;

-- 4. Remobrar campos y tablas 
RENAME TABLE user TO data_user;

ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

DESCRIBE data_user;

-- modificar fecha_actual para que acepte nulos
ALTER TABLE credit_card
MODIFY COLUMN fecha_actual DATE NULL;

-- Crear Vista InformeTecnico
CREATE OR REPLACE VIEW InformeTecnico AS
SELECT 
	t.id AS transaction_id,
	du.name AS user_name,
	du.surname AS user_surname,
	cc.iban,
	c.company_name,
	t.timestamp AS trans_date
FROM transaction t 
INNER JOIN data_user du
	ON du.id = t.user_id
INNER JOIN credit_card cc
	ON cc.id = t.credit_card_id
INNER JOIN company c
	ON c.id = t.company_id;

SELECT * FROM InformeTecnico
ORDER BY transaction_id;



 
