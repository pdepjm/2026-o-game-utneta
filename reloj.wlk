import wollok.game.*

// ============================================================
// RELOJ: el único onTick del juego. Cada 100 ms les avisa a
// todas las tareas que pasó el tiempo, y cada una se hace
// cuando le toca. Lo hicimos así por dos cosas:
// - Wollok revisa todos los onTick en cada cuadro (unas 60 veces
//   por segundo): con uno por cada planta, bolita y zombie, el
//   juego se trababa.
// - Para pausar alcanza con frenar el reloj: todo se queda quieto.
// ============================================================
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

  // cuando termina la partida, lo que quedaba pendiente ya no se hace
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
    // copy() porque mientras recorremos se pueden agregar tareas (por ejemplo, una bolita nueva)
    tareas.copy().forEach({ tarea => tarea.pasarTiempo(msPorTic) })
    tareas.removeAllSuchThat({ tarea => tarea.terminada() })
  }
}

// Algo que se hace cada tantos milisegundos, como un onTick
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

// Una tarea que se hace una cantidad fija de veces y después termina
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
