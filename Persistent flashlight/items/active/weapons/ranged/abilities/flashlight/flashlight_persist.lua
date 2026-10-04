-- ============================================================================
--  Persistent flashlight  -  ability NUEVA (no se modifica ningun .lua original)
-- ============================================================================
--
--  POR QUE HACE FALTA
--  flashlight.lua (vanilla) hace:
--      init()   -> self:reset()  ->  self.active = false   (al SACAR el arma)
--      uninit() -> self:reset()  ->  self.active = false   (al GUARDARLA)
--  y reset() ademas apaga las dos luces. El estado moria siempre con el ciclo
--  de vida de la ability, de ahi que la linterna nunca recordara nada.
--
--  COMO SE PERSISTE
--  Se guarda el estado en el propio objeto con activeItem.setInstanceValue()
--  (la misma API que usa el juego vanilla: ver adaptablecrossbow, que asi
--  recuerda su "ammoIndex") y se lee de vuelta con config.getParameter().
--
--  COMO SE CARGA
--  flashlight.weaponability (JSON) se parchea con flashlight.weaponability.patch
--  para que "scripts" apunte aqui y "class" sea FlashlightPersist.
--  El script vanilla se carga el primero desde ese mismo "scripts", de ahi que
--  la clase base "Flashlight" este disponible sin necesidad de require().
-- ============================================================================

-- Subclase de la ability vanilla: reutiliza todo, solo cambia la memoria.
FlashlightPersist = Flashlight:new()

function FlashlightPersist:init()
  -- En vez de reset() (que apaga y olvida), restauramos lo ultimo guardado.
  -- Partida nueva / primera vez: no hay valor -> false, igual que vanilla.
  self.active = not not config.getParameter("flashlightOn", false)

  -- Deteccion de flanco del boton: cada sacada empieza de cero.
  self.lastFireMode = nil
  self.synced = false

  self:applyLights()
end

function FlashlightPersist:applyLights()
  animator.setLightActive("flashlight", self.active)
  animator.setLightActive("flashlightSpread", self.active)
end

function FlashlightPersist:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  -- Red de seguridad: si init() llego antes de que el animator estuviera
  -- listo, reaplicamos la luz en el primer fotograma.
  if not self.synced then
    self.synced = true
    self:applyLights()
  end

  if self.fireMode == "alt" and self.lastFireMode ~= "alt" then
    self.active = not self.active
    self:applyLights()
    animator.playSound("flashlight")

    -- Se graba en cuanto se pulsa el boton, no al guardar el arma.
    activeItem.setInstanceValue("flashlightOn", self.active)
  end

  self.lastFireMode = fireMode
end

function FlashlightPersist:uninit()
  -- A proposito NO llamamos a reset(): pondria self.active = false y apagaria
  -- las luces. El valor ya quedo grabado en el update en que se pulso, asi
  -- que aqui no se hace nada y la linterna recuerda su estado.
end
