import wollok.game.*

object jardin {
  // zonas del tablero (12 x 7)
  const property columnaCasa = 0           // si un zombie llega acá, perdiste
  const columnasDePasto = 1..9             // solo acá se puede plantar (la 10 es la vereda)
  const property columnaCalle = 11         // de acá salen los zombies
  const property carriles = [0, 1, 2, 3, 4]   // filas por las que avanzan los zombies (la 5 es la cerca)
  const property filaDelPanel = 6          // arriba de todo, para elegir plantas
  const plantasActivas = []

  method prepararTablero() {
    game.width(columnaCalle + 1)
    game.height(filaDelPanel + 1)
    game.cellSize(220)
    game.title("Plantas vs Zombies")
    game.boardGround("fondo.png")
  }

  method reiniciar() {
    plantasActivas.clear()
  }

  method plantar(unaPlanta) {
    self.validarQueSePuedePlantarEn(unaPlanta.position())
    plantasActivas.add(unaPlanta)
    game.addVisual(unaPlanta)
    unaPlanta.iniciar()
  }

  method validarQueSePuedePlantarEn(posicion) {
    if (!self.esPasto(posicion)) {
      throw new NoSePuedePlantar(message = "Solo se puede plantar en el pasto", cartel = "avisoPasto.png")
    }
    if (self.hayPlantaEn(posicion)) {
      throw new NoSePuedePlantar(message = "Ya hay una planta acá", cartel = "avisoPlanta.png")
    }
  }

  method esPasto(posicion) = columnasDePasto.contains(posicion.x()) and carriles.contains(posicion.y())

 
  method hayPlantaEn(posicion) = plantasActivas.any({ planta => planta.position() == posicion })

  method plantaEn(posicion) = plantasActivas.find({ planta => planta.position() == posicion })

  method sacarPlanta(unaPlanta) {
    plantasActivas.remove(unaPlanta)
  }
}


class NoSePuedePlantar inherits DomainException {
  const property cartel
}
