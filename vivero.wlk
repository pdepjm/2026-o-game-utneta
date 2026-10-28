import wollok.game.*
import plantas.*
import jardin.*
import soles.*
import reloj.*

// ============================================================
// VIVERO: las plantas que puede elegir el jugador en el panel
// ============================================================
object vivero {
  const property opciones = [
    new OpcionDePlanta(numero = 1, nombre = "lanzaguisantes", costo = 50, segundosDeRecarga = 3, nuevaPlanta = { posicion => new Lanzaguisantes(position = posicion) }),
    new OpcionDePlanta(numero = 2, nombre = "lanzaguisanteDeHielo", costo = 75, segundosDeRecarga = 5, nuevaPlanta = { posicion => new LanzaguisantesHielo(position = posicion) }),
    new OpcionDePlanta(numero = 3, nombre = "lanzaguisantesDoble", costo = 125, segundosDeRecarga = 7, nuevaPlanta = { posicion => new LanzaguisantesDoble(position = posicion) })
  ]
  var property elegida = opciones.first()

  method reiniciar() {
    opciones.forEach({ opcion => opcion.quedarDisponible() })
    elegida = opciones.first()
  }

  method mostrarPanel() {
    game.addVisual(panel)
    opciones.forEach({ opcion => game.addVisual(opcion) })
    game.addVisual(marcoDeSeleccion)
  }

  method plantarEn(posicion) {
    elegida.plantarEn(posicion)
  }
}

class OpcionDePlanta {
  const property numero      // tecla con la que se elige y lugar en el panel
  const nombre               // la tarjeta del panel es nombre + "Tarjeta.png"
  const costo                // en soles
  const segundosDeRecarga
  const nuevaPlanta          // bloque que crea la planta en la posición que le pasen
  var recarga = disponible

  const property position = game.at(numero, jardin.filaDelPanel())
  // si no alcanzan los soles, la tarjeta se ve gris
  method image() = if (soles.alcanzan(costo)) nombre + "Tarjeta.png" else nombre + "TarjetaGris.png"

  method plantarEn(posicion) {
    recarga.validarQueSePuedePlantar()
    soles.validarQueAlcancen(costo)
    jardin.plantar(nuevaPlanta.apply(posicion))
    soles.gastar(costo)
    recarga = new Recargando(opcion = self, segundos = segundosDeRecarga)
    recarga.empezar()
  }

  method quedarDisponible() {
    recarga = disponible
  }
}

// ============================================================
// RECARGA: estados de cada opción, como la ralentización del zombie
// ============================================================

// lista para plantar
object disponible {
  method validarQueSePuedePlantar() {}
}

// se dibuja arriba de la tarjeta con los segundos que faltan
class Recargando {
  const opcion
  var segundos
  const property position = opcion.position()   // arriba de la tarjeta de su planta
  const tarea = new Tarea(milisegundos = 1000, accion = { self.pasarUnSegundo() })

  method image() = "recarga" + segundos + ".png"

  method validarQueSePuedePlantar() {
    throw new NoSePuedePlantar(message = "Todavía se está recargando", cartel = "avisoRecarga.png")
  }

  method empezar() {
    game.addVisual(self)
    reloj.agregar(tarea)
  }

  method pasarUnSegundo() {
    segundos -= 1
    if (segundos == 0) {
      tarea.terminar()
      game.removeVisual(self)
      opcion.quedarDisponible()
    }
  }
}

// ============================================================
// VISUALES DEL PANEL
// ============================================================
object panel {
  const property position = game.at(0, jardin.filaDelPanel())
  method image() = "panel.png"
}

// se dibuja arriba de la tarjeta elegida
object marcoDeSeleccion {
  method position() = vivero.elegida().position()
  method image() = "marco.png"
}

// Cartel grande con lo que no te deja plantar. Se va solo al rato.
object cartelDeAviso {
  var property image = "avisoPasto.png"

  const property position = game.at(2, 5)   // arriba del jardín, sobre la cerca

  method mostrar(unCartel) {
    image = unCartel
    if (!game.hasVisual(self)) {
      game.addVisual(self)
      reloj.enUnRato(1500, { game.removeVisual(self) })
    }
  }
}
