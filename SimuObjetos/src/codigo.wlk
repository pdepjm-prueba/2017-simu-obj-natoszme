//MINIONS
class ExcepcionImposibleRealizarTarea inherits Exception{}

class Minion
{
	var rol
	var estamina
	var tareasRealizadas = []
	
	method estamina() = estamina
	
	/*method intentarRealizar(tarea)
	{
		if (!tarea.puedeSerRealizadaPor(self))
		{
			throw new ExcepcionImposibleRealizarTarea()
		}
		tarea.esRealizadaPor(self)
		tareasRealizadas.add(tarea)
	}*/
	
	method intentarRealizar(tarea)
	{
		if (!tarea.puedeSerRealizadaPor(self))
		{
			throw new ExcepcionImposibleRealizarTarea()
		}
		rol.realizaTarea(self, tarea)
		tareasRealizadas.add(tarea)
	}
	
	method experiencia()
	{
		return tareasRealizadas.size() * tareasRealizadas.sum({tarea => tarea.dificultad(self)})
	}
	
	method fuerza()
	{
		return (self.fuerzaBase() + rol.fuerzaExtra()) / self.factorFuerzaPropia()
	}
	
	method fuerzaBase()
	{
		return estamina / 2 + 2
	}
	
	method factorFuerzaPropia()
	{
		return 1
	}
	
	method tieneHerramientas(herramientas)
	{
		return rol.tieneHerramientas(herramientas)
	}
	
	method perderEstamina(cantidad)
	{
		estamina = 0.max(estamina - cantidad)
	}
	
	method factorDificultadAlDefender()
	{
		return 1
	}
	
	method factorPerdidaEstaminaAlLimpiar()
	{
		rol.factorPerdidaEstaminaAlLimpiar()
	}
	
	method esMucama()
	{
		return rol.esMucama()
	}
	
	method estaminaPerdidaAlDefender()
	{
		return rol.estaminaPerdidaAlDefender(self)
	}
	
	method delegar(tarea)
	{
		rol.delegarTarea(tarea)
	}
}

class Ciclope inherits Minion
{
	override method factorFuerzaPropia()
	{
		return 2
	}
	
	override method factorDificultadAlDefender()
	{
		return 2
	}
}


//esta quedando vacia! se necesita porque Minion es abstracta
class Biclope inherits Minion
{
	
}

//ROLES
class Rol
{
	method fuerzaExtra()
	{
		return 0
	}
	
	method tieneHerramientas(herrs)
	{
		return false
	}
	
	method factorPerdidaEstaminaAlLimpiar()
	{
		return 1
	}
	
	method estaminaPerdidaAlDefender()
	{
		return 1
	}
	
	method esMucama()
	{
		return false
	}
	
	method esCapataz()
	{
		return false
	}
	
	method estaminaPerdidaAlDefender(minion)
	{
		return minion.estamina() / 2
	}
	
	//cambio de enfoque
	/*method puedeRealizar(minion, tarea)
	{
		return tarea.condicionParaPoderRealizar(minion)
	}*/
	
	method realizarTarea(minion, tarea)
	{
		tarea.esRealizadaPor(minion)	
	}
	
}

class Soldado inherits Rol
{
	var danio
	
	override method fuerzaExtra()
	{
		return danio
	}
	
	override method estaminaPerdidaAlDefender(minion)
	{
		return 0
	}
}

class Obrero inherits Rol
{
	var herraminetas = #{}
	
	override method tieneHerramientas(herramientasNecesarias)
	{
		return herraminetas == herramientasNecesarias
	}
}

class Mucama inherits Rol
{
	override method factorPerdidaEstaminaAlLimpiar()
	{
		return 0
	}
	
	override method esMucama()
	{
		return true
	}
	
	override method estaminaPerdidaAlDefender()
	{
		return 0
	}
}

class Capataz inherits Rol
{
	var subordinados = #{}
	
	/*override method esCapataz()
	{
		return true
	}
	
	method intentarDelegar(tarea)
	{
		var subordinadoMasCapaz = self.subordinadoMasCapaz(tarea)
		if (subordinadoMasCapaz)
		{
			subordinadoMasCapaz.intentarRealizar(tarea)
		}
		else
		{
			minion.
		}
	}*/
	
	override method realizarTarea(minion, tarea)
	{
		if (self.subordinadoMasCapaz(tarea))
		{
			self.subordinadoMasCapaz(tarea).intentarRealizar(tarea)
		}
		else
		{
			super(minion, tarea)
		}
	}
	
	method subordinadoMasCapaz(tarea)
	{
		return self.subordinadosOrdenadosPorExperiencia(self.subordinadosQuePuedenRealizar(tarea)).first()
	}
	
	method subordinadosOrdenadosPorExperiencia(subordinadosCandidatos)
	{
		return subordinadosCandidatos.sortedBy({unMinion, otroMinion => unMinion.experiencia() >= otroMinion.experiencia()})
	}
	
	method subordinadosQuePuedenRealizar(tarea)
	{
		return subordinados.filter({minion => tarea.puedeRealizar(minion)})
	}
}

//TAREAS
class Tarea
{
	//esto quedo medio feo
	/*method esRealizadaPor(minion)
	{
		if (minion.esCapataz())
		{
			minion.intentarDelegar(self)
		}
		else
		{
			minion.perderEstamina(self.estaminaAPerder(minion))
		}		
	}*/
	
	method esRealizadaPor(minion)
	{
		minion.perderEstamina(self.estaminaAPerder(minion))
	}
	
	method puedeSerRealizadaPor(minion)
	{
		return self.condicionParaPoderRealizar(minion)
	}
	
	method condicionParaPoderRealizar(minion)
	
	method estaminaAPerder(minion)
}

class ArreglarMaquina inherits Tarea
{
	var complejidad
	var herramientasNecesarias = #{}
	
	
	method dificultad(minion)
	{
		return 2 * complejidad
	}
	
	override method condicionParaPoderRealizar(minion)
	{
		return minion.estamina() == complejidad && minion.tieneHerramientas(herramientasNecesarias)
	}
	
	override method estaminaAPerder(minion)
	{
		return complejidad
	}
}

class DefenderSector inherits Tarea
{
	var gradoAmenaza
	
	method dificultad(minion)
	{
		return 	gradoAmenaza * minion.factorDificultadAlDefender()
	}
	
	override method condicionParaPoderRealizar(minion)
	{
		return !minion.esMucama() && minion.fuerza() >= gradoAmenaza
	}
	
	override method estaminaAPerder(minion)
	{
		//mejor usar un 'factor'? seria...
		//return minion.perderEstamina( minion.estamina() / 2 * self.factorPerdidaEstaminaAlDefender() )
		//tal vez eso seria mejor porque es este objeto el que sabe cuanto (por defecto) pierde
		return minion.estaminaPerdidaAlDefender()
	}
}

object dificultadAlLimpiar
{
	var dificultad
	
	method dificultad()
	{
		return dificultad
	} 	
}

class LimpiarSector inherits Tarea
{
	var sectorGrande
	
	/*method dificultad(nuevoNivelDificultad)
	{
		dificultad = nuevoNivelDificultad
	}*/
	
	method dificultad()
	{
		return dificultadAlLimpiar.dificultad()
	}
	
	override method condicionParaPoderRealizar(minion)
	{
		return minion.estamina() >= self.estaminaRequerida() || minion.esMucama()
	}
	
	method estaminaRequerida()
	{
		if (sectorGrande)
		{
			return 4
		}
		return 1 	
	}
	
	override method estaminaAPerder(minion)
	{
		return self.estaminaRequerida() * minion.factorPerdidaEstaminaAlLimpiar()
	}	
}