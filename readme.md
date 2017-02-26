#Notas
Al ir con retraso he preferido no utilizar asyncData por lo que la carga inicial (incluye imágenes y pdfs) tarda un rato. Podría haber puesto la carga de pdfs cuando se soliciten, no lo he hecho así ya que di por hecho que esto sólo era obligado en el caso de asyncData. 

#Preguntas

##Modelo

- Primer Arranque
	- ¿Dónde guardar los datos relativos a la biblioteca, json con libros, fotos (portadas) y pdfs


>Al final me he decidido por un json en Documents ya que utilizar asyncData no es viable por el tiempo y la voy a utilizar en iOS avanzado. 


##Tabla de libros
- Guardar favoritos
	- ¿Cómo lo guardarás? ¿Se te ocurre más de una manera de hacerlo? Justifica tu decisión


>Los guardo en el mismo json, con una etiqueta nueva "isFav" y estado true si es favorito o false o inexistente si no lo es.

>Lo que he hecho es utilizar el JSON como un contexto (creo, aún no he empezado con las clases de avanzado) global accesible en toda la app, de modo que al elegir un libro como favorito se actualiza tanto su modelo, como el contexto JSON. Y dado que este contexto se graba al salir o cambiar de aplicación. Se supone que quedará guardado correctamente.

>La razón es que me parecía más limpio y sencillo que intentar modificar libro a libro. Parece matar moscas a cañonazos, pero en cambio te aseguras la integridad de los datos.



- Reflejo en tabla del cambio de la propiedad isFavorite
	- ¿cómo enviarías información de un Book a un `LibraryViewController`? ¿Se te ocurren más de una forma de hacerlo? Justifica tu decisión

>Creo que puede hacerse con delegado y con notificación. He elegido la primera, por la metáfora de ironman, al final es sólo el libro el que va a modificar la vista en ese sentido (cambio de Favorito). Además me servía para entender bien el patrón delegado, en sus tres partes: El delegador propone un contrato, el delegado propone una solución al contrato y el delegador elige quien es su delegado que entonces resuelve. Ha sido interesante ver como BookViewController (*BVC*) es delegado para LibraryTableViewController (*LTVC*) para la presentación del libro, y como *LTVC* es delegado para *BVC* para la presentación de los favoritos. 

- Utilización del método `reloadData`de `UITableView`.
	- ¿Es una aberración desde el punto de vista del rendimiento (volver a cargar datos que en su mayoría ya estaban correctos)? Explica por qué no es así

>A ver, no lo tengo muy claro. Creo que prima la integridad de los datos por encima del sobretrabajo que sea volver a cargar los datos. Por otro lado, estoy casi convencido de que el método reloadData estará optimizado para él mismo, sólo cargar aquello que claramente sea distinto.

>Supongo que intentar añadir o eliminar el item favorito de la tabla terminaría siendo una fuente de errores y el tiempo de desarrollo invertido en optimizarlo no compensaría

* ¿Hay una alternativa? ¿Cuando merece la pena usarse?

>Supongo que la utilización de los métodos *addRowsAtIndexPath* y *deleteRowsAtIndexPath*. Yo los usaría si el control de inserción o borrado lo tuviera la propia *TableView*, como por ejemplo que al pulsar en la fila se borre o se debieran añadir celdas de tipo hijo. En el caso de que la modificación sea remota o por otro controlador, es más caro explicar que he hecho que mandar todos los datos ya modificados.

##Controlador de PDF: `PDFViewController`

- Actualización de `PDFViewController` al cambiar el libro
	- ¿Como lo harías?

> Dado que al cambiar de libro ya hay dos acciones que mostrar, el cambio en el visor de la portada, autor y tags y el cambio en el lectorPDF, la mejor manera es hacerlo con una notificación. *LibraryTableViewController* avisa cuando hay un cambio de libro y *PDFViewController* recibe la notificación (a la que se ha suscrito) y actúa en consecuencia. Supongo que por simplicidad y limpieza se podría elimiar el delegado que muestra el libro y sustituirlo por una suscripción a la notificación. No lo he hecho así, he mantenido el delegado.

> Por lo que sé ahora, quizás pudiera hacerse encadenando delegados ya que del *BookViewController* depende el *PDFViewController* que he añadido vía push, luego el delegado que recibe la señal de cambio de libro podría avisar a un delegado del *PDFViewController* (algo así como una subcontrata) pero me parece muy farragoso
>  
##Extras

- ¿Qué funcionalidades le añadirías antes de subirla a la App Store?

>Añadir y quitar libros de la biblioteca

>Poner un PDFViewController decente (que permita recordar el punto de lectura en el que me quedé, anotaciones, subrayados,...)


- Usando esta app como "plantilla" ¿qué otras versiones se te ocurren? ¿Algo que puedas monetizar?

>Lo único que se me ocurre es tener un background de documentos que tengan interés (por ejemplo reglamentos técnicos que afecten a instalaciones en viviendas particulares o comunidades) bien organizados y que se puedan consultar con rápidez mediante un buen mecanismo de búsqueda. Eso desembocaría en una lista de documentos en pdf que podrías leer. Las consultas se cobrarían, bien por suscripción, bien por número de documentos. Habría que poner mecanismos para evitar la impresión física o digital de los documentos.