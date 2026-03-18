# Sprint_4 Michela Vistarini

> Creación y diseño de una Base de Datos con SQL
> 

# Nivel 1

El modelo propuesto para el marketplace sigue una estructura en estrella. Se ha definido la tabla **`transactions`** como la tabla de hechos del modelo, ya que en ella se registran las transacciones diarias realizadas en el marketplace.

El resto de tablas —**`american_users`**, **`european_users`**, **`credit_cards`**, **`companies`** y **`products`**— se consideran tablas de dimensiones, puesto que aportan información descriptiva y atributos adicionales que enriquecen el análisis. Sin embargo, las principales métricas de negocio se concentran en la tabla transactions, que actúa como eje central del modelo.

Para la creación de las tablas, se ha optado por ajustar directamente la longitud de los campos **VARCHAR** para optimizar el almacenamiento y asignar a cada atributo el tipo de dato más adecuado según su contenido.

Tanto el campo **`user_id`** de la tabla **`transactions`** como el **`id`** de la tabla **`user`** se ha mantenido como texto para evitar la pérdida de posibles ceros a la izquierda.

Las modificaciones de tipos de dato se han realizado durante la importación con **`SET`**

Proceso de creación:

![Screenshot 2026-03-18 at 10.23.48.png](assests/Screenshot_2026-03-18_at_10.23.48.png)

![Screenshot 2026-03-18 at 10.28.34.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.28.34.png)

![Screenshot 2026-03-18 at 10.30.27.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.30.27.png)

<aside>

Se han renombrado algunos campos para adaptarlos a una nomenclatura más habitual y cómoda de usar en el entorno de trabajo.

</aside>

Dado que la información de **`users`** estaba dividida en dos archivos en función de su origen, en el modelo final se ha decidido consolidarla en una sola tabla y añadir un campo adicional para indicar la región de origen de cada registro.

![Screenshot 2026-03-18 at 10.31.55.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.31.55.png)

![Screenshot 2026-03-18 at 10.32.43.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.32.43.png)

![Screenshot 2026-03-18 at 10.33.10.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.33.10.png)

![Screenshot 2026-03-18 at 10.34.33.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.34.33.png)

![Screenshot 2026-03-18 at 10.35.01.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.35.01.png)

![Screenshot 2026-03-18 at 10.36.55.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.36.55.png)

![Screenshot 2026-03-18 at 10.38.31.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.38.31.png)

Tablas creadas en el modelo:

![Screenshot 2026-03-18 at 10.40.27.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.40.27.png)

Creamos las conexiones entre dimensiones y tabla de hechos:

![Screenshot 2026-03-18 at 10.41.04.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.41.04.png)

Modelo resultante:

![Screenshot 2026-03-18 at 10.42.00.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.42.00.png)

Por último se añade la última tabla del modelo: **`products`**

En la tabla de hechos **`transactions`** se observa que **`products_ids`** contiene una lista de valores separada por comas, no un único valor por celda. Esto indica que una misma transacción puede incluir varios productos.

Para facilitar futuras consultas, conviene normalizar este campo en una **tabla intermedia**, donde cada fila relacione una transacción con un producto. Así se resuelve la relación **muchos a muchos (M:N)** y se simplifican los **JOIN** con la tabla de productos.

![Screenshot 2026-03-18 at 10.44.20.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.44.20.png)

![Screenshot 2026-03-18 at 10.45.25.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.45.25.png)

![Screenshot 2026-03-18 at 10.46.50.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.46.50.png)

![Screenshot 2026-03-18 at 10.47.40.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.47.40.png)

**MODELO FINAL**

![Screenshot 2026-03-18 at 10.49.05.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.49.05.png)

El modelo final podría decirse que no se trata de un esquema en estrella puro, sino de un modelo dimensional que incorpora una tabla puente. Por su estructura, presenta una organización más próxima a un esquema snowflake que a una estrella clásica ya que incorpora una tabla puente.

**Ejercicio 1.1 Usuarios con más de 80 transacciones**

![Screenshot 2026-03-18 at 10.56.42.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.56.42.png)

**Ejercicio 1.2 Media de amount por `iban` de las tarjetas de la compañía Donec Ltd.**

![Screenshot 2026-03-18 at 10.57.40.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_10.57.40.png)

# Nivel 2

**Ejercicio 2.1 Crea una nueva tabla que refleje el estado de las tarjetas de crédito: si las tres últimas transacciones han sido rechazadas, la tarjeta se considerará inactiva; si al menos una de ellas no ha sido rechazada, se considerará activa. A partir de esta tabla, responde:**

**¿Cuántas tarjetas están activas?**

![Screenshot 2026-03-18 at 11.00.36.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_11.00.36.png)

![Screenshot 2026-03-18 at 11.01.07.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_11.01.07.png)

# Nivel 3

**Ejercicio 3.1 Necesitamos conocer el número de veces que se ha vendido cada producto.**

![Screenshot 2026-03-18 at 11.02.16.png](Sprint_4%20Michela%20Vistarini/Screenshot_2026-03-18_at_11.02.16.png)
