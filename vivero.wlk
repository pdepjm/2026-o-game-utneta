import wollok.game.*
import plantas.*
import jardin.*
import soles.*
import reloj.*


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
  const property numero      
  const nombre               
  const costo                
  const segundosDeRecarga
  const nuevaPlanta          
  var recarga = disponible

  const property position = game.at(numero, jardin.filaDelPanel())
  
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


object disponible {
  method validarQueSePuedePlantar() {}
}


class Recargando {
  const opcion
  var segundos
  const property position = opcion.position()  
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


object panel {
  const property position = game.at(0, jardin.filaDelPanel())
  method image() = "panel.png"
}


object marcoDeSeleccion {
  method position() = vivero.elegida().position()
  method image() = "marco.png"
}


object cartelDeAviso {
  var property image = "avisoPasto.png"

  const property position = game.at(2, 5)   

  method mostrar(unCartel) {
    image = unCartel
    if (!game.hasVisual(self)) {
      game.addVisual(self)
      reloj.enUnRato(1500, { game.removeVisual(self) })
    }
  }
}
