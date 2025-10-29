Tengo la carpeta @AnalisisDetallado/ pero siento que esta desordenada, como 2 o 3 versiones, quiero que agarre lo mejor de todo y crees una carpeta en la raiz llamada AnalisisFinal
Dentro de analisis tendremos dos subcrpetas:

## docs:
* Aca coloca todos los diagramas necesario para entender 
    * Arquitectura
    * Proceso
    * Entidad Relacion ( con listas de tablas/colecciones, separada por tipo de base de datos)

* Tambien coloca las Historias de usuarios que saque segun cada procesos, para poder analizar las implicaciones


## source
* Scripts
    * Todos los scripts para crear la base de datos y estructura, separado por tipo de base de datos
    * Todos los scritps para crear los indices separado por tipo de base de datos
    * Para insertar datos mock, para poblar las diferentes base de datos
* Api Movile
    Esta es la api que usara muy seguido la aplicacion del dia a dia, aca debe estar entocados endpoint mas demandados
    Crear un documentos de que procesos pueden ir aca
    Crear codigo en go de los endpoint, documentado con swaggo, para que genere el swaggui, y que los endpoint devuelva datos mock
        Se debe crear los modelos en go, tanto para response, como request, asi como enum necesario que permita trabajar con swaggerUI
    Unos de los endpoint debe tener un metodo para cargar archivos como pdf

* Api Administracion en go
    Esta es la encargada de insertar algunas tablas, como colegio, usuarios segun el tipo de perfil alumno, profesor, etc.
    Debe exponer los endpoint necesario para el crud de varios, que no es el dia a dia
    Debe tener los modelos response , request y enum necesario para hacer swaggui

* Worker 
    Codigo en go que escuche una cola en rabbit
    Aca debe estar los modelos tanto lo que publica la cola, como los que considero que aca es donde se guarda en la base de datos de mongo



La Meta es que al terminar tendremos los procesos claro, para evaluar y empezar el desarrollo, las apis en go y el worker, no quiero codigo pulido, pero si tener ese codigo grueso de tanta carpiteria que es los endpoint, los swaggui, etc etc etc

Con el tema de source puede guiarte a lo que se hizo en la carpeta raiz @source (no confundir con el source que vas hacer dentro de la carpeta AnalisisFinal)



En el analisis descarta todas las bifurcaciones, referente, es, si decido usar solo postgresql hace esto, sino aquello, ya de entrada se toma la decision de tener (y toda aquellas mejoras que digas) varias api, varias base de datos, y el analisis seria posgresql para lo que consideres y mongo, para cada cosa, explicito sin condicional
 

Usa pensamiento profundo, Ultra Things