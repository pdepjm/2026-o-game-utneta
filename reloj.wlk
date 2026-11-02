import wollok.game.*


object reloj {
  const msPorTic = 100
  const tareas = []

  method iniciar() {
    tareas.clear()
    self.continuar()
  }

  method pausar() {
    game.removeTickEvent("reloj")
  }

  method continuar() {
    game.onTick(msPorTic, "reloj", { self.tic() })
  }

  
  method detener() {
    tareas.forEach({ tarea => tarea.terminar() })
    self.pausar()
  }

  method agregar(tarea) {
    tareas.add(tarea)
  }

  // como game.schedule: lo hace una sola vez, dentro de un rato
  method enUnRato(milisegundos, accion) {
    self.agregar(new TareaRepetida(milisegundos = milisegundos, veces = 1, accion = accion))
  }

  method tic() {
    tareas.copy().forEach({ tarea => tarea.pasarTiempo(msPorTic) })
    tareas.removeAllSuchThat({ tarea => tarea.terminada() })
  }
}


class Tarea {
  var property milisegundos
  const accion
  var acumulado = 0
  var terminada = false

  method terminada() = terminada

  method terminar() {
    terminada = true
  }

  method pasarTiempo(ms) {
    if (!terminada) {
      acumulado += ms
      if (acumulado >= milisegundos) {
        acumulado = 0
        self.hacer()
      }
    }
  }

  method hacer() {
    accion.apply()
  }
}


class TareaRepetida inherits Tarea {
  var veces

  override method hacer() {
    super()
    veces -= 1
    if (veces == 0) {
      self.terminar()
    }
  }
}
