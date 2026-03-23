import type { Directive } from 'vue'
import type { Position } from '../interface'

export interface DraggableBindingValue {
  handle?: string
  cancel?: string
  position?: Position
}

type DraggableElement = HTMLElement & {
  __dragCleanup__?: () => void
  __lastBoundPosition__?: Position
}

function toElement(target: EventTarget | null): Element | null {
  return target instanceof Element ? target : null
}

function matchesWithinRoot(
  root: HTMLElement,
  target: EventTarget | null,
  selector?: string
): boolean {
  if (!selector) {
    return false
  }

  const element = toElement(target)
  const matched = element?.closest(selector)

  return !!matched && root.contains(matched)
}

function applyPosition(el: HTMLElement, position?: Position): void {
  if (!position) {
    return
  }

  el.style.left = `${position.x}px`
  el.style.top = `${position.y}px`
}

const draggable: Directive<HTMLElement, DraggableBindingValue | undefined> = {
  mounted(el, binding) {
    const target = el as DraggableElement

    el.style.position = el.style.position || 'absolute'
    applyPosition(el, binding.value?.position)
    target.__lastBoundPosition__ = binding.value?.position
      ? { ...binding.value.position }
      : undefined

    const handleMouseDown = (event: MouseEvent) => {
      if (matchesWithinRoot(el, event.target, binding.value?.cancel)) {
        return
      }

      if (
        binding.value?.handle &&
        !matchesWithinRoot(el, event.target, binding.value.handle)
      ) {
        return
      }

      const startX = event.clientX
      const startY = event.clientY
      const startLeft = Number.parseFloat(el.style.left || '0')
      const startTop = Number.parseFloat(el.style.top || '0')

      const handleMouseMove = (moveEvent: MouseEvent) => {
        const deltaX = moveEvent.clientX - startX
        const deltaY = moveEvent.clientY - startY

        el.style.left = `${startLeft + deltaX}px`
        el.style.top = `${startTop + deltaY}px`
      }

      const handleMouseUp = () => {
        document.removeEventListener('mousemove', handleMouseMove)
        document.removeEventListener('mouseup', handleMouseUp)
        document.body.style.userSelect = ''
      }

      document.body.style.userSelect = 'none'
      document.addEventListener('mousemove', handleMouseMove)
      document.addEventListener('mouseup', handleMouseUp)
    }

    el.addEventListener('mousedown', handleMouseDown)
    target.__dragCleanup__ = () => {
      el.removeEventListener('mousedown', handleMouseDown)
      document.body.style.userSelect = ''
    }
  },
  updated(el, binding) {
    const target = el as DraggableElement
    const nextPosition = binding.value?.position
    const prevPosition = target.__lastBoundPosition__

    if (
      nextPosition &&
      (!prevPosition ||
        prevPosition.x !== nextPosition.x ||
        prevPosition.y !== nextPosition.y)
    ) {
      applyPosition(el, nextPosition)
      target.__lastBoundPosition__ = { ...nextPosition }
    }
  },
  unmounted(el) {
    const target = el as DraggableElement

    target.__dragCleanup__?.()
    delete target.__lastBoundPosition__
    delete target.__dragCleanup__
  },
}

export default draggable
