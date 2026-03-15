# Sprint_3 Michela Vistarini

# Ampliación del modelo

Para esta fase del proyecto (Sprint 3), hemos ampliado el modelo de datos incorporando dos nuevas tablas (**`user`** y **`credit_card`**) con el objetivo de cubrir los nuevos requisitos del sprint: por un lado, registrar y relacionar de forma estructurada la información de usuarios/as; y por otro, almacenar los datos de las tarjetas de crédito asociadas a las transacciones, mejorando la trazabilidad del medio de pago y facilitando la generación de informes y consultas.

# Nivel 1

**Ejercicio 1. Añadir tabla** 

Nueva tabla **`credit_card`**

| **id** | varchar(20) PK |
| --- | --- |
| iban | varchar(50) |
| pan | varchar(50)  |
| pin | varchar(4) |
| cvv | char(3) |
| expiring_date | varchar(20) |

Definimos la tabla indicando sus campos y el tipo de dato que almacenará cada uno. Todos los atributos son de tipo **VARCHAR o CHAR** (cadenas de texto) para asegurarnos que en la importación de datos no omitimos ceros o errores por si hubiera algún espacio o signo.

![Screenshot 2026-03-12 at 11.49.32.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_11.49.32.png)

Una vez creada la tabla, importamos los datos y establecemos la relación entre **`credit_card`** y **`transaction`** mediante una clave foránea. En concreto, **`transaction.credit_card_id`** (FK) referencia a **`credit_card.id`** (PK), garantizando la integridad referencial entre ambas tablas y asociando cada transacción a una tarjeta concreta.

![Screenshot 2026-03-12 at 11.57.05.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_11.57.05.png)

**Ejercicio 1.1. Estructura del modelo**

![Screenshot 2026-03-12 at 11.59.59.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_11.59.59.png)

El modelo resultante es un **esquema en estrella**, ya que la tabla central (**`transaction`**) representa el evento principal del sistema —las transacciones del *marketplace*— y, a partir de ella, se conectan tablas auxiliares (dimensiones) que amplían y describen la información asociada a determinados campos de la tabla principal.

En este caso, las relaciones son de tipo **1:N**: cada registro en **`credit_card`**  y **`company`**es único (PK) y puede estar asociado a múltiples registros en la tabla de hechos **`transaction`**, ya que una misma tarjeta o compañía pueden intervenir en más de una transacción.

**Ejercicio 2. Modificar registro**

El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a la tarjeta de crédito con ID **CcU-2938**. La información que debe mostrarse para este registro es: **TR323456312213576817699999**. 

![Screenshot 2026-02-26 at 11.39.45.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-02-26_at_11.39.45.png)

![Screenshot 2026-02-26 at 11.46.51.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-02-26_at_11.46.51.png)

**Ejercicio 3. Añadir registro nuevo en `transaction`**

Antes de poder añadir un nuevo registro en la tabla **`transaction`**, es necesario verificar previamente la existencia de los IDs correspondientes en las tablas de dimensiones o en su defecto crearlos. De lo contrario, se producirá un error de integridad referencial, ya que la transacción no podrá asociar correctamente sus claves foráneas (IDs “hijo”) con los registros existentes en sus tablas correspondientes.

![Screenshot 2026-03-12 at 12.47.26.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_12.47.26.png)

Antes de insertar el nuevo registro, detectamos incongruencias en la información facilitada: 

- **Latitud:** el valor recibido es **829.999**, que está fuera del rango permitido para latitud (90 a -90). Para mantener la coherencia del dato y evitar almacenar un valor inválido, se registra provisionalmente como **`NULL`**, quedando pendiente de actualización del cliente.

![Screenshot 2026-03-12 at 12.51.26.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_12.51.26.png)

**Ejercicio 4. Eliminar columna `pan` de la tabla `credit_card`**

![Screenshot 2026-03-12 at 12.54.01.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_12.54.01.png)

# Nivel 2

**Ejercicio 1. Eliminar registro de la tabla `transaction`**

![Screenshot 2026-03-01 at 13.24.05.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-01_at_13.24.05.png)

![Screenshot 2026-03-01 at 13.24.36.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-01_at_13.24.36.png)

**Ejercicio 2. Vista de compañías y transacciones para el departamento de Marketing**

El departamento de marketing pide una vista con la información de contacto de cada empresa y su media de ventas ordenadas de mayor a menor.

Se ha decidido ordenar los resultados fuera de la vista para poder cambiar el orden más fácilmente en el futuro. 

![Screenshot 2026-03-12 at 12.58.07.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_12.58.07.png)

**Ejercicio 3. Vista filtrada para mostrar solo las compañías de Alemania**

![Screenshot 2026-03-04 at 19.58.14.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-04_at_19.58.14.png)

# Nivel 3

3.1. Nueva tabla **`user`**

| **id** | char(10) PK |
| --- | --- |
| name | varchar(100) |
| surname | varchar(100) |
| phone | varchar(150)  |
| email | varchar(150) |
| birth_date | varchar(100) |
| country | varchar(150) |
| city | varchar(150) |
| postal_code | varchar(100) |
| address | varchar(255) |

Esta tabla almacena la información identificativa y de contacto de cada usuario que ha realizado una transacción. Los campos se definen como tipos de texto (**VARCHAR** o **CHAR**), ya que contienen valores alfanuméricos de longitud variable o fija.

Ejecutamos el archivo .sql para crear la tabla. 

**`user`** se conecta a  **`transaction`** mediante una clave foránea: **`transaction.user_id`** (FK) referenciando **`user.id`** (PK).

Para que la relación se cree correctamente, ambos campos deben tener el mismo tipo de dato. 
En este caso, la PK **`user.id`** está definida como **CHAR(10)** y la FK correspondiente en **`transaction`** está definida como **INTEGER**, por lo que la creación de la restricción fallará por incompatibilidad de tipos.

Para resolverlo, se debe homogeneizar la tipología. En este diseño se ha optado por convertir **`user.id`** de **CHAR** a **INTEGER**, de forma que tanto **`user.id`** como **`transaction.user_id`** almacenen valores de tipo **INTEGER** y la clave foránea pueda aplicarse sin errores.

![Screenshot 2026-03-12 at 13.06.00.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_13.06.00.png)

![Screenshot 2026-03-12 at 13.07.12.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-12_at_13.07.12.png)

Al insertar un nuevo registro en **`transaction`** hemos creado un nuevo id de **`user`** que no figura en la tabla.

![Screenshot 2026-03-15 at 17.12.50.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_17.12.50.png)

**Ejercicio 1. Modificaciones en la base de datos**

El **Departamento de Marketing** solicita actualizar el modelo de datos actual conforme a los cambios definidos en el modelo adjuntado. Las modificaciones requeridas son las siguientes:

- Eliminar VistaMarketing

**Tabla `transaction`**

- Modificar logitud de VARCHAR de**`credit_card_id`**

**Tabla `user`**

- Renombrar la tabla **`user`** a **`data_user`**.
- Renombrar el campo **`mail`** a **`personal_mail`**.

![Screenshot 2026-03-15 at 17.21.30.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_17.21.30.png)

**Tabla `company`**

- Eliminar campo **`website`**

**Tabla** **`credit_card`**

- Modificar tipo de dato de **`cvv`**
- Añadir nuevo campo **`fecha_actual`**

![Screenshot 2026-03-15 at 17.34.08.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_17.34.08.png)

**Estructura del modelo modificado**

Modelo de partida:

![Screenshot 2026-03-15 at 18.55.34.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_18.55.34.png)

Modelo final:

![Screenshot 2026-03-15 at 17.36.51.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_17.36.51.png)

**Ejercicio 2. Crear vista Informe Técnico**

![Screenshot 2026-03-15 at 18.56.47.png](Sprint_3%20Michela%20Vistarini/Screenshot_2026-03-15_at_18.56.47.png)
