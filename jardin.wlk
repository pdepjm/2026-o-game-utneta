import plantas.*
import zombies.*
import wollok.game.*

object jardin {
  var property pausado = false
  const property carriles = [1, 2, 3]   // filas (y) por las que avanzan los zombies
  const plantasActivas = []
  const tiksActivos = []

  method plantar(unaPlanta) {
    plantasActivas.add(unaPlanta)
    game.addVisual(unaPlanta)
    unaPlanta.iniciar()
  }

  method eliminarPlanta(unaPlanta) {
    plantasActivas.remove(unaPlanta)
  }

  // arma el jardín inicial: una planta distinta en cada carril, en la primera columna
  method iniciar() {
    self.plantar(new Lanzaguisantes(position = game.at(0, carriles.get(0))))
    self.plantar(new LanzaguisantesHielo(position = game.at(0, carriles.get(1))))
    self.plantar(new LanzaguisantesDoble(position = game.at(0, carriles.get(2))))
  }

  method agregarTiks(idTick, intervalo, accionARealizar, objetoDestino) {
    const nuevoTik = new Tiks(msAccion = intervalo, accion = accionARealizar, objeto = objetoDestino, idTick = idTick)
    nuevoTik.iniciar()
    tiksActivos.add(nuevoTik)
  }

  method eliminarTiks(idTick) {
    const aEliminar = tiksActivos.filter({ t => t.idTick() == idTick })
    aEliminar.forEach({ t => t.eliminar() }) 
    tiksActivos.removeAll(aEliminar)        
  }

  method pausar(){
    pausado = true
    game.addVisual(pausa)
    tiksActivos.forEach({ t => t.pausar() })
  }

  method reanudar(){
    pausado = false
    game.removeVisual(pausa)
    tiksActivos.forEach({ t => t.reanudar() })
  }

  method finalizar(motivo) {        
    game.clear()
    game.addVisual(motivo)
  }
}
object victoria {
  method position() = game.center()
  method image() = "ganaste.png"
}
object pausa{
  method position() = game.center()
  method image() = "pausa.png" // falta hacerlo
}
object derrota {
  method position() = game.center()
  method image() = "perdiste.png"
}

class Tiks {
  const property idTick
  var property msAccion
  var property accion
  var property objeto
  
  method iniciar(){
    game.onTick(msAccion,idTick,{accion.apply(objeto)})
  }

  method eliminar() {
  game.removeTickEvent(idTick)}

  method pausar() {
    self.eliminar() }

  method reanudar(){
    self.iniciar()  }

}