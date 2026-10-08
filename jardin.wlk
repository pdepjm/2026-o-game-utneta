import plantas.*
import zombies.*
import wollok.game.*

object jardin {
    var property plantasActivas = []

    method plantar(posicion) {
        const nuevaPlanta = new Planta(
            nombre ="lanzaguisantes",   // nombre de la planta (utilizado para ponerle la imagen)
            position = posicion,   // posicion de la planta
            vida = 100, // vida total de la planta
            velocidad = 2, // realizara la accion cada 2 segundo
            accion = {unaPlanta => unaPlanta.disparar()}) // podemos elegir la accion que realizara la planta
        plantasActivas.add(nuevaPlanta) // se la agrega a la lista de plantas que tiene el jardin
        game.addVisual(nuevaPlanta) // se le agrega la imagen
        nuevaPlanta.iniciar()   // se inicializa el tick interno de la planta para que realize su accion caracteristica
    }
}

