# Comunicación
Siempre mantener informados de los pasos que se estan trabajando al usuario.
La comunicacion debe ser en español
La comunicacion debe ser clara, precisa, pero rapida, ya el usuario te pedira explicitamente que de mas detalle, pero en la interacion, resumenes claros y concisos

# Gestión de Contexto
Se debe tener control sobre la ventana de contexto para evitar pérdida de información y garantizar calidad en la ejecución:
* Cada fase debe completarse en una sesión continua cuando sea posible
* Si una fase supera las 2 horas de trabajo continuo, evaluar split en sub-fases
* Si el contexto acumulado supera 50K tokens, crear checkpoint en LOGS.md y pausar
* Al retomar trabajo después de interrupción, leer LOGS.md primero para recuperar contexto
* Máximo 3 fases consecutivas sin validación del usuario
* Si se detecta acumulación excesiva de tareas pendientes, detener y consolidar antes de continuar
* Antes de iniciar fase nueva, validar que fase anterior está completamente cerrada (PR mergeado, logs actualizados)

# Logs
Se debe tener en la carpeta specs/api-admin-jerarquia/ un archivo LOGS.md donde se iran documentando la hora que se toma cada tarea y si esta completada, esto trasversal a todas las tareas, de esta manera sabemos donde retomar si el trabajo se interrumpe por cualquier motivo, mediante el logs.md tenemos un aproximado de las ultimas interaciones, en el momento de terminar la tarea marcarla como completada, sino tiene la marca se entiende que la tarea se interrumpio.
# Ramas
Nunca trabajar en main, ni crear pr hacia main, esto se pedira explicitamente en algun momento.
No deberiamos trabajar en dev, se debe crear una rama nueva a partir de dev, antes de hacer la rama, se debe validar que dev este actualizado local, y que dev este actualizado de main remoto, asi evitamos conflictos con recientes merges a main.
El deber ser que cada Fase/Tarea tenga su propia rama, pero si se considera que la Fase/Tarea, puede acumular otras, se puede agrupar las tareas en una sola rama, pero siempre se debe evitar que una rama tenga muchas responsabilidades.
# Pull Requests
Cada Rama debe tener su propia PR, y los pr deben ir a dev
Los PR deben tener un titulo claro y conciso, que indique la tarea que se esta realizando, y debe tener una descripcion detallada de los cambios realizados, asi como los pasos para probar los cambios.
Debes crear el Pr y esperar que se ejecute el CI/CD, para eso tener una fase de espera escalonada, pero maximo 5 minutos en total, si se pasa ese tiempo detener el proceso y notificar al usuario.
Palalelo a la revision de CICD, automaticamente se ejecuta el revisor de Copilot, se debe esperar que termine su revision, por lo generar crea comentarios en el pr.
## Solucion de CICD
Todos los cicd que se ejecute deben pasar correcto, sea o no sea opcional.
En Caso contrario que tenga tema los CICD se debe:
  * Crear una carpeta si no existe en specs/api-admin-jerarquia/ llamada CICD_ISSUES
  * Crear un archivo markdown con la fecha, el api y el numoero del pr
  * En la documentacion se debe crear seciones por errors y documentar cada error, la situacion en que paso, informacion valiosa que te permita tener contexto a futuro de que condicion paso ese error
  * Documentar las posibles soluciones a aplicar
  * Aplicar la solucion y documentar que se aplico
  * Generar un Id aleatorio unico para ese error, y colocarlo como titulo en la secion
    * En segunda interaccion, de errores del CICD, se debe buscar si en este archivo ya existe algun error similar, si es asi, en el momento del analisis, hay que meter en contexto la informacion del error anterior, de esta manera saber que los intentos anteriores fallaron y tener un mejor contexto
    * Ejemplo de este tipo de caso, fue en sesiones anteriores, habia un error con la version de go, que era fallas de uso de algunas dependencia, solucionar ese error, causaba otros, en el momento que analizamos los ultimos commit, dimos cuenta que la solucion era un analisis completo del cambio de version de go, y no ir parcheando errores uno a uno, y compilar testear local y ver si alguna otra dependencia fallaba
  * Al corregir todos los errores hacer push y esperar que el CICD pase correctamente, mismo principio, esperar maximo 5 minutos, si no pasa en ese tiempo, detener el proceso y notificar al usuario
## Solucion de Copilot u otro revisor
  * En caso de que el revisor automatico genere comentarios en el pr, se debe analizar cada comentario, y decidir si se aplica o no la sugerencia, con estos criterios
    * Correccion inmediata, clasificarla como prioritaria a solucionar
    * Correciones de traducion de texto o correcion de documentacion, descartarla, y justificar en el pr porque no se aplica
    * Consolidar que si aplica pero no para este pr
      * Si la solucion es rapida, usando fibonacci, de 3 puntos, aplicar la solucion en este pr
      * Si la solucion es superior a 3 puntos:
        * Si la solucion es menos de 8 puntos, crear una nueva issue en github, y documentar en el pr que se creo la issue para solucionar el tema, pero que este clasificado para ejecutarse en la siguiente fase tarea como rama intermedia, ejemoplo si estamos en la tarea 3, antes de empezar la tarea 4, se debe crear una fase tarea 3.5 y llevar el mismo estandar, crear rama de dev, crear pr, esperar cicd, etc con la solucion de la issue creada
        * Si la solucion es mayor a 8 puntos, crear una nueva issue en github, documentar en el pr que se creo la issues, pero indicar tambien al usuario que se creo una deuda tecnica, y dar las 3 posibles soluciones, y en que momento ejecutarlo, aconsejando segun el plan completo de todo el plan de trabajo
    * Aquellas sugerencias que no apliquen a los criterios anteriores, documentar en el pr porque no se aplican, e informar al usuario.
  * Esperar que el CICD pase correctamente, mismo principio, esperar maximo 5 minutos, si no pasa en ese tiempo, detener el proceso y notificar al usuario
## Al terminar las revisiones y correciones, y validado que todo se ejecuto
  * Si esta bloqueado el pr, detener y notificar al usuario
  * Si el pr puede mergearse, pero existieron issues creadas por sugerencia del revisor automaticos, de tipo que debia crearse tarea intermedia o deuda tecnica, notificar al usuario y esperar
  * Si el pr puede mergearse y todo esta ok, hacer merge y continuar a la siguiente tarea

## Excepciones
  * Nunca debe hacerse pr a main, Nunca debe hacerse pr sin pasar por dev, pero si eres la api shared, eso tendra que crearse release por modulos, asi que en aquellas modificaciones a la api shared, y el pr hizo el merge limpio a dev, validar la creacion de los releases correspondientes por modulos afectado, pero seran de dev. siempre tener un comentario presente que ese release es para dev, al final de todo, se hara un release general a main por cada modulo, pero al final, recuerda que shared debe tener un release para poder actualizarlo en los otros proyectos
