import wollok.game.*
import zombies.*
import jardin.*

// ============================================================
// PLANTAS
// Planta (abstracta) -> Lanzador (abstracta) -> 3 plantas concretas.
// Cada subclase solo redefine (override) lo que cambia.
// ============================================================

class Planta {
  var property position
  var vida
  const property nombre
  const msEntreAcciones
  const idTick = "accionPlanta" + self.identity()

  method image() = nombre + ".png"

  method iniciar() {
    game.onTick(msEntreAcciones, idTick, { self.accion() })
  }

  method accion()   // abstracto: cada planta decide qué hace

  // las plantas ignoran las bolitas (polimorfismo con Zombie)
  method recibirImpacto(proyectil) {}

  method recibirDanio(cantidad) {
    vida -= cantidad
  }
}

// Plantas que disparan proyectiles por su carril
class Lanzador inherits Planta {
  method crearProyectil(posicion)   // abstracto: cada lanzador decide qué proyectil crea

  method lanzar(posicion) {
    const proyectil = self.crearProyectil(posicion)
    game.addVisual(proyectil)
    proyectil.iniciarMovimiento()
  }

  method disparar() {
    self.lanzar(position.right(1))
  }

  override method accion() {
    if (generadorDeZombies.hayZombiesEnCarril(position.y())) {   // solo dispara si hay zombies en SU carril
      self.disparar()
    }
  }
}

class Lanzaguisantes inherits Lanzador(nombre = "lanzaguisantes", vida = 100, msEntreAcciones = 2000) {
  override method crearProyectil(posicion) = new Bolita(position = posicion)
}

class LanzaguisantesHielo inherits Lanzador(nombre = "lanzaguisanteDeHielo", vida = 100, msEntreAcciones = 2000) {
  override method crearProyectil(posicion) = new BolitaHielo(position = posicion)
}

class LanzaguisantesDoble inherits Lanzador(nombre = "lanzaguisantes", vida = 100, msEntreAcciones = 3000) {  // TODO imagen propia: "lanzaguisantesDoble"
  override method crearProyectil(posicion) = new Bolita(position = posicion)

  // dispara una bolita adelante y otra pegada atrás (una celda detrás de la primera)
  override method disparar() {
    super()
    self.lanzar(position)
  }
}

// ============================================================
// PROYECTILES
// ============================================================

class Bolita {
  var property position
  var viva = true
  const idTick = "movimientoBolita" + self.identity()   // id único por bolita

  method nombre() = "guisante"
  method danio() = 25
  method image() = self.nombre() + ".png"
  method estaViva() = viva

  method iniciarMovimiento() {
    game.onTick(400, idTick, { self.mover() })
    game.onCollideDo(self, { otro => otro.recibirImpacto(self) })
  }

  method mover() {
    const siguiente = position.right(1)
    game.getObjectsIn(siguiente).copyWithout(self).forEach({ otro => if (viva) otro.recibirImpacto(self) })
    if (viva){
      position = siguiente
    if (position.x() >= game.width()) {
      self.morir()
    }
    }
    
  }

  // efecto sobre el zombie que impactó (las subclases pueden agregar efectos)
  method impactar(zombie) {
    zombie.recibirDanio(self.danio())
  }

  // dos bolitas en la misma celda no se afectan
  method recibirImpacto(otraBolita) {}

  method morir() {
    if (viva) {
      viva = false
      game.removeTickEvent(idTick)
      game.removeVisual(self)
    }
  }
}

class BolitaHielo inherits Bolita {
  override method nombre() = "guisanteDeHielo"

  override method impactar(zombie) {
    super(zombie)
    zombie.ralentizar()
  }
}
