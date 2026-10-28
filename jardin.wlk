import plantas.*
import zombies.*
import wollok.game.*

object jardin {
  var property pausado = false
  const property carriles = [1, 2, 3]   // filas (y) por las que avanzan los zombies
  const plantasActivas = []
  const ticksActivos = []
  const proyectilesActivos = []

  method espacioOcupado(posicion) {
    return plantasActivas.any({planta => planta.position() == posicion})
  }

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

  method agregarTicks(idTick, intervalo, accionARealizar, objetoDestino) {
    const nuevoTick = new Ticks(msAccion = intervalo, accion = accionARealizar, objeto = objetoDestino, idTick = idTick)
    nuevoTick.iniciar()
    ticksActivos.add(nuevoTick)
  }

  method eliminarTick(idTick) {
    const tick = ticksActivos.findOrDefault({t => t.idTick() == idTick}, null)
    if (tick != null) {
      tick.eliminar()        
      ticksActivos.remove(tick)
    }
  }

  method pausar(){
    pausado = true
    game.addVisual(pausa)
    ticksActivos.forEach({ t => t.pausar() })
  }

  method reanudar(){
    pausado = false
    game.removeVisual(pausa)
    ticksActivos.forEach({ t => t.reanudar() })
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

class Ticks {
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

object seleccionador {
  var property position = game.at(0,0)
  var property eleccion = "vacio"
  method image() = "seleccionador.png"
  
  method seleccionarLanzaguisante(){
    selector.position(game.at(0,6))
    eleccion = {posicion => new Lanzaguisantes(position = posicion)}
    game.addVisual(selector)
  }
  method seleccionarLansaguisantesCongelados(){
    selector.position(game.at(1,6))
    eleccion = {posicion => new LanzaguisantesHielo(position = posicion)}
    game.addVisual(selector)
  }
  method seleccionarLansaguisantesDoble(){
    selector.position(game.at(2,6))
    eleccion = {posicion => new LanzaguisantesDoble(position = posicion)}
    game.addVisual(selector)
  }

  method plantar(posicion){
    position = posicion
    if(eleccion != "vacio" and !jardin.espacioOcupado(posicion)){      
      const plantaNueva = eleccion.apply(posicion)
      jardin.plantar(plantaNueva)
      eleccion = "vacio"
      game.removeVisual(selector)
    }
  }

  method moverIzquierda() {
    position = position.left(1)}

  method moverDerecha(){ 
    position = position.right(1)}

  method moverArriba() {
    position = position.up(1)}

  method moverAbajo() {
     position = position.down(1)}

  method recibirImpacto(proyectil){} // necesario para el polimorfismo

}

object selector{ // objeto utilizado para mostrar que opcion se selecciono para plantar
  var property position = game.origin()
  method image() = "selector.png"
}