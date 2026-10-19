import wollok.game.*
import jardin.*

// ============================================================
// ZOMBIES
// Clase base con todo el comportamiento común. Cada subclase
// solo define lo que la hace distinta: nombre (imagen), vida y
// velocidad. Todos responden a los mismos mensajes (polimorfismo).
// ============================================================

class Zombie {
  var property position
  const property nombre         // para la imagen: nombre + ".png"
  var vida
  var msPorPaso                 // milisegundos entre paso y paso (más alto = más lento)
  var ralentizado = false
  var vivo = true
  const property danio = 10     // todavía sin usar (para cuando los zombies ataquen)
  const idTick = "movimientoZombie" + self.identity()   // id único por zombie

  method image() = nombre + ".png"
  method carril() = position.y()
  method estaVivo() = vivo

  method iniciar() {
    game.onTick(msPorPaso, idTick, { self.mover() })
  }

  method mover() {
    const siguiente = position.left(1)
    const planta = game.getObjectsIn(siguiente).findOrDefault({ o => o.esPlanta() }, null)
    if (planta != null) {
      planta.recibirDanio(danio) //queda atacando
    } else{
      position = siguiente
      if (position.x() <= 0) {      // llegó al final del carril
      jardin.perder()
    }
    }
    
  }

  // Mensaje polimórfico: cualquier proyectil le dice al objeto con el que choca "recibirImpacto".
  // El zombie reacciona recibiendo el efecto del proyectil; la planta lo ignora.
  method recibirImpacto(proyectil) {
    if (proyectil.estaViva() and vivo) {
      proyectil.impactar(self)
      proyectil.morir()
    }
  }

  method recibirDanio(cantidad) {
    vida -= cantidad
    if (vida <= 0) {
      self.morir()
    }
  }

  // Duplica el tiempo entre pasos. Como el intervalo del tick queda fijo al crearlo,
  // hay que sacar el evento y registrarlo de nuevo con el intervalo nuevo.
  method ralentizar() {
    if (vivo and !ralentizado) {
      ralentizado = true
      msPorPaso = msPorPaso * 2
      game.removeTickEvent(idTick)
      self.iniciar()
    }
  }

  method morir() {
    if (vivo) {
      vivo = false
      game.removeTickEvent(idTick)
      game.removeVisual(self)
      generadorDeZombies.zombieEliminado(self)
    }
  }
}

class ZombieNormal inherits Zombie(nombre = "zombie", vida = 100, msPorPaso = 1000) {}

// Lento pero con mucha vida
class ZombieTanque inherits Zombie(nombre = "zombie", vida = 300, msPorPaso = 2000) {}  // TODO imagen propia: "zombieTanque"

// Muy rápido pero con poca vida
class ZombieRapido inherits Zombie(nombre = "zombie", vida = 50, msPorPaso = 500) {}    // TODO imagen propia: "zombieRapido"

// ============================================================
// GENERADOR: crea zombies de tipo y carril al azar, y avisa
// al jardín cuando ya no queda ninguno de la oleada (victoria).
// ============================================================
object generadorDeZombies {
  const property zombiesActivos = []
  const totalAGenerar = 12        // tamaño de la oleada: al matarlos a todos se gana
  const msEntreZombies = 5000
  var generados = 0

  // cada "fábrica" sabe crear un tipo de zombie en la posición que le pasen
  const fabricas = [
    { posicion => new ZombieNormal(position = posicion) },
    { posicion => new ZombieTanque(position = posicion) },
    { posicion => new ZombieRapido(position = posicion) }
  ]

  method iniciar() {
    self.generar()   // el primero aparece de entrada
    game.onTick(msEntreZombies, "spawnZombies", { self.generar() })
  }

  method generar() {
    const posicion = game.at(game.width() - 1, jardin.carriles().anyOne())
    const nuevoZombie = fabricas.anyOne().apply(posicion)
    zombiesActivos.add(nuevoZombie)
    game.addVisual(nuevoZombie)
    nuevoZombie.iniciar()
    generados += 1
    if (generados == totalAGenerar) {
      game.removeTickEvent("spawnZombies")   // ya no se generan más
    }
  }

  method hayZombiesEnCarril(carril) = zombiesActivos.any({ z => z.carril() == carril })

  method zombieEliminado(unZombie) {
    zombiesActivos.remove(unZombie)
    if (generados == totalAGenerar and zombiesActivos.isEmpty()) {
      jardin.ganar()
    }
  }
}
