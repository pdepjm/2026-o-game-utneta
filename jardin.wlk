import plantas.*
import zombies.*
import wollok.game.*

object jardin {
  var property pausado = false
  const property carriles = [1, 2, 3]   // filas (y) por las que avanzan los zombies
  const plantasActivas = []
  const tiksActivos = []
  const proyectilesActivos = []

  method plantar(unaPlanta) {
    plantasActivas.add(unaPlanta)
    game.addVisual(unaPlanta)
    unaPlanta.iniciar()
  }

  method eliminarPlanta(unaPlanta) {
    plantasActivas.remove(unaPlanta)
    game.removeVisual(unaPlanta)
  }

  // arma el jardín inicial: una planta distinta en cada carril, en la primera columna
  method iniciar() {
    self.plantar(new Lanzaguisantes(position = game.at(0, carriles.get(0))))
    self.plantar(new LanzaguisantesHielo(position = game.at(0, carriles.get(1))))
    self.plantar(new LanzaguisantesDoble(position = game.at(0, carriles.get(2))))
  }

  method agregarProyectil(nuevoProyectil){
    proyectilesActivos.add(nuevoProyectil)
    game.addVisual(nuevoProyectil)
  }

  method eliminarProyectil(proyectil){
    proyectilesActivos.remove(proyectil)
    game.removeVisual(proyectil)
  }

  method agregarTiks(idTik, intervalo, accionARealizar, objetoDestino) {
    const nuevoTik = new Tiks(msAccion = intervalo, accion = accionARealizar, objeto = objetoDestino, idTick = idTik)
    nuevoTik.iniciar()
    tiksActivos.add(nuevoTik)
  }

  method eliminarTik(idTik) {
    const tik = tiksActivos.find({tik => tik.idTick() == idTik})
    tik.eliminar()        
    tiksActivos.remove(tik)
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

  method reiniciar(){
    plantasActivas.forEach({planta => planta.morir()})
    generadorDeZombies.zombiesActivos().forEach({zombie => zombie.morir()})
    proyectilesActivos.forEach({proyectil => proyectil.morir()})
    generadorDeZombies.generados(0)
    if(pausado){self.reanudar()}
  }

  method finalizar(motivo) {        
    self.pausar()
    game.addVisual(motivo)
  }
}
object victoria {
  method position() = game.at(4,4)
  method image() = "ganaste.png"
}
object pausa{
  method position() = game.at(4,4)
  method image() = "pausa.png" // falta hacerlo
}
object derrota {
  method position() = game.at(4,4)
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