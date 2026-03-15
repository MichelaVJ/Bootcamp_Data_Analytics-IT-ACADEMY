USE sprint3_transactions;

-- Creamos tabla credit_card y cargamos datos del archivo sql
CREATE TABLE IF NOT EXISTS credit_card (
id VARCHAR(20) PRIMARY KEY,
iban VARCHAR(50),
pan VARCHAR(50),
pin VARCHAR(4),
cvv CHAR(3),
expiring_date VARCHAR(20)
);

DESCRIBE credit_card;

-- Importamos datos a tabla credit_card
SELECT * FROM credit_card;

-- Creamos la conexión entre credit_card y la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_transaction
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

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

-- Añadir un nuevo registro en transaction
-- INSERT INTO transaction (id, credit_card_id, company_id, user_id, longitude, amount, declined)
-- VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,-117.999,111.11,0);

-- Inserta id en las tablas correspondientes.
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

-- comprobamos los inserts
SELECT id FROM company
WHERE id = 'b-9999';
SELECT * FROM credit_card
WHERE id = 'CcU-9999';

-- insertamos en transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,-117.999,111.11,0);

-- comprobamos insert
SELECT * FROM transaction
WHERE company_id = 'b-9999';

-- Eliminar campo pan de la tabla credit_card
DESCRIBE credit_card;
ALTER TABLE credit_card
DROP COLUMN pan;
DESCRIBE credit_card;

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

-- Añadir tabla user: ejecutamos sql con estructura de tabla_user para crearla.

-- Comprobamos de qué tipo son los datos
SHOW COLUMNS FROM `transaction` LIKE 'user_id';
SHOW COLUMNS FROM `user`        LIKE 'id';

-- Modificamos el tipo de dato de tabla user
ALTER TABLE user
MODIFY id INT NOT NULL;

-- Cargamos datos en user, comprobamos que se ha cargado bien.
SELECT * FROM user;

-- Añadimos el nuevo id de user que hemos creado en el nivel 1
INSERT INTO user (id) VALUES ('9999');
SELECT * FROM user
WHERE id = 9999;

-- Creamos la conexión entre user y transactions
ALTER TABLE transaction
ADD CONSTRAINT fk_user_transaction
FOREIGN KEY (user_id) REFERENCES user(id);

-- MODIFICACIONES DEL MODELO

-- 1. Eliminar vista marketing
DROP VIEW VistaMarketing;

-- 2. Igualar largo de VARCHAR en credit_card_id
ALTER TABLE transaction
MODIFY credit_card_id VARCHAR(20);

-- 3. Remobrar tabla user y campo email
RENAME TABLE user TO data_user;

ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

DESCRIBE data_user;

-- 4. Modificaciones en credit_card
ALTER TABLE credit_card
MODIFY cvv INT;

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT (CURRENT_DATE);

-- 5. Modificar tabla company
ALTER TABLE company
DROP COLUMN website;






